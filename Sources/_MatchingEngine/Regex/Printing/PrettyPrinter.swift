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

/// Track and handle state relevant to pretty-printing ASTs.
struct PrettyPrinter {
  // Configuration

  /// Cut off pattern conversion after this many levels
  var maxTopDownLevels: Int?

  /// Cut off pattern conversion after this tree height
  var minBottomUpLevels: Int?

  /// How many spaces to indent with ("tab-width")
  var indentWidth = 2

  // Internal state

  // The output string we're building up
  fileprivate var result = ""

  // Whether next print needs to indent
  fileprivate var startOfLine = true

  // The indentation level
  fileprivate var indentLevel = 0
}

// MARK: - Raw interface
extension PrettyPrinter {
  // This might be necessary if `fileprivate` above suppresses
  // default struct inits.
  init(
    maxTopDownLevels: Int? = nil,
    minBottomUpLevels: Int? = nil
  ) {
    self.maxTopDownLevels = maxTopDownLevels
    self.minBottomUpLevels = minBottomUpLevels
  }

  /// Output a string directly, without termination, without
  /// indentation, and without updating _any_ internal state.
  ///
  /// This is the low-level interface to the pret
  ///
  /// NOTE: If `s` includes a newline, even at the end,
  /// this function will not update any tracking state.
  mutating func output(_ s: String) {
    result += s
  }

  /// Terminate a line, updating any relevant state
  mutating func terminateLine() {
    output("\n")
    startOfLine = true
  }

  /// Indent a new line, if at the start of a line, otherwise
  /// does nothing. Updates internal state.
  mutating func indent() {
    guard startOfLine else { return }
    let numCols = indentLevel * indentWidth
    output(String(repeating: " ", count: numCols))
    startOfLine = false
  }

  // Finish, flush, and clear. Returns the rendered output
  mutating func finish() -> String {
    defer { result = "" }
    return result
  }

  var depth: Int { indentLevel }
}

// MARK: - Pretty-print interface
extension PrettyPrinter {
  /// Print out a new entry.
  ///
  /// This will property indent `s`, update any internal state,
  /// and will also terminate the current line.
  mutating func print(_ s: String) {
    indent()
    output("\(s)")
    terminateLine()
  }

  /// Print out a new entry by invoking `f` until it returns `nil`.
  ///
  /// This will property indent, update any internal state,
  /// and will also terminate the current line.
  mutating func printLine(_ f: () -> String?) {
    // TODO: What should we do if `f` never returns non-nil?
    indent()
    while let s = f() {
      output(s)
    }
    terminateLine()
  }

  /// Execute `f` at one increased level of indentation
  mutating func printIndented(
    _ f: (inout Self) -> ()
  ) {
    self.indentLevel += 1
    f(&self)
    self.indentLevel -= 1
  }

  /// Execute `f` inside an indented "block", which has a header
  /// and delimiters.
  mutating func printBlock(
    _ header: String,
    startDelimiter: String = "{",
    endDelimiter: String = "}",
    _ f: (inout Self) -> ()
  ) {
    print("\(header) \(startDelimiter)")
    printIndented(f)
    print(endDelimiter)
  }
}
