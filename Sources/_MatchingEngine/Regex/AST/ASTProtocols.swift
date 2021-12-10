///// An AST value tracks source info from where it originated from.
/////
///// Note: source ranges participate in equality/hashing, so that two instances
///// of the same e.g. literal `Character` in the input are distinct when stored in
///// a set or dictionary.
/////
///// To get a location-invariant notion of equality/hashing, use `.value` directly.
/////
///// TODO: print/dump/anything else?
//public protocol ASTValue: Hashable {
//  associatedtype Value: Hashable
//
//  var value: Value { get }
//  var sourceRange: SourceRange? { get }
//
//  init(_ value: Value, _ sourceRange: SourceRange?)
//}
//// TODO: Or is Source.Value above better?
//
//
//// Source range doesn't participate in equality / hashing
////
//// FIXME: But should it? If we see same value twice, shouldn't that
//// be two separate values inside a `Set`?
////
//// We could go either way. For the purposes of a testing harness,
//// we want location-invariant equality checks. For the purposes
//// of data structures, they're different values (identity from
//// location). For the former we can have a "stripping source loc".
//extension ASTValue {
//  // For now, omit source ranges...
//  public func hash(into hasher: inout Hasher) {
//    value.hash(into: &hasher)
//  }
//  // For now, omit source ranges...
//  static func == (lhs: Self, rhs: Self) -> Bool {
//    lhs.value == rhs.value
//  }
//}
//
///// TODO: Describe
/////
///// Tracks source location information
//public protocol ASTEntity: Hashable {
//  var sourceRange: SourceRange? { get }
//}
//
//public protocol ASTParentEntity: Hashable, _ASTPrintableNested {
//  // TODO: variadic access to children?
//}

// MARK: - Source range tracking

// TODO: anything interesting here? E.g.:
// protocol _ASTNode { sourceRange: SourceRange }

// MARK: - AST parenting

// Useful for relatively opaque recursive traversals

// Can't pull in `Hashable` because `Self` requirement
protocol _ASTNode: _ASTPrintable {
}
extension _ASTNode {
}

protocol _ASTParent: _ASTNode {
  var children: [AST] { get }
}

extension AST.Concatenation: _ASTParent {}
extension AST.Alternation: _ASTParent {}

extension AST.Group: _ASTParent {
  var children: [AST] { [child] }
}
extension AST.Quantification: _ASTParent {
  var children: [AST] { [child] }
}

