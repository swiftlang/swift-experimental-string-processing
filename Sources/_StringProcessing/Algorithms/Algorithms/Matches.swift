import _MatchingEngine

extension Regex {
  /// Prefixes this regex with `/.*?/`, effectively converting it into a
  /// pattern that searches for the first location of the match.
  fileprivate var searchingForFirst: Regex {
    let lazyManyAny: AST.Quantification = .init(
      .init(faking: .zeroOrMore),
      .init(faking: .reluctant),
      .atom(.init(.any, .fake)),
      .fake)
    return Regex(ast: .concatenation(
      .init([.quantification(lazyManyAny), regex.regex.ast], .fake)))
  }
}

/// A sequence of all the matches of a given regular expression.
public struct AllRegexMatches<Capture: MatchProtocol> {
  var input: String
  var range: Range<String.Index>
  var vm: Executor

  init(input: String, range: Range<String.Index>, regex: Regex<Capture>) {
    let ast = regex.searchingForFirst.ast
    
    self.input = input
    self.vm = .init(program: try! Compiler(ast: ast).emit())
    self.range = range
  }
}

extension AllRegexMatches: Sequence {
  public struct Iterator: IteratorProtocol {
    var input: String
    var nextRange: Range<String.Index>?
    var vm: Executor
    
    public mutating func next() -> RegexMatch<Capture>? {
      guard let nextRange = nextRange else {
        return nil
      }
    
      guard let result = vm.execute(
        input: input,
        in: nextRange,
        mode: .partialFromFront)
      else {
        self.nextRange = nil
        return nil
      }
    
      // FIXME: Decide on / implement advancing from empty range
      // Current behavior: If the previous match covered an empty range,
      // advance one position before searching again (otherwise the same
      // position keeps being found). If not empty, just start at the end of
      // the previous match.
      //
      // Perl takes a different strategy — if the previous match was an empty
      // range, it starts at the same position, but disallows empty matches.
      // This allows a different branch of an alternation or other different
      // approaches to match the second time, advancing through the matches.
      // See: https://www.regular-expressions.info/zerolength.html#advance
      if result.range.isEmpty {
        if result.range.upperBound < nextRange.upperBound {
          self.nextRange =
            input.index(after: result.range.upperBound) ..< nextRange.upperBound
        } else {
          self.nextRange = nil
        }
      } else {
        self.nextRange =
          result.range.upperBound ..< nextRange.upperBound
      }

      let (range, captures) = result.destructure
      return RegexMatch(
        range: range,
        match: captures.value as! Capture)
    }
  }
  
  public func makeIterator() -> Iterator {
    Iterator(input: input, nextRange: range, vm: vm)
  }
}

extension String {
  /// Returns a sequence of all the matches in this string for the given
  /// regular expression.
  public func allMatches<Capture: MatchProtocol>(_ regex: Regex<Capture>) -> AllRegexMatches<Capture> {
    AllRegexMatches(input: self, range: startIndex..<endIndex, regex: regex)
  }
  
  /// Returns the first match in this string for the given regular expression.
  public func firstMatch<Capture: MatchProtocol>(_ regex: Regex<Capture>) -> RegexMatch<Capture>? {
    var iterator = allMatches(regex).makeIterator()
    return iterator.next()
  }
}

extension Substring {
  public func allMatches<Capture: MatchProtocol>(_ regex: Regex<Capture>) -> AllRegexMatches<Capture> {
    AllRegexMatches(input: base, range: startIndex..<endIndex, regex: regex)
  }
  
  public func firstMatch<Capture: MatchProtocol>(_ regex: Regex<Capture>) -> RegexMatch<Capture>? {
    var iterator = allMatches(regex).makeIterator()
    return iterator.next()
  }
}
