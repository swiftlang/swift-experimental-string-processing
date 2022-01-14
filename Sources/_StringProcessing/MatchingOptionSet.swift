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
struct MatchingOptionSet: RawRepresentable {
  var rawValue: UInt32
}

extension MatchingOptionSet {
  init(_ kind: AST.MatchingOption.Kind) {
    self.rawValue = 1 << kind.rawValue
  }
  
  fileprivate init(unchecked kinds: AST.MatchingOption.Kind...) {
    self.rawValue = 0
    for kind in kinds {
      self.rawValue |= 1 << kind.rawValue
    }
  }

  fileprivate mutating func remove(_ kind: Self) {
    self.rawValue &= ~kind.rawValue
  }
  
  fileprivate mutating func insert(_ kind: Self) {
    self.rawValue |= kind.rawValue
  }

  fileprivate static var textSegmentOptions: Self {
    Self(unchecked: .textSegmentGraphemeMode, .textSegmentWordMode)
  }

  fileprivate static var semanticMatchingLevels: Self {
    Self(unchecked: .graphemeClusterSemantics, .unicodeScalarSemantics, .byteSemantics)
  }
}

// Compiler API
extension MatchingOptionSet {
  static var `default`: Self {
    Self(unchecked: .graphemeClusterSemantics, .textSegmentGraphemeMode)
  }

  func contains(_ kind: AST.MatchingOption.Kind) -> Bool {
    self.rawValue & (1 << kind.rawValue) != 0
  }
  
  func merging(_ sequence: AST.MatchingOptionSequence) -> MatchingOptionSet {
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
