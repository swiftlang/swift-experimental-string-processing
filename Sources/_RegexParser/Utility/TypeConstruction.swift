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

// Swift runtime metadata functions.
//   SWIFT_RUNTIME_EXPORT SWIFT_CC(swift)
//   MetadataResponse
//   swift_getTupleTypeMetadata(MetadataRequest request,
//                              TupleTypeFlags flags,
//                              const Metadata * const *elements,
//                              const char *labels,
//                              const ValueWitnessTable *proposedWitnesses);


@_silgen_name("swift_getTupleTypeMetadata")
private func swift_getTupleTypeMetadata(
  request: Int,
  flags: Int,
  elements: UnsafePointer<Any.Type>?,
  labels: UnsafePointer<Int8>?,
  proposedWitnesses: UnsafeRawPointer?
) -> (value: Any.Type, state: Int)

public enum TypeConstruction {
  /// Returns a tuple metatype of the given element types.
  public static func tupleType<
    ElementTypes: BidirectionalCollection
  >(
    of elementTypes: __owned ElementTypes,
    labels: String? = nil
  ) -> Any.Type where ElementTypes.Element == Any.Type {
    // From swift/ABI/Metadata.h:
    //   template <typename int_type>
    //   class TargetTupleTypeFlags {
    //     enum : int_type {
    //       NumElementsMask = 0x0000FFFFU,
    //       NonConstantLabelsMask = 0x00010000U,
    //     };
    //     int_type Data;
    //     ...
    let elementCountFlag = 0x0000FFFF
    assert(elementTypes.count != 1, "A one-element tuple is not a realistic Swift type")
    assert(elementTypes.count <= elementCountFlag, "Tuple size exceeded \(elementCountFlag)")
    
    var flags = elementTypes.count
    
    // If we have labels to provide, then say the label pointer is not constant
    // because the lifetime of said pointer will only be vaild for the lifetime
    // of the 'swift_getTupleTypeMetadata' call. If we don't have labels, then
    // our label pointer will be empty and constant.
    if labels != nil {
      // Has non constant labels
      flags |= 0x10000
    }
    
    let result = elementTypes.withContiguousStorageIfAvailable { elementTypesBuffer in
      if let labels = labels {
        return labels.withCString { labelsPtr in
          swift_getTupleTypeMetadata(
            request: 0,
            flags: flags,
            elements: elementTypesBuffer.baseAddress,
            labels: labelsPtr,
            proposedWitnesses: nil
          )
        }
      } else {
        return swift_getTupleTypeMetadata(
          request: 0,
          flags: flags,
          elements: elementTypesBuffer.baseAddress,
          labels: nil,
          proposedWitnesses: nil
        )
      }
    }
    
    guard let result = result else {
      fatalError(
        """
        The collection of element types does not support an internal representation of
        contiguous storage
        """
      )
    }
    
    return result.value
  }

  /// Creates a type-erased tuple with the given elements.
  public static func tuple<Elements: BidirectionalCollection>(
    of elements: __owned Elements
  ) -> Any where Elements.Element == Any {
    // Open existential on the overall tuple type.
    func create<T>(_: T.Type) -> Any {
      let baseAddress = UnsafeMutablePointer<T>.allocate(
        capacity: MemoryLayout<T>.size)
      defer { baseAddress.deallocate() }
      // Initialize elements based on their concrete type.
      var currentElementAddressUnaligned = UnsafeMutableRawPointer(baseAddress)
      for element in elements {
        // Open existential on each element type.
        func initializeElement<T>(_ element: T) {
          currentElementAddressUnaligned =
            currentElementAddressUnaligned.roundedUp(toAlignmentOf: T.self)
          currentElementAddressUnaligned.bindMemory(
            to: T.self, capacity: MemoryLayout<T>.size
          ).initialize(to: element)
          // Advance to the next element (unaligned).
          currentElementAddressUnaligned =
            currentElementAddressUnaligned.advanced(by: MemoryLayout<T>.size)
        }
        _openExistential(element, do: initializeElement)
      }
      return baseAddress.move()
    }
    let elementTypes = elements.map { type(of: $0) }
    return _openExistential(tupleType(of: elementTypes), do: create)
  }

  public static func arrayType(of childType: Any.Type) -> Any.Type {
    func helper<T>(_: T.Type) -> Any.Type {
      [T].self
    }
    return _openExistential(childType, do: helper)
  }

  public static func optionalType(of childType: Any.Type) -> Any.Type {
    func helper<T>(_: T.Type) -> Any.Type {
      T?.self
    }
    return _openExistential(childType, do: helper)
  }
}
