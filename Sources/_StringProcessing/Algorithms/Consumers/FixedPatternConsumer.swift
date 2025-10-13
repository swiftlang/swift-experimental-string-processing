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

struct FixedPatternConsumer<Consumed: Collection, Pattern: Sequence>
  where Consumed.Element: Equatable, Pattern.Element == Consumed.Element
{
  let pattern: Pattern
}

extension FixedPatternConsumer: CollectionConsumer {
  func consuming(
    _ consumed: Consumed,
    in range: Range<Consumed.Index>
  ) -> Consumed.Index? {
    var index = range.lowerBound
    var patternIterator = pattern.makeIterator()
    
    while let element = patternIterator.next() {
      if index == range.upperBound || consumed[index] != element {
        return nil
      }
      
      consumed.formIndex(after: &index)
    }
    
    return index
  }
}

