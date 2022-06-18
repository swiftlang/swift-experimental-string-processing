//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

#include "Common/ScriptData.h"
#include "include/UnicodeData.h"

SWIFT_CC
uint8_t _swift_string_processing_getScript(uint32_t scalar) {
  int lowerBoundIndex = 0;
  int endIndex = SCRIPTS_COUNT;
  int upperBoundIndex = endIndex - 1;
  
  while (upperBoundIndex >= lowerBoundIndex) {
    int index = lowerBoundIndex + (upperBoundIndex - lowerBoundIndex) / 2;
    
    const uint32_t entry = _swift_stdlib_scripts[index];
    
    // Shift the enum value out of the scalar.
    uint32_t lowerBoundScalar = (entry << 11) >> 11;
    
    uint32_t upperBoundScalar = 0;
    
    // If we're not at the end of the array, the range count is simply the
    // distance to the next element.
    if (index != endIndex - 1) {
      const uint32_t nextEntry = _swift_stdlib_scripts[index + 1];
      
      uint32_t nextLower = (nextEntry << 11) >> 11;
      
      upperBoundScalar = nextLower - 1;
    } else {
      // Otherwise, the range count is the distance to 0x10FFFF
      upperBoundScalar = 0x10FFFF;
    }
    
    // Shift the scalar out and get the enum value.
    uint8_t script = entry >> 21;
    
    if (scalar >= lowerBoundScalar && scalar <= upperBoundScalar) {
      return script;
    }
    
    if (scalar > upperBoundScalar) {
      lowerBoundIndex = index + 1;
      continue;
    }
    
    if (scalar < lowerBoundScalar) {
      upperBoundIndex = index - 1;
      continue;
    }
  }
  
  // If we make it out of this loop, then it means the scalar was not found at
  // all in the array. This should never happen because the array represents all
  // scalars from 0x0 to 0x10FFFF, but if somehow this branch gets reached,
  // return 255 to indicate a failure.
  return UINT8_MAX;
}

SWIFT_CC
const uint8_t *_swift_string_processing_getScriptExtensions(uint32_t scalar,
                                                            uint8_t *count) {
  intptr_t dataIdx = _swift_string_processing_getScalarBitArrayIdx(scalar,
                                                _swift_stdlib_script_extensions,
                                         _swift_stdlib_script_extensions_ranks);
  
  // If we don't have an index into the data indices, then this scalar has no
  // script extensions
  if (dataIdx == INTPTR_MAX) {
    return 0;
  }
  
  uint16_t scalarDataIdx = _swift_stdlib_script_extensions_data_indices[dataIdx];
  *count = scalarDataIdx >> 11;
  
  return _swift_stdlib_script_extensions_data + (scalarDataIdx & 0x7FF);
}
