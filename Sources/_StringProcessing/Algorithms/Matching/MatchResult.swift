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

public struct _MatchResult<S: MatchingCollectionSearcher> {
  public let match: S.Searched.SubSequence
  public let result: S.Match
  
  public var range: Range<S.Searched.Index> {
    match.startIndex..<match.endIndex
  }
}

public struct _BackwardMatchResult<S: BackwardMatchingCollectionSearcher> {
  public let match: S.BackwardSearched.SubSequence
  public let result: S.Match
  
  public var range: Range<S.BackwardSearched.Index> {
    match.startIndex..<match.endIndex
  }
}
