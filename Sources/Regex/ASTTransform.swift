extension CharacterClass {
  public func withMatchLevel(
    _ level: CharacterClass.MatchLevel
  ) -> CharacterClass {
      var cc = self
      cc.matchLevel = level
      return cc
  }
}

