//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

#if defined(__APPLE__)
#include "Apple/NormalizationData.h"
#else
#include "Common/NormalizationData.h"
#endif

#include "include/UnicodeData.h"

SWIFT_CC
uint16_t _swift_stdlib_getNormData(uint32_t scalar) {
  // Fast Path: ASCII and some latiny scalars are very basic and have no
  // normalization properties.
  if (scalar < 0xC0) {
    return 0;
  }
  
  intptr_t dataIdx = _swift_stdlib_getScalarBitArrayIdx(scalar,
                                                    _swift_stdlib_normData,
                                                  _swift_stdlib_normData_ranks);

  // If we don't have an index into the data indices, then this scalar has no
  // normalization information.
  if (dataIdx == INTPTR_MAX) {
    return 0;
  }

  const uint8_t scalarDataIdx = _swift_stdlib_normData_data_indices[dataIdx];
  return _swift_stdlib_normData_data[scalarDataIdx];
}

SWIFT_CC
const uint8_t *_swift_stdlib_nfd_decompositions(void) {
  return _swift_stdlib_nfd_decomp;
}

SWIFT_CC
uint32_t _swift_stdlib_getDecompositionEntry(uint32_t scalar) {
  intptr_t levelCount = NFD_DECOMP_LEVEL_COUNT;
  intptr_t decompIdx = _swift_stdlib_getMphIdx(scalar, levelCount,
                                                  _swift_stdlib_nfd_decomp_keys,
                                                  _swift_stdlib_nfd_decomp_ranks,
                                                  _swift_stdlib_nfd_decomp_sizes);

  return _swift_stdlib_nfd_decomp_indices[decompIdx];
}

SWIFT_CC
uint32_t _swift_stdlib_getComposition(uint32_t x, uint32_t y) {
  intptr_t levelCount = NFC_COMP_LEVEL_COUNT;
  intptr_t compIdx = _swift_stdlib_getMphIdx(y, levelCount,
                                                  _swift_stdlib_nfc_comp_keys,
                                                  _swift_stdlib_nfc_comp_ranks,
                                                  _swift_stdlib_nfc_comp_sizes);
  const uint32_t *array = _swift_stdlib_nfc_comp_indices[compIdx];

  // Ensure that the first element in this array is equal to our y scalar.
  const uint32_t realY = (array[0] << 11) >> 11;

  if (y != realY) {
    return UINT32_MAX;
  }

  const uint32_t count = array[0] >> 21;

  uint32_t low = 1;
  uint32_t high = count - 1;

  while (high >= low) {
    uint32_t idx = low + (high - low) / 2;
  
    const uint32_t entry = array[idx];
  
    // Shift the range count out of the scalar.
    const uint32_t lower = (entry << 15) >> 15;
  
    _Bool isNegative = entry >> 31;
    uint32_t rangeCount = (entry << 1) >> 18;
  
    if (isNegative) {
      rangeCount = -rangeCount;
    }
  
    const uint32_t composed = lower + rangeCount;
  
    if (x == lower) {
      return composed;
    }
  
    if (x > lower) {
      low = idx + 1;
      continue;
    }
  
    if (x < lower) {
      high = idx - 1;
      continue;
    }
  }

  // If we made it out here, then our scalar was not found in the composition
  // array.
  // Return the max here to indicate that we couldn't find one.
  return UINT32_MAX;
}
