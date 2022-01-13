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

extension AST {
  /// An option written in source that changes matching semantics.
  public struct MatchingOption: Hashable {
    public enum Kind: Int {
      // PCRE options
      case caseInsensitive          // i
      case allowDuplicateGroupNames // J
      case multiline                // m
      case noAutoCapture            // n
      case singleLine               // s
      case reluctantByDefault       // U
      case extended                 // x
      case extraExtended            // xx

      // ICU options
      case unicodeWordBoundaries    // w

      // Oniguruma options
      case asciiOnlyDigit           // D
      case asciiOnlyPOSIXProps      // P
      case asciiOnlySpace           // S
      case asciiOnlyWord            // W

      // Oniguruma text segment options (these are mutually exclusive and cannot
      // be unset, only flipped between)
      case textSegmentGraphemeMode  // y{g}
      case textSegmentWordMode      // y{w}
      
      // Swift semantic matching level
      case graphemeClusterSemantics // X
      case unicodeScalarSemantics   // u
      case byteSemantics            // b
    }
    public var kind: Kind
    public var location: SourceLocation

    public init(_ kind: Kind, location: SourceLocation) {
      self.kind = kind
      self.location = location
    }

    public var isTextSegmentMode: Bool {
      switch kind {
      case .textSegmentGraphemeMode, .textSegmentWordMode:
        return true
      default:
        return false
      }
    }
    
    public var isSemanticMatchingLevel: Bool {
      switch kind {
      case .graphemeClusterSemantics, .unicodeScalarSemantics, .byteSemantics:
        return true
      default:
        return false
      }
    }
  }

  /// A sequence of matching options written in source.
  public struct MatchingOptionSequence: Hashable {
    /// If the sequence starts with a caret '^', its source location, or nil
    /// otherwise. If this is set, it indicates that all the matching options
    /// are unset, except the ones in `adding`.
    public var caretLoc: SourceLocation?

    /// The options to add.
    public var adding: [MatchingOption]

    /// The location of the '-' between the options to add and options to
    /// remove.
    public var minusLoc: SourceLocation?

    /// The options to remove.
    public var removing: [MatchingOption]

    public init(caretLoc: SourceLocation?, adding: [MatchingOption],
                minusLoc: SourceLocation?, removing: [MatchingOption]) {
      self.caretLoc = caretLoc
      self.adding = adding
      self.minusLoc = minusLoc
      self.removing = removing
    }
    
    public func options(merging optionSet: MatchingOptionSet = []) -> MatchingOptionSet {
      var result = optionSet
      for opt in adding {
        if opt.isSemanticMatchingLevel {
          result.remove(.semanticMatchingLevels)
        }
        if opt.isTextSegmentMode {
          result.remove(.textSegmentOptions)
        }
        
        result.insert(.init(opt.kind))
      }
      for opt in removing {
        result.remove(.init(opt.kind))
      }
      return result
    }
  }
  
  /// A set of matching options.
  public struct MatchingOptionSet: OptionSet {
    public var rawValue: UInt32
    
    public init(rawValue: UInt32) {
      self.rawValue = rawValue
    }
    
    public init(_ kind: AST.MatchingOption.Kind) {
      self.rawValue = 1 << kind.rawValue
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
}

extension AST.MatchingOption: _ASTPrintable {
  public var _dumpBase: String { "\(kind)" }
}

extension AST.MatchingOptionSequence: _ASTPrintable {
  public var _dumpBase: String {
    "adding: \(adding), removing: \(removing), hasCaret: \(caretLoc != nil)"
  }
}
