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

// MARK: - Missing stdlib API

extension Unicode {
  // Note: The `Script` enum includes the "meta" script type "Katakana_Or_Hiragana", which
  // isn't defined by https://www.unicode.org/Public/UCD/latest/ucd/Scripts.txt,
  // but is defined by https://www.unicode.org/Public/UCD/latest/ucd/PropertyValueAliases.txt.
  // We may want to split it out, as it's the only case that is a union of
  // other script types.

  /// Character script types.
  public enum Script: String, Hashable, CaseIterable {
    case adlam = "Adlam"
    case ahom = "Ahom"
    case anatolianHieroglyphs = "Anatolian_Hieroglyphs"
    case arabic = "Arabic"
    case armenian = "Armenian"
    case avestan = "Avestan"
    case balinese = "Balinese"
    case bamum = "Bamum"
    case bassaVah = "Bassa_Vah"
    case batak = "Batak"
    case bengali = "Bengali"
    case bhaiksuki = "Bhaiksuki"
    case bopomofo = "Bopomofo"
    case brahmi = "Brahmi"
    case braille = "Braille"
    case buginese = "Buginese"
    case buhid = "Buhid"
    case canadianAboriginal = "Canadian_Aboriginal"
    case carian = "Carian"
    case caucasianAlbanian = "Caucasian_Albanian"
    case chakma = "Chakma"
    case cham = "Cham"
    case cherokee = "Cherokee"
    case chorasmian = "Chorasmian"
    case common = "Common"
    case coptic = "Coptic"
    case cuneiform = "Cuneiform"
    case cypriot = "Cypriot"
    case cyrillic = "Cyrillic"
    case cyproMinoan = "Cypro_Minoan"
    case deseret = "Deseret"
    case devanagari = "Devanagari"
    case divesAkuru = "Dives_Akuru"
    case dogra = "Dogra"
    case duployan = "Duployan"
    case egyptianHieroglyphs = "Egyptian_Hieroglyphs"
    case elbasan = "Elbasan"
    case elymaic = "Elymaic"
    case ethiopic = "Ethiopic"
    case georgian = "Georgian"
    case glagolitic = "Glagolitic"
    case gothic = "Gothic"
    case grantha = "Grantha"
    case greek = "Greek"
    case gujarati = "Gujarati"
    case gunjalaGondi = "Gunjala_Gondi"
    case gurmukhi = "Gurmukhi"
    case han = "Han"
    case hangul = "Hangul"
    case hanifiRohingya = "Hanifi_Rohingya"
    case hanunoo = "Hanunoo"
    case hatran = "Hatran"
    case hebrew = "Hebrew"
    case hiragana = "Hiragana"
    case imperialAramaic = "Imperial_Aramaic"
    case inherited = "Inherited"
    case inscriptionalPahlavi = "Inscriptional_Pahlavi"
    case inscriptionalParthian = "Inscriptional_Parthian"
    case javanese = "Javanese"
    case kaithi = "Kaithi"
    case kannada = "Kannada"
    case katakana = "Katakana"
    case katakanaOrHiragana = "Katakana_Or_Hiragana"
    case kayahLi = "Kayah_Li"
    case kharoshthi = "Kharoshthi"
    case khitanSmallScript = "Khitan_Small_Script"
    case khmer = "Khmer"
    case khojki = "Khojki"
    case khudawadi = "Khudawadi"
    case lao = "Lao"
    case latin = "Latin"
    case lepcha = "Lepcha"
    case limbu = "Limbu"
    case linearA = "Linear_A"
    case linearB = "Linear_B"
    case lisu = "Lisu"
    case lycian = "Lycian"
    case lydian = "Lydian"
    case mahajani = "Mahajani"
    case makasar = "Makasar"
    case malayalam = "Malayalam"
    case mandaic = "Mandaic"
    case manichaean = "Manichaean"
    case marchen = "Marchen"
    case masaramGondi = "Masaram_Gondi"
    case medefaidrin = "Medefaidrin"
    case meeteiMayek = "Meetei_Mayek"
    case mendeKikakui = "Mende_Kikakui"
    case meroiticCursive = "Meroitic_Cursive"
    case meroiticHieroglyphs = "Meroitic_Hieroglyphs"
    case miao = "Miao"
    case modi = "Modi"
    case mongolian = "Mongolian"
    case mro = "Mro"
    case multani = "Multani"
    case myanmar = "Myanmar"
    case nabataean = "Nabataean"
    case nandinagari = "Nandinagari"
    case newa = "Newa"
    case newTaiLue = "New_Tai_Lue"
    case nko = "Nko"
    case nushu = "Nushu"
    case nyiakengPuachueHmong = "Nyiakeng_Puachue_Hmong"
    case ogham = "Ogham"
    case olChiki = "Ol_Chiki"
    case oldHungarian = "Old_Hungarian"
    case oldItalic = "Old_Italic"
    case oldNorthArabian = "Old_North_Arabian"
    case oldPermic = "Old_Permic"
    case oldPersian = "Old_Persian"
    case oldSogdian = "Old_Sogdian"
    case oldSouthArabian = "Old_South_Arabian"
    case oldTurkic = "Old_Turkic"
    case oldUyghur = "Old_Uyghur"
    case oriya = "Oriya"
    case osage = "Osage"
    case osmanya = "Osmanya"
    case pahawhHmong = "Pahawh_Hmong"
    case palmyrene = "Palmyrene"
    case pauCinHau = "Pau_Cin_Hau"
    case phagsPa = "Phags_Pa"
    case phoenician = "Phoenician"
    case psalterPahlavi = "Psalter_Pahlavi"
    case rejang = "Rejang"
    case runic = "Runic"
    case samaritan = "Samaritan"
    case saurashtra = "Saurashtra"
    case sharada = "Sharada"
    case shavian = "Shavian"
    case siddham = "Siddham"
    case signWriting = "SignWriting"
    case sinhala = "Sinhala"
    case sogdian = "Sogdian"
    case soraSompeng = "Sora_Sompeng"
    case soyombo = "Soyombo"
    case sundanese = "Sundanese"
    case sylotiNagri = "Syloti_Nagri"
    case syriac = "Syriac"
    case tagalog = "Tagalog"
    case tagbanwa = "Tagbanwa"
    case taiLe = "Tai_Le"
    case taiTham = "Tai_Tham"
    case taiViet = "Tai_Viet"
    case takri = "Takri"
    case tamil = "Tamil"
    case tangsa = "Tangsa"
    case tangut = "Tangut"
    case telugu = "Telugu"
    case thaana = "Thaana"
    case thai = "Thai"
    case tibetan = "Tibetan"
    case tifinagh = "Tifinagh"
    case tirhuta = "Tirhuta"
    case toto = "Toto"
    case ugaritic = "Ugaritic"
    case unknown = "Unknown"
    case vai = "Vai"
    case vithkuqi = "Vithkuqi"
    case wancho = "Wancho"
    case warangCiti = "Warang_Citi"
    case yezidi = "Yezidi"
    case yi = "Yi"
    case zanabazarSquare = "Zanabazar_Square"
  }

  /// POSIX character properties not already covered by general categories or
  /// binary properties.
  public enum POSIXProperty: String, Hashable, CaseIterable {
    case alnum = "alnum"
    case blank = "blank"
    case graph = "graph"
    case print = "print"
    case word = "word"
    case xdigit = "xdigit"
    // As per http://www.unicode.org/reports/tr18/#Compatibility_Properties,
    // [:alpha:], [:lower:], [:upper:], and [:space:] are covered by binary
    // properties. [:punct:], [:digit:], and [:cntrl:] are covered by general
    // categories. [:ascii:] is covered by CharacterProperty.Kind.ascii.
    // These may have different semantics depending on matching mode, but that
    // should be left up to the matching engine.
  }

  /// Unicode.GeneralCategory + cases for "meta categories" such as "L", which
  /// encompasses Lu | Ll | Lt | Lm | Lo.
  public enum ExtendedGeneralCategory: String, Hashable, CaseIterable {
    case other = "C"
    case control = "Cc"
    case format = "Cf"
    case unassigned = "Cn"
    case privateUse = "Co"
    case surrogate = "Cs"

    case letter = "L"
    case casedLetter = "Lc"
    case lowercaseLetter = "Ll"
    case modifierLetter = "Lm"
    case otherLetter = "Lo"
    case titlecaseLetter = "Lt"
    case uppercaseLetter = "Lu"

    case mark = "M"
    case spacingMark = "Mc"
    case enclosingMark = "Me"
    case nonspacingMark = "Mn"

    case number = "N"
    case decimalNumber = "Nd"
    case letterNumber = "Nl"
    case otherNumber = "No"

    case punctuation = "P"
    case connectorPunctuation = "Pc"
    case dashPunctuation = "Pd"
    case closePunctuation = "Pe"
    case finalPunctuation = "Pf"
    case initialPunctuation = "Pi"
    case otherPunctuation = "Po"
    case openPunctuation = "Ps"

    case symbol = "S"
    case currencySymbol = "Sc"
    case modifierSymbol = "Sk"
    case mathSymbol = "Sm"
    case otherSymbol = "So"

    case separator = "Z"
    case lineSeparator = "Zl"
    case paragraphSeparator = "Zp"
    case spaceSeparator = "Zs"
  }

  /// A list of Unicode properties that can either be true or false.
  ///
  /// https://www.unicode.org/Public/UCD/latest/ucd/PropertyAliases.txt
  public enum BinaryProperty: String, Hashable, CaseIterable {
    case asciiHexDigit = "ASCII_Hex_Digit"
    case alphabetic = "Alphabetic"
    case bidiControl = "Bidi_Control"
    case bidiMirrored = "Bidi_Mirrored"
    case cased = "Cased"
    case compositionExclusion = "Composition_Exclusion"
    case caseIgnorable = "Case_Ignorable"
    case changesWhenCasefolded = "Changes_When_Casefolded"
    case changesWhenCasemapped = "Changes_When_Casemapped"
    case changesWhenNFKCCasefolded = "Changes_When_NFKC_Casefolded"
    case changesWhenLowercased = "Changes_When_Lowercased"
    case changesWhenTitlecased = "Changes_When_Titlecased"
    case changesWhenUppercased = "Changes_When_Uppercased"
    case dash = "Dash"
    case deprecated = "Deprecated"
    case defaultIgnorableCodePoint = "Default_Ignorable_Code_Point"
    case diacratic = "Diacritic"
    case emojiModifierBase = "Emoji_Modifier_Base"
    case emojiComponent = "Emoji_Component"
    case emojiModifier = "Emoji_Modifier"
    case emoji = "Emoji"
    case emojiPresentation = "Emoji_Presentation"
    case extender = "Extender"
    case extendedPictographic = "Extended_Pictographic"
    case fullCompositionExclusion = "Full_Composition_Exclusion"
    case graphemeBase = "Grapheme_Base"
    case graphemeExtended = "Grapheme_Extend"
    case graphemeLink = "Grapheme_Link"
    case hexDigit = "Hex_Digit"
    case hyphen = "Hyphen"
    case idContinue = "ID_Continue"
    case ideographic = "Ideographic"
    case idStart = "ID_Start"
    case idsBinaryOperator = "IDS_Binary_Operator"
    case idsTrinaryOperator = "IDS_Trinary_Operator"
    case joinControl = "Join_Control"
    case logicalOrderException = "Logical_Order_Exception"
    case lowercase = "Lowercase"
    case math = "Math"
    case noncharacterCodePoint = "Noncharacter_Code_Point"
    case otherAlphabetic = "Other_Alphabetic"
    case otherDefaultIgnorableCodePoint = "Other_Default_Ignorable_Code_Point"
    case otherGraphemeExtended = "Other_Grapheme_Extend"
    case otherIDContinue = "Other_ID_Continue"
    case otherIDStart = "Other_ID_Start"
    case otherLowercase = "Other_Lowercase"
    case otherMath = "Other_Math"
    case otherUppercase = "Other_Uppercase"
    case patternSyntax = "Pattern_Syntax"
    case patternWhitespace = "Pattern_White_Space"
    case prependedConcatenationMark = "Prepended_Concatenation_Mark"
    case quotationMark = "Quotation_Mark"
    case radical = "Radical"
    case regionalIndicator = "Regional_Indicator"
    case softDotted = "Soft_Dotted"
    case sentenceTerminal = "Sentence_Terminal"
    case terminalPunctuation = "Terminal_Punctuation"
    case unifiedIdiograph = "Unified_Ideograph"
    case uppercase = "Uppercase"
    case variationSelector = "Variation_Selector"
    case whitespace = "White_Space"
    case xidContinue = "XID_Continue"
    case xidStart = "XID_Start"
    case expandsOnNFC = "Expands_On_NFC"
    case expandsOnNFD = "Expands_On_NFD"
    case expandsOnNFKC = "Expands_On_NFKC"
    case expandsOnNFKD = "Expands_On_NFKD"
  }

  /// A list of unicode character blocks, including `No_Block`.
  /// https://www.unicode.org/Public/UCD/latest/ucd/Blocks.txt
  public enum Block: String, Hashable, CaseIterable {
    /// 0000..007F; Basic Latin
    case basicLatin                                  = "Basic_Latin"
    /// 0080..00FF; Latin-1 Supplement
    case latin1Supplement                            = "Latin_1_Supplement"
    /// 0100..017F; Latin Extended-A
    case latinExtendedA                              = "Latin_Extended_A"
    /// 0180..024F; Latin Extended-B
    case latinExtendedB                              = "Latin_Extended_B"
    /// 0250..02AF; IPA Extensions
    case ipaExtensions                               = "IPA_Extensions"
    /// 02B0..02FF; Spacing Modifier Letters
    case spacingModifierLetters                      = "Spacing_Modifier_Letters"
    /// 0300..036F; Combining Diacritical Marks
    case combiningDiacriticalMarks                   = "Combining_Diacritical_Marks"
    /// 0370..03FF; Greek and Coptic
    case greekAndCoptic                              = "Greek_and_Coptic"
    /// 0400..04FF; Cyrillic
    case cyrillic                                    = "Cyrillic"
    /// 0500..052F; Cyrillic Supplement
    case cyrillicSupplement                          = "Cyrillic_Supplement"
    /// 0530..058F; Armenian
    case armenian                                    = "Armenian"
    /// 0590..05FF; Hebrew
    case hebrew                                      = "Hebrew"
    /// 0600..06FF; Arabic
    case arabic                                      = "Arabic"
    /// 0700..074F; Syriac
    case syriac                                      = "Syriac"
    /// 0750..077F; Arabic Supplement
    case arabicSupplement                            = "Arabic_Supplement"
    /// 0780..07BF; Thaana
    case thaana                                      = "Thaana"
    /// 07C0..07FF; NKo
    case nko                                         = "NKo"
    /// 0800..083F; Samaritan
    case samaritan                                   = "Samaritan"
    /// 0840..085F; Mandaic
    case mandaic                                     = "Mandaic"
    /// 0860..086F; Syriac Supplement
    case syriacSupplement                            = "Syriac_Supplement"
    /// 0870..089F; Arabic Extended-B
    case arabicExtendedB                             = "Arabic_Extended_B"
    /// 08A0..08FF; Arabic Extended-A
    case arabicExtendedA                             = "Arabic_Extended_A"
    /// 0900..097F; Devanagari
    case devanagari                                  = "Devanagari"
    /// 0980..09FF; Bengali
    case bengali                                     = "Bengali"
    /// 0A00..0A7F; Gurmukhi
    case gurmukhi                                    = "Gurmukhi"
    /// 0A80..0AFF; Gujarati
    case gujarati                                    = "Gujarati"
    /// 0B00..0B7F; Oriya
    case oriya                                       = "Oriya"
    /// 0B80..0BFF; Tamil
    case tamil                                       = "Tamil"
    /// 0C00..0C7F; Telugu
    case telugu                                      = "Telugu"
    /// 0C80..0CFF; Kannada
    case kannada                                     = "Kannada"
    /// 0D00..0D7F; Malayalam
    case malayalam                                   = "Malayalam"
    /// 0D80..0DFF; Sinhala
    case sinhala                                     = "Sinhala"
    /// 0E00..0E7F; Thai
    case thai                                        = "Thai"
    /// 0E80..0EFF; Lao
    case lao                                         = "Lao"
    /// 0F00..0FFF; Tibetan
    case tibetan                                     = "Tibetan"
    /// 1000..109F; Myanmar
    case myanmar                                     = "Myanmar"
    /// 10A0..10FF; Georgian
    case georgian                                    = "Georgian"
    /// 1100..11FF; Hangul Jamo
    case hangulJamo                                  = "Hangul_Jamo"
    /// 1200..137F; Ethiopic
    case ethiopic                                    = "Ethiopic"
    /// 1380..139F; Ethiopic Supplement
    case ethiopicSupplement                          = "Ethiopic_Supplement"
    /// 13A0..13FF; Cherokee
    case cherokee                                    = "Cherokee"
    /// 1400..167F; Unified Canadian Aboriginal Syllabics
    case unifiedCanadianAboriginalSyllabics          = "Unified_Canadian_Aboriginal_Syllabics"
    /// 1680..169F; Ogham
    case ogham                                       = "Ogham"
    /// 16A0..16FF; Runic
    case runic                                       = "Runic"
    /// 1700..171F; Tagalog
    case tagalog                                     = "Tagalog"
    /// 1720..173F; Hanunoo
    case hanunoo                                     = "Hanunoo"
    /// 1740..175F; Buhid
    case buhid                                       = "Buhid"
    /// 1760..177F; Tagbanwa
    case tagbanwa                                    = "Tagbanwa"
    /// 1780..17FF; Khmer
    case khmer                                       = "Khmer"
    /// 1800..18AF; Mongolian
    case mongolian                                   = "Mongolian"
    /// 18B0..18FF; Unified Canadian Aboriginal Syllabics Extended
    case unifiedCanadianAboriginalSyllabicsExtended  = "Unified_Canadian_Aboriginal_Syllabics_Extended"
    /// 1900..194F; Limbu
    case limbu                                       = "Limbu"
    /// 1950..197F; Tai Le
    case taiLe                                       = "Tai_Le"
    /// 1980..19DF; New Tai Lue
    case newTailue                                   = "New_Tai_Lue"
    /// 19E0..19FF; Khmer Symbols
    case khmerSymbols                                = "Khmer_Symbols"
    /// 1A00..1A1F; Buginese
    case buginese                                    = "Buginese"
    /// 1A20..1AAF; Tai Tham
    case taiTham                                     = "Tai_Tham"
    /// 1AB0..1AFF; Combining Diacritical Marks Extended
    case combiningDiacriticalMarksExtended           = "Combining_Diacritical_Marks_Extended"
    /// 1B00..1B7F; Balinese
    case balinese                                    = "Balinese"
    /// 1B80..1BBF; Sundanese
    case sundanese                                   = "Sundanese"
    /// 1BC0..1BFF; Batak
    case batak                                       = "Batak"
    /// 1C00..1C4F; Lepcha
    case lepcha                                      = "Lepcha"
    /// 1C50..1C7F; Ol Chiki
    case olChiki                                     = "Ol_Chiki"
    /// 1C80..1C8F; Cyrillic Extended-C
    case cyrillicExtendedC                           = "Cyrillic_Extended_C"
    /// 1C90..1CBF; Georgian Extended
    case georgianExtended                            = "Georgian_Extended"
    /// 1CC0..1CCF; Sundanese Supplement
    case sundaneseSupplement                         = "Sundanese_Supplement"
    /// 1CD0..1CFF; Vedic Extensions
    case vedicExtensions                             = "Vedic_Extensions"
    /// 1D00..1D7F; Phonetic Extensions
    case phoneticExtensions                          = "Phonetic_Extensions"
    /// 1D80..1DBF; Phonetic Extensions Supplement
    case phoneticExtensionsSupplement                = "Phonetic_Extensions_Supplement"
    /// 1DC0..1DFF; Combining Diacritical Marks Supplement
    case combiningDiacriticalMarksSupplement         = "Combining_Diacritical_Marks_Supplement"
    /// 1E00..1EFF; Latin Extended Additional
    case latinExtendedAdditional                     = "Latin_Extended_Additional"
    /// 1F00..1FFF; Greek Extended
    case greekExtended                               = "Greek_Extended"
    /// 2000..206F; General Punctuation
    case generalPunctuation                          = "General_Punctuation"
    /// 2070..209F; Superscripts and Subscripts
    case superscriptsAndSubscripts                   = "Superscripts_and_Subscripts"
    /// 20A0..20CF; Currency Symbols
    case currencySymbols                             = "Currency_Symbols"
    /// 20D0..20FF; Combining Diacritical Marks for Symbols
    case combiningDiacriticalMarksForSymbols         = "Combining_Diacritical_Marks_for_Symbols"
    /// 2100..214F; Letterlike Symbols
    case letterLikeSymbols                           = "Letterlike_Symbols"
    /// 2150..218F; Number Forms
    case numberForms                                 = "Number_Forms"
    /// 2190..21FF; Arrows
    case arrows                                      = "Arrows"
    /// 2200..22FF; Mathematical Operators
    case mathematicalOperators                       = "Mathematical_Operators"
    /// 2300..23FF; Miscellaneous Technical
    case miscellaneousTechnical                      = "Miscellaneous_Technical"
    /// 2400..243F; Control Pictures
    case controlPictures                             = "Control_Pictures"
    /// 2440..245F; Optical Character Recognition
    case opticalCharacterRecognition                 = "Optical_Character_Recognition"
    /// 2460..24FF; Enclosed Alphanumerics
    case enclosedAlphanumerics                       = "Enclosed_Alphanumerics"
    /// 2500..257F; Box Drawing
    case boxDrawing                                  = "Box_Drawing"
    /// 2580..259F; Block Elements
    case blockElements                               = "Block_Elements"
    /// 25A0..25FF; Geometric Shapes
    case geometricShapes                             = "Geometric_Shapes"
    /// 2600..26FF; Miscellaneous Symbols
    case miscellaneousSymbols                        = "Miscellaneous_Symbols"
    /// 2700..27BF; Dingbats
    case dingbats                                    = "Dingbats"
    /// 27C0..27EF; Miscellaneous Mathematical Symbols-A
    case miscellaneousMathematicalSymbolsA           = "Miscellaneous_Mathematical_Symbols_A"
    /// 27F0..27FF; Supplemental Arrows-A
    case supplementalArrowsA                         = "Supplemental_Arrows_A"
    /// 2800..28FF; Braille Patterns
    case braillePatterns                             = "Braille_Patterns"
    /// 2900..297F; Supplemental Arrows-B
    case supplementalArrowsB                         = "Supplemental_Arrows_B"
    /// 2980..29FF; Miscellaneous Mathematical Symbols-B
    case miscellaneousMathematicalSymbolsB           = "Miscellaneous_Mathematical_Symbols_B"
    /// 2A00..2AFF; Supplemental Mathematical Operators
    case supplementalMathematicalOperators           = "Supplemental_Mathematical_Operators"
    /// 2B00..2BFF; Miscellaneous Symbols and Arrows
    case miscellaneousSymbolsAndArrows               = "Miscellaneous_Symbols_and_Arrows"
    /// 2C00..2C5F; Glagolitic
    case glagolitic                                  = "Glagolitic"
    /// 2C60..2C7F; Latin Extended-C
    case latinExtendedC                              = "Latin_Extended_C"
    /// 2C80..2CFF; Coptic
    case coptic                                      = "Coptic"
    /// 2D00..2D2F; Georgian Supplement
    case georgianSupplement                          = "Georgian_Supplement"
    /// 2D30..2D7F; Tifinagh
    case tifinagh                                    = "Tifinagh"
    /// 2D80..2DDF; Ethiopic Extended
    case ethiopicExtended                            = "Ethiopic_Extended"
    /// 2DE0..2DFF; Cyrillic Extended-A
    case cyrillicExtendedA                           = "Cyrillic_Extended_A"
    /// 2E00..2E7F; Supplemental Punctuation
    case supplementalPunctuation                     = "Supplemental_Punctuation"
    /// 2E80..2EFF; CJK Radicals Supplement
    case cjkRadicalsSupplement                       = "CJK_Radicals_Supplement"
    /// 2F00..2FDF; Kangxi Radicals
    case kangxiRadicals                              = "Kangxi_Radicals"
    /// 2FF0..2FFF; Ideographic Description Characters
    case ideographicDescriptionCharacters            = "Ideographic_Description_Characters"
    /// 3000..303F; CJK Symbols and Punctuation
    case cjkSymbolsAndPunctuation                    = "CJK_Symbols_and_Punctuation"
    /// 3040..309F; Hiragana
    case hiragana                                    = "Hiragana"
    /// 30A0..30FF; Katakana
    case katakana                                    = "Katakana"
    /// 3100..312F; Bopomofo
    case bopomofo                                    = "Bopomofo"
    /// 3130..318F; Hangul Compatibility Jamo
    case hangulCompatibilityJamo                     = "Hangul_Compatibility_Jamo"
    /// 3190..319F; Kanbun
    case kanbun                                      = "Kanbun"
    /// 31A0..31BF; Bopomofo Extended
    case bopomofoExtended                            = "Bopomofo_Extended"
    /// 31C0..31EF; CJK Strokes
    case cjkStrokes                                  = "CJK_Strokes"
    /// 31F0..31FF; Katakana Phonetic Extensions
    case katakanaPhoneticExtensions                  = "Katakana_Phonetic_Extensions"
    /// 3200..32FF; Enclosed CJK Letters and Months
    case enclosedCJKLettersAndMonths                 = "Enclosed_CJK_Letters_and_Months"
    /// 3300..33FF; CJK Compatibility
    case cjkCompatibility                            = "CJK_Compatibility"
    /// 3400..4DBF; CJK Unified Ideographs Extension A
    case cjkUnifiedIdeographsExtensionA              = "CJK_Unified_Ideographs_Extension_A"
    /// 4DC0..4DFF; Yijing Hexagram Symbols
    case yijingHexagramSymbols                       = "Yijing_Hexagram_Symbols"
    /// 4E00..9FFF; CJK Unified Ideographs
    case cjkUnifiedIdeographs                        = "CJK_Unified_Ideographs"
    /// A000..A48F; Yi Syllables
    case yiSyllables                                 = "Yi_Syllables"
    /// A490..A4CF; Yi Radicals
    case yiRadicals                                  = "Yi_Radicals"
    /// A4D0..A4FF; Lisu
    case lisu                                        = "Lisu"
    /// A500..A63F; Vai
    case vai                                         = "Vai"
    /// A640..A69F; Cyrillic Extended-B
    case cyrillicExtendedB                           = "Cyrillic_Extended_B"
    /// A6A0..A6FF; Bamum
    case bamum                                       = "Bamum"
    /// A700..A71F; Modifier Tone Letters
    case modifierToneLetters                         = "Modifier_Tone_Letters"
    /// A720..A7FF; Latin Extended-D
    case latinExtendedD                              = "Latin_Extended_D"
    /// A800..A82F; Syloti Nagri
    case sylotiNagri                                 = "Syloti_Nagri"
    /// A830..A83F; Common Indic Number Forms
    case commonIndicNumberForms                      = "Common_Indic_Number_Forms"
    /// A840..A87F; Phags-pa
    case phagsPA                                     = "Phags_pa"
    /// A880..A8DF; Saurashtra
    case saurashtra                                  = "Saurashtra"
    /// A8E0..A8FF; Devanagari Extended
    case devanagariExtended                          = "Devanagari_Extended"
    /// A900..A92F; Kayah Li
    case kayahLi                                     = "Kayah_Li"
    /// A930..A95F; Rejang
    case rejang                                      = "Rejang"
    /// A960..A97F; Hangul Jamo Extended-A
    case hangulJamoExtendedA                         = "Hangul_Jamo_Extended_A"
    /// A980..A9DF; Javanese
    case javanese                                    = "Javanese"
    /// A9E0..A9FF; Myanmar Extended-B
    case myanmarExtendedB                            = "Myanmar_Extended_B"
    /// AA00..AA5F; Cham
    case cham                                        = "Cham"
    /// AA60..AA7F; Myanmar Extended-A
    case myanmarExtendedA                            = "Myanmar_Extended_A"
    /// AA80..AADF; Tai Viet
    case taiViet                                     = "Tai_Viet"
    /// AAE0..AAFF; Meetei Mayek Extensions
    case meeteiMayekExtensions                       = "Meetei_Mayek_Extensions"
    /// AB00..AB2F; Ethiopic Extended-A
    case ethiopicExtendedA                           = "Ethiopic_Extended_A"
    /// AB30..AB6F; Latin Extended-E
    case latinExtendedE                              = "Latin_Extended_E"
    /// AB70..ABBF; Cherokee Supplement
    case cherokeeSupplement                          = "Cherokee_Supplement"
    /// ABC0..ABFF; Meetei Mayek
    case meeteiMayek                                 = "Meetei_Mayek"
    /// AC00..D7AF; Hangul Syllables
    case hangulSyllables                             = "Hangul_Syllables"
    /// D7B0..D7FF; Hangul Jamo Extended-B
    case hangulJamoExtendedB                         = "Hangul_Jamo_Extended_B"
    /// D800..DB7F; High Surrogates
    case highSurrogates                              = "High_Surrogates"
    /// DB80..DBFF; High Private Use Surrogates
    case highPrivateUseSurrogates                    = "High_Private_Use_Surrogates"
    /// DC00..DFFF; Low Surrogates
    case lowSurrogates                               = "Low_Surrogates"
    /// E000..F8FF; Private Use Area
    case privateUseArea                              = "Private_Use_Area"
    /// F900..FAFF; CJK Compatibility Ideographs
    case cjkCompatibilityIdeographs                  = "CJK_Compatibility_Ideographs"
    /// FB00..FB4F; Alphabetic Presentation Forms
    case alphabeticPresentationForms                 = "Alphabetic_Presentation_Forms"
    /// FB50..FDFF; Arabic Presentation Forms-A
    case arabicPresentationFormsA                    = "Arabic_Presentation_Forms_A"
    /// FE00..FE0F; Variation Selectors
    case variationSelectors                          = "Variation_Selectors"
    /// FE10..FE1F; Vertical Forms
    case verticalForms                               = "Vertical_Forms"
    /// FE20..FE2F; Combining Half Marks
    case combiningHalfMarks                          = "Combining_Half_Marks"
    /// FE30..FE4F; CJK Compatibility Forms
    case cjkcompatibilityForms                       = "CJK_Compatibility_Forms"
    /// FE50..FE6F; Small Form Variants
    case smallFormVariants                           = "Small_Form_Variants"
    /// FE70..FEFF; Arabic Presentation Forms-B
    case arabicPresentationFormsB                    = "Arabic_Presentation_Forms_B"
    /// FF00..FFEF; Halfwidth and Fullwidth Forms
    case halfwidthAndFullwidthForms                  = "Halfwidth_and_Fullwidth_Forms"
    /// FFF0..FFFF; Specials
    case specials                                    = "Specials"
    /// 10000..1007F; Linear B Syllabary
    case linearBSyllabary                            = "Linear_B_Syllabary"
    /// 10080..100FF; Linear B Ideograms
    case linearBIdeograms                            = "Linear_B_Ideograms"
    /// 10100..1013F; Aegean Numbers
    case aegeanNumbers                               = "Aegean_Numbers"
    /// 10140..1018F; Ancient Greek Numbers
    case ancientGreekNumbers                         = "Ancient_Greek_Numbers"
    /// 10190..101CF; Ancient Symbols
    case ancientSymbols                              = "Ancient_Symbols"
    /// 101D0..101FF; Phaistos Disc
    case phaistosDisc                                = "Phaistos_Disc"
    /// 10280..1029F; Lycian
    case lycian                                      = "Lycian"
    /// 102A0..102DF; Carian
    case carian                                      = "Carian"
    /// 102E0..102FF; Coptic Epact Numbers
    case copticEpactNumbers                          = "Coptic_Epact_Numbers"
    /// 10300..1032F; Old Italic
    case oldItalic                                   = "Old_Italic"
    /// 10330..1034F; Gothic
    case gothic                                      = "Gothic"
    /// 10350..1037F; Old Permic
    case oldPermic                                   = "Old_Permic"
    /// 10380..1039F; Ugaritic
    case ugaritic                                    = "Ugaritic"
    /// 103A0..103DF; Old Persian
    case oldPersian                                  = "Old_Persian"
    /// 10400..1044F; Deseret
    case deseret                                     = "Deseret"
    /// 10450..1047F; Shavian
    case shavian                                     = "Shavian"
    /// 10480..104AF; Osmanya
    case osmanya                                     = "Osmanya"
    /// 104B0..104FF; Osage
    case osage                                       = "Osage"
    /// 10500..1052F; Elbasan
    case elbasan                                     = "Elbasan"
    /// 10530..1056F; Caucasian Albanian
    case caucasianAlbanian                           = "Caucasian_Albanian"
    /// 10570..105BF; Vithkuqi
    case vithkuqi                                    = "Vithkuqi"
    /// 10600..1077F; Linear A
    case linearA                                     = "Linear_A"
    /// 10780..107BF; Latin Extended-F
    case latinExtendedF                              = "Latin_Extended_F"
    /// 10800..1083F; Cypriot Syllabary
    case cypriotSyllabary                            = "Cypriot_Syllabary"
    /// 10840..1085F; Imperial Aramaic
    case imperialAramaic                             = "Imperial_Aramaic"
    /// 10860..1087F; Palmyrene
    case palmyrene                                   = "Palmyrene"
    /// 10880..108AF; Nabataean
    case nabataean                                   = "Nabataean"
    /// 108E0..108FF; Hatran
    case hatran                                      = "Hatran"
    /// 10900..1091F; Phoenician
    case phoenician                                  = "Phoenician"
    /// 10920..1093F; Lydian
    case lydian                                      = "Lydian"
    /// 10980..1099F; Meroitic Hieroglyphs
    case meroiticHieroglyphs                         = "Meroitic_Hieroglyphs"
    /// 109A0..109FF; Meroitic Cursive
    case meroiticCursive                             = "Meroitic_Cursive"
    /// 10A00..10A5F; Kharoshthi
    case kharoshthi                                  = "Kharoshthi"
    /// 10A60..10A7F; Old South Arabian
    case oldSouthArabian                             = "Old_South_Arabian"
    /// 10A80..10A9F; Old North Arabian
    case oldNorthArabian                             = "Old_North_Arabian"
    /// 10AC0..10AFF; Manichaean
    case manichaean                                  = "Manichaean"
    /// 10B00..10B3F; Avestan
    case avestan                                     = "Avestan"
    /// 10B40..10B5F; Inscriptional Parthian
    case inscriptionalParthian                       = "Inscriptional_Parthian"
    /// 10B60..10B7F; Inscriptional Pahlavi
    case inscriptionalPahlavi                        = "Inscriptional_Pahlavi"
    /// 10B80..10BAF; Psalter Pahlavi
    case psalterPahlavi                              = "Psalter_Pahlavi"
    /// 10C00..10C4F; Old Turkic
    case oldTurkic                                   = "Old_Turkic"
    /// 10C80..10CFF; Old Hungarian
    case oldHungarian                                = "Old_Hungarian"
    /// 10D00..10D3F; Hanifi Rohingya
    case hanifiRohingya                              = "Hanifi_Rohingya"
    /// 10E60..10E7F; Rumi Numeral Symbols
    case rumiNumeralSymbols                          = "Rumi_Numeral_Symbols"
    /// 10E80..10EBF; Yezidi
    case yezidi                                      = "Yezidi"
    /// 10F00..10F2F; Old Sogdian
    case oldSogdian                                  = "Old_Sogdian"
    /// 10F30..10F6F; Sogdian
    case sogdian                                     = "Sogdian"
    /// 10F70..10FAF; Old Uyghur
    case oldUyghur                                   = "Old_Uyghur"
    /// 10FB0..10FDF; Chorasmian
    case chorasmian                                  = "Chorasmian"
    /// 10FE0..10FFF; Elymaic
    case elymaic                                     = "Elymaic"
    /// 11000..1107F; Brahmi
    case brahmi                                      = "Brahmi"
    /// 11080..110CF; Kaithi
    case kaithi                                      = "Kaithi"
    /// 110D0..110FF; Sora Sompeng
    case soraSompeng                                 = "Sora_Sompeng"
    /// 11100..1114F; Chakma
    case chakma                                      = "Chakma"
    /// 11150..1117F; Mahajani
    case mahajani                                    = "Mahajani"
    /// 11180..111DF; Sharada
    case sharada                                     = "Sharada"
    /// 111E0..111FF; Sinhala Archaic Numbers
    case sinhalaArchaicNumbers                       = "Sinhala_Archaic_Numbers"
    /// 11200..1124F; Khojki
    case khojki                                      = "Khojki"
    /// 11280..112AF; Multani
    case multani                                     = "Multani"
    /// 112B0..112FF; Khudawadi
    case khudawadi                                   = "Khudawadi"
    /// 11300..1137F; Grantha
    case grantha                                     = "Grantha"
    /// 11400..1147F; Newa
    case newa                                        = "Newa"
    /// 11480..114DF; Tirhuta
    case tirhuta                                     = "Tirhuta"
    /// 11580..115FF; Siddham
    case siddham                                     = "Siddham"
    /// 11600..1165F; Modi
    case modi                                        = "Modi"
    /// 11660..1167F; Mongolian Supplement
    case mongolianSupplement                         = "Mongolian_Supplement"
    /// 11680..116CF; Takri
    case takri                                       = "Takri"
    /// 11700..1174F; Ahom
    case ahom                                        = "Ahom"
    /// 11800..1184F; Dogra
    case dogra                                       = "Dogra"
    /// 118A0..118FF; Warang Citi
    case warangCiti                                  = "Warang_Citi"
    /// 11900..1195F; Dives Akuru
    case divesAkuru                                  = "Dives_Akuru"
    /// 119A0..119FF; Nandinagari
    case nandinagari                                 = "Nandinagari"
    /// 11A00..11A4F; Zanabazar Square
    case zanabazarSquare                             = "Zanabazar_Square"
    /// 11A50..11AAF; Soyombo
    case soyombo                                     = "Soyombo"
    /// 11AB0..11ABF; Unified Canadian Aboriginal Syllabics Extended-A
    case unifiedCanadianAboriginalSyllabicsExtendedA = "Unified_Canadian_Aboriginal_Syllabics_Extended_A"
    /// 11AC0..11AFF; Pau Cin Hau
    case pauCinHau                                   = "Pau_Cin_Hau"
    /// 11C00..11C6F; Bhaiksuki
    case bhaiksuki                                   = "Bhaiksuki"
    /// 11C70..11CBF; Marchen
    case marchen                                     = "Marchen"
    /// 11D00..11D5F; Masaram Gondi
    case masaramGondi                                = "Masaram_Gondi"
    /// 11D60..11DAF; Gunjala Gondi
    case gunjalaGondi                                = "Gunjala_Gondi"
    /// 11EE0..11EFF; Makasar
    case makasar                                     = "Makasar"
    /// 11FB0..11FBF; Lisu Supplement
    case lisuSupplement                              = "Lisu_Supplement"
    /// 11FC0..11FFF; Tamil Supplement
    case tamilSupplement                             = "Tamil_Supplement"
    /// 12000..123FF; Cuneiform
    case cuneiform                                   = "Cuneiform"
    /// 12400..1247F; Cuneiform Numbers and Punctuation
    case cuneiformNumbersAndPunctuation              = "Cuneiform_Numbers_and_Punctuation"
    /// 12480..1254F; Early Dynastic Cuneiform
    case earlyDynasticCuneiform                      = "Early_Dynastic_Cuneiform"
    /// 12F90..12FFF; Cypro-Minoan
    case cyproMinoan                                 = "Cypro_Minoan"
    /// 13000..1342F; Egyptian Hieroglyphs
    case egyptianHieroglyphs                         = "Egyptian_Hieroglyphs"
    /// 13430..1343F; Egyptian Hieroglyph Format Controls
    case egyptianHieroglyphFormatControls            = "Egyptian_Hieroglyph_Format_Controls"
    /// 14400..1467F; Anatolian Hieroglyphs
    case anatolianHieroglyphs                        = "Anatolian_Hieroglyphs"
    /// 16800..16A3F; Bamum Supplement
    case bamumSupplement                             = "Bamum_Supplement"
    /// 16A40..16A6F; Mro
    case mro                                         = "Mro"
    /// 16A70..16ACF; Tangsa
    case tangsa                                      = "Tangsa"
    /// 16AD0..16AFF; Bassa Vah
    case bassaVah                                    = "Bassa_Vah"
    /// 16B00..16B8F; Pahawh Hmong
    case pahawhHmong                                 = "Pahawh_Hmong"
    /// 16E40..16E9F; Medefaidrin
    case medefaidrin                                 = "Medefaidrin"
    /// 16F00..16F9F; Miao
    case miao                                        = "Miao"
    /// 16FE0..16FFF; Ideographic Symbols and Punctuation
    case ideographicSymbolsAndPunctuation            = "Ideographic_Symbols_and_Punctuation"
    /// 17000..187FF; Tangut
    case tangut                                      = "Tangut"
    /// 18800..18AFF; Tangut Components
    case tangutComponents                            = "Tangut_Components"
    /// 18B00..18CFF; Khitan Small Script
    case khitanSmallScript                           = "Khitan_Small_Script"
    /// 18D00..18D7F; Tangut Supplement
    case tangutSupplement                            = "Tangut_Supplement"
    /// 1AFF0..1AFFF; Kana Extended-B
    case kanaExtendedB                               = "Kana_Extended_B"
    /// 1B000..1B0FF; Kana Supplement
    case kanaSupplement                              = "Kana_Supplement"
    /// 1B100..1B12F; Kana Extended-A
    case kanaExtendedA                               = "Kana_Extended_A"
    /// 1B130..1B16F; Small Kana Extension
    case smallKanaExtension                          = "Small_Kana_Extension"
    /// 1B170..1B2FF; Nushu
    case nushu                                       = "Nushu"
    /// 1BC00..1BC9F; Duployan
    case duployan                                    = "Duployan"
    /// 1BCA0..1BCAF; Shorthand Format Controls
    case shorthandFormatControls                     = "Shorthand_Format_Controls"
    /// 1CF00..1CFCF; Znamenny Musical Notation
    case znamennyMusicalNotation                     = "Znamenny_Musical_Notation"
    /// 1D000..1D0FF; Byzantine Musical Symbols
    case byzantineMusicalSymbols                     = "Byzantine_Musical_Symbols"
    /// 1D100..1D1FF; Musical Symbols
    case musicalSymbols                              = "Musical_Symbols"
    /// 1D200..1D24F; Ancient Greek Musical Notation
    case ancientGreekMusicalNotation                 = "Ancient_Greek_Musical_Notation"
    /// 1D2E0..1D2FF; Mayan Numerals
    case mayanNumerals                               = "Mayan_Numerals"
    /// 1D300..1D35F; Tai Xuan Jing Symbols
    case taiXuanJingSymbols                          = "Tai_Xuan_Jing_Symbols"
    /// 1D360..1D37F; Counting Rod Numerals
    case countingRodNumerals                         = "Counting_Rod_Numerals"
    /// 1D400..1D7FF; Mathematical Alphanumeric Symbols
    case mathematicalAlphanumericSymbols             = "Mathematical_Alphanumeric_Symbols"
    /// 1D800..1DAAF; Sutton SignWriting
    case suttonSignwriting                           = "Sutton_SignWriting"
    /// 1DF00..1DFFF; Latin Extended-G
    case latinExtendedG                              = "Latin_Extended_G"
    /// 1E000..1E02F; Glagolitic Supplement
    case glagoliticSupplement                        = "Glagolitic_Supplement"
    /// 1E100..1E14F; Nyiakeng Puachue Hmong
    case nyiakengPuachueHmong                        = "Nyiakeng_Puachue_Hmong"
    /// 1E290..1E2BF; Toto
    case toto                                        = "Toto"
    /// 1E2C0..1E2FF; Wancho
    case wancho                                      = "Wancho"
    /// 1E7E0..1E7FF; Ethiopic Extended-B
    case ethiopicExtendedB                           = "Ethiopic_Extended_B"
    /// 1E800..1E8DF; Mende Kikakui
    case mendeKikakui                                = "Mende_Kikakui"
    /// 1E900..1E95F; Adlam
    case adlam                                       = "Adlam"
    /// 1EC70..1ECBF; Indic Siyaq Numbers
    case indicSiyaqNumbers                           = "Indic_Siyaq_Numbers"
    /// 1ED00..1ED4F; Ottoman Siyaq Numbers
    case ottomanSiyaqNumbers                         = "Ottoman_Siyaq_Numbers"
    /// 1EE00..1EEFF; Arabic Mathematical Alphabetic Symbols
    case arabicMathematicalAlphabeticSymbols         = "Arabic_Mathematical_Alphabetic_Symbols"
    /// 1F000..1F02F; Mahjong Tiles
    case mahjongTiles                                = "Mahjong_Tiles"
    /// 1F030..1F09F; Domino Tiles
    case dominoTiles                                 = "Domino_Tiles"
    /// 1F0A0..1F0FF; Playing Cards
    case playingCards                                = "Playing_Cards"
    /// 1F100..1F1FF; Enclosed Alphanumeric Supplement
    case enclosedAlphanumericSupplement              = "Enclosed_Alphanumeric_Supplement"
    /// 1F200..1F2FF; Enclosed Ideographic Supplement
    case enclosedIdeographicSupplement               = "Enclosed_Ideographic_Supplement"
    /// 1F300..1F5FF; Miscellaneous Symbols and Pictographs
    case miscellaneousSymbolsandPictographs          = "Miscellaneous_Symbols_and_Pictographs"
    /// 1F600..1F64F; Emoticons
    case emoticons                                   = "Emoticons"
    /// 1F650..1F67F; Ornamental Dingbats
    case ornamentalDingbats                          = "Ornamental_Dingbats"
    /// 1F680..1F6FF; Transport and Map Symbols
    case transportAndMapSymbols                      = "Transport_and_Map_Symbols"
    /// 1F700..1F77F; Alchemical Symbols
    case alchemicalSymbols                           = "Alchemical_Symbols"
    /// 1F780..1F7FF; Geometric Shapes Extended
    case geometricShapesExtended                     = "Geometric_Shapes_Extended"
    /// 1F800..1F8FF; Supplemental Arrows-C
    case supplementalArrowsC                         = "Supplemental_Arrows_C"
    /// 1F900..1F9FF; Supplemental Symbols and Pictographs
    case supplementalSymbolsAndPictographs           = "Supplemental_Symbols_and_Pictographs"
    /// 1FA00..1FA6F; Chess Symbols
    case chessSymbols                                = "Chess_Symbols"
    /// 1FA70..1FAFF; Symbols and Pictographs Extended-A
    case symbolsAndPictographsExtendedA              = "Symbols_and_Pictographs_Extended_A"
    /// 1FB00..1FBFF; Symbols for Legacy Computing
    case symbolsForLegacyComputing                   = "Symbols_for_Legacy_Computing"
    /// 20000..2A6DF; CJK Unified Ideographs Extension B
    case cjkUnifiedIdeographsExtensionB              = "CJK_Unified_Ideographs_Extension_B"
    /// 2A700..2B73F; CJK Unified Ideographs Extension C
    case cjkUnifiedIdeographsExtensionC              = "CJK_Unified_Ideographs_Extension_C"
    /// 2B740..2B81F; CJK Unified Ideographs Extension D
    case cjkUnifiedIdeographsExtensionD              = "CJK_Unified_Ideographs_Extension_D"
    /// 2B820..2CEAF; CJK Unified Ideographs Extension E
    case cjkUnifiedIdeographsExtensionE              = "CJK_Unified_Ideographs_Extension_E"
    /// 2CEB0..2EBEF; CJK Unified Ideographs Extension F
    case cjkUnifiedIdeographsExtensionF              = "CJK_Unified_Ideographs_Extension_F"
    /// 2F800..2FA1F; CJK Compatibility Ideographs Supplement
    case cjkCompatibilityIdeographsSupplement        = "CJK_Compatibility_Ideographs_Supplement"
    /// 30000..3134F; CJK Unified Ideographs Extension G
    case cjkUnifiedIdeographsExtensionG              = "CJK_Unified_Ideographs_Extension_G"
    /// E0000..E007F; Tags
    case tags                                        = "Tags"
    /// E0100..E01EF; Variation Selectors Supplement
    case variationSelectorsSupplement                = "Variation_Selectors_Supplement"
    /// F0000..FFFFF; Supplementary Private Use Area-A
    case supplementaryPrivateUseAreaA                = "Supplementary_Private_Use_Area_A"
    /// 100000..10FFFF; Supplementary Private Use Area-B
    case supplementaryPrivateUseAreaB                = "Supplementary_Private_Use_Area_B"
    /// @missing: 0000..10FFFF; No_Block
    case noBlock                                     = "No_Block"
  }
}

extension Character {
  /// Whether this character represents an octal (base 8) digit,
  /// for the purposes of pattern parsing.
  public var isOctalDigit: Bool { ("0"..."7").contains(self) }

  /// Whether this character represents a word character,
  /// for the purposes of pattern parsing.
  public var isWordCharacter: Bool { isLetter || isNumber || self == "_" }

  /// Whether this character represents whitespace,
  /// for the purposes of pattern parsing.
  public var isPatternWhitespace: Bool {
    return unicodeScalars.first!.properties.isPatternWhitespace
  }
}

extension UnicodeScalar {
  /// Whether this character represents a printable ASCII character,
  /// for the purposes of pattern parsing.
  public var isPrintableASCII: Bool {
    // Exclude non-printables before the space character U+20, and anything
    // including and above the DEL character U+7F.
    value >= 0x20 && value < 0x7F
  }
}
