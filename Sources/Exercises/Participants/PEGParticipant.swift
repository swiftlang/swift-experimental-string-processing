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

struct PEGParticipant: Participant {
  static var name: String { "PEG" }
}

import Prototypes
private func graphemeBreakPropertyData(forLine line: String) -> GraphemeBreakEntry? {
  typealias Pattern = PEG<Character>.Pattern

  /*
   # This is a comment

   0600..0605    ; Prepend # Cf   [6] ARABIC NUMBER SIGN..ARABIC NUMBER MARK ABOVE
   06DD          ; Prepend # Cf       ARABIC END OF AYAH

   Decl -> Scalar (".." Scalar)? Space+ ";" Space Property Space "#" .* success
   Scalar -> \h{4, 6}
   Space -> \s
   Property -> \w+

   */

  let scalar = Pattern.repeatRange(.charactetSet(\.isHexDigit), atLeast: 4, atMost: 6)
  let space = Pattern.charactetSet(\.isWhitespace)
  let property = Pattern.oneOrMore(.charactetSet(\.isLetter))
  let entry = Pattern(
    scalar, .zeroOrOne(Pattern("..", scalar)), .repeat(space, atLeast: 1),
    ";", space, property, space, "#", .many(.any), .success)

  let program = PEG.Program(start: "Entry", environment: ["Entry": entry])

  let vm = program.compile(for: String.self)
  let engine = try! program.transpile()
  _ = (vm, engine)

  fatalError("Unsupported")
  //    let resultVM = vm.consume(line)
  //    let resultTrans = engine.consume(line)
  //
  //    precondition(resultVM == resultTrans)

}

