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


extension Processor {
  // TODO: Should we throw here?
  mutating func consume() -> Input.Index? {
    while true {
      switch self.state {
      case .accept:
        return self.currentPosition
      case .fail:
        return nil
      case .inProgress: self.cycle()
      }
    }
  }
}

