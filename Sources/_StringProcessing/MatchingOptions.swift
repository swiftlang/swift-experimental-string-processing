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

/// A type that represents the current state of regex matching options, with
/// stack-based scoping.
struct MatchingOptions {
  /// A set of matching options. 
  fileprivate struct Representation: OptionSet, RawRepresentable {
    var rawValue: UInt32

    /// Options that comprise the mutually exclusive test segmentation group.
    static var textSegmentOptions: Self {
      Self(unchecked: .textSegmentGraphemeMode, .textSegmentWordMode)
    }

    /// Options that comprise the mutually exclusive semantic matching level
    /// group.
    static var semanticMatchingLevels: Self {
      Self(unchecked: .graphemeClusterSemantics, .unicodeScalarSemantics, .byteSemantics)
    }

    /// The default set of options.
    static var `default`: Self {
      Self(unchecked: .graphemeClusterSemantics, .textSegmentGraphemeMode)
    }

    func contains(_ kind: AST.MatchingOption.Kind) -> Bool {
      self.rawValue & (1 << kind.rawValue) != 0
    }
    
    /// Merges `sequence` with this option set, preserving the
    mutating func merge(with sequence: AST.MatchingOptionSequence) {
      if sequence.caretLoc != nil {
        self = .default
      }
      
      for opt in sequence.adding {
        // If opt is in one of the mutually exclusive groups, clear out the
        // group before inserting.
        if opt.isSemanticMatchingLevel {
          remove(.semanticMatchingLevels)
        }
        if opt.isTextSegmentMode {
          remove(.textSegmentOptions)
        }
        
        insert(.init(opt.kind))
      }
      for opt in sequence.removing {
        remove(.init(opt.kind))
      }
    }
  }

  fileprivate var stack: [Representation]
  
  fileprivate func _invariantCheck() {
    assert(!stack.isEmpty, "Unbalanced call to endScope")
  }
}

// Compiler API
extension MatchingOptions {
  /// Creates an instance with the default options.
  init() {
    self.stack = [.default]
  }

  mutating func beginScope() {
    stack.append(stack.last!)
  }
  
  mutating func endScope() {
    _ = stack.removeLast()
    _invariantCheck()
  }

  mutating func replaceCurrent(_ sequence: AST.MatchingOptionSequence) {
    stack[stack.count - 1].merge(with: sequence)
  }

  var isReluctantByDefault: Bool {
    stack.last!.contains(.reluctantByDefault)
  }
  
  var dotMatchesNewline: Bool {
    stack.last!.contains(.singleLine)
  }
  
  enum SemanticLevel {
    case graphemeCluster
    case unicodeScalar
    // TODO: include?
    // case byte
  }
  
  var semanticLevel: SemanticLevel {
    stack.last!.contains(.graphemeClusterSemantics)
      ? .graphemeCluster
      : .unicodeScalar
  }
}

// Deprecated CharacterClass.MatchLevel API
extension MatchingOptions {
  @available(*, deprecated)
  mutating func replaceMatchLevel(_ matchLevel: CharacterClass.MatchLevel) {
    var result = stack.last!
    result.remove(.semanticMatchingLevels)
    switch matchLevel {
    case .graphemeCluster:
      result.insert(.init(.graphemeClusterSemantics))
    case .unicodeScalar:
      result.insert(.init(.unicodeScalarSemantics))
    }
    stack[stack.count - 1] = result
  }
  
  @available(*, deprecated)
  var matchLevel: CharacterClass.MatchLevel {
    switch semanticLevel {
    case .graphemeCluster:
      return .graphemeCluster
    case .unicodeScalar:
      return .unicodeScalar
    }
  }
}

extension MatchingOptions.Representation {
  fileprivate init(_ kind: AST.MatchingOption.Kind) {
    self.rawValue = 1 << kind.rawValue
  }
  
  fileprivate init(unchecked kinds: AST.MatchingOption.Kind...) {
    self.rawValue = 0
    for kind in kinds {
      self.rawValue |= 1 << kind.rawValue
    }
  }
}
