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

  init(_ ast: AST) {
    self.ast = ast
    self.captures = ast.captureList
  }

  func error(_ kind: ParseError, at loc: SourceLocation) -> Error {
    Source.LocatedError(kind, loc)
  }
}

extension String {
  fileprivate var quoted: String { "'\(self)'" }
}

extension RegexValidator {
  func validate() throws {
    for opt in ast.globalOptions?.options ?? [] {
      try validateGlobalMatchingOption(opt)
    }
    try validateNode(ast.root)
  }

  func validateGlobalMatchingOption(_ opt: AST.GlobalMatchingOption) throws {
    switch opt.kind {
    case .limitDepth, .limitHeap, .limitMatch, .notEmpty, .notEmptyAtStart,
        .noAutoPossess, .noDotStarAnchor, .noJIT, .noStartOpt, .utfMode,
        .unicodeProperties:
      // These are PCRE specific, and not something we're likely to ever
      // support.
      throw error(.unsupported("global matching option"), at: opt.location)

    case .newlineMatching:
      // We have implemented the correct behavior for multi-line literals, but
      // these should also affect '.' and '\N' matching, which we haven't
      // implemented.
      throw error(.unsupported("newline matching mode"), at: opt.location)

    case .newlineSequenceMatching:
      // We haven't yet implemented the '\R' matching specifics of these.
      throw error(
        .unsupported("newline sequence matching mode"), at: opt.location)
    }
  }

  func validateReference(_ ref: AST.Reference) throws {
    switch ref.kind {
    case .absolute(let i):
      guard i <= captures.captures.count else {
        throw error(.invalidReference(i), at: ref.innerLoc)
      }
    case .relative:
      throw error(.unsupported("relative capture reference"), at: ref.innerLoc)
    case .named:
      // TODO: This could be implemented by querying the capture list for an
      // index.
      throw error(.unsupported("named capture reference"), at: ref.innerLoc)
    }
    if let recLevel = ref.recursionLevel {
      throw error(.unsupported("recursion level"), at: recLevel.location)
    }
  }

  func validateMatchingOption(_ opt: AST.MatchingOption) throws {
    let loc = opt.location
    switch opt.kind {
    case .allowDuplicateGroupNames:
      // Not currently supported as we need to figure out what to do with
      // the capture type.
      throw error(.unsupported("duplicate group naming"), at: loc)

    case .unicodeWordBoundaries:
      throw error(.unsupported("unicode word boundary mode"), at: loc)

    case .textSegmentWordMode, .textSegmentGraphemeMode:
      throw error(.unsupported("text segment mode"), at: loc)

    case .byteSemantics:
      throw error(.unsupported("byte semantic mode"), at: loc)

    case .caseInsensitive, .possessiveByDefault, .reluctantByDefault,
        .unicodeScalarSemantics, .graphemeClusterSemantics,
        .singleLine, .multiline, .namedCapturesOnly, .extended, .extraExtended,
        .asciiOnlyDigit, .asciiOnlyWord, .asciiOnlySpace, .asciiOnlyPOSIXProps:
      break
    }
  }

  func validateMatchingOptions(_ opts: AST.MatchingOptionSequence) throws {
    for opt in opts.adding {
      try validateMatchingOption(opt)
    }
    for opt in opts.removing {
      try validateMatchingOption(opt)
    }
  }

  func validateBinaryProperty(
    _ prop: Unicode.BinaryProperty, at loc: SourceLocation
  ) throws {
    switch prop {
    case .asciiHexDigit, .alphabetic, .bidiMirrored, .cased, .caseIgnorable,
        .changesWhenCasefolded, .changesWhenCasemapped,
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
      throw error(.deprecatedUnicode(prop.rawValue.quoted), at: loc)

    case .bidiControl, .compositionExclusion, .emojiComponent,
        .extendedPictographic, .graphemeLink, .hyphen, .otherAlphabetic,
        .otherDefaultIgnorableCodePoint, .otherGraphemeExtended,
        .otherIDContinue, .otherIDStart, .otherLowercase, .otherMath,
        .otherUppercase, .prependedConcatenationMark:
      throw error(.unsupported(prop.rawValue.quoted), at: loc)
    }
  }

  func validateCharacterProperty(
    _ prop: AST.Atom.CharacterProperty, at loc: SourceLocation
  ) throws {
    // TODO: We could re-add the .other case to diagnose unknown properties
    // here instead of in the parser.
    // TODO: Should we store an 'inner location' for the contents of `\p{...}`?
    switch prop.kind {
    case .binary(let b, _):
      try validateBinaryProperty(b, at: loc)
    case .any, .assigned, .ascii, .generalCategory, .posix, .named, .script,
        .scriptExtension:
      break
    case .pcreSpecial:
      throw error(.unsupported("PCRE property"), at: loc)
    case .onigurumaSpecial:
      throw error(.unsupported("Unicode block property"), at: loc)
    }
  }

  func validateEscaped(
    _ esc: AST.Atom.EscapedBuiltin, at loc: SourceLocation
  ) throws {
    switch esc {
    case .resetStartOfMatch, .singleDataUnit, .horizontalWhitespace,
        .notHorizontalWhitespace, .verticalTab, .notVerticalTab,
        // '\N' needs to be emitted using 'emitAny'.
        .notNewline:
      throw error(.unsupported("'\\\(esc.character)'"), at: loc)

    // Character classes.
    case .decimalDigit, .notDecimalDigit, .whitespace, .notWhitespace,
        .wordCharacter, .notWordCharacter, .graphemeCluster, .trueAnychar:
      // TODO: What about scalar matching mode for .graphemeCluster? We
      // currently crash at runtime.
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

  func validateAtom(_ atom: AST.Atom) throws {
    switch atom.kind {
    case .escaped(let esc):
      try validateEscaped(esc, at: atom.location)

    case .keyboardControl, .keyboardMeta, .keyboardMetaControl:
      // We need to implement the scalar computations for these.
      throw error(.unsupported("control sequence"), at: atom.location)

    case .property(let p):
      try validateCharacterProperty(p, at: atom.location)

    case .backreference(let r):
      try validateReference(r)

    case .subpattern:
      throw error(.unsupported("subpattern"), at: atom.location)

    case .callout:
      // These are PCRE and Oniguruma specific, supporting them is future work.
      throw error(.unsupported("callout"), at: atom.location)

    case .backtrackingDirective:
      // These are PCRE-specific, and are unlikely to be fully supported.
      throw error(.unsupported("backtracking directive"), at: atom.location)

    case .changeMatchingOptions(let opts):
      try validateMatchingOptions(opts)

    case .namedCharacter:
      // TODO: We should error on unknown Unicode scalar names.
      break

    case .char, .scalar, .startOfLine, .endOfLine, .any:
      break
    }
  }

  func validateCustomCharacterClass(_ c: AST.CustomCharacterClass) throws {
    for member in c.members {
      try validateCharacterClassMember(member)
    }
  }

  func validateCharacterClassRange(
    _ range: AST.CustomCharacterClass.Range
  ) throws {
    let lhs = range.lhs
    let rhs = range.rhs

    try validateAtom(lhs)
    try validateAtom(rhs)

    guard lhs.isValidCharacterClassRangeBound else {
      throw error(.invalidCharacterClassRangeOperand, at: lhs.location)
    }
    guard rhs.isValidCharacterClassRangeBound else {
      throw error(.invalidCharacterClassRangeOperand, at: rhs.location)
    }

    guard lhs.literalCharacterValue != nil else {
      throw error(
        .unsupported("character class range operand"), at: lhs.location)
    }

    guard rhs.literalCharacterValue != nil else {
      throw error(
        .unsupported("character class range operand"), at: rhs.location)
    }

    // TODO: Validate lhs <= rhs? That may require knowledge of case
    // insensitivity though.
  }

  func validateCharacterClassMember(
    _ member: AST.CustomCharacterClass.Member
  ) throws {
    switch member {
    case .custom(let c):
      try validateCustomCharacterClass(c)

    case .range(let r):
      try validateCharacterClassRange(r)

    case .atom(let a):
      try validateAtom(a)

    case .setOperation(let lhs, _, let rhs):
      for lh in lhs { try validateCharacterClassMember(lh) }
      for rh in rhs { try validateCharacterClassMember(rh) }

    case .quote, .trivia:
      break
    }
  }

  func validateGroup(_ group: AST.Group) throws {
    let kind = group.kind
    switch kind.value {
    case .capture, .namedCapture, .nonCapture, .lookahead, .negativeLookahead:
      break

    case .balancedCapture:
      // These are .NET specific, and kinda niche.
      throw error(.unsupported("balanced capture"), at: kind.location)

    case .nonCaptureReset:
      // We need to figure out how these interact with typed captures.
      throw error(.unsupported("branch reset group"), at: kind.location)

    case .atomicNonCapturing:
      throw error(.unsupported("atomic group"), at: kind.location)

    case .nonAtomicLookahead:
      throw error(.unsupported("non-atomic lookahead"), at: kind.location)

    case .lookbehind, .negativeLookbehind, .nonAtomicLookbehind:
      throw error(.unsupported("lookbehind"), at: kind.location)

    case .scriptRun, .atomicScriptRun:
      throw error(.unsupported("script run"), at: kind.location)

    case .changeMatchingOptions(let opts):
      try validateMatchingOptions(opts)
    }
    try validateNode(group.child)
  }

  func validateQuantification(_ quant: AST.Quantification) throws {
    try validateNode(quant.child)
    switch quant.amount.value {
    case .range(let lhs, let rhs):
      guard lhs.value <= rhs.value else {
        throw error(
          .invalidQuantifierRange(lhs.value, rhs.value), at: quant.location)
      }
    case .zeroOrMore, .oneOrMore, .zeroOrOne, .exactly, .nOrMore, .upToN:
      break
    }
  }

  func validateNode(_ node: AST.Node) throws {
    switch node {
    case .alternation(let a):
      for branch in a.children {
        try validateNode(branch)
      }
    case .concatenation(let c):
      for child in c.children {
        try validateNode(child)
      }

    case .group(let g):
      try validateGroup(g)

    case .conditional(let c):
      // Note even once we get runtime support for this, we need to change the
      // parsing to incorporate what is specified in the syntax proposal.
      throw error(.unsupported("conditional"), at: c.location)

    case .quantification(let q):
      try validateQuantification(q)

    case .atom(let a):
      try validateAtom(a)

    case .customCharacterClass(let c):
      try validateCustomCharacterClass(c)

    case .absentFunction(let a):
      // These are Oniguruma specific.
      throw error(.unsupported("absent function"), at: a.location)

    case .quote, .trivia, .empty:
      break
    }
  }
}

/// Check a regex AST for semantic validity.
public func validate(_ ast: AST) throws {
  try RegexValidator(ast).validate()
}
