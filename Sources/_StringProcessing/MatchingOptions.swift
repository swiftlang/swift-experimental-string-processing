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
  fileprivate var stack: [Representation]
  
  fileprivate func _invariantCheck() {
    assert(!stack.isEmpty, "Unbalanced call to endScope")
    
    // Must contain exactly one of each mutually exclusive group
    assert(stack.last!.intersection(.textSegmentOptions).rawValue.nonzeroBitCount == 1)
    assert(stack.last!.intersection(.semanticMatchingLevels).rawValue.nonzeroBitCount == 1)
  }
}

// MARK: Compilation API
extension MatchingOptions {
  /// Creates an instance with the default options.
  init() {
    self.stack = [.default]
    _invariantCheck()
  }

  /// Starts a new scope with the current options.
  mutating func beginScope() {
    stack.append(stack.last!)
    _invariantCheck()
  }
  
  /// Ends the current scope.
  mutating func endScope() {
    _ = stack.removeLast()
    _invariantCheck()
  }

  /// Updates the options in the current scope with the changes described by
  /// `sequence`.
  mutating func apply(_ sequence: AST.MatchingOptionSequence) {
    stack[stack.count - 1].apply(sequence)
    _invariantCheck()
  }
}

// MARK: Matching behavior API
extension MatchingOptions {
  var isCaseSensitive: Bool {
    !stack.last!.contains(.caseInsensitive)
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
  var matchLevel: CharacterClass.MatchLevel {
    switch semanticLevel {
    case .graphemeCluster:
      return .graphemeCluster
    case .unicodeScalar:
      return .unicodeScalar
    }
  }
}

extension MatchingOptions {
  /// An option that changes the behavior of a regular expression.
  fileprivate enum Option: Int {
    // PCRE options
    case caseInsensitive
    case allowDuplicateGroupNames
    case multiline
    case noAutoCapture
    case singleLine
    case reluctantByDefault

    // ICU options
    case unicodeWordBoundaries

    // NSRegularExpression compatibility options
    // Not available via regex literal flags
    case transparentBounds
    case withoutAnchoringBounds

    // Oniguruma options
    case asciiOnlyDigit
    case asciiOnlyPOSIXProps
    case asciiOnlySpace
    case asciiOnlyWord

    // Oniguruma text segment options (these are mutually exclusive and cannot
    // be unset, only flipped between)
    case textSegmentGraphemeMode
    case textSegmentWordMode
    
    // Swift semantic matching level
    case graphemeClusterSemantics
    case unicodeScalarSemantics
    case byteSemantics
    
    init?(_ astKind: AST.MatchingOption.Kind) {
      switch astKind {
      case .caseInsensitive:
        self = .caseInsensitive
      case .allowDuplicateGroupNames:
        self = .allowDuplicateGroupNames
      case .multiline:
        self = .multiline
      case .noAutoCapture:
        self = .noAutoCapture
      case .singleLine:
        self = .singleLine
      case .reluctantByDefault:
        self = .reluctantByDefault
      case .unicodeWordBoundaries:
        self = .unicodeWordBoundaries
      case .asciiOnlyDigit:
        self = .asciiOnlyDigit
      case .asciiOnlyPOSIXProps:
        self = .asciiOnlyPOSIXProps
      case .asciiOnlySpace:
        self = .asciiOnlySpace
      case .asciiOnlyWord:
        self = .asciiOnlyWord
      case .textSegmentGraphemeMode:
        self = .textSegmentGraphemeMode
      case .textSegmentWordMode:
        self = .textSegmentWordMode
      case .graphemeClusterSemantics:
        self = .graphemeClusterSemantics
      case .unicodeScalarSemantics:
        self = .unicodeScalarSemantics
      case .byteSemantics:
        self = .byteSemantics
        
      // Whitespace options are only relevant during parsing, not compilation.
      case .extended, .extraExtended:
        return nil
      @unknown default:
        // Ignore unknown 
        return nil
      }
    }
    
    fileprivate var representation: Representation {
      return .init(self)
    }
  }
}

extension MatchingOptions {
  /// A set of matching options.
  fileprivate struct Representation: OptionSet, RawRepresentable {
    var rawValue: UInt32

    /// Returns `true` if the option denoted by `kind` is a member of this set.
    func contains(_ kind: Option) -> Bool {
      contains(.init(kind))
    }
    
    /// Applies the changes described by `sequence` to this set of options.
    mutating func apply(_ sequence: AST.MatchingOptionSequence) {
      // Replace entirely if the sequence includes a caret, e.g. `(?^is)`.
      if sequence.caretLoc != nil {
        self = .default
      }
      
      for opt in sequence.adding {
        guard let opt = Option(opt.kind)?.representation else {
          continue
        }
        
        // If opt is in one of the mutually exclusive groups, clear out the
        // group before inserting.
        if Self.semanticMatchingLevels.contains(opt) {
          remove(.semanticMatchingLevels)
        }
        if Self.textSegmentOptions.contains(opt) {
          remove(.textSegmentOptions)
        }

        insert(opt)
      }
      
      for opt in sequence.removing {
        guard let opt = Option(opt.kind)?.representation else {
          continue
        }

        remove(opt)
      }
    }
  }
}

extension MatchingOptions.Representation {
  fileprivate init(_ kind: MatchingOptions.Option) {
    self.rawValue = 1 << kind.rawValue
  }
  
  // Text segmentation options
  static var textSegmentGraphemeMode: Self { .init(.textSegmentGraphemeMode) }
  static var textSegmentWordMode: Self { .init(.textSegmentWordMode) }
  
  /// Options that comprise the mutually exclusive test segmentation group.
  static var textSegmentOptions: Self {
    [.textSegmentGraphemeMode, .textSegmentWordMode]
  }

  // Semantic matching level options
  static var graphemeClusterSemantics: Self { .init(.graphemeClusterSemantics) }
  static var unicodeScalarSemantics: Self { .init(.unicodeScalarSemantics) }
  static var byteSemantics: Self { .init(.byteSemantics) }

  /// Options that comprise the mutually exclusive semantic matching level
  /// group.
  static var semanticMatchingLevels: Self {
    [.graphemeClusterSemantics, .unicodeScalarSemantics, .byteSemantics]
  }
    
  /// The default set of options.
  static var `default`: Self {
    [.graphemeClusterSemantics, .textSegmentGraphemeMode]
  }
}

extension AST.Quantification.Kind {
  func applying(_ options: MatchingOptions) -> Self {
    if options.isReluctantByDefault && self != .possessive {
      return self == .eager ? .reluctant : .eager
    }

    return self
  }
}
