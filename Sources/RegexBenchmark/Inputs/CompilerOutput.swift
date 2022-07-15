extension Inputs {
  /// Output of trying to build after deleting `Sources/_StringProcessing/Regex`
  /// Mostly a ton of error messages
  /// Original output was >6000 lines but it was cut down to reduce benchmarker times
  static let compilerOutput = #"""
[0/1] Planning build
Building for debugging...
[1/66] Compiling _StringProcessing Encodings.swift
[2/66] Compiling _StringProcessing Formatting.swift
[3/66] Compiling _StringProcessing NecessaryEvils.swift
[4/66] Compiling _StringProcessing NumberParsing.swift
[5/66] Compiling _StringProcessing ScalarProps.swift
[6/66] Compiling _StringProcessing Transcoding.swift
[7/72] Compiling _StringProcessing CollectionConsumer.swift
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:15:6: error: cannot find type 'RegexComponent' in scope
  R: RegexComponent, Consumed: BidirectionalCollection
     ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:43:23: error: 'RegexOutput' is not a member type of type 'R'
  typealias Match = R.RegexOutput
                    ~ ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:42:1: error: type 'RegexConsumer<R, Consumed>' does not conform to protocol 'MatchingCollectionConsumer'
extension RegexConsumer: MatchingCollectionConsumer {
^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchingCollectionConsumer.swift:13:18: note: protocol requires nested type 'Match'; do you want to add it?
  associatedtype Match
                 ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:75:1: error: type 'RegexConsumer<R, Consumed>' does not conform to protocol 'MatchingCollectionSearcher'
extension RegexConsumer: MatchingStatelessCollectionSearcher {
^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchingCollectionSearcher.swift:13:18: note: protocol requires nested type 'Match'; do you want to add it?
  associatedtype Match
                 ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:90:1: error: type 'RegexConsumer<R, Consumed>' does not conform to protocol 'BackwardMatchingCollectionSearcher'
extension RegexConsumer: BackwardMatchingStatelessCollectionSearcher {
^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchingCollectionSearcher.swift:83:18: note: protocol requires nested type 'Match'; do you want to add it?
  associatedtype Match
                 ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:30:35: error: value of type 'R' has no member 'regex'
    guard let result = try! regex.regex._match(
                            ~~~~~ ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:32:25: error: cannot infer contextual base in reference to member 'partialFromFront'
      in: range, mode: .partialFromFront
                       ~^~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:60:31: error: type of expression is ambiguous without more context
      if let (end, capture) = _matchingConsuming(
                              ^~~~~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/FirstMatch.swift:43:22: error: cannot find type 'RegexComponent' in scope
  func firstMatch<R: RegexComponent>(
                     ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/FirstMatch.swift:50:21: error: cannot find type 'RegexComponent' in scope
  func lastMatch<R: RegexComponent>(
                    ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/FirstMatch.swift:63:8: error: cannot find type 'Regex' in scope
  ) -> Regex<Output>.Match? {
       ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/FirstMatch.swift:62:16: error: cannot find type 'RegexComponent' in scope
    of r: some RegexComponent<Output>
               ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:79:22: error: cannot find type 'RegexComponent' in scope
  func _replacing<R: RegexComponent, Replacement: Collection>(
                     ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:93:22: error: cannot find type 'RegexComponent' in scope
  func _replacing<R: RegexComponent, Replacement: Collection>(
                     ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:106:29: error: cannot find type 'RegexComponent' in scope
  mutating func _replace<R: RegexComponent, Replacement: Collection>(
                            ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:133:24: error: cannot find type 'Regex' in scope
    with replacement: (Regex<Output>.Match) throws -> Replacement
                       ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:130:19: error: cannot find type 'RegexComponent' in scope
    _ regex: some RegexComponent<Output>,
                  ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:168:24: error: cannot find type 'Regex' in scope
    with replacement: (Regex<Output>.Match) throws -> Replacement
                       ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:166:19: error: cannot find type 'RegexComponent' in scope
    _ regex: some RegexComponent<Output>,
                  ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:189:24: error: cannot find type 'Regex' in scope
    with replacement: (Regex<Output>.Match) throws -> Replacement
                       ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:187:19: error: cannot find type 'RegexComponent' in scope
    _ regex: some RegexComponent<Output>,
                  ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/Matches.swift:374:9: error: cannot find type 'Regex' in scope
  ) -> [Regex<Output>.Match] {
        ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/Matches.swift:373:16: error: cannot find type 'RegexComponent' in scope
    of r: some RegexComponent<Output>
               ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Algorithms/Replace.swift:176:19: error: cannot find type 'RegexComponent' in scope
    _ regex: some RegexComponent,
                  ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Algorithms/Replace.swift:202:19: error: cannot find type 'RegexComponent' in scope
    _ regex: some RegexComponent,
                  ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:174:7: error: argument 'with' must precede argument 'subrange'
      with: replacement)
~~~~~~^~~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:195:7: error: argument 'with' must precede argument 'subrange'
      with: replacement)
~~~~~~^~~~~~~~~~~~~~~~~
[8/72] Compiling _StringProcessing FixedPatternConsumer.swift
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:15:6: error: cannot find type 'RegexComponent' in scope
  R: RegexComponent, Consumed: BidirectionalCollection
     ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:43:23: error: 'RegexOutput' is not a member type of type 'R'
  typealias Match = R.RegexOutput
                    ~ ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:42:1: error: type 'RegexConsumer<R, Consumed>' does not conform to protocol 'MatchingCollectionConsumer'
extension RegexConsumer: MatchingCollectionConsumer {
^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchingCollectionConsumer.swift:13:18: note: protocol requires nested type 'Match'; do you want to add it?
  associatedtype Match
                 ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:75:1: error: type 'RegexConsumer<R, Consumed>' does not conform to protocol 'MatchingCollectionSearcher'
extension RegexConsumer: MatchingStatelessCollectionSearcher {
^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchingCollectionSearcher.swift:13:18: note: protocol requires nested type 'Match'; do you want to add it?
  associatedtype Match
                 ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:90:1: error: type 'RegexConsumer<R, Consumed>' does not conform to protocol 'BackwardMatchingCollectionSearcher'
extension RegexConsumer: BackwardMatchingStatelessCollectionSearcher {
^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchingCollectionSearcher.swift:83:18: note: protocol requires nested type 'Match'; do you want to add it?
  associatedtype Match
                 ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:30:35: error: value of type 'R' has no member 'regex'
    guard let result = try! regex.regex._match(
                            ~~~~~ ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:32:25: error: cannot infer contextual base in reference to member 'partialFromFront'
      in: range, mode: .partialFromFront
                       ~^~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:60:31: error: type of expression is ambiguous without more context
      if let (end, capture) = _matchingConsuming(
                              ^~~~~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/FirstMatch.swift:43:22: error: cannot find type 'RegexComponent' in scope
  func firstMatch<R: RegexComponent>(
                     ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/FirstMatch.swift:50:21: error: cannot find type 'RegexComponent' in scope
  func lastMatch<R: RegexComponent>(
                    ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/FirstMatch.swift:63:8: error: cannot find type 'Regex' in scope
  ) -> Regex<Output>.Match? {
       ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/FirstMatch.swift:62:16: error: cannot find type 'RegexComponent' in scope
    of r: some RegexComponent<Output>
               ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:79:22: error: cannot find type 'RegexComponent' in scope
  func _replacing<R: RegexComponent, Replacement: Collection>(
                     ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:93:22: error: cannot find type 'RegexComponent' in scope
  func _replacing<R: RegexComponent, Replacement: Collection>(
                     ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:106:29: error: cannot find type 'RegexComponent' in scope
  mutating func _replace<R: RegexComponent, Replacement: Collection>(
                            ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:133:24: error: cannot find type 'Regex' in scope
    with replacement: (Regex<Output>.Match) throws -> Replacement
                       ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:130:19: error: cannot find type 'RegexComponent' in scope
    _ regex: some RegexComponent<Output>,
                  ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:168:24: error: cannot find type 'Regex' in scope
    with replacement: (Regex<Output>.Match) throws -> Replacement
                       ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:166:19: error: cannot find type 'RegexComponent' in scope
    _ regex: some RegexComponent<Output>,
                  ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:189:24: error: cannot find type 'Regex' in scope
    with replacement: (Regex<Output>.Match) throws -> Replacement
                       ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:187:19: error: cannot find type 'RegexComponent' in scope
    _ regex: some RegexComponent<Output>,
                  ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/Matches.swift:374:9: error: cannot find type 'Regex' in scope
  ) -> [Regex<Output>.Match] {
        ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/Matches.swift:373:16: error: cannot find type 'RegexComponent' in scope
    of r: some RegexComponent<Output>
               ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Algorithms/Replace.swift:176:19: error: cannot find type 'RegexComponent' in scope
    _ regex: some RegexComponent,
                  ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Algorithms/Replace.swift:202:19: error: cannot find type 'RegexComponent' in scope
    _ regex: some RegexComponent,
                  ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:174:7: error: argument 'with' must precede argument 'subrange'
      with: replacement)
~~~~~~^~~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:195:7: error: argument 'with' must precede argument 'subrange'
      with: replacement)
~~~~~~^~~~~~~~~~~~~~~~~
[9/72] Compiling _StringProcessing ManyConsumer.swift
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:15:6: error: cannot find type 'RegexComponent' in scope
  R: RegexComponent, Consumed: BidirectionalCollection
     ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:43:23: error: 'RegexOutput' is not a member type of type 'R'
  typealias Match = R.RegexOutput
                    ~ ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:42:1: error: type 'RegexConsumer<R, Consumed>' does not conform to protocol 'MatchingCollectionConsumer'
extension RegexConsumer: MatchingCollectionConsumer {
^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchingCollectionConsumer.swift:13:18: note: protocol requires nested type 'Match'; do you want to add it?
  associatedtype Match
                 ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:75:1: error: type 'RegexConsumer<R, Consumed>' does not conform to protocol 'MatchingCollectionSearcher'
extension RegexConsumer: MatchingStatelessCollectionSearcher {
^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchingCollectionSearcher.swift:13:18: note: protocol requires nested type 'Match'; do you want to add it?
  associatedtype Match
                 ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:90:1: error: type 'RegexConsumer<R, Consumed>' does not conform to protocol 'BackwardMatchingCollectionSearcher'
extension RegexConsumer: BackwardMatchingStatelessCollectionSearcher {
^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchingCollectionSearcher.swift:83:18: note: protocol requires nested type 'Match'; do you want to add it?
  associatedtype Match
                 ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:30:35: error: value of type 'R' has no member 'regex'
    guard let result = try! regex.regex._match(
                            ~~~~~ ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:32:25: error: cannot infer contextual base in reference to member 'partialFromFront'
      in: range, mode: .partialFromFront
                       ~^~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:60:31: error: type of expression is ambiguous without more context
      if let (end, capture) = _matchingConsuming(
                              ^~~~~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/FirstMatch.swift:43:22: error: cannot find type 'RegexComponent' in scope
  func firstMatch<R: RegexComponent>(
                     ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/FirstMatch.swift:50:21: error: cannot find type 'RegexComponent' in scope
  func lastMatch<R: RegexComponent>(
                    ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/FirstMatch.swift:63:8: error: cannot find type 'Regex' in scope
  ) -> Regex<Output>.Match? {
       ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/FirstMatch.swift:62:16: error: cannot find type 'RegexComponent' in scope
    of r: some RegexComponent<Output>
               ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:79:22: error: cannot find type 'RegexComponent' in scope
  func _replacing<R: RegexComponent, Replacement: Collection>(
                     ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:93:22: error: cannot find type 'RegexComponent' in scope
  func _replacing<R: RegexComponent, Replacement: Collection>(
                     ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:106:29: error: cannot find type 'RegexComponent' in scope
  mutating func _replace<R: RegexComponent, Replacement: Collection>(
                            ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:133:24: error: cannot find type 'Regex' in scope
    with replacement: (Regex<Output>.Match) throws -> Replacement
                       ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:130:19: error: cannot find type 'RegexComponent' in scope
    _ regex: some RegexComponent<Output>,
                  ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:168:24: error: cannot find type 'Regex' in scope
    with replacement: (Regex<Output>.Match) throws -> Replacement
                       ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:166:19: error: cannot find type 'RegexComponent' in scope
    _ regex: some RegexComponent<Output>,
                  ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:189:24: error: cannot find type 'Regex' in scope
    with replacement: (Regex<Output>.Match) throws -> Replacement
                       ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:187:19: error: cannot find type 'RegexComponent' in scope
    _ regex: some RegexComponent<Output>,
                  ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/Matches.swift:374:9: error: cannot find type 'Regex' in scope
  ) -> [Regex<Output>.Match] {
        ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/Matches.swift:373:16: error: cannot find type 'RegexComponent' in scope
    of r: some RegexComponent<Output>
               ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Algorithms/Replace.swift:176:19: error: cannot find type 'RegexComponent' in scope
    _ regex: some RegexComponent,
                  ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Algorithms/Replace.swift:202:19: error: cannot find type 'RegexComponent' in scope
    _ regex: some RegexComponent,
                  ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:174:7: error: argument 'with' must precede argument 'subrange'
      with: replacement)
~~~~~~^~~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:195:7: error: argument 'with' must precede argument 'subrange'
      with: replacement)
~~~~~~^~~~~~~~~~~~~~~~~
[10/72] Compiling _StringProcessing PredicateConsumer.swift
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:15:6: error: cannot find type 'RegexComponent' in scope
  R: RegexComponent, Consumed: BidirectionalCollection
     ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:43:23: error: 'RegexOutput' is not a member type of type 'R'
  typealias Match = R.RegexOutput
                    ~ ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:42:1: error: type 'RegexConsumer<R, Consumed>' does not conform to protocol 'MatchingCollectionConsumer'
extension RegexConsumer: MatchingCollectionConsumer {
^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchingCollectionConsumer.swift:13:18: note: protocol requires nested type 'Match'; do you want to add it?
  associatedtype Match
                 ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:75:1: error: type 'RegexConsumer<R, Consumed>' does not conform to protocol 'MatchingCollectionSearcher'
extension RegexConsumer: MatchingStatelessCollectionSearcher {
^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchingCollectionSearcher.swift:13:18: note: protocol requires nested type 'Match'; do you want to add it?
  associatedtype Match
                 ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:90:1: error: type 'RegexConsumer<R, Consumed>' does not conform to protocol 'BackwardMatchingCollectionSearcher'
extension RegexConsumer: BackwardMatchingStatelessCollectionSearcher {
^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchingCollectionSearcher.swift:83:18: note: protocol requires nested type 'Match'; do you want to add it?
  associatedtype Match
                 ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:30:35: error: value of type 'R' has no member 'regex'
    guard let result = try! regex.regex._match(
                            ~~~~~ ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:32:25: error: cannot infer contextual base in reference to member 'partialFromFront'
      in: range, mode: .partialFromFront
                       ~^~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:60:31: error: type of expression is ambiguous without more context
      if let (end, capture) = _matchingConsuming(
                              ^~~~~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/FirstMatch.swift:43:22: error: cannot find type 'RegexComponent' in scope
  func firstMatch<R: RegexComponent>(
                     ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/FirstMatch.swift:50:21: error: cannot find type 'RegexComponent' in scope
  func lastMatch<R: RegexComponent>(
                    ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/FirstMatch.swift:63:8: error: cannot find type 'Regex' in scope
  ) -> Regex<Output>.Match? {
       ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/FirstMatch.swift:62:16: error: cannot find type 'RegexComponent' in scope
    of r: some RegexComponent<Output>
               ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:79:22: error: cannot find type 'RegexComponent' in scope
  func _replacing<R: RegexComponent, Replacement: Collection>(
                     ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:93:22: error: cannot find type 'RegexComponent' in scope
  func _replacing<R: RegexComponent, Replacement: Collection>(
                     ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:106:29: error: cannot find type 'RegexComponent' in scope
  mutating func _replace<R: RegexComponent, Replacement: Collection>(
                            ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:133:24: error: cannot find type 'Regex' in scope
    with replacement: (Regex<Output>.Match) throws -> Replacement
                       ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:130:19: error: cannot find type 'RegexComponent' in scope
    _ regex: some RegexComponent<Output>,
                  ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:168:24: error: cannot find type 'Regex' in scope
    with replacement: (Regex<Output>.Match) throws -> Replacement
                       ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:166:19: error: cannot find type 'RegexComponent' in scope
    _ regex: some RegexComponent<Output>,
                  ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:189:24: error: cannot find type 'Regex' in scope
    with replacement: (Regex<Output>.Match) throws -> Replacement
                       ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:187:19: error: cannot find type 'RegexComponent' in scope
    _ regex: some RegexComponent<Output>,
                  ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/Matches.swift:374:9: error: cannot find type 'Regex' in scope
  ) -> [Regex<Output>.Match] {
        ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/Matches.swift:373:16: error: cannot find type 'RegexComponent' in scope
    of r: some RegexComponent<Output>
               ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Algorithms/Replace.swift:176:19: error: cannot find type 'RegexComponent' in scope
    _ regex: some RegexComponent,
                  ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Algorithms/Replace.swift:202:19: error: cannot find type 'RegexComponent' in scope
    _ regex: some RegexComponent,
                  ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:174:7: error: argument 'with' must precede argument 'subrange'
      with: replacement)
~~~~~~^~~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:195:7: error: argument 'with' must precede argument 'subrange'
      with: replacement)
~~~~~~^~~~~~~~~~~~~~~~~
[11/72] Compiling _StringProcessing RegexConsumer.swift
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:15:6: error: cannot find type 'RegexComponent' in scope
  R: RegexComponent, Consumed: BidirectionalCollection
     ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:43:23: error: 'RegexOutput' is not a member type of type 'R'
  typealias Match = R.RegexOutput
                    ~ ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:42:1: error: type 'RegexConsumer<R, Consumed>' does not conform to protocol 'MatchingCollectionConsumer'
extension RegexConsumer: MatchingCollectionConsumer {
^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchingCollectionConsumer.swift:13:18: note: protocol requires nested type 'Match'; do you want to add it?
  associatedtype Match
                 ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:75:1: error: type 'RegexConsumer<R, Consumed>' does not conform to protocol 'MatchingCollectionSearcher'
extension RegexConsumer: MatchingStatelessCollectionSearcher {
^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchingCollectionSearcher.swift:13:18: note: protocol requires nested type 'Match'; do you want to add it?
  associatedtype Match
                 ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:90:1: error: type 'RegexConsumer<R, Consumed>' does not conform to protocol 'BackwardMatchingCollectionSearcher'
extension RegexConsumer: BackwardMatchingStatelessCollectionSearcher {
^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchingCollectionSearcher.swift:83:18: note: protocol requires nested type 'Match'; do you want to add it?
  associatedtype Match
                 ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:30:35: error: value of type 'R' has no member 'regex'
    guard let result = try! regex.regex._match(
                            ~~~~~ ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:32:25: error: cannot infer contextual base in reference to member 'partialFromFront'
      in: range, mode: .partialFromFront
                       ~^~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:60:31: error: type of expression is ambiguous without more context
      if let (end, capture) = _matchingConsuming(
                              ^~~~~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/FirstMatch.swift:43:22: error: cannot find type 'RegexComponent' in scope
  func firstMatch<R: RegexComponent>(
                     ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/FirstMatch.swift:50:21: error: cannot find type 'RegexComponent' in scope
  func lastMatch<R: RegexComponent>(
                    ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/FirstMatch.swift:63:8: error: cannot find type 'Regex' in scope
  ) -> Regex<Output>.Match? {
       ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/FirstMatch.swift:62:16: error: cannot find type 'RegexComponent' in scope
    of r: some RegexComponent<Output>
               ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:79:22: error: cannot find type 'RegexComponent' in scope
  func _replacing<R: RegexComponent, Replacement: Collection>(
                     ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:93:22: error: cannot find type 'RegexComponent' in scope
  func _replacing<R: RegexComponent, Replacement: Collection>(
                     ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:106:29: error: cannot find type 'RegexComponent' in scope
  mutating func _replace<R: RegexComponent, Replacement: Collection>(
                            ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:133:24: error: cannot find type 'Regex' in scope
    with replacement: (Regex<Output>.Match) throws -> Replacement
                       ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:130:19: error: cannot find type 'RegexComponent' in scope
    _ regex: some RegexComponent<Output>,
                  ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:168:24: error: cannot find type 'Regex' in scope
    with replacement: (Regex<Output>.Match) throws -> Replacement
                       ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:166:19: error: cannot find type 'RegexComponent' in scope
    _ regex: some RegexComponent<Output>,
                  ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:189:24: error: cannot find type 'Regex' in scope
    with replacement: (Regex<Output>.Match) throws -> Replacement
                       ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:187:19: error: cannot find type 'RegexComponent' in scope
    _ regex: some RegexComponent<Output>,
                  ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/Matches.swift:374:9: error: cannot find type 'Regex' in scope
  ) -> [Regex<Output>.Match] {
        ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/Matches.swift:373:16: error: cannot find type 'RegexComponent' in scope
    of r: some RegexComponent<Output>
               ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Algorithms/Replace.swift:176:19: error: cannot find type 'RegexComponent' in scope
    _ regex: some RegexComponent,
                  ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Algorithms/Replace.swift:202:19: error: cannot find type 'RegexComponent' in scope
    _ regex: some RegexComponent,
                  ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:174:7: error: argument 'with' must precede argument 'subrange'
      with: replacement)
~~~~~~^~~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:195:7: error: argument 'with' must precede argument 'subrange'
      with: replacement)
~~~~~~^~~~~~~~~~~~~~~~~
[12/72] Compiling _StringProcessing FirstMatch.swift
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:15:6: error: cannot find type 'RegexComponent' in scope
  R: RegexComponent, Consumed: BidirectionalCollection
     ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:43:23: error: 'RegexOutput' is not a member type of type 'R'
  typealias Match = R.RegexOutput
                    ~ ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:42:1: error: type 'RegexConsumer<R, Consumed>' does not conform to protocol 'MatchingCollectionConsumer'
extension RegexConsumer: MatchingCollectionConsumer {
^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchingCollectionConsumer.swift:13:18: note: protocol requires nested type 'Match'; do you want to add it?
  associatedtype Match
                 ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:75:1: error: type 'RegexConsumer<R, Consumed>' does not conform to protocol 'MatchingCollectionSearcher'
extension RegexConsumer: MatchingStatelessCollectionSearcher {
^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchingCollectionSearcher.swift:13:18: note: protocol requires nested type 'Match'; do you want to add it?
  associatedtype Match
                 ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:90:1: error: type 'RegexConsumer<R, Consumed>' does not conform to protocol 'BackwardMatchingCollectionSearcher'
extension RegexConsumer: BackwardMatchingStatelessCollectionSearcher {
^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchingCollectionSearcher.swift:83:18: note: protocol requires nested type 'Match'; do you want to add it?
  associatedtype Match
                 ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:30:35: error: value of type 'R' has no member 'regex'
    guard let result = try! regex.regex._match(
                            ~~~~~ ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:32:25: error: cannot infer contextual base in reference to member 'partialFromFront'
      in: range, mode: .partialFromFront
                       ~^~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:60:31: error: type of expression is ambiguous without more context
      if let (end, capture) = _matchingConsuming(
                              ^~~~~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/FirstMatch.swift:43:22: error: cannot find type 'RegexComponent' in scope
  func firstMatch<R: RegexComponent>(
                     ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/FirstMatch.swift:50:21: error: cannot find type 'RegexComponent' in scope
  func lastMatch<R: RegexComponent>(
                    ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/FirstMatch.swift:63:8: error: cannot find type 'Regex' in scope
  ) -> Regex<Output>.Match? {
       ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/FirstMatch.swift:62:16: error: cannot find type 'RegexComponent' in scope
    of r: some RegexComponent<Output>
               ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:79:22: error: cannot find type 'RegexComponent' in scope
  func _replacing<R: RegexComponent, Replacement: Collection>(
                     ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:93:22: error: cannot find type 'RegexComponent' in scope
  func _replacing<R: RegexComponent, Replacement: Collection>(
                     ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:106:29: error: cannot find type 'RegexComponent' in scope
  mutating func _replace<R: RegexComponent, Replacement: Collection>(
                            ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:133:24: error: cannot find type 'Regex' in scope
    with replacement: (Regex<Output>.Match) throws -> Replacement
                       ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:130:19: error: cannot find type 'RegexComponent' in scope
    _ regex: some RegexComponent<Output>,
                  ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:168:24: error: cannot find type 'Regex' in scope
    with replacement: (Regex<Output>.Match) throws -> Replacement
                       ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:166:19: error: cannot find type 'RegexComponent' in scope
    _ regex: some RegexComponent<Output>,
                  ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:189:24: error: cannot find type 'Regex' in scope
    with replacement: (Regex<Output>.Match) throws -> Replacement
                       ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:187:19: error: cannot find type 'RegexComponent' in scope
    _ regex: some RegexComponent<Output>,
                  ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/Matches.swift:374:9: error: cannot find type 'Regex' in scope
  ) -> [Regex<Output>.Match] {
        ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/Matches.swift:373:16: error: cannot find type 'RegexComponent' in scope
    of r: some RegexComponent<Output>
               ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Algorithms/Replace.swift:176:19: error: cannot find type 'RegexComponent' in scope
    _ regex: some RegexComponent,
                  ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Algorithms/Replace.swift:202:19: error: cannot find type 'RegexComponent' in scope
    _ regex: some RegexComponent,
                  ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:174:7: error: argument 'with' must precede argument 'subrange'
      with: replacement)
~~~~~~^~~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:195:7: error: argument 'with' must precede argument 'subrange'
      with: replacement)
~~~~~~^~~~~~~~~~~~~~~~~
[13/72] Compiling _StringProcessing MatchReplace.swift
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:15:6: error: cannot find type 'RegexComponent' in scope
  R: RegexComponent, Consumed: BidirectionalCollection
     ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:43:23: error: 'RegexOutput' is not a member type of type 'R'
  typealias Match = R.RegexOutput
                    ~ ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:42:1: error: type 'RegexConsumer<R, Consumed>' does not conform to protocol 'MatchingCollectionConsumer'
extension RegexConsumer: MatchingCollectionConsumer {
^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchingCollectionConsumer.swift:13:18: note: protocol requires nested type 'Match'; do you want to add it?
  associatedtype Match
                 ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:75:1: error: type 'RegexConsumer<R, Consumed>' does not conform to protocol 'MatchingCollectionSearcher'
extension RegexConsumer: MatchingStatelessCollectionSearcher {
^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchingCollectionSearcher.swift:13:18: note: protocol requires nested type 'Match'; do you want to add it?
  associatedtype Match
                 ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:90:1: error: type 'RegexConsumer<R, Consumed>' does not conform to protocol 'BackwardMatchingCollectionSearcher'
extension RegexConsumer: BackwardMatchingStatelessCollectionSearcher {
^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchingCollectionSearcher.swift:83:18: note: protocol requires nested type 'Match'; do you want to add it?
  associatedtype Match
                 ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:30:35: error: value of type 'R' has no member 'regex'
    guard let result = try! regex.regex._match(
                            ~~~~~ ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:32:25: error: cannot infer contextual base in reference to member 'partialFromFront'
      in: range, mode: .partialFromFront
                       ~^~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Consumers/RegexConsumer.swift:60:31: error: type of expression is ambiguous without more context
      if let (end, capture) = _matchingConsuming(
                              ^~~~~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/FirstMatch.swift:43:22: error: cannot find type 'RegexComponent' in scope
  func firstMatch<R: RegexComponent>(
                     ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/FirstMatch.swift:50:21: error: cannot find type 'RegexComponent' in scope
  func lastMatch<R: RegexComponent>(
                    ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/FirstMatch.swift:63:8: error: cannot find type 'Regex' in scope
  ) -> Regex<Output>.Match? {
       ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/FirstMatch.swift:62:16: error: cannot find type 'RegexComponent' in scope
    of r: some RegexComponent<Output>
               ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:79:22: error: cannot find type 'RegexComponent' in scope
  func _replacing<R: RegexComponent, Replacement: Collection>(
                     ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:93:22: error: cannot find type 'RegexComponent' in scope
  func _replacing<R: RegexComponent, Replacement: Collection>(
                     ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:106:29: error: cannot find type 'RegexComponent' in scope
  mutating func _replace<R: RegexComponent, Replacement: Collection>(
                            ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:133:24: error: cannot find type 'Regex' in scope
    with replacement: (Regex<Output>.Match) throws -> Replacement
                       ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:130:19: error: cannot find type 'RegexComponent' in scope
    _ regex: some RegexComponent<Output>,
                  ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:168:24: error: cannot find type 'Regex' in scope
    with replacement: (Regex<Output>.Match) throws -> Replacement
                       ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:166:19: error: cannot find type 'RegexComponent' in scope
    _ regex: some RegexComponent<Output>,
                  ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:189:24: error: cannot find type 'Regex' in scope
    with replacement: (Regex<Output>.Match) throws -> Replacement
                       ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:187:19: error: cannot find type 'RegexComponent' in scope
    _ regex: some RegexComponent<Output>,
                  ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/Matches.swift:374:9: error: cannot find type 'Regex' in scope
  ) -> [Regex<Output>.Match] {
        ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/Matches.swift:373:16: error: cannot find type 'RegexComponent' in scope
    of r: some RegexComponent<Output>
               ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Algorithms/Replace.swift:176:19: error: cannot find type 'RegexComponent' in scope
    _ regex: some RegexComponent,
                  ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Algorithms/Replace.swift:202:19: error: cannot find type 'RegexComponent' in scope
    _ regex: some RegexComponent,
                  ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:174:7: error: argument 'with' must precede argument 'subrange'
      with: replacement)
~~~~~~^~~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Matching/MatchReplace.swift:195:7: error: argument 'with' must precede argument 'subrange'
      with: replacement)
~~~~~~^~~~~~~~~~~~~~~~~
[14/72] Compiling _StringProcessing UCD.swift
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Unicode/WordBreaking.swift:12:2: warning: '@_spi' import of 'Swift' will not include any SPI symbols; 'Swift' was built from the public interface at /Users/lilylin/Downloads/Xcode-beta 2.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.0.sdk/usr/lib/swift/Swift.swiftmodule/arm64e-apple-macos.swiftinterface
@_spi(_Unicode)
 ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Unicode/WordBreaking.swift:46:13: error: cannot find '_wordIndex' in scope
        j = _wordIndex(after: j)
            ^~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Utility/AsciiBitset.swift:1:11: error: cannot find type 'DSLTree' in scope
extension DSLTree.CustomCharacterClass {
          ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Utility/AsciiBitset.swift:90:50: error: cannot find type 'AsciiBitset' in scope
    internal func union(_ other: AsciiBitset) -> AsciiBitset {
                                                 ^~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Utility/AsciiBitset.swift:90:34: error: cannot find type 'AsciiBitset' in scope
    internal func union(_ other: AsciiBitset) -> AsciiBitset {
                                 ^~~~~~~~~~~
[15/72] Compiling _StringProcessing Validation.swift
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Unicode/WordBreaking.swift:12:2: warning: '@_spi' import of 'Swift' will not include any SPI symbols; 'Swift' was built from the public interface at /Users/lilylin/Downloads/Xcode-beta 2.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.0.sdk/usr/lib/swift/Swift.swiftmodule/arm64e-apple-macos.swiftinterface
@_spi(_Unicode)
 ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Unicode/WordBreaking.swift:46:13: error: cannot find '_wordIndex' in scope
        j = _wordIndex(after: j)
            ^~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Utility/AsciiBitset.swift:1:11: error: cannot find type 'DSLTree' in scope
extension DSLTree.CustomCharacterClass {
          ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Utility/AsciiBitset.swift:90:50: error: cannot find type 'AsciiBitset' in scope
    internal func union(_ other: AsciiBitset) -> AsciiBitset {
                                                 ^~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Utility/AsciiBitset.swift:90:34: error: cannot find type 'AsciiBitset' in scope
    internal func union(_ other: AsciiBitset) -> AsciiBitset {
                                 ^~~~~~~~~~~
[16/72] Compiling _StringProcessing WordBreaking.swift
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Unicode/WordBreaking.swift:12:2: warning: '@_spi' import of 'Swift' will not include any SPI symbols; 'Swift' was built from the public interface at /Users/lilylin/Downloads/Xcode-beta 2.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.0.sdk/usr/lib/swift/Swift.swiftmodule/arm64e-apple-macos.swiftinterface
@_spi(_Unicode)
 ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Unicode/WordBreaking.swift:46:13: error: cannot find '_wordIndex' in scope
        j = _wordIndex(after: j)
            ^~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Utility/AsciiBitset.swift:1:11: error: cannot find type 'DSLTree' in scope
extension DSLTree.CustomCharacterClass {
          ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Utility/AsciiBitset.swift:90:50: error: cannot find type 'AsciiBitset' in scope
    internal func union(_ other: AsciiBitset) -> AsciiBitset {
                                                 ^~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Utility/AsciiBitset.swift:90:34: error: cannot find type 'AsciiBitset' in scope
    internal func union(_ other: AsciiBitset) -> AsciiBitset {
                                 ^~~~~~~~~~~
[17/72] Compiling _StringProcessing ASTBuilder.swift
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Unicode/WordBreaking.swift:12:2: warning: '@_spi' import of 'Swift' will not include any SPI symbols; 'Swift' was built from the public interface at /Users/lilylin/Downloads/Xcode-beta 2.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.0.sdk/usr/lib/swift/Swift.swiftmodule/arm64e-apple-macos.swiftinterface
@_spi(_Unicode)
 ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Unicode/WordBreaking.swift:46:13: error: cannot find '_wordIndex' in scope
        j = _wordIndex(after: j)
            ^~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Utility/AsciiBitset.swift:1:11: error: cannot find type 'DSLTree' in scope
extension DSLTree.CustomCharacterClass {
          ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Utility/AsciiBitset.swift:90:50: error: cannot find type 'AsciiBitset' in scope
    internal func union(_ other: AsciiBitset) -> AsciiBitset {
                                                 ^~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Utility/AsciiBitset.swift:90:34: error: cannot find type 'AsciiBitset' in scope
    internal func union(_ other: AsciiBitset) -> AsciiBitset {
                                 ^~~~~~~~~~~
[18/72] Compiling _StringProcessing AsciiBitset.swift
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Unicode/WordBreaking.swift:12:2: warning: '@_spi' import of 'Swift' will not include any SPI symbols; 'Swift' was built from the public interface at /Users/lilylin/Downloads/Xcode-beta 2.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.0.sdk/usr/lib/swift/Swift.swiftmodule/arm64e-apple-macos.swiftinterface
@_spi(_Unicode)
 ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Unicode/WordBreaking.swift:46:13: error: cannot find '_wordIndex' in scope
        j = _wordIndex(after: j)
            ^~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Utility/AsciiBitset.swift:1:11: error: cannot find type 'DSLTree' in scope
extension DSLTree.CustomCharacterClass {
          ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Utility/AsciiBitset.swift:90:50: error: cannot find type 'AsciiBitset' in scope
    internal func union(_ other: AsciiBitset) -> AsciiBitset {
                                                 ^~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Utility/AsciiBitset.swift:90:34: error: cannot find type 'AsciiBitset' in scope
    internal func union(_ other: AsciiBitset) -> AsciiBitset {
                                 ^~~~~~~~~~~
[19/72] Compiling _StringProcessing Protocols.swift
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Unicode/WordBreaking.swift:12:2: warning: '@_spi' import of 'Swift' will not include any SPI symbols; 'Swift' was built from the public interface at /Users/lilylin/Downloads/Xcode-beta 2.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.0.sdk/usr/lib/swift/Swift.swiftmodule/arm64e-apple-macos.swiftinterface
@_spi(_Unicode)
 ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Unicode/WordBreaking.swift:46:13: error: cannot find '_wordIndex' in scope
        j = _wordIndex(after: j)
            ^~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Utility/AsciiBitset.swift:1:11: error: cannot find type 'DSLTree' in scope
extension DSLTree.CustomCharacterClass {
          ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Utility/AsciiBitset.swift:90:50: error: cannot find type 'AsciiBitset' in scope
    internal func union(_ other: AsciiBitset) -> AsciiBitset {
                                                 ^~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Utility/AsciiBitset.swift:90:34: error: cannot find type 'AsciiBitset' in scope
    internal func union(_ other: AsciiBitset) -> AsciiBitset {
                                 ^~~~~~~~~~~
[20/72] Compiling _StringProcessing PatternOrEmpty.swift
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Algorithms/StartsWith.swift:62:17: error: cannot find type 'RegexComponent' in scope
  func _ends<R: RegexComponent>(with regex: R) -> Bool {
                ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:863:11: error: cannot find type 'DSLTree' in scope
extension DSLTree.Node {
          ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:12:2: warning: '@_spi' import of 'Swift' will not include any SPI symbols; 'Swift' was built from the public interface at /Users/lilylin/Downloads/Xcode-beta 2.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.0.sdk/usr/lib/swift/Swift.swiftmodule/arm64e-apple-macos.swiftinterface
@_spi(_Unicode)
 ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:21:24: error: cannot find type 'DSLTree' in scope
    var asciiBitsets: [DSLTree.CustomCharacterClass.AsciiBitset] = []
                       ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:44:32: error: cannot find type 'ReferenceID' in scope
    var unresolvedReferences: [ReferenceID: [InstructionAddress]] = [:]
                               ^~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:45:36: error: cannot find type 'ReferenceID' in scope
    var referencedCaptureOffsets: [ReferenceID: Int] = [:]
                                   ^~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:41:34: error: cannot find type 'DSLTree' in scope
  mutating func emitRoot(_ root: DSLTree.Node) throws -> MEProgram {
                                 ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:51:31: error: cannot find type 'DSLTree' in scope
  mutating func emitAtom(_ a: DSLTree.Atom) throws {
                              ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:349:18: error: cannot find type 'DSLTree' in scope
    _ children: [DSLTree.Node]
                 ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:380:13: error: cannot find type 'DSLTree' in scope
    _ node: DSLTree.Node
            ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:389:14: error: cannot find type 'DSLTree' in scope
    _ child: DSLTree.Node
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:434:14: error: cannot find type 'DSLTree' in scope
    _ child: DSLTree.Node
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:466:26: error: cannot find type '_MatcherInterface' in scope
    _ matcher: @escaping _MatcherInterface
                         ^~~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:484:14: error: cannot find type 'DSLTree' in scope
    _ child: DSLTree.Node
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:522:13: error: cannot find type 'DSLTree' in scope
    _ kind: DSLTree.QuantificationKind,
            ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:523:14: error: cannot find type 'DSLTree' in scope
    _ child: DSLTree.Node
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:755:12: error: cannot find type 'DSLTree' in scope
    _ ccc: DSLTree.CustomCharacterClass
           ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:771:34: error: cannot find type 'DSLTree' in scope
  mutating func emitNode(_ node: DSLTree.Node) throws -> ValueRegister? {
                                 ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:44:19: error: cannot infer contextual base in reference to member 'capture'
    try emitNode(.capture(name: nil, reference: nil, root))
                 ~^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:44:33: error: 'nil' requires a contextual type
    try emitNode(.capture(name: nil, reference: nil, root))
                                ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:44:49: error: 'nil' requires a contextual type
    try emitNode(.capture(name: nil, reference: nil, root))
                                                ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:242:46: error: cannot find type 'ReferenceID' in scope
  mutating func buildUnresolvedReference(id: ReferenceID) {
                                             ^~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Algorithms/Contains.swift:76:38: error: cannot find type 'RegexComponent' in scope
  public func contains(_ regex: some RegexComponent) -> Bool {
                                     ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:169:10: error: cannot find type 'DSLTree' in scope
    _ b: DSLTree.CustomCharacterClass.AsciiBitset
         ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:162:10: error: cannot find type 'DSLTree' in scope
    _ b: DSLTree.CustomCharacterClass.AsciiBitset
         ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:412:9: error: cannot find type 'ReferenceID' in scope
    id: ReferenceID?, name: String?
        ^~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Capture.swift:41:11: error: cannot find type 'AnyRegexOutput' in scope
extension AnyRegexOutput.Element {
          ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Capture.swift:59:37: error: cannot find type 'AnyRegexOutput' in scope
extension Sequence where Element == AnyRegexOutput.Element {
                                    ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Capture.swift:65:10: error: value of type 'Self.Element' has no member 'existentialOutputComponent'
      $0.existentialOutputComponent(from: input)
      ~~ ^~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Capture.swift:73:19: error: value of type 'Self.Element' has no member 'slice'
    self.map { $0.slice(from: input) }
               ~~ ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:15:13: error: cannot find type 'DSLTree' in scope
  let tree: DSLTree
            ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:25:14: error: cannot find type 'DSLTree' in scope
  init(tree: DSLTree) {
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:29:14: error: cannot find type 'DSLTree' in scope
  init(tree: DSLTree, compileOptions: CompileOptions) {
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:67:20: error: cannot find type 'RegexSemanticLevel' in scope
  _ semanticLevel: RegexSemanticLevel? = nil
                   ^~~~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:22:21: error: value of type 'AST' has no member 'dslTree'
    self.tree = ast.dslTree
                ~~~ ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:70:12: error: cannot find type 'DSLTree' in scope
  let dsl: DSLTree
           ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:72:25: error: type of expression is ambiguous without more context
  switch semanticLevel?.base {
         ~~~~~~~~~~~~~~~^~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:75:11: error: cannot find 'DSLTree' in scope
    dsl = DSLTree(.nonCapturingGroup(.init(ast: .changeMatchingOptions(sequence)), ast.dslTree.root))
          ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:78:11: error: cannot find 'DSLTree' in scope
    dsl = DSLTree(.nonCapturingGroup(.init(ast: .changeMatchingOptions(sequence)), ast.dslTree.root))
          ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:80:15: error: value of type 'AST' has no member 'dslTree'
    dsl = ast.dslTree
          ~~~ ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:82:29: error: incorrect argument label in call (have 'tree:', expected 'ast:')
  let program = try Compiler(tree: dsl).emit()
                            ^~~~~
                             ast
[21/72] Compiling _StringProcessing PredicateSearcher.swift
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Algorithms/StartsWith.swift:62:17: error: cannot find type 'RegexComponent' in scope
  func _ends<R: RegexComponent>(with regex: R) -> Bool {
                ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:863:11: error: cannot find type 'DSLTree' in scope
extension DSLTree.Node {
          ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:12:2: warning: '@_spi' import of 'Swift' will not include any SPI symbols; 'Swift' was built from the public interface at /Users/lilylin/Downloads/Xcode-beta 2.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.0.sdk/usr/lib/swift/Swift.swiftmodule/arm64e-apple-macos.swiftinterface
@_spi(_Unicode)
 ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:21:24: error: cannot find type 'DSLTree' in scope
    var asciiBitsets: [DSLTree.CustomCharacterClass.AsciiBitset] = []
                       ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:44:32: error: cannot find type 'ReferenceID' in scope
    var unresolvedReferences: [ReferenceID: [InstructionAddress]] = [:]
                               ^~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:45:36: error: cannot find type 'ReferenceID' in scope
    var referencedCaptureOffsets: [ReferenceID: Int] = [:]
                                   ^~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:41:34: error: cannot find type 'DSLTree' in scope
  mutating func emitRoot(_ root: DSLTree.Node) throws -> MEProgram {
                                 ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:51:31: error: cannot find type 'DSLTree' in scope
  mutating func emitAtom(_ a: DSLTree.Atom) throws {
                              ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:349:18: error: cannot find type 'DSLTree' in scope
    _ children: [DSLTree.Node]
                 ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:380:13: error: cannot find type 'DSLTree' in scope
    _ node: DSLTree.Node
            ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:389:14: error: cannot find type 'DSLTree' in scope
    _ child: DSLTree.Node
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:434:14: error: cannot find type 'DSLTree' in scope
    _ child: DSLTree.Node
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:466:26: error: cannot find type '_MatcherInterface' in scope
    _ matcher: @escaping _MatcherInterface
                         ^~~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:484:14: error: cannot find type 'DSLTree' in scope
    _ child: DSLTree.Node
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:522:13: error: cannot find type 'DSLTree' in scope
    _ kind: DSLTree.QuantificationKind,
            ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:523:14: error: cannot find type 'DSLTree' in scope
    _ child: DSLTree.Node
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:755:12: error: cannot find type 'DSLTree' in scope
    _ ccc: DSLTree.CustomCharacterClass
           ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:771:34: error: cannot find type 'DSLTree' in scope
  mutating func emitNode(_ node: DSLTree.Node) throws -> ValueRegister? {
                                 ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:44:19: error: cannot infer contextual base in reference to member 'capture'
    try emitNode(.capture(name: nil, reference: nil, root))
                 ~^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:44:33: error: 'nil' requires a contextual type
    try emitNode(.capture(name: nil, reference: nil, root))
                                ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:44:49: error: 'nil' requires a contextual type
    try emitNode(.capture(name: nil, reference: nil, root))
                                                ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:242:46: error: cannot find type 'ReferenceID' in scope
  mutating func buildUnresolvedReference(id: ReferenceID) {
                                             ^~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Algorithms/Contains.swift:76:38: error: cannot find type 'RegexComponent' in scope
  public func contains(_ regex: some RegexComponent) -> Bool {
                                     ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:169:10: error: cannot find type 'DSLTree' in scope
    _ b: DSLTree.CustomCharacterClass.AsciiBitset
         ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:162:10: error: cannot find type 'DSLTree' in scope
    _ b: DSLTree.CustomCharacterClass.AsciiBitset
         ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:412:9: error: cannot find type 'ReferenceID' in scope
    id: ReferenceID?, name: String?
        ^~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Capture.swift:41:11: error: cannot find type 'AnyRegexOutput' in scope
extension AnyRegexOutput.Element {
          ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Capture.swift:59:37: error: cannot find type 'AnyRegexOutput' in scope
extension Sequence where Element == AnyRegexOutput.Element {
                                    ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Capture.swift:65:10: error: value of type 'Self.Element' has no member 'existentialOutputComponent'
      $0.existentialOutputComponent(from: input)
      ~~ ^~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Capture.swift:73:19: error: value of type 'Self.Element' has no member 'slice'
    self.map { $0.slice(from: input) }
               ~~ ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:15:13: error: cannot find type 'DSLTree' in scope
  let tree: DSLTree
            ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:25:14: error: cannot find type 'DSLTree' in scope
  init(tree: DSLTree) {
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:29:14: error: cannot find type 'DSLTree' in scope
  init(tree: DSLTree, compileOptions: CompileOptions) {
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:67:20: error: cannot find type 'RegexSemanticLevel' in scope
  _ semanticLevel: RegexSemanticLevel? = nil
                   ^~~~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:22:21: error: value of type 'AST' has no member 'dslTree'
    self.tree = ast.dslTree
                ~~~ ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:70:12: error: cannot find type 'DSLTree' in scope
  let dsl: DSLTree
           ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:72:25: error: type of expression is ambiguous without more context
  switch semanticLevel?.base {
         ~~~~~~~~~~~~~~~^~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:75:11: error: cannot find 'DSLTree' in scope
    dsl = DSLTree(.nonCapturingGroup(.init(ast: .changeMatchingOptions(sequence)), ast.dslTree.root))
          ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:78:11: error: cannot find 'DSLTree' in scope
    dsl = DSLTree(.nonCapturingGroup(.init(ast: .changeMatchingOptions(sequence)), ast.dslTree.root))
          ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:80:15: error: value of type 'AST' has no member 'dslTree'
    dsl = ast.dslTree
          ~~~ ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:82:29: error: incorrect argument label in call (have 'tree:', expected 'ast:')
  let program = try Compiler(tree: dsl).emit()
                            ^~~~~
                             ast
[22/72] Compiling _StringProcessing TwoWaySearcher.swift
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Algorithms/StartsWith.swift:62:17: error: cannot find type 'RegexComponent' in scope
  func _ends<R: RegexComponent>(with regex: R) -> Bool {
                ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:863:11: error: cannot find type 'DSLTree' in scope
extension DSLTree.Node {
          ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:12:2: warning: '@_spi' import of 'Swift' will not include any SPI symbols; 'Swift' was built from the public interface at /Users/lilylin/Downloads/Xcode-beta 2.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.0.sdk/usr/lib/swift/Swift.swiftmodule/arm64e-apple-macos.swiftinterface
@_spi(_Unicode)
 ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:21:24: error: cannot find type 'DSLTree' in scope
    var asciiBitsets: [DSLTree.CustomCharacterClass.AsciiBitset] = []
                       ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:44:32: error: cannot find type 'ReferenceID' in scope
    var unresolvedReferences: [ReferenceID: [InstructionAddress]] = [:]
                               ^~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:45:36: error: cannot find type 'ReferenceID' in scope
    var referencedCaptureOffsets: [ReferenceID: Int] = [:]
                                   ^~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:41:34: error: cannot find type 'DSLTree' in scope
  mutating func emitRoot(_ root: DSLTree.Node) throws -> MEProgram {
                                 ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:51:31: error: cannot find type 'DSLTree' in scope
  mutating func emitAtom(_ a: DSLTree.Atom) throws {
                              ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:349:18: error: cannot find type 'DSLTree' in scope
    _ children: [DSLTree.Node]
                 ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:380:13: error: cannot find type 'DSLTree' in scope
    _ node: DSLTree.Node
            ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:389:14: error: cannot find type 'DSLTree' in scope
    _ child: DSLTree.Node
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:434:14: error: cannot find type 'DSLTree' in scope
    _ child: DSLTree.Node
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:466:26: error: cannot find type '_MatcherInterface' in scope
    _ matcher: @escaping _MatcherInterface
                         ^~~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:484:14: error: cannot find type 'DSLTree' in scope
    _ child: DSLTree.Node
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:522:13: error: cannot find type 'DSLTree' in scope
    _ kind: DSLTree.QuantificationKind,
            ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:523:14: error: cannot find type 'DSLTree' in scope
    _ child: DSLTree.Node
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:755:12: error: cannot find type 'DSLTree' in scope
    _ ccc: DSLTree.CustomCharacterClass
           ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:771:34: error: cannot find type 'DSLTree' in scope
  mutating func emitNode(_ node: DSLTree.Node) throws -> ValueRegister? {
                                 ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:44:19: error: cannot infer contextual base in reference to member 'capture'
    try emitNode(.capture(name: nil, reference: nil, root))
                 ~^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:44:33: error: 'nil' requires a contextual type
    try emitNode(.capture(name: nil, reference: nil, root))
                                ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:44:49: error: 'nil' requires a contextual type
    try emitNode(.capture(name: nil, reference: nil, root))
                                                ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:242:46: error: cannot find type 'ReferenceID' in scope
  mutating func buildUnresolvedReference(id: ReferenceID) {
                                             ^~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Algorithms/Contains.swift:76:38: error: cannot find type 'RegexComponent' in scope
  public func contains(_ regex: some RegexComponent) -> Bool {
                                     ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:169:10: error: cannot find type 'DSLTree' in scope
    _ b: DSLTree.CustomCharacterClass.AsciiBitset
         ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:162:10: error: cannot find type 'DSLTree' in scope
    _ b: DSLTree.CustomCharacterClass.AsciiBitset
         ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:412:9: error: cannot find type 'ReferenceID' in scope
    id: ReferenceID?, name: String?
        ^~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Capture.swift:41:11: error: cannot find type 'AnyRegexOutput' in scope
extension AnyRegexOutput.Element {
          ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Capture.swift:59:37: error: cannot find type 'AnyRegexOutput' in scope
extension Sequence where Element == AnyRegexOutput.Element {
                                    ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Capture.swift:65:10: error: value of type 'Self.Element' has no member 'existentialOutputComponent'
      $0.existentialOutputComponent(from: input)
      ~~ ^~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Capture.swift:73:19: error: value of type 'Self.Element' has no member 'slice'
    self.map { $0.slice(from: input) }
               ~~ ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:15:13: error: cannot find type 'DSLTree' in scope
  let tree: DSLTree
            ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:25:14: error: cannot find type 'DSLTree' in scope
  init(tree: DSLTree) {
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:29:14: error: cannot find type 'DSLTree' in scope
  init(tree: DSLTree, compileOptions: CompileOptions) {
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:67:20: error: cannot find type 'RegexSemanticLevel' in scope
  _ semanticLevel: RegexSemanticLevel? = nil
                   ^~~~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:22:21: error: value of type 'AST' has no member 'dslTree'
    self.tree = ast.dslTree
                ~~~ ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:70:12: error: cannot find type 'DSLTree' in scope
  let dsl: DSLTree
           ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:72:25: error: type of expression is ambiguous without more context
  switch semanticLevel?.base {
         ~~~~~~~~~~~~~~~^~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:75:11: error: cannot find 'DSLTree' in scope
    dsl = DSLTree(.nonCapturingGroup(.init(ast: .changeMatchingOptions(sequence)), ast.dslTree.root))
          ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:78:11: error: cannot find 'DSLTree' in scope
    dsl = DSLTree(.nonCapturingGroup(.init(ast: .changeMatchingOptions(sequence)), ast.dslTree.root))
          ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:80:15: error: value of type 'AST' has no member 'dslTree'
    dsl = ast.dslTree
          ~~~ ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:82:29: error: incorrect argument label in call (have 'tree:', expected 'ast:')
  let program = try Compiler(tree: dsl).emit()
                            ^~~~~
                             ast
[23/72] Compiling _StringProcessing ZSearcher.swift
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Algorithms/StartsWith.swift:62:17: error: cannot find type 'RegexComponent' in scope
  func _ends<R: RegexComponent>(with regex: R) -> Bool {
                ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:863:11: error: cannot find type 'DSLTree' in scope
extension DSLTree.Node {
          ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:12:2: warning: '@_spi' import of 'Swift' will not include any SPI symbols; 'Swift' was built from the public interface at /Users/lilylin/Downloads/Xcode-beta 2.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.0.sdk/usr/lib/swift/Swift.swiftmodule/arm64e-apple-macos.swiftinterface
@_spi(_Unicode)
 ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:21:24: error: cannot find type 'DSLTree' in scope
    var asciiBitsets: [DSLTree.CustomCharacterClass.AsciiBitset] = []
                       ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:44:32: error: cannot find type 'ReferenceID' in scope
    var unresolvedReferences: [ReferenceID: [InstructionAddress]] = [:]
                               ^~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:45:36: error: cannot find type 'ReferenceID' in scope
    var referencedCaptureOffsets: [ReferenceID: Int] = [:]
                                   ^~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:41:34: error: cannot find type 'DSLTree' in scope
  mutating func emitRoot(_ root: DSLTree.Node) throws -> MEProgram {
                                 ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:51:31: error: cannot find type 'DSLTree' in scope
  mutating func emitAtom(_ a: DSLTree.Atom) throws {
                              ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:349:18: error: cannot find type 'DSLTree' in scope
    _ children: [DSLTree.Node]
                 ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:380:13: error: cannot find type 'DSLTree' in scope
    _ node: DSLTree.Node
            ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:389:14: error: cannot find type 'DSLTree' in scope
    _ child: DSLTree.Node
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:434:14: error: cannot find type 'DSLTree' in scope
    _ child: DSLTree.Node
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:466:26: error: cannot find type '_MatcherInterface' in scope
    _ matcher: @escaping _MatcherInterface
                         ^~~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:484:14: error: cannot find type 'DSLTree' in scope
    _ child: DSLTree.Node
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:522:13: error: cannot find type 'DSLTree' in scope
    _ kind: DSLTree.QuantificationKind,
            ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:523:14: error: cannot find type 'DSLTree' in scope
    _ child: DSLTree.Node
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:755:12: error: cannot find type 'DSLTree' in scope
    _ ccc: DSLTree.CustomCharacterClass
           ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:771:34: error: cannot find type 'DSLTree' in scope
  mutating func emitNode(_ node: DSLTree.Node) throws -> ValueRegister? {
                                 ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:44:19: error: cannot infer contextual base in reference to member 'capture'
    try emitNode(.capture(name: nil, reference: nil, root))
                 ~^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:44:33: error: 'nil' requires a contextual type
    try emitNode(.capture(name: nil, reference: nil, root))
                                ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:44:49: error: 'nil' requires a contextual type
    try emitNode(.capture(name: nil, reference: nil, root))
                                                ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:242:46: error: cannot find type 'ReferenceID' in scope
  mutating func buildUnresolvedReference(id: ReferenceID) {
                                             ^~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Algorithms/Contains.swift:76:38: error: cannot find type 'RegexComponent' in scope
  public func contains(_ regex: some RegexComponent) -> Bool {
                                     ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:169:10: error: cannot find type 'DSLTree' in scope
    _ b: DSLTree.CustomCharacterClass.AsciiBitset
         ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:162:10: error: cannot find type 'DSLTree' in scope
    _ b: DSLTree.CustomCharacterClass.AsciiBitset
         ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:412:9: error: cannot find type 'ReferenceID' in scope
    id: ReferenceID?, name: String?
        ^~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Capture.swift:41:11: error: cannot find type 'AnyRegexOutput' in scope
extension AnyRegexOutput.Element {
          ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Capture.swift:59:37: error: cannot find type 'AnyRegexOutput' in scope
extension Sequence where Element == AnyRegexOutput.Element {
                                    ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Capture.swift:65:10: error: value of type 'Self.Element' has no member 'existentialOutputComponent'
      $0.existentialOutputComponent(from: input)
      ~~ ^~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Capture.swift:73:19: error: value of type 'Self.Element' has no member 'slice'
    self.map { $0.slice(from: input) }
               ~~ ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:15:13: error: cannot find type 'DSLTree' in scope
  let tree: DSLTree
            ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:25:14: error: cannot find type 'DSLTree' in scope
  init(tree: DSLTree) {
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:29:14: error: cannot find type 'DSLTree' in scope
  init(tree: DSLTree, compileOptions: CompileOptions) {
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:67:20: error: cannot find type 'RegexSemanticLevel' in scope
  _ semanticLevel: RegexSemanticLevel? = nil
                   ^~~~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:22:21: error: value of type 'AST' has no member 'dslTree'
    self.tree = ast.dslTree
                ~~~ ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:70:12: error: cannot find type 'DSLTree' in scope
  let dsl: DSLTree
           ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:72:25: error: type of expression is ambiguous without more context
  switch semanticLevel?.base {
         ~~~~~~~~~~~~~~~^~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:75:11: error: cannot find 'DSLTree' in scope
    dsl = DSLTree(.nonCapturingGroup(.init(ast: .changeMatchingOptions(sequence)), ast.dslTree.root))
          ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:78:11: error: cannot find 'DSLTree' in scope
    dsl = DSLTree(.nonCapturingGroup(.init(ast: .changeMatchingOptions(sequence)), ast.dslTree.root))
          ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:80:15: error: value of type 'AST' has no member 'dslTree'
    dsl = ast.dslTree
          ~~~ ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:82:29: error: incorrect argument label in call (have 'tree:', expected 'ast:')
  let program = try Compiler(tree: dsl).emit()
                            ^~~~~
                             ast
[24/72] Compiling _StringProcessing ByteCodeGen.swift
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Algorithms/StartsWith.swift:62:17: error: cannot find type 'RegexComponent' in scope
  func _ends<R: RegexComponent>(with regex: R) -> Bool {
                ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:863:11: error: cannot find type 'DSLTree' in scope
extension DSLTree.Node {
          ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:12:2: warning: '@_spi' import of 'Swift' will not include any SPI symbols; 'Swift' was built from the public interface at /Users/lilylin/Downloads/Xcode-beta 2.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.0.sdk/usr/lib/swift/Swift.swiftmodule/arm64e-apple-macos.swiftinterface
@_spi(_Unicode)
 ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:21:24: error: cannot find type 'DSLTree' in scope
    var asciiBitsets: [DSLTree.CustomCharacterClass.AsciiBitset] = []
                       ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:44:32: error: cannot find type 'ReferenceID' in scope
    var unresolvedReferences: [ReferenceID: [InstructionAddress]] = [:]
                               ^~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:45:36: error: cannot find type 'ReferenceID' in scope
    var referencedCaptureOffsets: [ReferenceID: Int] = [:]
                                   ^~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:41:34: error: cannot find type 'DSLTree' in scope
  mutating func emitRoot(_ root: DSLTree.Node) throws -> MEProgram {
                                 ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:51:31: error: cannot find type 'DSLTree' in scope
  mutating func emitAtom(_ a: DSLTree.Atom) throws {
                              ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:349:18: error: cannot find type 'DSLTree' in scope
    _ children: [DSLTree.Node]
                 ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:380:13: error: cannot find type 'DSLTree' in scope
    _ node: DSLTree.Node
            ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:389:14: error: cannot find type 'DSLTree' in scope
    _ child: DSLTree.Node
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:434:14: error: cannot find type 'DSLTree' in scope
    _ child: DSLTree.Node
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:466:26: error: cannot find type '_MatcherInterface' in scope
    _ matcher: @escaping _MatcherInterface
                         ^~~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:484:14: error: cannot find type 'DSLTree' in scope
    _ child: DSLTree.Node
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:522:13: error: cannot find type 'DSLTree' in scope
    _ kind: DSLTree.QuantificationKind,
            ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:523:14: error: cannot find type 'DSLTree' in scope
    _ child: DSLTree.Node
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:755:12: error: cannot find type 'DSLTree' in scope
    _ ccc: DSLTree.CustomCharacterClass
           ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:771:34: error: cannot find type 'DSLTree' in scope
  mutating func emitNode(_ node: DSLTree.Node) throws -> ValueRegister? {
                                 ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:44:19: error: cannot infer contextual base in reference to member 'capture'
    try emitNode(.capture(name: nil, reference: nil, root))
                 ~^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:44:33: error: 'nil' requires a contextual type
    try emitNode(.capture(name: nil, reference: nil, root))
                                ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:44:49: error: 'nil' requires a contextual type
    try emitNode(.capture(name: nil, reference: nil, root))
                                                ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:242:46: error: cannot find type 'ReferenceID' in scope
  mutating func buildUnresolvedReference(id: ReferenceID) {
                                             ^~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Algorithms/Contains.swift:76:38: error: cannot find type 'RegexComponent' in scope
  public func contains(_ regex: some RegexComponent) -> Bool {
                                     ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:169:10: error: cannot find type 'DSLTree' in scope
    _ b: DSLTree.CustomCharacterClass.AsciiBitset
         ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:162:10: error: cannot find type 'DSLTree' in scope
    _ b: DSLTree.CustomCharacterClass.AsciiBitset
         ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:412:9: error: cannot find type 'ReferenceID' in scope
    id: ReferenceID?, name: String?
        ^~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Capture.swift:41:11: error: cannot find type 'AnyRegexOutput' in scope
extension AnyRegexOutput.Element {
          ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Capture.swift:59:37: error: cannot find type 'AnyRegexOutput' in scope
extension Sequence where Element == AnyRegexOutput.Element {
                                    ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Capture.swift:65:10: error: value of type 'Self.Element' has no member 'existentialOutputComponent'
      $0.existentialOutputComponent(from: input)
      ~~ ^~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Capture.swift:73:19: error: value of type 'Self.Element' has no member 'slice'
    self.map { $0.slice(from: input) }
               ~~ ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:15:13: error: cannot find type 'DSLTree' in scope
  let tree: DSLTree
            ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:25:14: error: cannot find type 'DSLTree' in scope
  init(tree: DSLTree) {
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:29:14: error: cannot find type 'DSLTree' in scope
  init(tree: DSLTree, compileOptions: CompileOptions) {
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:67:20: error: cannot find type 'RegexSemanticLevel' in scope
  _ semanticLevel: RegexSemanticLevel? = nil
                   ^~~~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:22:21: error: value of type 'AST' has no member 'dslTree'
    self.tree = ast.dslTree
                ~~~ ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:70:12: error: cannot find type 'DSLTree' in scope
  let dsl: DSLTree
           ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:72:25: error: type of expression is ambiguous without more context
  switch semanticLevel?.base {
         ~~~~~~~~~~~~~~~^~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:75:11: error: cannot find 'DSLTree' in scope
    dsl = DSLTree(.nonCapturingGroup(.init(ast: .changeMatchingOptions(sequence)), ast.dslTree.root))
          ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:78:11: error: cannot find 'DSLTree' in scope
    dsl = DSLTree(.nonCapturingGroup(.init(ast: .changeMatchingOptions(sequence)), ast.dslTree.root))
          ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:80:15: error: value of type 'AST' has no member 'dslTree'
    dsl = ast.dslTree
          ~~~ ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:82:29: error: incorrect argument label in call (have 'tree:', expected 'ast:')
  let program = try Compiler(tree: dsl).emit()
                            ^~~~~
                             ast
[25/72] Compiling _StringProcessing Capture.swift
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Algorithms/StartsWith.swift:62:17: error: cannot find type 'RegexComponent' in scope
  func _ends<R: RegexComponent>(with regex: R) -> Bool {
                ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:863:11: error: cannot find type 'DSLTree' in scope
extension DSLTree.Node {
          ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:12:2: warning: '@_spi' import of 'Swift' will not include any SPI symbols; 'Swift' was built from the public interface at /Users/lilylin/Downloads/Xcode-beta 2.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.0.sdk/usr/lib/swift/Swift.swiftmodule/arm64e-apple-macos.swiftinterface
@_spi(_Unicode)
 ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:21:24: error: cannot find type 'DSLTree' in scope
    var asciiBitsets: [DSLTree.CustomCharacterClass.AsciiBitset] = []
                       ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:44:32: error: cannot find type 'ReferenceID' in scope
    var unresolvedReferences: [ReferenceID: [InstructionAddress]] = [:]
                               ^~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:45:36: error: cannot find type 'ReferenceID' in scope
    var referencedCaptureOffsets: [ReferenceID: Int] = [:]
                                   ^~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:41:34: error: cannot find type 'DSLTree' in scope
  mutating func emitRoot(_ root: DSLTree.Node) throws -> MEProgram {
                                 ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:51:31: error: cannot find type 'DSLTree' in scope
  mutating func emitAtom(_ a: DSLTree.Atom) throws {
                              ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:349:18: error: cannot find type 'DSLTree' in scope
    _ children: [DSLTree.Node]
                 ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:380:13: error: cannot find type 'DSLTree' in scope
    _ node: DSLTree.Node
            ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:389:14: error: cannot find type 'DSLTree' in scope
    _ child: DSLTree.Node
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:434:14: error: cannot find type 'DSLTree' in scope
    _ child: DSLTree.Node
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:466:26: error: cannot find type '_MatcherInterface' in scope
    _ matcher: @escaping _MatcherInterface
                         ^~~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:484:14: error: cannot find type 'DSLTree' in scope
    _ child: DSLTree.Node
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:522:13: error: cannot find type 'DSLTree' in scope
    _ kind: DSLTree.QuantificationKind,
            ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:523:14: error: cannot find type 'DSLTree' in scope
    _ child: DSLTree.Node
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:755:12: error: cannot find type 'DSLTree' in scope
    _ ccc: DSLTree.CustomCharacterClass
           ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:771:34: error: cannot find type 'DSLTree' in scope
  mutating func emitNode(_ node: DSLTree.Node) throws -> ValueRegister? {
                                 ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:44:19: error: cannot infer contextual base in reference to member 'capture'
    try emitNode(.capture(name: nil, reference: nil, root))
                 ~^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:44:33: error: 'nil' requires a contextual type
    try emitNode(.capture(name: nil, reference: nil, root))
                                ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/ByteCodeGen.swift:44:49: error: 'nil' requires a contextual type
    try emitNode(.capture(name: nil, reference: nil, root))
                                                ^
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:242:46: error: cannot find type 'ReferenceID' in scope
  mutating func buildUnresolvedReference(id: ReferenceID) {
                                             ^~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Algorithms/Contains.swift:76:38: error: cannot find type 'RegexComponent' in scope
  public func contains(_ regex: some RegexComponent) -> Bool {
                                     ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:169:10: error: cannot find type 'DSLTree' in scope
    _ b: DSLTree.CustomCharacterClass.AsciiBitset
         ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:162:10: error: cannot find type 'DSLTree' in scope
    _ b: DSLTree.CustomCharacterClass.AsciiBitset
         ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Engine/MEBuilder.swift:412:9: error: cannot find type 'ReferenceID' in scope
    id: ReferenceID?, name: String?
        ^~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Capture.swift:41:11: error: cannot find type 'AnyRegexOutput' in scope
extension AnyRegexOutput.Element {
          ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Capture.swift:59:37: error: cannot find type 'AnyRegexOutput' in scope
extension Sequence where Element == AnyRegexOutput.Element {
                                    ^~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Capture.swift:65:10: error: value of type 'Self.Element' has no member 'existentialOutputComponent'
      $0.existentialOutputComponent(from: input)
      ~~ ^~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Capture.swift:73:19: error: value of type 'Self.Element' has no member 'slice'
    self.map { $0.slice(from: input) }
               ~~ ^~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:15:13: error: cannot find type 'DSLTree' in scope
  let tree: DSLTree
            ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:25:14: error: cannot find type 'DSLTree' in scope
  init(tree: DSLTree) {
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:29:14: error: cannot find type 'DSLTree' in scope
  init(tree: DSLTree, compileOptions: CompileOptions) {
             ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:67:20: error: cannot find type 'RegexSemanticLevel' in scope
  _ semanticLevel: RegexSemanticLevel? = nil
                   ^~~~~~~~~~~~~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:22:21: error: value of type 'AST' has no member 'dslTree'
    self.tree = ast.dslTree
                ~~~ ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:70:12: error: cannot find type 'DSLTree' in scope
  let dsl: DSLTree
           ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:72:25: error: type of expression is ambiguous without more context
  switch semanticLevel?.base {
         ~~~~~~~~~~~~~~~^~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:75:11: error: cannot find 'DSLTree' in scope
    dsl = DSLTree(.nonCapturingGroup(.init(ast: .changeMatchingOptions(sequence)), ast.dslTree.root))
          ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:78:11: error: cannot find 'DSLTree' in scope
    dsl = DSLTree(.nonCapturingGroup(.init(ast: .changeMatchingOptions(sequence)), ast.dslTree.root))
          ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:80:15: error: value of type 'AST' has no member 'dslTree'
    dsl = ast.dslTree
          ~~~ ^~~~~~~
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Compiler.swift:82:29: error: incorrect argument label in call (have 'tree:', expected 'ast:')
  let program = try Compiler(tree: dsl).emit()
                            ^~~~~
                             ast
[26/72] Compiling _StringProcessing Compiler.swift
/Users/lilylin/Work/swift-project/swift-experimental-string-processing/Sources/_StringProcessing/Algorithms/Algorithms/StartsWith.swift:62:17: error: cannot find type 'RegexComponent' in scope
  func _ends<R: RegexComponent>(with regex: R) -> Bool {
                ^~~~~~~~~~~~~~
"""#
}
