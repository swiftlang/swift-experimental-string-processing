
import XCTest
import _StringProcessing
import RegexBuilder

private let enablePrinting = false

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
    check(try! Regex(#"""
      (?x)
      \p{hexdigit}{4} -? \p{hexdigit}{4} -?
      \p{hexdigit}{4} -? \p{hexdigit}{4}
      """#, as: Substring.self),
      .none,
      noCapOutput
    )
    check(try! Regex(#"""
      (?x)
      (\p{hexdigit}{4}) -? (\p{hexdigit}{4}) -?
      (\p{hexdigit}{4}) -? (\p{hexdigit}{4})
      """#, as: (Substring, Substring, Substring, Substring, Substring).self),
      .unnamed,
      unnamedOutput    
    )
    check(try! Regex(#"""
      (?x)
      (\p{hexdigit}{4}) -? (?<salient>\p{hexdigit}{4}) -?
      (\p{hexdigit}{4}) -? (\p{hexdigit}{4})
      """#, as: (Substring, Substring, salient: Substring, Substring, Substring).self),
      .salient,
      salientOutput
    )
    check(try! Regex(#"""
      (?x)
      (\p{hexdigit}{4}) -? (?<note>\p{hexdigit}{4}) -?
      (\p{hexdigit}{4}) -? (\p{hexdigit}{4})
      """#, as: (Substring, Substring, note: Substring, Substring, Substring).self),
      .note,
      noteOutput
    )

    // Run-time strings (ARO)
    check(try! Regex(#"""
      (?x)
      \p{hexdigit}{4} -? \p{hexdigit}{4} -?
      \p{hexdigit}{4} -? \p{hexdigit}{4}
      """#),
      .none,
      noCapOutput)
    check(try! Regex(#"""
      (?x)
      (\p{hexdigit}{4}) -? (\p{hexdigit}{4}) -?
      (\p{hexdigit}{4}) -? (\p{hexdigit}{4})
      """#),
      .unnamed,
      unnamedOutput
    )
    check(try! Regex(#"""
      (?x)
      (\p{hexdigit}{4}) -? (?<salient>\p{hexdigit}{4}) -?
      (\p{hexdigit}{4}) -? (\p{hexdigit}{4})
      """#),
      .salient,
      salientOutput
    )
    check(try! Regex(#"""
      (?x)
      (\p{hexdigit}{4}) -? (?<note>\p{hexdigit}{4}) -?
      (\p{hexdigit}{4}) -? (\p{hexdigit}{4})
      """#),
      .note,
      noteOutput
    )

    // Run-time strings (errors)
    XCTAssertThrowsError(try Regex("abc", as: (Substring, Substring).self))
    XCTAssertThrowsError(try Regex("(abc)", as: Substring.self))
    XCTAssertThrowsError(try Regex("(?<test>abc)", as: (Substring, Substring).self))
    XCTAssertThrowsError(try Regex("(?<test>abc)?", as: (Substring, test: Substring).self))
    
    XCTAssertNoThrow(try Regex("abc", as: Substring.self))
    XCTAssertNoThrow(try Regex("(abc)", as: (Substring, Substring).self))
    XCTAssertNoThrow(try Regex("(?<test>abc)", as: (Substring, test: Substring).self))
    XCTAssertNoThrow(try Regex("(?<test>abc)?", as: (Substring, test: Substring?).self))
    
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
    check(
      Regex {
        let doublet = Repeat(.hexDigit, count: 4)
        Capture { doublet }
        Optionally { "-" }
        Capture { doublet }
        Optionally { "-" }
        Capture { doublet }
        Optionally { "-" }
        Capture { doublet }
      },
      .unnamed,
      unnamedOutput
    )

    // FIXME: `salient` and `note` builders using a semantically rich
    // `mapOutput`

  }
}
