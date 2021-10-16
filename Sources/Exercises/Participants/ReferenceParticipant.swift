
struct ReferenceParticipant: Participant {
  static var name: String { "Reference" }

  static func graphemeBreakProperty() throws -> (String) -> GraphemeBreakEntry? {
    try! NaiveParticipant.graphemeBreakProperty()
  }
}
