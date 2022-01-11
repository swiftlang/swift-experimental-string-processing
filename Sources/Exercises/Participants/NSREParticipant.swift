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

import Foundation

struct NSREParticipant: Participant {
  static var name: String { "NSRegularExpression" }

  // Produce a function that will parse a grapheme break entry from a line
  static func graphemeBreakProperty() throws -> (String) -> GraphemeBreakEntry? {
    graphemeBreakPropertyData(forLine:)
  }
}

extension String {
  var nsRange: NSRange {
    NSRange(location: 0, length: utf16.count)
  }
  
  subscript(nsrange: NSRange) -> Substring {
    guard let range = Range(nsrange, in: self) else { return prefix(0) }
    return self[range]
  }
}

private func graphemeBreakPropertyData(
  forLine line: String
) -> GraphemeBreakEntry? {
  let regex = try! NSRegularExpression(
    pattern: "([0-9a-f]+)(?:\\.\\.([0-9a-f]+))?\\s+;\\s+(\\w+).+",
    options: .caseInsensitive)
  
  guard let match = regex.firstMatch(in: line, options: [], range: line.nsRange)
    else { return nil }
  
  guard let lowerScalar = Unicode.Scalar(hex: line[match.range(at: 1)]),
        let property = Unicode.GraphemeBreakProperty(line[match.range(at: 3)])
    else { return nil }
  let upperScalar = Unicode.Scalar(hex: line[match.range(at: 2)]) ?? lowerScalar
  return GraphemeBreakEntry(lowerScalar...upperScalar, property)
}
