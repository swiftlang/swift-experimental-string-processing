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
  mutating func addDiceNotation() {
    // Matches the notation for dice rolls in tabletop games, ie: 2d6+1d10
    let diceRegex = #"(?:(?:\d+)?(?:d|D)(?:\d+)\+?)+"#
    let dice = CrossBenchmark(
      baseName: "DiceRollsInText",
      regex: diceRegex,
      input: Inputs.diceRollsInText
    )
    let diceList = CrossInputListBenchmark(
      baseName: "DiceNotation",
      regex: diceRegex,
      inputs: Inputs.diceRolls
    )
    diceList.register(&self)
    dice.register(&self)
  }
}
