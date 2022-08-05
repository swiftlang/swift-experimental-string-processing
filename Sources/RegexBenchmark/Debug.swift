import Foundation

extension Benchmark {
  func debug() {
    switch type {
    case .whole:
      let result = target.wholeMatch(of: regex)
      if let match = result {
        if match.0.count > 1000 {
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
      if results.count > 100 {
        print("# Too many matches, not printing")
        let avgLen = results.map({result in String(target[result.range]).count})
          .reduce(0.0, {$0 + Double($1)}) / Double(results.count)
        print("Average match length = \(avgLen)")
        print("First match = \(String(target[results[0].range]))")
        return
      }
      
      for match in results {
        if match.0.count > 1000 {
          print("- Match: len =  \(match.0.count)")
        } else {
          print("- Match: \(match.0)")
        }
      }
    
    case .first:
      let result = target.firstMatch(of: regex)
      if let match = result {
        if match.0.count > 1000 {
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
  func debug() {
    switch type {
    case .allMatches:
      let results = regex.matches(in: target, range: range)
      if results.isEmpty {
        print("- Warning: No matches")
        return
      }
      
      print("- Total matches: \(results.count)")
      if results.count > 100 {
        print("# Too many matches, not printing")
        return
      }
      
      for m in results {
        if m.range.length > 1000 {
          print("- Match: len =  \(m.range.length)")
        } else {
          print("- Match: \(target[Range(m.range, in: target)!])")
        }
      }
    case .first:
      let result = regex.firstMatch(in: target, range: range)
      if let match = result {
        if match.range.length > 1000 {
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

extension InputListBenchmark {
  func debug() {
    var matched = 0
    var failed = 0
    for target in targets {
      if target.wholeMatch(of: regex) != nil {
        matched += 1
      } else {
        failed += 1
      }
    }
    print("- Matched \(matched) elements of the input set")
    print("- Failed to match \(failed) elements of the input set")
  }
}

extension InputListNSBenchmark {
  func debug() {
    var matched = 0
    var failed = 0
    for target in targets {
      let range = range(in: target)
      if regex.firstMatch(in: target, range: range) != nil {
        matched += 1
      } else {
        failed += 1
      }
    }
    print("- Matched \(matched) elements of the input set")
    print("- Failed to match \(failed) elements of the input set")
  }
}
