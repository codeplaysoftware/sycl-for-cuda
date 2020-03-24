//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include <spirv/spirv.h>

#define IMPL(TYPE, AS, NAME, PREFIX, SUFFIX)                                   \
  _CLC_OVERLOAD _CLC_DEF TYPE NAME(volatile AS TYPE *p, enum Scope scope,      \
                                   enum MemorySemanticsMask semantics,         \
                                   TYPE val) {                                 \
    return PREFIX##__sync_fetch_and_##SUFFIX(p, val);                          \
  }

IMPL(int, global, __spirv_AtomicSMin, , min)
IMPL(unsigned int, global, __spirv_AtomicUMin, , umin)
IMPL(int, local, __spirv_AtomicSMin, , min)
IMPL(unsigned int, local, __spirv_AtomicUMin, , umin)

#ifdef cl_khr_int64_extended_atomics
unsigned long __clc__sync_fetch_and_min_local_8(volatile local long *, long);
unsigned long __clc__sync_fetch_and_min_global_8(volatile global long *, long);
unsigned long __clc__sync_fetch_and_umin_local_8(volatile local unsigned long *, unsigned long);
unsigned long __clc__sync_fetch_and_umin_global_8(volatile global unsigned long *, unsigned long);

IMPL(long, global, __spirv_AtomicSMin, __clc, min_global_8)
IMPL(unsigned long, global, __spirv_AtomicUMin, __clc, umin_global_8)
IMPL(long, local, __spirv_AtomicSMin, __clc, min_local_8)
IMPL(unsigned long, local, __spirv_AtomicUMin, __clc, umin_local_8)
#endif
#undef IMPL
