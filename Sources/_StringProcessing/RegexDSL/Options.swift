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

import _MatchingEngine

extension RegexComponent {
  public func caseSensitive(_ isCaseSensitive: Bool) -> Regex<Output> {
    // The API is "case sensitive = true or false", so as to avoid the
    // double negatives inherent in setting "case insensitive" to a Boolean
    // value. The internal version of this option, on the other hand, is
    // `.caseInsensitive`, derived from the `(?i)` regex literal option.
    let sequence = isCaseSensitive
      ? AST.MatchingOptionSequence(removing: [.init(.caseInsensitive, location: .fake)])
      : AST.MatchingOptionSequence(adding: [.init(.caseInsensitive, location: .fake)])
    return Regex(node: .nonCapturingGroup(
      .changeMatchingOptions(sequence, isIsolated: false),
      regex.root))
  }
}

