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
struct Engine {

  let program: MEProgram

  // TODO: Pre-allocated register banks

  var instructions: InstructionList<Instruction> { program.instructions }

  var enableTracing: Bool { program.enableTracing }
  var enableMetrics: Bool { program.enableMetrics }

  init(_ program: MEProgram) {
    self.program = program
  }
}

struct AsyncEngine { /* ... */ }

extension Engine: CustomStringConvertible {
  var description: String {
    // TODO: better description
    return program.description
  }
}
