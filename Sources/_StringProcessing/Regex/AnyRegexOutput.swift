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

/// A type-erased regex output.
@available(SwiftStdlib 5.7, *)
public struct AnyRegexOutput {
  internal let input: String
  internal var _elements: [ElementRepresentation]
}

@available(SwiftStdlib 5.7, *)
extension AnyRegexOutput {
  /// Creates a type-erased regex output from an existing match.
  ///
  /// Use this initializer to fit a strongly-typed regex match into the
  /// use site of a type-erased regex output.
  public init<Output>(_ match: Regex<Output>.Match) {
    self = match.anyRegexOutput
  }

  /// Returns a strongly-typed output by converting type-erased values to the specified type.
  ///
  /// - Parameter type: The expected output type.
  /// - Returns: The output, if the underlying value can be converted to the
  ///   output type; otherwise `nil`.
  public func extractValues<Output>(
    as type: Output.Type = Output.self
  ) -> Output? {
    let elements = map {
      $0.existentialOutputComponent(from: input)
    }
    return TypeConstruction.tuple(of: elements) as? Output
  }
}

@available(SwiftStdlib 5.7, *)
extension AnyRegexOutput: RandomAccessCollection {
  /// An individual type-erased output value.
  public struct Element {
    internal let representation: ElementRepresentation
    internal let input: String

    /// The range over which a value was captured. `nil` for no-capture.
    public var range: Range<String.Index>? {
      representation.content?.range
    }

    /// The slice of the input over which a value was captured. `nil` for no-capture.
    public var substring: Substring? {
      range.map { input[$0] }
    }

    /// The captured value, `nil` for no-capture.
    public var value: Any? {
      representation.value(forInput: input)
    }

    public var type: Any.Type {
      representation.type
    }

    /// The name of this capture, if it has one, otherwise `nil`.
    public var name: String? {
      representation.name
    }

    // TODO: Consider making API, and figure out how
    // DSL and this would work together...
    /// Whether this capture is considered optional by the regex. I.e.,
    /// whether it is inside an alternation or zero-or-n quantification.
    var isOptional: Bool {
      representation.optionalDepth != 0
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
  /// Access a capture by name. Returns `nil` if no capture with that name was present in the Regex.
  public subscript(name: String) -> Element? {
    first {
      $0.name == name
    }
  }
}

@available(SwiftStdlib 5.7, *)
extension Regex.Match where Output == AnyRegexOutput {
  /// Accesses the whole match using the `.0` syntax.
  public subscript(
    dynamicMember keyPath: KeyPath<(Substring, _doNotUse: ()), Substring>
  ) -> Substring {
    anyRegexOutput.input[range]
  }

  /// Access a capture by name. Returns `nil` if there's no capture with that name.
  public subscript(name: String) -> AnyRegexOutput.Element? {
    anyRegexOutput.first {
      $0.name == name
    }
  }
}

// MARK: - Run-time regex creation and queries

@available(SwiftStdlib 5.7, *)
extension Regex where Output == AnyRegexOutput {
  /// Parses and compiles a regular expression, resulting in a type-erased capture list.
  ///
  /// - Parameter pattern: The regular expression.
  public init(_ pattern: String) throws {
    self.init(ast: try parse(pattern, .traditional))
  }
  
  internal init(_ pattern: String, syntax: SyntaxOptions) throws {
    self.init(ast: try parse(pattern, syntax))
  }
}

@available(SwiftStdlib 5.7, *)
extension Regex {
  /// Parses and compiles a regular expression.
  ///
  /// - Parameter pattern: The regular expression.
  /// - Parameter as: The desired type for the output.
  public init(
    _ pattern: String,
    as: Output.Type = Output.self
  ) throws {
    let regex = Regex(ast: try parse(pattern, .traditional))
    
    let (isSuccess, correctType) = regex._verifyType()
    
    guard isSuccess else {
      throw RegexCompilationError.incorrectOutputType(
        incorrect: Output.self,
        correct: correctType
      )
    }
    
    self = regex
  }

  /// Produces a regex that matches `verbatim` exactly, as though every
  /// metacharacter in it was escaped.
  public init(verbatim: String) {
    self.init(node: .quotedLiteral(verbatim))
  }

  /// Returns whether a named-capture with `name` exists
  public func contains(captureNamed name: String) -> Bool {
    program.tree.captureList.captures.contains(where: {
      $0.name == name
    })
  }
}

// MARK: - Converting to/from ARO

@available(SwiftStdlib 5.7, *)
extension Regex where Output == AnyRegexOutput {
  /// Creates a type-erased regex from an existing regex.
  ///
  /// Use this initializer to fit a regex with strongly-typed captures into the
  /// use site of a type-erased regex, i.e. one that was created from a string.
  public init<Output>(_ regex: Regex<Output>) {
    self.init(node: regex.root)
  }
}

@available(SwiftStdlib 5.7, *)
extension Regex.Match where Output == AnyRegexOutput {
  /// Creates a type-erased regex match from an existing match.
  ///
  /// Use this initializer to fit a regex match with strongly-typed captures into the
  /// use site of a type-erased regex match.
  public init<Output>(_ match: Regex<Output>.Match) {
    self.init(
      anyRegexOutput: match.anyRegexOutput,
      range: match.range
    )
  }
}

@available(SwiftStdlib 5.7, *)
extension Regex {
  /// Creates a strongly-typed regex from a type-erased regex.
  ///
  /// Use this initializer to create a strongly-typed regex from
  /// one that was created from a string. Returns `nil` if the types
  /// don't match.
  public init?(
    _ erased: Regex<AnyRegexOutput>,
    as: Output.Type = Output.self
  ) {
    self.init(node: erased.root)
    
    guard _verifyType().0 else {
      return nil
    }
  }
}

// MARK: - Internals

@available(SwiftStdlib 5.7, *)
extension AnyRegexOutput {
  /// The underlying representation of the element of a type-erased regex
  /// output.
  internal struct ElementRepresentation {
    /// The depth of `Optioals`s wrapping the underlying value. For example,
    /// `Substring` has optional depth `0`, and `Int??` has optional depth `2`.
    let optionalDepth: Int

    /// The capture content representation, i.e. the element bounds and the
    /// value (if available).
    let content: (range: Range<String.Index>, value: Any?)?

    /// The name of the capture.
    var name: String? = nil

    /// The capture reference this element refers to.
    var referenceID: ReferenceID? = nil
  }

  internal init(input: String, elements: [ElementRepresentation]) {
    self.init(input: input, _elements: elements)
  }
}

@available(SwiftStdlib 5.7, *)
extension AnyRegexOutput.ElementRepresentation {
  fileprivate func value(forInput input: String) -> Any {
    constructExistentialOutputComponent(
      from: input,
      component: content,
      optionalCount: optionalDepth
    )
  }

  var type: Any.Type {
    content?.value.map { Swift.type(of: $0) }
      ?? TypeConstruction.optionalType(of: Substring.self, depth: optionalDepth)
  }
}
