// TODO: Check if this works with empty patterns
public struct ZSearcher<Searched: Collection> {
  let pattern: [Searched.Element]
  let z: [Int]
  let areEquivalent: (Searched.Element, Searched.Element) -> Bool
  
  public init(pattern: [Searched.Element], by areEquivalent: @escaping (Searched.Element, Searched.Element) -> Bool) {
    self.pattern = pattern
    self.z = zAlgorithm(pattern, by: areEquivalent)
    self.areEquivalent = areEquivalent
  }
}

extension ZSearcher: StatelessCollectionSearcher {
  public func search(_ searched: Searched, from index: Searched.Index) -> Range<Searched.Index>? {
    var l = index
    var r = l
    var distanceFromL = 0
    var distanceToR = 0
    
    func compare(start: Searched.Index, end: Searched.Index, minLength: Int) -> Range<Searched.Index>? {
      var left = minLength
      var right = end
      
      while left != pattern.endIndex && right != searched.endIndex && areEquivalent(pattern[left], searched[right]) {
        left += 1
        searched.formIndex(after: &right)
      }
      
      if left == pattern.count {
        return start..<right
      } else {
        l = start
        r = right
        distanceFromL = 0
        distanceToR = left
        return nil
      }
    }
    
    var i = index
    
    while true {
      if i >= r {
        if let range = compare(start: i, end: i, minLength: 0) {
          return range
        }
      } else {
        let length = distanceToR
        let prev = z[distanceFromL]
        
        if prev >= length {
          if let range = compare(start: i, end: r, minLength: length) {
            return range
          }
        }
      }
      
      if i == searched.endIndex {
        return nil
      }
      
      searched.formIndex(after: &i)
      distanceFromL += 1
      distanceToR -= 1
    }
  }
}

func zAlgorithm<T>(_ elements: [T], by areEquivalent: (T, T) -> Bool) -> [Int] {
  var z: [Int] = [elements.count]
  z.reserveCapacity(elements.count)
  
  var l = 0
  var r = 0
  
  func compare(start: Int, minLength: Int) {
    var left = minLength
    var right = start + minLength
    
    while right < elements.count && areEquivalent(elements[left], elements[right]) {
      left += 1
      right += 1
    }
    
    z.append(left)
    l = start
    r = right
  }
  
  for index in elements.indices.dropFirst() {
    if index >= r {
      compare(start: index, minLength: 0)
    } else {
      let length = r - index
      let prev = z[index - l]
      
      if prev < length {
        z.append(prev)
      } else {
        compare(start: index, minLength: length)
      }
    }
  }
  
  return z
}
