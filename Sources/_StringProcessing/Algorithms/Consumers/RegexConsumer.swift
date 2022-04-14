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

// FIXME: What even is this? Can we delete this whole thing?
struct RegexConsumer<
  R: RegexComponent, Consumed: BidirectionalCollection
> where Consumed.SubSequence == Substring {
  // TODO: Should `Regex` itself implement these protocols?
  let regex: R

  init(_ regex: R) {
    self.regex = regex
  }
}

extension RegexConsumer {
  func _matchingConsuming(
    _ consumed: Substring, in range: Range<String.Index>
  ) -> (upperBound: String.Index, match: Match)? {
    guard let result = try! regex.regex._match(
      consumed.base,
      in: range, mode: .partialFromFront
    ) else { return nil }
    return (result.range.upperBound, result.output)
  }
}

// TODO: Explicitly implement the non-matching consumer/searcher protocols as
// well, taking advantage of the fact that the captures can be ignored

extension RegexConsumer: MatchingCollectionConsumer {
  typealias Match = R.RegexOutput
  
  func matchingConsuming(
    _ consumed: Consumed, in range: Range<Consumed.Index>
  ) -> (upperBound: String.Index, match: Match)? {
    _matchingConsuming(consumed[...], in: range)
  }
}

// TODO: We'll want to bake backwards into the engine
extension RegexConsumer: BidirectionalMatchingCollectionConsumer {
  func matchingConsumingBack(
    _ consumed: Consumed, in range: Range<Consumed.Index>
  ) -> (lowerBound: String.Index, match: Match)? {
    var i = range.lowerBound
    while true {
      if let (end, capture) = _matchingConsuming(
        consumed[...],
        in: i..<range.upperBound
      ), end == range.upperBound {
        return (i, capture)
      } else if i == range.upperBound {
        return nil
      } else {
        consumed.formIndex(after: &i)
      }
    }
  }
}

extension RegexConsumer: MatchingStatelessCollectionSearcher {
  typealias Searched = Consumed

  // TODO: We'll want to bake search into the engine so it can
  // take advantage of the structure of the regex itself and
  // its own internal state
  func matchingSearch(
    _ searched: Searched, in range: Range<Searched.Index>
  ) -> (range: Range<String.Index>, match: Match)? {
    ConsumerSearcher(consumer: self).matchingSearch(searched, in: range)
  }
}

// TODO: Bake in search-back to engine too
extension RegexConsumer: BackwardMatchingStatelessCollectionSearcher {
  typealias BackwardSearched = Consumed
  
  func matchingSearchBack(
    _ searched: BackwardSearched, in range: Range<Searched.Index>
  ) -> (range: Range<String.Index>, match: Match)? {
    ConsumerSearcher(consumer: self).matchingSearchBack(searched, in: range)
  }
}
