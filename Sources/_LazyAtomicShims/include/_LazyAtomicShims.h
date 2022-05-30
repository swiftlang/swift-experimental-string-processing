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

// THIS FILE IS PART OF A SUBSET OF https://github.com/apple/swift-atomics/

#ifndef SWIFT_STDLIB_SHIMS_LAZYATOMIC_H
#define SWIFT_STDLIB_SHIMS_LAZYATOMIC_H

#include <stdbool.h>
#include <stdint.h>
#include <assert.h>
// The atomic primitives are only needed when this is compiled using Swift's
// Clang Importer. This allows us to continue reling on some Clang extensions
// (see https://github.com/apple/swift-atomics/issues/37).
#if defined(__swift__)
#  include <stdatomic.h>
#endif

#if defined(__swift__)

#define SWIFTATOMIC_INLINE static inline __attribute__((__always_inline__))
#define SWIFTATOMIC_SWIFT_NAME(name) __attribute__((swift_name(#name)))

// Definition of an atomic storage type.
#define SWIFTATOMIC_STORAGE_TYPE(swiftType, cType, storageType)         \
  typedef struct {                                                      \
    _Atomic(storageType) value;                                         \
  } _sa_##swiftType                                                     \
  SWIFTATOMIC_SWIFT_NAME(_Atomic##swiftType##Storage);

// Storage value initializer
#define SWIFTATOMIC_PREPARE_FN(swiftType, cType, storageType)           \
  SWIFTATOMIC_INLINE                                                    \
  _sa_##swiftType _sa_prepare_##swiftType(cType value)                  \
  {                                                                     \
    _sa_##swiftType storage = { SWIFTATOMIC_ENCODE_##swiftType(value) }; \
    assert(atomic_is_lock_free(&storage.value));                        \
    return storage;                                                     \
  }

// Storage value disposal function
#define SWIFTATOMIC_DISPOSE_FN(swiftType, cType, storageType)           \
  SWIFTATOMIC_INLINE                                                    \
  cType _sa_dispose_##swiftType(_sa_##swiftType storage)                \
  {                                                                     \
    return SWIFTATOMIC_DECODE_##swiftType(storage.value);               \
  }

// Atomic load
#define SWIFTATOMIC_LOAD_FN(swiftType, cType, storageType, order)       \
  SWIFTATOMIC_INLINE                                                    \
  cType _sa_load_##order##_##swiftType(                                 \
    _sa_##swiftType *ptr)                                               \
  {                                                                     \
    return SWIFTATOMIC_DECODE_##swiftType(                              \
      atomic_load_explicit(&ptr->value,                                 \
                           memory_order_##order));                      \
  }

// Atomic compare/exchange
#define SWIFTATOMIC_CMPXCHG_FN_SIMPLE(_kind, swiftType, cType, storageType, succ, fail) \
  SWIFTATOMIC_INLINE                                                    \
  bool                                                                  \
  _sa_cmpxchg_##_kind##_##succ##_##fail##_##swiftType(                  \
    _sa_##swiftType *ptr,                                               \
    cType *expected,                                                    \
    cType desired)                                                      \
  {                                                                     \
    return atomic_compare_exchange_##_kind##_explicit(                  \
      &ptr->value,                                                      \
      expected,                                                         \
      desired,                                                          \
      memory_order_##succ,                                              \
      memory_order_##fail);                                             \
  }

#define SWIFTATOMIC_DEFINE_TYPE(variant, swiftType, cType, storageType) \
  SWIFTATOMIC_STORAGE_TYPE(swiftType, cType, storageType)              \
  SWIFTATOMIC_PREPARE_FN(swiftType, cType, storageType)                \
  SWIFTATOMIC_DISPOSE_FN(swiftType, cType, storageType)                \
  SWIFTATOMIC_LOAD_FN(swiftType, cType, storageType, acquire)          \
  SWIFTATOMIC_CMPXCHG_FN_##variant(strong, swiftType, cType, storageType, acq_rel, acquire)

#define SWIFTATOMIC_ENCODE_Int(value) (value)
#define SWIFTATOMIC_DECODE_Int(value) (value)
SWIFTATOMIC_DEFINE_TYPE(SIMPLE, Int, intptr_t, intptr_t)

#endif // __swift__

#endif // SWIFT_STDLIB_SHIMS_LAZYATOMIC_H
