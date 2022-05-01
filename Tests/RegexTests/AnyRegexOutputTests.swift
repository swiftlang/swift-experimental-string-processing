
import _StringProcessing
import XCTest

// Test that our existential capture and concrete captures are
// the same
private func checkSame(
  _ aro: AnyRegexOutput,
  _ concrete: (Substring, fieldA: Substring, fieldB: Substring)
) {
  XCTAssertEqual(aro[0].substring, concrete.0)

  XCTAssertEqual(aro["fieldA"]!.substring, concrete.1)
  XCTAssertEqual(aro["fieldA"]!.substring, concrete.fieldA)

  XCTAssertEqual(aro[1].substring, concrete.1)

  XCTAssertEqual(aro["fieldB"]!.substring, concrete.2)
  XCTAssertEqual(aro["fieldB"]!.substring, concrete.fieldB)

  XCTAssertEqual(aro[2].substring, concrete.2)

}
private func checkSame(
  _ aro: Regex<AnyRegexOutput>.Match,
  _ concrete: Regex<(Substring, fieldA: Substring, fieldB: Substring)>.Match
) {
  checkSame(aro.output, concrete.output)

  XCTAssertEqual(aro.0, concrete.0)
  XCTAssertEqual(aro[0].substring, concrete.0)

  XCTAssertEqual(aro["fieldA"]!.substring, concrete.1)
  XCTAssertEqual(aro["fieldA"]!.substring, concrete.fieldA)
  XCTAssertEqual(aro[1].substring, concrete.1)

  XCTAssertEqual(aro["fieldB"]!.substring, concrete.2)
  XCTAssertEqual(aro["fieldB"]!.substring, concrete.fieldB)
  XCTAssertEqual(aro[2].substring, concrete.2)
}
private func checkSame(
  _ aro: Regex<AnyRegexOutput>,
  _ concrete: Regex<(Substring, fieldA: Substring, fieldB: Substring)>
) {
  XCTAssertEqual(
    aro.contains(captureNamed: "fieldA"),
    concrete.contains(captureNamed: "fieldA"))
  XCTAssertEqual(
    aro.contains(captureNamed: "fieldB"),
    concrete.contains(captureNamed: "fieldB"))
  XCTAssertEqual(
    aro.contains(captureNamed: "notAField"),
    concrete.contains(captureNamed: "notAField"))
}

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

    // MARK: Check equivalence with concrete

    let regexConcrete:
      Regex<(Substring, fieldA: Substring, fieldB: Substring)>
    = try! Regex(#"""
    (?x)
    (?<fieldA> [^,]*)
    ,
    (?<fieldB> [^,]*)
    """#)
    checkSame(regex, regexConcrete)

    let matchConcrete = "abc,def".wholeMatch(of: regexConcrete)!
    checkSame(match, matchConcrete)

    let output = match.output
    let concreteOutput = matchConcrete.output
    checkSame(output, concreteOutput)

    // TODO: ARO init from concrete match tuple

    let concreteOutputCasted = output.as(
      (Substring, fieldA: Substring, fieldB: Substring).self
    )!
    checkSame(output, concreteOutputCasted)

    var concreteOutputCopy = concreteOutput
    concreteOutputCopy = output.as()!
    checkSame(output, concreteOutputCopy)

    // TODO: Regex<ARO>.Match: init from tuple match and as to tuple match

    // TODO: Regex<ARO>: init from tuple regex and as cast to tuple regex

  }
}
