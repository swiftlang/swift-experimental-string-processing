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

// Currently, engine binds the type and consume binds an instance.
// But, we can play around with this.
public struct Engine<Input: BidirectionalCollection> where Input.Element: Hashable {

  var program: Program<Input>

  // TODO: Pre-allocated register banks

  var instructions: InstructionList<Instruction> { program.instructions }

  var enableTracing: Bool {
    get { program.enableTracing }
    set { program.enableTracing = newValue }
  }

  public init(
    _ program: Program<Input>,
    enableTracing: Bool? = nil
  ) {
    var program = program
    if let t = enableTracing {
      program.enableTracing = t
    }
    self.program = program
  }
}

public struct AsyncEngine { /* ... */ }

extension Engine: CustomStringConvertible {
  public var description: String {
    // TODO: better description
    return program.description
  }
}
