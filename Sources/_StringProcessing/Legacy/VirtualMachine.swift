//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2021-2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import _MatchingEngine

protocol VirtualMachine {
  associatedtype Program

  /// The backend's motto and general life philosophy.
  static var motto: String { get }

  /// Creates a virtual machine.
  init(program: Program)

  /// Executes the program on the given input in the specified range.
  func execute(
    input: String,
    in range: Range<String.Index>,
    mode: MatchMode
  ) -> MatchResult?
}

extension VirtualMachine {
  /// Executes the program on the given input.
  func execute(
    input: String, mode: MatchMode = .wholeString
  ) -> MatchResult? {
    execute(
      input: input,
      in: input.startIndex..<input.endIndex,
      mode: mode)
  }
  func execute(
    input: Substring, mode: MatchMode = .wholeString
  ) -> MatchResult? {
    execute(
      input: input.base,
      in: input.startIndex ..< input.endIndex,
      mode: mode)
  }
}

extension RECode {
  /// A convenient VM thread "core" abstraction
  struct ThreadCore {
    enum CaptureState {
      case started(String.Index)
      case ended

      var isEnded: Bool {
        guard case .ended = self else {
          return false
        }
        return true
      }

      mutating func start(at index: String.Index) {
        assert(isEnded, "Capture already started")
        self = .started(index)
      }

      mutating func end(at endIndex: String.Index) -> Range<String.Index> {
        guard case let .started(startIndex) = self else {
          fatalError("Capture already ended")
        }
        self = .ended
        return startIndex..<endIndex
      }
    }
    var pc: InstructionAddress
    let input: String

    var groups = Stack<[Capture]>()
    var topLevelCaptures: [Capture] = []
    var captureState: CaptureState = .ended

    init(startingAt pc: InstructionAddress, input: String) {
      self.pc = pc
      self.input = input
    }

    mutating func advance() { self.pc = self.pc + 1 }
    mutating func go(to: InstructionAddress) { self.pc = to }

    public mutating func beginCapture(_ index: String.Index) {
      captureState.start(at: index)
    }

    /// Ends the current capture at the given index and applies the given
    /// transform if available. Returns true on success. Returns false if the
    /// trasnform failed.
    mutating func endCapture(
      _ endIndex: String.Index, transform: CaptureTransform?
    ) -> Bool {
      let range = captureState.end(at: endIndex)
      let substring = input[range]
      let value: Any
      if let transform = transform {
        guard let transformed = transform(substring) else {
          return false
        }
        value = transformed
      } else {
        value = substring
      }
      topLevelCaptures.append(.atom(value))
      return true
    }

    mutating func beginGroup() {
      groups.push(topLevelCaptures)
      topLevelCaptures = []
    }

    mutating func endGroup() {
      assert(!groups.isEmpty)
      var top = groups.pop()
      if !topLevelCaptures.isEmpty {
        top.append(singleCapture())
      }
      topLevelCaptures = top
    }

    mutating func captureNil(childType: AnyCaptureType) {
      topLevelCaptures = [.none(childType: childType)]
    }

    mutating func captureSome() {
      topLevelCaptures = [.some(.tupleOrAtom(topLevelCaptures))]
    }

    mutating func captureArray(childType: AnyCaptureType) {
      topLevelCaptures = [.array(topLevelCaptures, childType: childType)]
    }

    func singleCapture() -> Capture {
      .tupleOrAtom(topLevelCaptures)
    }
  }
}

struct Stack<T> {
  var stack: Array<T>

  init() { self.stack = [] }
  var isEmpty: Bool { return stack.isEmpty }

  mutating func pop() -> T {
    guard !isEmpty else { fatalError("stack is empty") }
    return stack.popLast()!
  }
  mutating func push(_ t: T) {
    stack.append(t)
  }
  func peek() -> T {
    guard !isEmpty else { fatalError("stack is empty") }
    return stack.last!
  }
}
