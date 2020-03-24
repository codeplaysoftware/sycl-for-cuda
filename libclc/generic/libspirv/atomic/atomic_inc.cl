//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include <spirv/spirv.h>

_CLC_OVERLOAD _CLC_DEF int
__spirv_AtomicIIncrement(volatile local int *p, enum Scope scope,
                         enum MemorySemanticsMask semantics) {
  return __sync_fetch_and_add(p, (int)1);
}

_CLC_OVERLOAD _CLC_DEF int
__spirv_AtomicIIncrement(volatile global int *p, enum Scope scope,
                         enum MemorySemanticsMask semantics) {
  return __sync_fetch_and_add(p, (int)1);
}

_CLC_OVERLOAD _CLC_DEF uint
__spirv_AtomicIIncrement(volatile local uint *p, enum Scope scope,
                         enum MemorySemanticsMask semantics) {
  return __sync_fetch_and_add(p, (uint)1);
}

_CLC_OVERLOAD _CLC_DEF uint
__spirv_AtomicIIncrement(volatile global uint *p, enum Scope scope,
                         enum MemorySemanticsMask semantics) {
  return __sync_fetch_and_add(p, (uint)1);
}

#ifdef cl_khr_int64_base_atomics
_CLC_OVERLOAD _CLC_DEF long
__spirv_AtomicIIncrement(volatile local long *p, enum Scope scope,
                         enum MemorySemanticsMask semantics) {
  return __sync_fetch_and_add(p, (long)1);
}

_CLC_OVERLOAD _CLC_DEF long
__spirv_AtomicIIncrement(volatile global long *p, enum Scope scope,
                         enum MemorySemanticsMask semantics) {
  return __sync_fetch_and_add(p, (long)1);
}

_CLC_OVERLOAD _CLC_DEF ulong
__spirv_AtomicIIncrement(volatile local ulong *p, enum Scope scope,
                         enum MemorySemanticsMask semantics) {
  return __sync_fetch_and_add(p, (ulong)1);
}

_CLC_OVERLOAD _CLC_DEF ulong
__spirv_AtomicIIncrement(volatile global ulong *p, enum Scope scope,
                         enum MemorySemanticsMask semantics) {
  return __sync_fetch_and_add(p, (ulong)1);
}
#endif
