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

public enum Exercises {
  public static var allParticipants: Array<Participant.Type> {
    [
      NaiveParticipant.self,
      HandWrittenParticipant.self,
      RegexDSLParticipant.self,
      RegexLiteralParticipant.self,
      NSREParticipant.self,
    ]
  }

  public static var referenceParticipant: Participant.Type {
    ReferenceParticipant.self
  }
}

