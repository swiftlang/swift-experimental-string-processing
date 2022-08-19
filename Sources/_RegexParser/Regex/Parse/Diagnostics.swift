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

// MARK: - Parse errors

enum ParseError: Error, Hashable {
  // TODO: I wonder if it makes sense to store the string.
  // This can make equality weird.

  // MARK: Syntactic Errors

  case numberOverflow(String)
  case expectedNumDigits(String, Int)
  case expectedNumber(String, kind: RadixKind)

  // Expected the given character or string
  case expected(String)

  // Expected something, anything really
  case unexpectedEndOfInput

  // Something happened, fall-back for now
  case misc(String)

  case tooManyBranchesInConditional(Int)
  case unsupportedCondition(String)

  case tooManyAbsentExpressionChildren(Int)

  case globalMatchingOptionNotAtStart(String)

  case expectedASCII(Character)

  case expectedNonEmptyContents
  case expectedEscape
  case invalidEscape(Character)
  case confusableCharacter(Character)

  case quoteMayNotSpanMultipleLines
  case unsetExtendedSyntaxMayNotSpanMultipleLines

  case cannotReferToWholePattern

  case quantifierRequiresOperand(String)

  case backtrackingDirectiveMustHaveName(String)

  case unknownGroupKind(String)
  case unknownCalloutKind(String)
  case unknownTextSegmentMatchingOption(Character)

  case invalidMatchingOption(Character)
  case cannotRemoveMatchingOptionsAfterCaret

  case expectedCustomCharacterClassMembers

  case emptyProperty
  case unknownProperty(key: String?, value: String)
  case unrecognizedScript(String)
  case unrecognizedCategory(String)
  case unrecognizedBlock(String)
  case invalidAge(String)
  case invalidNumericValue(String)
  case unrecognizedNumericType(String)
  case invalidCCC(String)
  
  case expectedGroupSpecifier
  case unbalancedEndOfGroup

  // Identifier diagnostics.
  case expectedIdentifier(IdentifierKind)
  case identifierMustBeAlphaNumeric(IdentifierKind)
  case identifierCannotStartWithNumber(IdentifierKind)

  case cannotRemoveTextSegmentOptions
  case cannotRemoveSemanticsOptions
  case cannotRemoveExtendedSyntaxInMultilineMode
  case cannotResetExtendedSyntaxInMultilineMode

  case expectedCalloutArgument

  // MARK: Semantic Errors

  case unsupported(String)
  case deprecatedUnicode(String)
  case invalidReference(Int)
  case invalidNamedReference(String)
  case duplicateNamedCapture(String)
  case invalidCharacterClassRangeOperand
  case unsupportedDotNetSubtraction
  case invalidQuantifierRange(Int, Int)
  case invalidCharacterRange(from: Character, to: Character)
  case notQuantifiable
}

extension IdentifierKind {
  fileprivate var diagDescription: String {
    switch self {
    case .groupName:            return "group name"
    case .onigurumaCalloutName: return "callout name"
    case .onigurumaCalloutTag:  return "callout tag"
    }
  }
}

extension ParseError: CustomStringConvertible {
  var description: String {
    switch self {
    // MARK: Syntactic Errors
    case let .numberOverflow(s):
      return "number overflow: \(s)"
    case let .expectedNumDigits(s, i):
      return "expected \(i) digits in '\(s)'"
    case let .expectedNumber(s, kind: kind):
      let number: String
      switch kind {
      case .octal:
        number = "octal number"
      case .decimal:
        number = "number"
      case .hex:
        number = "hexadecimal number"
      }
      let suffix = s.isEmpty ? "" : " in '\(s)'"
      return "expected \(number)\(suffix)"
    case let .expected(s):
      return "expected '\(s)'"
    case .unexpectedEndOfInput:
      return "unexpected end of input"
    case let .misc(s):
      return s
    case .expectedNonEmptyContents:
      return "expected non-empty contents"
    case .expectedEscape:
      return "expected escape sequence"
    case .invalidEscape(let c):
      return "invalid escape sequence '\\\(c)'"
    case .confusableCharacter(let c):
      return "'\(c)' is confusable for a metacharacter; use '\\u{...}' instead"
    case .quoteMayNotSpanMultipleLines:
      return "quoted sequence may not span multiple lines in multi-line literal"
    case .unsetExtendedSyntaxMayNotSpanMultipleLines:
      return "group that unsets extended syntax may not span multiple lines in multi-line literal"
    case .cannotReferToWholePattern:
      return "cannot refer to whole pattern here"
    case .quantifierRequiresOperand(let q):
      return "quantifier '\(q)' must appear after expression"
    case .backtrackingDirectiveMustHaveName(let b):
      return "backtracking directive '\(b)' must include name"
    case let .tooManyBranchesInConditional(i):
      return "expected 2 branches in conditional, have \(i)"
    case let .unsupportedCondition(str):
      return "\(str) cannot be used as condition"
    case let .tooManyAbsentExpressionChildren(i):
      return "expected 2 expressions in absent expression, have \(i)"
    case let .globalMatchingOptionNotAtStart(opt):
      return "matching option '\(opt)' may only appear at the start of the regex"
    case let .unknownGroupKind(str):
      return "unknown group kind '(\(str)'"
    case let .unknownCalloutKind(str):
      return "unknown callout kind '\(str)'"
    case let .unknownTextSegmentMatchingOption(m):
      return "unknown text segment mode '\(m)'; expected 'w' or 'g'"
    case let .invalidMatchingOption(c):
      return "invalid matching option '\(c)'"
    case .cannotRemoveMatchingOptionsAfterCaret:
      return "cannot remove matching options with '^' specifier"
    case let .expectedASCII(c):
      return "expected ASCII for '\(c)'"
    case .expectedCustomCharacterClassMembers:
      return "expected custom character class members"
    case .invalidCharacterClassRangeOperand:
      return "invalid bound for character class range"
    case .unsupportedDotNetSubtraction:
      return "subtraction with '-' is unsupported; use '--' instead"
    case .emptyProperty:
      return "expected property name"
    case .unknownProperty(let key, let value):
      if let key = key {
        return "unknown character property '\(key)=\(value)'"
      }
      return "unknown character property '\(value)'"
    case .expectedGroupSpecifier:
      return "expected group specifier"
    case .unbalancedEndOfGroup:
      return "closing ')' does not balance any groups openings"
    case .expectedIdentifier(let i):
      return "expected \(i.diagDescription)"
    case .identifierMustBeAlphaNumeric(let i):
      return "\(i.diagDescription) must only contain alphanumeric characters"
    case .identifierCannotStartWithNumber(let i):
      return "\(i.diagDescription) must not start with number"
    case .cannotRemoveTextSegmentOptions:
      return "text segment mode cannot be unset, only changed"
    case .cannotRemoveSemanticsOptions:
      return "semantic level cannot be unset, only changed"
    case .cannotRemoveExtendedSyntaxInMultilineMode:
      return "extended syntax may not be disabled in multi-line mode"
    case .cannotResetExtendedSyntaxInMultilineMode:
      return "extended syntax may not be disabled in multi-line mode; use '(?^x)' instead"
    case .expectedCalloutArgument:
      return "expected argument to callout"
    case .unrecognizedScript(let value):
      return "unrecognized script '\(value)'"
    case .unrecognizedCategory(let value):
      return "unrecognized category '\(value)'"
    case .unrecognizedBlock(let value):
      return "unrecognized block '\(value)'"
    case .unrecognizedNumericType(let value):
      return "unrecognized numeric type '\(value)'"
    case .invalidAge(let value):
      return "invalid age format for '\(value)' - use '3.0' or 'V3_0' formats"
    case .invalidNumericValue(let value):
      return "invalid numeric value '\(value)'"
    case .invalidCCC(let value):
      return "invalid canonical combining class '\(value)'"

    // MARK: Semantic Errors

    case let .unsupported(kind):
      return "\(kind) is not currently supported"
    case let .deprecatedUnicode(kind):
      return "\(kind) is a deprecated Unicode property, and is not supported"
    case let .invalidReference(i):
      return "no capture numbered \(i)"
    case let .invalidNamedReference(name):
      return "no capture named '\(name)'"
    case let .duplicateNamedCapture(str):
      return "group named '\(str)' already exists"
    case let .invalidQuantifierRange(lhs, rhs):
      return "range lower bound '\(lhs)' must be less than or equal to upper bound '\(rhs)'"
    case let .invalidCharacterRange(from: lhs, to: rhs):
      return "character '\(lhs)' must compare less than or equal to '\(rhs)'"
    case .notQuantifiable:
      return "expression is not quantifiable"
    }
  }
}

/// A fatal error that indicates broken logic in the parser.
enum FatalParseError: Hashable, Error {
  case unreachable(String)
}

extension FatalParseError: CustomStringConvertible {
  var description: String {
    switch self {
    case .unreachable(let str):
      return "UNREACHABLE: \(str)"
    }
  }
}

// MARK: Diagnostic handling

/// A diagnostic to emit.
public struct Diagnostic: Hashable {
  public let behavior: Behavior
  public let message: String
  public let location: SourceLocation

  // TODO: Fixits, notes, etc.

  // The underlying ParseError if applicable. This is used for testing.
  internal let underlyingParseError: ParseError?

  init(_ behavior: Behavior, _ message: String, at loc: SourceLocation,
       underlyingParseError: ParseError? = nil) {
    self.behavior = behavior
    self.message = message
    self.location = loc
    self.underlyingParseError = underlyingParseError
  }

  public var isAnyError: Bool { behavior.isAnyError }
}

extension Diagnostic {
  public enum Behavior: Hashable {
    case fatalError, error, warning

    public var isAnyError: Bool {
      switch self {
      case .fatalError, .error:
        return true
      case .warning:
        return false
      }
    }
  }
}

/// A collection of diagnostics to emit.
public struct Diagnostics: Hashable {
  public private(set) var diags = [Diagnostic]()

  public init() {}
  public init(_ diags: [Diagnostic]) {
    self.diags = diags
  }

  /// Add a new diagnostic to emit.
  public mutating func append(_ diag: Diagnostic) {
    diags.append(diag)
  }

  /// Add all the diagnostics of another diagnostic collection.
  public mutating func append(contentsOf other: Diagnostics) {
    diags.append(contentsOf: other.diags)
  }

  /// Add all the new fatal error diagnostics of another diagnostic collection.
  /// This assumes that `other` was the same as `self`, but may have additional
  /// diagnostics added to it.
  public mutating func appendNewFatalErrors(from other: Diagnostics) {
    let newDiags = other.diags.dropFirst(diags.count)
    for diag in newDiags where diag.behavior == .fatalError {
      append(diag)
    }
  }

  /// Whether any error is present. This includes fatal errors.
  public var hasAnyError: Bool {
    diags.contains(where: { $0.isAnyError })
  }

  /// Whether any fatal error is present.
  public var hasFatalError: Bool {
    diags.contains(where: { $0.behavior == .fatalError })
  }

  /// If any error diagnostic has been added, throw it as an Error.
  func throwAnyError() throws {
    for diag in diags where diag.isAnyError {
      struct ErrorDiagnostic: Error, CustomStringConvertible {
        var diag: Diagnostic
        var description: String { diag.message }
      }
      throw Source.LocatedError(ErrorDiagnostic(diag: diag), diag.location)
    }
  }
}

// MARK: Diagnostic construction

extension Diagnostic {
  init(_ err: ParseError, at loc: SourceLocation) {
    self.init(.error, "\(err)", at: loc, underlyingParseError: err)
  }

  init(_ err: FatalParseError, at loc: SourceLocation) {
    self.init(.fatalError, "\(err)", at: loc)
  }
}

extension Diagnostics {
  mutating func error(_ err: ParseError, at loc: SourceLocation) {
    append(Diagnostic(err, at: loc))
  }

  mutating func fatal(_ err: FatalParseError, at loc: SourceLocation) {
    append(Diagnostic(err, at: loc))
  }
}
