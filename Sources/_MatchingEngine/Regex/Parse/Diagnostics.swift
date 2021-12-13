// MARK: - Parse errors

enum ParseError: Error, Hashable {
  // TODO: I wonder if it makes sense to store the string.
  // This can make equality weird.

  case numberOverflow(String)
  case expectedDigits(String, expecting: ClosedRange<Int>)
  case tooManyDigits(String)

  case expectedHexNumber(String)

  // Expected the given character or string
  case expected(String)

  // Expected something, anything really
  case unexpectedEndOfInput

  // Something happened, fall-back for now
  case misc(String)

  case expectedASCII(Character)

  case expectedCustomCharacterClassMembers
  case invalidCharacterClassRangeOperand

  case invalidPOSIXSetName(String)
  case emptyProperty
}

// TODO: Fixits, notes, etc.

// TODO: Diagnostics engine, recorder, logger, or similar.



