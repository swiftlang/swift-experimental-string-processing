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

@_silgen_name("_swift_stdlib_getWordBreakProperty")
func _swift_stdlib_getWordBreakProperty(_: UInt32) -> UInt8

extension Unicode {
  internal enum _WordBreakProperty {
    case aLetter
    case any
    case doubleQuote
    case extend
    case extendedPictographic
    case extendNumLet
    case format
    case hebrewLetter
    case katakana
    case midLetter
    case midNum
    case midNumLet
    case newlineCRLF
    case numeric
    case regionalIndicator
    case singleQuote
    case wSegSpace
    case zwj
    
    init(from scalar: Unicode.Scalar) {
      switch scalar.value {
      case 0xA ... 0xD,
           0x85,
           0x2028 ... 0x2029:
        self = .newlineCRLF
      case 0x22:
        self = .doubleQuote
      case 0x27:
        self = .singleQuote
      case 0x200D:
        self = .zwj
      case 0x1F1E6 ... 0x1F1FF:
        self = .regionalIndicator
      default:
        let rawValue = _swift_stdlib_getWordBreakProperty(scalar.value)
        
        switch rawValue {
        case 0:
          self = .extend
        case 1:
          self = .format
        case 2:
          self = .katakana
        case 3:
          self = .hebrewLetter
        case 4:
          self = .aLetter
        case 5:
          self = .midNumLet
        case 6:
          self = .midLetter
        case 7:
          self = .midNum
        case 8:
          self = .numeric
        case 9:
          self = .extendNumLet
        case 10:
          self = .wSegSpace
        case 11:
          self = .extendedPictographic
        default:
          self = .any
        }
      }
    }
  }
}

internal struct _WordBreakingState {
  var previousIndex: Int? = nil
  var previousProperty: Unicode._WordBreakProperty? = nil
  var previousZWJ = false
  
  // When walking forward in a string, we need to not break on emoji flag
  // sequences. Emoji flag sequences are composed of 2 regional indicators, so
  // when we see our first (.regionalIndicator, .regionalIndicator) decision,
  // we need to know to return false in this case. However, if the next scalar
  // is another regional indicator, we reach the same decision rule, but in this
  // case we actually need to break there's a boundary between emoji flag
  // sequences.
  var shouldBreakRI = false
}

extension String.WordView {
  // Returns the stride of the next word at the previous boundary offset.
  internal func nextBoundary(
    startingAt index: Int,
    nextScalar: (Int) -> (Unicode.Scalar, end: Int)
  ) -> Int {
    _internalInvariant(index != endIndex._encodedOffset)
    var state = _WordBreakingState()
    var index = index
    
    while true {
      let (scalar1, nextIdx) = nextScalar(index)
      index = nextIdx
      
      guard index != endIndex._encodedOffset else {
        break
      }
      
      let (scalar2, _) = nextScalar(index)
      
      if shouldBreak(scalar1, between: scalar2, &state, index) {
        break
      }
    }
    
    return index
  }
  
  // Returns the stride of the previous word at the current boundary offset.
  internal func previousBoundary(
    endingAt index: Int,
    previousScalar: (Int) -> (Unicode.Scalar, start: Int)
  ) -> Int {
    _internalInvariant(index != startIndex._encodedOffset)
    var state = _WordBreakingState()
    var index = index
    
    while true {
      let (scalar2, previousIdx) = previousScalar(index)
      index = previousIdx
      
      guard index != startIndex._encodedOffset else {
        break
      }
      
      let (scalar1, _) = previousScalar(index)
      
      if shouldBreak(
        scalar1,
        between: scalar2,
        &state,
        index,
        isBackwards: true
      ) {
        break
      }
    }
    
    return index
  }
}

extension String.WordView {
  internal func peek(_ index: Int) -> Unicode._WordBreakProperty? {
    var index = String.Index(_encodedOffset: index)
    var result: Unicode._WordBreakProperty? = nil
    
    while true {
      base.unicodeScalars.formIndex(after: &index)
      
      guard index != endIndex else {
        return nil
      }
      
      let scalar = base.unicodeScalars[index]
      
      result = Unicode._WordBreakProperty(from: scalar)
      
      if result != .format && result != .extend && result != .zwj {
        break
      }
    }
    
    return result
  }
  
  internal func peekPrevious(_ index: Int) -> Unicode._WordBreakProperty? {
    var index = String.Index(_encodedOffset: index)
    var result: Unicode._WordBreakProperty? = .any
    
    while true {
      base.unicodeScalars.formIndex(before: &index)
      
      guard index != startIndex else {
        return nil
      }
      
      base.unicodeScalars.formIndex(before: &index)
      let scalar = base.unicodeScalars[index]
      
      result = Unicode._WordBreakProperty(from: scalar)
      
      if result != .format && result != .extend && result != .zwj {
        break
      }
    }
    
    return result
  }
  
  // The "algorithm" that determines whether or not we should break between
  // certain word break properties.
  //
  // This is based off of the Unicode Annex #29 for [Word Boundary
  // Rules](https://unicode.org/reports/tr29/#Word_Boundary_Rules).
  internal func shouldBreak(
    _ scalar1: Unicode.Scalar,
    between scalar2: Unicode.Scalar,
    _ state: inout _WordBreakingState,
    _ index: Int,
    isBackwards: Bool = false
  ) -> Bool {
    // WB3
    if scalar1.value == 0xD, scalar2.value == 0xA {
      return false
    }
    
    var index = index
    
    var x: Unicode._WordBreakProperty
    
    if let previousProperty = state.previousProperty {
      x = previousProperty
      index = state.previousIndex!
    } else {
      x = Unicode._WordBreakProperty(from: scalar1)
    }
    
    let y = Unicode._WordBreakProperty(from: scalar2)
    
    // Handle cases wher e
    if y == .extendedPictographic, state.previousProperty == .zwj {
      x = .zwj
    }
    
    var previousIndex: Int? = nil
    var previousProperty: Unicode._WordBreakProperty? = nil
    var previousZWJ = false
    
    defer {
      state.previousIndex = previousIndex
      state.previousProperty = previousProperty
      state.previousZWJ = previousZWJ
    }
    
    switch (x, y) {
      
    // Fast path: If we know our scalars have no properties the decision is
    //            trivial and we don't need to crawl to the default statement.
    case (.any, .any):
      return true
      
    // WB3a and WB3b
    case (.newlineCRLF, _),
         (_, .newlineCRLF):
      return true
    
    // WB3c
    case (_, .extendedPictographic):
      if (x == .zwj && state.previousProperty == nil) || state.previousZWJ {
        return false
      }
      
      return true
      
    // WB3d
    case (.wSegSpace, .wSegSpace):
      if state.previousProperty == nil {
        return false
      }
      
      return true
      
    // WB4
    case (_, .format),
         (_, .extend),
         (_, .zwj):
      previousIndex = index
      previousProperty = x
      previousZWJ = y == .zwj
      return false
      
    // WB5
    case (.aLetter, .aLetter),
         (.aLetter, .hebrewLetter),
         (.hebrewLetter, .aLetter),
         (.hebrewLetter, .hebrewLetter):
      return false
    
    // WB6
    case (.aLetter, .midLetter),
         (.hebrewLetter, .midLetter),
         (.aLetter, .midNumLet),
         (.hebrewLetter, .midNumLet),
         (.aLetter, .singleQuote),
         (.hebrewLetter, .singleQuote):
      if peek(index) == .aLetter ||
         peek(index) == .hebrewLetter {
        return false
      } else {
        // WB7a
        if x == .hebrewLetter, y == .singleQuote {
          return false
        }
        
        return true
      }
      
    // WB7
    case (.midLetter, .aLetter),
         (.midLetter, .hebrewLetter),
         (.midNumLet, .aLetter),
         (.midNumLet, .hebrewLetter),
         (.singleQuote, .aLetter),
         (.singleQuote, .hebrewLetter):
      if peekPrevious(index) == .aLetter ||
         peekPrevious(index) == .hebrewLetter {
        return false
      } else {
        return true
      }
    
    // WB7b
    case (.hebrewLetter, .doubleQuote):
      if peek(index) == .hebrewLetter {
        return false
      } else {
        return true
      }
      
    // WB7c
    case (.doubleQuote, .hebrewLetter):
      if peekPrevious(index) == .hebrewLetter {
        return false
      } else {
        return true
      }
      
    // WB8
    case (.numeric, .numeric):
      return false
    
    // WB9
    case (.aLetter, .numeric),
         (.hebrewLetter, .numeric):
      return false
    
    // WB10
    case (.numeric, .aLetter),
         (.numeric, .hebrewLetter):
      return false
      
    // WB11
    case (.midNum, .numeric),
         (.midNumLet, .numeric),
         (.singleQuote, .numeric):
      if peekPrevious(index) == .numeric {
        return false
      } else {
        return true
      }
      
    // WB12
    case (.numeric, .midNum),
         (.numeric, .midNumLet),
         (.numeric, .singleQuote):
      if peek(index) == .numeric {
        return false
      } else {
        return true
      }
      
    // WB13
    case (.katakana, .katakana):
      return false
      
    // WB13a
    case (.aLetter, .extendNumLet),
         (.hebrewLetter, .extendNumLet),
         (.numeric, .extendNumLet),
         (.katakana, .extendNumLet),
         (.extendNumLet, .extendNumLet):
      return false
      
    // WB13b
    case (.extendNumLet, .aLetter),
         (.extendNumLet, .hebrewLetter),
         (.extendNumLet, .numeric),
         (.extendNumLet, .katakana):
      return false
    
    // WB15
    case (.regionalIndicator, .regionalIndicator):
      if isBackwards {
        return countRIs(index)
      }
      
      defer {
        state.shouldBreakRI.toggle()
      }
      
      return state.shouldBreakRI
      
    default:
      return true
    }
  }
  
  internal func countRIs(
    _ index: Int
  ) -> Bool {
    var riIdx = String.Index(_encodedOffset: index)
    
    guard riIdx != startIndex else {
      return false
    }
    
    var riCount = 0
    
    let scalars = base.unicodeScalars
    scalars.formIndex(before: &riIdx)
    
    while riIdx != startIndex {
      scalars.formIndex(before: &riIdx)
      let scalar = scalars[riIdx]
      
      let wbp = Unicode._WordBreakProperty(from: scalar)
      
      guard wbp == .regionalIndicator else {
        break
      }
      
      riCount += 1
    }
    
    return riCount & 1 != 0
  }
}
