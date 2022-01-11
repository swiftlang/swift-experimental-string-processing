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

import XCTest
@testable import Prototypes
import _MatchingEngine

enum Event: UInt64, Hashable {
  case authenticate = 0
  case authorize
  case use

  // Various paired operations
  case acquire
  case release

  case lock
  case unlock

  // Multi-phase and/or scoped operations
  case enterPhase1
  case enterPhase2
  case enterPhase3

  case exitPhase1
  case exitPhase2
  case exitPhase3


}


class PTCaRetTests: XCTestCase {
  typealias Formula = PTCaRet<Event>.Formula
  let enterPhase1 = Formula.event(.enterPhase1)
  let acquire = Formula.event(.acquire)
  let release = Formula.event(.release)

  func testHappensBefore() {



  }

  func testDirectCall() {
    // Function `f` can only be called directly by `g`
    //
    // call_f → @_c call_g
    //
    // Note: a beginSpecific would be clearer

    let f = Formula.implies(
      .callSpecific("F"),
      .atFunctionCall(.callSpecific("G")))

    _ = f

    // Function `f` can only be called directly or
    // indirectly by `g`, i.e. `g` must be somewhere on the
    // call stack.
    //
    //
    //
    // TODO: stackSometime()


  }

  func testAcquireRelease() {
    // A certain resource acquired during this function's
    // execution must be released by its end of execution.
    //
    // end → (¬acquire S̅ begin ∨ ¬(¬release S̅ acquire))
    let req = Formula.abstractRequirement(
        acquire, requiresEventually: release,
        since: .begin, triggeredBy: .end)

    _ = req

  }

  func testComplex() {


    /// From "Synthesizing Monitors for Safety Properties - This
    /// Time With Calls and Returns " by Rosu et al.
    ///
    /// Suppose that a program carries out a critical multi-phase task and
    /// the following safety properties must hold when execution enters the
    /// second phase:
    ///
    /// 1. Execution entered the first phase within the same procedure
    /// 2. Resource acquired within same procedure since first phase must be released
    /// 3. Caller of current procedure must have had approval for the second phase
    /// 4. Task is executed directly or indirectly by the procedure safe exec.


    let rule_1 = Formula.abstractSometime(
      enterPhase1, since: .begin)
    let rule_2 = Formula.or(
      .never(acquire, since: enterPhase1),
      .sometime(release, since: acquire))

    // TODO: ...
    (_, _) = (rule_1, rule_2)

  }


}
