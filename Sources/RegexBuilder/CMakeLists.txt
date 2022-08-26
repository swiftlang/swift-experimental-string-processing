
add_library(RegexBuilder
  Algorithms.swift
  Anchor.swift
  Builder.swift
  CharacterClass.swift
  DSL.swift
  Variadics.swift)
target_compile_options(RegexBuilder PRIVATE
  -enable-library-evolution
  -Xfrontend -enable-experimental-pairwise-build-block)
