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

#ifndef SWIFT_STDLIB_SHIMS_UNICODEDATA_H
#define SWIFT_STDLIB_SHIMS_UNICODEDATA_H

#include "stdbool.h"
#include "stdint.h"
#include "limits.h"

#define SWIFT_CC __attribute__((swiftcall))

//===----------------------------------------------------------------------===//
// Utilities
//===----------------------------------------------------------------------===//

intptr_t _swift_stdlib_getMphIdx(uint32_t scalar, intptr_t levels,
                                 const uint64_t * const *keys,
                                 const uint16_t * const *ranks,
                                 const uint16_t * const sizes);

intptr_t _swift_stdlib_getScalarBitArrayIdx(uint32_t scalar,
                                            const uint64_t *bitArrays,
                                            const uint16_t *ranks);

//===----------------------------------------------------------------------===//
// Normalization
//===----------------------------------------------------------------------===//

SWIFT_CC
uint16_t _swift_stdlib_getNormData(uint32_t scalar);

SWIFT_CC
const uint8_t *_swift_stdlib_nfd_decompositions(void);

SWIFT_CC
uint32_t _swift_stdlib_getDecompositionEntry(uint32_t scalar);

SWIFT_CC
uint32_t _swift_stdlib_getComposition(uint32_t x, uint32_t y);

//===----------------------------------------------------------------------===//
// Grapheme Breaking
//===----------------------------------------------------------------------===//

SWIFT_CC
uint8_t _swift_stdlib_getGraphemeBreakProperty(uint32_t scalar);

SWIFT_CC
_Bool _swift_stdlib_isLinkingConsonant(uint32_t scalar);

//===----------------------------------------------------------------------===//
// Scalar Props
//===----------------------------------------------------------------------===//

SWIFT_CC
uint8_t _swift_stdlib_getScript(uint32_t scalar);

SWIFT_CC
const uint8_t *_swift_stdlib_getScriptExtensions(uint32_t scalar,
                                                 uint8_t *count);

#endif // SWIFT_STDLIB_SHIMS_UNICODEDATA_H
