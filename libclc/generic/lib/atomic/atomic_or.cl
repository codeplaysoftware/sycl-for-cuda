#include <clc/clc.h>
#include <spirv/spirv.h>

#define IMPL(TYPE, AS)                                                         \
  _CLC_OVERLOAD _CLC_DEF TYPE atomic_or(volatile AS TYPE *p, TYPE val) {       \
    return __spirv_AtomicOr(p, Device, SequentiallyConsistent, val);           \
  }

IMPL(int, global)
IMPL(unsigned int, global)
IMPL(int, local)
IMPL(unsigned int, local)
#undef IMPL
