import Util

/// A baby tortoise, to be spawned and march in lock-step with all the others
struct Hatchling {
  var core: RECode.ThreadCore
  var pc: InstructionAddress { return core.pc }

  init(_ pc: InstructionAddress, numCaptures: Int) {
    self.core = RECode.ThreadCore(startingAt: pc, numCaptures: numCaptures)
  }

  mutating func plod() { core.advance() }
  mutating func plod(to: InstructionAddress) { core.go(to: to) }

  mutating func beginCapture(
    _ id: CaptureId, _ sp: String.Index
  ) {
    core.beginCapture(id, sp)
  }
  mutating func endCapture(
    _ id: CaptureId, _ sp: String.Index
  ) {
    core.endCapture(id, sp)
  }
}

/// A group of hatchlings that march in lock-step
typealias Bale = [Hatchling]

public struct TortoiseVM: VirtualMachine {
  public static let motto = """
        "Slow and steady", which is a concise way of saying that tracking all
         eventualities ensures runtime linearly proportional to input size.
         Average case takes longer, but that's ok: tortoises have long lives.

        Approach: lock-step BFS

        Worst case time: O(n * m)
        Worst case space: O(m)
        """
  var code: RECode

  public init(_ code: RECode) {
    self.code = code
  }

  public func execute(input: String) -> (Bool, [CaptureStack]) {
    var bale = Bale()
    let startTurtle = Hatchling(code.startIndex, numCaptures: code.numCaptures)
    bale.append(contentsOf: readThrough(input.startIndex, startTurtle))
    for idx in input.indices {
      bale = advance(input, idx, bale)
    }
    for hatchling in bale {
      if .accept == code[hatchling.pc] {
        return (true, hatchling.core.captures)
      }
    }
    return (false, [])
  }
}

// TODO: Avoid infinite behavior from (a*)*. This happens because `readThrough`
//       tries to be overly-efficient. Since Bale size is bounded by the program
//       size, we can just unique based on pc.

extension TortoiseVM {
  // TODO: SmallVector-like struct, as almost always 1 or 2 length.
  func readThrough(_ sp: String.Index, _ hatchling: Hatchling) -> Bale {
    var result = Bale()

    var worklist = [hatchling]
    while !worklist.isEmpty {
      var hatchling = worklist.popLast()!
      while !code[hatchling.pc].isMatching {
        switch code[hatchling.pc] {
        case .nop: hatchling.plod()
        case .split(disfavoring: let other):
          var disfavoredHatchling = hatchling
          hatchling.plod()
          disfavoredHatchling.plod(to: code.lookup(other)+1) // read through label
          worklist.append(disfavoredHatchling)
        case .goto(label: let target):
          hatchling.plod(to: code.lookup(target)+1)
        case .label(_):
          hatchling.plod()
        case .beginCapture(let id):
          hatchling.beginCapture(id, sp)
          hatchling.plod()
        case .endCapture(let id):
          hatchling.endCapture(id, sp)
          hatchling.plod()

        default:
          fatalError("\(code[hatchling.pc]) should of been caught by !isMatching")
        }
      }
      result.append(hatchling)
    }
    return result
  }

  func advance(_ input: String, _ sp: String.Index, _ bale: Bale) -> Bale {
    var result = Bale()
    guard bale.all({ code[$0.pc].isMatching }) else {
      fatalError("should of been readThrough")
    }

    func advance(_ hatchling: inout Hatchling) {
      hatchling.plod()
      // TODO: this is double calculated
      let sp = input.index(after: sp)
      result.append(contentsOf: readThrough(sp, hatchling))
    }

    for hatchling in bale {
      var hatchling = hatchling
      switch code[hatchling.pc] {

      case .accept: break

      case .character(let c):
        guard input[sp] == c else { break }
        advance(&hatchling)

      case .characterClass(let cc):
        guard cc.matches(input[sp]) else { break }
        advance(&hatchling)

      case .any:
        advance(&hatchling)

      default: fatalError("should of been caught by isMatching")
      }
    }
    return result
  }
}
