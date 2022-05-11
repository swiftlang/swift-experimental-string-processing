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

extension Source {
  typealias PropertyKind = AST.Atom.CharacterProperty.Kind

  static private func withNormalizedForms<T>(
    _ str: String, match: (String) throws -> T?
  ) rethrows -> T? {
    // This follows the rules provided by UAX44-LM3, including trying to drop an
    // "is" prefix, which isn't required by UTS#18 RL1.2, but is nice for
    // consistency with other engines and the Unicode.Scalar.Properties names.
    let str = str.filter { !$0.isPatternWhitespace && $0 != "_" && $0 != "-" }
                 .lowercased()
    if let m = try match(str) {
      return m
    }
    if str.hasPrefix("is"), let m = try match(String(str.dropFirst(2))) {
      return m
    }
    return nil
  }

  static private func classifyGeneralCategory(
    _ str: String
  ) -> Unicode.ExtendedGeneralCategory? {
    // This uses the aliases defined in https://www.unicode.org/Public/UCD/latest/ucd/PropertyValueAliases.txt.
    // Additionally, uses the `L& = Lc` alias defined by PCRE.
    withNormalizedForms(str) { str in
      switch str {
      case "c", "other":                   return .other
      case "cc", "control", "cntrl":       return .control
      case "cf", "format":                 return .format
      case "cn", "unassigned":             return .unassigned
      case "co", "privateuse":             return .privateUse
      case "cs", "surrogate":              return .surrogate
      case "l", "letter":                  return .letter
      case "lc", "l&", "casedletter":      return .casedLetter
      case "ll", "lowercaseletter":        return .lowercaseLetter
      case "lm", "modifierletter":         return .modifierLetter
      case "lo", "otherletter":            return .otherLetter
      case "lt", "titlecaseletter":        return .titlecaseLetter
      case "lu", "uppercaseletter":        return .uppercaseLetter
      case "m", "mark", "combiningmark":   return .mark
      case "mc", "spacingmark":            return .spacingMark
      case "me", "enclosingmark":          return .enclosingMark
      case "mn", "nonspacingmark":         return .nonspacingMark
      case "n", "number":                  return .number
      case "nd", "decimalnumber", "digit": return .decimalNumber
      case "nl", "letternumber":           return .letterNumber
      case "no", "othernumber":            return .otherNumber
      case "p", "punctuation", "punct":    return .punctuation
      case "pc", "connectorpunctuation":   return .connectorPunctuation
      case "pd", "dashpunctuation":        return .dashPunctuation
      case "pe", "closepunctuation":       return .closePunctuation
      case "pf", "finalpunctuation":       return .finalPunctuation
      case "pi", "initialpunctuation":     return .initialPunctuation
      case "po", "otherpunctuation":       return .otherPunctuation
      case "ps", "openpunctuation":        return .openPunctuation
      case "s", "symbol":                  return .symbol
      case "sc", "currencysymbol":         return .currencySymbol
      case "sk", "modifiersymbol":         return .modifierSymbol
      case "sm", "mathsymbol":             return .mathSymbol
      case "so", "othersymbol":            return .otherSymbol
      case "z", "separator":               return .separator
      case "zl", "lineseparator":          return .lineSeparator
      case "zp", "paragraphseparator":     return .paragraphSeparator
      case "zs", "spaceseparator":         return .spaceSeparator
      default:                             return nil
      }
    }
  }

  static private func classifyNumericType(
    _ str: String
  ) -> Unicode.NumericType? {
    withNormalizedForms(str) { str in
      switch str {
      case "decimal":   return .decimal
      case "digit":     return .digit
      case "numeric":   return .numeric
      default:          return nil
      }
    }
  }

  static private func classifyBoolProperty(
    _ str: String
  ) -> Unicode.BinaryProperty? {
    // This uses the aliases defined in
    // https://www.unicode.org/Public/UCD/latest/ucd/PropertyAliases.txt.
    withNormalizedForms(str) { str in
      switch str {
      case "ahex", "asciihexdigit":                 return .asciiHexDigit
      case "alpha", "alphabetic":                   return .alphabetic
      case "bidic", "bidicontrol":                  return .bidiControl
      case "bidim", "bidimirrored":                 return .bidiMirrored
      case "cased":                                 return .cased
      case "ce", "compositionexclusion":            return .compositionExclusion
      case "ci", "caseignorable":                   return .caseIgnorable
      case "compex", "fullcompositionexclusion":    return .fullCompositionExclusion
      case "cwcf", "changeswhencasefolded":         return .changesWhenCasefolded
      case "cwcm", "changeswhencasemapped":         return .changesWhenCasemapped
      case "cwkcf", "changeswhennfkccasefolded":    return .changesWhenNFKCCasefolded
      case "cwl", "changeswhenlowercased":          return .changesWhenLowercased
      case "cwt", "changeswhentitlecased":          return .changesWhenTitlecased
      case "cwu", "changeswhenuppercased":          return .changesWhenUppercased
      case "dash":                                  return .dash
      case "dep", "deprecated":                     return .deprecated
      case "di", "defaultignorablecodepoint":       return .defaultIgnorableCodePoint
      case "dia", "diacritic":                      return .diacratic
      case "ebase", "emojimodifierbase":            return .emojiModifierBase
      case "ecomp", "emojicomponent":               return .emojiComponent
      case "emod", "emojimodifier":                 return .emojiModifier
      case "emoji":                                 return .emoji
      case "epres", "emojipresentation":            return .emojiPresentation
      case "ext", "extender":                       return .extender
      case "extpict", "extendedpictographic":       return .extendedPictographic
      case "grbase", "graphemebase":                return .graphemeBase
      case "grext", "graphemeextend":               return .graphemeExtended
      case "grlink", "graphemelink":                return .graphemeLink
      case "hex", "hexdigit":                       return .hexDigit
      case "hyphen":                                return .hyphen
      case "idc", "idcontinue":                     return .idContinue
      case "ideo", "ideographic":                   return .ideographic
      case "ids", "idstart":                        return .idStart
      case "idsb", "idsbinaryoperator":             return .idsBinaryOperator
      case "idst", "idstrinaryoperator":            return .idsTrinaryOperator
      case "joinc", "joincontrol":                  return .joinControl
      case "loe", "logicalorderexception":          return .logicalOrderException
      case "lower", "lowercase":                    return .lowercase
      case "math":                                  return .math
      case "nchar", "noncharactercodepoint":        return .noncharacterCodePoint
      case "oalpha", "otheralphabetic":             return .otherAlphabetic
      case "odi", "otherdefaultignorablecodepoint": return .otherDefaultIgnorableCodePoint
      case "ogrext", "othergraphemeextend":         return .otherGraphemeExtended
      case "oidc", "otheridcontinue":               return .otherIDContinue
      case "oids", "otheridstart":                  return .otherIDStart
      case "olower", "otherlowercase":              return .otherLowercase
      case "omath", "othermath":                    return .otherMath
      case "oupper", "otheruppercase":              return .otherUppercase
      case "patsyn", "patternsyntax":               return .patternSyntax
      case "patws", "patternwhitespace":            return .patternWhitespace
      case "pcm", "prependedconcatenationmark":     return .prependedConcatenationMark
      case "qmark", "quotationmark":                return .quotationMark
      case "radical":                               return .radical
      case "ri", "regionalindicator":               return .regionalIndicator
      case "sd", "softdotted":                      return .softDotted
      case "sterm", "sentenceterminal":             return .sentenceTerminal
      case "term", "terminalpunctuation":           return .terminalPunctuation
      case "uideo", "unifiedideograph":             return .unifiedIdiograph
      case "upper", "uppercase":                    return .uppercase
      case "vs", "variationselector":               return .variationSelector
      case "wspace", "whitespace", "space":         return .whitespace
      case "xidc", "xidcontinue":                   return .xidContinue
      case "xids", "xidstart":                      return .xidStart
      case "xonfc", "expandsonnfc":                 return .expandsOnNFC
      case "xonfd", "expandsonnfd":                 return .expandsOnNFD
      case "xonfkc", "expandsonnfkc":               return .expandsOnNFKC
      case "xonfkd", "expandsonnfkd":               return .expandsOnNFKD
      default:                                      return nil
      }
    }
  }

  static private func classifyCharacterPropertyBoolValue(
    _ str: String
  ) -> Bool? {
    // This uses the aliases defined in
    // https://www.unicode.org/Public/UCD/latest/ucd/PropertyValueAliases.txt.
    withNormalizedForms(str) { str -> Bool? in
      switch str {
      case "t", "true", "y", "yes": return true
      case "f", "false", "n", "no": return false
      default:                      return nil
      }
    }
  }

  static private func classifyPOSIX(_ value: String) -> Unicode.POSIXProperty? {
    withNormalizedForms(value) { Unicode.POSIXProperty(rawValue: $0) }
  }

  static private func classifyScriptProperty(
    _ value: String
  ) -> Unicode.Script? {
    // This uses the aliases defined in
    // https://www.unicode.org/Public/UCD/latest/ucd/PropertyValueAliases.txt.
    withNormalizedForms(value) { str in
      switch str {
      case "adlm", "adlam":                 return .adlam
      case "aghb", "caucasianalbanian":     return .caucasianAlbanian
      case "ahom":                          return .ahom
      case "arab", "arabic":                return .arabic
      case "armi", "imperialaramaic":       return .imperialAramaic
      case "armn", "armenian":              return .armenian
      case "avst", "avestan":               return .avestan
      case "bali", "balinese":              return .balinese
      case "bamu", "bamum":                 return .bamum
      case "bass", "bassavah":              return .bassaVah
      case "batk", "batak":                 return .batak
      case "beng", "bengali":               return .bengali
      case "bhks", "bhaiksuki":             return .bhaiksuki
      case "bopo", "bopomofo":              return .bopomofo
      case "brah", "brahmi":                return .brahmi
      case "brai", "braille":               return .braille
      case "bugi", "buginese":              return .buginese
      case "buhd", "buhid":                 return .buhid
      case "cakm", "chakma":                return .chakma
      case "cans", "canadianaboriginal":    return .canadianAboriginal
      case "cari", "carian":                return .carian
      case "cham":                          return .cham
      case "cher", "cherokee":              return .cherokee
      case "chrs", "chorasmian":            return .chorasmian
      case "copt", "coptic", "qaac":        return .coptic
      case "cpmn", "cyprominoan":           return .cyproMinoan
      case "cprt", "cypriot":               return .cypriot
      case "cyrl", "cyrillic":              return .cyrillic
      case "deva", "devanagari":            return .devanagari
      case "diak", "divesakuru":            return .divesAkuru
      case "dogr", "dogra":                 return .dogra
      case "dsrt", "deseret":               return .deseret
      case "dupl", "duployan":              return .duployan
      case "egyp", "egyptianhieroglyphs":   return .egyptianHieroglyphs
      case "elba", "elbasan":               return .elbasan
      case "elym", "elymaic":               return .elymaic
      case "ethi", "ethiopic":              return .ethiopic
      case "geor", "georgian":              return .georgian
      case "glag", "glagolitic":            return .glagolitic
      case "gong", "gunjalagondi":          return .gunjalaGondi
      case "gonm", "masaramgondi":          return .masaramGondi
      case "goth", "gothic":                return .gothic
      case "gran", "grantha":               return .grantha
      case "grek", "greek":                 return .greek
      case "gujr", "gujarati":              return .gujarati
      case "guru", "gurmukhi":              return .gurmukhi
      case "hang", "hangul":                return .hangul
      case "hani", "han":                   return .han
      case "hano", "hanunoo":               return .hanunoo
      case "hatr", "hatran":                return .hatran
      case "hebr", "hebrew":                return .hebrew
      case "hira", "hiragana":              return .hiragana
      case "hluw", "anatolianhieroglyphs":  return .anatolianHieroglyphs
      case "hmng", "pahawhhmong":           return .pahawhHmong
      case "hmnp", "nyiakengpuachuehmong":  return .nyiakengPuachueHmong
      case "hrkt", "katakanaorhiragana":    return .katakanaOrHiragana
      case "hung", "oldhungarian":          return .oldHungarian
      case "ital", "olditalic":             return .oldItalic
      case "java", "javanese":              return .javanese
      case "kali", "kayahli":               return .kayahLi
      case "kana", "katakana":              return .katakana
      case "khar", "kharoshthi":            return .kharoshthi
      case "khmr", "khmer":                 return .khmer
      case "khoj", "khojki":                return .khojki
      case "kits", "khitansmallscript":     return .khitanSmallScript
      case "knda", "kannada":               return .kannada
      case "kthi", "kaithi":                return .kaithi
      case "lana", "taitham":               return .taiTham
      case "laoo", "lao":                   return .lao
      case "latn", "latin":                 return .latin
      case "lepc", "lepcha":                return .lepcha
      case "limb", "limbu":                 return .limbu
      case "lina", "lineara":               return .linearA
      case "linb", "linearb":               return .linearB
      case "lisu":                          return .lisu
      case "lyci", "lycian":                return .lycian
      case "lydi", "lydian":                return .lydian
      case "mahj", "mahajani":              return .mahajani
      case "maka", "makasar":               return .makasar
      case "mand", "mandaic":               return .mandaic
      case "mani", "manichaean":            return .manichaean
      case "marc", "marchen":               return .marchen
      case "medf", "medefaidrin":           return .medefaidrin
      case "mend", "mendekikakui":          return .mendeKikakui
      case "merc", "meroiticcursive":       return .meroiticCursive
      case "mero", "meroitichieroglyphs":   return .meroiticHieroglyphs
      case "mlym", "malayalam":             return .malayalam
      case "modi":                          return .modi
      case "mong", "mongolian":             return .mongolian
      case "mroo", "mro":                   return .mro
      case "mtei", "meeteimayek":           return .meeteiMayek
      case "mult", "multani":               return .multani
      case "mymr", "myanmar":               return .myanmar
      case "nand", "nandinagari":           return .nandinagari
      case "narb", "oldnortharabian":       return .oldNorthArabian
      case "nbat", "nabataean":             return .nabataean
      case "newa":                          return .newa
      case "nkoo", "nko":                   return .nko
      case "nshu", "nushu":                 return .nushu
      case "ogam", "ogham":                 return .ogham
      case "olck", "olchiki":               return .olChiki
      case "orkh", "oldturkic":             return .oldTurkic
      case "orya", "oriya":                 return .oriya
      case "osge", "osage":                 return .osage
      case "osma", "osmanya":               return .osmanya
      case "ougr", "olduyghur":             return .oldUyghur
      case "palm", "palmyrene":             return .palmyrene
      case "pauc", "paucinhau":             return .pauCinHau
      case "perm", "oldpermic":             return .oldPermic
      case "phag", "phagspa":               return .phagsPa
      case "phli", "inscriptionalpahlavi":  return .inscriptionalPahlavi
      case "phlp", "psalterpahlavi":        return .psalterPahlavi
      case "phnx", "phoenician":            return .phoenician
      case "plrd", "miao":                  return .miao
      case "prti", "inscriptionalparthian": return .inscriptionalParthian
      case "rjng", "rejang":                return .rejang
      case "rohg", "hanifirohingya":        return .hanifiRohingya
      case "runr", "runic":                 return .runic
      case "samr", "samaritan":             return .samaritan
      case "sarb", "oldsoutharabian":       return .oldSouthArabian
      case "saur", "saurashtra":            return .saurashtra
      case "sgnw", "signwriting":           return .signWriting
      case "shaw", "shavian":               return .shavian
      case "shrd", "sharada":               return .sharada
      case "sidd", "siddham":               return .siddham
      case "sind", "khudawadi":             return .khudawadi
      case "sinh", "sinhala":               return .sinhala
      case "sogd", "sogdian":               return .sogdian
      case "sogo", "oldsogdian":            return .oldSogdian
      case "sora", "sorasompeng":           return .soraSompeng
      case "soyo", "soyombo":               return .soyombo
      case "sund", "sundanese":             return .sundanese
      case "sylo", "sylotinagri":           return .sylotiNagri
      case "syrc", "syriac":                return .syriac
      case "tagb", "tagbanwa":              return .tagbanwa
      case "takr", "takri":                 return .takri
      case "tale", "taile":                 return .taiLe
      case "talu", "newtailue":             return .newTaiLue
      case "taml", "tamil":                 return .tamil
      case "tang", "tangut":                return .tangut
      case "tavt", "taiviet":               return .taiViet
      case "telu", "telugu":                return .telugu
      case "tfng", "tifinagh":              return .tifinagh
      case "tglg", "tagalog":               return .tagalog
      case "thaa", "thaana":                return .thaana
      case "thai":                          return .thai
      case "tibt", "tibetan":               return .tibetan
      case "tirh", "tirhuta":               return .tirhuta
      case "tnsa", "tangsa":                return .tangsa
      case "toto":                          return .toto
      case "ugar", "ugaritic":              return .ugaritic
      case "vaii", "vai":                   return .vai
      case "vith", "vithkuqi":              return .vithkuqi
      case "wara", "warangciti":            return .warangCiti
      case "wcho", "wancho":                return .wancho
      case "xpeo", "oldpersian":            return .oldPersian
      case "xsux", "cuneiform":             return .cuneiform
      case "yezi", "yezidi":                return .yezidi
      case "yiii", "yi":                    return .yi
      case "zanb", "zanabazarsquare":       return .zanabazarSquare
      case "zinh", "inherited", "qaai":     return .inherited
      case "zyyy", "common":                return .common
      case "zzzz", "unknown":               return .unknown
      default:                              return nil
      }
    }
  }

  static func classifySpecialPropValue(_ value: String) -> PropertyKind? {
    withNormalizedForms(value) { str in
      switch str {
      case "any":      return .any
      case "assigned": return .assigned
      case "ascii":    return .ascii
      default:         return nil
      }
    }
  }
  
  static func parseAge(_ value: String) -> Unicode.Version? {
    // Age can be specified in the form '3.0' or 'V3_0'.
    // Other formats are not supported.
    var str = value[...]
    
    let separator: Character
    if str.first == "V" {
      str.removeFirst()
      separator = "_"
    } else {
      separator = "."
    }
    
    guard let sepIndex = str.firstIndex(of: separator),
          let major = Int(str[..<sepIndex]),
          let minor = Int(str[sepIndex...].dropFirst())
    else { return nil }
    
    return (major, minor)
  }

  static func classifyCharacterPropertyValueOnly(
    _ value: String
  ) throws -> PropertyKind {
    guard !value.isEmpty else { throw ParseError.emptyProperty }

    // Some special cases defined by UTS#18 (and Oniguruma for 'ANY' and
    // 'Assigned').
    if let specialProp = classifySpecialPropValue(value) {
      return specialProp
    }

    // The following properties we can infer keys/values for.
    if let prop = classifyBoolProperty(value) {
      return .binary(prop, value: true)
    }
    if let cat = classifyGeneralCategory(value) {
      return .generalCategory(cat)
    }
    if let script = classifyScriptProperty(value) {
      return .scriptExtension(script)
    }
    if let posix = classifyPOSIX(value) {
      return .posix(posix)
    }

    // Some additional special cases we recognise.
    // TODO: Normalize these?
    if let oniguruma = OnigurumaSpecialProperty(rawValue: value) {
      return .onigurumaSpecial(oniguruma)
    }
    typealias PCRESpecial = AST.Atom.CharacterProperty.PCRESpecialCategory
    if let pcreSpecial = PCRESpecial(rawValue: value) {
      return .pcreSpecial(pcreSpecial)
    }

    // TODO: This should be versioned, and do we want a more lax behavior for
    // the runtime?
    throw ParseError.unknownProperty(key: nil, value: value)
  }

  static func classifyCharacterProperty(
    key: String, value: String
  ) throws -> PropertyKind {
    guard !key.isEmpty && !value.isEmpty else { throw ParseError.emptyProperty }

    if let prop = classifyBoolProperty(key),
       let isTrue = classifyCharacterPropertyBoolValue(value) {
      return .binary(prop, value: isTrue)
    }

    // This uses the aliases defined in
    // https://www.unicode.org/Public/UCD/latest/ucd/PropertyAliases.txt.
    let match = try withNormalizedForms(key) { key -> PropertyKind? in
      switch key {
      case "script", "sc":
        guard let script = classifyScriptProperty(value) else {
          throw ParseError.unrecognizedScript(value)
        }
        return .script(script)
      case "scriptextensions", "scx":
        guard let script = classifyScriptProperty(value) else {
          throw ParseError.unrecognizedScript(value)
        }
        return .scriptExtension(script)
      case "gc", "generalcategory":
        guard let cat = classifyGeneralCategory(value) else {
          throw ParseError.unrecognizedCategory(value)
        }
        return .generalCategory(cat)
      case "age":
        guard let (major, minor) = parseAge(value) else {
          throw ParseError.invalidAge(value)
        }
        return .age(major: major, minor: minor)
      case "name", "na":
        return .named(value)
      case "numericvalue", "nv":
        guard let numericValue = Double(value) else {
          throw ParseError.invalidNumericValue(value)
        }
        return .numericValue(numericValue)
      case "numerictype", "nt":
        guard let type = classifyNumericType(value) else {
          throw ParseError.unrecognizedNumericType(value)
        }
        return .numericType(type)
      default:
        break
      }
      return nil
    }
    if let match = match {
      return match
    }
    // TODO: This should be versioned, and do we want a more lax behavior for
    // the runtime?
    throw ParseError.unknownProperty(key: key, value: value)
  }
}
