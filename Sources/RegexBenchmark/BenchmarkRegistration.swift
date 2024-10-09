// This file has lines generated by createBenchmark.py
// Do not remove the start of registration or end of registration markers

extension BenchmarkRunner {
  mutating func registerDefault() {
    // -- start of registrations --
    self.addReluctantQuant()
    self.addCSS()
    self.addNotFound()
    self.addGraphemeBreak()
    self.addHangulSyllable()
    // self.addHTML() // Disabled due to \b being unusably slow
    self.addEmail()
    self.addCustomCharacterClasses()
    self.addBuiltinCC()
    self.addUnicode()
    self.addLiteralSearch()
    self.addDiceNotation()
    self.addErrorMessages()
    self.addIpAddress()

    self.addURL()
    // -- end of registrations --
  }
}
