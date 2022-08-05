import Foundation

enum Stats {}

extension Stats {
  // 500µs, maybe this should be a % of the runtime for each benchmark?
  static let maxAllowedStdev = 500e-6

  static func tTest(_ a: Measurement, _ b: Measurement) -> Bool {
    // Student's t-test
    // Since we should generally have similar variances across runs
    let n1 = Double(a.samples)
    let n2 = Double(b.samples)
    let sPNumerator = (n1 - 1) * pow(a.stdev, 2) + (n2 - 1) * pow(b.stdev, 2)
    let sPDenominator = n1 + n2 - 2
    let sP = (sPNumerator/sPDenominator).squareRoot()
    let tVal = (a.median.seconds - b.median.seconds) / (sP * (pow(n1, -1) + pow(n2, -1)).squareRoot())
    return abs(tVal) > 2
  }
}
