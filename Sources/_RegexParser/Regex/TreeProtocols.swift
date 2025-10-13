//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2021-2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

public protocol _TreeNode {
  var children: [Self]? { get }
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


