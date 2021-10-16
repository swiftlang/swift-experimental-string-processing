/// Participants engage in a number of exercises.
///
/// Default implementations will throw `Unsupported`.
/// Opt-in for cross-library comparisons, testing, and benchmarking by overriding the corresponding functions.
///
public protocol Participant {
  static var name: String { get }

  // Produce a function that will parse a grapheme break entry from a line
  static func graphemeBreakProperty() throws -> (String) -> GraphemeBreakEntry?

  // Produce a function that will extract the bodies of C-style comments from its input
  static func cComments() throws -> (String) -> [Substring]

  // Produce a function that will extract the bodies of Swift-style comments from its input
  static func swiftComments() throws -> (String) -> [Substring]

  // ...
}

extension String: Error {}

// Default impls
extension Participant {
  static var unsupported: Error { "Unsupported" }

  // Produce a function that will parse a grapheme break entry from a line
  public static func graphemeBreakProperty() throws -> (String) -> GraphemeBreakEntry? {
    throw unsupported
  }

  // Produce a function that will extract the bodies of C-style comments from its input
  public static func cComments() throws -> (String) -> [Substring] {
    throw unsupported
  }

  // Produce a function that will extract the bodies of Swift-style comments from its input
  public static func swiftComments() throws -> (String) -> [Substring] {
    throw unsupported
  }
}
