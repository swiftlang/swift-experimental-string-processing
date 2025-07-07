//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

#include "include/UnicodeData.h"

// Every 4 byte chunks of data that we need to hash (in this case only ever
// scalars and levels who are all uint32), we need to calculate K. At the end
// of this scramble sequence to get K, directly apply this to the current hash.
static inline uint32_t scramble(uint32_t scalar) {
  scalar *= 0xCC9E2D51;
  scalar = (scalar << 15) | (scalar >> 17);
  scalar *= 0x1B873593;
  return scalar;
}

// This is a reimplementation of MurMur3 hash with a modulo at the end.
static uint32_t hash(uint32_t scalar, uint32_t level, uint32_t seed) {
  uint32_t hash = seed;

  hash ^= scramble(scalar);
  hash = (hash << 13) | (hash >> 19);
  hash = hash * 5 + 0xE6546B64;
  
  hash ^= scramble(level);
  hash = (hash << 13) | (hash >> 19);
  hash = hash * 5 + 0xE6546B64;

  hash ^= 8;
  hash ^= hash >> 16;
  hash *= 0x85EBCA6B;
  hash ^= hash >> 13;
  hash *= 0xC2B2AE35;
  hash ^= hash >> 16;

  return hash % level;
}

// This implementation is based on the minimal perfect hashing strategy found
// here: https://arxiv.org/pdf/1702.03154.pdf
intptr_t _swift_string_processing_getMphIdx(uint32_t scalar, intptr_t levels,
                                            const uint64_t * const *keys,
                                            const uint16_t * const *ranks,
                                            const uint16_t * const sizes) {
  intptr_t resultIdx = 0;

  // Here, levels represent the numbers of bit arrays used for this hash table.
  for (int i = 0; i != levels; i += 1) {
    const uint64_t *bitArray = keys[i];

    // Get the specific bit that this scalar hashes to in the bit array.
    uint64_t idx = (uint64_t) hash(scalar, sizes[i], i);

    uint64_t word = bitArray[idx / 64];
    uint64_t mask = (uint64_t) 1 << (idx % 64);

    // If our scalar's bit is turned on in the bit array, it means we no longer
    // need to iterate the bit arrays to find where our scalar is located...
    // its in this one.
    if (word & mask) {
      // Our initial rank corresponds to our current level and there are ranks
      // within each bit array every 512 bits. Say our level (bit array)
      // contains 16 uint64 integers to represent all of the required bits.
      // There would be a total of 1024 bits, so our rankings for this level
      // would contain two values for precomputed counted bits for both halfs
      // of this bit array (1024 / 512 = 2).
      uint16_t rank = ranks[i][idx / 512];

      // Because ranks are provided every 512 bits (8 uint64s), we still need to
      // count the bits of the uints64s before us in our 8 uint64 sequence. So
      // for example, if we are bit 576, we are larger than 512, so there is a
      // provided rank for the first 8 uint64s, however we're in the second
      // 8 uint64 sequence and within said sequence we are the #2 uint64. This
      // loop will count the bits set for the first uint64 and terminate.
      for (int j = (idx / 64) & ~7; j != idx / 64; j += 1) {
        rank += __builtin_popcountll(bitArray[j]);
      }

      // After counting the other bits set in the uint64s before, its time to
      // count our word itself and the bits before us.
      if (idx % 64 > 0) {
        rank += __builtin_popcountll(word << (64 - (idx % 64)));
      }

      // Our result is the built up rank value from all of the provided ranks
      // and the ones we've manually counted ourselves.
      resultIdx = rank;
      break;
    }
  }

  return resultIdx;
}

intptr_t _swift_string_processing_getScalarBitArrayIdx(uint32_t scalar,
                                                       const uint64_t *bitArrays,
                                                       const uint16_t *ranks) {
  uint64_t chunkSize = 0x110000 / 64 / 64;
  uint64_t base = scalar / chunkSize;
  uint64_t idx = base / 64;
  uint64_t chunkBit = base % 64;
  
  const uint64_t quickLookSize = bitArrays[0];
  
  // If our chunk index is larger than the quick look indices, then it means
  // our scalar appears in chunks who are all 0 and trailing.
  if ((uint64_t) idx > quickLookSize) {
    return INTPTR_MAX;
  }
  
  const uint64_t quickLook = bitArrays[idx + 1];
  
  if ((quickLook & ((uint64_t) 1 << chunkBit)) == 0) {
    return INTPTR_MAX;
  }
  
  // Ok, our scalar failed the quick look check. Go lookup our scalar in the
  // chunk specific bit array.
  uint16_t chunkRank = ranks[idx];
  
  if (chunkBit != 0) {
    chunkRank += __builtin_popcountll(quickLook << (64 - chunkBit));
  }
  
  const uint64_t *chunkBA = bitArrays + 1 + quickLookSize + (chunkRank * 5);
  
  uint32_t scalarOverallBit = scalar - (base * chunkSize);
  uint32_t scalarSpecificBit = scalarOverallBit % 64;
  uint32_t scalarWord = scalarOverallBit / 64;
  
  const uint64_t chunkWord = chunkBA[scalarWord];
  
  // If our scalar specifically is not turned on, then we're done.
  if ((chunkWord & ((uint64_t) 1 << scalarSpecificBit)) == 0) {
    return INTPTR_MAX;
  }
  
  uint16_t scalarRank = ranks[quickLookSize + (chunkRank * 5) + scalarWord];
  
  if (scalarSpecificBit != 0) {
    scalarRank += __builtin_popcountll(chunkWord << (64 - scalarSpecificBit));
  }
  
  const uint64_t chunkDataIdx = chunkBA[4] >> 16;

  return chunkDataIdx + scalarRank;
}
