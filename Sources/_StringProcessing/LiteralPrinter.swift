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

internal import _RegexParser

@available(SwiftStdlib 5.7, *)
extension Regex {
  /// The literal pattern for this regex.
  ///
  /// This is non-`nil` when used on a regex that can be represented as a
  /// string. The literal pattern may be different from the literal or string
  /// that was used to create the regex, though parsing the `_literalPattern`
  /// always generates the same internal representation as the original regex.
  ///
  ///     // The literal pattern for some regexes is identical to the original:
  ///     let regex1 = /(\d+):(\d+)/
  ///     // regex1._literalPattern == #"(\d+):(\d+)"#
  ///
  ///     // The literal pattern for others is different, but equivalent:
  ///     let regex2 = /\p{isName=BEE}/
  ///     // regex2._literalPattern == #"\N{BEE}"#
  ///
  /// If this regex includes components that cannot be represented in a regex
  /// literal, such as a capture transform or a custom parser that conforms to
  /// the `CustomConsumingRegexComponent` protocol, this property is `nil`.
  ///
  /// The value of this property may change between different releases of Swift.
  @available(SwiftStdlib 6.0, *)
  public var _literalPattern: String? {
    var gen = LiteralPrinter(options: MatchingOptions())
    gen.outputNode(self.program.tree.root)
    return gen.canonicalLiteralString
  }
}

enum PatternSegment {
  case converted(String)
  case inconvertible(DSLTree.Node)
  
  var string: String? {
    switch self {
    case let .converted(str):
      return str
    case .inconvertible:
      return nil
    }
  }
}

fileprivate struct LiteralPrinter {
  var options: MatchingOptions
  private var segments: [PatternSegment] = []
  
  init(options: MatchingOptions) {
    self.options = options
  }
  
  var canonicalLiteralString: String? {
    var result = ""
    result.reserveCapacity(segments.count)
    
    for segment in segments {
      guard let str = segment.string else {
        return nil
      }
      result.append(str)
    }
    return result
  }
  
  mutating func output(_ str: String) {
    segments.append(.converted(str))
  }
  
  mutating func saveInconvertible(_ node: DSLTree.Node) {
    segments.append(.inconvertible(node))
  }
}

extension LiteralPrinter {
  mutating func outputNode(_ node: DSLTree.Node) {
    switch node {
    case let .orderedChoice(children):
      outputAlternation(children)
    case let .concatenation(children):
      outputConcatenation(children)
      
    case let .capture(name, nil, child, nil):
      options.beginScope()
      defer { options.endScope() }
      outputCapture(name, child)
    case .capture:
      // Captures that use a reference or a transform are unsupported
      saveInconvertible(node)
      
    case let .nonCapturingGroup(kind, child):
      guard let kindPattern = kind._patternString else {
        saveInconvertible(node)
        return
      }
      options.beginScope()
      defer { options.endScope() }

      output(kindPattern)
      if case .changeMatchingOptions(let optionSequence) = kind.ast {
        options.apply(optionSequence)
      }
      outputNode(child)
      output(")")
      
    case let .ignoreCapturesInTypedOutput(child),
         let .limitCaptureNesting(child):
      outputNode(child)
    case let .quantification(amount, kind, node):
      outputQuantification(amount, kind, node)
    case let .customCharacterClass(charClass):
      outputCustomCharacterClass(charClass)
    case let .atom(atom):
      outputAtom(atom)
    case let .quotedLiteral(literal):
      output(prepareQuotedLiteral(literal))

    case .trivia(_):
      // TODO: Include trivia?
      return
    case .empty:
      return

    case .conditional, .absentFunction, .consumer, .matcher, .characterPredicate:
      saveInconvertible(node)
    }
  }
  
  mutating func outputAlternation(_ children: [DSLTree.Node]) {
    guard let first = children.first else { return }
    
    outputNode(first)
    for child in children.dropFirst() {
      output("|")
      outputNode(child)
    }
  }
  
  mutating func outputConcatenation(_ children: [DSLTree.Node]) {
    for child in children {
      outputNode(child)
    }
  }
  
  mutating func outputCapture(_ name: String?, _ child: DSLTree.Node) {
    if let name {
      output("(?<\(name)>")
    } else {
      output("(")
    }
    outputNode(child)
    output(")")
  }
  
  func requiresGrouping(_ node: DSLTree.Node) -> Bool {
    switch node {
    case .concatenation(let children):
      switch children.count {
      case 0:
        return false
      case 1:
        return requiresGrouping(children.first!)
      default:
        return true
      }
      
    case .quotedLiteral(let literal):
      return prepareQuotedLiteral(literal).count > 1
      
    default:
      return false
    }
  }

  mutating func outputQuantification(
    _ amount: DSLTree._AST.QuantificationAmount,
    _ kind: DSLTree.QuantificationKind,
    _ child: DSLTree.Node
  ) {
    // RegexBuilder regexes can have children that need 
    if requiresGrouping(child) {
      output("(?:")
      outputNode(child)
      output(")")
    } else {
      outputNode(child)
    }

    switch amount.ast {
    case .zeroOrMore:
      output("*")
    case .oneOrMore:
      output("+")
    case .zeroOrOne:
      output("?")
    case let .exactly(n):
      output("{\(n.value!)}")
    case let .nOrMore(n):
      output("{\(n.value!),}")
    case let .upToN(n):
      output("{,\(n.value!)}")
    case let .range(low, high):
      output("{\(low.value!),\(high.value!)}")
    #if RESILIENT_LIBRARIES
    @unknown default:
      fatalError()
    #endif
    }
    
    outputQuantificationKind(kind)
  }
  
  mutating func outputQuantificationKind(_ kind: DSLTree.QuantificationKind) {
    guard let astKind = kind.quantificationKind?.ast else {
      // We can treat this as if the current default had been given explicity.
      outputQuantificationKind(
        .explicit(.init(ast: options.defaultQuantificationKind)))
      return
    }
    
    if kind.isExplicit {
      // Explicitly provided modifiers need to match the current option state.
      switch astKind {
      case .eager:
        output(options.isReluctantByDefault ? "?" : "")
      case .reluctant:
        output(options.isReluctantByDefault ? "" : "?")
      case .possessive:
        output("+")
      #if RESILIENT_LIBRARIES
      @unknown default:
        fatalError()
      #endif
      }
    } else {
      // Syntactically-specified quantification modifiers can stay as-is.
      switch astKind {
      case .eager:
        output("")
      case .reluctant:
        output("?")
      case .possessive:
        output("+")
      #if RESILIENT_LIBRARIES
      @unknown default:
        fatalError()
      #endif
      }
    }
  }

  mutating func outputAssertion(_ assertion: DSLTree.Atom.Assertion) {
    switch assertion {
    case .startOfSubject:
      output(#"\A"#)
    case .endOfSubjectBeforeNewline:
      output(#"\Z"#)
    case .endOfSubject:
      output(#"\z"#)
    case .resetStartOfMatch:
      output(#"\K"#)
    case .firstMatchingPositionInSubject:
      output(#"\G"#)
    case .textSegment:
      output(#"\y"#)
    case .notTextSegment:
      output(#"\Y"#)
    case .startOfLine:
      if options.anchorsMatchNewlines {
        output(#"^"#)
      } else {
        output(#"(?m:^)"#)
      }
    case .endOfLine:
      if options.anchorsMatchNewlines {
        output(#"$"#)
      } else {
        output(#"(?m:$)"#)
      }
    case .caretAnchor:
      output("^")
    case .dollarAnchor:
      output("$")
    case .wordBoundary:
      output(#"\b"#)
    case .notWordBoundary:
      output(#"\B"#)
    }
  }
  
  mutating func outputAtom(_ atom: DSLTree.Atom) {
    switch atom {
    case .char(let char):
      output(char.escapingForLiteral)
    case .scalar(let scalar):
      output(scalar.escapedString)
    case .any:
      if options.dotMatchesNewline {
        output(".")
      } else {
        output("(?s:.)")
      }
    case .anyNonNewline:
      if options.dotMatchesNewline {
        output("(?-s:.)")
      } else {
        output(".")
      }
    case .dot:
      output(".")
    case .characterClass(let charClass):
      if let patt = charClass._patternString {
        output(patt)
      } else {
        saveInconvertible(.atom(atom))
      }
    case .assertion(let assertion):
      outputAssertion(assertion)
    case .backreference(let backref):
      outputReference(backref)
    case .symbolicReference(_):
      // RegexBuilder only
      saveInconvertible(.atom(atom))
    case .changeMatchingOptions(let optionSequence):
      output(optionSequence.ast._patternString)
      output(")")
      options.apply(optionSequence.ast)
    case .unconverted(let atom):
      outputUnconvertedAST(atom.ast)
    }
  }
  
  mutating func outputReference(_ ref: DSLTree._AST.Reference) {
    switch ref.ast.kind {
    case .absolute(let number):
      guard let value = number.value else {
        saveInconvertible(.atom(.backreference(ref)))
        return
      }
      if value < 10 {
        output("\\\(value)")
      } else {
        output("\\g{\(value)}")
      }
    case .relative(let number):
      guard let value = number.value else {
        saveInconvertible(.atom(.backreference(ref)))
        return
      }
      let prefix = value < 0 ? "-" : "+"
      output("\\g{\(prefix)\(abs(value))}")
    case .named(let name):
      output("\\g{\(name)}")
    #if RESILIENT_LIBRARIES
    @unknown default:
      fatalError()
    #endif
    }
  }
  
  func prepareQuotedLiteral(_ literal: String) -> String {
    if options.usesExtendedWhitespace || literal.containsRegexMetaCharacters {
      return #"\Q\#(literal)\E"#
    } else {
      return literal.escapingConfusableCharacters()
    }
  }
  
  mutating func outputCustomCharacterClass(_ charClass: DSLTree.CustomCharacterClass) {
    // Sometimes we end up with a singly-wrapped CCC — flatten it out
    if !charClass.isInverted {
      let trivialessMembers = charClass.members.filter {
        if case .trivia = $0 { return false } else { return true }
      }
      if trivialessMembers.count == 1,
         case let .custom(inner) = trivialessMembers[0] {
        outputCustomCharacterClass(inner)
        return
      }
    }
    
    output(charClass.isInverted ? "[^" : "[")
    for member in charClass.members {
      switch member {
      case let .atom(atom):
        outputAtom(atom)
      case let .range(low, high):
        outputAtom(low)
        output("-")
        outputAtom(high)
      case let .custom(charClass):
        outputCustomCharacterClass(charClass)
      case let .quotedLiteral(literal):
        if options.usesExtendedWhitespace || literal.containsRegexMetaCharacters {
          output(#"\Q\#(literal)\E"#)
        } else {
          output(literal)
        }
      case .trivia(_):
        // TODO: ignore trivia?
        break
      case let .intersection(left, right):
        outputCustomCharacterClass(left)
        output("&&")
        outputCustomCharacterClass(right)
      case let .subtraction(left, right):
        outputCustomCharacterClass(left)
        output("--")
        outputCustomCharacterClass(right)
      case let .symmetricDifference(left, right):
        outputCustomCharacterClass(left)
        output("~~")
        outputCustomCharacterClass(right)
      }
    }
    output("]")
  }
  
  mutating func outputUnconvertedAST(_ ast: AST.Atom) {
    switch ast.kind {
    case let .property(property):
      if let base = property._regexBase {
        output(base)
      } else {
        saveInconvertible(.atom(.unconverted(.init(ast: ast))))
      }
    case let .namedCharacter(name):
      output("\\N{\(name)}")
    default:
      saveInconvertible(.atom(.unconverted(.init(ast: ast))))
    }
  }
}

// MARK: - Supporting extensions

fileprivate let metachars = Set(#"\[](){}|+*?^$.-"#)

extension String {
  var containsRegexMetaCharacters: Bool {
    contains(where: \.isRegexMetaCharacter)
  }
  
  func escapingConfusableCharacters() -> String {
    lazy.map(\.escapingConfusable).joined()
  }
}

extension UnicodeScalar {
  var escapedString: String {
    switch self {
    case "\n": return #"\n"#
    case "\r": return #"\r"#
    case "\t": return #"\t"#
    default:
      let code = String(value, radix: 16, uppercase: true)
      let prefix = code.count <= 4
        ? #"\u"# + String(repeating: "0", count: 4 - code.count)
        : #"\U"# + String(repeating: "0", count: 8 - code.count)
      return prefix + code
    }
  }
}

extension Character {
  var isRegexMetaCharacter: Bool {
    metachars.contains(self)
  }
  
  var escapingConfusable: String {
    if isConfusable {
      return String(unicodeScalars.first!) +
        unicodeScalars.dropFirst().lazy.map(\.escapedString).joined()
    } else {
      return String(self)
    }
  }
  
  var escapingForLiteral: String {
    if isRegexMetaCharacter {
      return "\\\(self)"
    } else {
      return escapingConfusable
    }
  }
}

// MARK: Pattern Strings

// Pattern representation for the types below is unaffected by the regex's
// options state, so they can be pure conversions.

extension DSLTree.Atom.CharacterClass {
  fileprivate var _patternString: String? {
    switch self {
    case .digit:
      return #"\d"#
    case .notDigit:
      return #"\D"#
    case .horizontalWhitespace:
      return #"\h"#
    case .notHorizontalWhitespace:
      return #"\H"#
    case .newlineSequence:
      return #"\R"#
    case .notNewline:
      return #"\N"#
    case .whitespace:
      return #"\s"#
    case .notWhitespace:
      return #"\S"#
    case .verticalWhitespace:
      return #"\v"#
    case .notVerticalWhitespace:
      return #"\V"#
    case .word:
      return #"\w"#
    case .notWord:
      return #"\W"#
    case .anyGrapheme:
      return #"\X"#
    case .anyUnicodeScalar:
      return nil
    }
  }
}

extension AST.MatchingOption.Kind {
  fileprivate var _patternString: String? {
    switch self {
    // PCRE options
    case .caseInsensitive: return "i"
    case .allowDuplicateGroupNames: return "J"
    case .multiline: return "m"
    case .namedCapturesOnly: return "n"
    case .singleLine: return "s"
    case .reluctantByDefault: return "U"
    case .extended: return "x"
    case .extraExtended: return "xx"
      
    // ICU options
    case .unicodeWordBoundaries: return "w"
      
    // Oniguruma options
    case .asciiOnlyDigit: return "D"
    case .asciiOnlyPOSIXProps: return "P"
    case .asciiOnlySpace: return "S"
    case .asciiOnlyWord: return "W"
      
    // Oniguruma text segment options (these are mutually exclusive and cannot
    // be unset, only flipped between)
    case .textSegmentGraphemeMode: return "y{g}"
    case .textSegmentWordMode: return "y{w}"
      
    // Swift semantic matching level
    case .graphemeClusterSemantics: return "X"
    case .unicodeScalarSemantics: return "u"
    case .byteSemantics: return "b"
      
    // Swift-only default possessive quantifier
    case .possessiveByDefault: return nil
      
    // NSRE Compatibility option; no literal representation
    case .nsreCompatibleDot: return nil

    #if RESILIENT_LIBRARIES
    @unknown default:
      fatalError()
    #endif
    }
  }
}

extension AST.MatchingOptionSequence {
  fileprivate var _patternString: String {
    let adding = adding.compactMap(\.kind._patternString).joined()
    let removing = removing.compactMap(\.kind._patternString).joined()
    
    if resetsCurrentOptions {
      assert(removing.isEmpty)
      return "(?^\(adding)"
    } else {
      return "(?\(adding)"
      + (removing.isEmpty ? "" : "-\(removing)")
    }
  }
}

extension DSLTree._AST.GroupKind {
  fileprivate var _patternString: String? {
    switch self.ast {
    case .capture:                return "("
    case .namedCapture(let n):    return "(?<\(n.value)>"
    case .balancedCapture(_):     return nil
    case .nonCapture:             return "(?:"
    case .nonCaptureReset:        return "(?|"
    case .atomicNonCapturing:     return "(?>"
    case .lookahead:              return "(?="
    case .negativeLookahead:      return "(?!"
    case .nonAtomicLookahead:     return "(?*"
    case .lookbehind:             return "(?<="
    case .negativeLookbehind:     return "(?<!"
    case .nonAtomicLookbehind:    return "(?<*"
    case .scriptRun:              return "(*sr:"
    case .atomicScriptRun:        return "(*asr:"
      
    case let .changeMatchingOptions(sequence):
      return sequence._patternString + ":"

    #if RESILIENT_LIBRARIES
    @unknown default:
      fatalError()
    #endif
    }
  }
}
