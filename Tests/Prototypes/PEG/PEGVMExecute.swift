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

extension PEG.VM {

  // TODO: Consumers need a concept of forward progress.
  // They can return `nil` and `startIndex`, both which may
  // have the same effect for many API, but others might wish
  // to differentiate it. We should think through this issue
  // and likely make forward progress a more established
  // concept.

  func consume(_ input: Input) -> Input.Index? {
    var core = Core(
      instructions, input, enableTracing: enableTracing)
    while true {
      switch core.state {
      case .accept: return core.current.pos
      case .fail: return nil
      case .processing: core.cycle()
      }
    }
  }
}

extension PEG {
  public struct Consumer<Input: Collection> where Input.Element == Element {
    var vm: PEG.VM<Input>

    public func consume(_ input: Input) -> Input.Index? {
      vm.consume(input)
    }
  }
}
