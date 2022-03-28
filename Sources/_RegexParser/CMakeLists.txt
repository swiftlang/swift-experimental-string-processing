
add_library(_RegexParser
  AST/AST.swift
  AST/ASTAction.swift
  AST/ASTProtocols.swift
  AST/Atom.swift
  AST/Conditional.swift
  AST/CustomCharClass.swift
  AST/Group.swift
  AST/MatchingOptions.swift
  AST/Quantification.swift
  Parse/CaptureStructure.swift
  Parse/CharacterPropertyClassification.swift
  Parse/DelimiterLexing.swift
  Parse/Diagnostics.swift
  Parse/LexicalAnalysis.swift
  Parse/Mocking.swift
  Parse/Parse.swift
  Parse/Source.swift
  Parse/SourceLocation.swift
  Parse/SyntaxOptions.swift
  Printing/DumpAST.swift
  Printing/PrettyPrinter.swift
  Printing/PrintAsCanonical.swift
  Printing/RenderRanges.swift
  TreeProtocols.swift)
target_compile_options(_RegexParser PRIVATE
  -enable-library-evolution)
