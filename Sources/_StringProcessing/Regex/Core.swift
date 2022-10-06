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

/// A type that represents a regular expression.
@available(SwiftStdlib 5.7, *)
public protocol RegexComponent<RegexOutput> {
  associatedtype RegexOutput
  var regex: Regex<RegexOutput> { get }
}

/// A regular expression.
///
///     let regex = try Regex("a(.*)b")
///     let match = "cbaxb".firstMatch(of: regex)
///     print(match.0) // "axb"
///     print(match.1) // "x"
///
@available(SwiftStdlib 5.7, *)
public struct Regex<Output>: RegexComponent {
  let program: Program

  var hasCapture: Bool {
    program.tree.hasCapture
  }

  init(ast: AST) {
    self.program = Program(ast: ast)
  }
  init(ast: AST.Node) {
    self.program = Program(ast:
        .init(ast, globalOptions: nil, diags: Diagnostics()))
  }

  // Compiler interface. Do not change independently.
  @usableFromInline
  init(_regexString pattern: String) {
    self.init(ast: try! parse(pattern, .traditional))
  }

  // Compiler interface. Do not change independently.
  @usableFromInline
  init(_regexString pattern: String, version: Int) {
    assert(version == currentRegexLiteralFormatVersion)
    // The version argument is passed by the compiler using the value defined
    // in libswiftParseRegexLiteral.
    self.init(ast: try! parseWithDelimiters(pattern))
  }

  public var regex: Regex<Output> {
    self
  }
}

@available(SwiftStdlib 5.7, *)
extension Regex {
  @available(*, deprecated, renamed: "init(verbatim:)")
  public init(quoting string: String) {
    self.init(node: .quotedLiteral(string))
  }
}


@available(SwiftStdlib 5.7, *)
extension Regex {
  /// A program representation that caches any lowered representation for
  /// execution.
  internal final class Program {
    /// The underlying IR.
    ///
    /// FIXME: If Regex is the unit of composition, then it should be a Node instead,
    /// and we should have a separate type that handled both global options and,
    /// likely, compilation/caching.
    let tree: DSLTree

    /// OptionSet of compiler options for testing purposes
    fileprivate var compileOptions: _CompileOptions = .default

    private final class ProgramBox {
      let value: MEProgram
      init(_ value: MEProgram) { self.value = value }
    }

    /// Do not use directly - all accesses must go through `loweredProgram`.
    fileprivate var _loweredProgramStorage: AnyObject? = nil
    
    /// The program for execution with the matching engine.
    var loweredProgram: MEProgram {
      /// Atomically loads the compiled program if it has already been stored.
      func loadProgram() -> MEProgram? {
        guard let loweredObject = _stdlib_atomicLoadARCRef(object: &_loweredProgramStorage)
          else { return nil }
        return unsafeDowncast(loweredObject, to: ProgramBox.self).value
      }
      
      // Use the previously compiled program, if available.
      if let program = loadProgram() {
        return program
      }
      
      // Compile the DSLTree into a lowered program and store it atomically.
      let compiledProgram = try! Compiler(tree: tree, compileOptions: compileOptions).emit()
      let storedNewProgram = _stdlib_atomicInitializeARCRef(
        object: &_loweredProgramStorage,
        desired: ProgramBox(compiledProgram))
      
      // Return the winner of the storage race. We're guaranteed at this point
      // to have compiled program stored in `_loweredProgramStorage`.
      return storedNewProgram
        ? compiledProgram
        : loadProgram()!
    }

    init(ast: AST) {
      self.tree = ast.dslTree
    }

    init(tree: DSLTree) {
      self.tree = tree
    }
  }
  
  /// The set of matching options that applies to the start of this regex.
  ///
  /// Note that the initial options may not apply to the entire regex. For
  /// example, in this regex, only case insensitivity (`i`) and Unicode scalar
  /// semantics (set by API) apply to the entire regex, while ASCII character
  /// classes (`P`) is part of `initialOptions` but not global:
  ///
  ///     let regex = /(?i)(?P:\d+\s*)abc/.semanticLevel(.unicodeScalar)
  var initialOptions: MatchingOptions {
    program.loweredProgram.initialOptions
  }
}

@available(SwiftStdlib 5.7, *)
extension Regex {
  var root: DSLTree.Node {
    program.tree.root
  }

  init(node: DSLTree.Node) {
    self.program = Program(tree: .init(node))
  }
}

@available(SwiftStdlib 5.7, *)
@_spi(RegexBenchmark)
extension Regex {
  public enum _RegexInternalAction {
    case recompile
    case addOptions(_CompileOptions)
  }
  
  /// Internal API for RegexBenchmark
  /// Forces the regex to perform the given action, returning if it was successful
  public mutating func _forceAction(_ action: _RegexInternalAction) -> Bool {
    do {
      switch action {
      case .addOptions(let opts):
        program.compileOptions.insert(opts)
        program._loweredProgramStorage = nil
        return true
      case .recompile:
        let _ = try Compiler(
          tree: program.tree,
          compileOptions: program.compileOptions).emit()
        return true
      }
    } catch {
      return false
    }
  }
}
