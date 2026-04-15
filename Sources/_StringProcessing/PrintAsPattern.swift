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

// TODO: Add an expansion level, both from top to bottom.
//       After `printAsCanonical` is fleshed out, these two
//       printers can call each other. This would enable
//       incremental conversion, such that leaves remain
//       as canonical regex literals.

/// Renders an AST tree as a Pattern DSL.
///
/// - Parameters:
///   - ast: A `_RegexParser.AST` instance.
///   - maxTopDownLevels: The number of levels down from the root of the tree
///     to perform conversion. `nil` means no limit.
///   - minBottomUpLevels: The number of levels up from the leaves of the tree
///     to perform conversion. `nil` means no limit.
/// - Returns: A string representation of `ast` in the `RegexBuilder` syntax.
@_spi(PatternConverter)
public func renderAsBuilderDSL(
  ast: Any,
  maxTopDownLevels: Int? = nil,
  minBottomUpLevels: Int? = nil
) -> String {
  var printer = PrettyPrinter(
    maxTopDownLevels: maxTopDownLevels,
    minBottomUpLevels: minBottomUpLevels)
  printer.printAsPattern(ast as! AST)
  return printer.finish()
}

extension PrettyPrinter {
  mutating func printAsPattern(_ ast: AST) {
    let list = DSLList(ast: ast)

    // If we have any named captures, create references to those above the regex.
    let namedCaptures = list.getNamedCaptures()

    for namedCapture in namedCaptures {
      print("let \(namedCapture) = Reference(Substring.self)")
    }

    printBlock("Regex") { printer in
      var slice = list.nodes[...]
      printer.printAsPatternFromList(&slice, isTopLevel: true)
    }

    printInlineMatchingOptions()
  }

  private mutating func printAsPatternFromList(
    _ list: inout ArraySlice<DSLTree.Node>,
    isTopLevel: Bool = false
  ) {
    guard let node = list.popFirst() else { return }

    switch node {
    case .orderedChoice(let count):
      printBlock("ChoiceOf") { printer in
        for _ in 0..<count {
          printer.printAsPatternFromList(&list)
        }
      }

    case .concatenation(let count):
      printConcatenationAsPatternFromList(&list, count: count, isTopLevel: isTopLevel)

    case let .nonCapturingGroup(kind):
      switch kind.ast {
      case .atomicNonCapturing:
        printBlock("Local") { printer in
          printer.printAsPatternFromList(&list)
        }

      case .lookahead:
        printBlock("Lookahead") { printer in
          printer.printAsPatternFromList(&list)
        }

      case .negativeLookahead:
        printBlock("NegativeLookahead") { printer in
          printer.printAsPatternFromList(&list)
        }

      default:
        printAsPatternFromList(&list, isTopLevel: isTopLevel)
      }

    case let .capture(name, _, _):
      var cap = "Capture"
      if let n = name {
        cap += "(as: \(n))"
      }
      printBlock(cap) { printer in
        printer.printAsPatternFromList(&list)
      }

    case .ignoreCapturesInTypedOutput:
      printAsPatternFromList(&list, isTopLevel: isTopLevel)

    case .limitCaptureNesting:
      printAsPatternFromList(&list, isTopLevel: isTopLevel)

    case .conditional:
      print("/* TODO: conditional */")

    case let .quantification(amount, kind):
      let amountStr = amount.ast._patternBase
      var kindStr = kind.ast?._patternBase ?? ""

      if quantificationBehavior != .eager {
        kindStr = quantificationBehavior._patternBase
      }

      var blockName = "\(amountStr)(\(kindStr))"
      if kindStr == ".eager" {
        blockName = "\(amountStr)"
      }

      // Special case: check if next child is a simple atom or CCC for inline syntax
      if amount.ast.supportsInlineComponent, let child = list.first {
        switch child {
        case let .atom(a):
          if let pattern = a._patternBase(&self), pattern.canBeWrapped {
            // Consume the atom from the list
            list = list.dropFirst()
            indent()
            if kindStr != ".eager" {
              var b = blockName
              b.removeLast()
              output("\(b), ")
            } else {
              output("\(blockName)(")
            }
            output("\(pattern.0))")
            terminateLine()
            return
          }
        case let .customCharacterClass(ccc):
          if ccc.isSimplePrint {
            list = list.dropFirst()
            indent()
            if kindStr != ".eager" {
              var b = blockName
              b.removeLast()
              output("\(b), ")
            } else {
              output("\(blockName)(")
            }
            printAsPattern(ccc, wrap: false, terminateLine: false)
            output(")")
            terminateLine()
            return
          }
        default:
          break
        }
      }

      printBlock(blockName) { printer in
        printer.printAsPatternFromList(&list, isTopLevel: true)
      }

    case let .atom(a):
      if case .unconverted(let a) = a, a.ast.isUnprintableAtom {
        print("#/\(a.ast._regexBase)/#")
        return
      }

      if let pattern = a._patternBase(&self) {
        if pattern.canBeWrapped {
          print("One(\(pattern.0))")
        } else {
          print(pattern.0)
        }
      }

    case .trivia:
      break

    case .empty:
      print("")

    case let .quotedLiteral(v, display: d):
      if let display = d {
        print(display._bareQuoted)
      } else {
        print(v._quoted)
      }

    case let .customCharacterClass(ccc):
      printAsPattern(ccc)

    case .consumer:
      print("/* TODO: consumers */")
    case .matcher:
      print("/* TODO: consumer validators */")
    case .characterPredicate:
      print("/* TODO: character predicates */")
    case .absentFunction:
      print("/* TODO: absent function */")
    }
  }

  // List-based concatenation printing. Since DSLList(ast:) pre-coalesces
  // adjacent chars/scalars into quotedLiteral nodes, no additional coalescing
  // is needed here — we just iterate the count children.
  private mutating func printConcatenationAsPatternFromList(
    _ list: inout ArraySlice<DSLTree.Node>,
    count: Int,
    isTopLevel: Bool
  ) {
    if isTopLevel || count <= 1 {
      for _ in 0..<count {
        printAsPatternFromList(&list)
      }
    } else {
      printBlock("Regex") { printer in
        for _ in 0..<count {
          printer.printAsPatternFromList(&list)
        }
      }
    }
  }

  mutating func printInlineMatchingOptions() {
    while !inlineMatchingOptions.isEmpty {
      let (options, condition) = popMatchingOptions()

      printIndented { printer in
        for option in options {
          switch option.kind {
          case .asciiOnlyDigit:
            printer.print(".asciiOnlyDigits(\(condition))")

          case .asciiOnlyPOSIXProps:
            printer.print(".asciiOnlyCharacterClasses(\(condition))")

          case .asciiOnlySpace:
            printer.print(".asciiOnlyWhitespace(\(condition))")

          case .asciiOnlyWord:
            printer.print(".asciiOnlyWordCharacters(\(condition))")

          case .caseInsensitive:
            printer.print(".ignoresCase(\(condition))")

          case .multiline:
            printer.print(".anchorsMatchLineEndings(\(condition))")

          case .reluctantByDefault:
            // This is handled by altering every OneOrMore, etc by changing each
            // individual repetition behavior instead of creating a nested regex.
            continue

          case .singleLine:
            printer.print(".dotMatchesNewlines(\(condition))")

          default:
            break
          }
        }
      }

      print("}")
    }
  }

  enum NodeToPrint {
    case dslNode(DSLTree.Node)
    case stringLiteral(String)
  }

  mutating func printAsPattern(
    _ ccc: DSLTree.CustomCharacterClass,
    wrap: Bool = true,
    terminateLine: Bool = true
  ) {
    if ccc.hasUnprintableProperty {
      printAsRegex(ccc, terminateLine: terminateLine)
      return
    }
    
    defer {
      if ccc.isInverted {
        printIndented { printer in
          printer.indent()
          printer.output(".inverted")
          
          if terminateLine {
            printer.terminateLine()
          }
        }
      }
    }
    
    // If we only have 1 member, then we can emit it without the extra
    // CharacterClass initialization
    if ccc.members.count == 1 {
      printAsPattern(ccc.members[0], wrap: wrap)
      
      if terminateLine {
        self.terminateLine()
      }
      
      return
    }
    
    var charMembers = StringLiteralBuilder()

    // This iterates through all of the character class members collecting all
    // of the members who can be stuffed into a singular '.anyOf(...)' vs.
    // having multiple. This does alter the original representation, but the
    // result is the same. For example:
    //
    // Convert: '[abc\d\Qxyz\E[:space:]def]'
    //
    // CharacterClass(
    //   .anyOf("abcxyzdef"),
    //   .digit,
    //   .whitespace
    // )
    //
    // This also allows us to determine if after collecting all of the members
    // and stuffing them if we can just emit a standalone '.anyOf' instead of
    // initializing a 'CharacterClass'.
    let nonCharMembers = ccc.members.filter {
      switch $0 {
      case let .atom(a):
        switch a {
        case let .char(c):
          charMembers.append(c)
          return false
        case let .scalar(s):
          charMembers.append(unescaped: s._dslBase)
          return false
        case .unconverted(_):
          return true
        default:
          return true
        }
        
      case let .quotedLiteral(s):
        charMembers.append(s)
        return false
        
      case .trivia(_):
        return false
        
      default:
        return true
      }
    }
    
    // Also in the same vein, if we have a few atom members but no
    // nonAtomMembers, then we can emit a single .anyOf(...) for them.
    if !charMembers.isEmpty, nonCharMembers.isEmpty {
      let anyOf = "CharacterClass.anyOf(\(charMembers))"
      
      indent()
      
      if wrap {
        output("One(\(anyOf))")
      } else {
        output(anyOf)
      }
      
      if terminateLine {
        self.terminateLine()
      }
      
      return
    }
    
    // Otherwise, use the CharacterClass initialization with multiple members.
    print("CharacterClass(")
    printIndented { printer in      
      printer.indent()
      
      if !charMembers.isEmpty {
        printer.output(".anyOf(\(charMembers))")
        
        if nonCharMembers.count > 0 {
          printer.output(",")
        }
        
        printer.terminateLine()
      }
      
      for (i, member) in nonCharMembers.enumerated() {
        printer.printAsPattern(member, wrap: false)
        
        if i != nonCharMembers.count - 1 {
          printer.output(",")
        }
        
        printer.terminateLine()
      }
    }
    
    indent()
    output(")")
    
    if terminateLine {
      self.terminateLine()
    }
  }

  // TODO: Some way to integrate this with conversion...
  mutating func printAsPattern(
    _ member: DSLTree.CustomCharacterClass.Member,
    wrap: Bool = true
  ) {
    switch member {
    case let .custom(ccc):
      printAsPattern(ccc, terminateLine: false)
      
    case let .range(lhs, rhs):
      if let lhs = lhs._patternBase(&self), let rhs = rhs._patternBase(&self) {
        indent()
        output("(")
        output(lhs.0)
        output("...")
        output(rhs.0)
        output(")")
      }
      
    case let .atom(a):
      indent()
      switch a {
      case let .char(c):
        
        if wrap {
          output("One(.anyOf(\(String(c)._quoted)))")
        } else {
          output("CharacterClass.anyOf(\(String(c)._quoted))")
        }
        
      case let .scalar(s):
        
        if wrap {
          output("One(.anyOf(\(s._dslBase._bareQuoted)))")
        } else {
          output("CharacterClass.anyOf(\(s._dslBase._bareQuoted))")
        }
        
      case let .unconverted(a):
        let base = a.ast._patternBase
        
        if base.canBeWrapped, wrap {
          output("One(\(base.0))")
        } else {
          output(base.0)
        }

      case let .characterClass(cc):
        if wrap {
          output("One(\(cc._patternBase))")
        } else {
          output(cc._patternBase)
        }

      default:
        print(" // TODO: Atom \(a)")
      }
      
    case .quotedLiteral(let s):
      
      if wrap {
        output("One(.anyOf(\(s._quoted)))")
      } else {
        output("CharacterClass.anyOf(\(s._quoted))")
      }
      
    case .trivia(_):
      // We never print trivia
      break
      
    case .intersection(let first, let second):
      if wrap, first.isSimplePrint {
        indent()
        output("One(")
      }
      
      printAsPattern(first, wrap: false)
      printIndented { printer in
        printer.indent()
        printer.output(".intersection(")
        printer.printAsPattern(second, wrap: false, terminateLine: false)
        printer.output(")")
      }
      
      if wrap, first.isSimplePrint {
        output(")")
      }
      
    case .subtraction(let first, let second):
      if wrap, first.isSimplePrint {
        indent()
        output("One(")
      }
      
      printAsPattern(first, wrap: false)
      printIndented { printer in
        printer.indent()
        printer.output(".subtracting(")
        printer.printAsPattern(second, wrap: false, terminateLine: false)
        printer.output(")")
      }
      
      if wrap, first.isSimplePrint {
        output(")")
      }
      
    case .symmetricDifference(let first, let second):
      if wrap, first.isSimplePrint {
        indent()
        output("One(")
      }
      
      printAsPattern(first, wrap: false)
      printIndented { printer in
        printer.indent()
        printer.output(".symmetricDifference(")
        printer.printAsPattern(second, wrap: false, terminateLine: false)
        printer.output(")")
      }
      
      if wrap, first.isSimplePrint {
        output(")")
      }
    }
  }
  
  mutating func printAsRegex(
    _ ccc: DSLTree.CustomCharacterClass,
    asFullRegex: Bool = true,
    terminateLine: Bool = true
  ) {
    indent()
    
    if asFullRegex {
      output("#/")
    }
    
    output("[")
    
    if ccc.isInverted {
      output("^")
    }
    
    for member in ccc.members {
      printAsRegex(member)
    }
    
    output("]")
    
    if asFullRegex {
      if terminateLine {
        print("/#")
      } else {
        output("/#")
      }
    }
  }
  
  mutating func printAsRegex(_ member: DSLTree.CustomCharacterClass.Member) {
    switch member {
    case let .custom(ccc):
      printAsRegex(ccc, terminateLine: false)
      
    case let .range(lhs, rhs):
      output(lhs._regexBase)
      output("-")
      output(rhs._regexBase)
      
    case let .atom(a):
      switch a {
      case let .char(c):
        output(String(c))
      case let .unconverted(a):
        output(a.ast._regexBase)
      default:
        print(" // TODO: Atom \(a)")
      }
      
    case .quotedLiteral(let s):
      output("\\Q\(s)\\E")
      
    case .trivia(_):
      // We never print trivia
      break
      
    case .intersection(let first, let second):
      printAsRegex(first, asFullRegex: false, terminateLine: false)
      output("&&")
      printAsRegex(second, asFullRegex: false, terminateLine: false)
      
    case .subtraction(let first, let second):
      printAsRegex(first, asFullRegex: false, terminateLine: false)
      output("--")
      printAsRegex(second, asFullRegex: false, terminateLine: false)
      
    case .symmetricDifference(let first, let second):
      printAsRegex(first, asFullRegex: false, terminateLine: false)
      output("~~")
      printAsRegex(second, asFullRegex: false, terminateLine: false)
    }
  }
}

extension String {
  var _escaped: String {
    _replacing(#"\"#, with: #"\\"#)._replacing(#"""#, with: #"\""#)
  }

  var _quoted: String {
    _escaped._bareQuoted
  }

  var _bareQuoted: String {
    #""\#(self)""#
  }
}

extension UnicodeScalar {
  var _dslBase: String { "\\u{\(String(value, radix: 16, uppercase: true))}" }
}

/// A helper for building string literals, which handles escaping the contents
/// appended.
fileprivate struct StringLiteralBuilder {
  private var contents = ""

  var result: String { contents._bareQuoted }
  var isEmpty: Bool { contents.isEmpty }

  mutating func append(_ str: String) {
    contents += str._escaped
  }
  mutating func append(_ c: Character) {
    contents += String(c)._escaped
  }
  mutating func append(unescaped str: String) {
    contents += str
  }
}
extension StringLiteralBuilder: CustomStringConvertible {
  var description: String { result }
}

extension DSLTree.Atom.Assertion {
  // TODO: Some way to integrate this with conversion...
  var _patternBase: String {
    switch self {
    case .startOfLine:
      return "Anchor.startOfLine"
    case .endOfLine:
      return "Anchor.endOfLine"
    case .caretAnchor:
      // The DSL doesn't have an equivalent to this, so print as regex.
      return "/^/"
    case .dollarAnchor:
      // The DSL doesn't have an equivalent to this, so print as regex.
      return "/$/"
    case .wordBoundary:
      return "Anchor.wordBoundary"
    case .notWordBoundary:
      return "Anchor.wordBoundary.inverted"
    case .startOfSubject:
      return "Anchor.startOfSubject"
    case .endOfSubject:
      return "Anchor.endOfSubject"
    case .endOfSubjectBeforeNewline:
      return "Anchor.endOfSubjectBeforeNewline"
    case .textSegment:
      return "Anchor.textSegmentBoundary"
    case .notTextSegment:
      return "Anchor.textSegmentBoundary.inverted"
    case .firstMatchingPositionInSubject:
      return "Anchor.firstMatchingPositionInSubject"
      
    case .resetStartOfMatch:
      return "TODO: Assertion resetStartOfMatch"
    }
  }
}

extension DSLTree.Atom.CharacterClass {
  var _patternBase: String {
    switch self {
    case .anyGrapheme:
      return ".anyGraphemeCluster"
    case .digit:
      return ".digit"
    case .notDigit:
      return ".digit.inverted"
    case .word:
      return ".word"
    case .notWord:
      return ".word.inverted"
    case .horizontalWhitespace:
      return ".horizontalWhitespace"
    case .notHorizontalWhitespace:
      return ".horizontalWhitespace.inverted"
    case .newlineSequence:
      return ".newlineSequence"
    case .notNewline:
      return ".newlineSequence.inverted"
    case .verticalWhitespace:
      return ".verticalWhitespace"
    case .notVerticalWhitespace:
      return ".verticalWhitespace.inverted"
    case .whitespace:
      return ".whitespace"
    case .notWhitespace:
      return ".whitespace.inverted"
    case .anyUnicodeScalar:
      fatalError("Unsupported")
    }
  }
}

extension AST.Atom.CharacterProperty {
  var isUnprintableProperty: Bool {
    switch kind {
    case .ascii:
      return true
    case .binary(let b, value: _):
      return isUnprintableBinary(b)
    case .generalCategory(let gc):
      return isUnprintableGeneralCategory(gc)
    case .posix(let p):
      return isUnprintablePOSIX(p)
    case .script(_), .scriptExtension(_):
      return true
    default:
      return false
    }
  }
  
  func isUnprintableBinary(_ binary: Unicode.BinaryProperty) -> Bool {
    // List out the ones we can print because that list is smaller.
    switch binary {
    case .whitespace:
      return false
    default:
      return true
    }
  }
  
  func isUnprintableGeneralCategory(
    _ gc: Unicode.ExtendedGeneralCategory
  ) -> Bool {
    // List out the ones we can print because that list is smaller.
    switch gc {
    case .decimalNumber:
      return false
    default:
      return true
    }
  }
  
  func isUnprintablePOSIX(_ posix: Unicode.POSIXProperty) -> Bool {
    // List out the ones we can print because that list is smaller.
    switch posix {
    case .xdigit:
      return false
    case .word:
      return false
    default:
      return true
    }
  }
}

extension AST.Atom.CharacterProperty {
  // TODO: Some way to integrate this with conversion...
  var _patternBase: String {
    if isUnprintableProperty {
      return _regexBase ?? " // TODO: Property \(self)"
    }
    
    return _dslBase
  }
  
  var _dslBase: String {
    switch kind {
    case .binary(let bp, _):
      switch bp {
      case .whitespace:
        return ".whitespace"
      default:
        return ""
      }
      
    case .generalCategory(let gc):
      switch gc {
      case .decimalNumber:
        return ".digit"
      default:
        return ""
      }
      
    case .posix(let p):
      switch p {
      case .xdigit:
        return ".hexDigit"
      case .word:
        return ".word"
      default:
        return ""
      }
      
    default:
      return ""
    }
  }
  
  var _regexBase: String? {
    let prefix = isInverted ? "\\P" : "\\p"
    switch kind {
    case .ascii:
      return "[:\(isInverted ? "^" : "")ascii:]"
      
    case .binary(let b, value: let value):
      let suffix = value ? "" : "=false"
      return "\(prefix){\(b.rawValue)\(suffix)}"
      
    case .generalCategory(let gc):
      return "\(prefix){\(gc.rawValue)}"

    case .posix(let p):
      return "[:\(isInverted ? "^" : "")\(p.rawValue):]"
      
    case .script(let s):
      return "[:\(isInverted ? "^" : "")script=\(s.rawValue):]"
      
    case .scriptExtension(let s):
      return "[:\(isInverted ? "^" : "")scx=\(s.rawValue):]"
      
    case .any:
      return "\(prefix){Any}"
    case .assigned:
      return "\(prefix){Assigned}"

    case .named(let name):
      return "\\N{\(name)}"

    default:
      return nil
    }
  }
}

extension AST.Atom {
  var isUnprintableAtom: Bool {
    switch kind {
    case .keyboardControl, .keyboardMeta, .keyboardMetaControl:
      return true
    case .namedCharacter(_):
      return true
    case .property(let p):
      return p.isUnprintableProperty
    default:
      return false
    }
  }
}

extension AST.Atom {
  /// Base string to use when rendering as a component in a
  /// pattern. Note that when the atom is rendered individually,
  /// it still may need to be wrapped in quotes.
  ///
  /// TODO: We want to coalesce adjacent atoms, likely in
  /// caller, but we might want to be parameterized at that point.
  ///
  /// TODO: Some way to integrate this with conversion...
  var _patternBase: (String, canBeWrapped: Bool) {
    if let anchor = self.dslAssertionKind {
      return (anchor._patternBase, false)
    }

    if isUnprintableAtom {
      return (_regexBase, false)
    }
    
    return _dslBase
  }
  
  var _dslBase: (String, canBeWrapped: Bool) {
    switch kind {
    case let .char(c):
      return (String(c), false)

    case let .scalar(s):
      return (s.value._dslBase, false)

    case let .scalarSequence(seq):
      return (seq.scalarValues.map(\._dslBase).joined(), false)

    case let .property(p):
      return (p._dslBase, true)
      
    case let .escaped(e):
      switch e {
      // Anchors
      case .wordBoundary:
        return ("Anchor.wordBoundary", false)
      case .notWordBoundary:
        return ("Anchor.wordBoundary.inverted", false)
      case .startOfSubject:
        return ("Anchor.startOfSubject", false)
      case .endOfSubject:
        return ("Anchor.endOfSubject", false)
      case .endOfSubjectBeforeNewline:
        return ("Anchor.endOfSubjectBeforeNewline", false)
      case .firstMatchingPositionInSubject:
        return ("Anchor.firstMatchingPositionInSubject", false)
      case .textSegment:
        return ("Anchor.textSegmentBoundary", false)
      case .notTextSegment:
        return ("Anchor.textSegmentBoundary.inverted", false)
        
      // Character Classes
      case .decimalDigit:
        return (".digit", true)
      case .notDecimalDigit:
        return (".digit.inverted", true)
      case .horizontalWhitespace:
        return (".horizontalWhitespace", true)
      case .notHorizontalWhitespace:
        return (".horizontalWhitespace.inverted", true)
      case .whitespace:
        return (".whitespace", true)
      case .notWhitespace:
        return (".whitespace.inverted", true)
      case .wordCharacter:
        return (".word", true)
      case .notWordCharacter:
        return (".word.inverted", true)
      case .graphemeCluster:
        return (".anyGraphemeCluster", true)
      case .newlineSequence:
        return (".newlineSequence", true)
      case .notNewline:
        return (".newlineSequence.inverted", true)
      case .verticalTab:
        return (".verticalWhitespace", true)
      case .notVerticalTab:
        return (".verticalWhitespace.inverted", true)
        
      // Literal single characters all get converted into DSLTree.Atom.scalar
        
      default:
        return ("TODO: escaped \(e)", false)
      }
      
    case .namedCharacter:
      return (" /* TODO: named character */", false)

    case .dot:
      // The DSL does not have an equivalent to '.', print as a regex.
      return ("/./", false)

    case .caretAnchor, .dollarAnchor:
      fatalError("unreachable")

    case .backreference:
      return (" /* TODO: back reference */", false)

    case .subpattern:
      return (" /* TODO: subpattern */", false)

    case .callout:
      return (" /* TODO: callout */", false)

    case .backtrackingDirective:
      return (" /* TODO: backtracking directive */", false)

    case .changeMatchingOptions:
      return ("/* TODO: change matching options */", false)
      
    // Every other case we've already decided cannot be represented inside the
    // DSL.
    default:
      return ("", false)
    }
  }
  
  var _regexBase: String {
    switch kind {
    case .char, .scalar, .scalarSequence:
      return literalStringValue!

    case .invalid:
      // TODO: Can we recover the original regex text from the source range?
      return "<#value#>"

    case let .property(p):
      return p._regexBase ?? " // TODO: Property \(p)"
      
    case let .escaped(e):
      return "\\\(e.character)"
      
    case .keyboardControl(let k):
      return "\\c\(k)"
      
    case .keyboardMeta(let k):
      return "\\M-\(k)"
      
    case .keyboardMetaControl(let k):
      return "\\M-\\C-\(k)"
      
    case .namedCharacter(let n):
      return "\\N{\(n)}"
      
    case .dot:
      return "."
      
    case .caretAnchor, .dollarAnchor:
      fatalError("unreachable")
      
    case .backreference:
      return " /* TODO: back reference */"
      
    case .subpattern:
      return " /* TODO: subpattern */"
      
    case .callout:
      return " /* TODO: callout */"
      
    case .backtrackingDirective:
      return " /* TODO: backtracking directive */"
      
    case .changeMatchingOptions:
      return "/* TODO: change matching options */"

    #if RESILIENT_LIBRARIES
    @unknown default:
      fatalError()
    #endif
    }
  }
}

extension AST.Atom.Number {
  var _patternBase: String {
    value.map { "\($0)" } ?? "<#number#>"
  }
}

extension AST.Quantification.Amount {
  var _patternBase: String {
    switch self {
    case .zeroOrMore: return "ZeroOrMore"
    case .oneOrMore:  return "OneOrMore"
    case .zeroOrOne:  return "Optionally"
    case let .exactly(n):  return "Repeat(count: \(n._patternBase))"
    case let .nOrMore(n):  return "Repeat(\(n._patternBase)...)"
    case let .upToN(n):    return "Repeat(...\(n._patternBase))"
    case let .range(n, m): return "Repeat(\(n._patternBase)...\(m._patternBase))"
    #if RESILIENT_LIBRARIES
    @unknown default: fatalError()
    #endif
    }
  }
  
  var supportsInlineComponent: Bool {
    switch self {
    case .zeroOrMore: return true
    case .oneOrMore: return true
    case .zeroOrOne: return true
    default: return false
    }
  }
}

extension AST.Quantification.Kind {
  var _patternBase: String {
    switch self {
    case .eager: return ".eager"
    case .reluctant: return ".reluctant"
    case .possessive: return ".possessive"
    #if RESILIENT_LIBRARIES
    @unknown default: fatalError()
    #endif
    }
  }
}

extension DSLTree.QuantificationKind {
  var _patternBase: String {
    (ast ?? .eager)._patternBase
  }
}

extension DSLTree.CustomCharacterClass.Member {
  var isUnprintableMember: Bool {
    switch self {
    case .atom(.unconverted(let a)):
      return a.ast.isUnprintableAtom
    case .custom(let c):
      return c.hasUnprintableProperty
    case .range(.unconverted(let lhs), .unconverted(let rhs)):
      return lhs.ast.isUnprintableAtom || rhs.ast.isQuantifiable
    case .intersection(let first, let second):
      return first.hasUnprintableProperty || second.hasUnprintableProperty
    case .subtraction(let first, let second):
      return first.hasUnprintableProperty || second.hasUnprintableProperty
    case .symmetricDifference(let first, let second):
      return first.hasUnprintableProperty || second.hasUnprintableProperty
    default:
      return false
    }
  }
}

extension DSLTree.CustomCharacterClass {
  var hasUnprintableProperty: Bool {
    members.contains {
      $0.isUnprintableMember
    }
  }
  
  var isSimplePrint: Bool {
    if members.count == 1 {
      switch members[0] {
      case .intersection(_, _):
        return false
      case .subtraction(_, _):
        return false
      case .symmetricDifference(_, _):
        return false
      default:
        return true
      }
    }
    
    let nonCharMembers = members.filter {
      switch $0 {
      case let .atom(a):
        switch a {
        case .char(_):
          return false
        case .scalar(_):
          return false
        case .unconverted(_):
          return true
        default:
          return true
        }
        
      case .quotedLiteral(_):
        return false
        
      case .trivia(_):
        return false
        
      default:
        return true
      }
    }
    
    if nonCharMembers.isEmpty {
      return true
    }
    
    return false
  }
}

extension DSLTree.Atom {
  func _patternBase(
    _ printer: inout PrettyPrinter
  ) -> (String, canBeWrapped: Bool)? {
    switch self {
    case .any:
      return (".any", true)

    case .anyNonNewline:
      return (".anyNonNewline", true)

    case .dot:
      // The DSL does not have an equivalent to '.', print as a regex.
      return ("/./", false)
      
    case let .char(c):
      return (String(c)._quoted, false)
      
    case let .scalar(s):
      let hex = String(s.value, radix: 16, uppercase: true)
      return ("\\u{\(hex)}"._bareQuoted, false)

    case let .unconverted(a):
      if a.ast.isUnprintableAtom {
        return ("#/\(a.ast._regexBase)/#", false)
      } else {
        return a.ast._dslBase
      }
      
    case .assertion(let a):
      return (a._patternBase, false)
    case .characterClass(let cc):
      return (cc._patternBase, true)
      
    case .backreference(_):
      return ("/* TODO: backreferences */", false)
      
    case .symbolicReference:
      return ("/* TODO: symbolic references */", false)
      
    case .changeMatchingOptions(let matchingOptions):
      let options: [AST.MatchingOption]
      let isAdd: Bool

      if matchingOptions.ast.removing.isEmpty {
        options = matchingOptions.ast.adding
        isAdd = true
      } else {
        options = matchingOptions.ast.removing
        isAdd = false
      }

      for option in options {
        switch option.kind {
        case .extended:
          // We don't currently support (?x) in the DSL, so if we see it, just
          // do nothing.
          if options.count == 1 {
            return nil
          }

        case .reluctantByDefault:
          if isAdd {
            printer.quantificationBehavior = .reluctant
          } else {
            printer.quantificationBehavior = .eager
          }


          // Don't create a nested Regex for (?U), we handle this by altering
          // every individual repetitionBehavior for things like OneOrMore.
          if options.count == 1 {
            return nil
          }

        default:
          break
        }
      }

      printer.print("Regex {")
      printer.pushMatchingOptions(options, isAdded: isAdd)
    }
    
    return nil
  }
  
  var _regexBase: String {
    switch self {
    case .any:
      return "(?s:.)"

    case .anyNonNewline:
      return "(?-s:.)"

    case .dot:
      return "."
      
    case let .char(c):
      return String(c)
      
    case let .scalar(s):
      let hex = String(s.value, radix: 16, uppercase: true)
      return "\\u{\(hex)}"._bareQuoted
      
    case let .unconverted(a):
      return a.ast._regexBase
      
    case .assertion:
      return "/* TODO: assertions */"
    case .characterClass:
      return "/* TODO: character classes */"
    case .backreference:
      return "/* TODO: backreferences */"
    case .symbolicReference:
      return "/* TODO: symbolic references */"
    case .changeMatchingOptions(let matchingOptions):
      var result = ""
      
      for add in matchingOptions.ast.adding {
        switch add.kind {
        case .reluctantByDefault:
          result += "(?U)"
        default:
          break
        }
      }
      
      return result
    }
  }
}
