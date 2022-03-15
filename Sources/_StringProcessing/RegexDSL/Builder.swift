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

@resultBuilder
public enum RegexComponentBuilder {
  public static func buildBlock() -> Regex<Substring> {
    .init(node: .empty)
  }

  /// A builder component that stores a regex component and its source location
  /// for debugging purposes.
  public struct Component<Value: RegexComponent>: RegexComponent {
    public var value: Value
    public var file: String
    public var function: String
    public var line: Int
    public var column: Int

    var location: DSLSourceLocation {
      .init(file: file, function: function, line: line, column: column)
    }

    public var regex: Regex<Value.Match> {
      .init(node: .located(value.regex.root, location))
    }
  }

  public static func buildPartialBlock<R: RegexComponent>(first: R) -> R {
    first
  }

  public static func buildExpression<R: RegexComponent>(
    _ regex: R,
    file: String = #file,
    function: String = #function,
    line: Int = #line,
    column: Int = #column
  ) -> Component<R> {
    .init(
      value: regex, file: file, function: function, line: line, column: column)
  }

  public static func buildEither<R: RegexComponent>(first component: R) -> R {
    component
  }

  public static func buildEither<R: RegexComponent>(second component: R) -> R {
    component
  }
}
