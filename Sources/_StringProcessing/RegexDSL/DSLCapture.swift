extension RegexProtocol {
  public func capture() -> CapturingGroup<Tuple2<Substring, Substring>> where Match.Capture: EmptyCaptureProtocol {
    .init(self)
  }

  public func capture<NewCapture>(
    _ transform: @escaping (Substring) -> NewCapture
  ) -> CapturingGroup<Tuple2<Substring, NewCapture>> where Match.Capture: EmptyCaptureProtocol {
    .init(self, transform: transform)
  }

  public func capture<C0>() -> CapturingGroup<Tuple3<Substring, Substring, C0>>
  where Match.Capture == C0 {
    .init(self)
  }

  public func capture<NewCapture, C0>(
    _ transform: @escaping (Substring) -> NewCapture
  ) -> CapturingGroup<Tuple3<Substring, NewCapture, C0>> where Match.Capture == C0 {
    .init(self, transform: transform)
  }

  public func capture<C0, C1>() -> CapturingGroup<Tuple4<Substring, Substring, C0, C1>> where Match.Capture == Tuple2<C0, C1> {
    .init(self)
  }

  public func capture<NewCapture, C0, C1>(
    _ transform: @escaping (Substring) -> NewCapture
  ) -> CapturingGroup<Tuple4<Substring, NewCapture, C0, C1>> where Match.Capture == Tuple2<C0, C1> {
    .init(self, transform: transform)
  }

  public func capture<C0, C1, C2>() -> CapturingGroup<Tuple5<Substring, Substring, C0, C1, C2>>
  where Match.Capture == Tuple3<C0, C1, C2> {
    .init(self)
  }

  public func capture<NewCapture, C0, C1, C2>(
    _ transform: @escaping (Substring) -> NewCapture
  ) -> CapturingGroup<Tuple5<Substring, NewCapture, C0, C1, C2>> where Match.Capture == Tuple3<C0, C1, C2> {
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
