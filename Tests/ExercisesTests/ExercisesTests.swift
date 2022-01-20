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

import Exercises
import XCTest

//extension String: Error {}

let doPrint = false//true
func output<S: ExpressibleByStringInterpolation>(_ s: S) {
  if doPrint { print(s) }
}

class ExercisesTests: XCTestCase {
  func testAll() {

    // MARK: - Grapheme break properties
    output("Grapheme break properties")
    let reference = try! Exercises.referenceParticipant.graphemeBreakProperty()
    for participant in Exercises.allParticipants {
      let outputHeader = "  - \(participant.name): " // TODO: pad name...
      guard let f = try? participant.graphemeBreakProperty() else {
        output("\(outputHeader)unsupported")
        continue
      }

      var pass = true
      for line in graphemeBreakData.split(separator: "\n") {
        let line = String(line)
        let ref = reference(line)
        let result = f(line)
        guard ref == result else {
          pass = false
          XCTFail("""
            Participant \(participant.name) failed
            - Input: \(line)
            - Expected: \(String(describing: ref))
            - Result: \(String(describing: result))
            """)
          break
        }
      }
      output("\(outputHeader)\(pass ? "pass" : "FAIL")")
    }

  }

}
