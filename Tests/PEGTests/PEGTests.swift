import XCTest
@testable import PEG
import MatchingEngine

// Make examples more sane. Need builder
typealias Pattern = PEG<Character>.Pattern
extension PEG.Pattern:
  ExpressibleByExtendedGraphemeClusterLiteral,
  ExpressibleByUnicodeScalarLiteral,
  ExpressibleByStringLiteral
where Element == Character {
  public typealias UnicodeScalarLiteralType = String
  public typealias ExtendedGraphemeClusterLiteralType = String

  public init(stringLiteral value: String) {
    if value.count == 1 {
      self = .element(value.first!)
    } else {
      self = .literal(Array(value))
    }
  }
}
extension PEG.Pattern {
  init(_ term: Self) {
    self = term
  }
  init(_ terms: Self...) {
    self = .concat(terms)
  }
}

class PEGTests: XCTestCase {
}

class PEGStringTests: XCTestCase {
  typealias Pattern = PEG<Character>.Pattern

  let doPrint = false
  func show<S: CustomStringConvertible>(_ s: S) {
    if doPrint { print(s) }
  }

  func testComments() {
    /// Match C-style comments 
    ///
    ///     CComment -> '/*' (!'*/' <any>)* '*/'
    ///
    let notEnd = Pattern(.difference(.any, "*/"))
    let cComment = Pattern(
      "/*",
      .many(notEnd),
      "*/")
    show(cComment)
    let cProgram = PEG.Program(
      start: "CComment",
      environment: ["CComment": cComment])

    /// Match Swift style comments
    ///
    ///     SwiftComment -> '/*' SwiftBody '*/'
    ///     SwiftBody -> (SwiftComment | (!'*/' <any>))*
    ///
    let swiftComment = Pattern(
      "/*", .variable("SwiftBody"), "*/")
    let swiftBody = Pattern(
      .many(.orderedChoice(.variable("SwiftComment"), notEnd)))
    let swiftProgram = PEG.Program(
      start: "SwiftComment",
      environment: ["SwiftComment": swiftComment, "SwiftBody": swiftBody])
    
    // Test convention: special characters denote end of C, Swift, or both
    // comment styles.
    let tests: Array<String> = [
      "abc",
      "/**/🔚 xyz",
      "/* abc */🔚 xyz",
      "/* abc * / def */🔚 xyz",
      "/* abc /* def */🐚 def*/🕊 xyz",
    ]
    func expect(
      _ test: String, cEnd: String.Index?, swiftEnd: String.Index?
    ) {
      if let idx = test.firstIndex(of: "🔚") {
        XCTAssertEqual(idx, cEnd)
        XCTAssertEqual(idx, swiftEnd)
        return
      }
      XCTAssertEqual(test.firstIndex(of: "🐚"), cEnd)
      XCTAssertEqual(test.firstIndex(of: "🕊"), swiftEnd)
    }

    // Test PEG interpreter
    for test in tests {
      expect(
        test,
        cEnd: cProgram.consume(test),
        swiftEnd: swiftProgram.consume(test))
    }

    // Compile down to the PEG core and run that
    let cCode = PEG.VM<String>.compile(cProgram)
    let swiftCode = PEG.VM<String>.compile(swiftProgram)
    show(cCode)
    show(swiftCode)
    let cVM = PEG.VM.load(cCode)
    let swiftVM = PEG.VM.load(swiftCode)
    show(cVM)
    show(swiftVM)

    for test in tests {
      expect(
        test,
        cEnd: cVM.consume(test),
        swiftEnd: swiftVM.consume(test))
    }

    // Transpile to the matching engine and run that
    let cTranspiled = cVM.transpile()
    let swiftTranspiled = swiftVM.transpile()
    show(cTranspiled)
    show(swiftTranspiled)

    let cME = Engine<String>(cTranspiled)
    let swiftME = Engine<String>(swiftTranspiled)

    for test in tests {
      expect(
        test,
        cEnd: cME.consume(test),
        swiftEnd: swiftME.consume(test))
    }
  }

  // TODO: Simple parse examples
  /*

   `a + (b - c) * d` -> .product(.sum(a, .minus(b, c)), d)

   */

  func testEvenZeroesOnes() {
    // Even zeroes and even ones
    // This is a regular language, simple state machine,
    // but increadibly difficult to express with a
    // regular expression

    /*

     Even -> 0 OddZero | 1 OddOne
     OddZero -> 0 Even | 1 OddBoth
     OddOne -> 0 OddBoth | 1 Even
     OddBoth -> 0 OddOne | 1 OddZero

     */

    let even = Pattern.orderedChoice(
      Pattern("0", .variable("OddZero")),
      Pattern("1", .variable("OddOne")))
    let oddZero = Pattern.orderedChoice(
      Pattern("0", .variable("Even")),
      Pattern("1", .variable("OddBoth")))
    let oddOne = Pattern.orderedChoice(
      Pattern("0", .variable("OddBoth")),
      Pattern("1", .variable("Even")))
    let oddBoth = Pattern.orderedChoice(
      Pattern("0", .variable("OddOne")),
      Pattern("1", .variable("OddZero")))

    /*
     If you wanted to accept zero-length, you can modify the
     grammar:

     Start -> Even | success

     But that's all-or-nothing. Otherwise, you need to adjust
     the calls to "Even" to call start instead

     Similarly, you can match anywhere in the middle with
     something like:

     Start -> Evens | . Start

     But I don't think this is a great user experience, better
     to have APIs drive the right behavior through native Swift
     rather than require the user to modify a different
     matching language

     Note that backtracking is not strictly needed, as 
     alternatives are strictly exclusive. But, naive compilation
     will produce them, so this is an interesting example
     for byte code optimization

     */
    let start = Pattern(.orderedChoice(.variable("_Even"), .success))
    let env: PEG<Character>.Environment = [
      "Even": start,
      "_Even": even,
      "OddZero": oddZero,
      "OddOne": oddOne,
      "OddBoth": oddBoth,
    ]
    show(start)
    let pegProgram = PEG.Program(start: "Even", environment: env)

    let tests: Array<(String, Int)> = [
     // ("x00", 0),
      ("00", 2),
      ("11", 2),
      ("1100", 4),
      ("010100", 6),
      ("10100", 4),
      ("0101tail", 4),
    ]
    func expect(
      _ test: String, expected: Int, actual: String.Index?
    ) {
      guard let idx = actual else {
        XCTAssertEqual(expected, 0)
        return
      }
      XCTAssertEqual(
        expected,
        test.distance(from: test.startIndex, to: idx))
    }

    for (test, count) in tests {
      expect(
        test, expected: count, actual: pegProgram.consume(test))
    }

    // TODO: A more natural way to solve even zeros and even ones is to attach
    // a counter. This might be provided by a generalized pattern matching
    // facility or through custom user hooks like assertions and consumptions

    // Compilation
    let code = PEG.VM<String>.compile(
      PEG.Program(start: "Even", environment: env)
    )

    var vm = PEG.VM.load(code)
    vm.enableTracing = false
    show(vm)
    for (test, count) in tests {
      // TODO: This test doesn't work quite yet
      _ = (test, count)

      expect(test, expected: count, actual: vm.consume(test))
    }

    let engine = Engine<String>(vm.transpile())
    show(engine)
    for (test, count) in tests {
      // TODO: This test doesn't work quite yet
      _ = (test, count, engine)

      expect(test, expected: count, actual: engine.consume(test))
    }


  }

  func testHappensBefore() {
    enum Event: Comparable, Hashable {
      case auth, approve, use, other
    }
    typealias Pattern = PEG<Event>.Pattern

    return // TODO: happens before PEG equivalents
  }

  func testCamelCase() {
    let tests: Array<(String, Array<String>)> = [
      ("AB", ["AB"]),
      ("ABc", ["A", "Bc"]),
      ("ABcdE", ["A", "Bcd", "E"]),
      ("abc", ["abc"]),
      ("abcDEF", ["abc", "DEF"]),
      ("abcDEFgh", ["abc", "DE", "Fgh"]),
    ]
    _ = tests

    return // TODO: camel case examples
  }

  func testCharacterClasses() {
    func testClass(_ p: Pattern, _ c: Character) -> Bool {
      // Compilation
      let code = PEG.VM<String>.compile(PEG.Program(start: "S", environment: ["S": p]))
      var vm = PEG.VM.load(code)
      vm.enableTracing = false
      show(vm)

      let engine = Engine<String>(vm.transpile())
      show(engine)

      let s = String(c)

      let (vmResult, transpileResult) = (vm.consume(s), engine.consume(s))
      XCTAssertEqual(vmResult, transpileResult)
      return vmResult != nil
    }

    let hex = Pattern.charactetSet(\.isHexDigit)
    let newline = Pattern.charactetSet(\.isNewline)
    let letter = Pattern.charactetSet(\.isLetter)
    let ascii = Pattern.charactetSet(\.isASCII)

    let alphaHexadecimal = Pattern.orderedChoice(hex, letter)

    let tests = "7abCz 🧟‍♀️_e\u{301}_é\n.\r\n,"
    for char in tests {
      XCTAssertEqual(char.isHexDigit, testClass(hex, char))
      XCTAssertEqual(char.isNewline, testClass(newline, char))
      XCTAssertEqual(char.isLetter, testClass(letter, char))
      XCTAssertEqual(char.isASCII, testClass(ascii, char))
      XCTAssertEqual(char.isHexDigit || char.isLetter, testClass(alphaHexadecimal, char))
    }
  }

  func testGraphemeBreakProperties() {

    /*
     # This is a comment

     0600..0605    ; Prepend # Cf   [6] ARABIC NUMBER SIGN..ARABIC NUMBER MARK ABOVE
     06DD          ; Prepend # Cf       ARABIC END OF AYAH

     */

    // The API will run us over every line, our PEG tells whether the
    // line matches and what captures to extract.
    //
    /*

     Single line:

     Decl -> <<\h{4, 6}> (".." <\h{4, 6}>)?> \s+ ";" \s <\w+> \s "#" .* success
     
     Multi line:

     Decl -> <<Scalar> (".." <Scalar>)?> Space+ ";" Space Property Space "#" .* success
     Scalar -> \h{4, 6}
     Space -> \s
     Property -> \w+

     */


    return // TODO: parse data file

  }
}
