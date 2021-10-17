public enum MatchMode {
  case wholeString
  case partialFromFront
}

public struct MatchResult {
  public var matched: Range<String.Index>
  public var captures: [CaptureStack]

  public var destructure: (
    matched: Range<String.Index>, captures: [CaptureStack]
  ) {
    (matched, captures)
  }

  public init(
    _ matched: Range<String.Index>, _ captures: [CaptureStack]
  ) {
    self.matched = matched
    self.captures = captures
  }
}

/// VMs load RECode and run over Strings.
public protocol VirtualMachine {
  /// Declare this VM's motto and general life philosophy
  static var motto: String { get }

  /// Load some RECode and prepare to match
  init(_: RECode)

  /// Match `input`
  func execute(input: String, in range: Range<String.Index>, _ mode: MatchMode) -> MatchResult?
}

extension VirtualMachine {
  /// Match `input`
  public func execute(
    input: String, _ mode: MatchMode = .wholeString
  ) -> MatchResult? {
    execute(input: input, in: input.startIndex..<input.endIndex, mode)
  }
}

import Util

extension RECode {
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

