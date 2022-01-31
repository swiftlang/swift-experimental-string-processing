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

// swift run VariadicsGenerator --max-arity 7 > Sources/_StringProcessing/RegexDSL/Concatenation.swift

import ArgumentParser

struct Permutation {
  let arity: Int
  // 1 -> no extra constraint
  // 0 -> where T.Match: NoCaptureProtocol
  let bits: Int64

  func isCaptureless(at index: Int) -> Bool {
    bits & (1 << index) != 0
  }

  var hasCaptureless: Bool {
    bits != 0
  }

  func hasCaptureless(beyond index: Int) -> Bool {
    bits >> (index + 1) != 0
  }

  var identifier: String {
    var result = ""
    for i in 0..<arity {
      result.append(isCaptureless(at: i) ? "V" : "T")
    }
    return String(result.reversed())
  }

  var capturelessIndices: [Int] {
    (0..<arity).filter { isCaptureless(at: $0) }
  }

  var captureIndices: [Int] {
    (0..<arity).filter { !isCaptureless(at: $0) }
  }
}

struct Permutations: Sequence {
  let arity: Int

  struct Iterator: IteratorProtocol {
    let arity: Int
    var counter = Int64(0)

    mutating func next() -> Permutation? {
      guard counter & (1 << arity) == 0 else {
        return nil
      }
      defer { counter += 1 }
      return Permutation(arity: arity, bits: counter)
    }
  }

  public func makeIterator() -> Iterator {
    Iterator(arity: arity)
  }
}

func output(_ content: String) {
  print(content, terminator: "")
}

func outputForEach<C: Collection>(
  _ elements: C,
  separator: String,
  lineTerminator: String? = nil,
  _ content: (C.Element) -> String
) {
  for i in elements.indices {
    output(content(elements[i]))
    let needsSep = elements.index(after: i) != elements.endIndex
    if needsSep {
      output(separator)
    }
    if let lt = lineTerminator {
      let indent = needsSep ? "      " : "    "
      output("\(lt)\n\(indent)")
    }
  }
}

typealias Counter = Int64
let patternProtocolName = "RegexProtocol"
let concatenationStructTypeBaseName = "Concatenate"
let capturingGroupTypeBaseName = "CapturingGroup"
let matchAssociatedTypeName = "Match"
let captureAssociatedTypeName = "Capture"
let patternBuilderTypeName = "RegexBuilder"
let patternProtocolRequirementName = "regex"
let PatternTypeBaseName = "Regex"
let emptyProtocolName = "EmptyCaptureProtocol"
let baseMatchTypeName = "Substring"

@main
struct VariadicsGenerator: ParsableCommand {
  @Option(help: "The minimum arity of declarations to generate.")
  var minArity: Int = 2

  @Option(help: "The maximum arity of declarations to generate.")
  var maxArity: Int

  func run() throws {
    precondition(minArity > 0)
    precondition(maxArity > 1)
    precondition(maxArity < Counter.bitWidth)

    output("""
      // BEGIN AUTO-GENERATED CONTENT

      import _MatchingEngine


      """)

    for arity in 2...maxArity+1 {
      emitTupleStruct(arity: arity)
    }

    for arity in minArity...maxArity {
      for permutation in Permutations(arity: arity) {
        emitConcatenation(permutation: permutation)
      }
      output("\n\n")
    }

    output("// END AUTO-GENERATED CONTENT")
  }

  func emitTupleStruct(arity: Int) {
    output("""
      @frozen @dynamicMemberLookup
      public struct Tuple\(arity)<
      """)
    outputForEach(0..<arity, separator: ", ") {
      "_\($0)"
    }
    output("> {")
    // `public typealias Tuple = (_0, ...)`
    output("\n  public typealias Tuple = (")
    outputForEach(0..<arity, separator: ", ") { "_\($0)" }
    output(")")
    // `public var tuple: Tuple`
    output("\n  public var tuple: Tuple\n")
    // `subscript(dynamicMember:)`
    output("""
        public subscript<T>(dynamicMember keyPath: WritableKeyPath<Tuple, T>) -> T {
          get { tuple[keyPath: keyPath] }
          _modify { yield &tuple[keyPath: keyPath] }
        }
      """)
    output("\n}\n")
    output("extension Tuple\(arity): \(emptyProtocolName) where ")
    outputForEach(1..<arity, separator: ", ") {
      "_\($0): \(emptyProtocolName)"
    }
    output(" {}\n")
    output("extension Tuple\(arity): MatchProtocol {\n")
    output("  public typealias Capture = ")
    if arity == 2 {
      output("_1")
    } else {
      output("Tuple\(arity-1)<")
      outputForEach(1..<arity, separator: ", ") {
        "_\($0)"
      }
      output(">")
    }
    output("\n  public init(_ tuple: Tuple) { self.tuple = tuple }")
    // `public init(_0: _0, ...) { ... }`
    output("\n  public init(")
    outputForEach(0..<arity, separator: ", ") {
      "_ _\($0): _\($0)"
    }
    output(") {\n")
    output("    self.init((")
    outputForEach(0..<arity, separator: ", ") { "_\($0)" }
    output("))\n")
    output("  }")
    output("\n}\n")
    // Equatable
    output("extension Tuple\(arity): Equatable where ")
    outputForEach(0..<arity, separator: ", ") {
      "_\($0): Equatable"
    }
    output(" {\n")
    output("  public static func == (lhs: Self, rhs: Self) -> Bool {\n")
    output("    ")
    outputForEach(0..<arity, separator: " && ") {
      "lhs.tuple.\($0) == rhs.tuple.\($0)"
    }
    output("\n  }\n")
    output("}\n")
  }

  func emitConcatenation(permutation: Permutation) {
    let arity = permutation.arity

    func emitGenericParameters(withConstraints: Bool) {
      outputForEach(0..<arity, separator: ", ") {
        var base = "T\($0)"
        if withConstraints {
          base += ": \(patternProtocolName)"
        }
        return base
      }
    }

    // Emit concatenation type declarations.
    //   public struct Concatenation{n}_{perm}<...>: RegexProtocol {
    //     public typealias Match = ...
    //     public let regex: Regex<Match>
    //     public init(...) { ... }
    //   }
    let typeName =
      "\(concatenationStructTypeBaseName)\(arity)_\(permutation.identifier)"
    output("public struct \(typeName)<\n  ")
    emitGenericParameters(withConstraints: true)
    output("\n>: \(patternProtocolName)")
    if permutation.hasCaptureless {
      output(" where ")
      outputForEach(permutation.capturelessIndices, separator: ", ") {
        "T\($0).\(matchAssociatedTypeName).\(captureAssociatedTypeName): \(emptyProtocolName)"
      }
    }
    output(" {\n")
    let captureIndices = permutation.captureIndices
    output("  public typealias \(matchAssociatedTypeName) = ")
    let captureElements = captureIndices
      .map { "T\($0).\(matchAssociatedTypeName).\(captureAssociatedTypeName)" }
    if captureElements.isEmpty {
      output(baseMatchTypeName)
    } else {
      let count = captureElements.count + 1
      output("Tuple\(count)<\(baseMatchTypeName), \(captureElements.joined(separator: ", "))>")
    }
    output("\n")
    output("  public let \(patternProtocolRequirementName): \(PatternTypeBaseName)<\(matchAssociatedTypeName)>\n")
    output("  init(")
    outputForEach(0..<arity, separator: ", ") { "_ x\($0): T\($0)" }
    output(") {\n")
    output("    \(patternProtocolRequirementName) = .init(node: .concatenation([\n      ")
    outputForEach(
      0..<arity, separator: ", ", lineTerminator: ""
    ) { i in
      "x\(i).\(patternProtocolRequirementName).root"
    }
    output("]))\n")
    output("  }\n}\n\n")

    // Emit concatenation builders.
    output("extension \(patternBuilderTypeName) {\n")
    output("  public static func buildBlock<")
    emitGenericParameters(withConstraints: true)
    output(">(\n    ")
    outputForEach(0..<arity, separator: ", ") { "_ x\($0): T\($0)" }
    output("\n  ) -> \(typeName)<")
    emitGenericParameters(withConstraints: false)
    output("> {\n")
    output("    \(typeName)(")
    outputForEach(0..<arity, separator: ", ") { "x\($0)" }
    output(")\n  }\n}\n\n")
  }
}
