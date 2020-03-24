#include <clc/clc.h>
#include <spirv/spirv.h>

#ifdef cl_khr_int64_extended_atomics

#define IMPL(TYPE, AS, NAME)                                                   \
  _CLC_OVERLOAD _CLC_DEF TYPE atom_max(volatile AS TYPE *p, TYPE val) {        \
    return NAME(p, Device, SequentiallyConsistent, val);                       \
  }

IMPL(long, global, __spirv_AtomicSMax)
IMPL(unsigned long, global, __spirv_AtomicUMax)
IMPL(long, local, __spirv_AtomicSMax)
IMPL(unsigned long, local, __spirv_AtomicUMax)
#undef IMPL

#endif
