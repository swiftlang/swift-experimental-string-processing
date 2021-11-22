
extension FixedWidthInteger {
  var hexStr: String {
    String(self, radix: 16, uppercase: true)
  }
}

func unreachable(_ s: @autoclosure () -> String) -> Never {
  fatalError("unreachable \(s())")
}
func unreachable() -> Never {
  fatalError("unreachable")
}
