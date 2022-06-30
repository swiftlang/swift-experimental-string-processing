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

@_spi(_Unicode)
import Swift

extension String {
  func isOnWordBoundary(at i: String.Index) -> Bool {
    guard i != startIndex, i != endIndex else {
      return true
    }
    
    if #available(SwiftStdlib 5.7, *) {
      var indices: Set<String.Index> = []
      var j = startIndex
      
      while j < endIndex, j <= i {
        indices.insert(j)
        j = _wordIndex(after: j)
      }
      
      return indices.contains(i)
    } else {
      return false
    }
  }
}
