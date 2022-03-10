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

// swift run VariadicsGenerator --max-arity 10 > Sources/_StringProcessing/RegexDSL/Variadics.swift

import ArgumentParser
#if os(macOS)
import Darwin
#elseif os(Linux)
import Glibc
#elseif os(Windows)
import CRT
#endif

// (T), (T)
// (T), (T, T)
// …
// (T), (T, T, T, T, T, T, T)
// (T, T), (T)
// (T, T), (T, T)
// …
// (T, T), (T, T, T, T, T, T)
// …
struct Permutations: Sequence {
  let totalArity: Int

  struct Iterator: IteratorProtocol {
    let totalArity: Int
    var leftArity: Int = 0
    var rightArity: Int = 0

    mutating func next() -> (combinedArity: Int, nextArity: Int)? {
      guard leftArity < totalArity else {
        return nil
      }
      defer {
        if leftArity + rightArity >= totalArity {
          leftArity += 1
          rightArity = 0
        } else {
          rightArity += 1
        }
      }
      return (leftArity, rightArity)
    }
  }

  public func makeIterator() -> Iterator {
    Iterator(totalArity: totalArity)
  }
}

func output(_ content: String) {
  print(content, terminator: "")
}

func outputForEach<C: Collection>(
  _ elements: C,
  separator: String? = nil,
  lineTerminator: String? = nil,
  _ content: (C.Element) -> String
) {
  for i in elements.indices {
    output(content(elements[i]))
    let needsSep = elements.index(after: i) != elements.endIndex
    if needsSep, let sep = separator {
      output(sep)
    }
    if let lt = lineTerminator {
      let indent = needsSep ? "      " : "    "
      output("\(lt)\n\(indent)")
    }
  }
}

struct StandardErrorStream: TextOutputStream {
  func write(_ string: String) {
    fputs(string, stderr)
  }
}
var standardError = StandardErrorStream()

typealias Counter = Int64
let regexComponentProtocolName = "RegexComponent"
let matchAssociatedTypeName = "Match"
let patternProtocolRequirementName = "regex"
let regexTypeName = "Regex"
let baseMatchTypeName = "Substring"
let concatBuilderName = "RegexComponentBuilder"
let altBuilderName = "AlternationBuilder"

@main
struct VariadicsGenerator: ParsableCommand {
  @Option(help: "The maximum arity of declarations to generate.")
  var maxArity: Int

  func run() throws {
    precondition(maxArity > 1)
    precondition(maxArity < Counter.bitWidth)

    output("""
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

      // BEGIN AUTO-GENERATED CONTENT

      import _MatchingEngine


      """)

    print("Generating concatenation overloads...", to: &standardError)
    for (leftArity, rightArity) in Permutations(totalArity: maxArity) {
      guard rightArity != 0 else {
        continue
      }
      print(
        "  Left arity: \(leftArity)  Right arity: \(rightArity)",
        to: &standardError)
      emitConcatenation(leftArity: leftArity, rightArity: rightArity)
    }

    for arity in 0...maxArity {
      emitConcatenationWithEmpty(leftArity: arity)
    }

    output("\n\n")

    print("Generating quantifiers...", to: &standardError)
    for arity in 0...maxArity {
      print("  Arity \(arity): ", terminator: "", to: &standardError)
      for kind in QuantifierKind.allCases {
        print("\(kind.rawValue) ", terminator: "", to: &standardError)
        emitQuantifier(kind: kind, arity: arity)
      }
      print("repeating ", terminator: "", to: &standardError)
      emitRepeating(arity: arity)
      print(to: &standardError)
    }

    print("Generating alternation overloads...", to: &standardError)
    for (leftArity, rightArity) in Permutations(totalArity: maxArity) {
      print(
        "  Left arity: \(leftArity)  Right arity: \(rightArity)",
        to: &standardError)
      emitAlternation(leftArity: leftArity, rightArity: rightArity)
    }

    print("Generating 'AlternationBuilder.buildBlock(_:)' overloads...", to: &standardError)
    for arity in 1...maxArity {
      print("  Capture arity: \(arity)", to: &standardError)
      emitUnaryAlternationBuildBlock(arity: arity)
    }

    print("Generating 'capture' and 'tryCapture' overloads...", to: &standardError)
    for arity in 0...maxArity {
      print("  Capture arity: \(arity)", to: &standardError)
      emitCapture(arity: arity)
    }

    output("\n\n")

    output("// END AUTO-GENERATED CONTENT\n")

    print("Done!", to: &standardError)
  }

  func tupleType(arity: Int, genericParameters: () -> String) -> String {
    assert(arity >= 0)
    if arity == 0 {
      return genericParameters()
    }
    return "(\(genericParameters()))"
  }

  func emitConcatenation(leftArity: Int, rightArity: Int) {
    let genericParams: String = {
      var result = "W0, W1"
      result += (0..<leftArity+rightArity).map {
        ", C\($0)"
      }.joined()
      result += ", R0: \(regexComponentProtocolName), R1: \(regexComponentProtocolName)"
      return result
    }()

    // Emit concatenation type declaration.

    let whereClause: String = {
      var result = " where R0.Match == "
      if leftArity == 0 {
        result += "W0"
      } else {
        result += "(W0"
        result += (0..<leftArity).map { ", C\($0)" }.joined()
        result += ")"
      }
      result += ", R1.Match == "
      if rightArity == 0 {
        result += "W1"
      } else {
        result += "(W1"
        result += (leftArity..<leftArity+rightArity).map { ", C\($0)" }.joined()
        result += ")"
      }
      return result
    }()

    let matchType: String = {
      if leftArity+rightArity == 0 {
        return baseMatchTypeName
      } else {
        return "(\(baseMatchTypeName), "
          + (0..<leftArity+rightArity).map { "C\($0)" }.joined(separator: ", ")
          + ")"
      }
    }()

    // Emit concatenation builder.
    output("extension \(concatBuilderName) {\n")
    output("""
        public static func buildBlock<\(genericParams)>(
          combining next: R1, into combined: R0
        ) -> \(regexTypeName)<\(matchType)> \(whereClause) {
          .init(node: combined.regex.root.appending(next.regex.root))
        }
      }

      """)
  }

  func emitConcatenationWithEmpty(leftArity: Int) {
    // T + () = T
    output("""
       extension \(concatBuilderName) {
         public static func buildBlock<W0
       """)
    outputForEach(0..<leftArity) {
      ", C\($0)"
    }
    output("""
      , R0: \(regexComponentProtocolName), R1: \(regexComponentProtocolName)>(
          combining next: R1, into combined: R0
        ) -> \(regexTypeName)<
      """)
    if leftArity == 0 {
      output(baseMatchTypeName)
    } else {
      output("(\(baseMatchTypeName)")
      outputForEach(0..<leftArity) {
        ", C\($0)"
      }
      output(")")
    }
    output("> where R0.\(matchAssociatedTypeName) == ")
    if leftArity == 0 {
      output("W0")
    } else {
      output("(W0")
      outputForEach(0..<leftArity) {
        ", C\($0)"
      }
      output(")")
    }
    output("""
        {
          .init(node: combined.regex.root.appending(next.regex.root))
        }
      }

      """)
  }

  enum QuantifierKind: String, CaseIterable {
    case zeroOrOne = "Optionally"
    case zeroOrMore = "ZeroOrMore"
    case oneOrMore = "OneOrMore"

    var operatorName: String {
      switch self {
      case .zeroOrOne: return ".?"
      case .zeroOrMore: return ".*"
      case .oneOrMore: return ".+"
      }
    }

    var astQuantifierAmount: String {
      switch self {
      case .zeroOrOne: return "zeroOrOne"
      case .zeroOrMore: return "zeroOrMore"
      case .oneOrMore: return "oneOrMore"
      }
    }
  }
  
  struct QuantifierParameters {
    var disfavored: String
    var genericParams: String
    var whereClauseForInit: String
    var whereClause: String
    var quantifiedCaptures: String
    var matchType: String
    
    var repeatingWhereClause: String {
      whereClauseForInit.isEmpty
        ? "where R.Bound == Int"
        : whereClauseForInit + ", R.Bound == Int"
    }
    
    init(kind: QuantifierKind, arity: Int) {
      self.disfavored = arity == 0 ? "@_disfavoredOverload\n" : ""
      self.genericParams = {
        var result = ""
        if arity > 0 {
          result += "W"
          result += (0..<arity).map { ", C\($0)" }.joined()
          result += ", "
        }
        result += "Component: \(regexComponentProtocolName)"
        return result
      }()
      
      let captures = (0..<arity).map { "C\($0)" }
      let capturesJoined = captures.joined(separator: ", ")
      self.quantifiedCaptures = {
        switch kind {
        case .zeroOrOne, .zeroOrMore:
          return captures.map { "\($0)?" }.joined(separator: ", ")
        case .oneOrMore:
          return capturesJoined
        }
      }()
      self.matchType = arity == 0
        ? baseMatchTypeName
        : "(\(baseMatchTypeName), \(quantifiedCaptures))"
      self.whereClauseForInit = "where \(matchAssociatedTypeName) == \(matchType)" +
        (arity == 0 ? "" : ", Component.Match == (W, \(capturesJoined))")
      self.whereClause = arity == 0 ? "" :
        "where Component.Match == (W, \(capturesJoined))"
    }
  }

  func emitQuantifier(kind: QuantifierKind, arity: Int) {
    assert(arity >= 0)
    let params = QuantifierParameters(kind: kind, arity: arity)
    output("""
      extension \(kind.rawValue) {
        \(params.disfavored)\
        public init<\(params.genericParams)>(
          _ component: Component,
          _ behavior: QuantificationBehavior = .eagerly
        ) \(params.whereClauseForInit) {
          self.init(node: .quantification(.\(kind.astQuantifierAmount), behavior.astKind, component.regex.root))
        }
      }

      extension \(kind.rawValue) {
        \(params.disfavored)\
        public init<\(params.genericParams)>(
          _ behavior: QuantificationBehavior = .eagerly,
          @\(concatBuilderName) _ component: () -> Component
        ) \(params.whereClauseForInit) {
          self.init(node: .quantification(.\(kind.astQuantifierAmount), behavior.astKind, component().regex.root))
        }
      }

      \(params.disfavored)\
      public postfix func \(kind.operatorName)<\(params.genericParams)>(
        _ component: Component
      ) -> \(kind.rawValue)<\(params.matchType)> \(params.whereClause) {
        .init(node: .quantification(.\(kind.astQuantifierAmount), .eager, component.regex.root))
      }

      \(kind == .zeroOrOne ?
        """
        extension \(concatBuilderName) {
          public static func buildLimitedAvailability<\(params.genericParams)>(
            _ component: Component
          ) -> \(regexTypeName)<\(params.matchType)> \(params.whereClause) {
            .init(node: .quantification(.\(kind.astQuantifierAmount), .eager, component.regex.root))
          }
        }
        """ : "")

      """)
  }
  
  func emitRepeating(arity: Int) {
    assert(arity >= 0)
    // `repeat(..<5)` has the same generic semantics as zeroOrMore
    let params = QuantifierParameters(kind: .zeroOrMore, arity: arity)
    // TODO: Could `repeat(count:)` have the same generic semantics as oneOrMore?
    // We would need to prohibit `repeat(count: 0)`; can only happen at runtime
    
    output("""
      extension Repeat {
        \(params.disfavored)\
        public init<\(params.genericParams)>(
          _ component: Component,
          count: Int
        ) \(params.whereClauseForInit) {
          assert(count > 0, "Must specify a positive count")
          // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
          self.init(node: .quantification(.exactly(.init(faking: count)), .eager, component.regex.root))
        }

        \(params.disfavored)\
        public init<\(params.genericParams)>(
          count: Int,
          @\(concatBuilderName) _ component: () -> Component
        ) \(params.whereClauseForInit) {
          assert(count > 0, "Must specify a positive count")
          // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
          self.init(node: .quantification(.exactly(.init(faking: count)), .eager, component().regex.root))
        }

        \(params.disfavored)\
        public init<\(params.genericParams), R: RangeExpression>(
          _ component: Component,
          _ expression: R,
          _ behavior: QuantificationBehavior = .eagerly
        ) \(params.repeatingWhereClause) {
          self.init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component.regex.root))
        }

        \(params.disfavored)\
        public init<\(params.genericParams), R: RangeExpression>(
          _ expression: R,
          _ behavior: QuantificationBehavior = .eagerly,
          @\(concatBuilderName) _ component: () -> Component
        ) \(params.repeatingWhereClause) {
          self.init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component().regex.root))
        }
      }
      
      """)
  }

  func emitAlternation(leftArity: Int, rightArity: Int) {
    let leftGenParams: String = {
      if leftArity == 0 {
        return "R0"
      }
      return "R0, W0, " + (0..<leftArity).map { "C\($0)" }.joined(separator: ", ")
    }()
    let rightGenParams: String = {
      if rightArity == 0 {
        return "R1"
      }
      return "R1, W1, " + (leftArity..<leftArity+rightArity).map { "C\($0)" }.joined(separator: ", ")
    }()
    let genericParams = leftGenParams + ", " + rightGenParams
    let whereClause: String = {
      var result = "where R0: \(regexComponentProtocolName), R1: \(regexComponentProtocolName)"
      if leftArity > 0 {
        result += ", R0.\(matchAssociatedTypeName) == (W0, \((0..<leftArity).map { "C\($0)" }.joined(separator: ", ")))"
      }
      if rightArity > 0 {
        result += ", R1.\(matchAssociatedTypeName) == (W1, \((leftArity..<leftArity+rightArity).map { "C\($0)" }.joined(separator: ", ")))"
      }
      return result
    }()
    let resultCaptures: String = {
      var result = (0..<leftArity).map { "C\($0)" }.joined(separator: ", ")
      if leftArity > 0, rightArity > 0 {
        result += ", "
      }
      result += (leftArity..<leftArity+rightArity).map { "C\($0)?" }.joined(separator: ", ")
      return result
    }()
    let matchType: String = {
      if leftArity == 0, rightArity == 0 {
        return baseMatchTypeName
      }
      return "(\(baseMatchTypeName), \(resultCaptures))"
    }()
    output("""
      extension \(altBuilderName) {
        public static func buildBlock<\(genericParams)>(
          combining next: R1, into combined: R0
        ) -> ChoiceOf<\(matchType)> \(whereClause) {
          .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
        }
      }

      public func | <\(genericParams)>(lhs: R0, rhs: R1) -> ChoiceOf<\(matchType)> \(whereClause) {
        .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
      }

      """)
  }

  func emitUnaryAlternationBuildBlock(arity: Int) {
    assert(arity > 0)
    let captures = (0..<arity).map { "C\($0)" }.joined(separator: ", ")
    let genericParams: String = {
      if arity == 0 {
        return "R"
      }
      return "R, W, " + captures
    }()
    let whereClause: String = """
      where R: \(regexComponentProtocolName), \
      R.\(matchAssociatedTypeName) == (W, \(captures))
      """
    let resultCaptures = (0..<arity).map { "C\($0)?" }.joined(separator: ", ")
    output("""
      extension \(altBuilderName) {
        public static func buildBlock<\(genericParams)>(_ regex: R) -> ChoiceOf<(W, \(resultCaptures))> \(whereClause) {
          .init(node: .alternation([regex.regex.root]))
        }
      }
      
      """)
  }

  func emitCapture(arity: Int) {
    let disfavored = arity == 0 ? "@_disfavoredOverload\n" : ""
    let genericParams = arity == 0
      ? "R: \(regexComponentProtocolName), W"
      : "R: \(regexComponentProtocolName), W, " + (0..<arity).map { "C\($0)" }.joined(separator: ", ")
    let matchType = arity == 0
      ? "W"
      : "(W, " + (0..<arity).map { "C\($0)" }.joined(separator: ", ") + ")"
    func newMatchType(newCaptureType: String) -> String {
      return arity == 0
        ? "(\(baseMatchTypeName), \(newCaptureType))"
        : "(\(baseMatchTypeName), \(newCaptureType), " + (0..<arity).map { "C\($0)" }.joined(separator: ", ") + ")"
    }
    let rawNewMatchType = newMatchType(newCaptureType: "W")
    let transformedNewMatchType = newMatchType(newCaptureType: "NewCapture")
    let whereClauseRaw = "where \(matchAssociatedTypeName) == \(rawNewMatchType), R.\(matchAssociatedTypeName) == \(matchType)"
    let whereClauseTransformed = "where \(matchAssociatedTypeName) == \(transformedNewMatchType), R.\(matchAssociatedTypeName) == \(matchType)"
    output("""
      // MARK: - Non-builder capture arity \(arity)

      extension Capture {
        \(disfavored)\
        public init<\(genericParams)>(
          _ component: R
        ) \(whereClauseRaw) {
          self.init(node: .group(.capture, component.regex.root))
        }

        \(disfavored)\
        public init<\(genericParams)>(
          _ component: R, as reference: Reference<W>
        ) \(whereClauseRaw) {
          self.init(node: .group(.capture, component.regex.root, reference.id))
        }

        \(disfavored)\
        public init<\(genericParams), NewCapture>(
          _ component: R,
          transform: @escaping (Substring) -> NewCapture
        ) \(whereClauseTransformed) {
          self.init(node: .groupTransform(
            .capture,
            component.regex.root,
            CaptureTransform(resultType: NewCapture.self) {
              transform($0) as Any
            }))
        }

        \(disfavored)\
        public init<\(genericParams), NewCapture>(
          _ component: R,
          as reference: Reference<NewCapture>,
          transform: @escaping (Substring) -> NewCapture
        ) \(whereClauseTransformed) {
          self.init(node: .groupTransform(
            .capture,
            component.regex.root,
            CaptureTransform(resultType: NewCapture.self) {
              transform($0) as Any
            },
            reference.id))
        }
      }

      extension TryCapture {
        \(disfavored)\
        public init<\(genericParams), NewCapture>(
          _ component: R,
          transform: @escaping (Substring) throws -> NewCapture
        ) \(whereClauseTransformed) {
          self.init(node: .groupTransform(
            .capture,
            component.regex.root,
            CaptureTransform(resultType: NewCapture.self) {
              try transform($0) as Any
            }))
        }

        \(disfavored)\
        public init<\(genericParams), NewCapture>(
          _ component: R,
          as reference: Reference<NewCapture>,
          transform: @escaping (Substring) throws -> NewCapture
        ) \(whereClauseTransformed) {
          self.init(node: .groupTransform(
            .capture,
            component.regex.root,
            CaptureTransform(resultType: NewCapture.self) {
              try transform($0) as Any
            },
            reference.id))
        }

        \(disfavored)\
        public init<\(genericParams), NewCapture>(
          _ component: R,
          transform: @escaping (Substring) -> NewCapture?
        ) \(whereClauseTransformed) {
          self.init(node: .groupTransform(
            .capture,
            component.regex.root,
            CaptureTransform(resultType: NewCapture.self) {
              transform($0) as Any?
            }))
        }

        \(disfavored)\
        public init<\(genericParams), NewCapture>(
          _ component: R,
          as reference: Reference<NewCapture>,
          transform: @escaping (Substring) -> NewCapture?
        ) \(whereClauseTransformed) {
          self.init(node: .groupTransform(
            .capture,
            component.regex.root,
            CaptureTransform(resultType: NewCapture.self) {
              transform($0) as Any?
            },
            reference.id))
        }
      }

      // MARK: - Builder capture arity \(arity)

      extension Capture {
        \(disfavored)\
        public init<\(genericParams)>(
          @\(concatBuilderName) _ component: () -> R
        ) \(whereClauseRaw) {
          self.init(node: .group(.capture, component().regex.root))
        }

        \(disfavored)\
        public init<\(genericParams)>(
          as reference: Reference<W>,
          @\(concatBuilderName) _ component: () -> R
        ) \(whereClauseRaw) {
          self.init(node: .group(.capture, component().regex.root, reference.id))
        }

        \(disfavored)\
        public init<\(genericParams), NewCapture>(
          @\(concatBuilderName) _ component: () -> R,
          transform: @escaping (Substring) -> NewCapture
        ) \(whereClauseTransformed) {
          self.init(node: .groupTransform(
            .capture,
            component().regex.root,
            CaptureTransform(resultType: NewCapture.self) {
              transform($0) as Any
            }))
        }

        \(disfavored)\
        public init<\(genericParams), NewCapture>(
          as reference: Reference<NewCapture>,
          @\(concatBuilderName) _ component: () -> R,
          transform: @escaping (Substring) -> NewCapture
        ) \(whereClauseTransformed) {
          self.init(node: .groupTransform(
            .capture,
            component().regex.root,
            CaptureTransform(resultType: NewCapture.self) {
              transform($0) as Any
            },
            reference.id))
        }
      }

      extension TryCapture {
        \(disfavored)\
        public init<\(genericParams), NewCapture>(
          @\(concatBuilderName) _ component: () -> R,
          transform: @escaping (Substring) throws -> NewCapture
        ) \(whereClauseTransformed) {
          self.init(node: .groupTransform(
            .capture,
            component().regex.root,
            CaptureTransform(resultType: NewCapture.self) {
              try transform($0) as Any
            }))
        }

        \(disfavored)\
        public init<\(genericParams), NewCapture>(
          as reference: Reference<NewCapture>,
          @\(concatBuilderName) _ component: () -> R,
          transform: @escaping (Substring) throws -> NewCapture
        ) \(whereClauseTransformed) {
          self.init(node: .groupTransform(
            .capture,
            component().regex.root,
            CaptureTransform(resultType: NewCapture.self) {
              try transform($0) as Any
            },
            reference.id))
        }

        \(disfavored)\
        public init<\(genericParams), NewCapture>(
          @\(concatBuilderName) _ component: () -> R,
          transform: @escaping (Substring) -> NewCapture?
        ) \(whereClauseTransformed) {
          self.init(node: .groupTransform(
            .capture,
            component().regex.root,
            CaptureTransform(resultType: NewCapture.self) {
              transform($0) as Any?
            }))
        }

        \(disfavored)\
        public init<\(genericParams), NewCapture>(
          as reference: Reference<NewCapture>,
          @\(concatBuilderName) _ component: () -> R,
          transform: @escaping (Substring) -> NewCapture?
        ) \(whereClauseTransformed) {
          self.init(node: .groupTransform(
            .capture,
            component().regex.root,
            CaptureTransform(resultType: NewCapture.self) {
              transform($0) as Any?
            },
            reference.id))
        }
      }


      """)
  }
}
