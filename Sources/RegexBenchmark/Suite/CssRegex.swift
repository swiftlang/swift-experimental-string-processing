import Foundation
import _StringProcessing

extension BenchmarkRunner {
  mutating func addCSS() {
    let r = #"--([a-zA-Z0-9_-]+)\s*:\s*(.*?);"#

    // FIXME: Why is `first` and `all` the same running time?

    let css = CrossBenchmark(
      baseName: "css", regex: r, input: Inputs.swiftOrgCSS)
    css.register(&self)
  }
}
