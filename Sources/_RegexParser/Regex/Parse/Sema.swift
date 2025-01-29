//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

/// Validate a regex AST for semantic validity. Once bytecode is emitted at
/// compile time, this could potentially be subsumed by the bytecode generator.
fileprivate struct RegexValidator {
  let ast: AST
  let captures: CaptureList
  var diags = Diagnostics()

  init(_ ast: AST) {
    self.ast = ast
    self.captures = ast.captureList
  }

  mutating func error(_ kind: ParseError, at loc: SourceLocation) {
    diags.error(kind, at: loc)
  }
  mutating func unreachable(_ str: String, at loc: SourceLocation) {
    diags.fatal(.unreachable(str), at: loc)
  }
}

extension String {
  fileprivate var quoted: String { "'\(self)'" }
}

extension RegexValidator {
  mutating func validate() -> AST {
    for opt in ast.globalOptions?.options ?? [] {
      validateGlobalMatchingOption(opt)
    }
    validateCaptures()
    validateNode(ast.root)

    var result = ast
    result.diags.append(contentsOf: diags)
    return result
  }

  /// Called when some piece of invalid AST is encountered. We want to ensure
  /// an error was emitted.
  mutating func expectInvalid(at loc: SourceLocation) {
    guard ast.diags.hasAnyError else {
      unreachable("Invalid, but no error emitted?", at: loc)
      return
    }
  }

  mutating func validateGlobalMatchingOption(_ opt: AST.GlobalMatchingOption) {
    switch opt.kind {
    case .limitDepth, .limitHeap, .limitMatch, .notEmpty, .notEmptyAtStart,
        .noAutoPossess, .noDotStarAnchor, .noJIT, .noStartOpt, .utfMode,
        .unicodeProperties:
      // These are PCRE specific, and not something we're likely to ever
      // support.
      error(.unsupported("global matching option"), at: opt.location)

    case .newlineMatching:
      // We have implemented the correct behavior for multi-line literals, but
      // these should also affect '.' and '\N' matching, which we haven't
      // implemented.
      error(.unsupported("newline matching mode"), at: opt.location)

    case .newlineSequenceMatching:
      // We haven't yet implemented the '\R' matching specifics of these.
      error(.unsupported("newline sequence matching mode"), at: opt.location)
    }
  }

  mutating func validateCaptures() {
    // TODO: Should this be validated when creating the capture list?
    var usedNames = Set<String>()
    for capture in captures.captures {
      guard let name = capture.name else { continue }
      if !usedNames.insert(name).inserted {
        error(.duplicateNamedCapture(name), at: capture.location)
      }
    }
  }

  mutating func validateReference(_ ref: AST.Reference) {
    if let recLevel = ref.recursionLevel {
      error(.unsupported("recursion level"), at: recLevel.location)
    }
    switch ref.kind {
    case .absolute(let num):
      guard let i = num.value else {
        // Should have already been diagnosed.
        expectInvalid(at: ref.innerLoc)
        break
      }
      if i >= captures.captures.count {
        error(.invalidReference(i), at: ref.innerLoc)
      }
    case .named(let name):
      // An empty name is already invalid, so don't bother validating.
      guard !name.isEmpty else { break }
      if !captures.hasCapture(named: name) {
        error(.invalidNamedReference(name), at: ref.innerLoc)
      }
    case .relative(let num):
      guard let _ = num.value else {
        // Should have already been diagnosed.
        expectInvalid(at: ref.innerLoc)
        break
      }
      error(.unsupported("relative capture reference"), at: ref.innerLoc)
    }
  }

  mutating func validateMatchingOption(_ opt: AST.MatchingOption) {
    let loc = opt.location
    switch opt.kind {
    case .allowDuplicateGroupNames:
      // Not currently supported as we need to figure out what to do with
      // the capture type.
      error(.unsupported("duplicate group naming"), at: loc)

    case .unicodeWordBoundaries:
      error(.unsupported("unicode word boundary mode"), at: loc)

    case .textSegmentWordMode, .textSegmentGraphemeMode:
      error(.unsupported("text segment mode"), at: loc)

    case .byteSemantics:
      error(.unsupported("byte semantic mode"), at: loc)

    case .unicodeScalarSemantics:
      error(.unsupported("unicode scalar semantic mode"), at: loc)

    case .graphemeClusterSemantics:
      error(.unsupported("grapheme semantic mode"), at: loc)

    case .caseInsensitive, .possessiveByDefault, .reluctantByDefault,
        .singleLine, .multiline, .namedCapturesOnly, .extended, .extraExtended,
        .asciiOnlyDigit, .asciiOnlyWord, .asciiOnlySpace, .asciiOnlyPOSIXProps,
        .nsreCompatibleDot, .reverse:
      break
    }
  }

  mutating func validateMatchingOptions(_ opts: AST.MatchingOptionSequence) {
    for opt in opts.adding {
      validateMatchingOption(opt)
    }
    for opt in opts.removing {
      validateMatchingOption(opt)
    }
  }

  mutating func validateBinaryProperty(
    _ prop: Unicode.BinaryProperty, at loc: SourceLocation
  ) {
    switch prop {
    case .asciiHexDigit, .alphabetic, .bidiControl, .bidiMirrored, .cased,
        .caseIgnorable, .changesWhenCasefolded, .changesWhenCasemapped,
        .changesWhenNFKCCasefolded, .changesWhenLowercased,
        .changesWhenTitlecased, .changesWhenUppercased, .dash, .deprecated,
        .defaultIgnorableCodePoint, .diacratic, .extender,
        .fullCompositionExclusion, .graphemeBase, .graphemeExtended, .hexDigit,
        .idContinue, .ideographic, .idStart, .idsBinaryOperator,
        .idsTrinaryOperator, .joinControl, .logicalOrderException, .lowercase,
        .math, .noncharacterCodePoint, .patternSyntax, .patternWhitespace,
        .quotationMark, .radical, .regionalIndicator, .softDotted,
        .sentenceTerminal, .terminalPunctuation, .unifiedIdiograph, .uppercase,
        .variationSelector, .whitespace, .xidContinue, .xidStart:
      break

    case .emojiModifierBase, .emojiModifier, .emoji, .emojiPresentation:
      // These are available on macOS 10.12.2, iOS 10.2, tvOS 10.1, watchOS 3.1.1.
      // TODO: We should ideally check deployment target for such conditionally
      // available properties.
      break

    case .expandsOnNFC, .expandsOnNFD, .expandsOnNFKD, .expandsOnNFKC:
      error(.deprecatedUnicode(prop.rawValue.quoted), at: loc)

    case .compositionExclusion, .emojiComponent,
        .extendedPictographic, .graphemeLink, .hyphen, .otherAlphabetic,
        .otherDefaultIgnorableCodePoint, .otherGraphemeExtended,
        .otherIDContinue, .otherIDStart, .otherLowercase, .otherMath,
        .otherUppercase, .prependedConcatenationMark:
      error(.unsupported(prop.rawValue.quoted), at: loc)
    }
  }

  mutating func validateCharacterProperty(
    _ prop: AST.Atom.CharacterProperty, at loc: SourceLocation
  ) {
    // TODO: We could re-add the .other case to diagnose unknown properties
    // here instead of in the parser.
    // TODO: Should we store an 'inner location' for the contents of `\p{...}`?
    switch prop.kind {
    case .binary(let b, _):
      validateBinaryProperty(b, at: loc)
    case .any, .assigned, .ascii, .generalCategory, .posix, .named, .script,
        .scriptExtension, .age, .numericType, .numericValue, .mapping, .ccc:
      break
    case .invalid:
      // Should have already been diagnosed.
      expectInvalid(at: loc)
    case .pcreSpecial:
      error(.unsupported("PCRE property"), at: loc)
    case .block:
      error(.unsupported("Unicode block property"), at: loc)
    case .javaSpecial:
      error(.unsupported("Java property"), at: loc)
    }
  }

  mutating func validateEscaped(
    _ esc: AST.Atom.EscapedBuiltin, at loc: SourceLocation
  ) {
    switch esc {
    case .resetStartOfMatch, .singleDataUnit, .trueAnychar,
        // '\N' needs to be emitted using 'emitDot'.
        .notNewline:
      error(.unsupported("'\\\(esc.character)'"), at: loc)

    // Character classes.
    case .decimalDigit, .notDecimalDigit, .whitespace, .notWhitespace,
        .wordCharacter, .notWordCharacter, .graphemeCluster,
        .horizontalWhitespace, .notHorizontalWhitespace,
        .verticalTab, .notVerticalTab:
      break

    case .newlineSequence:
      break

    // Assertions.
    case .wordBoundary, .notWordBoundary, .startOfSubject,
        .endOfSubjectBeforeNewline, .endOfSubject, .textSegment,
        .notTextSegment, .firstMatchingPositionInSubject:
      break

    // Literal escapes.
    case .alarm, .backspace, .escape, .formfeed, .newline, .carriageReturn,
        .tab:
      break
    }
  }

  mutating func validateAtom(_ atom: AST.Atom, inCustomCharacterClass: Bool) {
    switch atom.kind {
    case .escaped(let esc):
      validateEscaped(esc, at: atom.location)

    case .keyboardControl, .keyboardMeta, .keyboardMetaControl:
      // We need to implement the scalar computations for these.
      error(.unsupported("control sequence"), at: atom.location)

    case .property(let p):
      validateCharacterProperty(p, at: atom.location)

    case .backreference(let r):
      validateReference(r)

    case .subpattern:
      error(.unsupported("subpattern"), at: atom.location)

    case .callout:
      // These are PCRE and Oniguruma specific, supporting them is future work.
      error(.unsupported("callout"), at: atom.location)

    case .backtrackingDirective:
      // These are PCRE-specific, and are unlikely to be fully supported.
      error(.unsupported("backtracking directive"), at: atom.location)

    case .changeMatchingOptions(let opts):
      validateMatchingOptions(opts)

    case .namedCharacter:
      // TODO: We should error on unknown Unicode scalar names.
      break

    case .scalarSequence:
      // Not currently supported in a custom character class.
      if inCustomCharacterClass {
        error(.unsupported("scalar sequence in custom character class"),
              at: atom.location)
      }

    case .char, .scalar, .caretAnchor, .dollarAnchor, .dot:
      break

    case .invalid:
      // Should have already been diagnosed.
      expectInvalid(at: atom.location)
      break
    }
  }

  mutating func validateCustomCharacterClass(_ c: AST.CustomCharacterClass) {
    for member in c.members {
      validateCharacterClassMember(member)
    }
  }

  mutating func validateCharacterClassRange(
    _ range: AST.CustomCharacterClass.Range
  ) {
    let lhs = range.lhs
    let rhs = range.rhs

    validateAtom(lhs, inCustomCharacterClass: true)
    validateAtom(rhs, inCustomCharacterClass: true)

    guard lhs.isValidCharacterClassRangeBound else {
      error(.invalidCharacterClassRangeOperand, at: lhs.location)
      return
    }
    guard rhs.isValidCharacterClassRangeBound else {
      error(.invalidCharacterClassRangeOperand, at: rhs.location)
      return
    }

    guard let lhsChar = lhs.literalCharacterValue else {
      error(
        .unsupported("character class range operand"), at: lhs.location)
      return
    }

    guard let rhsChar = rhs.literalCharacterValue else {
      error(
        .unsupported("character class range operand"), at: rhs.location)
      return
    }

    if lhsChar > rhsChar {
      error(
        .invalidCharacterRange(from: lhsChar, to: rhsChar), at: range.dashLoc)
    }
  }

  mutating func validateCharacterClassMember(
    _ member: AST.CustomCharacterClass.Member
  ) {
    switch member {
    case .custom(let c):
      validateCustomCharacterClass(c)

    case .range(let r):
      validateCharacterClassRange(r)

    case .atom(let a):
      validateAtom(a, inCustomCharacterClass: true)

    case .setOperation(let lhs, _, let rhs):
      for lh in lhs { validateCharacterClassMember(lh) }
      for rh in rhs { validateCharacterClassMember(rh) }

    case .quote, .trivia:
      break
    }
  }

  mutating func validateGroup(_ group: AST.Group) {
    let kind = group.kind
    if let name = kind.value.name, name.isEmpty {
      expectInvalid(at: kind.location)
    }
    switch kind.value {
    case .capture, .namedCapture, .nonCapture, .lookahead, .negativeLookahead,
        .atomicNonCapturing, .lookbehind, .negativeLookbehind:
      break

    case .balancedCapture:
      // These are .NET specific, and kinda niche.
      error(.unsupported("balanced capture"), at: kind.location)

    case .nonCaptureReset:
      // We need to figure out how these interact with typed captures.
      error(.unsupported("branch reset group"), at: kind.location)

    case .nonAtomicLookahead:
      error(.unsupported("non-atomic lookahead"), at: kind.location)

    case .nonAtomicLookbehind:
      error(.unsupported("non-atomic lookbehind"), at: kind.location)

    case .scriptRun, .atomicScriptRun:
      error(.unsupported("script run"), at: kind.location)

    case .changeMatchingOptions(let opts):
      validateMatchingOptions(opts)
    }
    validateNode(group.child)
  }

  mutating func validateQuantification(_ quant: AST.Quantification) {
    validateNode(quant.child)
    if !quant.child.isQuantifiable {
      error(.notQuantifiable, at: quant.child.location)
    }
    switch quant.amount.value {
    case .range(let lhs, let rhs):
      guard let lhs = lhs.value, let rhs = rhs.value else {
        // Should have already been diagnosed.
        expectInvalid(at: quant.location)
        break
      }
      if lhs > rhs {
        error(.invalidQuantifierRange(lhs, rhs), at: quant.location)
      }
    case .zeroOrMore, .oneOrMore, .zeroOrOne, .exactly, .nOrMore, .upToN:
      break
    }
  }

  mutating func validateNode(_ node: AST.Node) {
    switch node {
    case .alternation(let a):
      for branch in a.children {
        validateNode(branch)
      }
    case .concatenation(let c):
      for child in c.children {
        validateNode(child)
      }

    case .group(let g):
      validateGroup(g)

    case .conditional(let c):
      // Note even once we get runtime support for this, we need to change the
      // parsing to incorporate what is specified in the syntax proposal.
      error(.unsupported("conditional"), at: c.location)

    case .quantification(let q):
      validateQuantification(q)

    case .atom(let a):
      validateAtom(a, inCustomCharacterClass: false)

    case .customCharacterClass(let c):
      validateCustomCharacterClass(c)

    case .absentFunction(let a):
      // These are Oniguruma specific.
      error(.unsupported("absent function"), at: a.location)

    case .interpolation(let i):
      // This is currently rejected in the parser for better diagnostics, but
      // reject here too until we get runtime support.
      error(.unsupported("interpolation"), at: i.location)

    case .quote, .trivia, .empty:
      break
    }
  }
}

/// Check a regex AST for semantic validity.
public func validate(_ ast: AST) -> AST {
  var validator = RegexValidator(ast)
  return validator.validate()
}
