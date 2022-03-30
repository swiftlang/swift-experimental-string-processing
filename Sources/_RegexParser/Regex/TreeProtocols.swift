

public protocol _TreeNode {
  var children: [Self]? { get }

  func _captureStructure(
    _: inout CaptureStructure.Constructor
  ) -> CaptureStructure
}

extension _TreeNode {
  public var height: Int {
    // FIXME: Is this right for custom char classes?
    // How do we count set operations?
    guard let children = self.children else {
      return 1
    }
    guard let max = children.lazy.map(\.height).max() else {
      return 1
    }
    return 1 + max
  }
}

// TODO: Pretty-printing helpers, etc


