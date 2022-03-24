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
  public func match<R: RegexComponent>(
    @RegexComponentBuilder _ content: () -> R
  ) -> Regex<R.Output>.Match? {
    match(content())
  }
}

extension Substring {
  public func match<R: RegexComponent>(
    @RegexComponentBuilder _ content: () -> R
  ) -> Regex<R.Output>.Match? {
    match(content())
  }
}
