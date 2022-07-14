import _StringProcessing

extension BenchmarkRunner {
  mutating func addDiceNotation() {
    // Matches the notation for dice rolls in tabletop games, ie: 2d6+1d10
    let diceRegex = #"(?:(?:\d+)?(?:d|D)(?:\d+)\+?)+"#
    let dice = CrossBenchmark(
      baseName: "DiceNotation",
      regex: diceRegex,
      input: Inputs.diceRollsInText
    )
    dice.register(&self)
  }
}
