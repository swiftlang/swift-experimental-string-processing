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

  case cannotReferToWholePattern

  case notQuantifiable
  case quantifierRequiresOperand(String)

  case backtrackingDirectiveMustHaveName(String)

  case unknownGroupKind(String)
  case unknownCalloutKind(String)

  case invalidMatchingOption(Character)
  case cannotRemoveMatchingOptionsAfterCaret

  case expectedCustomCharacterClassMembers
  case invalidCharacterClassRangeOperand

  case invalidPOSIXSetName(String)
  case emptyProperty

  case expectedGroupSpecifier
  case unbalancedEndOfGroup

  // Identifier diagnostics.
  case expectedIdentifier(IdentifierKind)
  case identifierMustBeAlphaNumeric(IdentifierKind)
  case identifierCannotStartWithNumber(IdentifierKind)

  case cannotRemoveTextSegmentOptions
  case cannotRemoveSemanticsOptions
  case expectedCalloutArgument
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
    case let .numberOverflow(s):
      return "number overflow: \(s)"
    case let .expectedNumDigits(s, i):
      return "expected \(i) digits in '\(s)'"
    case let .expectedNumber(s, kind: kind):
      let radix: String
      if kind == .decimal {
        radix = ""
      } else {
        radix = " of radix \(kind.radix)"
      }
      return "expected a numbers in '\(s)'\(radix)"
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
    case .cannotReferToWholePattern:
      return "cannot refer to whole pattern here"
    case .notQuantifiable:
      return "expression is not quantifiable"
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
    case let .invalidPOSIXSetName(n):
      return "invalid character set name: '\(n)'"
    case .emptyProperty:
      return "empty property"
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
    case .expectedCalloutArgument:
      return "expected argument to callout"
    }
  }
}

// TODO: Fixits, notes, etc.

// TODO: Diagnostics engine, recorder, logger, or similar.



