extension Processor {
  struct ProcessorMetrics {
    var instructionCounts: [Int] = .init(repeating: 0, count: Instruction.OpCode.allCases.count)
    var caseInsensitiveInstrs: Bool = false
  }
  
  func printMetrics() {
    // print("Total cycle count: \(cycleCount)")
    // print("Instructions:")
    let sorted = metrics.instructionCounts.enumerated()
      .filter({$0.1 != 0})
      .sorted(by: { (a,b) in a.1 > b.1 })
    for (opcode, count) in sorted {
      print("\(Instruction.OpCode.init(rawValue: UInt64(opcode))!),\(count)")
    }
  }
  
  mutating func measureMetrics() {
    if shouldMeasureMetrics {
      let (opcode, _) = fetch().destructure
      metrics.instructionCounts[Int(opcode.rawValue)] += 1
    }
  }
}
