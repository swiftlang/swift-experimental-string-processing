# Declarative String Processing for Swift

An early experimental general-purpose pattern matching engine for Swift.

See [Declarative String Processing Overview][decl-string]

[decl-string]: Documentation/DeclarativeStringProcessing.md

## Requirements

- [Swift Trunk Development Snapshot](https://www.swift.org/download/#snapshots) DEVELOPMENT-SNAPSHOT-2022-03-09 or later.

## Integration with Swift

`_MatchingEngine`, `_CUnicode` and `_StringProcessing` are specially integrated modules that are built as part of apple/swift.

Specifically, `_MatchingEngine` contains the parser for regular expression literals and is built both as part of the compiler and as a core library. `_CUnicode` and `_StringProcessing` are built together as a core library named `_StringProcessing`.

| Module              | Swift toolchain component                                                            |
| ------------------- | ------------------------------------------------------------------------------------ |
| `_MatchingEngine`   | `SwiftCompilerSources/Sources/ExperimentalRegex` and `stdlib/public/_MatchingEngine` |
| `_CUnicode`         | `stdlib/public/_StringProcessing`                                                    |
| `_StringProcessing` | `stdlib/public/_StringProcessing`                                                    |

### Branching scheme

#### Development branch

The `main` branch is the branch for day-to-day development. Generally, you should create PRs against this branch.

#### Swift integration branches

Branches whose name starts with `swift/` are Swift integration branches similar to those in [apple/llvm-project](https://github.com/apple/llvm-project). For each branch, dropping the `swift/` prefix is the corresponding branch in [apple/swift](https://github.com/apple/swift).

| apple/swift branch  | apple/swift-experimental-string-processing branch     |
| ------------------- | ----------------------------------------------------- |
| main                | swift/main                                            |
| release/5.7         | swift/release/5.7                                     |
| ...                 | swift/...                                             |

A pair of corresponding branches are expected to build successfully together and pass all tests.

### Integration workflow

To integrate the latest changes in apple/swift-experimental-string-processing to apple/swift, carefully follow the workflow: 

- Create pull requests.
  - Create a pull request in apple/swift-experimental-string-processing from `main` to `swift/main`, e.g. "[Integration] main -> swift/main".
  - If apple/swift needs to be modified to work with the latest `main` in apple/swift-experimental-string-processing, create a pull request in apple/swift.
- Trigger CI.
  - In the apple/swift-experimental-string-processing pull request, trigger CI using the following command (replacing `<PR NUMBER>` with the apple/swift pull request number, if any):
    ```
    apple/swift#<PR NUMBER> # use this line only if there is an corresponding apple/swift PR
    @swift-ci please test
    ```
  - In the apple/swift pull request (if any), trigger CI using the following command (replacing `<PR NUMBER>` with the apple/swift-experimental-string-processing pull request number):
    ```
    apple/swift-experimental-string-processing#<PR NUMBER>
    @swift-ci please test
    ```
- Merge when approved.
  - Merge the pull request in apple/swift-experimental-string-processing as a **merge commit**.
  - Merge the pull request in apple/swift (if any).

### Development notes

Compiler integration can be tricky. Use special caution when developing `_MatchingEngine`, `_CUnicode` and `_StringProcessing` modules.

- Do not change the names of these modules without due approval from compiler and infrastructure teams.
- Do not modify the existing ABI (e.g. C API, serialization format) between the regular expression parser and the Swift compiler unless absolutely necessary. 
- Always minimize the number of lockstep integrations, i.e. when apple/swift-experimental-string-processing and apple/swift have to change together. Whenever possible, introduce new API first, migrate Swift compiler onto it, and then deprecate old API. Use versioning if helpful.
- In `_StringProcessing`, do not write fully qualified references to symbols in `_CUnicode`, and always wrap `import _CUnicode` in a `#if canImport(_CUnicode)`. This is because `_CUnicode` is built as part of `_StringProcessing` with CMake.
- In `_MatchingEngine`, do not write fully qualified references to `_MatchingEngine` itself. This is because `_MatchingEngine` is built as `ExperimentalRegex` in `SwiftCompilerSources/` with CMake. 
