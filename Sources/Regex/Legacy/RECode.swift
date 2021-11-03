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
  var options: REOptions
}

extension RECode {
  /// A RECode instruction.
  public enum Instruction: Hashable {
    /// NOP (currently unused).
    case nop

    /// Denote a sucessful match. (currently used only at the end of a program).
    case accept

    /// Consume and try to match a unit of input.
    case character(Character)

    /// Consume and try to match a unit of input against a character class.
    case characterClass(CharacterClass)

    case unicodeScalar(UnicodeScalar)

    /// Consume any unit of input
    case any

    /// Split execution. Favored path will fall through while disfavored will branch to
    /// `disfavoring`.
    case split(disfavoring: LabelId)

    /// Branch to `label`.
    case goto(label: LabelId)

    /// The target of a branch, executed as a NOP.
    case label(LabelId)

    /// Begin a capture group.
    case beginGroup

    /// Ends a capture group.
    case endGroup

    /// Begin capturing a portion of the input string.
    case beginCapture

    /// End capturing a portion of the input string, transforming the substring with the specified
    /// transform.
    case endCapture(transform: CaptureTransform? = nil)

    /// Form a `Capture.optional(.some(...))` from top-level captures, and use it to replace the
    /// top-level captures.
    case captureSome

    /// Replace top-level captures with a single `Capture.optional(nil)`.
    case captureNil

    /// Form a `Capture.array(...)` from top-level captures, and use it to replace the top-level
    /// captures.
    case captureArray

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
  static func label(_ i: Int) -> Self { .label(LabelId(i)) }
}

public struct REOptions: OptionSet {
  public let rawValue: Int

  public static var none = REOptions(rawValue: 0)
  public static var caseInsensitive = REOptions(rawValue: 1 << 0)
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
  /// Lookup the location of a label
  public func lookup(_ id: LabelId) -> InstructionAddress {
    let result = labels[id.rawValue]
    guard case .label(let lid) = self[result], lid == id else {
      fatalError("malformed program: labels not hooked up correctly")
    }
    return result
  }
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
    case .beginGroup: return "<BEGIN GROUP>"
    case .endGroup: return "<END GROUP>"
    case .beginCapture: return "<BEGIN CAP>"
    case .endCapture: return "<END CAP>"
    case .captureSome: return "<CAP SOME>"
    case .captureNil: return "<CAP NIL>"
    case .captureArray: return "<CAP ARRAY>"
    }
  }
}
