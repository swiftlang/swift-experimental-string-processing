struct PrettyPrinter {
  var output = ""

  var indentation = 0
  var indentWidth = 2

  var startOfLine = true

  var maxTopDownLevels: Int?

  var minBottomUpLevels: Int?
}

extension PrettyPrinter {
  private var numCols: Int { indentation * indentWidth }
  private var header: String {
    startOfLine ? String(repeating: " ", count: numCols) : ""
  }

  // FIXME: track new line...
  mutating func print(_ s: String, terminate: Bool = true) {
    let terminator = terminate ? "\n" : ""
    output += "\(header)\(s)\(terminator)"
    startOfLine = terminate
  }
  mutating func printQuoted(
    _ s: String, terminate: Bool = true
  ) {
    print("\"\(s)\"", terminate: terminate)
  }

  /// If pattern printing should back off, prints the regex literal and returns true
  mutating func patternBackoff(_ ast: AST) -> Bool {
    if let max = maxTopDownLevels, indentation >= max {
      let canon = printAsCanonical(ast)
      print("'/\(canon)/'")
      return true
    }
    if let min = minBottomUpLevels, ast.height <= min {
      let canon = printAsCanonical(ast)
      print("'/\(canon)/'")
      return true
    }
    return false
  }

}

extension PrettyPrinter {
  mutating func indent(
    _ f: (inout Self) -> ()
  ) {
    self.indentation += 1
    f(&self)
    self.indentation -= 1
  }

  mutating func printBlock(
    _ header: String,
    startDelimiter: String = "{",
    endDelimiter: String = "}",
    _ f: (inout Self) -> ()
  ) {
    print("\(header) \(startDelimiter)")
    indent(f)
    print(endDelimiter)
  }
}
