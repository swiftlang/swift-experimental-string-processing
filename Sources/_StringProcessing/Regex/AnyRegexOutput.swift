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

/// The type-erased, dynamic output of a regular expression match.
///
/// When you find a match using regular expression that has `AnyRegexOutput`
/// as its output type, you can find information about matches by iterating
@available(SwiftStdlib 5.7, *)
public struct AnyRegexOutput {
  internal let input: String
  internal var _elements: [ElementRepresentation]
}

@available(SwiftStdlib 5.7, *)
extension AnyRegexOutput {
  /// Creates a dynamic regular expression match output from an existing match.
  ///
  /// You can use this initializer when you need an `AnyRegexOutput` instance
  /// instead of the output type of a strongly-typed `Regex.Match`.
  public init<Output>(_ match: Regex<Output>.Match) {
    self = match.anyRegexOutput
  }

  /// Returns strongly-typed match output by converting this type-erased
  /// output to the specified type, if possible.
  ///
  /// - Parameter outputType: The expected output type.
  /// - Returns: The output, if the underlying value can be converted to
  ///   `outputType`; otherwise, `nil`.
  public func extractValues<Output>(
    as outputType: Output.Type = Output.self
  ) -> Output? {
    let elements = map {
      $0.existentialOutputComponent(from: input)
    }
    return TypeConstruction.tuple(of: elements) as? Output
  }
}

@available(SwiftStdlib 5.7, *)
extension AnyRegexOutput: RandomAccessCollection {
  /// An individual match output value.
  public struct Element {
    internal let representation: ElementRepresentation
    internal let input: String

    /// The range over which a value was captured, if there was a capture.
    ///
    /// If nothing was captured, `range` is `nil`.
    public var range: Range<String.Index>? {
      representation.content?.range
    }

    /// The slice of the input which was captured, if there was a capture.
    ///
    /// If nothing was captured, `substring` is `nil`.
    public var substring: Substring? {
      range.map { input[$0] }
    }

    /// The captured value, if there was a capture.
    ///
    /// If nothing was captured, `value` is `nil`.
    public var value: Any? {
      representation.value(forInput: input)
    }

    /// The type of this capture.
    public var type: Any.Type {
      representation.type
    }

    /// The name of this capture, if the capture is named.
    ///
    /// If the capture is unnamed, `name` is `nil`.
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
  /// Accesses the capture with the specified name, if a capture with that name
  /// exists.
  ///
  /// - Parameter name: The name of the capture to access.
  /// - Returns: An element providing information about the capture, if there is
  ///   a capture named `name`; otherwise, `nil`.
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
    dynamicMember _keyPath: KeyPath<(Substring, _doNotUse: ()), Substring>
  ) -> Substring {
    anyRegexOutput.input[range]
  }

  /// Accesses the capture with the specified name, if a capture with that name
  /// exists.
  ///
  /// - Parameter name: The name of the capture to access.
  /// - Returns: An element providing information about the capture, if there is
  ///   a capture named `name`; otherwise, `nil`.
  public subscript(name: String) -> AnyRegexOutput.Element? {
    anyRegexOutput.first {
      $0.name == name
    }
  }
}

// MARK: - Run-time regex creation and queries

@available(SwiftStdlib 5.7, *)
extension Regex where Output == AnyRegexOutput {
  /// Creates a regular expression from the given string, using a dynamic
  /// capture list.
  ///
  /// Use this initializer to create a `Regex` instance from a regular
  /// expression that you have stored in `pattern`.
  ///
  ///     let simpleDigits = try Regex("[0-9]+")
  ///
  /// This initializer throws an error if `pattern` uses invalid regular
  /// expression syntax.
  ///
  /// The output type of the new `Regex` is the dynamic ``AnyRegexOutput``.
  /// If you know the capture structure of `pattern` ahead of time, use the
  /// ``init(_:as:)`` initializer instead.
  ///
  /// - Parameter pattern: A string with regular expression syntax.
  @_effects(readnone)
  public init(_ pattern: String) throws {
    self.init(ast: try parse(pattern, .traditional))
  }
  
  @_effects(readnone)
  internal init(_ pattern: String, syntax: SyntaxOptions) throws {
    self.init(ast: try parse(pattern, syntax))
  }
}

@available(SwiftStdlib 5.7, *)
extension Regex {
  /// Creates a regular expression from the given string, using the specified
  /// capture type.
  ///
  /// You can use this initializer to create a `Regex` instance from a regular
  /// expression that you have stored in `pattern` when you know the capture
  /// structure of the regular expression in advance.
  ///
  /// In this example, the regular expression includes two parenthesized
  /// capture groups, so the capture type is `(Substring, Substring, Substring)`.
  /// The first substring in the tuple represents the entire match, while the
  /// second and third substrings represent the first and second capture group,
  /// respectively.
  ///
  ///     let keyAndValue = try Regex("(.+): (.+)", as: (Substring, Substring, Substring).self)
  ///
  /// This initializer throws an error if `pattern` uses invalid regular
  /// expression syntax, or if `outputType` does not match the capture
  /// structure declared by `pattern`. If you don't know the capture structure
  /// in advance, use the ``init(_:)`` initializer instead.
  ///
  /// - Parameters:
  ///   - pattern: A string with regular expression syntax.
  ///   - outputType: The desired type for the output captures.
  @_effects(readnone)
  public init(
    _ pattern: String,
    as outputType: Output.Type = Output.self
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

  /// Creates a regular expression that matches the given string exactly, as
  /// though every metacharacter in it was escaped.
  ///
  /// This example creates a regular expression that matches the string
  /// `"(adj)"`, including the parentheses. Although parentheses are regular
  /// expression metacharacters, they do not need escaping in the string passed
  /// as `verbatimString`.
  ///
  ///     let adjectiveDesignator = Regex<Substring>(verbatim: "(adj.)")
  ///
  ///     print("awesome (adj.)".contains(adjectiveDesignator))
  ///     // Prints "true"
  ///     print("apple (n.)".contains(adjectiveDesignator))
  ///     // Prints "false"
  ///
  /// - Parameter verbatimString: A string to convert into a regular expression
  ///   exactly, escaping any metacharacters.
  public init(verbatim verbatimString: String) {
    self.init(node: .quotedLiteral(verbatimString))
  }

  /// Returns a Boolean value indicating whether a named capture with the given
  /// name exists.
  ///
  /// This example shows a regular expression that includes capture groups
  /// named `key` and `value`:
  ///
  ///     let regex = try Regex("(?'key'.+?): (?'value'.+)")
  ///     regex.contains(captureNamed: "key")       // true
  ///     regex.contains(captureNamed: "VALUE")     // false
  ///     regex.contains(captureNamed: "1")         // false
  ///
  /// - Parameter name: The name to look for among the regular expression's
  ///   capture groups. Capture group names are case sensitive.
  public func contains(captureNamed name: String) -> Bool {
    program.list.captureList.captures.contains(where: {
      $0.name == name
    })
  }
}

// MARK: - Converting to/from ARO

@available(SwiftStdlib 5.7, *)
extension Regex where Output == AnyRegexOutput {
  /// Creates a regular expression with a dynamic capture list from the given
  /// regular expression.
  ///
  /// You can use this initializer to convert a `Regex` with strongly-typed
  /// captures into a `Regex` with `AnyRegexOutput` as its output type.
  ///
  /// - Parameter regex: A regular expression to convert to use a dynamic
  ///   capture list.
  public init<OtherOutput>(_ regex: Regex<OtherOutput>) {
    self.init(list: regex.list)
  }
}

@available(SwiftStdlib 5.7, *)
extension Regex.Match where Output == AnyRegexOutput {
  /// Creates a regular expression match with a dynamic capture list from the
  /// given match.
  ///
  /// You can use this initializer to convert a `Regex.Match` with
  /// strongly-typed captures into a match with the type-eraser `AnyRegexOutput`
  /// as its output type.
  ///
  /// - Parameter match: A regular expression match to convert to a match with
  ///   type-erased captures.
  public init<OtherOutput>(_ match: Regex<OtherOutput>.Match) {
    self.init(
      anyRegexOutput: match.anyRegexOutput,
      range: match.range
    )
  }
}

@available(SwiftStdlib 5.7, *)
extension Regex {
  /// Creates a regular expression with a strongly-typed capture list from the
  /// given regular expression.
  ///
  /// You can use this initializer to convert a regular expression with a
  /// dynamic capture list to one with a strongly-typed capture list. If the
  /// type you provide as `outputType` doesn't match the capture structure of
  /// `regex`, the initializer returns `nil`.
  ///
  ///     let dynamicRegex = try Regex("(.+?): (.+)")
  ///     if let stronglyTypedRegex = Regex(dynamicRegex, as: (Substring, Substring, Substring).self) {
  ///         print("Converted properly")
  ///     }
  ///     // Prints "Converted properly"
  ///
  /// - Parameters:
  ///   - regex: A regular expression to convert to use a strongly-typed capture
  ///     list.
  ///   - outputType: The capture structure to use.
  public init?(
    _ regex: Regex<AnyRegexOutput>,
    as outputType: Output.Type = Output.self
  ) {
    self.init(list: regex.list)
    
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
    
    /// A Boolean value indicating whether this capture should be included in
    /// the typed output.
    var visibleInTypedOutput: Bool
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
    func wrapIfNecessary<U>(_: U.Type) -> Any.Type {
      TypeConstruction.optionalType(of: U.self, depth: optionalDepth)
    }

    return content?.value.map {
      _openExistential(Swift.type(of: $0), do: wrapIfNecessary)
    } ?? TypeConstruction.optionalType(of: Substring.self, depth: optionalDepth)
  }
}
