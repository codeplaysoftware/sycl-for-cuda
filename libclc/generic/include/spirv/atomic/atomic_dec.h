//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

_CLC_OVERLOAD _CLC_DECL int __spirv_AtomicIDecrement(volatile local int *,
                                                     enum Scope,
                                                     enum MemorySemanticsMask);
_CLC_OVERLOAD _CLC_DECL int __spirv_AtomicIDecrement(volatile global int *,
                                                     enum Scope,
                                                     enum MemorySemanticsMask);
_CLC_OVERLOAD _CLC_DECL uint __spirv_AtomicIDecrement(volatile local uint *,
                                                      enum Scope,
                                                      enum MemorySemanticsMask);
_CLC_OVERLOAD _CLC_DECL uint __spirv_AtomicIDecrement(volatile global uint *,
                                                      enum Scope,
                                                      enum MemorySemanticsMask);

#ifdef cl_khr_int64_base_atomics
_CLC_OVERLOAD _CLC_DECL long __spirv_AtomicIDecrement(volatile local long *,
                                                      enum Scope,
                                                      enum MemorySemanticsMask);
_CLC_OVERLOAD _CLC_DECL long __spirv_AtomicIDecrement(volatile global long *,
                                                      enum Scope,
                                                      enum MemorySemanticsMask);
_CLC_OVERLOAD _CLC_DECL unsigned long
__spirv_AtomicIDecrement(volatile local unsigned long *, enum Scope,
                         enum MemorySemanticsMask);
_CLC_OVERLOAD _CLC_DECL unsigned long
__spirv_AtomicIDecrement(volatile global unsigned long *, enum Scope,
                         enum MemorySemanticsMask);
#endif
