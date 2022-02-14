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

#include "Common/GraphemeData.h"
#include "include/UnicodeData.h"

SWIFT_CC
uint8_t _swift_stdlib_getGraphemeBreakProperty(uint32_t scalar) {
  int low = 0;
  int high = GRAPHEME_BREAK_DATA_COUNT - 1;

  while (high >= low) {
    int idx = low + (high - low) / 2;

    const uint32_t entry = _swift_stdlib_graphemeBreakProperties[idx];

    // Shift the enum and range count out of the value.
    uint32_t lower = (entry << 11) >> 11;

    // Shift the enum out first, then shift out the scalar value.
    uint32_t upper = lower + ((entry << 3) >> 24);

    // Shift everything out.
    uint8_t enumValue = (uint8_t)(entry >> 29);

    // Special case: extendedPictographic who used an extra bit for the range.
    if (enumValue == 5) {
      upper = lower + ((entry << 2) >> 23);
    }

    if (scalar >= lower && scalar <= upper) {
      return enumValue;
    }

    if (scalar > upper) {
      low = idx + 1;
      continue;
    }

    if (scalar < lower) {
      high = idx - 1;
      continue;
    }
  }

  // If we made it out here, then our scalar was not found in the grapheme
  // array (this occurs when a scalar doesn't map to any grapheme break
  // property). Return the max value here to indicate .any.
  return 0xFF;
}

SWIFT_CC
_Bool _swift_stdlib_isLinkingConsonant(uint32_t scalar) {
  intptr_t idx = _swift_stdlib_getScalarBitArrayIdx(scalar,
                                          _swift_stdlib_linkingConsonant,
                                          _swift_stdlib_linkingConsonant_ranks);

  if (idx == INTPTR_MAX) {
    return false;
  }

  return true;
}
