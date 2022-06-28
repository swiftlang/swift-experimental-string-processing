//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2021-2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

/*

Syntactic structure of a regular expression

 Regex           -> GlobalMatchingOptionSequence? RegexNode
 RegexNode       -> '' | Alternation
 Alternation     -> Concatenation ('|' Concatenation)*
 Concatenation   -> (!'|' !')' ConcatComponent)*
 ConcatComponent -> Trivia | Quote | Quantification
 Quantification  -> QuantOperand Quantifier?
 QuantOperand    -> Conditional | Group | CustomCharClass
                  | Atom | AbsentFunction

 Conditional -> CondStart Concatenation ('|' Concatenation)? ')'
 CondStart   -> KnownCondStart | GroupCondStart

 Group       -> GroupStart RegexNode ')'

Custom character classes are a mini-language to their own. We
support UTS#18 set operators and nested character classes. The
meaning of some atoms, such as `\b` changes inside a custom
chararacter class. Below, we have a grammar "scope", that is we
say "SetOp" to mean "CustomCharactetClass.SetOp", so we don't
have to abbreviate/obfuscate/disambiguate with ugly names like
"CCCSetOp".

Also, PCRE lets you end in `&&`, but not Oniguruma as it's a set
operator. We probably want a rule similar to how you can end in
`-` and that's just the character. Perhaps we also have syntax
options in case we need a compatibilty mode (it's easy to add
here and now)

 CustomCharClass -> Start Set (SetOp Set)* ']'
 Set             -> Member+
 Member          -> CustomCharClass | !']' !SetOp (Range | Atom)
 Range           -> Atom `-` Atom

Lexical analysis provides the following:

 Atom       -> `lexAtom`
 Trivia     -> `lexComment` | `lexNonSemanticWhitespace`
 Quote      -> `lexQuote`
 Quantifier -> `lexQuantifier`
 GroupStart -> `lexGroupStart`

 GroupCondStart -> `lexGroupConditionalStart`
 KnownCondStart -> `lexKnownCondition`

 CustomCharacterClass.Start -> `lexCustomCCStart`
 CustomCharacterClass.SetOp -> `lexCustomCCBinOp`

*/

struct ParsingContext {
  /// Whether we're currently parsing in a custom character class.
  fileprivate(set) var isInCustomCharacterClass = false

  /// Tracks the number of group openings we've seen, to disambiguate the '\n'
  /// syntax as a backreference or an octal sequence.
  private var priorGroupCount = 0

  /// A set of used group names.
  private var usedGroupNames = Set<String>()

  /// The syntax options currently set.
  fileprivate(set) var syntax: SyntaxOptions

  /// The current newline matching mode.
  fileprivate(set) var newlineMode: AST.GlobalMatchingOption.NewlineMatching
    = .anyCarriageReturnOrLinefeed

  fileprivate mutating func recordGroup(_ g: AST.Group.Kind) {
    // TODO: Needs to track group number resets (?|...).
    priorGroupCount += 1
    if let name = g.name {
      usedGroupNames.insert(name)
    }
  }

  init(syntax: SyntaxOptions) {
    self.syntax = syntax
  }

  /// Check whether a given reference refers to a prior group.
  func isPriorGroupRef(_ ref: AST.Reference.Kind) -> Bool {
    switch ref {
    case .absolute(let i):
      guard let i = i.value else { return false }
      return i <= priorGroupCount
    case .relative(let i):
      guard let i = i.value else { return false }
      return i < 0
    case .named(let str):
      return usedGroupNames.contains(str)
    }
  }
}

private struct Parser {
  var source: Source
  var context: ParsingContext

  init(_ source: Source, syntax: SyntaxOptions) {
    self.source = source
    self.context = ParsingContext(syntax: syntax)
  }
}

extension ParsingContext {
  var experimentalRanges: Bool { syntax.contains(.experimentalRanges) }
  var experimentalCaptures: Bool { syntax.contains(.experimentalCaptures) }
  var experimentalQuotes: Bool { syntax.contains(.experimentalQuotes) }
  var experimentalComments: Bool { syntax.contains(.experimentalComments) }
  var ignoreWhitespace: Bool { syntax.contains(.nonSemanticWhitespace) }
  var endOfLineComments: Bool { syntax.contains(.endOfLineComments) }
}

// Diagnostics
extension Parser {
  fileprivate func loc(
    _ start: Source.Position
  ) -> SourceLocation {
    SourceLocation(start ..< source.currentPosition)
  }
}

extension Parser {
  /// Parse a top-level regular expression. Do not use for recursive calls, use
  /// `parseNode()` instead.
  ///
  ///     Regex -> GlobalMatchingOptionSequence? RegexNode
  ///
  mutating func parse() throws -> AST {
    // First parse any global matching options if present.
    let opts = try source.lexGlobalMatchingOptionSequence()

    // If we have a newline mode global option, update the context accordingly.
    if let opts = opts {
      for opt in opts.options.reversed() {
        guard case .newlineMatching(let newline) = opt.kind else { continue }
        context.newlineMode = newline
        break
      }
    }

    // Then parse the root AST node.
    let ast = try parseNode()
    guard source.isEmpty else {
      // parseConcatenation() terminates on encountering a ')' to enable
      // recursive parses of a group body. However for a top-level parse, this
      // means we have an unmatched closing paren, so let's diagnose.
      if let loc = source.tryEatWithLoc(")") {
        throw Source.LocatedError(ParseError.unbalancedEndOfGroup, loc)
      }
      fatalError("Unhandled termination condition")
    }
    // TODO: Record and store diagnostics on the AST.
    return .init(ast, globalOptions: opts, diags: Diagnostics())
  }

  /// Parse a regular expression node. This should be used instead of `parse()`
  /// for recursive calls.
  ///
  ///     RegexNode    -> '' | Alternation
  ///     Alternation  -> Concatenation ('|' Concatenation)*
  ///
  mutating func parseNode() throws -> AST.Node {
    let _start = source.currentPosition

    if source.isEmpty { return .empty(.init(loc(_start))) }

    var result = [try parseConcatenation()]
    var pipes: [SourceLocation] = []
    while true {
      let pipeStart = source.currentPosition
      guard source.tryEat("|") else { break }
      pipes.append(loc(pipeStart))
      result.append(try parseConcatenation())
    }

    if result.count == 1 {
      return result[0]
    }

    return .alternation(.init(result, pipes: pipes))
  }

  /// Parse a term, potentially separated from others by `|`
  ///
  ///     Concatenation   -> (!'|' !')' ConcatComponent)*
  ///     ConcatComponent -> Trivia | Quote | Quantification
  ///     Quantification  -> QuantOperand Quantifier?
  ///
  mutating func parseConcatenation() throws -> AST.Node {
    var result = [AST.Node]()
    let _start = source.currentPosition

    while true {
      // Check for termination, e.g. of recursion or bin ops
      if source.isEmpty { break }
      if source.peek() == "|" || source.peek() == ")" { break }

      // TODO: refactor loop body into function
      let _start = source.currentPosition

      //     Trivia -> `lexTrivia`
      if let triv = try source.lexTrivia(context: context) {
        result.append(.trivia(triv))
        continue
      }

      //     Quote      -> `lexQuote`
      if let quote = try source.lexQuote(context: context) {
        result.append(.quote(quote))
        continue
      }

      // Interpolation -> `lexInterpolation`
      if let interpolation = try source.lexInterpolation() {
        result.append(.interpolation(interpolation))
        continue
      }

      //     Quantification  -> QuantOperand Quantifier?
      if let operand = try parseQuantifierOperand() {
        if let (amt, kind, trivia) =
            try source.lexQuantifier(context: context) {
          let location = loc(_start)
          result.append(.quantification(
            .init(amt, kind, operand, location, trivia: trivia)))
        } else {
          result.append(operand)
        }
        continue
      }

      throw Unreachable("TODO: reason")
    }
    guard !result.isEmpty else {
      return .empty(.init(loc(_start)))
    }
    if result.count == 1 {
      return result[0]
    }

    return .concatenation(.init(result, loc(_start)))
  }

  /// Perform a recursive parse for the branches of a conditional.
  mutating func parseConditionalBranches(
    start: Source.Position, _ cond: AST.Conditional.Condition
  ) throws -> AST.Node {
    let child = try parseNode()
    let trueBranch: AST.Node, falseBranch: AST.Node, pipe: SourceLocation?
    switch child {
    case .alternation(let a):
      // If we have an alternation child, we only accept 2 branches.
      let numBranches = a.children.count
      guard numBranches == 2 else {
        // TODO: Better API for the parser to throw located errors.
        throw Source.LocatedError(
          ParseError.tooManyBranchesInConditional(numBranches), child.location
        )
      }
      trueBranch = a.children[0]
      falseBranch = a.children[1]
      pipe = a.pipes[0]
    default:
      // If there's no alternation, the child is assumed to be the true
      // branch, with the false branch matching anything.
      trueBranch = child
      falseBranch = .empty(.init(loc(source.currentPosition)))
      pipe = nil
    }
    try source.expect(")")
    return .conditional(.init(
      cond, trueBranch: trueBranch, pipe: pipe, falseBranch: falseBranch,
      loc(start)))
  }

  /// Apply the syntax options of a given matching option sequence to the
  /// current set of options.
  private mutating func applySyntaxOptions(
    of opts: AST.MatchingOptionSequence, isScoped: Bool
  ) throws {
    func mapOption(_ option: SyntaxOptions,
                   _ pred: (AST.MatchingOption) -> Bool) {
      if opts.resetsCurrentOptions {
        context.syntax.remove(option)
      }
      if opts.adding.contains(where: pred) {
        context.syntax.insert(option)
      }
      if opts.removing.contains(where: pred) {
        context.syntax.remove(option)
      }
    }
    func mapOption(_ option: SyntaxOptions, _ kind: AST.MatchingOption.Kind) {
      mapOption(option, { $0.kind == kind })
    }

    // (?n)
    mapOption(.namedCapturesOnly, .namedCapturesOnly)

    // (?x), (?xx)
    // This cannot be unset in a multi-line literal, unless in a scoped group
    // e.g (?-x:...). We later enforce that such a group does not span multiple
    // lines.
    // TODO: PCRE differentiates between (?x) and (?xx) where only the latter
    // handles non-semantic whitespace in a custom character class. Other
    // engines such as Oniguruma, Java, and ICU do this under (?x). Therefore,
    // treat (?x) and (?xx) as the same option here. If we ever get a strict
    // PCRE mode, we will need to change this to handle that.
    if !isScoped && context.syntax.contains(.multilineCompilerLiteral) {
      // An unscoped removal of extended syntax is not allowed in a multi-line
      // literal.
      if let opt = opts.removing.first(where: \.isAnyExtended) {
        throw Source.LocatedError(
          ParseError.cannotRemoveExtendedSyntaxInMultilineMode, opt.location)
      }
      if opts.resetsCurrentOptions {
        throw Source.LocatedError(
          ParseError.cannotResetExtendedSyntaxInMultilineMode, opts.caretLoc!)
      }
      // The only remaning case is an unscoped addition of extended syntax,
      // which is a no-op.
    } else {
      // We either have a scoped change of extended syntax, or this is a
      // single-line literal.
      mapOption(.extendedSyntax, \.isAnyExtended)
    }
  }

  /// Apply the syntax options of a matching option changing group to the
  /// current set of options.
  private mutating func applySyntaxOptions(
    of group: AST.Group.Kind, isScoped: Bool
  ) throws {
    if case .changeMatchingOptions(let seq) = group {
      try applySyntaxOptions(of: seq, isScoped: isScoped)
    }
  }

  /// Perform a recursive parse for the body of a group.
  mutating func parseGroupBody(
    start: Source.Position, _ kind: AST.Located<AST.Group.Kind>
  ) throws -> AST.Group {
    context.recordGroup(kind.value)

    let currentSyntax = context.syntax
    try applySyntaxOptions(of: kind.value, isScoped: true)
    defer {
      context.syntax = currentSyntax
    }
    let unsetsExtendedSyntax = currentSyntax.contains(.extendedSyntax) &&
                              !context.syntax.contains(.extendedSyntax)
    let child = try parseNode()
    try source.expect(")")
    let groupLoc = loc(start)

    // In multi-line literals, the body of a group that unsets extended syntax
    // may not span multiple lines.
    if unsetsExtendedSyntax &&
        context.syntax.contains(.multilineCompilerLiteral) &&
        source[child.location.range].spansMultipleLinesInRegexLiteral {
      throw Source.LocatedError(
        ParseError.unsetExtendedSyntaxMayNotSpanMultipleLines, groupLoc)
    }
    return .init(kind, child, groupLoc)
  }

  /// Consume the body of an absent function.
  ///
  ///     AbsentFunction -> '(?~' RegexNode ')'
  ///                     | '(?~|' Concatenation '|' Concatenation ')'
  ///                     | '(?~|' Concatenation ')'
  ///                     | '(?~|)'
  ///
  mutating func parseAbsentFunctionBody(
    _ start: AST.Located<AST.AbsentFunction.Start>
  ) throws -> AST.AbsentFunction {
    let startLoc = start.location

    // TODO: Diagnose on nested absent functions, which Oniguruma states is
    // undefined behavior.
    let kind: AST.AbsentFunction.Kind
    switch start.value {
    case .withoutPipe:
      // Must be a repeater.
      kind = .repeater(try parseNode())
    case .withPipe where source.peek() == ")":
      kind = .clearer
    case .withPipe:
      // Can either be an expression or stopper depending on whether we have a
      // any additional '|'s.
      let child = try parseNode()
      switch child {
      case .alternation(let alt):
        // A pipe, so an expression.
        let numChildren = alt.children.count
        guard numChildren == 2 else {
          throw Source.LocatedError(
            ParseError.tooManyAbsentExpressionChildren(numChildren),
            child.location
          )
        }
        kind = .expression(
          absentee: alt.children[0], pipe: alt.pipes[0], expr: alt.children[1])
      default:
        // No pipes, so a stopper.
        kind = .stopper(child)
      }
    }
    try source.expect(")")
    return .init(kind, start: startLoc, location: loc(startLoc.start))
  }

  /// Parse a (potentially quantified) component
  ///
  ///     QuantOperand     -> Conditional | Group | CustomCharClass | Atom
  ///                       | AbsentFunction
  ///     Group            -> GroupStart RegexNode ')'
  ///     Conditional      -> CondStart Concatenation ('|' Concatenation)? ')'
  ///     CondStart        -> KnownCondStart | GroupCondStart
  ///
  mutating func parseQuantifierOperand() throws -> AST.Node? {
    assert(!source.isEmpty)

    let _start = source.currentPosition

    // Check if we have the start of a conditional '(?(cond)', which can either
    // be a known condition, or an arbitrary group condition.
    if let cond = try source.lexKnownConditionalStart(context: context) {
      return try parseConditionalBranches(start: _start, cond)
    }
    if let kind = try source.lexGroupConditionalStart(context: context) {
      let groupStart = kind.location.start
      let group = try parseGroupBody(start: groupStart, kind)
      return try parseConditionalBranches(
        start: _start, .init(.group(group), group.location))
    }

    // Check if we have an Oniguruma absent function.
    if let start = source.lexAbsentFunctionStart() {
      return .absentFunction(try parseAbsentFunctionBody(start))
    }

    // Check if we have the start of a group '('.
    if let kind = try source.lexGroupStart(context: context) {
      return .group(try parseGroupBody(start: _start, kind))
    }

    // Check if we have the start of a custom character class '['.
    if let cccStart = source.lexCustomCCStart() {
      return .customCharacterClass(
        try parseCustomCharacterClass(cccStart))
    }

    if let atom = try source.lexAtom(context: context) {
      // If we have a change matching options atom, apply the syntax options. We
      // already take care of scoping syntax options within a group.
      if case .changeMatchingOptions(let opts) = atom.kind {
        try applySyntaxOptions(of: opts, isScoped: false)
      }
      // TODO: track source locations
      return .atom(atom)
    }

    return nil
  }
}

// MARK: - Custom character classes

/// `AST.CustomCharacterClass.Start` is a mouthful
internal typealias CustomCC = AST.CustomCharacterClass

extension Parser {
  /// Parse a custom character class
  ///
  ///     CustomCharClass -> Start Set (SetOp Set)* ']'
  ///     Set             -> Member+
  ///     Member          -> CustomCharClass | !']' !SetOp (Range | Atom)
  ///     Range           -> Atom `-` Atom
  ///
  mutating func parseCustomCharacterClass(
    _ start: Source.Located<CustomCC.Start>
  ) throws -> CustomCC {
    let alreadyInCCC = context.isInCustomCharacterClass
    context.isInCustomCharacterClass = true
    defer { context.isInCustomCharacterClass = alreadyInCCC }

    typealias Member = CustomCC.Member
    var members: Array<Member> = []
    try parseCCCMembers(into: &members)

    // If we have a binary set operator, parse it and the next members. Note
    // that this means we left associate for a chain of operators.
    // TODO: We may want to diagnose and require users to disambiguate, at least
    // for chains of separate operators.
    // TODO: What about precedence?
    while let binOp = try source.lexCustomCCBinOp() {
      var rhs: Array<Member> = []
      try parseCCCMembers(into: &rhs)

      if members.none(\.isSemantic) || rhs.none(\.isSemantic) {
        throw Source.LocatedError(
          ParseError.expectedCustomCharacterClassMembers, start.location)
      }
      members = [.setOperation(members, binOp, rhs)]
    }
    if members.none(\.isSemantic) {
      throw Source.LocatedError(
        ParseError.expectedCustomCharacterClassMembers, start.location)
    }
    try source.expect("]")
    return CustomCC(start, members, loc(start.location.start))
  }

  mutating func parseCCCMember() throws -> CustomCC.Member? {
    guard !source.isEmpty && source.peek() != "]" && source.peekCCBinOp() == nil
    else { return nil }

    // Nested custom character class.
    if let cccStart = source.lexCustomCCStart() {
      return .custom(try parseCustomCharacterClass(cccStart))
    }

    // Quoted sequence.
    if let quote = try source.lexQuote(context: context) {
      return .quote(quote)
    }

    // Lex triva if we're allowed.
    if let trivia = try source.lexTrivia(context: context) {
      return .trivia(trivia)
    }

    if let atom = try source.lexAtom(context: context) {
      return .atom(atom)
    }
    return nil
  }

  mutating func parseCCCMembers(
    into members: inout Array<CustomCC.Member>
  ) throws {
    // Parse members until we see the end of the custom char class or an
    // operator.
    while let member = try parseCCCMember() {
      members.append(member)

      // If we have an atom, we can try to parse a character class range. Each
      // time we parse a component of the range, we append to `members` in case
      // it ends up not being a range, and we bail. If we succeed in parsing, we
      // remove the intermediate members.
      if case .atom(let lhs) = member {
        let membersBeforeRange = members.count - 1

        while let t = try source.lexTrivia(context: context) {
          members.append(.trivia(t))
        }

        guard let dash = source.lexCustomCharacterClassRangeOperator() else {
          continue
        }
        // If we can't parse a range, '-' becomes literal, e.g `[6-]`.
        members.append(.atom(.init(.char("-"), dash)))

        while let t = try source.lexTrivia(context: context) {
          members.append(.trivia(t))
        }
        guard let rhs = try parseCCCMember() else { continue }
        members.append(rhs)

        guard case let .atom(rhs) = rhs else { continue }

        // We've successfully parsed an atom LHS and RHS, so form a range,
        // collecting the trivia we've parsed, and replacing the members that
        // would have otherwise been added to the custom character class.
        let rangeMemberCount = members.count - membersBeforeRange
        let trivia = members.suffix(rangeMemberCount).compactMap(\.asTrivia)
        members.removeLast(rangeMemberCount)
        members.append(.range(.init(lhs, dash, rhs, trivia: trivia)))
      }
    }
  }
}

public enum ASTStage {
  /// The regex is parsed, and a syntactically valid AST is returned. Otherwise
  /// an error is thrown. This is useful for e.g syntax coloring.
  case syntactic

  /// The regex is parsed, and a syntactically and semantically valid AST is
  /// returned. Otherwise an error is thrown. A semantically valid AST has been
  /// checked for e.g unsupported constructs and invalid backreferences.
  case semantic
}

public func parse<S: StringProtocol>(
  _ regex: S, _ stage: ASTStage, _ syntax: SyntaxOptions
) throws -> AST where S.SubSequence == Substring
{
  let source = Source(String(regex))
  var parser = Parser(source, syntax: syntax)
  let ast = try parser.parse()
  switch stage {
  case .syntactic:
    break
  case .semantic:
    try validate(ast)
  }
  return ast
}

extension StringProtocol {
  /// Whether the given string is considered multi-line for a regex literal.
  var spansMultipleLinesInRegexLiteral: Bool {
    unicodeScalars.contains(where: { $0 == "\n" || $0 == "\r" })
  }
}

/// Retrieve the default set of syntax options that a delimiter and literal
/// contents indicates.
fileprivate func defaultSyntaxOptions(
  _ delim: Delimiter, contents: String
) -> SyntaxOptions {
  switch delim.kind {
  case .forwardSlash:
    // For an extended syntax forward slash e.g #/.../#, extended syntax is
    // permitted if it spans multiple lines.
    if delim.poundCount > 0 && contents.spansMultipleLinesInRegexLiteral {
      return [.multilineCompilerLiteral, .extendedSyntax]
    }
    return .traditional
  case .reSingleQuote:
    return .traditional
  case .experimental, .rxSingleQuote:
    return .experimental
  }
}

/// Parses a given regex string with delimiters, inferring the syntax options
/// from the delimiters used.
public func parseWithDelimiters<S: StringProtocol>(
  _ regex: S, _ stage: ASTStage
) throws -> AST where S.SubSequence == Substring {
  let (contents, delim) = droppingRegexDelimiters(String(regex))
  do {
    let syntax = defaultSyntaxOptions(delim, contents: contents)
    return try parse(contents, stage, syntax)
  } catch let error as LocatedErrorProtocol {
    // Convert the range in 'contents' to the range in 'regex'.
    let delimCount = delim.opening.count
    let offsets = contents.offsets(of: error.location.range)
    let startIndex = regex.index(atOffset: delimCount + offsets.lowerBound)
    let endIndex = regex.index(atOffset: delimCount + offsets.upperBound)

    throw error._typeErasedError.addingLocation(startIndex..<endIndex)
  }
}
