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

  case cannotReferToWholePattern

  case quantifierRequiresOperand(String)

  case backtrackingDirectiveMustHaveName(String)

  case unknownGroupKind(String)
  case unknownCalloutKind(String)

  case invalidMatchingOption(Character)
  case cannotRemoveMatchingOptionsAfterCaret

  case expectedCustomCharacterClassMembers

  case emptyProperty
  case unknownProperty(key: String?, value: String)

  case expectedGroupSpecifier
  case unbalancedEndOfGroup

  // Identifier diagnostics.
  case expectedIdentifier(IdentifierKind)
  case identifierMustBeAlphaNumeric(IdentifierKind)
  case identifierCannotStartWithNumber(IdentifierKind)

  case cannotRemoveTextSegmentOptions
  case cannotRemoveSemanticsOptions
  case cannotRemoveExtendedSyntaxInMultilineMode

  case expectedCalloutArgument

  // MARK: Semantic Errors

  case unsupported(String)
  case deprecatedUnicode(String)
  case invalidReference(Int)
  case duplicateNamedCapture(String)
  case invalidCharacterClassRangeOperand
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
    case let .invalidMatchingOption(c):
      return "invalid matching option '\(c)'"
    case .cannotRemoveMatchingOptionsAfterCaret:
      return "cannot remove matching options with '^' specifier"
    case let .expectedASCII(c):
      return "expected ASCII for '\(c)'"
    case .expectedCustomCharacterClassMembers:
      return "expected custom character class members"
    case .invalidCharacterClassRangeOperand:
      return "invalid character class range"
    case .emptyProperty:
      return "empty property"
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
    case .expectedCalloutArgument:
      return "expected argument to callout"

    // MARK: Semantic Errors

    case let .unsupported(kind):
      return "\(kind) is not currently supported"
    case let .deprecatedUnicode(kind):
      return "\(kind) is a deprecated Unicode property, and is not supported"
    case let .invalidReference(i):
      return "no capture numbered \(i)"
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

// TODO: Fixits, notes, etc.

// TODO: Diagnostics engine, recorder, logger, or similar.



