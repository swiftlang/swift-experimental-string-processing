extension RegexProtocol where Capture: EmptyProtocol {
  public func capture() -> CapturingGroup<Substring> {
    .init(self)
  }

  public func capture<NewCapture>(
    _ transform: @escaping (Substring) -> NewCapture
  ) -> CapturingGroup<NewCapture> {
    .init(self, transform: transform)
  }
}

extension RegexProtocol {
  // Note: We use `@_disfavoredOverload` to prevent tuple captures from choosing this overload.
  @_disfavoredOverload
  public func capture() -> CapturingGroup<(Substring, Capture)> {
    .init(self)
  }

  // Note: We use `@_disfavoredOverload` to prevent tuple captures from choosing this overload.
  @_disfavoredOverload
  public func capture<NewCapture>(
    _ transform: @escaping (Substring) -> NewCapture
  ) -> CapturingGroup<(Substring, Capture)> {
    .init(self, transform: transform)
  }

  public func capture<C0, C1>() -> CapturingGroup<(Substring, C0, C1)> where Capture == (C0, C1) {
    .init(self)
  }

  public func capture<NewCapture, C0, C1>(
    _ transform: @escaping (Substring) -> NewCapture
  ) -> CapturingGroup<(Substring, C0, C1)> where Capture == (C0, C1) {
    .init(self, transform: transform)
  }

  public func capture<C0, C1, C2>() -> CapturingGroup<(Substring, C0, C1, C2)>
  where Capture == (C0, C1, C2) {
    .init(self)
  }

  public func capture<NewCapture, C0, C1, C2>(
    _ transform: @escaping (Substring) -> NewCapture
  ) -> CapturingGroup<(Substring, C0, C1, C2)> where Capture == (C0, C1, C2) {
    .init(self, transform: transform)
  }

  public func capture<C0, C1, C2, C3>() -> CapturingGroup<(Substring, C0, C1, C2, C3)>
  where Capture == (C0, C1, C2, C3) {
    .init(self)
  }

  public func capture<C0, C1, C2, C3, C4>() -> CapturingGroup<(Substring, C0, C1, C2, C3, C4)>
  where Capture == (C0, C1, C2, C3, C4) {
    .init(self)
  }

  public func capture<C0, C1, C2, C3, C4, C5>() -> CapturingGroup<(Substring, C0, C1, C2, C3, C4, C5)>
  where Capture == (C0, C1, C2, C3, C4, C5) {
    .init(self)
  }

  public func capture<C0, C1, C2, C3, C4, C5, C6>() -> CapturingGroup<(Substring, C0, C1, C2, C3, C4, C5, C6)>
  where Capture == (C0, C1, C2, C3, C4, C5, C6) {
    .init(self)
  }
}

/* Or using parameterized extensions and variadic generics.
extension<T...> RegexProtocol where Capture == (T...) {
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
