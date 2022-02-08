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

import _MatchingEngine

// TODO: what here should be in the compile-time module?

enum Capture {
  case atom(Any)
  indirect case tuple([Capture])
  indirect case some(Capture)
  case none(childType: AnyType)
  indirect case array([Capture], childType: AnyType)

  static func none(childType: Any.Type) -> Capture {
    .none(childType: AnyType(childType))
  }

  static func array(_ children: [Capture], childType: Any.Type) -> Capture {
    .array(children, childType: AnyType(childType))
  }
}

extension Capture {
  static func tupleOrAtom(_ elements: [Capture]) -> Self {
    elements.count == 1 ? elements[0] : .tuple(elements)
  }

  static var void: Capture {
    .tuple([])
  }

  var value: Any {
    switch self {
    case .atom(let atom):
      return atom
    case .tuple(let elements):
      return TypeConstruction.tuple(
        of: elements.map(\.value))
    case .array(let elements, let childType):
      func helper<T>(_: T.Type) -> Any {
        elements.map { $0.value as! T }
      }
      return _openExistential(childType.base, do: helper)
    case .some(let subcapture):
      func helper<T>(_ value: T) -> Any {
        Optional(value) as Any
      }
      return _openExistential(subcapture.value, do: helper)
    case .none(let childType):
      func helper<T>(_: T.Type) -> Any {
        nil as T? as Any
      }
      return _openExistential(childType.base, do: helper)
    }
  }

  private func prepending(_ newElement: Any) -> Self {
    switch self {
    case .atom, .some, .none, .array:
      return .tuple([.atom(newElement), self])
    case .tuple(let elements):
      return .tuple([.atom(newElement)] + elements)
    }
  }

  func matchValue(withWholeMatch wholeMatch: Substring) -> Any {
    prepending(wholeMatch).value
  }
}

extension Capture: CustomStringConvertible {
  public var description: String {
    var printer = PrettyPrinter()
    _print(&printer)
    return printer.finish()
  }

  private func _print(_ printer: inout PrettyPrinter) {
    switch self {
    case let .atom(n):
      printer.print("Atom(\(n))")
    case let .tuple(ns):
      if ns.isEmpty {
        printer.print("Tuple()")
        return
      }

      printer.printBlock("Tuple") { printer in
        for n in ns {
          n._print(&printer)
        }
      }

    case let .some(n):
      printer.printBlock("Tuple") { printer in
        n._print(&printer)
      }

    case let .none(childType):
      printer.print("None(\(childType))")

    case let .array(ns, childType):
      printer.printBlock("Array(\(childType))") { printer in
        for n in ns {
          n._print(&printer)
        }
      }

    }
  }
}
