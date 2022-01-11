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

// Useful for testing, debugging, etc.
extension AST {
  func _postOrder() -> Array<AST> {
    var nodes = Array<AST>()
    _postOrder(into: &nodes)
    return nodes
  }
  func _postOrder(into array: inout Array<AST>) {
    children?.forEach { $0._postOrder(into: &array) }
    array.append(self)
  }

  // We render from top-to-bottom, coalescing siblings
  public func _render(in input: String) -> [String] {
    let base = String(repeating: " ", count: input.count)
    var lines = [base]

    // TODO: drop the filtering when fake-ness is taken out of
    // this module
    let nodes = _postOrder().filter(\.location.isReal)

    nodes.forEach { node in
      let loc = node.location
      let count = input[loc.range].count
      for idx in lines.indices {
        if lines[idx][loc.range].all(\.isWhitespace) {
          node._renderRange(count: count, into: &lines[idx])
          return
        }
      }
      var nextLine = base
      node._renderRange(count: count, into: &nextLine)
      lines.append(nextLine)
    }

    return lines.first!.all(\.isWhitespace) ? [] : lines
  }

  // Produce a textually "rendered" rane
  //
  // NOTE: `input` must be the string from which a
  // source range was derived.
  func _renderRange(
    count: Int, into output: inout String
  ) {
    guard count > 0 else { return }
    let repl = String(repeating: "-", count: count-1) + "^"
    output.replaceSubrange(location.range, with: repl)
  }
}
