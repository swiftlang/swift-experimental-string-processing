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
