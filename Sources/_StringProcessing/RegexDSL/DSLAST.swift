import _MatchingEngine

// NOTE: Not sure if below is better or worse than existentials


// FIXME: Get this out of here
public struct CaptureTransform: Equatable, Hashable, CustomStringConvertible {
  public let closure: (Substring) -> Any

  public init(_ closure: @escaping (Substring) -> Any) {
    self.closure = closure
  }

  public func callAsFunction(_ input: Substring) -> Any {
    closure(input)
  }

  public static func == (lhs: CaptureTransform, rhs: CaptureTransform) -> Bool {
    unsafeBitCast(lhs.closure, to: (Int, Int).self) ==
      unsafeBitCast(rhs.closure, to: (Int, Int).self)
  }

  public func hash(into hasher: inout Hasher) {
    let (fn, ctx) = unsafeBitCast(closure, to: (Int, Int).self)
    hasher.combine(fn)
    hasher.combine(ctx)
  }

  public var description: String {
    "<transform>"
  }
}


// CollectionConsumer
typealias _ConsumerInterface = (
  String, Range<String.Index>
) -> String.Index?

// Type producing consume
typealias _ConsumerValidatorInterface = (
  String, Range<String.Index>
) -> (Any, Any.Type, String.Index)?

// Character-set (post grapheme segmentation)
typealias _CharacterPredicateInterface = (
  (Character) -> Bool
)

typealias QuantKind = AST.Quantification.Kind
typealias QuantAmount = AST.Quantification.Amount
typealias GroupKind = AST.Group.Kind

indirect enum RegexDSLAST {
  case literal(AST)

  case consumer(_ConsumerInterface)
  case consumerValidator(_ConsumerValidatorInterface)

  // Support matching constructs for nesting

  case alternation([RegexDSLAST])
  case concatenation([RegexDSLAST])
  case quantification(QuantAmount, QuantKind, RegexDSLAST)
  case customCharacterClass(_CharacterPredicateInterface)
  case group(GroupKind, RegexDSLAST)
  case groupTransform(
    GroupKind, transform: CaptureTransform, RegexDSLAST)
}

extension RegexDSLAST {
  var hasCapture: Bool {
    switch self {
    case let .literal(l): return l.hasCapture

    case let .alternation(c):   return c.any(\.hasCapture)
    case let .concatenation(c): return c.any(\.hasCapture)

    case let .quantification(_, _, c): return c.hasCapture
    case let .group(_, c):             return c.hasCapture
    case let .groupTransform(_, _, c): return c.hasCapture

    case .consumer, .consumerValidator, .customCharacterClass:
      return false
    }
  }

  var literalAST: AST? {
    switch self {
    case .literal(let l): return l
    default: return nil
    }
  }
}
