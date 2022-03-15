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

struct DSLSourceLocation {
  var file: String
  var function: String
  var line: Int
  var column: Int
}

extension DSLSourceLocation: CustomStringConvertible {
  var description: String {
    "\(file)@\(function):\(line):\(column)"
  }
}

struct DSLLocated<Value> {
  var value: Value
  var location: DSLSourceLocation?
}
