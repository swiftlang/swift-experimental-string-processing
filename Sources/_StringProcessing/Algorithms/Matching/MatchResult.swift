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

struct _MatchResult<S: MatchingCollectionSearcher> {
  let match: S.Searched.SubSequence
  let result: S.Match
  
  var range: Range<S.Searched.Index> {
    match.startIndex..<match.endIndex
  }
}

struct _BackwardMatchResult<S: BackwardMatchingCollectionSearcher> {
  let match: S.BackwardSearched.SubSequence
  let result: S.Match
  
  var range: Range<S.BackwardSearched.Index> {
    match.startIndex..<match.endIndex
  }
}
