import _StringProcessing
import RegexDSL

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
    graphemeBreakPropertyDataLiteral(forLine:)
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
) -> GraphemeBreakEntry? where RP.Capture == (Substring, Substring?, Substring) {
  line.match(regex).map(\.captures).flatMap(extractFromCaptures)
}

private func graphemeBreakPropertyData(
  forLine line: String
) -> GraphemeBreakEntry? {
  graphemeBreakPropertyData(forLine: line, using: Regex {
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
  })
}

private func graphemeBreakPropertyDataLiteral(
  forLine line: String
) -> GraphemeBreakEntry? {
  return graphemeBreakPropertyData(
    forLine: line,
    using: r(#"([0-9A-F]+)(?:\.\.([0-9A-F]+))?\s+;\s+(\w+).*"#,
             capturing: (Substring, Substring?, Substring).self))
}
