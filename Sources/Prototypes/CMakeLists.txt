
add_library(Prototypes
  Combinators/Combinators.swift
  PEG/PEG.swift
  PEG/PEGCode.swift
  PEG/PEGCompile.swift
  PEG/PEGCore.swift
  PEG/PEGInterpreter.swift
  PEG/PEGTranspile.swift
  PEG/PEGVM.swift
  PEG/PEGVMExecute.swift
  PEG/Printing.swift
  PTCaRet/Interpreter.swift
  PTCaRet/PTCaRet.swift
  TourOfTypes/CharacterClass.swift
  TourOfTypes/Literal.swift)
target_link_libraries(Prototypes PUBLIC
  _RegexParser)
