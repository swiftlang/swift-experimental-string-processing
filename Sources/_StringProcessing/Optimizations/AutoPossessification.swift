//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2025 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

internal import _RegexParser

extension DSLList {
  /// Returns the required first atom of the node at `position`, leaving
  /// `position` just past that node's entire subtree, so that a caller walking
  /// a list of nodes reads the next sibling.
  ///
  /// A `nil` result means this node has no effect on what has to match first,
  /// and `.some(nil)` means that no required first atom can be determined.
  ///
  /// Some of the cases below stop looking at children as soon as the answer is
  /// known, and others don't look at them at all, so the end of the subtree is
  /// found up front rather than left to the traversal to reach.
  private func _requiredAtomImpl(
    _ position: inout Int,
    options: inout MatchingOptions,
    allowOptionsChanges: Bool
  ) -> DSLTree.Atom?? {
    guard position < nodes.count else {
      return nil
    }

    var endOfSubtree = position
    skipNode(&endOfSubtree)
    endOfSubtree += 1
    defer { position = endOfSubtree }

    switch nodes[position] {
    case .atom(let atom):
      switch atom {
      case .changeMatchingOptions(let seq):
        // Exit early if an atom changes the matching options.
        if allowOptionsChanges {
          options.apply(seq.ast)
          return nil
        } else {
          return .some(nil)
        }
      default:
        return atom
      }

    // In a concatenation, the first definitive child provides the answer.
    case .concatenation(let count):
      position += 1
      for _ in 0..<count {
        if let r = _requiredAtomImpl(&position, options: &options, allowOptionsChanges: allowOptionsChanges) {
          return r
        }
      }
      return nil

    // For a quoted literal, we can look at the first char
    // TODO: matching semantics???
    case .quotedLiteral(let str, _):
      return str.first.map(DSLTree.Atom.char)
    
    // TODO: custom character classes could/should participate here somehow
    case .customCharacterClass:
      return .some(nil)
      
    // Trivia/empty have no effect.
    case .trivia, .empty:
      return nil
      
    // For alternation and conditional, no required first (this could change
    // if we identify the _same_ required first atom across all possibilities).
    case .orderedChoice, .conditional:
      return .some(nil)

    // A negative lookahead rules out the existence of a safe required
    // character.
    case .nonCapturingGroup(let kind) where kind.isNegativeLookahead:
      return .some(nil)

    // Bail out early if this group changes options.
    // TODO: Allow some/all options changes.
    case .nonCapturingGroup(let kind):
      position += 1
      options.beginScope()
      defer { options.endScope() }
      switch kind.ast {
      case .changeMatchingOptions(let seq) where allowOptionsChanges:
        options.apply(seq)
      case .changeMatchingOptions:
        return .some(nil)
      default:
        break
      }
      return _requiredAtomImpl(&position, options: &options, allowOptionsChanges: allowOptionsChanges)

    // Groups need to manage option scope.
    case .capture:
      position += 1
      options.beginScope()
      defer { options.endScope() }
      return _requiredAtomImpl(&position, options: &options, allowOptionsChanges: allowOptionsChanges)

    // Other parent nodes defer to the child.
    case .ignoreCapturesInTypedOutput,
        .limitCaptureNesting:
      position += 1
      return _requiredAtomImpl(&position, options: &options, allowOptionsChanges: allowOptionsChanges)

    // A quantification that doesn't require its child to exist can still
    // allow a start-only match. (e.g. `/(foo)?^bar/`)
    case .quantification(let amount, _):
      if amount.requiresAtLeastOne {
        position += 1
        return _requiredAtomImpl(&position, options: &options, allowOptionsChanges: allowOptionsChanges)
      } else {
        return .some(nil)
      }

    // Extended behavior isn't known, so we return `false` for safety.
    case .consumer, .matcher, .characterPredicate, .absentFunction:
      return .some(nil)
    }
  }

  internal func requiredFirstAtom(allowOptionsChanges: Bool) -> DSLTree.Atom? {
    var position = 0
    var options = MatchingOptions()
    return _requiredAtomImpl(&position, options: &options, allowOptionsChanges: allowOptionsChanges) ?? nil
  }

  /// Auto-possessifies the quantifications inside the node at `position`,
  /// leaving `position` just past that node's entire subtree, so that a caller
  /// walking a list of nodes reads the next sibling.
  ///
  /// Returns a single-atom quantification that ends the node at `position`, if
  /// there is one, so that an enclosing concatenation can try to possessify it
  /// against whatever follows.
  ///
  /// Some of the cases below stop looking at children as soon as the answer is
  /// known, and others don't look at them at all, so the end of the subtree is
  /// found up front rather than left to the traversal to reach.
  internal mutating func autoPossessifyNextQuantification(
    _ position: inout Int,
    options: inout MatchingOptions
  ) -> (Int, DSLTree.Atom)? {
    guard position < nodes.count else {
      return nil
    }

    var endOfSubtree = position
    skipNode(&endOfSubtree)
    endOfSubtree += 1
    defer { position = endOfSubtree }

    switch nodes[position] {
    case .quantification(_, _):
      let quantPosition = position
      position += 1
      
      // Limit auto-possessification to a single quantified atom, to avoid
      // issues of overlapped matches.
      guard position < nodes.count else {
        return nil
      }
      switch nodes[position] {
      case .atom(let atom) where atom.isMatchable:
        return (quantPosition, atom)
      default:
        _ = autoPossessifyNextQuantification(&position, options: &options)
        return nil
      }
      
    case .concatenation(let count):
      // A quantification found among this concatenation's components can be
      // possessified against the first component after it that has a required
      // first atom. If no component provides a definitive answer, pop up the
      // recursion stack to find a sibling at a higher level.
      var pendingQuantification: (Int, DSLTree.Atom)? = nil
      position += 1
      for _ in 0..<count {
        if let (quantIndex, quantAtom) = pendingQuantification {
          // Look for a required atom in this component without consuming it,
          // so that its own quantifications still get possessified below.
          var lookahead = position
          switch _requiredAtomImpl(&lookahead, options: &options, allowOptionsChanges: false) {
          case .some(.some(let nextAtom)):
            // We found a quantifier with a required first atom and a required
            // following atom. If the second is excluded by the first, we can
            // safely convert the quantifier to possessive.
            if quantAtom.excludes(nextAtom, options: options),
                case .quantification(let amount, _) = nodes[quantIndex]
            {
              nodes[quantIndex] = .quantification(amount, .explicit(.possessive))
            }
            pendingQuantification = nil
          case .some(nil):
            // Nothing is known about what has to match here, so the pending
            // quantification can't be possessified at any level.
            pendingQuantification = nil
          case nil:
            // This component doesn't match anything on its own; keep looking.
            break
          }
        }

        if let result = autoPossessifyNextQuantification(&position, options: &options) {
          pendingQuantification = result
        }
      }

      return pendingQuantification
      
    // For alternations, we need to explore / auto-possessify in the different
    // branches, but quantifications inside an alternation don't
    // auto-possessify with following matching elements outside of the
    // alternation (for now, at least).
    case .orderedChoice(let count):
      position += 1
      for _ in 0..<count {
        _ = autoPossessifyNextQuantification(&position, options: &options)
      }
    
    // Same as alternations, just with n = 2
    case .conditional:
      position += 1
      for _ in 0..<2 {
        _ = autoPossessifyNextQuantification(&position, options: &options)
      }

    case .nonCapturingGroup(let kind):
      position += 1
      options.beginScope()
      defer { options.endScope() }

      if case .changeMatchingOptions(let seq) = kind.ast {
        options.apply(seq)
      }
      return autoPossessifyNextQuantification(&position, options: &options)

    case .capture:
      position += 1
      options.beginScope()
      defer { options.endScope() }

      return autoPossessifyNextQuantification(&position, options: &options)

    case .atom(let atom):
      switch atom {
      case .changeMatchingOptions(let seq):
        options.apply(seq.ast)
      default: break
      }
      
    // All other nodes defer to the child, if present
    default:
      // Multi-child nodes are handled above, just handle 0 and 1 here.
      let childCount = nodes[position].directChildren

      assert(childCount <= 1)
      if childCount == 1 {
        position += 1
        return autoPossessifyNextQuantification(&position, options: &options)
      }
    }
    return nil
  }
  
  internal mutating func autoPossessify() {
    var index = 0
    var options = MatchingOptions()
    while index < self.nodes.count {
      _ = autoPossessifyNextQuantification(&index, options: &options)
    }
  }
}

extension DSLTree.Atom {
  func excludes(_ other: Self, options: MatchingOptions) -> Bool {
    switch (self, other) {
    case (.char(let a), .char(let b)):
      // Two characters are mutually exclusive if one does not match against
      // the other.
      //
      // Relevant options:
      // - semantic level
      // - case insensitivity
      
      if options.semanticLevel == .graphemeCluster {
        // Just call String.match(Character, ...)
        let s = String(a)
        return nil == s.match(
          b, at: s.startIndex,
          limitedBy: s.endIndex,
          isCaseInsensitive: options.isCaseInsensitive)
      } else {
        // Call String.matchScalar(Scalar, ...) for each in scalar sequence
        let s = String(a)
        var i = s.startIndex
        var j = b.unicodeScalars.startIndex
        while i < s.endIndex {
          guard j < b.unicodeScalars.endIndex else { return true }
          guard let nextIndex = s.matchScalar(b.unicodeScalars[j], at: i, limitedBy: s.endIndex, boundaryCheck: false, isCaseInsensitive: options.isCaseInsensitive) else {
            return true
          }
          i = nextIndex
          b.unicodeScalars.formIndex(after: &j)
        }
        return false
      }
      
    case (.scalar(let a), .scalar(let b)):
      // Two scalars are mutually exclusive if one does not match against
      // the other.
      //
      // Relevant options:
      // - case insensitivity
      let s = String(a)
      return nil == s.matchScalar(
        b, at: s.startIndex,
        limitedBy: s.endIndex,
        boundaryCheck: false,
        isCaseInsensitive: options.isCaseInsensitive)
      
    case (.characterClass(let a), .characterClass(let b)):
      // Certain character classes are mutually exclusive of each other.
      return a.excludes(b, options: options)

    // For character class and char/scalar, we can test against the class's model.
    case (.characterClass(let a), .char(let b)), (.char(let b), .characterClass(let a)):
      let s = "\(b)"
      return nil == a.asRuntimeModel(options).matches(in: s, at: s.startIndex, limitedBy: s.endIndex)
    case (.characterClass(let a), .scalar(let b)), (.scalar(let b), .characterClass(let a)):
      let s = "\(b)"
      return nil == a.asRuntimeModel(options).matches(in: s, at: s.startIndex, limitedBy: s.endIndex)

    default:
      return false
    }
  }
}

extension DSLTree.Atom.CharacterClass {
  func excludes(_ other: Self, options: MatchingOptions) -> Bool {
    if other == .anyGrapheme || other == .anyUnicodeScalar {
      return false
    }
    
    return switch self {
    case .anyGrapheme, .anyUnicodeScalar:
      false
      
    case .digit:
      switch other {
      case .whitespace, .horizontalWhitespace, .verticalWhitespace, .newlineSequence,
          .notWord, .notDigit: true
      default: false
      }
    case .notDigit:
      other == .digit
      
    case .horizontalWhitespace:
      switch other {
      case .word, .digit, .verticalWhitespace, .newlineSequence,
          .notWhitespace, .notHorizontalWhitespace: true
      default: false
      }
    case .notHorizontalWhitespace:
      other == .horizontalWhitespace
      
    case .newlineSequence:
      switch other {
      case .word, .digit, .horizontalWhitespace, .notNewline: true
      default: false
      }
    case .notNewline:
      other == .newlineSequence
      
    case .whitespace:
      switch other {
      case .word, .digit, .notWhitespace: true
      default: false
      }
    case .notWhitespace:
      other == .whitespace
      
    case .verticalWhitespace:
      switch other {
      case .word, .digit, .notWhitespace, .notVerticalWhitespace: true
      default: false
      }
    case .notVerticalWhitespace:
      other == .verticalWhitespace
      
    case .word:
      switch other {
      case .whitespace, .horizontalWhitespace, .verticalWhitespace, .newlineSequence,
          .notWord: true
      default: false
      }
    case .notWord:
      other == .word
    }
  }
}
