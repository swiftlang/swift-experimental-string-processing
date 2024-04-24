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

// The version number for the regex. This gets emitted as an argument to the
// Regex(_regexString:version:) initializer and should be bumped if the format
// of the regex string needs to be changed in such a that requires the runtime
// to updated.
public let currentRegexLiteralFormatVersion = 1

@_spi(CompilerInterface)
public struct CompilerLexError: Error {
  var underlyingLocation: UnsafeSourceLocation

  public var message: String
  public var location: UnsafeRawPointer { return underlyingLocation.ptr }
  public var completelyErroneous: Bool

  init(
    message: String, location: UnsafeRawPointer, completelyErroneous: Bool
  ) {
    self.message = message
    self.underlyingLocation = UnsafeSourceLocation(location)
    self.completelyErroneous = completelyErroneous
  }
}

/// Interface for the Swift compiler.
///
/// Attempt to lex a regex literal string.
///
/// - Parameters:
///   - start: The pointer at which to start lexing the literal.
///   - bufferEnd: A pointer to the end of the buffer, which should not be lexed
///                past.
///   - mustBeRegex: Whether we expect a regex literal to be lexed here. If
///                  `false`, a regex literal will only be lexed if it does not
///                  produce an error.
///
/// - Returns: If a regex literal was lexed, `resumePtr` specifies where to
///            resume lexing and `error` specifies a lexing error to emit. If
///            a regex literal was not lexed, `nil` is returned.
///
@_spi(CompilerInterface)
public func swiftCompilerLexRegexLiteral(
  start: UnsafeRawPointer, bufferEnd: UnsafeRawPointer, mustBeRegex: Bool
) -> (resumePtr: UnsafeRawPointer, error: CompilerLexError?)? {
  do {
    let (_, _, endPtr) = try lexRegex(start: start, end: bufferEnd)
    return (resumePtr: endPtr, error: nil)
  } catch let error as DelimiterLexError {
    if !mustBeRegex {
      // This token can be something else. Let the client fallback.
      return nil
    }
    let completelyErroneous: Bool
    switch error.kind {
    case .unterminated, .multilineClosingNotOnNewline:
      // These can be recovered from.
      completelyErroneous = false
    case .unprintableASCII, .invalidUTF8:
      // We don't currently have good recovery behavior for these.
      completelyErroneous = true
    case .unknownDelimiter:
      // An unknown delimiter should be recovered from, as we may want to try
      // lex something else.
      return nil
    }
    // For now every lexer error is emitted at the starting delimiter.
    let compilerError = CompilerLexError(
      message: "\(error)", location: start,
      completelyErroneous: completelyErroneous
    )
    return (error.resumePtr, compilerError)
  } catch {
    fatalError("Should be a DelimiterLexError")
  }
}

@_spi(CompilerInterface)
public struct CompilerParseError: Error {
  public var message: String
  public var location: String.Index?
}

/// Interface for the Swift compiler.
///
/// Attempt to parse a regex literal string.
///
/// - Parameters:
///   - input: The regex input string, including delimiters.
///   - captureBufferOut: A buffer into which the captures of the regex will
///                       be encoded into upon a successful parse.
///
/// - Returns: The string to emit along with its version number.
/// - Throws: `CompilerParseError` if there was a parsing error.
@_spi(CompilerInterface)
public func swiftCompilerParseRegexLiteral(
  _ input: String, captureBufferOut: UnsafeMutableRawBufferPointer
) throws -> (regexToEmit: String, version: Int) {
  do {
    let ast = try parseWithDelimiters(input)
    // Serialize the capture structure for later type inference.
    assert(captureBufferOut.count >= input.utf8.count)
    ast.captureStructure.encode(to: captureBufferOut)

    // For now we just return the input as the regex to emit. This could be
    // changed in the future if need to back-deploy syntax to something already
    // known to the matching engine, or otherwise change the format. Note
    // however that it will need plumbing through on the compiler side.
    return (regexToEmit: input, version: currentRegexLiteralFormatVersion)
  } catch {
    throw CompilerParseError(
      message: "cannot parse regular expression: \(String(describing: error))",
      location: (error as? LocatedErrorProtocol)?.location.start
    )
  }
}
