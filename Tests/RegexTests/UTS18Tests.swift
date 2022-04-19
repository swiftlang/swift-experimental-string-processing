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

import XCTest
@testable // for internal `matches(of:)`
import _StringProcessing

class UTS18Tests: XCTestCase {
  var input: String {
    "ABCdefghîøü\u{FFF0} -–—[]123"
  // 012345678901       234567890
  // 0         10               20
  }
}

fileprivate extension String {
  subscript<R: RangeExpression>(pos bounds: R) -> Substring
    where R.Bound == Int
  {
    let bounds = bounds.relative(to: 0..<count)
    return dropFirst(bounds.lowerBound).prefix(bounds.count)
  }
}

fileprivate func expectFirstMatch<Output: Equatable>(
  _ input: String,
  _ r: Regex<Output>,
  _ output: Output,
  file: StaticString = #file,
  line: UInt = #line)
{
  XCTAssertEqual(input.firstMatch(of: r)?.output, output, file: file, line: line)
}

#if os(Linux)
func XCTExpectFailure(_ message: String? = nil, body: () -> Void) {}
#endif

// MARK: - Basic Unicode Support: Level 1

// C1. An implementation claiming conformance to Level 1 of this specification
// shall meet the requirements described in the following sections:
extension UTS18Tests {
  // RL1.1 Hex Notation
  //
  // To meet this requirement, an implementation shall supply a mechanism for
  // specifying any Unicode code point (from U+0000 to U+10FFFF), using the
  // hexadecimal code point representation.
  func testHexNotation() throws {
    expectFirstMatch("ab", #/\u{61}\u{62}/#, "ab")
    expectFirstMatch("𝄞", #/\u{1D11E}/#, "𝄞")
  }
  
  // 1.1.1 Hex Notation and Normalization
  //
  // TODO: Does this section make a recommendation?
  
  // RL1.2	Properties
  // To meet this requirement, an implementation shall provide at least a
  // minimal list of properties, consisting of the following:
  // - General_Category
  // - Script and Script_Extensions
  // - Alphabetic
  // - Uppercase
  // - Lowercase
  // - White_Space
  // - Noncharacter_Code_Point
  // - Default_Ignorable_Code_Point
  // - ANY, ASCII, ASSIGNED
  // The values for these properties must follow the Unicode definitions, and
  // include the property and property value aliases from the UCD. Matching of
  // Binary, Enumerated, Catalog, and Name values must follow the Matching
  // Rules from [UAX44] with one exception: implementations are not required
  // to ignore an initial prefix string of "is" in property values.
  func testProperties() throws {
    // General_Category
    expectFirstMatch(input, #/\p{Lu}+/#, input[pos: ..<3])
    expectFirstMatch(input, #/\p{lu}+/#, input[pos: ..<3])
    expectFirstMatch(input, #/\p{uppercase letter}+/#, input[pos: ..<3])
    expectFirstMatch(input, #/\p{Uppercase Letter}+/#, input[pos: ..<3])
    expectFirstMatch(input, #/\p{Uppercase_Letter}+/#, input[pos: ..<3])
    expectFirstMatch(input, #/\p{uppercaseletter}+/#, input[pos: ..<3])
    
    expectFirstMatch(input, #/\p{P}+/#, "-–—[]")
    expectFirstMatch(input, #/\p{Pd}+/#, "-–—")
    
    expectFirstMatch(input, #/\p{Any}+/#, input[...])
    expectFirstMatch(input, #/\p{Assigned}+/#, input[pos: ..<11])
    expectFirstMatch(input, #/\p{ASCII}+/#, input[pos: ..<8])
    
    // Script and Script_Extensions
    //    U+3042  あ  HIRAGANA LETTER A  Hira  {Hira}
    XCTAssertTrue("\u{3042}".contains(#/\p{Hira}/#))
    XCTAssertTrue("\u{3042}".contains(#/\p{sc=Hira}/#))
    XCTAssertTrue("\u{3042}".contains(#/\p{scx=Hira}/#))
    //    U+30FC  ー  KATAKANA-HIRAGANA PROLONGED SOUND MARK  Zyyy = Common  {Hira, Kana}
    XCTAssertTrue("\u{30FC}".contains(#/\p{Hira}/#))      // Implicit = Script_Extensions
    XCTAssertTrue("\u{30FC}".contains(#/\p{Kana}/#))
    XCTAssertTrue("\u{30FC}".contains(#/\p{sc=Zyyy}/#))   // Explicit = Script
    XCTAssertTrue("\u{30FC}".contains(#/\p{scx=Hira}/#))
    XCTAssertTrue("\u{30FC}".contains(#/\p{scx=Kana}/#))
    XCTAssertFalse("\u{30FC}".contains(#/\p{sc=Hira}/#))
    XCTAssertFalse("\u{30FC}".contains(#/\p{sc=Kana}/#))
    
    // Uppercase, etc
    expectFirstMatch(input, #/\p{Uppercase}+/#, input[pos: ..<3])
    expectFirstMatch(input, #/\p{isUppercase}+/#, input[pos: ..<3])
    expectFirstMatch(input, #/\p{Uppercase=true}+/#, input[pos: ..<3])
    expectFirstMatch(input, #/\p{is Uppercase}+/#, input[pos: ..<3])
    expectFirstMatch(input, #/\p{is uppercase = true}+/#, input[pos: ..<3])
    expectFirstMatch(input, #/\p{lowercase}+/#, input[pos: 3..<11])
    expectFirstMatch(input, #/\p{whitespace}+/#, input[pos: 12..<13])

    // Block vs Writing System
    let greekScalar = "Θ" // U+0398
    let greekExtendedScalar = "ἀ" // U+1F00
    XCTAssertTrue(greekScalar.contains(#/\p{Greek}/#))
    XCTAssertTrue(greekExtendedScalar.contains(#/\p{Greek}/#))
  }
  
  func testProperties_XFail() {
    XCTExpectFailure("Need to support 'age' and 'block' properties") {
      // XCTAssertFalse("z".contains(#/\p{age=3.1}/#))
      XCTFail(#"\(#/\p{age=3.1}/#)"#)
      // XCTAssertTrue("\u{1F00}".contains(#/\p{Block=Greek}/#))
      XCTFail(#"\(#/\p{Block=Greek}/#)"#)
    }
  }
  
  // RL1.2a	Compatibility Properties
  // To meet this requirement, an implementation shall provide the properties
  // listed in Annex C: Compatibility Properties, with the property values as
  // listed there. Such an implementation shall document whether it is using
  // the Standard Recommendation or POSIX-compatible properties.
  func testCompatibilityProperties() throws {
    // FIXME: These tests seem insufficient
    expectFirstMatch(input, #/[[:alpha:]]+/#, input[pos: ..<11])
    expectFirstMatch(input, #/[[:upper:]]+/#, input[pos: ..<3])
    expectFirstMatch(input, #/[[:lower:]]+/#, input[pos: 3..<11])
    expectFirstMatch(input, #/[[:punct:]]+/#, input[pos: 13..<18])
    expectFirstMatch(input, #/[[:digit:]]+/#, input[pos: 18..<21])
    expectFirstMatch(input, #/[[:xdigit:]]+/#, input[pos: ..<6])
    expectFirstMatch(input, #/[[:alnum:]]+/#, input[pos: ..<11])
    expectFirstMatch(input, #/[[:space:]]+/#, input[pos: 12..<13])
    // TODO: blank
    // TODO: cntrl
    expectFirstMatch(input, #/[[:graph:]]+/#, input[pos: ..<11])
    expectFirstMatch(input, #/[[:print:]]+/#, input[...])
    expectFirstMatch(input, #/[[:word:]]+/#, input[pos: ..<11])
  }
  
  //RL1.3 Subtraction and Intersection
  //
  // To meet this requirement, an implementation shall supply mechanisms for
  // union, intersection and set-difference of sets of characters within
  // regular expression character class expressions.
  func testSubtractionAndIntersection() {
    // Non-ASCII letters
    expectFirstMatch(input, #/[\p{Letter}--\p{ASCII}]+/#, input[pos: 8..<11])
    // Digits that aren't 1 or 2
    expectFirstMatch(input, #/[\p{digit}--[12]]+/#, input[pos: 20..<21])
    
    // ASCII-only letters
    expectFirstMatch(input, #/[\p{Letter}&&\p{ASCII}]+/#, input[pos: ..<8])
    // Digits that are 2 or 3
    expectFirstMatch(input, #/[\p{digit}&&[23]]+/#, input[pos: 19..<21])
    
    // Non-ASCII lowercase + non-lowercase ASCII
    expectFirstMatch(input, #/[\p{lowercase}~~\p{ascii}]+/#, input[pos: ..<3])
    XCTAssertTrue("123%&^ABC".contains(#/^[\p{lowercase}~~\p{ascii}]+$/#))
  }
  
  func testSubtractionAndIntersectionPrecedence() {
    expectFirstMatch("ABC123-", #/[[:alnum:]]*-/#, "ABC123-")
    expectFirstMatch("ABC123-", #/[[:alnum:]--\p{Uppercase}]*-/#, "123-")
    // Union binds more closely than difference
    expectFirstMatch("ABC123-", #/[[:alnum:]--\p{Uppercase}[:digit:]]*-/#, "-")
    // TODO: Test for intersection precedence
  }
  
  // RL1.4 Simple Word Boundaries
  // To meet this requirement, an implementation shall extend the word boundary
  // mechanism so that:
  // - The class of <word_character> includes all the Alphabetic values from the
  //   Unicode character database, from UnicodeData.txt, plus the decimals
  //   (General_Category=Decimal_Number, or equivalently Numeric_Type=Decimal),
  //   and the U+200C ZERO WIDTH NON-JOINER and U+200D ZERO WIDTH JOINER
  //   (Join_Control=True). See also Annex C: Compatibility Properties.
  // - Nonspacing marks are never divided from their base characters, and
  //   otherwise ignored in locating boundaries.
  func testSimpleWordBoundaries() {
    let simpleWordRegex = #/.+?\b/#.wordBoundaryKind(.unicodeLevel1)
    expectFirstMatch(input, simpleWordRegex, input[pos: ..<11])
    expectFirstMatch("don't", simpleWordRegex, "don")
    expectFirstMatch("Cafe\u{301}", simpleWordRegex, "Café")
  }
  
  // RL1.5 Simple Loose Matches
  //
  // To meet this requirement, if an implementation provides for case-
  // insensitive matching, then it shall provide at least the simple, default
  // Unicode case-insensitive matching, and specify which properties are closed
  // and which are not.
  //
  // To meet this requirement, if an implementation provides for case
  // conversions, then it shall provide at least the simple, default Unicode
  // case folding.
  func testSimpleLooseMatches() {
    expectFirstMatch("Dåb", #/Dåb/#.ignoresCase(), "Dåb")
    expectFirstMatch("dÅB", #/Dåb/#.ignoresCase(), "dÅB")
    expectFirstMatch("D\u{212B}B", #/Dåb/#.ignoresCase(), "D\u{212B}B")
  }

  func testSimpleLooseMatches_XFail() {
    XCTExpectFailure("Need case folding support") {
      let sigmas = "σΣς"
      expectFirstMatch(sigmas, #/σ+/#.ignoresCase(), sigmas[...])
      expectFirstMatch(sigmas, #/Σ+/#.ignoresCase(), sigmas[...])
      expectFirstMatch(sigmas, #/ς+/#.ignoresCase(), sigmas[...])
      
      // TODO: Test German sharp S
      // TODO: Test char classes, e.g. [\p{Block=Phonetic_Extensions} [A-E]]
    }
  }
  
  // RL1.6 Line Boundaries
  //
  // To meet this requirement, if an implementation provides for line-boundary
  // testing, it shall recognize not only CRLF, LF, CR, but also NEL (U+0085),
  // PARAGRAPH SEPARATOR (U+2029) and LINE SEPARATOR (U+2028).
  func testLineBoundaries() {
    let lineInput = """
      01
      02\r\
      03\n\
      04\u{a}\
      05\u{b}\
      06\u{c}\
      07\u{d}\
      08\u{d}\u{a}\
      09\u{85}\
      10\u{2028}\
      11\u{2029}\
      
      """
    // Check the input counts
    var lines = lineInput.matches(of: #/\d{2}/#)
    XCTAssertEqual(lines.count, 11)
    // Test \R - newline sequence
    lines = lineInput.matches(of: #/\d{2}\R/#)
    XCTAssertEqual(lines.count, 11)
    // Test anchors as line boundaries
    lines = lineInput.matches(of: #/^\d{2}$/#.anchorsMatchLineEndings())
    XCTAssertEqual(lines.count, 11)
    // Test that dot does not match line endings
    lines = lineInput.matches(of: #/.+/#)
    XCTAssertEqual(lines.count, 11)
    
    // Does not contain an empty line
    XCTAssertFalse(lineInput.contains(#/^$/#))
    // Does contain an empty line (between \n and \r, which are reversed here)
    let empty = "\n\r"
    XCTAssertTrue(empty.contains(#/^$/#.anchorsMatchLineEndings()))
  }
  
  // RL1.7 Supplementary Code Points
  //
  // To meet this requirement, an implementation shall handle the full range of
  // Unicode code points, including values from U+FFFF to U+10FFFF. In
  // particular, where UTF-16 is used, a sequence consisting of a leading
  // surrogate followed by a trailing surrogate shall be handled as a single
  // code point in matching.
  func testSupplementaryCodePoints() {
    XCTAssertTrue("👍".contains(#/\u{1F44D}/#))
    XCTAssertTrue("👍".contains(#/[\u{1F440}-\u{1F44F}]/#))
    XCTAssertTrue("👍👎".contains(#/^[\u{1F440}-\u{1F44F}]+$/#))
  }
}

// MARK: - Extended Unicode Support: Level 2

// C2.  An implementation claiming conformance to Level 2 of this specification
// shall satisfy C1, and meet the requirements described in the following
// sections:
extension UTS18Tests {
  // RL2.1 Canonical Equivalents
  //
  // Specific recommendation?
  func testCanonicalEquivalents() {
    let equivalents = [
      "\u{006f}\u{031b}\u{0323}",     // o + horn + dot_below
      "\u{006f}\u{0323}\u{031b}",     // o + dot_below + horn
      "\u{01a1}\u{0323}",             // o-horn + dot_below
      "\u{1ecd}\u{031b}",             // o-dot_below + horn
      "\u{1ee3}",                     // o-horn-dot_below
    ]
    
    let regexes = [
      #/\u{006f}\u{031b}\u{0323}/#,   // o + horn + dot_below
      #/\u{006f}\u{0323}\u{031b}/#,   // o + dot_below + horn
      #/\u{01a1}\u{0323}/#,           // o-horn + dot_below
      #/\u{1ecd}\u{031b}/#,           // o-dot_below + horn
      #/\u{1ee3}/#,                   // o-horn-dot_below
    ]

    // Default: Grapheme cluster semantics
    for (regexNum, regex) in regexes.enumerated() {
      for (equivNum, equiv) in equivalents.enumerated() {
        XCTAssertTrue(
          equiv.contains(regex),
          "Grapheme cluster semantics: Regex \(regexNum) didn't match with string \(equivNum)")
      }
    }
    
    // Unicode scalar semantics
    for (regexNum, regex) in regexes.enumerated() {
      for (equivNum, equiv) in equivalents.enumerated() {
        let regex = regex.matchingSemantics(.unicodeScalar)
        if regexNum == equivNum {
          XCTAssertTrue(
            equiv.contains(regex),
            "Unicode scalar semantics: Regex \(regexNum) didn't match with string \(equivNum)")
        } else {
          XCTAssertFalse(
            equiv.contains(regex),
            "Unicode scalar semantics: Regex \(regexNum) incorrectly matched with string \(equivNum)")
        }
      }
    }
  }
  
  // RL2.2 Extended Grapheme Clusters and Character Classes with Strings
  //
  // To meet this requirement, an implementation shall provide a mechanism for
  // matching against an arbitrary extended grapheme cluster, Character Classes
  // with Strings, and extended grapheme cluster boundaries.
  func testExtendedGraphemeClusters() {
    XCTExpectFailure { XCTFail("Implement tests") }
  }
  
  func testCharacterClassesWithStrings() {
    XCTExpectFailure { XCTFail("Implement tests") }
  }
  
  // RL2.3 Default Word Boundaries
  //
  // To meet this requirement, an implementation shall provide a mechanism for
  // matching Unicode default word boundaries.
  func testDefaultWordBoundaries() {
    XCTExpectFailure { XCTFail("Implement tests") }
  }

  // RL2.4 Default Case Conversion
  //
  // To meet this requirement, if an implementation provides for case
  // conversions, then it shall provide at least the full, default Unicode case
  // folding.
  func testDefaultCaseConversion() {
    XCTExpectFailure { XCTFail("Implement tests") }
  }
  
  // RL2.5 Name Properties
  //
  // To meet this requirement, an implementation shall support individually
  // named characters.
  func testNameProperty_XFail() {
    XCTExpectFailure("Need \\p{name=...} support") {
      XCTFail(#"\(#/\p{name=BOM}/#)"#)
      // Name property
      // XCTAssertTrue("\u{FEFF}".contains(#/\p{name=ZERO WIDTH NO-BREAK SPACE}/#))
      // Name property and Matching Rules
      // XCTAssertTrue("\u{FEFF}".contains(#/\p{name=zerowidthno breakspace}/#))
      // Name_Alias property
      // XCTAssertTrue("\u{FEFF}".contains(#/\p{name=BYTE ORDER MARK}/#))
      // Name_Alias property (again)
      // XCTAssertTrue("\u{FEFF}".contains(#/\p{name=BOM}/#))

      // Computed name
      // XCTAssertTrue("강".contains(#/\p{name=HANGUL SYLLABLE GANG}/#))

      // Control character
      // XCTAssertTrue("\u{7}".contains(#/\p{name=BEL}/#))
      // Graphic symbol
      // XCTAssertTrue("\u{1F514}".contains(#/\p{name=BELL}/#))
    }
  }
  
  func testIndividuallyNamedCharacters() {
    XCTAssertTrue("\u{263A}".contains(#/\N{WHITE SMILING FACE}/#))
    XCTAssertTrue("\u{3B1}".contains(#/\N{GREEK SMALL LETTER ALPHA}/#))
    XCTAssertTrue("\u{10450}".contains(#/\N{SHAVIAN LETTER PEEP}/#))
    
    XCTAssertTrue("\u{FEFF}".contains(#/\N{ZERO WIDTH NO-BREAK SPACE}/#))
    XCTAssertTrue("강".contains(#/\N{HANGUL SYLLABLE GANG}/#))
    XCTAssertTrue("\u{1F514}".contains(#/\N{BELL}/#))
    XCTAssertTrue("🐯".contains(#/\N{TIGER FACE}/#))
    XCTAssertFalse("🐯".contains(#/\N{TIEGR FACE}/#))
  }

  func testIndividuallyNamedCharacters_XFail() {
    XCTExpectFailure("Need to support named chars in custom character classes") {
      XCTFail("\(#/[\N{GREEK SMALL LETTER ALPHA}-\N{GREEK SMALL LETTER BETA}]+/#)")
      // XCTAssertTrue("^\u{3B1}\u{3B2}$".contains(#/[\N{GREEK SMALL LETTER ALPHA}-\N{GREEK SMALL LETTER BETA}]+/#))
    }
    
    XCTExpectFailure("Other named char failures -- investigate") {
      XCTAssertTrue("\u{263A}".contains(#/\N{whitesmilingface}/#))
      XCTAssertTrue("\u{C}".contains(#/\N{FORM FEED}/#))
      XCTAssertTrue("\u{FEFF}".contains(#/\N{zerowidthno breakspace}/#))
      XCTAssertTrue("\u{FEFF}".contains(#/\N{BYTE ORDER MARK}/#))
      XCTAssertTrue("\u{FEFF}".contains(#/\N{BOM}/#))
      XCTAssertTrue("\u{7}".contains(#/\N{BEL}/#))
    }
    
    XCTExpectFailure("Need to recognize invalid names at compile time") {
      XCTFail("This should be a compilation error, not a match failure:")
      XCTAssertFalse("abc".contains(#/\N{NOT AN ACTUAL CHARACTER NAME}/#))
    }
  }

  // RL2.6 Wildcards in Property Values
  //
  // To meet this requirement, an implementation shall support wildcards in
  // Unicode property values.
  func testWildcardsInPropertyValues() {
    XCTExpectFailure { XCTFail("Implement tests") }
  }
  
  // RL2.7 Full Properties
  //
  // To meet this requirement, an implementation shall support all of the
  // properties listed below that are in the supported version of the Unicode
  // Standard (or Unicode Technical Standard, respectively), with values that
  // match the Unicode definitions for that version.
  func testFullProperties() {
    // MARK: General
    // Name (Name_Alias)
    // Block
    // Age
    // General_Category
    // Script (Script_Extensions)
    // White_Space
    // Alphabetic
    // Hangul_Syllable_Type
    // Noncharacter_Code_Point
    // Default_Ignorable_Code_Point
    // Deprecated
    // Logical_Order_Exception
    // Variation_Selector

    // MARK: Numeric
    // Numeric_Value
    // Numeric_Type
    // Hex_Digit
    // ASCII_Hex_Digit

    // MARK: Identifiers
    // ID_Continue
    // ID_Start
    // XID_Continue
    // XID_Start
    // Pattern_Syntax
    // Pattern_White_Space
    // Identifier_Status
    // Identifier_Type

    // MARK: CJK
    // Ideographic
    // Unified_Ideograph
    // Radical
    // IDS_Binary_Operator
    // IDS_Trinary_Operator
    // Equivalent_Unified_Ideograph
    XCTExpectFailure()
    XCTFail(#"Unsupported: \(#/^\p{Equivalent_Unified_Ideograph=⼚}+$/#)"#)
    // XCTAssertTrue("⼚⺁厂".contains(#/^\p{Equivalent_Unified_Ideograph=⼚}+$/#))

    // MARK: Case
    // Uppercase
    // Lowercase
    // Simple_Lowercase_Mapping
    // Simple_Titlecase_Mapping
    // Simple_Uppercase_Mapping
    // Simple_Case_Folding
    // Soft_Dotted
    // Cased
    // Case_Ignorable
    // Changes_When_Lowercased
    // Changes_When_Uppercased
    XCTAssertTrue("a".contains(#/\p{Changes_When_Uppercased}/#))
    XCTAssertTrue("a".contains(#/\p{Changes_When_Uppercased=true}/#))
    XCTAssertFalse("A".contains(#/\p{Changes_When_Uppercased}/#))
    // Changes_When_Titlecased
    // Changes_When_Casefolded
    // Changes_When_Casemapped

    // MARK: Normalization
    // Canonical_Combining_Class
    // Decomposition_Type
    // NFC_Quick_Check
    // NFKC_Quick_Check
    // NFD_Quick_Check
    // NFKD_Quick_Check
    // NFKC_Casefold
    // Changes_When_NFKC_Casefolded

    // MARK: Emoji
    // Emoji
    // Emoji_Presentation
    // Emoji_Modifier
    // Emoji_Modifier_Base
    // Emoji_Component
    // Extended_Pictographic
    // Basic_Emoji*
    // Emoji_Keycap_Sequence*
    // RGI_Emoji_Modifier_Sequence*
    // RGI_Emoji_Flag_Sequence*
    // RGI_Emoji_Tag_Sequence*
    // RGI_Emoji_ZWJ_Sequence*
    // RGI_Emoji*

    // MARK: Shaping and Rendering
    // Join_Control
    // Joining_Group
    // Joining_Type
    // Vertical_Orientation
    // Line_Break
    // Grapheme_Cluster_Break
    // Sentence_Break
    // Word_Break
    // East_Asian_Width
    // Prepended_Concatenation_Mark

    // MARK: Bidirectional
    // Bidi_Class
    // Bidi_Control
    // Bidi_Mirrored
    // Bidi_Mirroring_Glyph
    // Bidi_Paired_Bracket
    // Bidi_Paired_Bracket_Type

    // MARK: Miscellaneous
    // Math
    // Quotation_Mark
    // Dash
    // Sentence_Terminal
    // Terminal_Punctuation
    // Diacritic
    // Extender
    // Grapheme_Base
    // Grapheme_Extend
    // Regional_Indicator
  }
}
