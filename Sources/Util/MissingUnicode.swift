// MARK: - Missing stdlib API

extension Unicode {
  public enum Script: String {
    case arabic = "Arabic"
    case armenian = "Armenian"
    case avestan = "Avestan"
    case balinese = "Balinese"
    case bamum = "Bamum"
    case bassaVah = "Bassa_Vah"
    case batak = "Batak"
    case bengali = "Bengali"
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
    case common = "Common"
    case coptic = "Coptic"
    case cuneiform = "Cuneiform"
    case cypriot = "Cypriot"
    case cyrillic = "Cyrillic"
    case deseret = "Deseret"
    case devanagari = "Devanagari"
    case duployan = "Duployan"
    case egyptianHieroglyphs = "Egyptian_Hieroglyphs"
    case elbasan = "Elbasan"
    case ethiopic = "Ethiopic"
    case georgian = "Georgian"
    case glagolitic = "Glagolitic"
    case gothic = "Gothic"
    case grantha = "Grantha"
    case greek = "Greek"
    case gujarati = "Gujarati"
    case gurmukhi = "Gurmukhi"
    case han = "Han"
    case hangul = "Hangul"
    case hanunoo = "Hanunoo"
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
    case kayah_Li = "Kayah_Li"
    case kharoshthi = "Kharoshthi"
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
    case malayalam = "Malayalam"
    case mandaic = "Mandaic"
    case manichaean = "Manichaean"
    case meeteiMayek = "Meetei_Mayek"
    case mendeKikakui = "Mende_Kikakui"
    case meroiticCursive = "Meroitic_Cursive"
    case meroiticHieroglyphs = "Meroitic_Hieroglyphs"
    case miao = "Miao"
    case modi = "Modi"
    case mongolian = "Mongolian"
    case mro = "Mro"
    case myanmar = "Myanmar"
    case nabataean = "Nabataean"
    case newTaiLue = "New_Tai_Lue"
    case nko = "Nko"
    case ogham = "Ogham"
    case olChiki = "Ol_Chiki"
    case oldItalic = "Old_Italic"
    case oldNorthArabian = "Old_North_Arabian"
    case oldPermic = "Old_Permic"
    case oldPersian = "Old_Persian"
    case oldSouthArabian = "Old_South_Arabian"
    case oldTurkic = "Old_Turkic"
    case oriya = "Oriya"
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
    case sinhala = "Sinhala"
    case soraSompeng = "Sora_Sompeng"
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
    case telugu = "Telugu"
    case thaana = "Thaana"
    case thai = "Thai"
    case tibetan = "Tibetan"
    case tifinagh = "Tifinagh"
    case tirhuta = "Tirhuta"
    case ugaritic = "Ugaritic"
    case vai = "Vai"
    case warangCiti = "Warang_Citi"
    case yi = "Yi"
  }

  public enum POSIXCharacterSet: String {
    case alnum = "alnum"
    case alpha = "alpha"
    case ascii = "ascii"
    case blank = "blank"
    case cntrl = "cntrl"
    case digit = "digit"
    case graph = "graph"
    case lower = "lower"
    case print = "print"
    case punct = "punct"
    case space = "space"
    case upper = "upper"
    case word = "word"
    case xdigit = "xdigit"
  }
}

// Oniguruma presents itself as just a flattened list of 
// properties, rather than interpreting whether it's a script
// or something else. Here I just splat it all in an enum,
// TBD how we actually model it.
public enum FlattendedOnigurumaUnicodeProperty: String {
  case ASCII_Hex_Digit
  case Adlam
  case Ahom
  case Alphabetic
  case Anatolian_Hieroglyphs
  case `Any`
  case Arabic
  case Armenian
  case Assigned
  case Avestan
  case Balinese
  case Bamum
  case Bassa_Vah
  case Batak
  case Bengali
  case Bhaiksuki
  case Bidi_Control
  case Bopomofo
  case Brahmi
  case Braille
  case Buginese
  case Buhid
  case C
  case Canadian_Aboriginal
  case Carian
  case Case_Ignorable
  case Cased
  case Caucasian_Albanian
  case Cc
  case Cf
  case Chakma
  case Cham
  case Changes_When_Casefolded
  case Changes_When_Casemapped
  case Changes_When_Lowercased
  case Changes_When_Titlecased
  case Changes_When_Uppercased
  case Cherokee
  case Chorasmian
  case Cn
  case Co
  case Common
  case Coptic
  case Cs
  case Cuneiform
  case Cypriot
  case Cypro_Minoan
  case Cyrillic
  case Dash
  case Default_Ignorable_Code_Point
  case Deprecated
  case Deseret
  case Devanagari
  case Diacritic
  case Dives_Akuru
  case Dogra
  case Duployan
  case Egyptian_Hieroglyphs
  case Elbasan
  case Elymaic
  case Emoji
  case Emoji_Component
  case Emoji_Modifier
  case Emoji_Modifier_Base
  case Emoji_Presentation
  case Ethiopic
  case Extended_Pictographic
  case Extender
  case Georgian
  case Glagolitic
  case Gothic
  case Grantha
  case Grapheme_Base
  case Grapheme_Extend
  case Grapheme_Link
  case Greek
  case Gujarati
  case Gunjala_Gondi
  case Gurmukhi
  case Han
  case Hangul
  case Hanifi_Rohingya
  case Hanunoo
  case Hatran
  case Hebrew
  case Hex_Digit
  case Hiragana
  case Hyphen
  case IDS_Binary_Operator
  case IDS_Trinary_Operator
  case ID_Continue
  case ID_Start
  case Ideographic
  case Imperial_Aramaic
  case Inherited
  case Inscriptional_Pahlavi
  case Inscriptional_Parthian
  case Javanese
  case Join_Control
  case Kaithi
  case Kannada
  case Katakana
  case Kayah_Li
  case Kharoshthi
  case Khitan_Small_Script
  case Khmer
  case Khojki
  case Khudawadi
  case L
  case LC
  case Lao
  case Latin
  case Lepcha
  case Limbu
  case Linear_A
  case Linear_B
  case Lisu
  case Ll
  case Lm
  case Lo
  case Logical_Order_Exception
  case Lowercase
  case Lt
  case Lu
  case Lycian
  case Lydian
  case M
  case Mahajani
  case Makasar
  case Malayalam
  case Mandaic
  case Manichaean
  case Marchen
  case Masaram_Gondi
  case Math
  case Mc
  case Me
  case Medefaidrin
  case Meetei_Mayek
  case Mende_Kikakui
  case Meroitic_Cursive
  case Meroitic_Hieroglyphs
  case Miao
  case Mn
  case Modi
  case Mongolian
  case Mro
  case Multani
  case Myanmar
  case N
  case Nabataean
  case Nandinagari
  case Nd
  case New_Tai_Lue
  case Newa
  case Nko
  case Nl
  case No
  case Noncharacter_Code_Point
  case Nushu
  case Nyiakeng_Puachue_Hmong
  case Ogham
  case Ol_Chiki
  case Old_Hungarian
  case Old_Italic
  case Old_North_Arabian
  case Old_Permic
  case Old_Persian
  case Old_Sogdian
  case Old_South_Arabian
  case Old_Turkic
  case Old_Uyghur
  case Oriya
  case Osage
  case Osmanya
  case Other_Alphabetic
  case Other_Default_Ignorable_Code_Point
  case Other_Grapheme_Extend
  case Other_ID_Continue
  case Other_ID_Start
  case Other_Lowercase
  case Other_Math
  case Other_Uppercase
  case P
  case Pahawh_Hmong
  case Palmyrene
  case Pattern_Syntax
  case Pattern_White_Space
  case Pau_Cin_Hau
  case Pc
  case Pd
  case Pe
  case Pf
  case Phags_Pa
  case Phoenician
  case Pi
  case Po
  case Prepended_Concatenation_Mark
  case Ps
  case Psalter_Pahlavi
  case Quotation_Mark
  case Radical
  case Regional_Indicator
  case Rejang
  case Runic
  case S
  case Samaritan
  case Saurashtra
  case Sc
  case Sentence_Terminal
  case Sharada
  case Shavian
  case Siddham
  case SignWriting
  case Sinhala
  case Sk
  case Sm
  case So
  case Soft_Dotted
  case Sogdian
  case Sora_Sompeng
  case Soyombo
  case Sundanese
  case Syloti_Nagri
  case Syriac
  case Tagalog
  case Tagbanwa
  case Tai_Le
  case Tai_Tham
  case Tai_Viet
  case Takri
  case Tamil
  case Tangsa
  case Tangut
  case Telugu
  case Terminal_Punctuation
  case Thaana
  case Thai
  case Tibetan
  case Tifinagh
  case Tirhuta
  case Toto
  case Ugaritic
  case Unified_Ideograph
  case Unknown
  case Uppercase
  case Vai
  case Variation_Selector
  case Vithkuqi
  case Wancho
  case Warang_Citi
  case White_Space
  case XID_Continue
  case XID_Start
  case Yezidi
  case Yi
  case Z
  case Zanabazar_Square
  case Zl
  case Zp
  case Zs
  case Adlm
  case Aghb
  case AHex
  case Arab
  case Armi
  case Armn
  case Avst
  case Bali
  case Bamu
  case Bass
  case Batk
  case Beng
  case Bhks
  case Bidi_C
  case Bopo
  case Brah
  case Brai
  case Bugi
  case Buhd
  case Cakm
  case Cans
  case Cari
  case Cased_Letter
  case Cher
  case Chrs
  case CI
  case Close_Punctuation
  case Combining_Mark
  case Connector_Punctuation
  case Control
  case Copt
  case Cpmn
  case Cprt
  case Currency_Symbol
  case CWCF
  case CWCM
  case CWL
  case CWT
  case CWU
  case Cyrl
  case Dash_Punctuation
  case Decimal_Number
  case Dep
  case Deva
  case DI
  case Dia
  case Diak
  case Dogr
  case Dsrt
  case Dupl
  case EBase
  case EComp
  case Egyp
  case Elba
  case Elym
  case EMod
  case Enclosing_Mark
  case EPres
  case Ethi
  case Ext
  case ExtPict
  case Final_Punctuation
  case Format
  case Geor
  case Glag
  case Gong
  case Gonm
  case Goth
  case Gran
  case Gr_Base
  case Grek
  case Gr_Ext
  case Gr_Link
  case Gujr
  case Guru
  case Hang
  case Hani
  case Hano
  case Hatr
  case Hebr
  case Hex
  case Hira
  case Hluw
  case Hmng
  case Hmnp
  case Hung
  case IDC
  case Ideo
  case IDS
  case IDSB
  case IDST
  case Initial_Punctuation
  case Ital
  case Java
  case Join_C
  case Kali
  case Kana
  case Khar
  case Khmr
  case Khoj
  case Kits
  case Knda
  case Kthi
  case Lana
  case Laoo
  case Latn
  case Lepc
  case Letter
  case Letter_Number
  case Limb
  case Lina
  case Linb
  case Line_Separator
  case LOE
  case Lowercase_Letter
  case Lyci
  case Lydi
  case Mahj
  case Maka
  case Mand
  case Mani
  case Marc
  case Mark
  case Math_Symbol
  case Medf
  case Mend
  case Merc
  case Mero
  case Mlym
  case Modifier_Letter
  case Modifier_Symbol
  case Mong
  case Mroo
  case Mtei
  case Mult
  case Mymr
  case Nand
  case Narb
  case Nbat
  case NChar
  case Nkoo
  case Nonspacing_Mark
  case Nshu
  case Number
  case OAlpha
  case ODI
  case Ogam
  case OGr_Ext
  case OIDC
  case OIDS
  case Olck
  case OLower
  case OMath
  case Open_Punctuation
  case Orkh
  case Orya
  case Osge
  case Osma
  case Other
  case Other_Letter
  case Other_Number
  case Other_Punctuation
  case Other_Symbol
  case Ougr
  case OUpper
  case Palm
  case Paragraph_Separator
  case Pat_Syn
  case Pat_WS
  case Pauc
  case PCM
  case Perm
  case Phag
  case Phli
  case Phlp
  case Phnx
  case Plrd
  case Private_Use
  case Prti
  case Punctuation
  case Qaac
  case Qaai
  case QMark
  case RI
  case Rjng
  case Rohg
  case Runr
  case Samr
  case Sarb
  case Saur
  case SD
  case Separator
  case Sgnw
  case Shaw
  case Shrd
  case Sidd
  case Sind
  case Sinh
  case Sogd
  case Sogo
  case Sora
  case Soyo
  case Space_Separator
  case Spacing_Mark
  case STerm
  case Sund
  case Surrogate
  case Sylo
  case Symbol
  case Syrc
  case Tagb
  case Takr
  case Tale
  case Talu
  case Taml
  case Tang
  case Tavt
  case Telu
  case Term
  case Tfng
  case Tglg
  case Thaa
  case Tibt
  case Tirh
  case Titlecase_Letter
  case Tnsa
  case Ugar
  case UIdeo
  case Unassigned
  case Uppercase_Letter
  case Vaii
  case Vith
  case VS
  case Wara
  case Wcho
  case WSpace
  case XIDC
  case XIDS
  case Xpeo
  case Xsux
  case Yezi
  case Yiii
  case Zanb
  case Zinh
  case Zyyy
  case Zzzz
  case In_Basic_Latin
  case In_Latin_1_Supplement
  case In_Latin_Extended_A
  case In_Latin_Extended_B
  case In_IPA_Extensions
  case In_Spacing_Modifier_Letters
  case In_Combining_Diacritical_Marks
  case In_Greek_and_Coptic
  case In_Cyrillic
  case In_Cyrillic_Supplement
  case In_Armenian
  case In_Hebrew
  case In_Arabic
  case In_Syriac
  case In_Arabic_Supplement
  case In_Thaana
  case In_NKo
  case In_Samaritan
  case In_Mandaic
  case In_Syriac_Supplement
  case In_Arabic_Extended_B
  case In_Arabic_Extended_A
  case In_Devanagari
  case In_Bengali
  case In_Gurmukhi
  case In_Gujarati
  case In_Oriya
  case In_Tamil
  case In_Telugu
  case In_Kannada
  case In_Malayalam
  case In_Sinhala
  case In_Thai
  case In_Lao
  case In_Tibetan
  case In_Myanmar
  case In_Georgian
  case In_Hangul_Jamo
  case In_Ethiopic
  case In_Ethiopic_Supplement
  case In_Cherokee
  case In_Unified_Canadian_Aboriginal_Syllabics
  case In_Ogham
  case In_Runic
  case In_Tagalog
  case In_Hanunoo
  case In_Buhid
  case In_Tagbanwa
  case In_Khmer
  case In_Mongolian
  case In_Unified_Canadian_Aboriginal_Syllabics_Extended
  case In_Limbu
  case In_Tai_Le
  case In_New_Tai_Lue
  case In_Khmer_Symbols
  case In_Buginese
  case In_Tai_Tham
  case In_Combining_Diacritical_Marks_Extended
  case In_Balinese
  case In_Sundanese
  case In_Batak
  case In_Lepcha
  case In_Ol_Chiki
  case In_Cyrillic_Extended_C
  case In_Georgian_Extended
  case In_Sundanese_Supplement
  case In_Vedic_Extensions
  case In_Phonetic_Extensions
  case In_Phonetic_Extensions_Supplement
  case In_Combining_Diacritical_Marks_Supplement
  case In_Latin_Extended_Additional
  case In_Greek_Extended
  case In_General_Punctuation
  case In_Superscripts_and_Subscripts
  case In_Currency_Symbols
  case In_Combining_Diacritical_Marks_for_Symbols
  case In_Letterlike_Symbols
  case In_Number_Forms
  case In_Arrows
  case In_Mathematical_Operators
  case In_Miscellaneous_Technical
  case In_Control_Pictures
  case In_Optical_Character_Recognition
  case In_Enclosed_Alphanumerics
  case In_Box_Drawing
  case In_Block_Elements
  case In_Geometric_Shapes
  case In_Miscellaneous_Symbols
  case In_Dingbats
  case In_Miscellaneous_Mathematical_Symbols_A
  case In_Supplemental_Arrows_A
  case In_Braille_Patterns
  case In_Supplemental_Arrows_B
  case In_Miscellaneous_Mathematical_Symbols_B
  case In_Supplemental_Mathematical_Operators
  case In_Miscellaneous_Symbols_and_Arrows
  case In_Glagolitic
  case In_Latin_Extended_C
  case In_Coptic
  case In_Georgian_Supplement
  case In_Tifinagh
  case In_Ethiopic_Extended
  case In_Cyrillic_Extended_A
  case In_Supplemental_Punctuation
  case In_CJK_Radicals_Supplement
  case In_Kangxi_Radicals
  case In_Ideographic_Description_Characters
  case In_CJK_Symbols_and_Punctuation
  case In_Hiragana
  case In_Katakana
  case In_Bopomofo
  case In_Hangul_Compatibility_Jamo
  case In_Kanbun
  case In_Bopomofo_Extended
  case In_CJK_Strokes
  case In_Katakana_Phonetic_Extensions
  case In_Enclosed_CJK_Letters_and_Months
  case In_CJK_Compatibility
  case In_CJK_Unified_Ideographs_Extension_A
  case In_Yijing_Hexagram_Symbols
  case In_CJK_Unified_Ideographs
  case In_Yi_Syllables
  case In_Yi_Radicals
  case In_Lisu
  case In_Vai
  case In_Cyrillic_Extended_B
  case In_Bamum
  case In_Modifier_Tone_Letters
  case In_Latin_Extended_D
  case In_Syloti_Nagri
  case In_Common_Indic_Number_Forms
  case In_Phags_pa
  case In_Saurashtra
  case In_Devanagari_Extended
  case In_Kayah_Li
  case In_Rejang
  case In_Hangul_Jamo_Extended_A
  case In_Javanese
  case In_Myanmar_Extended_B
  case In_Cham
  case In_Myanmar_Extended_A
  case In_Tai_Viet
  case In_Meetei_Mayek_Extensions
  case In_Ethiopic_Extended_A
  case In_Latin_Extended_E
  case In_Cherokee_Supplement
  case In_Meetei_Mayek
  case In_Hangul_Syllables
  case In_Hangul_Jamo_Extended_B
  case In_High_Surrogates
  case In_High_Private_Use_Surrogates
  case In_Low_Surrogates
  case In_Private_Use_Area
  case In_CJK_Compatibility_Ideographs
  case In_Alphabetic_Presentation_Forms
  case In_Arabic_Presentation_Forms_A
  case In_Variation_Selectors
  case In_Vertical_Forms
  case In_Combining_Half_Marks
  case In_CJK_Compatibility_Forms
  case In_Small_Form_Variants
  case In_Arabic_Presentation_Forms_B
  case In_Halfwidth_and_Fullwidth_Forms
  case In_Specials
  case In_Linear_B_Syllabary
  case In_Linear_B_Ideograms
  case In_Aegean_Numbers
  case In_Ancient_Greek_Numbers
  case In_Ancient_Symbols
  case In_Phaistos_Disc
  case In_Lycian
  case In_Carian
  case In_Coptic_Epact_Numbers
  case In_Old_Italic
  case In_Gothic
  case In_Old_Permic
  case In_Ugaritic
  case In_Old_Persian
  case In_Deseret
  case In_Shavian
  case In_Osmanya
  case In_Osage
  case In_Elbasan
  case In_Caucasian_Albanian
  case In_Vithkuqi
  case In_Linear_A
  case In_Latin_Extended_F
  case In_Cypriot_Syllabary
  case In_Imperial_Aramaic
  case In_Palmyrene
  case In_Nabataean
  case In_Hatran
  case In_Phoenician
  case In_Lydian
  case In_Meroitic_Hieroglyphs
  case In_Meroitic_Cursive
  case In_Kharoshthi
  case In_Old_South_Arabian
  case In_Old_North_Arabian
  case In_Manichaean
  case In_Avestan
  case In_Inscriptional_Parthian
  case In_Inscriptional_Pahlavi
  case In_Psalter_Pahlavi
  case In_Old_Turkic
  case In_Old_Hungarian
  case In_Hanifi_Rohingya
  case In_Rumi_Numeral_Symbols
  case In_Yezidi
  case In_Old_Sogdian
  case In_Sogdian
  case In_Old_Uyghur
  case In_Chorasmian
  case In_Elymaic
  case In_Brahmi
  case In_Kaithi
  case In_Sora_Sompeng
  case In_Chakma
  case In_Mahajani
  case In_Sharada
  case In_Sinhala_Archaic_Numbers
  case In_Khojki
  case In_Multani
  case In_Khudawadi
  case In_Grantha
  case In_Newa
  case In_Tirhuta
  case In_Siddham
  case In_Modi
  case In_Mongolian_Supplement
  case In_Takri
  case In_Ahom
  case In_Dogra
  case In_Warang_Citi
  case In_Dives_Akuru
  case In_Nandinagari
  case In_Zanabazar_Square
  case In_Soyombo
  case In_Unified_Canadian_Aboriginal_Syllabics_Extended_A
  case In_Pau_Cin_Hau
  case In_Bhaiksuki
  case In_Marchen
  case In_Masaram_Gondi
  case In_Gunjala_Gondi
  case In_Makasar
  case In_Lisu_Supplement
  case In_Tamil_Supplement
  case In_Cuneiform
  case In_Cuneiform_Numbers_and_Punctuation
  case In_Early_Dynastic_Cuneiform
  case In_Cypro_Minoan
  case In_Egyptian_Hieroglyphs
  case In_Egyptian_Hieroglyph_Format_Controls
  case In_Anatolian_Hieroglyphs
  case In_Bamum_Supplement
  case In_Mro
  case In_Tangsa
  case In_Bassa_Vah
  case In_Pahawh_Hmong
  case In_Medefaidrin
  case In_Miao
  case In_Ideographic_Symbols_and_Punctuation
  case In_Tangut
  case In_Tangut_Components
  case In_Khitan_Small_Script
  case In_Tangut_Supplement
  case In_Kana_Extended_B
  case In_Kana_Supplement
  case In_Kana_Extended_A
  case In_Small_Kana_Extension
  case In_Nushu
  case In_Duployan
  case In_Shorthand_Format_Controls
  case In_Znamenny_Musical_Notation
  case In_Byzantine_Musical_Symbols
  case In_Musical_Symbols
  case In_Ancient_Greek_Musical_Notation
  case In_Mayan_Numerals
  case In_Tai_Xuan_Jing_Symbols
  case In_Counting_Rod_Numerals
  case In_Mathematical_Alphanumeric_Symbols
  case In_Sutton_SignWriting
  case In_Latin_Extended_G
  case In_Glagolitic_Supplement
  case In_Nyiakeng_Puachue_Hmong
  case In_Toto
  case In_Wancho
  case In_Ethiopic_Extended_B
  case In_Mende_Kikakui
  case In_Adlam
  case In_Indic_Siyaq_Numbers
  case In_Ottoman_Siyaq_Numbers
  case In_Arabic_Mathematical_Alphabetic_Symbols
  case In_Mahjong_Tiles
  case In_Domino_Tiles
  case In_Playing_Cards
  case In_Enclosed_Alphanumeric_Supplement
  case In_Enclosed_Ideographic_Supplement
  case In_Miscellaneous_Symbols_and_Pictographs
  case In_Emoticons
  case In_Ornamental_Dingbats
  case In_Transport_and_Map_Symbols
  case In_Alchemical_Symbols
  case In_Geometric_Shapes_Extended
  case In_Supplemental_Arrows_C
  case In_Supplemental_Symbols_and_Pictographs
  case In_Chess_Symbols
  case In_Symbols_and_Pictographs_Extended_A
  case In_Symbols_for_Legacy_Computing
  case In_CJK_Unified_Ideographs_Extension_B
  case In_CJK_Unified_Ideographs_Extension_C
  case In_CJK_Unified_Ideographs_Extension_D
  case In_CJK_Unified_Ideographs_Extension_E
  case In_CJK_Unified_Ideographs_Extension_F
  case In_CJK_Compatibility_Ideographs_Supplement
  case In_CJK_Unified_Ideographs_Extension_G
  case In_Tags
  case In_Variation_Selectors_Supplement
  case In_Supplementary_Private_Use_Area_A
  case In_Supplementary_Private_Use_Area_B
  case In_No_Block
}
