extension Benchmark {
  public func debug() {
    switch type {
    case .whole:
      let result = target.wholeMatch(of: regex)
      if let match = result {
        if match.0.count > 100 {
          print("- Match: len =  \(match.0.count)")
        } else {
          print("- Match: \(match.0)")
        }
      } else {
        print("- Warning: No match found")
      }
    case .allMatches:
      let results = target.matches(of: regex)
      if results.isEmpty {
        print("- Warning: No matches")
        return
      }
      
      print("- Total matches: \(results.count)")
      if results.count > 10 {
        print("# Too many matches, not printing")
        return
      }
      
      for match in results {
        if match.0.count > 100 {
          print("- Match: len =  \(match.0.count)")
        } else {
          print("- Match: \(match.0)")
        }
      }
    
    case .first:
      let result = target.firstMatch(of: regex)
      if let match = result {
        if match.0.count > 100 {
          print("- Match: len =  \(match.0.count)")
        } else {
          print("- Match: \(match.0)")
        }
      } else {
        print("- Warning: No match found")
        return
      }
    }
  }
}

extension NSBenchmark {
  public func debug() {
    switch type {
    case .allMatches:
      let results = regex.matches(in: target, range: range)
      if results.isEmpty {
        print("- Warning: No matches")
        return
      }
      
      print("- Total matches: \(results.count)")
      if results.count > 10 {
        print("# Too many matches, not printing")
        return
      }
      
      for m in results {
        if m.range.length > 100 {
          print("- Match: len =  \(m.range.length)")
        } else {
          print("- Match: \(target[Range(m.range, in: target)!])")
        }
      }
    case .first:
      let result = regex.firstMatch(in: target, range: range)
      if let match = result {
        if match.range.length > 100 {
          print("- Match: len =  \(match.range.length)")
        } else {
          print("- Match: \(target[Range(match.range, in: target)!])")
        }
      } else {
        print("- Warning: No match found")
        return
      }
    }
  }
}
