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

struct NaiveParticipant: Participant {
  static var name: String { "Naive" }

  static func graphemeBreakProperty() throws -> (String) -> GraphemeBreakEntry? {
    graphemeBreakPropertyData(forLine:)
  }
}

private func graphemeBreakPropertyData(
  forLine line: String
) -> GraphemeBreakEntry? {
  let components = line.split(separator: ";")
  guard components.count >= 2 else { return nil }

  let splitProperty = components[1].split(separator: "#")
  let filteredProperty = splitProperty[0].filter { !$0.isWhitespace }
  guard let property = Unicode.GraphemeBreakProperty(filteredProperty) else {
    return nil
  }

  let scalars: ClosedRange<Unicode.Scalar>
  let filteredScalars = components[0].filter { !$0.isWhitespace }
  if filteredScalars.contains(".") {
    let range = filteredScalars
      .split(separator: ".")
      .map { Unicode.Scalar(hex: $0)! }
    scalars = range[0] ... range[1]
  } else {
    let scalar = Unicode.Scalar(hex: filteredScalars)!
    scalars = scalar...scalar
  }
  return GraphemeBreakEntry(scalars, property)
}

