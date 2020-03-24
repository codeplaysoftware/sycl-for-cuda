//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include <spirv/spirv.h>

_CLC_OVERLOAD _CLC_DEF float
__spirv_AtomicExchange(volatile global float *p, enum Scope scope,
                       enum MemorySemanticsMask semantics, float val) {
  return as_float(__spirv_AtomicExchange((volatile global uint *)p, scope,
                                         semantics, as_uint(val)));
}

_CLC_OVERLOAD _CLC_DEF float
__spirv_AtomicExchange(volatile local float *p, enum Scope scope,
                       enum MemorySemanticsMask semantics, float val) {
  return as_float(__spirv_AtomicExchange((volatile local uint *)p, scope,
                                         semantics, as_uint(val)));
}

#define IMPL(TYPE, AS, FN_NAME)                                                \
  _CLC_OVERLOAD _CLC_DEF TYPE __spirv_AtomicExchange(                          \
      volatile AS TYPE *p, enum Scope scope,                                   \
      enum MemorySemanticsMask semantics, TYPE val) {                          \
    return FN_NAME(p, val);                                                    \
  }

IMPL(int, global, __sync_swap_4)
IMPL(unsigned int, global, __sync_swap_4)
IMPL(int, local, __sync_swap_4)
IMPL(unsigned int, local, __sync_swap_4)

#ifdef cl_khr_int64_base_atomics
IMPL(long, global, __sync_swap_8)
IMPL(unsigned long, global, __sync_swap_8)
IMPL(long, local, __sync_swap_8)
IMPL(unsigned long, local, __sync_swap_8)
#endif
#undef IMPL
