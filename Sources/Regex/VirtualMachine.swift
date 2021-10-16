import Util

/// Object code for a regex program, to be interpreted by a VM
///
/// Consists of an instruction list and metadata tracking:
///   - Locations of labels (branch destinations)
///   - Locations of splits (branches)
///   - Total number of captures
///   - Various options (case-insensitive, etc)
///
public struct RECode {
  public typealias InstructionList = [Instruction]
  var instructions: InstructionList
  var labels: [InstructionAddress]
  var splits: [InstructionAddress]
  var numCaptures: Int
  var options: Options
}

extension RECode {
  /// A RECode instruction.
  public enum Instruction: Hashable {
    /// NOP (currently unused)
    case nop

    /// Denote a sucessful match. (currently used only at the end of a program)
    case accept

    /// Consume and try to match a unit of input
    case character(Character)

    /// Consume and try to match a unit of input against a character class
    case characterClass(CharacterClass)

    case unicodeScalar(UnicodeScalar)
    
    /// Consume any unit of input
    case any

    /// Split execution. Favored path will fall through while disfavored will branch to `disfavoring`
    case split(disfavoring: LabelId)

    /// Branch to `label`
    case goto(label: LabelId)

    /// The target of a branch, executed as a NOP
    case label(LabelId)

    /// Begin a numbered capture
    case beginCapture(CaptureId)

    /// End a numbered capture
    case endCapture(CaptureId)

    var isAccept: Bool {
      switch self {
      case .accept:
        return true
      default:
        return false
      }
    }
    
    // Future instructions
    //    case ratchet
    //    case peekAhead([CharacterClass])
    //    case peekBehind([CharacterClass])
  }
}

// Conveniences
extension RECode.Instruction {
  /// Fetch the label from a label instruction, else `nil`
  var label: LabelId? {
    guard case .label(let id) = self else { return nil }
    return id
  }

  /// Whether this instruction particpcates in matching
  var isMatching: Bool {
    switch self {
    case .accept: return true
    case .character(_): return true
    case .unicodeScalar(_): return true
    case .characterClass(_): return true
    case .any: return true
    default: return false
    }
  }

  /// Whether this instruction consumes the input
  var isConsuming: Bool {
    switch self {
    case .any: return true
    case .character(_): return true
    case .unicodeScalar(_): return true
    case .characterClass(_): return true
    default: return false
    }
  }

  // Convenience constructors
  static func beginCapture(_ i: Int) -> Self { .beginCapture(CaptureId(i)) }
  static func endCapture(_ i: Int) -> Self { .endCapture(CaptureId(i)) }

  static func label(_ i: Int) -> Self { .label(LabelId(i)) }
}

public struct Options: OptionSet {
  public let rawValue: Int

  public static var none = Options(rawValue: 0)
  public static var caseInsensitive = Options(rawValue: 1 << 0)
  // Future options
  //    ratcheting
  //    ??? partial
  //    ??? newlineTerminated

  public init() {
    self = .none
  }
  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
}

// RECode as a RAC of instructions. We might want to make this instead be
// `InstructionList` if that graduates from being an array.
extension RECode: RandomAccessCollection {
  public typealias Element = Instruction
  public typealias Index = InstructionAddress

  public var startIndex: Index { return Index(instructions.startIndex) }
  public var endIndex: Index { return Index(instructions.endIndex) }
  public subscript(_ i: Index) -> Element { return instructions[i.rawValue] }

  public func index(after i: Index) -> Index {
    return Index(i.rawValue + 1)
  }
  public func index(before i: Index) -> Index {
    return Index(i.rawValue - 1)
  }
  public func index(_ i: Index, offsetBy n: Int) -> Index {
    return Index(i.rawValue + n)
  }
}

extension RECode {
  public func withMatchLevel(_ level: CharacterClass.MatchLevel) -> RECode {
    var result = self
    result.instructions = result.instructions.map { inst in
      switch inst {
      case .characterClass(var cc):
        cc.matchLevel = level
        return .characterClass(cc)
      default:
        return inst
      }
    }
    return result
  }
}

extension RECode {
  /// Lookup the location of a label
  public func lookup(_ id: LabelId) -> InstructionAddress {
    let result = labels[id.rawValue]
    guard case .label(let lid) = self[result], lid == id else {
      fatalError("malformed program: labels not hooked up correctly")
    }
    return result
  }

  /// A convenient VM thread "core" abstraction
  public struct ThreadCore {
    public var pc: InstructionAddress
    public var captures: [CaptureStack]

    public init(startingAt pc: InstructionAddress, numCaptures: Int) {
      self.pc = pc
      self.captures = Array(repeating: CaptureStack(), count: numCaptures)
    }

    public mutating func advance() { self.pc = self.pc + 1 }
    public mutating func go(to: InstructionAddress) { self.pc = to }

    public mutating func beginCapture(
      _ id: CaptureId, _ sp: String.Index
    ) {
      captures[id.rawValue].beginCapture(sp)
    }
    public mutating func endCapture(
      _ id: CaptureId, _ sp: String.Index
    ) {
      captures[id.rawValue].endCapture(sp)
    }
  }
}

public struct Stack<T> {
  public var stack: Array<T>

  public init() { self.stack = [] }
  public var isEmpty: Bool { return stack.isEmpty }

  public mutating func pop() -> T {
    guard !isEmpty else { fatalError("stack is empty") }
    return stack.popLast()!
  }
  public mutating func push(_ t: T) {
    stack.append(t)
  }
  public func peek() -> T {
    guard !isEmpty else { fatalError("stack is empty") }
    return stack.last!
  }
}

/// Convenience abstraction for modeling a regex capture
///
/// Regex captures can exist inside quantifications, so they are ultimately a stack of captures
public struct CaptureStack {
  private static let sentinel = String.Index(encodedOffset: 8675309)

  public var stack: Stack<(String.Index, String.Index)>

  public init() { self.stack = Stack() }
  public mutating func beginCapture(_ idx: String.Index) {
    stack.push((idx, CaptureStack.sentinel))
  }
  public mutating func endCapture(_ idx: String.Index) {
    guard stack.peek().1 == CaptureStack.sentinel else {
      fatalError("Malformed stack: must pair begin and end captures")
    }
    let beginIdx = stack.pop().0
    stack.push((beginIdx, idx))
  }

  // Testing conveniences
  public func asSubstrings(from str: String) -> [Substring] {
    return stack.stack.map { str[$0.0..<$0.1] }
  }
  public func asStrings(from str: String) -> [String] {
    return stack.stack.map { str[$0.0..<$0.1] }.map { String($0) }
  }
}

/// VMs load RECode and run over Strings.
public protocol VirtualMachine {
  /// Declare this VM's motto and general life philosophy
  static var motto: String { get }

  /// Load some RECode and prepare to match
  init(_: RECode)

  /// Match `input`
  func execute(input: String) -> (Bool, [CaptureStack])
}

extension RECode.Instruction: CustomStringConvertible {
  public var description: String {
    switch self {
    case .nop: return "<NOP>"
    case .accept: return "<ACC>"
    case .any: return "<ANY>"
    case .characterClass(let kind): return "<CHAR CLASS \(kind)>"
    case .character(let c): return c.halfWidthCornerQuoted
    case .unicodeScalar(let u): return u.halfWidthCornerQuoted
    case .split(let i): return "<SPLIT disfavoring \(i)>"
    case .goto(let label): return "<GOTO \(label)>"
    case .label(let i): return "<\(i)>"
    case .beginCapture(let id): return "<CAP \(id)>"
    case .endCapture(let id): return "<END CAP \(id)>"
    }
  }
}

