
add_library(RegexBuilder
  Anchor.swift
  Builder.swift
  DSL.swift
  Match.swift
  Variadics.swift)
target_compile_options(RegexBuilder PRIVATE
  -enable-library-evolution
  -Xfrontend -enable-experimental-pairwise-build-block)
