import RegexDSL

struct RegexParticipant: Participant {
  static var name: String { "Regex" }

    // Produce a function that will parse a grapheme break entry from a line
  static func graphemeBreakProperty() throws -> (String) -> GraphemeBreakEntry? {
    graphemeBreakPropertyData(forLine:)
  }
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
  guard case let (lower, upper, propertyString)? = result?.captures,
        let lowerScalar = Unicode.Scalar(hex: lower),
        let upperScalar = upper.map(Unicode.Scalar.init(hex:)) ?? lowerScalar,
        let property = Unicode.GraphemeBreakProperty(propertyString)
  else {
    return nil
  }
  return GraphemeBreakEntry(lowerScalar...upperScalar, property)
}
