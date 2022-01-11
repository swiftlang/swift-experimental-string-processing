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


struct ReferenceParticipant: Participant {
  static var name: String { "Reference" }

  static func graphemeBreakProperty() throws -> (String) -> GraphemeBreakEntry? {
    try! NaiveParticipant.graphemeBreakProperty()
  }
}
