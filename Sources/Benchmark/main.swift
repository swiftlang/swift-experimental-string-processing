//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import Foundation
import Dispatch
import _StringProcessing

extension Executor {
  func _firstMatch(
    _ regex: String, input: String
  ) throws -> (match: Substring, captures: CaptureList) {
    // TODO: This should be a CollectionMatcher API to call...
    // Consumer -> searcher algorithm
    var start = input.startIndex
    while true {
      if let (range, caps) = self.executeFlat(
        input: input,
        in: start..<input.endIndex,
        mode: .partialFromFront
      ) {
        let matched = input[range]
        return (matched, caps)
      } else if start == input.endIndex {
        throw "match not found for \(regex) in \(input)"
      } else {
        input.formIndex(after: &start)
      }
    }
  }
}

@inline(never)
func identity<T>(_ t: T) -> T {
  t
}

@inline(never)
func getString(_ t: String) -> String {
  t
}

@inline(never)
func blackHole(_ x: Bool) {}

@inline(never)
func blackHole(_ x: String) {}

@inline(never)
func blackHole<T>(_ x: T) {}

@inline(never)
func blackHole(_ x: Int) {}

func time<T>(_ _caller : String = #function, _ block: () throws -> T) rethrows -> T {
  let start = DispatchTime.now()
  let res = try block()
  let end = DispatchTime.now()
  let realN = UInt64(N)
  let nanoseconds = (end.uptimeNanoseconds - start.uptimeNanoseconds) / realN
  let microseconds = (end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000 / realN
  let milliseconds = (end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000 / realN
  print("\(_caller)\tms: \(milliseconds), us: \(microseconds), ns: \(nanoseconds)")
  return res
}

let N = 10000

func nativeMatch(
  _ regex: String,
  input: String
) throws -> (match: Substring, captures: CaptureList) {
  let executor = try _compileRegex(regex)
  return try executor._firstMatch(regex, input: input)
}

func nsregexMatch(
  _ regex: String,
  input: String
) throws -> NSTextCheckingResult? {
  let nsregex = try NSRegularExpression(pattern: regex)
  let range = input.startIndex ..< input.endIndex
  return nsregex.firstMatch(in: input, range: NSRange(range, in: input))
}

print("Simple match: '.*' in 'hello world'")

@inline(never)
func run_simple_native(_ N: Int) throws {
  for _ in 0 ..< N {
    let match = try nativeMatch(".*", input: "hello world")
    
    blackHole(match)
  }
}

@inline(never)
func run_simple_nsregex(_ N: Int) throws {
  for _ in 0 ..< N {
    let match = try nsregexMatch(".*", input: "hello world")
    
    blackHole(match)
  }
}

try time("Native #1") {
  try run_simple_native(N)
}

try time("NSRegex #2") {
  try run_simple_nsregex(N)
}

print()
print(#"Simple Unicode match: '\u00e9' in 'Café'"#)

@inline(never)
func run_simple_unicode_native(_ N: Int) throws {
  for _ in 0 ..< N {
    let match = try nativeMatch(#"\u00e9"#, input: "Café")
    
    blackHole(match)
  }
}

@inline(never)
func run_simple_unicode_nsregex(_ N: Int) throws {
  for _ in 0 ..< N {
    let match = try nsregexMatch(#"\u00e9"#, input: "Café")
    
    blackHole(match)
  }
}

try time("Native #3") {
  try run_simple_unicode_native(N)
}

try time("NSRegex #4") {
  try run_simple_unicode_nsregex(N)
}

print()
print("Simple alternation match: 'abc(?:de)+fghi*k|j' in '123abcdedefghkxyz'")

@inline(never)
func run_simple_alternation_native(_ N: Int) throws {
  for _ in 0 ..< N {
    let match = try nativeMatch("abc(?:de)+fghi*k|j", input: "123abcdedefghkxyz")
    
    blackHole(match)
  }
}

@inline(never)
func run_simple_alternation_nsregex(_ N: Int) throws {
  for _ in 0 ..< N {
    let match = try nsregexMatch("abc(?:de)+fghi*k|j", input: "123abcdedefghkxyz")
    
    blackHole(match)
  }
}

try time("Native #5") {
  try run_simple_alternation_native(N)
}

try time("NSRegex #6") {
  try run_simple_alternation_nsregex(N)
}

print()
print(#"Simple quote match: 'a\Q \Q \\.\Eb' in '123a \Q \\.bxyz'"#)

@inline(never)
func run_simple_quotes_native(_ N: Int) throws {
  for _ in 0 ..< N {
    let match = try nativeMatch(#"a\Q \Q \\.\Eb"#, input: #"123a \Q \\.bxyz"#)
    
    blackHole(match)
  }
}

@inline(never)
func run_simple_quotes_nsregex(_ N: Int) throws {
  for _ in 0 ..< N {
    let match = try nsregexMatch(#"a\Q \Q \\.\Eb"#, input: #"123a \Q \\.bxyz"#)
    
    blackHole(match)
  }
}

try time("Native #7") {
  try run_simple_quotes_native(N)
}

try time("NSRegex #8") {
  try run_simple_quotes_nsregex(N)
}

print()
print(#"Simple character name match: '\N{ASTERISK}' in '123***xyz'"#)

@inline(never)
func run_simple_character_name_native(_ N: Int) throws {
  for _ in 0 ..< N {
    let match = try nativeMatch(#"\N{ASTERISK}"#, input: "123***xyz")
    
    blackHole(match)
  }
}

@inline(never)
func run_simple_character_name_nsregex(_ N: Int) throws {
  for _ in 0 ..< N {
    let match = try nsregexMatch(#"\N{ASTERISK}"#, input: "123***xyz")
    
    blackHole(match)
  }
}

try time("Native #9") {
  try run_simple_character_name_native(N)
}

try time("NSRegex #10") {
  try run_simple_character_name_nsregex(N)
}

print()
print(#"Simple script match: '\P{Script=Latn}' in 'abcαβγxyz'"#)

@inline(never)
func run_simple_script_native(_ N: Int) throws {
  for _ in 0 ..< N {
    let match = try nativeMatch(#"\P{Script=Latn}"#, input: "abcαβγxyz")
    
    blackHole(match)
  }
}

@inline(never)
func run_simple_script_nsregex(_ N: Int) throws {
  for _ in 0 ..< N {
    let match = try nsregexMatch(#"\P{Script=Latn}"#, input: "abcαβγxyz")
    
    blackHole(match)
  }
}

try time("Native #11") {
  try run_simple_script_native(N)
}

try time("NSRegex #12") {
  try run_simple_script_nsregex(N)
}

print()
print(#"Simple group match: '(?:a|.b)c' in '123abcxyz'"#)

@inline(never)
func run_simple_group_native(_ N: Int) throws {
  for _ in 0 ..< N {
    let match = try nativeMatch(#"(?:a|.b)c"#, input: "123abcxyz")
    
    blackHole(match)
  }
}

@inline(never)
func run_simple_group_nsregex(_ N: Int) throws {
  for _ in 0 ..< N {
    let match = try nsregexMatch(#"(?:a|.b)c"#, input: "123abcxyz")
    
    blackHole(match)
  }
}

try time("Native #13") {
  try run_simple_group_native(N)
}

try time("NSRegex #14") {
  try run_simple_group_nsregex(N)
}

print()
print(#"Simple comment match: 'a(?#. comment)b' in '123abcxyz'"#)

@inline(never)
func run_simple_comment_native(_ N: Int) throws {
  for _ in 0 ..< N {
    let match = try nativeMatch(#"a(?#. comment)b"#, input: "123abcxyz")
    
    blackHole(match)
  }
}

@inline(never)
func run_simple_comment_nsregex(_ N: Int) throws {
  for _ in 0 ..< N {
    let match = try nsregexMatch(#"a(?#. comment)b"#, input: "123abcxyz")
    
    blackHole(match)
  }
}

try time("Native #15") {
  try run_simple_comment_native(N)
}

try time("NSRegex #16") {
  try run_simple_comment_nsregex(N)
}

print()
print("Regex Redux (Benchmark Game)")

time("NSRegex #17") {
  nsregexRedux()
}
