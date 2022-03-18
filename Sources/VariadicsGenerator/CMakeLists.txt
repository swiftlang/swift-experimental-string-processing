
add_executable(VariadicsGenerator
  VariadicsGenerator.swift)
target_compile_options(VariadicsGenerator PRIVATE
  -parse-as-library)
target_link_libraries(VariadicsGenerator PUBLIC
  ArgumentParser)
