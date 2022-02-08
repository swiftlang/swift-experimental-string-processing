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

extension RegexProtocol {
  @_disfavoredOverload
  public func capture() -> CapturingGroup<(Substring, Substring)> {
    .init(self)
  }

  @_disfavoredOverload
  public func capture<NewCapture>(
    _ transform: @escaping (Substring) -> NewCapture
  ) -> CapturingGroup<(Substring, NewCapture)> {
    .init(self, transform: transform)
  }

  @_disfavoredOverload
  public func tryCapture<NewCapture>(
    _ transform: @escaping (Substring) throws -> NewCapture
  ) -> CapturingGroup<(Substring, NewCapture)> {
    .init(self, transform: transform)
  }

  @_disfavoredOverload
  public func tryCapture<NewCapture>(
    _ transform: @escaping (Substring) -> NewCapture?
  ) -> CapturingGroup<(Substring, NewCapture)> {
    .init(self, transform: transform)
  }

  public func capture<W, C0>() -> CapturingGroup<(Substring, Substring, C0)>
  where Match == (W, C0) {
    .init(self)
  }

  public func capture<NewCapture, W, C0>(
    _ transform: @escaping (Substring) -> NewCapture
  ) -> CapturingGroup<(Substring, NewCapture, C0)> where Match == (W, C0) {
    .init(self, transform: transform)
  }

  public func tryCapture<NewCapture, W, C0>(
    _ transform: @escaping (Substring) throws -> NewCapture
  ) -> CapturingGroup<(Substring, NewCapture, C0)> where Match == (W, C0) {
    .init(self, transform: transform)
  }

  public func tryCapture<NewCapture, W, C0>(
    _ transform: @escaping (Substring) -> NewCapture?
  ) -> CapturingGroup<(Substring, NewCapture, C0)> where Match == (W, C0) {
    .init(self, transform: transform)
  }

  public func capture<W, C0, C1>() -> CapturingGroup<(Substring, Substring, C0, C1)> where Match == (W, C0, C1) {
    .init(self)
  }

  public func capture<NewCapture, W, C0, C1>(
    _ transform: @escaping (Substring) -> NewCapture
  ) -> CapturingGroup<(Substring, NewCapture, C0, C1)> where Match == (W, C0, C1) {
    .init(self, transform: transform)
  }

  public func tryCapture<NewCapture, W, C0, C1>(
    _ transform: @escaping (Substring) throws -> NewCapture
  ) -> CapturingGroup<(Substring, NewCapture, C0, C1)> where Match == (W, C0, C1) {
    .init(self, transform: transform)
  }

  public func tryCapture<NewCapture, W, C0, C1>(
    _ transform: @escaping (Substring) -> NewCapture?
  ) -> CapturingGroup<(Substring, NewCapture, C0, C1)> where Match == (W, C0, C1) {
    .init(self, transform: transform)
  }

  public func capture<W, C0, C1, C2>() -> CapturingGroup<(Substring, Substring, C0, C1, C2)>
  where Match == (W, C0, C1, C2) {
    .init(self)
  }

  public func capture<NewCapture, W, C0, C1, C2>(
    _ transform: @escaping (Substring) -> NewCapture
  ) -> CapturingGroup<(Substring, NewCapture, C0, C1, C2)> where Match == (W, C0, C1, C2) {
    .init(self, transform: transform)
  }

  public func tryCapture<NewCapture, W, C0, C1, C2>(
    _ transform: @escaping (Substring) throws -> NewCapture
  ) -> CapturingGroup<(Substring, NewCapture, C0, C1, C2)> where Match == (W, C0, C1, C2) {
    .init(self, transform: transform)
  }

  public func tryCapture<NewCapture, W, C0, C1, C2>(
    _ transform: @escaping (Substring) -> NewCapture?
  ) -> CapturingGroup<(Substring, NewCapture, C0, C1, C2)> where Match == (W, C0, C1, C2) {
    .init(self, transform: transform)
  }
}

/* Or using parameterized extensions and variadic generics.
extension<T...> RegexProtocol where Match == (T...) {
  public func capture() -> CapturingGroup<(Substring, T...)> {
    .init(self)
  }

  public func capture<NewCapture>(
    _ transform: @escaping (Substring) -> NewCapture
  ) -> CapturingGroup<(NewCapture, T...)> {
    .init(self, transform: transform)
  }
}
*/
