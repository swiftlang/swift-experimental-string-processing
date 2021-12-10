import XCTest

@testable import _MatchingEngine

/// Hold context and run variety of ad-hoc tests
///
/// TODO: Use these to demonstrate first-order approximation of what
/// overhead such an engine imposes
fileprivate struct Test: ExpressibleByStringLiteral {
  var input: String
  var aEater: String
  var manyAEater: String
  var eatUntilA: String
  var eatThroughA: String

  // TODO: Have tests explicitly show each step of type binding,
  // input binding, etc.
  var enableTracing: Bool? = nil

  /*

   until first A
   through first A
   until / through last A
   etc

   */

  var file: String
  var line: UInt

  init(
    _ s: String,
    enableTracing: Bool? = nil,
    file: String = #file,
    line: UInt = #line
  ) {
    self.input = s
    self.aEater = s.first == "A" ? String(s.dropFirst()) : s
    self.manyAEater = String(s.drop(while: { $0 == "A" }))

    if let firstIdx = s.firstIndex(of: "A") {
      self.eatUntilA = String(s[firstIdx...])
      self.eatThroughA = String(eatUntilA.dropFirst())
    } else {
      self.eatUntilA = s
      self.eatThroughA = s
    }

    self.enableTracing = enableTracing

//    self.untilFirstAEater = String(
//      s[(s.firstIndex(where: { $0 == "A" }) ?? s.startIndex)...])


    self.file = file
    self.line = line
  }
  init(
    stringLiteral: String,
    file: String = #file,
    line: UInt = #line
  ) {
    self.init(stringLiteral, file: file, line: line)
  }
  init(stringLiteral: String) {
    // NOTE: Can't get source location of a literal...
    self.init(stringLiteral)
  }

  var slicedInput: (String, Range<String.Index>) {
    let prefix = "aAa prefix ⚠️"
    let suffix = "⚠️ aAa suffix"
    let outer = prefix + input + suffix
    let range = outer.mapOffsets(
      (lower: prefix.count, upper: -suffix.count))
    return (outer, range)
  }

  func check(_ engine: Engine<String>,  expected: String) {
    var engine = engine
    if let t = enableTracing {
      engine.enableTracing = t
    }
    let output: String
    let outputFromSlice: String

    if let idx = engine.consume(input) {
      output = String(input[idx...])
    } else {
      output = input
    }

    let (outerInput, range) = slicedInput
    if let idx = engine.consume(outerInput, in: range) {
      outputFromSlice = String(outerInput[idx..<range.upperBound])
    } else {
      outputFromSlice = input
    }

    XCTAssertEqual(expected, output)
    XCTAssertEqual(output, outputFromSlice)
  }

  func check(
    aEater: Engine<String>? = nil,
    manyAEater: Engine<String>? = nil,
    eatUntilA: Engine<String>? = nil,
    eatThroughA: Engine<String>? = nil
  ) {
    if let engine = aEater {
      check(engine, expected: self.aEater)
    }
    if let engine = manyAEater {
      check(engine, expected: self.manyAEater)
    }
    if let engine = eatUntilA {
      check(engine, expected: self.eatUntilA)
    }
    if let engine = eatThroughA {
      check(engine, expected: self.eatThroughA)
    }
  }
}

var doPrint = false
func show(_ s: CustomStringConvertible) {
  if doPrint { print(s) }
}

func makeEngine(
  _ constructor: (inout Program<String>.Builder) -> ()
) -> Engine<String> {
  var builder = Program<String>.Builder()
  constructor(&builder)
  let program = builder.assemble()
  let engine = Engine<String>(program)
  show(engine)
  return engine
}

// Eat an A off the front
//
//   [0] match "A"
//   [1] accept
//
let aEater: Engine<String> = {
  makeEngine { builder in
    builder.buildMatch("A")
    builder.buildAccept()
  }
}()

// Eat many "A"s off the input
//
//   [0] saveAddress [3] // .accept
//   [1] match "A"
//   [2] goto [1] // match "A"
//   [3] accept
//
// NOTE: a save would restore input position, which we
// actually don't want to do.
//
// NOTE: We should compare with a more sophisticated match
// instruction that can take at least or at most, etc.
//
let manyAEater: Engine<String> = {
  makeEngine { builder in
    let accTok = builder.makeAddress()
    let matchTok = builder.makeAddress()

    builder.buildSaveAddress(accTok)
    builder.buildMatch("A")
    builder.resolve(matchTok)
    builder.buildBranch(to: matchTok)
    builder.buildAccept()
    builder.resolve(accTok)
  }
}()

// Eat until you find an A (FAIL if no A)
//
//   [0] assert #0 #0
//   [1] condBranch #0 [x] // accept
//   [2] consume(1)
//   [3] goto 0
//   [4] accept
//
// NOTE: This check-consume-else-branch pattern
// could be pretty common and might be worth a dedicated
// instruction.
let eatUntilA: Engine<String> = {
  makeEngine { builder in 
    let reg = builder.makeRegister()
    let accTok = builder.makeAddress()
    let assertTok = builder.makeAddress()
    builder.buildAssert("A", into: reg)
    builder.resolve(assertTok)
    builder.buildCondBranch(reg, to: accTok)
    builder.buildConsume(1)
    builder.buildBranch(to: assertTok)
    builder.buildAccept()
    builder.resolve(accTok)
  }
}()

// Eat through the first A (FAIL if no A)
//
//   [0] assert #0 #0
//   [1] consume(1)
//   [2] condBranch #0 [x] // accept
//   [3] goto 0
//   [4] accept
let eatThroughA: Engine<String> = {
  makeEngine { builder in
    let reg = builder.makeRegister()
    let accTok = builder.makeAddress()
    let assertTok = builder.makeAddress()
    builder.buildAssert("A", into: reg)
    builder.resolve(assertTok)
    builder.buildConsume(1)
    builder.buildCondBranch(reg, to: accTok)
    builder.buildBranch(to: assertTok)
    builder.buildAccept()
    builder.resolve(accTok)
  }
}()

class MatchingEngineTests: XCTestCase {

  func testAEaters() {
    let tests: Array<Test> = [
      Test("abc"),
      Test("Abc"),
      Test("AAbc"),
      Test(""),
      Test("A"),
      Test("b"),
      Test("bbbA"),
      Test("bbAbA"),
    ]

    for test in tests {
      test.check(aEater: aEater)
      test.check(manyAEater: manyAEater)
      test.check(eatUntilA: eatUntilA)
      test.check(eatThroughA: eatThroughA)
    }
  }
}
