#include <clc/clc.h>
#include <spirv/spirv.h>

#define IMPL(TYPE, AS)                                                         \
  _CLC_OVERLOAD _CLC_DEF TYPE atomic_inc(volatile AS TYPE *p) {                \
    return __spirv_AtomicIIncrement(p, Device, SequentiallyConsistent);        \
  }

IMPL(int, global)
IMPL(unsigned int, global)
IMPL(int, local)
IMPL(unsigned int, local)
#undef IMPL
