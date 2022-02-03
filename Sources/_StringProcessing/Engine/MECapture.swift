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
    fileprivate var stack: Array<Range<Position>> = []

    // An in-progress capture start
    fileprivate var currentCaptureBegin: Position? = nil

    fileprivate func _invariantCheck() {
      if startState == nil {
        assert(stack.isEmpty)
        assert(currentCaptureBegin == nil)
      } else {
        assert(!stack.isEmpty || currentCaptureBegin != nil)
      }
    }

    // MARK: - IPI

    var isEmpty: Bool { stack.isEmpty }

    var history: Array<Range<Position>> {
      stack
    }

    var latest: Range<Position>? { stack.last }

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

      stack.append(currentCaptureBegin! ..< idx)
    }

    mutating func fail(truncatingAt stackIdx: Int) {
      _invariantCheck()
      assert(stackIdx <= stack.endIndex)
      defer { _invariantCheck() }

      stack.removeSubrange(stackIdx...)
      if stack.isEmpty {
        startState = nil
      }
    }
  }
}

public struct CaptureList {
  var caps: Array<Array<Range<String.Index>>>

  func extract(from s: String) -> Array<Array<Substring>> {
    caps.map { $0.map { s[$0] }  }
  }

  func latest(from s: String) -> Array<Substring?> {
    // TODO: If empty, probably need empty range or something...
    extract(from: s).map { $0.last }
  }
}
