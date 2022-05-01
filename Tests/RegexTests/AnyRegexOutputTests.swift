
import _StringProcessing
import XCTest

extension RegexTests {
  func testFoo1() {

    let regex = try! Regex(#"""
    (?x)
    (?<fieldA> [^,]*)
    ,
    (?<fieldB> [^,]*)
    """#)

    let match = "abc,def".wholeMatch(of: regex)!
    XCTAssertEqual(match.0, "abc,def")
    XCTAssertEqual(match[0].substring, "abc,def")

    XCTAssertEqual(match["fieldA"]!.substring, "abc")
    XCTAssertEqual(match.output["fieldA"]!.substring, "abc")
    XCTAssertEqual(match[1].substring, "abc")

    XCTAssertEqual(match["fieldB"]!.substring, "def")
    XCTAssertEqual(match.output["fieldB"]!.substring, "def")
    XCTAssertEqual(match[2].substring, "def")

    XCTAssertNil(match["notACapture"])
    XCTAssertNil(match.output["notACapture"])
    XCTAssertEqual(match.count, 3)

    XCTAssert(regex.contains(captureNamed: "fieldA"))
    XCTAssert(regex.contains(captureNamed: "fieldB"))
    XCTAssertFalse(regex.contains(captureNamed: "notAField"))


    let regexConcrete:
      Regex<(Substring, fieldA: Substring, fieldB: Substring)>
    = try! Regex(#"""
    (?x)
    (?<fieldA> [^,]*)
    ,
    (?<fieldB> [^,]*)
    """#)
    let matchConcrete = "abc,def".wholeMatch(of: regexConcrete)!
    XCTAssertEqual(matchConcrete.0, match.0)
    XCTAssertEqual(match[0].substring, match.0)

    XCTAssertEqual(matchConcrete.fieldA, match["fieldA"]!.substring)
    XCTAssertEqual(matchConcrete.output.fieldA, match.output["fieldA"]!.substring)
    XCTAssertEqual(matchConcrete.1, match[1].substring)

    XCTAssertEqual(matchConcrete.fieldB, match["fieldB"]!.substring)
    XCTAssertEqual(matchConcrete.output.fieldB, match.output["fieldB"]!.substring)
    XCTAssertEqual(matchConcrete.2, match[2].substring)

    // XCTAssertEqual(matchConcrete, match["notACapture"])
    // XCTAssertEqual(matchConcrete, match.output["notACapture"])

    // TODO: Do we want this?
    // XCTAssertEqual(matchConcrete, match.count)

    XCTAssertEqual(regexConcrete.contains(captureNamed: "fieldA"), regex.contains(captureNamed: "fieldA"))
    XCTAssertEqual(regexConcrete.contains(captureNamed: "fieldB"), regex.contains(captureNamed: "fieldB"))
    XCTAssertEqual(regexConcrete.contains(captureNamed: "notAField"), regex.contains(captureNamed: "notAField"))


    // TODO: ARO init from concrete match tuple

    // TODO: ARO as cast to concrete match tuple

    // Note on SE that Element means it must ARC the input

    // TODO: Match of ARO: init from tuple match and as to tuple match

    // TODO: init from output regex and as cast to output regex


  }
}
