//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension String {
  internal struct WordView {
    var base: String
  }
}

extension String.WordView: Collection {
  typealias Index = String.Index
  typealias Element = Substring
  
  var startIndex: Index {
    base.startIndex
  }
  
  var endIndex: Index {
    base.endIndex
  }
  
  func index(after i: Index) -> Index {
    _internalInvariant(i != endIndex)
    
    let nextIndex = nextBoundary(startingAt: i._encodedOffset) {
      let index = String.Index(_encodedOffset: $0)
      let scalar = base.unicodeScalars[index]
      
      if base._guts.isforeign() {
        return (scalar, $0 &+ UTF16.width(scalar))
      } else {
        return (scalar, $0 &+ UTF8.width(scalar))
      }
    }
    
    return String.Index(_encodedOffset: nextIndex)
  }
  
  subscript(position: Index) -> Element {
    let indexAfter = index(after: position)
    
    return base[position ..< indexAfter]
  }
}

extension String.WordView: BidirectionalCollection {
  func index(before i: Index) -> Index {
    _internalInvariant(i != startIndex)
    
    let previousIndex = previousBoundary(endingAt: i._encodedOffset) {
      var index = String.Index(_encodedOffset: $0)
      base.unicodeScalars.formIndex(before: &index)
      let scalar = base.unicodeScalars[index]
      
      if base._guts.isforeign() {
        return (scalar, $0 &- UTF16.width(scalar))
      } else {
        return (scalar, $0 &- UTF8.width(scalar))
      }
    }
    
    return String.Index(_encodedOffset: previousIndex)
  }
}

extension String {
  internal var words: WordView {
    WordView(base: self)
  }
}

extension String {
  internal func isOnWordBoundary(_ i: String.Index) -> Bool {
    guard i != startIndex, i != endIndex else {
      return true
    }
    
    guard i._isScalarAligned else {
      return false
    }
    
    let after = words.index(after: i)
    let before = words.index(before: after)
    
    return i == before
  }
}
