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

/// A set of matching options.
public struct MatchingOptionSet: OptionSet {
  public var rawValue: UInt32

  public init(rawValue: UInt32) {
    self.rawValue = rawValue
  }

  public init(_ kind: AST.MatchingOption.Kind) {
    self.rawValue = 1 << kind.rawValue
  }

  public static var `default`: Self {
    [.graphemeClusterSemantics, .textSegmentGraphemeMode]
  }

  // PCRE options
  public static var caseInsensitive: Self { .init(.caseInsensitive) }
  public static var allowDuplicateGroupNames: Self { .init(.allowDuplicateGroupNames) }
  public static var multiline: Self { .init(.multiline) }
  public static var noAutoCapture: Self { .init(.noAutoCapture) }
  public static var singleLine: Self { .init(.singleLine) }
  public static var reluctantByDefault: Self { .init(.reluctantByDefault) }
  public static var extended: Self { .init(.extended) }
  public static var extraExtended: Self { .init(.extraExtended) }

  // ICU options
  public static var unicodeWordBoundaries: Self { .init(.unicodeWordBoundaries) }

  // Oniguruma options
  public static var asciiOnlyDigit: Self { .init(.asciiOnlyDigit) }
  public static var asciiOnlyPOSIXProps: Self { .init(.asciiOnlyPOSIXProps) }
  public static var asciiOnlySpace: Self { .init(.asciiOnlySpace) }
  public static var asciiOnlyWord: Self { .init(.asciiOnlyWord) }

  // Oniguruma text segment options (these are mutually exclusive and cannot
  // be unset, only flipped between)
  public static var textSegmentGraphemeMode: Self { .init(.textSegmentGraphemeMode) }
  public static var textSegmentWordMode: Self { .init(.textSegmentWordMode) }

  public static var textSegmentOptions: Self {
    [.textSegmentGraphemeMode, .textSegmentWordMode]
  }

  // Swift semantic matching level
  public static var graphemeClusterSemantics: Self { .init(.graphemeClusterSemantics) }
  public static var unicodeScalarSemantics: Self { .init(.unicodeScalarSemantics) }
  public static var byteSemantics: Self { .init(.byteSemantics) }

  public static var semanticMatchingLevels: Self {
    [.graphemeClusterSemantics, .unicodeScalarSemantics, .byteSemantics]
  }
}

extension MatchingOptionSet {
  public func merging(_ sequence: AST.MatchingOptionSequence) -> MatchingOptionSet {
    var result = self
    for opt in sequence.adding {
      if opt.isSemanticMatchingLevel {
        result.remove(.semanticMatchingLevels)
      }
      if opt.isTextSegmentMode {
        result.remove(.textSegmentOptions)
      }
      
      result.insert(.init(opt.kind))
    }
    for opt in sequence.removing {
      result.remove(.init(opt.kind))
    }
    return result
  }
}

/// A never-empty stack of `MatchingOptionSet`s.
struct MatchingOptionSetStack {
  var stack: [MatchingOptionSet]
  
  init(_ initial: MatchingOptionSet) {
    self.stack = [initial]
  }

  private func _invariantCheck() {
    assert(!stack.isEmpty, "Unbalanced matching options pop")
  }
  
  var top: MatchingOptionSet {
    _invariantCheck()
    return stack.last!
  }
  
  mutating func push(_ set: MatchingOptionSet) {
    stack.append(set)
  }
  
  mutating func replaceTop(_ set: MatchingOptionSet) {
    _invariantCheck()
    stack.removeLast()
    stack.append(set)
  }
  
  @discardableResult
  mutating func pop() -> MatchingOptionSet {
    let result = stack.removeLast()
    _invariantCheck()
    return result
  }
}
