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

extension BenchmarkRunner {
  mutating func addUnicode() {
    // tagged unicode: unicode characters surrounded by html tags
    // use the same html regex, uses backreference + reluctant quantification
//    let tags = #"<(\w*)\b[^>]*>(.*?)<\/\1>"# // disabled due to \b being unusably slow
//    let taggedEmojis = CrossBenchmark(
//      baseName: "TaggedEmojis",
//      regex: tags,
//      input: Inputs.taggedEmojis)

    // Now actually matching emojis
    let emoji = #"(😃|😀|😳|😲|😦|😊|🙊|😘|😏|😳|😒){2,5}"#
    
    let emojiRegex = CrossBenchmark(
      baseName: "EmojiRegex",
      regex: emoji,
      input: Inputs.taggedEmojis)

    // taggedEmojis.register(&self)
    emojiRegex.register(&self)
  }
}
