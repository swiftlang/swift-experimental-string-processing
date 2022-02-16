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

extension MatchingCollectionConsumer where Consumed == String {
  public var regex: Regex<Match> {
    Regex(node: .matcher(.init(Match.self)) {
      self.matchingConsuming($0, in: $1)
    })
  }
}

extension CollectionConsumer where Consumed == String {
  public var regex: Regex<Void> {
    Regex(node: .consumer {
      self.consuming($0, in: $1)
    })
  }
}

// TODO: How can/should the DSL choose between them? Need to
// know whether value is captured or not. Should this be
// done via how we declare API or should this be part of
// compilation / DSLTree logic?

