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

class Compiler {
  let tree: DSLList

  // TODO: Or are these stored on the tree?
  var options = MatchingOptions()
  private var compileOptions: _CompileOptions = .default

  init(ast: AST) {
    self.tree = DSLList(tree: ast.dslTree)
  }

  init(tree: DSLTree) {
    self.tree = DSLList(tree: tree)
  }

  init(list: DSLList) {
    self.tree = list
  }

  init(tree: DSLTree, compileOptions: _CompileOptions) {
    self.tree = DSLList(tree: tree)
    self.compileOptions = compileOptions
  }

  init(tree: DSLList, compileOptions: _CompileOptions) {
    self.tree = tree
    self.compileOptions = compileOptions
  }

  __consuming func emit() throws -> MEProgram {
    try emitViaList()
  }
  
  __consuming func emitViaTree() throws -> MEProgram {
    // TODO: Handle global options
    var codegen = ByteCodeGen(
      options: options,
      compileOptions:
        compileOptions,
      captureList: tree.captureList)
    fatalError()
//    return try codegen.emitRoot(tree.root)
  }
  
  __consuming func emitViaList() throws -> MEProgram {
    // TODO: Handle global options
//    var dslList = DSLList(tree: tree)
    var codegen = ByteCodeGen(
      options: options,
      compileOptions:
        compileOptions,
      captureList: tree.captureList)
    var tree = tree
    return try codegen.emitRoot(&tree)
  }
}

/// Hashable wrapper for `Any.Type`.
struct AnyHashableType: CustomStringConvertible, Hashable {
  var ty: Any.Type
  init(_ ty: Any.Type) {
    self.ty = ty
  }
  var description: String { "\(ty)" }

  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.ty == rhs.ty
  }
  func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(ty))
  }
}

// An error produced when compiling a regular expression.
enum RegexCompilationError: Error, Hashable, CustomStringConvertible {
  // TODO: Source location?
  case uncapturedReference
  case incorrectOutputType(incorrect: AnyHashableType, correct: AnyHashableType)
  case invalidCharacterClassRangeOperand(Character)

  static func incorrectOutputType(
    incorrect: Any.Type, correct: Any.Type
  ) -> Self {
    .incorrectOutputType(incorrect: .init(incorrect), correct: .init(correct))
  }

  var description: String {
    switch self {
    case .uncapturedReference:
      return "Found a reference used before it captured any match."
    case .incorrectOutputType(let incorrect, let correct):
      return "Cast to incorrect type 'Regex<\(incorrect)>', expected 'Regex<\(correct)>'"
    case .invalidCharacterClassRangeOperand(let c):
      return "'\(c)' is an invalid bound for character class range"
    }
  }
}

// Testing support
@available(SwiftStdlib 5.7, *)
func _compileRegex(
  _ regex: String,
  _ syntax: SyntaxOptions = .traditional,
  _ semanticLevel: RegexSemanticLevel? = nil
) throws -> MEProgram {
  var ast = try parse(regex, syntax)
  let dsl: DSLList

  switch semanticLevel?.base {
  case .graphemeCluster:
    let sequence = AST.MatchingOptionSequence(adding: [.init(.graphemeClusterSemantics, location: .fake)])
    ast.root = AST.Node.group(AST.Group(.init(faking: .changeMatchingOptions(sequence)), ast.root, .fake))
    dsl = DSLList(ast: ast)
  case .unicodeScalar:
    let sequence = AST.MatchingOptionSequence(adding: [.init(.unicodeScalarSemantics, location: .fake)])
    ast.root = AST.Node.group(AST.Group(.init(faking: .changeMatchingOptions(sequence)), ast.root, .fake))
    dsl = DSLList(ast: ast)
  case .none:
    dsl = DSLList(ast: ast)
  }
  let program = try Compiler(list: dsl).emit()
  return program
}

@_spi(RegexBenchmark)
public struct _CompileOptions: OptionSet {
  public let rawValue: Int
  public init(rawValue: Int) {
    self.rawValue = rawValue
  }

  public static let disableOptimizations = _CompileOptions(rawValue: 1 << 0)
  public static let enableTracing = _CompileOptions(rawValue: 1 << 1)
  public static let enableMetrics = _CompileOptions(rawValue: 1 << 2)
  public static let `default`: _CompileOptions = []
}
