/// An token that matches against a certain position in the subject.
public enum Anchor: String, Hashable {
  case lineStart = "^"
  case lineEnd = "$"
  case wordBoundary = "\\b"
  case nonWordBoundary = "\\B"
  case stringStart = "\\A"
  case stringEndOrBeforeNewline = "\\Z"
  case stringEnd = "\\z"
  case startOfPreviousMatch = "\\G"
  case resetMatch = "\\K"
  case textSegmentBoundary = "\\y"
  case textSegmentNonBoundary = "\\Y"
}

extension Anchor: CustomStringConvertible {
  public var description: String { rawValue }
}
