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

@available(macOS 9999, *) // TODO: 5.9?
public struct PrintableRegex<Output>: RegexComponent, @unchecked Sendable
{
  public var regex: Regex<Output>

  internal var text: String

  public init?(_ re: Regex<Output>) {
    guard case .convertedRegexLiteral(_, let ast) = re.program.tree.root
    else {
      return nil
    }
    self.regex = re
    let str = ast.ast.renderAsCanonical()
    self.text = str
  }
}


@available(macOS 9999, *) // TODO: 5.9?
extension PrintableRegex: Hashable {
  public static func == (
    lhs: PrintableRegex<Output>, rhs: PrintableRegex<Output>
  ) -> Bool {
    lhs.text == rhs.text
  }
  public func hash(into hasher: inout Hasher) {
    text.hash(into: &hasher)
  }
}

// FIXME: Do we only work with ARO as the output type?

@available(macOS 9999, *) // TODO: 5.9?
extension PrintableRegex: Codable {
  private init(coding re: Regex<Output>) throws {
    guard case .convertedRegexLiteral = re.program.tree.root else {
      throw DecodingError.error
    }
    self.regex = re
    fatalError()
  }

  private enum DecodingError: Error {
    case error
  }
  enum CodingKeys: CodingKey {
    case string
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let str = try values.decode(String.self, forKey: .string)
    guard let pre = try PrintableRegex(Regex(str)) else {
      throw DecodingError.error
    }
    self = pre
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(text, forKey: .string)
  }
}

// MARK: - mock API

@available(macOS 9999, *) // TODO: 5.9?
extension Regex {
  public var printable: PrintableRegex<Output>? { .init(self) }
}

@available(macOS 9999, *) // TODO: 5.9?
public enum RegexSyntax {
  case swift
  case pcre2
  case sql
  case icu
  // ...
}

@available(macOS 9999, *) // TODO: 5.9?
extension PrintableRegex {
  public func print(using syntax: RegexSyntax = .swift) -> String {
    switch syntax {
    case .swift: return text
    default: fatalError()
    }
  }
}

@available(macOS 9999, *) // TODO: 5.9?
extension PrintableRegex: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    text
  }

  public var debugDescription: String {
    "/\(text)/"
  }
}


@available(macOS 9999, *) // TODO: 5.9?
extension PrintableRegex: LosslessStringConvertible {
  public init?(_ description: String) {
    guard let re = try? Regex<Output>(description) else {
      return nil
    }
    self.init(re)
  }


}
