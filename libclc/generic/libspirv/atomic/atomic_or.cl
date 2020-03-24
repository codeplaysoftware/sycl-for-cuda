//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include <spirv/spirv.h>

#define IMPL(TYPE, AS, FN_NAME)                                                \
  _CLC_OVERLOAD _CLC_DEF TYPE __spirv_AtomicOr(                                \
      volatile AS TYPE *p, enum Scope scope,                                   \
      enum MemorySemanticsMask semantics, TYPE val) {                          \
    return FN_NAME(p, val);                                                    \
  }

IMPL(int, global, __sync_fetch_and_or)
IMPL(unsigned int, global, __sync_fetch_and_or)
IMPL(int, local, __sync_fetch_and_or)
IMPL(unsigned int, local, __sync_fetch_and_or)

#ifdef cl_khr_int64_extended_atomics
IMPL(long, global, __sync_fetch_and_or_8)
IMPL(unsigned long, global, __sync_fetch_and_or_8)
IMPL(long, local, __sync_fetch_and_or_8)
IMPL(unsigned long, local, __sync_fetch_and_or_8)
#endif
#undef IMPL
