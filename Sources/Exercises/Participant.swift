//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2021-2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

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

// Errors that may be thrown from default implementations
private enum ParticipantError: Error {
  case unsupported
}

// Default impls
extension Participant {
  // Produce a function that will parse a grapheme break entry from a line
  public static func graphemeBreakProperty() throws -> (String) -> GraphemeBreakEntry? {
    throw ParticipantError.unsupported
  }

  // Produce a function that will extract the bodies of C-style comments from its input
  public static func cComments() throws -> (String) -> [Substring] {
    throw ParticipantError.unsupported
  }

  // Produce a function that will extract the bodies of Swift-style comments from its input
  public static func swiftComments() throws -> (String) -> [Substring] {
    throw ParticipantError.unsupported
  }
}
