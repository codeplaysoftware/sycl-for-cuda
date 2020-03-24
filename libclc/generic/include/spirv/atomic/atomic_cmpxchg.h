//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

_CLC_OVERLOAD _CLC_DECL int
__spirv_AtomicCompareExchange(volatile local int *, enum Scope,
                              enum MemorySemanticsMask,
                              enum MemorySemanticsMask, int, int);
_CLC_OVERLOAD _CLC_DECL int
__spirv_AtomicCompareExchange(volatile global int *, enum Scope,
                              enum MemorySemanticsMask,
                              enum MemorySemanticsMask, int, int);
_CLC_OVERLOAD _CLC_DECL uint __spirv_AtomicCompareExchange(
    volatile local uint *, enum Scope, enum MemorySemanticsMask,
    enum MemorySemanticsMask, uint, uint);
_CLC_OVERLOAD _CLC_DECL uint __spirv_AtomicCompareExchange(
    volatile global uint *, enum Scope, enum MemorySemanticsMask,
    enum MemorySemanticsMask, uint, uint);

#ifdef cl_khr_int64_base_atomics
_CLC_OVERLOAD _CLC_DECL long
__spirv_AtomicCompareExchange(volatile local long *, enum Scope,
                              enum MemorySemanticsMask,
                              enum MemorySemanticsMask, long, long);
_CLC_OVERLOAD _CLC_DECL long
__spirv_AtomicCompareExchange(volatile global long *, enum Scope,
                              enum MemorySemanticsMask,
                              enum MemorySemanticsMask, long, long);
_CLC_OVERLOAD _CLC_DECL unsigned long __spirv_AtomicCompareExchange(
    volatile local unsigned long *, enum Scope, enum MemorySemanticsMask,
    enum MemorySemanticsMask, unsigned long, unsigned long);
_CLC_OVERLOAD _CLC_DECL unsigned long __spirv_AtomicCompareExchange(
    volatile global unsigned long *, enum Scope, enum MemorySemanticsMask,
    enum MemorySemanticsMask, unsigned long, unsigned long);
#endif
