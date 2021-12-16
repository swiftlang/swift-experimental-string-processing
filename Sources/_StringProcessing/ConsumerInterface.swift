import _MatchingEngine

extension AST {
  /// Attempt to generate a consumer from this AST node
  ///
  /// A consumer is a Swift closure that matches against
  /// the front of an input range
  func generateConsumer(
    // TODO: Better option modeling
    _ opts: CharacterClass.MatchLevel
  ) -> Program<String>.ConsumeFunction? {
    switch self {
    case .atom(let a):
      return a.generateConsumer(opts)
    case .customCharacterClass(let ccc):
      return ccc.generateConsumer(opts)

    case .alternation, .concatenation, .group,
        .quantification, .quote, .trivia, .empty,
        .groupTransform: return nil
    }
  }
}

// TODO: This is basically an AST interpreter, which would
// be good or interesting to build regardless, and serves
// as a compiler fall-back path

extension AST.Atom {
  // TODO: clarify difference between this and
  // literal character value...
  //
  // For now this just extracts `.char` case
  //
  // TODO: Shouldn't this be parameterized over matching
  // level?
  var singleCharacter: Character? {
    switch kind {
    case .char(let c): return c
    default: return nil
    }
  }

  func generateConsumer(
    _ opts: CharacterClass.MatchLevel
  ) -> Program<String>.ConsumeFunction? {
    // TODO: Wean ourselves off of this type...
    if let cc = self.characterClass?.withMatchLevel(opts) {
      return { input, bounds in
        // FIXME: should we worry about out of bounds?
        cc.matches(in: input, at: bounds.lowerBound)
      }
    }

    switch kind {
    case let .scalar(s):
      return { input, bounds in
        // TODO: bounds checking?
        let low = bounds.lowerBound
        guard input.unicodeScalars[low] == s else {
          return nil
        }
        return input.unicodeScalars.index(after: low)
      }

    case let .char(c):
      // TODO: Match level?
      return { input, bounds in
        let low = bounds.lowerBound
        guard input[low] == c else {
          return nil
        }
        return input.index(after: low)
      }

    case let .property(p):
      return p.generateConsumer(opts)

    case let .namedCharacter(name):
      return consumeScalarProp {
        // TODO: alias? casing?
        $0.name == name || $0.nameAlias == name
      }

    case .escaped, .keyboardControl, .keyboardMeta, .keyboardMetaControl,
        .any, .startOfLine, .endOfLine,
        .backreference, .subpattern, .condition:
      // FIXME: implement
      return nil
    }
  }
}

extension AST.CustomCharacterClass.Member {
  func generateConsumer(
    _ opts: CharacterClass.MatchLevel
  ) -> Program<String>.ConsumeFunction {
    switch self {
    case .custom(let ccc):
      return ccc.generateConsumer(opts)

    case .range(let lower, let upper):
      guard let lhs = lower.literalCharacterValue else {
        fatalError("TODO")
      }
      guard let rhs = upper.literalCharacterValue else {
        fatalError("TODO")
      }

      return { input, bounds in
        // TODO: check for out of bounds?
        let curIdx = bounds.lowerBound
        if (lhs...rhs).contains(input[curIdx]) {
          // TODO: semantic level
          return input.index(after: curIdx)
        }
        return nil
      }

    case .atom(let atom):
      guard let gen = atom.generateConsumer(opts) else {
        fatalError("TODO")
      }
      return gen

    case .setOperation(let lhs, let op, let rhs):
      // TODO: We should probably have a component type
      // instead of a members array... for now we reconstruct
      // an AST node...
      let start = AST.Located(
        faking: AST.CustomCharacterClass.Start.normal)

      let lhs = AST.CustomCharacterClass(
        start, lhs, .fake
      ).generateConsumer(opts)
      let rhs = AST.CustomCharacterClass(
        start, rhs, .fake
      ).generateConsumer(opts)

      return { input, bounds in
        // NOTE: Easy way to implement, not performant
        let lhsIdxOpt = lhs(input, bounds)
        let rhsIdxOpt = rhs(input, bounds)

        // TODO: What if lengths don't line up?
        assert(lhsIdxOpt == rhsIdxOpt || lhsIdxOpt == nil
               || rhsIdxOpt == nil)

        switch op.value {
        case .subtraction:
          guard rhsIdxOpt == nil else { return nil }
          return lhsIdxOpt

        case .intersection:
          if let idx = lhsIdxOpt {
            return rhsIdxOpt == nil ? nil : idx
          }
          return nil

        case .symmetricDifference:
          if let idx = lhsIdxOpt {
            return rhsIdxOpt == nil ? idx : nil
          }
          return rhsIdxOpt
        }
      }
    }
  }
}

extension AST.CustomCharacterClass {
  func generateConsumer(
    _ opts: CharacterClass.MatchLevel
  ) -> Program<String>.ConsumeFunction {
    // NOTE: Easy way to implement, obviously not performant
    let consumers = members.map { $0.generateConsumer(opts) }
    return { input, bounds in
      for consumer in consumers {
        if let idx = consumer(input, bounds) {
          return isInverted ? nil : idx
        }
      }
      if isInverted {
        // FIXME: semantic level
        return input.index(after: bounds.lowerBound)
      }
      return nil
    }
  }
}

// NOTE: Conveniences, though not most performant
private func consumeScalarGC(
  _ gc: Unicode.GeneralCategory
) -> Program<String>.ConsumeFunction {
  consumeScalar { gc == $0.properties.generalCategory }
}
private func consumeScalarGCs(
  _ gcs: [Unicode.GeneralCategory]
) -> Program<String>.ConsumeFunction {
  consumeScalar { gcs.contains($0.properties.generalCategory) }
}
private func consumeScalarProp(
  _ p: @escaping (Unicode.Scalar.Properties) -> Bool
) -> Program<String>.ConsumeFunction {
  consumeScalar { p($0.properties) }
}
private func consumeScalar(
  _ p: @escaping (Unicode.Scalar) -> Bool
) -> Program<String>.ConsumeFunction {
  { input, bounds in
    // TODO: bounds check?
    let curIdx = bounds.lowerBound
    if p(input.unicodeScalars[curIdx]) {
      // TODO: semantic level?
      return input.unicodeScalars.index(after: curIdx)
    }
    return nil
  }
}

extension AST.Atom.CharacterProperty {
  func generateConsumer(
    _ opts: CharacterClass.MatchLevel
  ) -> Program<String>.ConsumeFunction {
    // Handle inversion for us, albeit not efficiently
    func invert(
      _ p: @escaping Program<String>.ConsumeFunction
    ) -> Program<String>.ConsumeFunction {
      return { input, bounds in
        if p(input, bounds) != nil { return nil }
        // TODO: semantic level
        // TODO: bounds check
        return input.unicodeScalars.index(
          after: bounds.lowerBound)
      }
    }

    // FIXME: Below is largely scalar based, for convenience,
    // but we want a comprehensive treatment to semantic mode
    // switching.
    let preInversion: Program<String>.ConsumeFunction = {
      switch kind {
        // TODO: is this modeled differently?
      case .any:
        return { input, bounds in
          // TODO: bounds check?
          return input.index(after: bounds.lowerBound)
        }
      case .assigned:
        return consumeScalar {
          $0.properties.generalCategory != .unassigned
        }
      case .ascii:
        return consumeScalar(\.isASCII)

      case .generalCategory(let p):
        return p.generateConsumer(opts)
//        fatalError("TODO: Map categories: \(p)")

      case .binary(let prop, value: let value):
        let cons = prop.generateConsumer(opts)
        return value ? cons : invert(cons)

      case .script(let s):
        fatalError("TODO: Map script: \(s)")

      case .scriptExtension(let s):
        fatalError("TODO: Map script: \(s)")

      case .posix(let p):
        return p.generateConsumer(opts)

      case .pcreSpecial(let s):
        fatalError("TODO: map PCRE special: \(s)")

      case .onigurumaSpecial(let s):
        fatalError("TODO: map Oniguruma special: \(s)")

      case let .other(key, value):
        fatalError("TODO: map other \(key ?? "")=\(value)")
      }
    }()

    if !isInverted { return preInversion }
    return invert(preInversion)
  }
}

extension Unicode.BinaryProperty {
  // FIXME: Semantic level, vet for precise defs
  func generateConsumer(
    _ opts: CharacterClass.MatchLevel
  ) -> Program<String>.ConsumeFunction {
    switch self {

    case .asciiHexDigit:
      return consumeScalarProp {
        $0.isHexDigit && $0.isASCIIHexDigit
      }
    case .alphabetic:
      return consumeScalarProp(\.isAlphabetic)
    case .bidiControl:
      break


    case .bidiMirrored: 
      return consumeScalarProp(\.isBidiMirrored)
    case .cased:
      return consumeScalarProp(\.isCased)
    case .compositionExclusion:
      break
    case .caseIgnorable:
      return consumeScalarProp(\.isCaseIgnorable)
    case .changesWhenCasefolded:
      return consumeScalarProp(\.changesWhenCaseFolded)
    case .changesWhenCasemapped:
      return consumeScalarProp(\.changesWhenCaseMapped)
    case .changesWhenNFKCCasefolded:
      return consumeScalarProp(\.changesWhenNFKCCaseFolded)
    case .changesWhenLowercased:
      return consumeScalarProp(\.changesWhenLowercased)
    case .changesWhenTitlecased:
      return consumeScalarProp(\.changesWhenTitlecased)
    case .changesWhenUppercased:
      return consumeScalarProp(\.changesWhenUppercased)
    case .dash:
      return consumeScalarProp(\.isDash)
    case .deprecated:
      return consumeScalarProp(\.isDeprecated)
    case .defaultIgnorableCodePoint:
      return consumeScalarProp(\.isDefaultIgnorableCodePoint)
    case .diacratic: // spelling?
      return consumeScalarProp(\.isDiacritic)
    case .emojiModifierBase:
      break // availability
    case .emojiComponent:
      break
    case .emojiModifier:
      break // availability
    case .emoji:
      break // availability
    case .emojiPresentation:
      break // availability
    case .extender:
      return consumeScalarProp(\.isExtender)
    case .extendedPictographic:
      break
    case .fullCompositionExclusion:
      return consumeScalarProp(\.isFullCompositionExclusion)
    case .graphemeBase:
      return consumeScalarProp(\.isGraphemeBase)
    case .graphemeExtended:
      break
    case .graphemeLink:
      break
    case .hexDigit:
      return consumeScalarProp(\.isHexDigit)
    case .hyphen:
      break
    case .idContinue:
      return consumeScalarProp(\.isIDContinue)
    case .ideographic:
      return consumeScalarProp(\.isIdeographic)
    case .idStart:
      return consumeScalarProp(\.isIDStart)
    case .idsBinaryOperator:
      return consumeScalarProp(\.isIDSBinaryOperator)
    case .idsTrinaryOperator:
      return consumeScalarProp(\.isIDSTrinaryOperator)
    case .joinControl:
      return consumeScalarProp(\.isJoinControl)
    case .logicalOrderException:
      return consumeScalarProp(\.isLogicalOrderException)
    case .lowercase:
      return consumeScalarProp(\.isLowercase)
    case .math:
      return consumeScalarProp(\.isMath)
    case .noncharacterCodePoint:
      return consumeScalarProp(\.isNoncharacterCodePoint)
    case .otherAlphabetic:
      break
    case .otherDefaultIgnorableCodePoint:
      break
    case .otherGraphemeExtended:
      break
    case .otherIDContinue:
      break
    case .otherIDStart:
      break
    case .otherLowercase:
      break
    case .otherMath:
      break
    case .otherUppercase:
      break
    case .patternSyntax:
      return consumeScalarProp(\.isPatternSyntax)
    case .patternWhitespace:
      return consumeScalarProp(\.isPatternWhitespace)
    case .prependedConcatenationMark:
      break
    case .quotationMark:
      return consumeScalarProp(\.isQuotationMark)
    case .radical:
      return consumeScalarProp(\.isRadical)
    case .regionalIndicator:
      break
    case .softDotted:
      return consumeScalarProp(\.isSoftDotted)
    case .sentenceTerminal:
      return consumeScalarProp(\.isSentenceTerminal)
    case .terminalPunctuation:
      return consumeScalarProp(\.isTerminalPunctuation)
    case .unifiedIdiograph: // spelling?
      return consumeScalarProp(\.isUnifiedIdeograph)
    case .uppercase:
      return consumeScalarProp(\.isUppercase)
    case .variationSelector:
      return consumeScalarProp(\.isVariationSelector)
    case .whitespace:
      return consumeScalarProp(\.isWhitespace)
    case .xidContinue:
      return consumeScalarProp(\.isXIDContinue)
    case .xidStart:
      return consumeScalarProp(\.isXIDStart)
    case .expandsOnNFC:
      break
    case .expandsOnNFD:
      break
    case .expandsOnNFKC:
      break
    case .expandsOnNFKD:
      break
    }

    fatalError("TODO: map prop \(self)")
  }
}

extension Unicode.POSIXProperty {
  // FIXME: Semantic level, vet for precise defs
  func generateConsumer(
    _ opts: CharacterClass.MatchLevel
  ) -> Program<String>.ConsumeFunction {
    // FIXME: semantic levels, modes, etc
    switch self {
    case .alnum:
      return consumeScalarProp {
        $0.isAlphabetic || $0.numericType != nil
      }
    case .blank:
      return consumeScalar { s in
        s.properties.generalCategory == .spaceSeparator ||
        s == "\t"
      }

    case .graph:
      return consumeScalarProp { p in
        !(
          p.isWhitespace ||
          p.generalCategory == .control ||
          p.generalCategory == .surrogate ||
          p.generalCategory == .unassigned
        )
      }
    case .print:
      return consumeScalarProp { p in
        // FIXME: better def
        p.generalCategory != .control
      }
    case .word:
      return consumeScalarProp { p in
        // FIXME: better def
        p.isAlphabetic || p.numericType != nil
        || p.isJoinControl
        || p.isDash// marks and connectors...
      }

    case .xdigit:
      return consumeScalarProp(\.isHexDigit) // or number
    }
  }

}

extension Unicode.ExtendedGeneralCategory {
  // FIXME: Semantic level
  func generateConsumer(
    _ opts: CharacterClass.MatchLevel
  ) -> Program<String>.ConsumeFunction {
    switch self {
    case .letter:
      return consumeScalarGCs([
        .uppercaseLetter, .lowercaseLetter,
        .titlecaseLetter, .modifierLetter,
        .otherLetter
      ])

    case .mark:
      return consumeScalarGCs([
        .nonspacingMark, .spacingMark, .enclosingMark
      ])

    case .number:
      return consumeScalarGCs([
        .decimalNumber, .letterNumber, .otherNumber
      ])

    case .symbol:
      return consumeScalarGCs([
        .mathSymbol, .currencySymbol, .modifierSymbol,
        .otherSymbol
      ])

    case .punctuation:
      return consumeScalarGCs([
        .connectorPunctuation, .dashPunctuation,
        .openPunctuation, .closePunctuation,
        .initialPunctuation, .finalPunctuation,
        .otherPunctuation
      ])

    case .separator:
      return consumeScalarGCs([
        .spaceSeparator, .lineSeparator, .paragraphSeparator
      ])

    case .other:
      return consumeScalarGCs([
        .control, .format, .surrogate, .privateUse, .unassigned
      ])

    case .casedLetter:
      fatalError("TODO: cased letter? not the property?")

    case .control:
      return consumeScalarGC(.control)
    case .format:
      return consumeScalarGC(.format)
    case .unassigned:
      return consumeScalarGC(.unassigned)
    case .privateUse:
      return consumeScalarGC(.privateUse)
    case .surrogate:
      return consumeScalarGC(.surrogate)
    case .lowercaseLetter:
      return consumeScalarGC(.lowercaseLetter)
    case .modifierLetter:
      return consumeScalarGC(.modifierLetter)
    case .otherLetter:
      return consumeScalarGC(.otherLetter)
    case .titlecaseLetter:
      return consumeScalarGC(.titlecaseLetter)
    case .uppercaseLetter:
      return consumeScalarGC(.uppercaseLetter)
    case .spacingMark:
      return consumeScalarGC(.spacingMark)
    case .enclosingMark:
      return consumeScalarGC(.enclosingMark)
    case .nonspacingMark:
      return consumeScalarGC(.nonspacingMark)
    case .decimalNumber:
      return consumeScalarGC(.decimalNumber)
    case .letterNumber:
      return consumeScalarGC(.letterNumber)
    case .otherNumber:
      return consumeScalarGC(.otherNumber)
    case .connectorPunctuation:
      return consumeScalarGC(.connectorPunctuation)
    case .dashPunctuation:
      return consumeScalarGC(.dashPunctuation)
    case .closePunctuation:
      return consumeScalarGC(.closePunctuation)
    case .finalPunctuation:
      return consumeScalarGC(.finalPunctuation)
    case .initialPunctuation:
      return consumeScalarGC(.initialPunctuation)
    case .otherPunctuation:
      return consumeScalarGC(.otherPunctuation)
    case .openPunctuation:
      return consumeScalarGC(.openPunctuation)
    case .currencySymbol:
      return consumeScalarGC(.currencySymbol)
    case .modifierSymbol:
      return consumeScalarGC(.modifierSymbol)
    case .mathSymbol:
      return consumeScalarGC(.mathSymbol)
    case .otherSymbol:
      return consumeScalarGC(.otherSymbol)
    case .lineSeparator:
      return consumeScalarGC(.lineSeparator)
    case .paragraphSeparator:
      return consumeScalarGC(.paragraphSeparator)
    case .spaceSeparator:
      return consumeScalarGC(.spaceSeparator)
    }
  }
}
