// swift run VariadicsGenerator --max-arity 10 > Sources/RegexDSL/Concatenation.swift

import ArgumentParser

struct Permutation {
  let arity: Int
  // 1 -> no extra constraint
  // 0 -> where T.CaptureValue: NoCaptureProtocol
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
  _ elements: C, separator: String, _ content: (C.Element) -> String
) {
  for i in elements.indices {
    output(content(elements[i]))
    if elements.index(after: i) != elements.endIndex {
      output(separator)
    }
  }
}

typealias Counter = Int64
let patternProtocolName = "RegexProtocol"
let concatenationStructTypeBaseName = "Concatenate"
let matchValueAssociatedTypeName = "MatchValue"
let captureValueAssociatedTypeName = "CaptureValue"
let patternBuilderTypeName = "RegexBuilder"
let patternProtocolRequirementName = "regex"
let PatternTypeBaseName = "Regex"
let emptyProtocolName = "EmptyProtocol"
let emptyStructName = "Empty"

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

    output("// BEGIN AUTO-GENERATED CONTENT\n\n\n")

    for arity in minArity...maxArity {
      emitDeclarations(arity: arity)
      output("\n\n")
    }

    output("// END AUTO-GENERATED CONTENT")
  }

  func emitDeclarations(arity: Int) {
    for permutation in Permutations(arity: arity) {
      // Emit type declarations.
      let typeName = "\(concatenationStructTypeBaseName)\(arity)_\(permutation.identifier)"
      output("public struct \(typeName)<")
      outputForEach(0..<arity, separator: ", ") { "T\($0): \(patternProtocolName)" }
      output(">: \(patternProtocolName)")
      if permutation.hasCaptureless {
        output(" where ")
        outputForEach(permutation.capturelessIndices, separator: ", ") {
          "T\($0).\(captureValueAssociatedTypeName): \(emptyProtocolName)"
        }
      }
      output(" {\n")
      output("  public typealias \(matchValueAssociatedTypeName) = ")
      let captureIndices = permutation.captureIndices
      let matchElements = captureIndices
        .map { "T\($0).\(matchValueAssociatedTypeName)" }
      if matchElements.isEmpty {
        output(emptyStructName)
      } else {
        output("(\(matchElements.joined(separator: ", ")))")
      }
      output("\n")
      output("  public typealias \(captureValueAssociatedTypeName) = ")
      let captureElements = captureIndices
        .map { "T\($0).\(captureValueAssociatedTypeName)" }
      if captureElements.isEmpty {
        output(emptyStructName)
      } else {
        output("(\(captureElements.joined(separator: ", ")))")
      }
      output("\n")
      output("  public let \(patternProtocolRequirementName): \(PatternTypeBaseName)<\(captureValueAssociatedTypeName)>\n")
      output("  init(")
      outputForEach(0..<arity, separator: ", ") { "_ x\($0): T\($0)" }
      output(") {\n")
      output("    \(patternProtocolRequirementName) = .init(ast: .concatenation([")
      outputForEach(0..<arity, separator: ", ") { i in
        "x\(i).\(patternProtocolRequirementName).ast"
      }
      output("]))\n")
      output("  }\n}\n\n")

      // Emit builders.
      output("extension \(patternBuilderTypeName) {\n")
      output("  public static func buildBlock<")
      outputForEach(0..<arity, separator: ", ") { "T\($0)" }
      output(">(\n    ")
      outputForEach(0..<arity, separator: ", ") { "_ x\($0): T\($0)" }
      output("\n  ) -> \(typeName)<")
      outputForEach(0..<arity, separator: ", ") { "T\($0)" }
      output("> {\n")
      output("    \(typeName)(")
      outputForEach(0..<arity, separator: ", ") { "x\($0)" }
      output(")\n  }\n}\n\n")
    }
  }
}
