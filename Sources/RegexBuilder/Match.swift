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

import _StringProcessing

extension String {
  @available(SwiftStdlib 5.7, *)
  public func wholeMatch<R: RegexComponent>(
    @RegexComponentBuilder of content: () -> R
  ) -> Regex<R.RegexOutput>.Match? {
    wholeMatch(of: content())
  }

  @available(SwiftStdlib 5.7, *)
  public func prefixMatch<R: RegexComponent>(
    @RegexComponentBuilder of content: () -> R
  ) -> Regex<R.RegexOutput>.Match? {
    prefixMatch(of: content())
  }
}

extension Substring {
  @available(SwiftStdlib 5.7, *)
  public func wholeMatch<R: RegexComponent>(
    @RegexComponentBuilder of content: () -> R
  ) -> Regex<R.RegexOutput>.Match? {
    wholeMatch(of: content())
  }

  @available(SwiftStdlib 5.7, *)
  public func prefixMatch<R: RegexComponent>(
    @RegexComponentBuilder of content: () -> R
  ) -> Regex<R.RegexOutput>.Match? {
    prefixMatch(of: content())
  }
}
