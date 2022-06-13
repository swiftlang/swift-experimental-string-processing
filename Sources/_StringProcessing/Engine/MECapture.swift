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

@_implementationOnly import _RegexParser

/*

 TODO: Specialized data structure for all captures:

 - We want to be able to refer to COW prefixes for which
   simple appends do not invalidate
 - We want a compact save-point representation

 TODO: Conjectures:

 - We should be able to remove the entire capture history,
   lazily recomputing it on-request from the initial stored
   save point
 - We should be able to keep these flat and simple, lazily
   constructing structured types on-request

 */


extension Processor {
  struct _StoredCapture {
    // Set whenever we push the very first capture, allows us
    // to theoretically re-compute anything we want to later.
    fileprivate var startState: SavePoint? = nil

    // Save the entire history as we go, so that backtracking
    // can just lop-off aborted runs.
    //
    // Backtracking entries can specify a per-capture stack
    // index so that we can abort anything that came after.
    //
    // By remembering the entire history, we waste space, but
    // we get flexibility for now.
    //
    fileprivate var history: Array<(range: Range<Position>, value: Any?)> = []

    // An in-progress capture start
    fileprivate var currentCaptureBegin: Position? = nil

    fileprivate func _invariantCheck() {
      if startState == nil {
        assert(history.isEmpty)
        assert(currentCaptureBegin == nil)
      } else if currentCaptureBegin == nil {
        assert(!history.isEmpty)
      }
    }

    // MARK: - IPI

    var isEmpty: Bool { history.isEmpty }

    var latest: (range: Range<Position>, value: Any?)? { history.last }

    /// Start a new capture. If the previously started one was un-ended,
    /// will clear it and restart. If this is the first start, will save `initial`.
    mutating func startCapture(
      _ idx: Position, initial: SavePoint
    ) {
      _invariantCheck()
      defer { _invariantCheck() }

      if self.startState == nil {
        self.startState = initial
      }
      currentCaptureBegin = idx
    }

    mutating func endCapture(_ idx: Position) {
      _invariantCheck()
      assert(currentCaptureBegin != nil)
      defer { _invariantCheck() }

      history.append((currentCaptureBegin! ..< idx, value: nil))
    }

    mutating func registerValue(
      _ value: Any,
      overwriteInitial: SavePoint? = nil
    ) {
      _invariantCheck()
      defer { _invariantCheck() }
      if let sp = overwriteInitial {
        self.startState = sp
      }
      history[history.endIndex - 1].value = value
    }

    mutating func fail(truncatingAt stackIdx: Int) {
      _invariantCheck()
      assert(stackIdx <= history.endIndex)
      defer { _invariantCheck() }

      history.removeSubrange(stackIdx...)
      if history.isEmpty {
        startState = nil
      }
    }
  }
}

extension Processor._StoredCapture: CustomStringConvertible {
  var description: String {
    return String(describing: history)
  }
}

struct MECaptureList {
  var values: Array<Processor<String>._StoredCapture>
  var referencedCaptureOffsets: [ReferenceID: Int]

  func latestUntyped(from input: String) -> Array<Substring?> {
    values.map {
      guard let last = $0.latest else {
        return nil
      }
      return input[last.0]
    }
  }
}
