// MARK: - Pitched Compiler/library interface

/// Conform to this to support regex literals
protocol ExpressibleByRegexLiteral {
  associatedtype Builder: RegexLiteralBuilderProtocol
  init(builder: Builder)
}

/// Builder conforms to this for compiler-library API
protocol RegexLiteralBuilderProtocol {
  /// Opaquely identify something built
  associatedtype ASTNodeId = UInt

  /// NOTE: This will likely not be a requirement but could be ad-hoc name lookup
  mutating func buildCharacterClass_d() -> ASTNodeId

  /// Any post-processing or partial compilation
  ///
  /// NOTE: we might want to make this `throws`, capable of communicating
  /// compilation failure if conformer is constant evaluable.
  mutating func finalize()
}

/*

 TODO: We will probably want defaulting mechanisms, such as:

 * Ability for a conformer to take a meta-character as
   just an escaped character
 * Ability for a conformer to use function decls for feature
   set communication alone, and have default impl build just
   echo the string for an engine

 */

// MARK: - Semantic levels

/// Dynamic notion of a specified semantics level for a regex
enum SemanticsLevel {
  case graphemeCluster
  case scalar
  case posix // different than ASCII?
  // ... code units ...
}

/// Conformers can be ran as a regex / pattern
protocol RegexProtocol {
  var level: SemanticsLevel? { get }
}

/// Provide the option to encode semantic level statically
protocol RegexLiteralProtocol: ExpressibleByRegexLiteral {
  associatedtype ScalarSemanticRegex: RegexProtocol
  associatedtype GraphemeSemanticRegex: RegexProtocol
  associatedtype POSIXSemanticRegex: RegexProtocol
  associatedtype UnspecifiedSemanticRegex: RegexProtocol = RegexLiteral

  var scalarSemantic: ScalarSemanticRegex { get }
  var graphemeSemantic: GraphemeSemanticRegex { get }
  var posixSemantic: POSIXSemanticRegex { get }
}

// MARK: - Statically encoded semantic level

/// A regex that has statically  bound its semantic level
struct StaticSemanticRegexLiteral: RegexLiteralProtocol {
  /*
   If we had values in type-parameter position, this would be
   far easier and more straight-forward to model.

   RegexLiteral<SemanticsLevel? = nil>

   */

  /// A regex that has statically  bound its semantic level
  struct ScalarSemanticRegex: RegexProtocol {
    var level: SemanticsLevel? { .scalar }
  }
  struct GraphemeSemanticRegex: RegexProtocol {
    var level: SemanticsLevel? { .graphemeCluster }
  }
  struct POSIXSemanticRegex: RegexProtocol {
    var level: SemanticsLevel? { .posix }
  }
  struct UnspecifiedSemanticRegex: RegexProtocol {
    var level: SemanticsLevel? { nil }
  }

  var scalarSemantic: ScalarSemanticRegex { x() }
  var graphemeSemantic: GraphemeSemanticRegex { x() }
  var posixSemantic: POSIXSemanticRegex { x() }

  init(builder: RegexLiteralBuilder) { }

  typealias Builder = RegexLiteralBuilder
}

// MARK: - stdlib conformer

/// Stdlib's conformer
struct RegexLiteralBuilder: RegexLiteralBuilderProtocol {
  /// Compiler converts literal into a series of calls to this kind of method
  mutating func buildCharacterClass_d() -> ASTNodeId { x() }

  /// We're done, so partially-compile or otherwise finalize
  mutating func finalize() { }
}


/// The produced value for a regex literal. Might end up being same type as
/// `Regex` or `Pattern`, but for now useful to model independently.
struct RegexLiteral: ExpressibleByRegexLiteral {
  typealias Builder = RegexLiteralBuilder

  /// An explicitly specified semantics level
  var level: SemanticsLevel? = nil

  init(builder: Builder) {
    // TODO: should this be throwing, constant evaluable, or
    // some other way to issue diagnostics?
  }
}

extension RegexLiteral: RegexProtocol, RegexLiteralProtocol {
  /// A regex that has finally bound its semantic level (dynamically)
  struct BoundSemantic: RegexProtocol {
    var _level: SemanticsLevel // Bound semantic level
    var level: SemanticsLevel? { _level }
  }
  private func sem(_ level: SemanticsLevel) -> BoundSemantic {
    x()
  }

  var scalarSemantic: BoundSemantic { sem(.scalar) }
  var graphemeSemantic: BoundSemantic { sem(.graphemeCluster) }
  var posixSemantic: BoundSemantic { sem(.posix) }

}


// ---

internal func x() -> Never { fatalError() }
