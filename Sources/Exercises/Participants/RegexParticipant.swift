import Regex
import RegexDSL
//import Algorithms

/*

 TODO: We probably want to allow participants to register
 multiple variations or strategies.

 We have:

 1) DSL vs literal
 2) HareVM, TortoiseVM, transpile to PEG, transpile to
    MatchingEngine

*/


struct RegexDSLParticipant: Participant {
  static var name: String { "Regex DSL" }

    // Produce a function that will parse a grapheme break entry from a line
  static func graphemeBreakProperty() throws -> (String) -> GraphemeBreakEntry? {
    graphemeBreakPropertyData(forLine:)
  }
}

struct RegexLiteralParticipant: Participant {
  static var name: String { "Regex Literal" }

    // Produce a function that will parse a grapheme break entry from a line
  static func graphemeBreakProperty() throws -> (String) -> GraphemeBreakEntry? {
//    graphemeBreakPropertyDataLiteral(forLine:)
    throw Self.unsupported
  }
}

private func extractFromCaptures(
  lower: Substring, upper: Substring?, prop: Substring
) -> GraphemeBreakEntry? {
  guard let lowerScalar = Unicode.Scalar(hex: lower),
        let upperScalar = upper.map(Unicode.Scalar.init(hex:)) ?? lowerScalar,
        let property = Unicode.GraphemeBreakProperty(prop)
  else {
    return nil
  }
  return GraphemeBreakEntry(lowerScalar...upperScalar, property)
}

@inline(__always) // get rid of generic please
private func graphemeBreakPropertyData<RP: RegexProtocol>(
  forLine line: String,
  using regex: RP
) -> GraphemeBreakEntry? {
  fatalError("""
    How would I do this? How do I type captures for RP?
    """)
}


private func graphemeBreakPropertyData(
  forLine line: String
) -> GraphemeBreakEntry? {
  let result = line.match {
    OneOrMore(CharacterClass.hexDigit).capture()
    Optionally {
      ".."
      OneOrMore(CharacterClass.hexDigit).capture()
    }
    OneOrMore(CharacterClass.whitespace)
    ";"
    OneOrMore(CharacterClass.whitespace)
    OneOrMore(CharacterClass.word).capture()
    Repeat(CharacterClass.any)
  }

  guard let (lower, upper, propertyString) = result?.captures
  else {
    return nil
  }

  return extractFromCaptures(lower: lower, upper: upper, prop: propertyString)
}

private func graphemeBreakPropertyDataLiteral(
  forLine line: String
) -> GraphemeBreakEntry? {
  // TODO: It might make sense to have a RegexLiteral that
  // conforms to RegexProtocol in the DSL and is
  // ExpressibleByStringLiteral for raw-strings.

  let reCode = try! compile(
    #"([0-9A-F]+)(?:\.\.([0-9A-F]+))?\s*;\s(\w+).*"#)
  let vm = TortoiseVM(reCode)
  guard let caps = vm.execute(input: line)?.captures else {
    return nil
  }
  _ = caps
  fatalError("FIXME: we never get here...")
//  return extractFromCaptures(lower: lower, upper: upper, prop: propertyString)
}
