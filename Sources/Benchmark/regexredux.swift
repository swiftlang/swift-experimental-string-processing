import Foundation
import Dispatch
import _StringProcessing

// The Computer Language Benchmarks Game
// https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
//
// contributed by Francois Green
// variant concurrency added by Daniel Sell
func nsregexRedux() {
  let input = FileManager.default.contents(
    atPath: "input500000.txt"
  )!
  
  var sequence = String(data: input, encoding: .ascii)!
  
  let inputLength = input.count
  
  let regex: (String) -> NSRegularExpression = { pattern in
    return try! NSRegularExpression(pattern: pattern, options: [])
  }
  
  sequence = sequence.replacingOccurrences(of: ">[^\n]*\n|\n", with: "",
                                           options: .regularExpression)
  
  let codeLength = sequence.utf8.count
  
  var resultLength = 0
  
  let group = DispatchGroup()
  
  group.enter()
  DispatchQueue.global().async {
    resultLength = [
      (regex: "tHa[Nt]",            replacement: "<4>"),
      (regex: "aND|caN|Ha[DS]|WaS", replacement: "<3>"),
      (regex: "a[NSt]|BY",          replacement: "<2>"),
      (regex: "<[^>]*>",            replacement: "|"),
      (regex: "\\|[^|][^|]*\\|",    replacement: "-")
    ].reduce(sequence) { buffer, iub in
      return buffer.replacingOccurrences(of: iub.regex,
                                         with: iub.replacement, options: .regularExpression)
    }.utf8.count
    group.leave()
  }
  
  let variants = [
    "agggtaaa|tttaccct",
    "[cgt]gggtaaa|tttaccc[acg]",
    "a[act]ggtaaa|tttacc[agt]t",
    "ag[act]gtaaa|tttac[agt]ct",
    "agg[act]taaa|ttta[agt]cct",
    "aggg[acg]aaa|ttt[cgt]ccct",
    "agggt[cgt]aa|tt[acg]accct",
    "agggta[cgt]a|t[acg]taccct",
    "agggtaa[cgt]|[acg]ttaccct",
  ]
  
  var variantMatches = Array(repeating: 0, count: variants.count)
  
  for (i, variant) in variants.enumerated() {
    group.enter()
    DispatchQueue.global().async {
      variantMatches[i] = regex(variant).numberOfMatches(in: sequence,
                                                         options: [], range: NSRange(location: 0, length: codeLength))
      group.leave()
    }
  }
  
  group.wait()
  
  for (i, variant) in variants.enumerated() {
    print(variant, variantMatches[i])
  }
  
  print("", inputLength, codeLength, resultLength, separator: "\n")
}
