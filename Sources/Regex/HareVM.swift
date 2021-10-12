import Util

/// A baby hare, to be spawned and sent down rabbit holes in search of a match
struct Leveret {
  var core: RECode.ThreadCore
  var sp: String.Index
  var pc: InstructionAddress { return core.pc }

  init(_ pc: InstructionAddress, _ sp: String.Index, numCaptures: Int) {
    self.core = RECode.ThreadCore(startingAt: pc, numCaptures: numCaptures)
    self.sp = sp
  }

  mutating func hop() { core.advance() }

  mutating func hop(to: InstructionAddress) { core.go(to: to) }

  mutating func nibble(on str: String) { sp = str.index(after: sp) }

  mutating func beginCapture(_ id: CaptureId) {
    core.beginCapture(id, sp)
  }
  mutating func endCapture(_ id: CaptureId) {
    core.endCapture(id, sp)
  }
}

/// Manage the progeny. This is our thread-stack.
///
/// "Bunny" is a valid term for a hare, as best exemplified by the Easter Bunny, who is a hare
struct BunnyStack {
  private var stack = Stack<Leveret>()

  var isEmpty: Bool { return stack.isEmpty }
  mutating func save(_ l: Leveret) {
    stack.push(l)
  }
  mutating func restore() -> Leveret {
    return stack.pop()
  }
}

public struct HareVM: VirtualMachine {
  public static let motto = """
        "Gotta go fast", which is a concise way of saying that by proceeding
        with the most optimistic of assumptions, matching happens very fast in
        average, common cases. However, hares have the tendency to become over-
        confident in their swiftness and chase too far down the wrong rabbit
        hole.

        Approach: Naive backtracking DFS

        Worst case time: exponential (is it O(n * 2^m) or O(2^n)?)
        Worst case space: O(n + m)
        """
  var code: RECode

  public init(_ code: RECode) {
    self.code = code
  }

  public func execute(input: String) -> (Bool, [CaptureStack]) {
    assert(code.last!.isAccept)
    var bunny = Leveret(
      code.startIndex, input.startIndex, numCaptures: code.numCaptures)
    var stack = BunnyStack()

    while true {
      let inst = code[bunny.pc]

      // Consuming operations require more input
      guard bunny.sp < input.endIndex || !inst.isConsuming else {
        // If there are no more alternatives to try, we failed
        guard !stack.isEmpty else { return (false, []) }

        // Continue with the next alternative
        bunny = stack.restore()
        continue
      }

      switch code[bunny.pc] {
      case .nop: bunny.hop()
      case .accept:
        // If we've matched all of our input, we're done
        if bunny.sp == input.endIndex {
          return (true, bunny.core.captures)
        }
        // If there are no more alternatives to try, we failed
        guard !stack.isEmpty else {
          return (false, [])
        }

        // Continue with the next alternative
        bunny = stack.restore()

      case .any:
        assert(bunny.sp < input.endIndex)
        bunny.nibble(on: input)
        bunny.hop()

      case .character(let c):
        assert(bunny.sp < input.endIndex)
        guard input[bunny.sp] == c else {
          // If there are no more alternatives to try, we failed
          guard !stack.isEmpty else {
            return (false, [])
          }

          // Continue with the next alternative
          bunny = stack.restore()
          continue
        }
        bunny.nibble(on: input)
        bunny.hop()

      case .characterClass(let cc):
        assert(bunny.sp < input.endIndex)
        guard cc.matches(input[bunny.sp]) else {
          // If there are no more alternatives to try, we failed
          guard !stack.isEmpty else {
            return (false, [])
          }

          // Continue with the next alternative
          bunny = stack.restore()
          continue
        }
        bunny.nibble(on: input)
        bunny.hop()

      case .split(let disfavoring):
        var disfavoredBunny = bunny
        disfavoredBunny.hop(to: code.lookup(disfavoring))
        stack.save(disfavoredBunny)
        bunny.hop()

      case .goto(let label):
        bunny.hop(to: code.lookup(label))

      case .label(_):
        bunny.hop()

      case .beginCapture(let id):
        bunny.beginCapture(id)
        bunny.hop()

      case .endCapture(let id):
        bunny.endCapture(id)
        bunny.hop()
      }
    }
  }
}
