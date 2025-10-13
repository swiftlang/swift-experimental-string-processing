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

protocol MatchingCollectionSearcher: CollectionSearcher {
  associatedtype Match
  func matchingSearch(
    _ searched: Searched,
    _ state: inout State
  ) -> (range: Range<Searched.Index>, match: Match)?
}

extension MatchingCollectionSearcher {
  func search(
    _ searched: Searched,
    _ state: inout State
  ) -> Range<Searched.Index>? {
    matchingSearch(searched, &state)?.range
  }
}
