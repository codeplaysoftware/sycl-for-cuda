//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include <spirv/spirv.h>

_CLC_OVERLOAD _CLC_DEF void
__spirv_AtomicStore(volatile global float *p, enum Scope scope,
                    enum MemorySemanticsMask semantics, float val) {
  __spirv_AtomicStore((volatile global uint *)p, scope, semantics,
                      as_uint(val));
}

_CLC_OVERLOAD _CLC_DEF void
__spirv_AtomicStore(volatile local float *p, enum Scope scope,
                    enum MemorySemanticsMask semantics, float val) {
  __spirv_AtomicStore((volatile local uint *)p, scope, semantics, as_uint(val));
}

#define FDECL(TYPE, PREFIX, AS, BYTE_SIZE, MEM_ORDER) \
TYPE __clc__atomic_##PREFIX##store_##AS##_##BYTE_SIZE##_##MEM_ORDER(volatile AS const TYPE *, TYPE);

#define IMPL(TYPE, AS, PREFIX, BYTE_SIZE)                                      \
  FDECL(TYPE, PREFIX, AS, BYTE_SIZE, unordered)                                \
  FDECL(TYPE, PREFIX, AS, BYTE_SIZE, release)                                  \
  FDECL(TYPE, PREFIX, AS, BYTE_SIZE, seq_cst)                                  \
  _CLC_OVERLOAD _CLC_DEF void __spirv_AtomicStore(                             \
      volatile AS TYPE *p, enum Scope scope,                                   \
      enum MemorySemanticsMask semantics, TYPE val) {                          \
    if (semantics == Release) {                                                \
      __clc__atomic_##PREFIX##store_##AS##_##BYTE_SIZE##_release(p, val);      \
    } else if (semantics == SequentiallyConsistent) {                          \
      __clc__atomic_##PREFIX##store_##AS##_##BYTE_SIZE##_seq_cst(p, val);      \
    } else {                                                                   \
      __clc__atomic_##PREFIX##store_##AS##_##BYTE_SIZE##_unordered(p, val);    \
    }                                                                          \
  }

#define IMPL_AS(TYPE, PREFIX, BYTE_SIZE)                                       \
  IMPL(TYPE, global, PREFIX, BYTE_SIZE)                                        \
  IMPL(TYPE, local, PREFIX, BYTE_SIZE)

IMPL_AS(int, , 4)
IMPL_AS(unsigned int, u, 4)

#ifdef cl_khr_int64_base_atomics
IMPL_AS(long, , 8)
IMPL_AS(unsigned long, u, 8)
#endif

#undef FDECL
#undef IMPL_AS
#undef IMPL
