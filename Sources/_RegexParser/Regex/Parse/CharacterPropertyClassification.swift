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

extension Parser {
  typealias PropertyKind = AST.Atom.CharacterProperty.Kind

  static private func withNormalizedForms<T>(
    _ str: String, requireInPrefix: Bool = false, match: (String) -> T?
  ) -> T? {
    // This follows the rules provided by UAX44-LM3, including trying to drop an
    // "is" prefix, which isn't required by UTS#18 RL1.2, but is nice for
    // consistency with other engines and the Unicode.Scalar.Properties names.
    let str = str.filter { !$0.isPatternWhitespace && $0 != "_" && $0 != "-" }
                 .lowercased()
    if requireInPrefix {
      guard str.hasPrefix("in") else { return nil }
      return match(String(str.dropFirst(2)))
    }
    if let m = match(str) {
      return m
    }
    if str.hasPrefix("is"), let m = match(String(str.dropFirst(2))) {
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

  static private func classifyBlockProperty(
    _ value: String, valueOnly: Bool
  ) -> Unicode.Block? {
    // Require an 'in' prefix for the shorthand variant. This is supported by
    // Oniguruma and Perl.
    // TODO: Perl discourages the shorthand 'in' prefix, should we diagnose and
    // suggest an explicit key/value?
    withNormalizedForms(value, requireInPrefix: valueOnly) { str in
      switch str {
      case "adlam":                                                           return .adlam
      case "aegeannumbers":                                                   return .aegeanNumbers
      case "ahom":                                                            return .ahom
      case "alchemical", "alchemicalsymbols":                                 return .alchemicalSymbols
      case "alphabeticpf", "alphabeticpresentationforms":                     return .alphabeticPresentationForms
      case "anatolianhieroglyphs":                                            return .anatolianHieroglyphs
      case "ancientgreekmusic", "ancientgreekmusicalnotation":                return .ancientGreekMusicalNotation
      case "ancientgreeknumbers":                                             return .ancientGreekNumbers
      case "ancientsymbols":                                                  return .ancientSymbols
      case "arabic":                                                          return .arabic
      case "arabicexta", "arabicextendeda":                                   return .arabicExtendedA
      case "arabicextb", "arabicextendedb":                                   return .arabicExtendedB
      case "arabicmath", "arabicmathematicalalphabeticsymbols":               return .arabicMathematicalAlphabeticSymbols
      case "arabicpfa", "arabicpresentationformsa":                           return .arabicPresentationFormsA
      case "arabicpfb", "arabicpresentationformsb":                           return .arabicPresentationFormsB
      case "arabicsup", "arabicsupplement":                                   return .arabicSupplement
      case "armenian":                                                        return .armenian
      case "arrows":                                                          return .arrows
      case "ascii", "basiclatin":                                             return .basicLatin
      case "avestan":                                                         return .avestan
      case "balinese":                                                        return .balinese
      case "bamum":                                                           return .bamum
      case "bamumsup", "bamumsupplement":                                     return .bamumSupplement
      case "bassavah":                                                        return .bassaVah
      case "batak":                                                           return .batak
      case "bengali":                                                         return .bengali
      case "bhaiksuki":                                                       return .bhaiksuki
      case "blockelements":                                                   return .blockElements
      case "bopomofo":                                                        return .bopomofo
      case "bopomofoext", "bopomofoextended":                                 return .bopomofoExtended
      case "boxdrawing":                                                      return .boxDrawing
      case "brahmi":                                                          return .brahmi
      case "braille", "braillepatterns":                                      return .braillePatterns
      case "buginese":                                                        return .buginese
      case "buhid":                                                           return .buhid
      case "byzantinemusic", "byzantinemusicalsymbols":                       return .byzantineMusicalSymbols
      case "carian":                                                          return .carian
      case "caucasianalbanian":                                               return .caucasianAlbanian
      case "chakma":                                                          return .chakma
      case "cham":                                                            return .cham
      case "cherokee":                                                        return .cherokee
      case "cherokeesup", "cherokeesupplement":                               return .cherokeeSupplement
      case "chesssymbols":                                                    return .chessSymbols
      case "chorasmian":                                                      return .chorasmian
      case "cjk", "cjkunifiedideographs":                                     return .cjkUnifiedIdeographs
      case "cjkcompat", "cjkcompatibility":                                   return .cjkCompatibility
      case "cjkcompatforms", "cjkcompatibilityforms":                         return .cjkcompatibilityForms
      case "cjkcompatideographs", "cjkcompatibilityideographs":               return .cjkCompatibilityIdeographs
      case "cjkcompatideographssup", "cjkcompatibilityideographssupplement":  return .cjkCompatibilityIdeographsSupplement
      case "cjkexta", "cjkunifiedideographsextensiona":                       return .cjkUnifiedIdeographsExtensionA
      case "cjkextb", "cjkunifiedideographsextensionb":                       return .cjkUnifiedIdeographsExtensionB
      case "cjkextc", "cjkunifiedideographsextensionc":                       return .cjkUnifiedIdeographsExtensionC
      case "cjkextd", "cjkunifiedideographsextensiond":                       return .cjkUnifiedIdeographsExtensionD
      case "cjkexte", "cjkunifiedideographsextensione":                       return .cjkUnifiedIdeographsExtensionE
      case "cjkextf", "cjkunifiedideographsextensionf":                       return .cjkUnifiedIdeographsExtensionF
      case "cjkextg", "cjkunifiedideographsextensiong":                       return .cjkUnifiedIdeographsExtensionG
      case "cjkradicalssup", "cjkradicalssupplement":                         return .cjkRadicalsSupplement
      case "cjkstrokes":                                                      return .cjkStrokes
      case "cjksymbols", "cjksymbolsandpunctuation":                          return .cjkSymbolsAndPunctuation
      case "compatjamo", "hangulcompatibilityjamo":                           return .hangulCompatibilityJamo
      case "controlpictures":                                                 return .controlPictures
      case "coptic":                                                          return .coptic
      case "copticepactnumbers":                                              return .copticEpactNumbers
      case "countingrod", "countingrodnumerals":                              return .countingRodNumerals
      case "cuneiform":                                                       return .cuneiform
      case "cuneiformnumbers", "cuneiformnumbersandpunctuation":              return .cuneiformNumbersAndPunctuation
      case "currencysymbols":                                                 return .currencySymbols
      case "cypriotsyllabary":                                                return .cypriotSyllabary
      case "cyprominoan":                                                     return .cyproMinoan
      case "cyrillic":                                                        return .cyrillic
      case "cyrillicexta", "cyrillicextendeda":                               return .cyrillicExtendedA
      case "cyrillicextb", "cyrillicextendedb":                               return .cyrillicExtendedB
      case "cyrillicextc", "cyrillicextendedc":                               return .cyrillicExtendedC
      case "cyrillicsup", "cyrillicsupplement", "cyrillicsupplementary":      return .cyrillicSupplement
      case "deseret":                                                         return .deseret
      case "devanagari":                                                      return .devanagari
      case "devanagariext", "devanagariextended":                             return .devanagariExtended
      case "diacriticals", "combiningdiacriticalmarks":                       return .combiningDiacriticalMarks
      case "diacriticalsext", "combiningdiacriticalmarksextended":            return .combiningDiacriticalMarksExtended
      case "diacriticalsforsymbols", "combiningdiacriticalmarksforsymbols",
        "combiningmarksforsymbols":                                           return .combiningDiacriticalMarksForSymbols
      case "diacriticalssup", "combiningdiacriticalmarkssupplement":          return .combiningDiacriticalMarksSupplement
      case "dingbats":                                                        return .dingbats
      case "divesakuru":                                                      return .divesAkuru
      case "dogra":                                                           return .dogra
      case "domino", "dominotiles":                                           return .dominoTiles
      case "duployan":                                                        return .duployan
      case "earlydynasticcuneiform":                                          return .earlyDynasticCuneiform
      case "egyptianhieroglyphformatcontrols":                                return .egyptianHieroglyphFormatControls
      case "egyptianhieroglyphs":                                             return .egyptianHieroglyphs
      case "elbasan":                                                         return .elbasan
      case "elymaic":                                                         return .elymaic
      case "emoticons":                                                       return .emoticons
      case "enclosedalphanum", "enclosedalphanumerics":                       return .enclosedAlphanumerics
      case "enclosedalphanumsup", "enclosedalphanumericsupplement":           return .enclosedAlphanumericSupplement
      case "enclosedcjk", "enclosedcjklettersandmonths":                      return .enclosedCJKLettersAndMonths
      case "enclosedideographicsup", "enclosedideographicsupplement":         return .enclosedIdeographicSupplement
      case "ethiopic":                                                        return .ethiopic
      case "ethiopicext", "ethiopicextended":                                 return .ethiopicExtended
      case "ethiopicexta", "ethiopicextendeda":                               return .ethiopicExtendedA
      case "ethiopicextb", "ethiopicextendedb":                               return .ethiopicExtendedB
      case "ethiopicsup", "ethiopicsupplement":                               return .ethiopicSupplement
      case "geometricshapes":                                                 return .geometricShapes
      case "geometricshapesext", "geometricshapesextended":                   return .geometricShapesExtended
      case "georgian":                                                        return .georgian
      case "georgianext", "georgianextended":                                 return .georgianExtended
      case "georgiansup", "georgiansupplement":                               return .georgianSupplement
      case "glagolitic":                                                      return .glagolitic
      case "glagoliticsup", "glagoliticsupplement":                           return .glagoliticSupplement
      case "gothic":                                                          return .gothic
      case "grantha":                                                         return .grantha
      case "greek", "greekandcoptic":                                         return .greekAndCoptic
      case "greekext", "greekextended":                                       return .greekExtended
      case "gujarati":                                                        return .gujarati
      case "gunjalagondi":                                                    return .gunjalaGondi
      case "gurmukhi":                                                        return .gurmukhi
      case "halfandfullforms", "halfwidthandfullwidthforms":                  return .halfwidthAndFullwidthForms
      case "halfmarks", "combininghalfmarks":                                 return .combiningHalfMarks
      case "hangul", "hangulsyllables":                                       return .hangulSyllables
      case "hanifirohingya":                                                  return .hanifiRohingya
      case "hanunoo":                                                         return .hanunoo
      case "hatran":                                                          return .hatran
      case "hebrew":                                                          return .hebrew
      case "highpusurrogates", "highprivateusesurrogates":                    return .highPrivateUseSurrogates
      case "highsurrogates":                                                  return .highSurrogates
      case "hiragana":                                                        return .hiragana
      case "idc", "ideographicdescriptioncharacters":                         return .ideographicDescriptionCharacters
      case "ideographicsymbols", "ideographicsymbolsandpunctuation":          return .ideographicSymbolsAndPunctuation
      case "imperialaramaic":                                                 return .imperialAramaic
      case "indicnumberforms", "commonindicnumberforms":                      return .commonIndicNumberForms
      case "indicsiyaqnumbers":                                               return .indicSiyaqNumbers
      case "inscriptionalpahlavi":                                            return .inscriptionalPahlavi
      case "inscriptionalparthian":                                           return .inscriptionalParthian
      case "ipaext", "ipaextensions":                                         return .ipaExtensions
      case "jamo", "hanguljamo":                                              return .hangulJamo
      case "jamoexta", "hanguljamoextendeda":                                 return .hangulJamoExtendedA
      case "jamoextb", "hanguljamoextendedb":                                 return .hangulJamoExtendedB
      case "javanese":                                                        return .javanese
      case "kaithi":                                                          return .kaithi
      case "kanaexta", "kanaextendeda":                                       return .kanaExtendedA
      case "kanaextb", "kanaextendedb":                                       return .kanaExtendedB
      case "kanasup", "kanasupplement":                                       return .kanaSupplement
      case "kanbun":                                                          return .kanbun
      case "kangxi", "kangxiradicals":                                        return .kangxiRadicals
      case "kannada":                                                         return .kannada
      case "katakana":                                                        return .katakana
      case "katakanaext", "katakanaphoneticextensions":                       return .katakanaPhoneticExtensions
      case "kayahli":                                                         return .kayahLi
      case "kharoshthi":                                                      return .kharoshthi
      case "khitansmallscript":                                               return .khitanSmallScript
      case "khmer":                                                           return .khmer
      case "khmersymbols":                                                    return .khmerSymbols
      case "khojki":                                                          return .khojki
      case "khudawadi":                                                       return .khudawadi
      case "lao":                                                             return .lao
      case "latin1sup", "latin1supplement", "latin1":                         return .latin1Supplement
      case "latinexta", "latinextendeda":                                     return .latinExtendedA
      case "latinextadditional", "latinextendedadditional":                   return .latinExtendedAdditional
      case "latinextb", "latinextendedb":                                     return .latinExtendedB
      case "latinextc", "latinextendedc":                                     return .latinExtendedC
      case "latinextd", "latinextendedd":                                     return .latinExtendedD
      case "latinexte", "latinextendede":                                     return .latinExtendedE
      case "latinextf", "latinextendedf":                                     return .latinExtendedF
      case "latinextg", "latinextendedg":                                     return .latinExtendedG
      case "lepcha":                                                          return .lepcha
      case "letterlikesymbols":                                               return .letterLikeSymbols
      case "limbu":                                                           return .limbu
      case "lineara":                                                         return .linearA
      case "linearbideograms":                                                return .linearBIdeograms
      case "linearbsyllabary":                                                return .linearBSyllabary
      case "lisu":                                                            return .lisu
      case "lisusup", "lisusupplement":                                       return .lisuSupplement
      case "lowsurrogates":                                                   return .lowSurrogates
      case "lycian":                                                          return .lycian
      case "lydian":                                                          return .lydian
      case "mahajani":                                                        return .mahajani
      case "mahjong", "mahjongtiles":                                         return .mahjongTiles
      case "makasar":                                                         return .makasar
      case "malayalam":                                                       return .malayalam
      case "mandaic":                                                         return .mandaic
      case "manichaean":                                                      return .manichaean
      case "marchen":                                                         return .marchen
      case "masaramgondi":                                                    return .masaramGondi
      case "mathalphanum", "mathematicalalphanumericsymbols":                 return .mathematicalAlphanumericSymbols
      case "mathoperators", "mathematicaloperators":                          return .mathematicalOperators
      case "mayannumerals":                                                   return .mayanNumerals
      case "medefaidrin":                                                     return .medefaidrin
      case "meeteimayek":                                                     return .meeteiMayek
      case "meeteimayekext", "meeteimayekextensions":                         return .meeteiMayekExtensions
      case "mendekikakui":                                                    return .mendeKikakui
      case "meroiticcursive":                                                 return .meroiticCursive
      case "meroitichieroglyphs":                                             return .meroiticHieroglyphs
      case "miao":                                                            return .miao
      case "miscarrows", "miscellaneoussymbolsandarrows":                     return .miscellaneousSymbolsAndArrows
      case "miscmathsymbolsa", "miscellaneousmathematicalsymbolsa":           return .miscellaneousMathematicalSymbolsA
      case "miscmathsymbolsb", "miscellaneousmathematicalsymbolsb":           return .miscellaneousMathematicalSymbolsB
      case "miscpictographs", "miscellaneoussymbolsandpictographs":           return .miscellaneousSymbolsandPictographs
      case "miscsymbols", "miscellaneoussymbols":                             return .miscellaneousSymbols
      case "misctechnical", "miscellaneoustechnical":                         return .miscellaneousTechnical
      case "modi":                                                            return .modi
      case "modifierletters", "spacingmodifierletters":                       return .spacingModifierLetters
      case "modifiertoneletters":                                             return .modifierToneLetters
      case "mongolian":                                                       return .mongolian
      case "mongoliansup", "mongoliansupplement":                             return .mongolianSupplement
      case "mro":                                                             return .mro
      case "multani":                                                         return .multani
      case "music", "musicalsymbols":                                         return .musicalSymbols
      case "myanmar":                                                         return .myanmar
      case "myanmarexta", "myanmarextendeda":                                 return .myanmarExtendedA
      case "myanmarextb", "myanmarextendedb":                                 return .myanmarExtendedB
      case "nabataean":                                                       return .nabataean
      case "nandinagari":                                                     return .nandinagari
      case "nb", "noblock":                                                   return .noBlock
      case "newtailue":                                                       return .newTailue
      case "newa":                                                            return .newa
      case "nko":                                                             return .nko
      case "numberforms":                                                     return .numberForms
      case "nushu":                                                           return .nushu
      case "nyiakengpuachuehmong":                                            return .nyiakengPuachueHmong
      case "ocr", "opticalcharacterrecognition":                              return .opticalCharacterRecognition
      case "ogham":                                                           return .ogham
      case "olchiki":                                                         return .olChiki
      case "oldhungarian":                                                    return .oldHungarian
      case "olditalic":                                                       return .oldItalic
      case "oldnortharabian":                                                 return .oldNorthArabian
      case "oldpermic":                                                       return .oldPermic
      case "oldpersian":                                                      return .oldPersian
      case "oldsogdian":                                                      return .oldSogdian
      case "oldsoutharabian":                                                 return .oldSouthArabian
      case "oldturkic":                                                       return .oldTurkic
      case "olduyghur":                                                       return .oldUyghur
      case "oriya":                                                           return .oriya
      case "ornamentaldingbats":                                              return .ornamentalDingbats
      case "osage":                                                           return .osage
      case "osmanya":                                                         return .osmanya
      case "ottomansiyaqnumbers":                                             return .ottomanSiyaqNumbers
      case "pahawhhmong":                                                     return .pahawhHmong
      case "palmyrene":                                                       return .palmyrene
      case "paucinhau":                                                       return .pauCinHau
      case "phagspa":                                                         return .phagsPA
      case "phaistos", "phaistosdisc":                                        return .phaistosDisc
      case "phoenician":                                                      return .phoenician
      case "phoneticext", "phoneticextensions":                               return .phoneticExtensions
      case "phoneticextsup", "phoneticextensionssupplement":                  return .phoneticExtensionsSupplement
      case "playingcards":                                                    return .playingCards
      case "psalterpahlavi":                                                  return .psalterPahlavi
      case "pua", "privateusearea", "privateuse":                             return .privateUseArea
      case "punctuation", "generalpunctuation":                               return .generalPunctuation
      case "rejang":                                                          return .rejang
      case "rumi", "ruminumeralsymbols":                                      return .rumiNumeralSymbols
      case "runic":                                                           return .runic
      case "samaritan":                                                       return .samaritan
      case "saurashtra":                                                      return .saurashtra
      case "sharada":                                                         return .sharada
      case "shavian":                                                         return .shavian
      case "shorthandformatcontrols":                                         return .shorthandFormatControls
      case "siddham":                                                         return .siddham
      case "sinhala":                                                         return .sinhala
      case "sinhalaarchaicnumbers":                                           return .sinhalaArchaicNumbers
      case "smallforms", "smallformvariants":                                 return .smallFormVariants
      case "smallkanaext", "smallkanaextension":                              return .smallKanaExtension
      case "sogdian":                                                         return .sogdian
      case "sorasompeng":                                                     return .soraSompeng
      case "soyombo":                                                         return .soyombo
      case "specials":                                                        return .specials
      case "sundanese":                                                       return .sundanese
      case "sundanesesup", "sundanesesupplement":                             return .sundaneseSupplement
      case "suparrowsa", "supplementalarrowsa":                               return .supplementalArrowsA
      case "suparrowsb", "supplementalarrowsb":                               return .supplementalArrowsB
      case "suparrowsc", "supplementalarrowsc":                               return .supplementalArrowsC
      case "supmathoperators", "supplementalmathematicaloperators":           return .supplementalMathematicalOperators
      case "suppuaa", "supplementaryprivateuseareaa":                         return .supplementaryPrivateUseAreaA
      case "suppuab", "supplementaryprivateuseareab":                         return .supplementaryPrivateUseAreaB
      case "suppunctuation", "supplementalpunctuation":                       return .supplementalPunctuation
      case "supsymbolsandpictographs", "supplementalsymbolsandpictographs":   return .supplementalSymbolsAndPictographs
      case "superandsub", "superscriptsandsubscripts":                        return .superscriptsAndSubscripts
      case "suttonsignwriting":                                               return .suttonSignwriting
      case "sylotinagri":                                                     return .sylotiNagri
      case "symbolsandpictographsexta", "symbolsandpictographsextendeda":     return .symbolsAndPictographsExtendedA
      case "symbolsforlegacycomputing":                                       return .symbolsForLegacyComputing
      case "syriac":                                                          return .syriac
      case "syriacsup", "syriacsupplement":                                   return .syriacSupplement
      case "tagalog":                                                         return .tagalog
      case "tagbanwa":                                                        return .tagbanwa
      case "tags":                                                            return .tags
      case "taile":                                                           return .taiLe
      case "taitham":                                                         return .taiTham
      case "taiviet":                                                         return .taiViet
      case "taixuanjing", "taixuanjingsymbols":                               return .taiXuanJingSymbols
      case "takri":                                                           return .takri
      case "tamil":                                                           return .tamil
      case "tamilsup", "tamilsupplement":                                     return .tamilSupplement
      case "tangsa":                                                          return .tangsa
      case "tangut":                                                          return .tangut
      case "tangutcomponents":                                                return .tangutComponents
      case "tangutsup", "tangutsupplement":                                   return .tangutSupplement
      case "telugu":                                                          return .telugu
      case "thaana":                                                          return .thaana
      case "thai":                                                            return .thai
      case "tibetan":                                                         return .tibetan
      case "tifinagh":                                                        return .tifinagh
      case "tirhuta":                                                         return .tirhuta
      case "toto":                                                            return .toto
      case "transportandmap", "transportandmapsymbols":                       return .transportAndMapSymbols
      case "ucas", "unifiedcanadianaboriginalsyllabics", "canadiansyllabics": return .unifiedCanadianAboriginalSyllabics
      case "ucasext", "unifiedcanadianaboriginalsyllabicsextended":           return .unifiedCanadianAboriginalSyllabicsExtended
      case "ucasexta", "unifiedcanadianaboriginalsyllabicsextendeda":         return .unifiedCanadianAboriginalSyllabicsExtendedA
      case "ugaritic":                                                        return .ugaritic
      case "vai":                                                             return .vai
      case "vedicext", "vedicextensions":                                     return .vedicExtensions
      case "verticalforms":                                                   return .verticalForms
      case "vithkuqi":                                                        return .vithkuqi
      case "vs", "variationselectors":                                        return .variationSelectors
      case "vssup", "variationselectorssupplement":                           return .variationSelectorsSupplement
      case "wancho":                                                          return .wancho
      case "warangciti":                                                      return .warangCiti
      case "yezidi":                                                          return .yezidi
      case "yiradicals":                                                      return .yiRadicals
      case "yisyllables":                                                     return .yiSyllables
      case "yijing", "yijinghexagramsymbols":                                 return .yijingHexagramSymbols
      case "zanabazarsquare":                                                 return .zanabazarSquare
      case "znamennymusic", "znamennymusicalnotation":                        return .znamennyMusicalNotation
      default:                                                                return nil
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

  mutating func classifyCharacterPropertyValueOnly(
    _ valueLoc: Located<String>
  ) -> PropertyKind {
    let value = valueLoc.value

    func error(_ err: ParseError) -> PropertyKind {
      self.error(err, at: valueLoc.location)
      return .invalid(key: nil, value: value)
    }

    guard !value.isEmpty else {
      return error(.emptyProperty)
    }

    // Some special cases defined by UTS#18 (and Oniguruma for 'ANY' and
    // 'Assigned').
    if let specialProp = Self.classifySpecialPropValue(value) {
      return specialProp
    }

    // The following properties we can infer keys/values for.
    if let prop = Self.classifyBoolProperty(value) {
      return .binary(prop, value: true)
    }
    if let cat = Self.classifyGeneralCategory(value) {
      return .generalCategory(cat)
    }
    if let script = Self.classifyScriptProperty(value) {
      return .scriptExtension(script)
    }
    if let posix = Self.classifyPOSIX(value) {
      return .posix(posix)
    }
    if let block = Self.classifyBlockProperty(value, valueOnly: true) {
      return .block(block)
    }

    // Special properties from other engines.
    typealias PCRESpecial = AST.Atom.CharacterProperty.PCRESpecialCategory
    if let pcreSpecial = PCRESpecial(rawValue: value) {
      return .pcreSpecial(pcreSpecial)
    }
    typealias JavaSpecial = AST.Atom.CharacterProperty.JavaSpecial
    if let javaSpecial = JavaSpecial(rawValue: value) {
      return .javaSpecial(javaSpecial)
    }

    // TODO: This should be versioned, and do we want a more lax behavior for
    // the runtime?
    return error(.unknownProperty(key: nil, value: value))
  }

  mutating func classifyCharacterProperty(
    key keyLoc: Located<String>, value valueLoc: Located<String>
  ) -> PropertyKind {
    let key = keyLoc.value
    let value = valueLoc.value

    func valueError(_ err: ParseError) -> PropertyKind {
      error(err, at: valueLoc.location)
      return .invalid(key: key, value: value)
    }

    guard !key.isEmpty else {
      error(.emptyProperty, at: keyLoc.location)
      return .invalid(key: key, value: value)
    }
    guard !value.isEmpty else {
      return valueError(.emptyProperty)
    }

    if let prop = Self.classifyBoolProperty(key),
       let isTrue = Self.classifyCharacterPropertyBoolValue(value) {
      return .binary(prop, value: isTrue)
    }

    // This uses the aliases defined in
    // https://www.unicode.org/Public/UCD/latest/ucd/PropertyAliases.txt.
    let match = Self.withNormalizedForms(key) { normalizedKey -> PropertyKind? in
      switch normalizedKey {
      case "script", "sc":
        guard let script = Self.classifyScriptProperty(value) else {
          return valueError(.unrecognizedScript(value))
        }
        return .script(script)
      case "scriptextensions", "scx":
        guard let script = Self.classifyScriptProperty(value) else {
          return valueError(.unrecognizedScript(value))
        }
        return .scriptExtension(script)
      case "gc", "generalcategory":
        guard let cat = Self.classifyGeneralCategory(value) else {
          return valueError(.unrecognizedCategory(value))
        }
        return .generalCategory(cat)
      case "age":
        guard let (major, minor) = Self.parseAge(value) else {
          return valueError(.invalidAge(value))
        }
        return .age(major: major, minor: minor)
      case "name", "na":
        return .named(value)
      case "numericvalue", "nv":
        guard let numericValue = Double(value) else {
          return valueError(.invalidNumericValue(value))
        }
        return .numericValue(numericValue)
      case "numerictype", "nt":
        guard let type = Self.classifyNumericType(value) else {
          return valueError(.unrecognizedNumericType(value))
        }
        return .numericType(type)
      case "slc", "simplelowercasemapping":
        return .mapping(.lowercase, value)
      case "suc", "simpleuppercasemapping":
        return .mapping(.uppercase, value)
      case "stc", "simpletitlecasemapping":
        return .mapping(.titlecase, value)
      case "ccc", "canonicalcombiningclass":
        guard let cccValue = UInt8(value), cccValue <= 254 else {
          return valueError(.invalidCCC(value))
        }
        return .ccc(.init(rawValue: cccValue))

      case "blk", "block":
        guard let block = Self.classifyBlockProperty(value, valueOnly: false) else {
          return valueError(.unrecognizedBlock(value))
        }
        return .block(block)
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
    error(.unknownProperty(key: key, value: value),
          at: keyLoc.location.union(with: valueLoc.location))
    return .invalid(key: key, value: value)
  }
}
