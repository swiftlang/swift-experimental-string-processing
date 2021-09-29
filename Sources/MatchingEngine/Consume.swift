var checkComments = true

extension Engine {
  func createProcessor(_ input: Input) -> Processor<Input> {
    Processor(program, input, enableTracing: enableTracing)
  }

  public func consume(_ input: Input) -> Input.Index? {
    if enableTracing {
      print("Consume: \(input)")
    }

    var cpu = createProcessor(input)
    let result: Input.Index? = {
      while true {
        switch cpu.state {
        case .accept:
          return cpu.currentPosition
        case .fail:
          return nil
        case .inprogress: cpu.cycle()
        }
      }
    }()

    if enableTracing {
      if let idx = result {
        print("Result: \(input[..<idx]) | \(input[idx...])")
      } else {
        print("Result: nil")
      }
    }
    return result
  }
}

