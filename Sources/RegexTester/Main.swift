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

import ArgumentParser
import _RegexParser
import _StringProcessing

@main
@available(SwiftStdlib 5.8, *)
struct Main: ParsableCommand {
  static var configuration: CommandConfiguration {
    .init(
      subcommands: [Tester.self, CompileOnceTest.self],
      defaultSubcommand: Tester.self)
  }
}
