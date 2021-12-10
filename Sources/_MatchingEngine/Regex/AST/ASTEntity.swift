//
///// TODO: Describe
/////
///// Values don't need to track locations. They're often trivially recomputable or irrelevant
//public protocol ASTValue: _ASTPrintable, Hashable {
//
//}
//
///// TODO: Describe
/////
///// Tracks source location information
//public protocol ASTEntity: ASTValue {
//  var sourceRange: SourceRange { get }
//}
//
//public protocol ASTParentEntity: ASTEntity, _ASTPrintableNested {
//  // TODO: variadic access to children?
//}
//
