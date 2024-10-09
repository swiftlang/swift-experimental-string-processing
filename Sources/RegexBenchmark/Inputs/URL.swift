extension Inputs {
  static let url: String = {
    let element = """
        Item 1     |        Item 2®                 •Item 3  Item4


          \t\t\t

        Check it out here: http://www.test.com/this-is-a-fake-url-that-should-be-replaced?a=1
        Check it out here: https://www.test.com/this-is-a-fake-url-that-should-be-replaced?a=1
        This is not a web link ftp://user@host:domain.com/path
        This is a link without a scheme www.apple.com/mac

        This is some good text and should not be removed.
        Thanks.
        😀🩷🤵🏿
        """
    let multiplier = 30
    return Array(repeating: element, count: multiplier).joined()
  }()

}
