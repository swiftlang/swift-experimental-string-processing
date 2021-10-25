import Util

/// A baby tortoise, to be spawned and march in lock-step with all the others
struct Hatchling {
  var core: RECode.ThreadCore
  var pc: InstructionAddress { return core.pc }

  init(_ pc: InstructionAddress, input: Substring) {
    self.core = RECode.ThreadCore(startingAt: pc, input: input)
  }

  mutating func plod() { core.advance() }
  mutating func plod(to: InstructionAddress) { core.go(to: to) }
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

  public func execute(
    input: Substring, in range: Range<String.Index>, _ mode: MatchMode
  ) -> MatchResult? {
    let (start, end) = range.destructure

    var bale = Bale()
    let startTurtle = Hatchling(code.startIndex, input: input)
    bale.append(contentsOf: readThrough(start, startTurtle))
    var idx = start

    switch mode {
    case .wholeString:
      // Run over the whole string, updating our bale
      while idx < end {
        (bale, idx) = advance(input, idx, bale)
      }
    case .partialFromFront:
      // Run until we have no more hatchlings or we finish the string
      while idx < end && !bale.isEmpty {
        let (nextBale, nextIdx) = advance(input, idx, bale)
        if nextBale.isEmpty { break }
        idx = nextIdx
        bale = nextBale
      }
    }
    for hatchling in bale {
      if code[hatchling.pc].isAccept {
        return MatchResult(
          start ..< idx, hatchling.core.singleCapture())
      }
    }
    return nil
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
        case .beginCapture:
          hatchling.core.beginCapture(sp)
          hatchling.plod()
        case .endCapture(let transform):
          hatchling.core.endCapture(sp, transform: transform)
          hatchling.plod()
        case .beginGroup:
          hatchling.core.beginGroup()
          hatchling.plod()
        case .endGroup:
          hatchling.core.endGroup()
          hatchling.plod()
        case .captureSome:
          hatchling.core.captureSome()
          hatchling.plod()
        case .captureNil:
          hatchling.core.captureNil()
          hatchling.plod()
        case .captureArray:
          hatchling.core.captureArray()
          hatchling.plod()

        default:
          fatalError("\(code[hatchling.pc]) should of been caught by !isMatching")
        }
      }
      result.append(hatchling)
    }
    return result
  }

  func advance(_ input: Substring, _ sp: String.Index, _ bale: Bale) -> (Bale, String.Index) {
    var result = Bale()
    var nextPosition = input.index(after: sp)
    
    guard bale.all({ code[$0.pc].isMatching }) else {
      fatalError("should of been readThrough")
    }

    func advance(_ hatchling: inout Hatchling, to sp: String.Index) {
      hatchling.plod()
      // TODO: this is double calculated
      nextPosition = sp
      result.append(contentsOf: readThrough(nextPosition, hatchling))
    }

    func advance(_ hatchling: inout Hatchling) {
      advance(&hatchling, to: input.index(after: sp))
    }

    for hatchling in bale {
      var hatchling = hatchling
      switch code[hatchling.pc] {

      case .accept: break

      case .character(let c):
        guard input[sp] == c else { break }
        advance(&hatchling)

      case .unicodeScalar(let u):
        guard input.unicodeScalars[sp] == u else { break }
        advance(&hatchling, to: input.unicodeScalars.index(after: sp))

      case .characterClass(let cc):
        guard let nextSp = cc.matches(in: input, at: sp) else { break }
        advance(&hatchling, to: nextSp)

      case .any:
        advance(&hatchling)

      default: fatalError("should of been caught by isMatching")
      }
    }
    return (result, nextPosition)
  }
}
