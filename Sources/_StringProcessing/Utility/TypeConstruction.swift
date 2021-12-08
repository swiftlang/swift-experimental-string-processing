// Swift runtime metadata functions.
//   SWIFT_RUNTIME_EXPORT SWIFT_CC(swift)
//   MetadataResponse
//   swift_getTupleTypeMetadata(MetadataRequest request,
//                              TupleTypeFlags flags,
//                              const Metadata * const *elements,
//                              const char *labels,
//                              const ValueWitnessTable *proposedWitnesses);
//
//   SWIFT_RUNTIME_EXPORT SWIFT_CC(swift)
//   MetadataResponse
//   swift_getTupleTypeMetadata2(MetadataRequest request,
//                               const Metadata *elt0, const Metadata *elt1,
//                               const char *labels,
//                               const ValueWitnessTable *proposedWitnesses);
//   SWIFT_RUNTIME_EXPORT SWIFT_CC(swift)
//   MetadataResponse
//   swift_getTupleTypeMetadata3(MetadataRequest request,
//                               const Metadata *elt0, const Metadata *elt1,
//                               const Metadata *elt2, const char *labels,
//                               const ValueWitnessTable *proposedWitnesses);

@_silgen_name("swift_getTupleTypeMetadata")
private func swift_getTupleTypeMetadata(
  request: Int,
  flags: Int,
  elements: UnsafePointer<Any.Type>?,
  labels: UnsafePointer<Int8>?,
  proposedWitnesses: UnsafeRawPointer?
) -> (value: Any.Type, state: Int)

@_silgen_name("swift_getTupleTypeMetadata2")
private func swift_getTupleTypeMetadata2(
  request: Int,
  element1: Any.Type,
  element2: Any.Type,
  labels: UnsafePointer<Int8>?,
  proposedWitnesses: UnsafeRawPointer?
) -> (value: Any.Type, state: Int)

@_silgen_name("swift_getTupleTypeMetadata3")
private func swift_getTupleTypeMetadata3(
  request: Int,
  element1: Any.Type,
  element2: Any.Type,
  element3: Any.Type,
  labels: UnsafePointer<Int8>?,
  proposedWitnesses: UnsafeRawPointer?
) -> (value: Any.Type, state: Int)

enum TypeConstruction {

  /// Returns a tuple metatype of the given element types.
  static func tupleType<
    ElementTypes: BidirectionalCollection
  >(
    of elementTypes: __owned ElementTypes
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
    switch elementTypes.count {
    case 2:
      return swift_getTupleTypeMetadata2(
        request: 0,
        element1: elementTypes[elementTypes.startIndex],
        element2: elementTypes[elementTypes.index(elementTypes.startIndex, offsetBy: 1)],
        labels: nil,
        proposedWitnesses: nil).value
    case 3:
      return swift_getTupleTypeMetadata3(
        request: 0,
        element1: elementTypes[elementTypes.startIndex],
        element2: elementTypes[elementTypes.index(elementTypes.startIndex, offsetBy: 1)],
        element3: elementTypes[elementTypes.index(elementTypes.startIndex, offsetBy: 2)],
        labels: nil,
        proposedWitnesses: nil).value
    default:
      let result = elementTypes.withContiguousStorageIfAvailable { elementTypesBuffer in
        swift_getTupleTypeMetadata(
          request: 0,
          flags: elementTypesBuffer.count,
          elements: elementTypesBuffer.baseAddress,
          labels: nil,
          proposedWitnesses: nil).value
      }
      guard let result = result else {
        fatalError("""
          The collection of element types does not support an internal representation of
          contiguous storage
          """)
      }
      return result
    }
  }

  /// Creates a type-erased tuple with the given elements.
  static func tuple<Elements: BidirectionalCollection>(
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
          currentElementAddressUnaligned.advanced(by: MemoryLayout<T>.stride)
        }
        _openExistential(element, do: initializeElement)
      }
      return baseAddress.move()
    }
    let elementTypes = elements.map { type(of: $0) }
    return _openExistential(tupleType(of: elementTypes), do: create)
  }
}
