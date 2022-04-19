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


extension PTCaRet {

  struct Interpreter {
    var state = 0
  }
}

/*

Consider making always/never/sometime etc., fundamental and
they get their own bit vectors, might be able to init and update
faster.

 */
