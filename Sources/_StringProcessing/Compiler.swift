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

class Compiler {
  let tree: DSLTree

  // TODO: Or are these stored on the tree?
  var options = MatchingOptions()

  init(ast: AST) {
    self.tree = ast.dslTree
  }

  init(tree: DSLTree) {
    self.tree = tree
  }

  __consuming func emit() throws -> MEProgram {
    // TODO: Handle global options
    var codegen = ByteCodeGen(
      options: options, captureList: tree.captureList
    )
    return try codegen.emitRoot(tree.root)
  }
}

func _compileRegex(
  _ regex: String, _ syntax: SyntaxOptions = .traditional
) throws -> Executor {
  let ast = try parse(regex, .semantic, syntax)
  let program = try Compiler(ast: ast).emit()
  return Executor(program: program)
}

// An error produced when compiling a regular expression.
enum RegexCompilationError: Error, CustomStringConvertible {
  // TODO: Source location?
  case uncapturedReference

  var description: String {
    switch self {
    case .uncapturedReference:
      return "Found a reference used before it captured any match."
    }
  }
}
