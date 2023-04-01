extension Processor {
  struct ProcessorMetrics {
    var instructionCounts: [Instruction.OpCode: Int] = [:]
    var backtracks: Int = 0
    var resets: Int = 0
    var cycleCount: Int = 0

    var isTracingEnabled: Bool = false
    var shouldMeasureMetrics: Bool = false
  }
  
  func printMetrics() {
    print("===")
    print("Total cycle count: \(metrics.cycleCount)")
    print("Backtracks: \(metrics.backtracks)")
    print("Resets: \(metrics.resets)")
    print("Instructions:")
    let sorted = metrics.instructionCounts
      .filter({$0.1 != 0})
      .sorted(by: { (a,b) in a.1 > b.1 })
    for (opcode, count) in sorted {
      print("> \(opcode): \(count)")
    }
    print("===")
  }

  mutating func measure() {
    let (opcode, _) = fetch().destructure
    if metrics.instructionCounts.keys.contains(opcode) {
      metrics.instructionCounts[opcode]! += 1
    } else {
      metrics.instructionCounts.updateValue(1, forKey: opcode)
    }
  }
  
  mutating func measureMetrics() {
    if metrics.shouldMeasureMetrics {
      measure()
    }
  }
}
