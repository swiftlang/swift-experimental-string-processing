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

public struct Unsupported: Error, CustomStringConvertible {
  var message: String
  var file: String
  var line: Int

  public var description: String { """
    Unsupported: '\(message)'
      \(file):\(line)
    """
  }

  public init(
    _ s: String,
    file: StaticString = #file,
    line: UInt = #line
  ) {
    self.message = s
    self.file = file.description
    self.line = Int(asserting: line)
  }
}

public struct Unreachable: Error, CustomStringConvertible {
  var message: String
  var file: String
  var line: Int

  public var description: String { """
    Unreachable: '\(message)'
      \(file):\(line)
    """
  }

  public init(
    _ s: String,
    file: StaticString = #file,
    line: UInt = #line
  ) {
    self.message = s
    self.file = file.description
    self.line = Int(asserting: line)
  }
}
