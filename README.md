# Declarative String Processing for Swift

An early experimental general-purpose pattern matching engine for Swift.

See [Declarative String Processing Overview][decl-string]

[decl-string]: Documentation/DeclarativeStringProcessing.md

## Requirements

- [Swift Trunk Development Snapshot](https://www.swift.org/download/#snapshots) DEVELOPMENT-SNAPSHOT-2022-04-20 or later.

## Trying it out

To try out the functionality provided here, download the latest open source development toolchain. Import `_StringProcessing` in your source file to get access to the API and specify `-Xfrontend -enable-experimental-string-processing` to get access to the literals.

For example, in a `Package.swift` file's target declaration:

```swift
.target(
    name: "foo",
    dependencies: ["depA"],
    swiftSettings: [.unsafeFlags(["-Xfrontend", "-enable-experimental-string-processing"])]
 ),
```


## Integration with Swift

`_RegexParser` and `_StringProcessing` are specially integrated modules that are built as part of apple/swift.

Specifically, `_RegexParser` contains the parser for regular expression literals and is built both as part of the compiler and as a core library. `_CUnicode` and `_StringProcessing` are built together as a core library named `_StringProcessing`.

| Module              | Swift toolchain component                                                            |
| ------------------- | ------------------------------------------------------------------------------------ |
| `_RegexParser`      | `SwiftCompilerSources/Sources/_RegexParser` and `stdlib/public/_RegexParser` |
| `_CUnicode`         | `stdlib/public/_StringProcessing`                                                    |
| `_StringProcessing` | `stdlib/public/_StringProcessing`                                                    |

### Branching scheme

The `main` branch is the branch for day-to-day development. Generally, you should create PRs against this branch.

Branches whose name starts with `swift/` are Swift integration branches similar to those in [apple/llvm-project](https://github.com/apple/llvm-project). For each branch, dropping the `swift/` prefix is the corresponding branch in [apple/swift](https://github.com/apple/swift).

This package's `main` branch will automatically integrate with Swift's `main` branch.

| apple/swift branch  | apple/swift-experimental-string-processing branch     |
| ------------------- | ----------------------------------------------------- |
| main                | main                                                  |
| release/5.7         | swift/release/5.7                                     |
| ...                 | swift/...                                             |

A pair of corresponding branches are expected to build successfully together and pass all tests.

### Running Package CI and full Swift CI

To integrate the latest changes in apple/swift-experimental-string-processing to apple/swift, carefully follow the workflow: 

- Run package CI
  - In the pull request, trigger package CI using
```
@swift-ci please test
```
- Run full Swift CI for any changes to public or SPI interfaces or the `_RegexParser` module.
  - If apple/swift needs to be modified to work with the latest `main` in apple/swift-experimental-string-processing, create a pull request in apple/swift.  **Note:** Since CI in apple/swift-experimental-string-processing has not yet been set up to run full toolchain tests, you should create a PR in apple/swift regardless; if the integartion does not require changing apple/swift, create a dummy PR in apple/swift by changing the README and just not merge it in the end.
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
  - Merge the PR in apple/swift-experimental-string-processing:
    - as a squash or rebase if against main (the development branch).
    - as a merge commit if it's a merge from main to swift/release/x.y.
  - Merge the pull request in apple/swift (if any).

### Development notes

Compiler integration can be tricky. Use special caution when developing `_RegexParser` and `_StringProcessing` modules.

- Do not change the names of these modules without due approval from compiler and infrastructure teams.
- Do not modify the existing ABI (e.g. C API, serialization format) between the regular expression parser and the Swift compiler unless absolutely necessary. 
- Always minimize the number of lockstep integrations, i.e. when apple/swift-experimental-string-processing and apple/swift have to change together. Whenever possible, introduce new API first, migrate Swift compiler onto it, and then deprecate old API. Use versioning if helpful.
- In `_StringProcessing`, do not write fully qualified references to symbols in `_CUnicode`, and always wrap `import _CUnicode` in a `#if canImport(_CUnicode)`. This is because `_CUnicode` is built as part of `_StringProcessing` with CMake.
