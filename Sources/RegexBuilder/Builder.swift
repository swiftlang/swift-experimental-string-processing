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

@_spi(RegexBuilder) import _StringProcessing

@available(SwiftStdlib 5.7, *)
@resultBuilder
public enum RegexComponentBuilder {
  /// A builder component that stores a regex component and its source location
   /// for debugging purposes.
  public struct Component<Value: RegexComponent>: RegexComponent {
     public let value: Value
     public let file: String
     public let function: String
     public let line: Int
     public let column: Int

    @usableFromInline
    internal init(value: Value, file: String, function: String, line: Int, column: Int) {
      self.value = value
      self.file = file
      self.function = function
      self.line = line
      self.column = column
    }

     public var regex: Regex<Value.RegexOutput> {
       _RegexFactory().located(value, file, function, line, column)
     }
   }

  public static func buildBlock() -> Regex<Substring> {
    _RegexFactory().empty()
  }

  @_alwaysEmitIntoClient
  public static func buildPartialBlock<R: RegexComponent>(
    first component: Component<R>
  ) -> Regex<R.RegexOutput> {
    component.regex
  }

  @_alwaysEmitIntoClient
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
}
