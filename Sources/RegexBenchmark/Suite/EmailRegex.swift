import _StringProcessing
import Foundation

extension BenchmarkRunner {
  mutating func addEmail() {
    // Regexes from https://www.regular-expressions.info/email.html
    // Inputs.validEmails is generated by Utils/generateEmails.py
    
    // Relatively simple regex to match email addresses, based on the offical RFC grammar
    let emailRFC = #"[A-z0-9!#$%&'*+\/=?^_‘{|}~-]+(?:\.[A-z0-9!#$%&'*+\/=?^_‘{|}~-]+)*@(?:[A-z0-9](?:[A-z0-9-]*[A-z0-9])?\.)+[A-z0-9](?:[A-z0-9-]*[A-z0-9])?"#
    
    // More complex, does length and consecutive hyphen validation via lookaheads
    let emailWithLookaheads = #"(?=[A-z0-9][A-z0-9@._%+-]{5,253})[A-z0-9._%+-]{1,64}@(?:(?=[A-z0-9-]{1,63}\.)[A-z0-9]+(?:-[A-z0-9]+)*\.){1,8}[A-z]{2,63}"#
    
    let emailRFCValid = CrossBenchmark(
      baseName: "EmailRFC", regex: emailRFC, input: Inputs.validEmails)
    
    let emailRFCInvalid = CrossBenchmark(
      baseName: "EmailRFCNoMatches",
      regex: emailRFC,
      input: Inputs.graphemeBreakData
    )
    
    let emailValid = CrossBenchmark(
      baseName: "EmailLookahead",
      regex: emailWithLookaheads,
      input: Inputs.validEmails
    )
    
    let emailInvalid = CrossBenchmark(
      baseName: "EmailLookaheadNoMatches",
      regex: emailWithLookaheads,
      input: Inputs.graphemeBreakData
    )
    
    emailRFCValid.register(&self)
    emailRFCInvalid.register(&self)
    emailValid.register(&self)
    emailInvalid.register(&self)
  }
}
