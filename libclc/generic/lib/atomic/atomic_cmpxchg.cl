#include <clc/clc.h>
#include <spirv/spirv.h>

#define IMPL(TYPE, AS)                                                         \
  _CLC_OVERLOAD _CLC_DEF TYPE atomic_cmpxchg(volatile AS TYPE *p, TYPE cmp,    \
                                             TYPE val) {                       \
    return __spirv_AtomicCompareExchange(p, Device, SequentiallyConsistent,    \
                                         SequentiallyConsistent, val, cmp);    \
  }

IMPL(int, global)
IMPL(unsigned int, global)
IMPL(int, local)
IMPL(unsigned int, local)
#undef IMPL
