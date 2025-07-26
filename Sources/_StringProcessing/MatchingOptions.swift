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

internal import _RegexParser

/// A type that represents the current state of regex matching options, with
/// stack-based scoping.
struct MatchingOptions {
  fileprivate var stack: [Representation]
  
  fileprivate func _invariantCheck() {
    assert(!stack.isEmpty, "Unbalanced call to endScope")
    
    // Must contain exactly one of each mutually exclusive group
    assert(stack.last!.intersection(.textSegmentOptions).rawValue.nonzeroBitCount == 1)
    assert(stack.last!.intersection(.semanticMatchingLevels).rawValue.nonzeroBitCount == 1)
    
    // Must contain at most one quantifier behavior
    assert(stack.last!.intersection(.repetitionBehaviors).rawValue.nonzeroBitCount <= 1)
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
  
  // @testable
  /// Returns true if the options at the top of `stack` are equal to those
  /// for `other`.
  func _equal(to other: MatchingOptions) -> Bool {
    stack.last == other.stack.last
  }
}

// MARK: Matching behavior API
extension MatchingOptions {
  var isCaseInsensitive: Bool {
    stack.last!.contains(.caseInsensitive)
  }
  
  var isReluctantByDefault: Bool {
    stack.last!.contains(.reluctantByDefault)
  }
  
  var defaultQuantificationKind: AST.Quantification.Kind {
    if stack.last!.contains(.possessiveByDefault) {
      return .possessive
    } else if stack.last!.contains(.reluctantByDefault) {
      return .reluctant
    } else {
      return .eager
    }
  }
  
  var dotMatchesNewline: Bool {
    stack.last!.contains(.singleLine)
  }
  
  var anchorsMatchNewlines: Bool {
    stack.last!.contains(.multiline)
  }
  
  var usesASCIIWord: Bool {
    stack.last!.contains(.asciiOnlyWord)
      || stack.last!.contains(.asciiOnlyPOSIXProps)
  }
  
  var usesASCIIDigits: Bool {
    stack.last!.contains(.asciiOnlyDigit)
      || stack.last!.contains(.asciiOnlyPOSIXProps)
  }
  
  var usesASCIISpaces: Bool {
    stack.last!.contains(.asciiOnlySpace)
      || stack.last!.contains(.asciiOnlyPOSIXProps)
  }
  
  var usesSimpleUnicodeBoundaries: Bool {
    !stack.last!.contains(.unicodeWordBoundaries)
  }
  
  var usesExtendedWhitespace: Bool {
    stack.last!.contains(.extended)
      || stack.last!.contains(.extraExtended)
  }
  
  enum SemanticLevel {
    case graphemeCluster
    case unicodeScalar
  }
  
  var semanticLevel: SemanticLevel {
    stack.last!.contains(.graphemeClusterSemantics)
      ? .graphemeCluster
      : .unicodeScalar
  }

  /// Whether matching needs to honor canonical equivalence.
  ///
  /// Currently, this is synonymous with grapheme-cluster semantics, but could
  /// become its own option in the future
  var usesCanonicalEquivalence: Bool {
    semanticLevel == .graphemeCluster
  }
  
  var usesNSRECompatibleDot: Bool {
    stack.last!.contains(.nsreCompatibleDot)
  }

  var reversed: Bool {
    stack.last!.contains(.reverse)
  }
}

// MARK: - Implementation
extension MatchingOptions {
  /// An option that changes the behavior of a regular expression.
  fileprivate enum Option: Int {
    // PCRE options
    case caseInsensitive
    case allowDuplicateGroupNames
    case multiline
    case namedCapturesOnly
    case singleLine
    case reluctantByDefault

    // ICU options
    case unicodeWordBoundaries

    // NSRegularExpression compatibility options
    // Not available via regex literal flags
    case transparentBounds
    case withoutAnchoringBounds
    case nsreCompatibleDot

    // Not available via regex literal flags
    case reverse

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
    
    // Swift-only default possessive quantifier
    case possessiveByDefault
    
    // Whitespace options
    case extended
    case extraExtended

    init?(_ astKind: AST.MatchingOption.Kind) {
      switch astKind {
      case .caseInsensitive:
        self = .caseInsensitive
      case .allowDuplicateGroupNames:
        self = .allowDuplicateGroupNames
      case .multiline:
        self = .multiline
      case .namedCapturesOnly:
        self = .namedCapturesOnly
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
      case .possessiveByDefault:
        self = .possessiveByDefault
      case .nsreCompatibleDot:
        self = .nsreCompatibleDot
      case .extended:
        self = .extended
      case .extraExtended:
        self = .extraExtended
      case .reverse:
        self = .reverse
      #if RESILIENT_LIBRARIES
      @unknown default:
        fatalError()
      #endif
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
    
    mutating func add(_ opt: Option) {
      // If opt is in one of the mutually exclusive groups, clear out the
      // group before inserting.
      if Self.semanticMatchingLevels.contains(opt.representation) {
        remove(.semanticMatchingLevels)
      }
      if Self.textSegmentOptions.contains(opt.representation) {
        remove(.textSegmentOptions)
      }
      if Self.repetitionBehaviors.contains(opt.representation) {
        remove(.repetitionBehaviors)
      }

      insert(opt.representation)
    }
    
    /// Applies the changes described by `sequence` to this set of options.
    mutating func apply(_ sequence: AST.MatchingOptionSequence) {
      // Replace entirely if the sequence includes a caret, e.g. `(?^is)`.
      if sequence.caretLoc != nil {
        self = .default
      }
      
      for opt in sequence.adding {
        guard let opt = Option(opt.kind) else {
          continue
        }
        add(opt)
      }
      
      for opt in sequence.removing {
        guard let opt = Option(opt.kind) else {
          continue
        }
        if Self.repetitionBehaviors.contains(opt.representation) {
          remove(.repetitionBehaviors)
        }
        remove(opt.representation)
      }
    }
  }
}

extension MatchingOptions.Representation {
  fileprivate init(_ kind: MatchingOptions.Option) {
    self.rawValue = 1 << kind.rawValue
  }
  
  // Case insensitivity
  static var caseInsensitive: Self { .init(.caseInsensitive) }
  
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
  
  // Quantification behavior options
  static var reluctantByDefault: Self { .init(.reluctantByDefault) }
  static var possessiveByDefault: Self { .init(.possessiveByDefault) }

  static var repetitionBehaviors: Self {
    [.reluctantByDefault, .possessiveByDefault]
  }
  
  // Uses level 2 Unicode word boundaries
  static var unicodeWordBoundaries: Self { .init(.unicodeWordBoundaries) }
  
  /// The default set of options.
  static var `default`: Self {
    [.graphemeClusterSemantics, .textSegmentGraphemeMode, .unicodeWordBoundaries]
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
