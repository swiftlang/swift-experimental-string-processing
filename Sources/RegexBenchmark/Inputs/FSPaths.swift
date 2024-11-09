// Successful match FSPaths
private let fsPathSuccess = #"""
./First/Second/Third/some/really/long/content.extension/more/stuff/OptionLeft
./First/Second/Third/some/really/long/content.extension/more/stuff/OptionRight
./First/Second/PrefixThird/some/really/long/content.extension/more/stuff/OptionLeft
./First/Second/PrefixThird/some/really/long/content.extension/more/stuff/OptionRight
"""#

// Unsucessful match FSPaths.
//
// We will have far more failures than successful matches by interspersing
// this whole list between each success
private let fsPathFailure = #"""
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

extension Inputs {
  static let fsPathsList: [String] = {
    var result: [String] = []
    let failures: [String] = fsPathFailure.split(whereSeparator: { $0.isNewline }).map { String($0) }
    result.append(contentsOf: failures)

    for success in fsPathSuccess.split(whereSeparator: { $0.isNewline }) {
      result.append(String(success))
      result.append(contentsOf: failures)
    }

    // Scale result up a bit
    result.append(contentsOf: result)
    result.append(contentsOf: result)
    result.append(contentsOf: result)
    result.append(contentsOf: result)

    return result

  }()
}
