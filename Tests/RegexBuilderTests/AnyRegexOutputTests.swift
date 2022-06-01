
import XCTest
import _StringProcessing
import RegexBuilder

private let enablePrinting = false

func addNote(
  _ in: (Substring, Substring, Substring, Substring, Substring)
) -> (Substring, Substring, note: Substring, Substring, Substring) {
  return `in`
}
func removeName(
  _ in: (Substring, Substring, Substring, Substring, Substring)
) -> (Substring, Substring, Substring, Substring, Substring) {
  return `in`
}

extension RegexDSLTests {

  func testContrivedAROExample() {
    // Find and extract potential IDs. IDs are 8 bytes encoded as
    // 16 hexadecimal numbers, with an optional `-` between every
    // double-byte (i.e. 4 hex digits).
    //
    // AAAA-BBBB-CCCC-DDDD
    // AAAABBBBCCCCDDDD
    // AAAABBBBCCCC-DDDD
    //
    // IDs are converted to uppercase and hyphen separated
    //
    // The regex can have special capture names which affect replacement 
    // behavior
    //   - "salient": presented uppercase in square brackets after
    //   - "note": presented lowercase in parens
    //   - none: nothing
    //   - no captures: "<error>"
    //
    let input = """
      Machine 1234-5678-90ab-CDEF connected
      Session FEDCAB0987654321 ended
      Artiface 0011deff-2231-abcd contrived
      """
    let noCapOutput = """
      Machine <error> connected
      Session <error> ended
      Artiface <error> contrived
      """
    let unnamedOutput = """
      Machine 1234-5678-90AB-CDEF connected
      Session FEDC-AB09-8765-4321 ended
      Artiface 0011-DEFF-2231-ABCD contrived
      """
    let salientOutput = """
      Machine 1234-5678-90AB-CDEF [5678] connected
      Session FEDC-AB09-8765-4321 [AB09] ended
      Artiface 0011-DEFF-2231-ABCD [DEFF] contrived
      """
    let noteOutput = """
      Machine 1234-5678-90AB-CDEF (5678) connected
      Session FEDC-AB09-8765-4321 (ab09) ended
      Artiface 0011-DEFF-2231-ABCD (deff) contrived
      """

    enum Kind {
      case none
      case unnamed
      case salient
      case note

      func contains(captureNamed s: String) -> Bool {
        switch self {
          case .none:    return false
          case .unnamed: return false
          case .salient: return s == "salient"
          case .note:    return s == "note"
        }
      }

      var expected: String {
        switch self {
        case .none: return """
          Machine <error> connected
          Session <error> ended
          Artiface <error> contrived
          """
        case .unnamed: return """
          Machine 1234-5678-90AB-CDEF connected
          Session FEDC-AB09-8765-4321 ended
          Artiface 0011-DEFF-2231-ABCD contrived
          """
        case .salient: return """
          Machine 1234-5678-90AB-CDEF [5678] connected
          Session FEDC-AB09-8765-4321 [AB09] ended
          Artiface 0011-DEFF-2231-ABCD [DEFF] contrived
          """
        case .note: return """
          Machine 1234-5678-90AB-CDEF (5678) connected
          Session FEDC-AB09-8765-4321 (ab09) ended
          Artiface 0011-DEFF-2231-ABCD (deff) contrived
          """  
        }        
      }
    }

    func checkContains<Output>(
      _ re: Regex<Output>, _ kind: Kind
    ) {
      for name in ["", "salient", "note", "other"] {
        XCTAssertEqual(
          kind.contains(captureNamed: name), re.contains(captureNamed: name))
      }
    }
    func checkAROReplacing<Output>(
      _ re: Regex<Output>, _ kind: Kind
    ) {
      let aro = Regex<AnyRegexOutput>(re)
      let output = input.replacing(aro) {
        (match: Regex<AnyRegexOutput>.Match) -> String in

        if match.count < 5 { return "<error>" }

        let suffix: String
        if re.contains(captureNamed: "salient") {
          let body = match["salient"]!.substring?.uppercased() ?? "<no capture>"
          suffix = " [\(body)]"
        } else if re.contains(captureNamed: "note") {
          let body = match["note"]!.substring?.lowercased() ?? "<no capture>"
          suffix = " (\(body))"
        } else {
          suffix = ""
        }

        return match.output.dropFirst().lazy.map {
          $0.substring!.uppercased()
        }.joined(separator: "-") + suffix
      }

      XCTAssertEqual(output, kind.expected)

      if enablePrinting {
        print("---")
        print(output)
        print(kind)
      }
    }
    func check<Output>(
      _ re: Regex<Output>, _ kind: Kind, _ expected: String
    ) {
      let aro = Regex<AnyRegexOutput>(re)

      // FIXME: The below fatal errors
      let casted = try! XCTUnwrap(Regex(aro, as: Output.self))

      // contains(captureNamed:)
      checkContains(re, kind)
      checkContains(aro, kind)
      checkContains(casted, kind)

      // replacing
      checkAROReplacing(re, kind)
      checkAROReplacing(aro, kind)
      checkAROReplacing(casted, kind)
    }

    // Literals (mocked up via explicit `as` types)
    let noCapBody = #"""
      (?x)
      \p{hexdigit}{4} -? \p{hexdigit}{4} -?
      \p{hexdigit}{4} -? \p{hexdigit}{4}
      """#
    let noCapType = Substring.self

    let unnamedBody = #"""
      (?x)
      (\p{hexdigit}{4}) -? (\p{hexdigit}{4}) -?
      (\p{hexdigit}{4}) -? (\p{hexdigit}{4})
      """#
    let unnamedType = (Substring, Substring, Substring, Substring, Substring).self

    let salientBody = #"""
      (?x)
      (\p{hexdigit}{4}) -? (?<salient>\p{hexdigit}{4}) -?
      (\p{hexdigit}{4}) -? (\p{hexdigit}{4})
      """#
    let salientType = (Substring, Substring, salient: Substring, Substring, Substring).self

    let noteBody = #"""
      (?x)
      (\p{hexdigit}{4}) -? (?<note>\p{hexdigit}{4}) -?
      (\p{hexdigit}{4}) -? (\p{hexdigit}{4})
      """#
    let noteType = (Substring, Substring, note: Substring, Substring, Substring).self

    let unknownBody = #"""
      (?x)
      (\p{hexdigit}{4}) -? (?<unknown>\p{hexdigit}{4}) -?
      (\p{hexdigit}{4}) -? (\p{hexdigit}{4})
      """#
    let unknownType = (Substring, Substring, unknown: Substring, Substring, Substring).self

    // TODO: unknown body tests?


    // Literals (mocked via exactly matching explicit types)
    check(
      try! Regex(noCapBody, as: noCapType),
      .none,
      noCapOutput
    )
    check(
      try! Regex(unnamedBody, as: unnamedType),
      .unnamed,
      unnamedOutput    
    )
    check(
      try! Regex(salientBody, as: salientType),
      .salient,
      salientOutput
    )
    check(
      try! Regex(noteBody, as: noteType),
      .note,
      noteOutput
    )
    // Unknown behaves same as unnamed
    check(
      try! Regex(unknownBody, as: unknownType),
      .unnamed,
      unnamedOutput
    )

    // TODO: Try regexes `as` different types to pick up different behavior

    // TODO: A `mapOutput` variant that takes no-cap and produces captures
    // by matching the other regexes inside the mapping

    // Run-time strings (ARO)
    check(
      try! Regex(noCapBody),
      .none,
      noCapOutput)
    check(
      try! Regex(unnamedBody),
      .unnamed,
      unnamedOutput
    )
    check(
      try! Regex(salientBody),
      .salient,
      salientOutput
    )
    check(
      try! Regex(noteBody),
      .note,
      noteOutput
    )
    // Unknown behaves same as no names
    check(
      try! Regex(unknownBody),
      .unnamed,
      unnamedOutput
    )

//    // Use `mapOutput` to add or remove capture names
//    check(
//      try! Regex(unnamedBody).mapOutput(addNote),
//      .note,
//      noteOutput
//    )
//    check(
//      try! Regex(salientBody).mapOutput(addNote),
//      .note,
//      noteOutput
//    )
//    check(try! Regex(#"""
//      (?x)
//      (\p{hexdigit}{4}) -? (?<salient>\p{hexdigit}{4}) -?
//      (\p{hexdigit}{4}) -? (\p{hexdigit}{4})
//      """#).mapOutput(removeName),
//      .unnamed,
//      unnamedOutput
//    )

    // Builders
    check(
      Regex {
        let doublet = Repeat(.hexDigit, count: 4)
        doublet
        Optionally { "-" }
        doublet
        Optionally { "-" }
        doublet
        Optionally { "-" }
        doublet
      },
      .none,
      noCapOutput
    )
    let capDSL = Regex {
      let doublet = Repeat(.hexDigit, count: 4)
      Capture { doublet }
      Optionally { "-" }
      Capture { doublet }
      Optionally { "-" }
      Capture { doublet }
      Optionally { "-" }
      Capture { doublet }
    }
    check(
      capDSL,
      .unnamed,
      unnamedOutput
    )

    // TODO: add first-class capture names via `mapOutput` to DSL test

  }
}
