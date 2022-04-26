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

@_implementationOnly import _RegexParser

@available(SwiftStdlib 5.7, *)
extension Regex where Output == AnyRegexOutput {
  /// Parse and compile `pattern`, resulting in an existentially-typed capture list.
  public init(_ pattern: String) throws {
    self.init(ast: try parse(pattern, .traditional))
  }
}

@available(SwiftStdlib 5.7, *)
extension Regex {
  /// Parse and compile `pattern`, resulting in a strongly-typed capture list.
  public init(
    _ pattern: String,
    as: Output.Type = Output.self
  ) throws {
    self.init(ast: try parse(pattern, .traditional))
  }
}

@available(SwiftStdlib 5.7, *)
extension Regex.Match where Output == AnyRegexOutput {
  // Ensures `.0` always refers to the whole match.
  public subscript(
    dynamicMember keyPath: KeyPath<(Substring, _doNotUse: ()), Substring>
  ) -> Substring {
    input[range]
  }

  public subscript(name: String) -> AnyRegexOutput.Element? {
    namedCaptureOffsets[name].map { self[$0 + 1] }
  }
}

/// A type-erased regex output
@available(SwiftStdlib 5.7, *)
public struct AnyRegexOutput {
  let input: String
  let namedCaptureOffsets: [String: Int]
  fileprivate let _elements: [ElementRepresentation]

  /// The underlying representation of the element of a type-erased regex
  /// output.
  fileprivate struct ElementRepresentation {
    /// The depth of `Optioals`s wrapping the underlying value. For example,
    /// `Substring` has optional depth `0`, and `Int??` has optional depth `2`.
    let optionalDepth: Int
    /// The bounds of the output element.
    let bounds: Range<String.Index>?
  }
}

@available(SwiftStdlib 5.7, *)
extension AnyRegexOutput {
  /// Creates a type-erased regex output from an existing output.
  ///
  /// Use this initializer to fit a regex with strongly typed captures into the
  /// use site of a dynamic regex, i.e. one that was created from a string.
  public init<Output>(_ match: Regex<Output>.Match) {
    // Note: We use type equality instead of `match.output as? ...` to prevent
    // unexpected optional flattening.
    if Output.self == AnyRegexOutput.self {
      self = match.output as! AnyRegexOutput
      return
    }
    fatalError("FIXME: Not implemented")
    // self.init(input: match.input, _elements: <elements of output tuple>)
  }

  /// Returns a typed output by converting the underlying value to the specified
  /// type.
  ///
  /// - Parameter type: The expected output type.
  /// - Returns: The output, if the underlying value can be converted to the
  ///   output type, or nil otherwise.
  public func `as`<Output>(_ type: Output.Type) -> Output? {
    let elements = _elements.map {
      StructuredCapture(
        optionalCount: $0.optionalDepth,
        storedCapture: .init(range: $0.bounds)
      ).existentialOutputComponent(from: input[...])
    }
    return TypeConstruction.tuple(of: elements) as? Output
  }
}

@available(SwiftStdlib 5.7, *)
extension AnyRegexOutput {
  internal init<C: Collection>(
    input: String, namedCaptureOffsets: [String: Int], elements: C
  ) where C.Element == StructuredCapture {
    self.init(
      input: input,
      namedCaptureOffsets: namedCaptureOffsets,
      _elements: elements.map(ElementRepresentation.init))
  }
}

@available(SwiftStdlib 5.7, *)
extension AnyRegexOutput.ElementRepresentation {
  init(_ element: StructuredCapture) {
    self.init(
      optionalDepth: element.optionalCount,
      bounds: element.storedCapture.flatMap(\.range))
  }

  func value(forInput input: String) -> Any {
    // Ok for now because `existentialMatchComponent`
    // wont slice the input if there's no range to slice with
    //
    // FIXME: This is ugly :-/
    let input = bounds.map { input[$0] } ?? ""

    return constructExistentialOutputComponent(
      from: input,
      in: bounds,
      value: nil,
      optionalCount: optionalDepth)
  }
}

@available(SwiftStdlib 5.7, *)
extension AnyRegexOutput: RandomAccessCollection {
  public struct Element {
    fileprivate let representation: ElementRepresentation
    let input: String

    /// The range over which a value was captured. `nil` for no-capture.
    public var range: Range<String.Index>? {
      representation.bounds
    }

    /// The slice of the input over which a value was captured. `nil` for no-capture.
    public var substring: Substring? {
      range.map { input[$0] }
    }

    /// The captured value, `nil` for no-capture
    public var value: Any? {
      fatalError()
    }
  }

  public var startIndex: Int {
    _elements.startIndex
  }

  public var endIndex: Int {
    _elements.endIndex
  }

  public var count: Int {
    _elements.count
  }

  public func index(after i: Int) -> Int {
    _elements.index(after: i)
  }

  public func index(before i: Int) -> Int {
    _elements.index(before: i)
  }

  public subscript(position: Int) -> Element {
    .init(representation: _elements[position], input: input)
  }
}

@available(SwiftStdlib 5.7, *)
extension AnyRegexOutput {
  public subscript(name: String) -> Element? {
    namedCaptureOffsets[name].map { self[$0 + 1] }
  }
}

@available(SwiftStdlib 5.7, *)
extension Regex.Match where Output == AnyRegexOutput {
  /// Creates a type-erased regex match from an existing match.
  ///
  /// Use this initializer to fit a regex match with strongly typed captures into the
  /// use site of a dynamic regex match, i.e. one that was created from a string.
  public init<Output>(_ match: Regex<Output>.Match) {
    fatalError("FIXME: Not implemented")
  }

  /// Returns a typed match by converting the underlying values to the specified
  /// types.
  ///
  /// - Parameter type: The expected output type.
  /// - Returns: A match generic over the output type if the underlying values can be converted to the
  ///   output type. Returns `nil` otherwise.
  public func `as`<Output>(_ type: Output.Type) -> Regex<Output>.Match? {
    fatalError("FIXME: Not implemented")
  }
}

@available(SwiftStdlib 5.7, *)
extension Regex where Output == AnyRegexOutput {
  /// Returns whether a named-capture with `name` exists
  public func contains(captureNamed name: String) -> Bool {
    fatalError("FIXME: not implemented")
  }

  /// Creates a type-erased regex from an existing regex.
  ///
  /// Use this initializer to fit a regex with strongly typed captures into the
  /// use site of a dynamic regex, i.e. one that was created from a string.
  public init<Output>(_ match: Regex<Output>) {
    fatalError("FIXME: Not implemented")
  }

  /// Returns a typed regex by converting the underlying types.
  ///
  /// - Parameter type: The expected output type.
  /// - Returns: A regex generic over the output type if the underlying types can be converted.
  ///   Returns `nil` otherwise.
  public func `as`<Output>(_ type: Output.Type) -> Regex<Output>? {
    fatalError("FIXME: Not implemented")
  }
}
