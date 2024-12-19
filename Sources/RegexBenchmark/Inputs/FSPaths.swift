// Successful match FSPaths
private let pathSuccess = #"""
./First/Second/Third/some/really/long/content.extension/more/stuff/OptionLeft
./First/Second/Third/some/really/long/content.extension/more/stuff/OptionRight
./First/Second/PrefixThird/some/really/long/content.extension/more/stuff/OptionLeft
./First/Second/PrefixThird/some/really/long/content.extension/more/stuff/OptionRight
"""#

// Unsucessful match FSPaths.
//
// We will have far more failures than successful matches by interspersing
// this whole list between each success
private let pathFailure = #"""
a/b/c
/smol/path
/a/really/long/path/that/is/certainly/stored/out/of/line
./First/Second/Third/some/really/long/content.extension/more/stuff/NothingToSeeHere
./First/Second/PrefixThird/some/really/long/content.extension/more/stuff/NothingToSeeHere
./First/Second/Third/some/really/long/content.extension/more/stuff/OptionNeither
./First/Second/PrefixThird/some/really/long/content.extension/more/stuff/OptionNeither
/First/Second/Third/some/really/long/content.extension/more/stuff/OptionLeft
/First/Second/Third/some/really/long/content.extension/more/stuff/OptionRight
/First/Second/PrefixThird/some/really/long/content.extension/more/stuff/OptionLeft
/First/Second/PrefixThird/some/really/long/content.extension/more/stuff/OptionRight
./First/Second/Third/some/really/long/content/more/stuff/OptionLeft
./First/Second/Third/some/really/long/content/more/stuff/OptionRight
./First/Second/PrefixThird/some/really/long/content/more/stuff/OptionLeft
./First/Second/PrefixThird/some/really/long/content/more/stuff/OptionRight
"""#

private func listify(_ s: String) -> [String] {
  s.split(whereSeparator: { $0.isNewline }).map { String($0) }
}

private let pathSuccessList: [String] = { listify(pathSuccess) }()
private let pathFailureList: [String] = { listify(pathFailure) }()

private func scale(_ input: [String]) -> [String] {
  let threshold = 1_000
  var result = input
  while result.count < threshold {
    result.append(contentsOf: input)
  }
  return result
}

extension Inputs {
  static let fsPathsList: [String] = {
    var result = pathFailureList
    result.append(contentsOf: pathFailureList)

    for success in pathSuccessList {
      result.append(String(success))
      result.append(contentsOf: pathFailureList)
      result.append(contentsOf: pathFailureList)
    }

    // Scale result up a bit
    return scale(result)

  }()

  static let fsPathsNotFoundList: [String] = {
    scale(pathFailureList)
  }()

  static let fsPathsFoundList: [String] = {
    scale(pathFailureList)
  }()
}
