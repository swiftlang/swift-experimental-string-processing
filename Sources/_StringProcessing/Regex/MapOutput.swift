

@available(SwiftStdlib 5.7, *)
extension Regex {
  public func mapOutput<NewOutput>(
    _ f: @escaping (Output) -> NewOutput
  ) -> Regex<NewOutput> {
    .init(node: .mapOutput(
      NewOutput.self,
      { f($0 as! Output) },
      self.root))
  }
}

