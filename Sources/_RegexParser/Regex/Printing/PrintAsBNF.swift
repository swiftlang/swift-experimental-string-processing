//
//  PrintAsBNF.swift
//  swift-experimental-string-processing
//
//  Created by Michael Ilseman on 1/9/25.
//

// Move to CL tool, but keep render here
// TODO: some kinda API/SPI
public func _printAsBNF(inputRegex: String) throws -> String {

  // TODO: Should we pass in our language subset constraints here to
  // error at parse time rather than render time?
  let ast = try _RegexParser.parse(inputRegex, .init())

  return try ast.renderAsBNF()
}

// Regex AST -> BNF
func convert(_ ast: AST) throws -> BNF {
  var converter = BNFConvert()
  let rhs = try converter.convert(ast.root)
  converter.root = converter.createProduction("ROOT", rhs)
  converter.optimize()
  return converter.createBNF()
}

extension AST {
  public func renderAsBNF() throws -> String {
    let bnf = try convert(self)
    return bnf.render()
  }
}
