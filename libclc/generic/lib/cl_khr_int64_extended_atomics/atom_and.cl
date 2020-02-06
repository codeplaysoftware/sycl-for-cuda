#include <clc/clc.h>
#include <spirv/spirv.h>

#ifdef cl_khr_int64_extended_atomics

#define IMPL(TYPE, TYPE_MANGLED, AS, AS_MANGLED) \
_CLC_OVERLOAD _CLC_DEF TYPE atom_and(volatile AS TYPE *p, TYPE val) { \
  return _Z17__spirv_AtomicAndPU3##AS_MANGLED##TYPE_MANGLED##N5__spv5ScopeENS1_19MemorySemanticsMaskE##TYPE_MANGLED(p, Device, SequentiallyConsistent, val); \
}

IMPL(long, l, global, AS1)
IMPL(unsigned long, m, global, AS1)
IMPL(long, l, local, AS3)
IMPL(unsigned long, m, local, AS3)
#undef IMPL

#endif
