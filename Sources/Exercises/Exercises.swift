public enum Exercises {
  public static var allParticipants: Array<Participant.Type> {
    [
      NaiveParticipant.self,
      HandWrittenParticipant.self,
      RegexParticipant.self,
      PEGParticipant.self,
      NSREParticipant.self,
    ]
  }

  public static var referenceParticipant: Participant.Type {
    ReferenceParticipant.self
  }
}

