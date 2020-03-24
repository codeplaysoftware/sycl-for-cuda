#include <clc/clc.h>
#include <spirv/spirv.h>

_CLC_OVERLOAD _CLC_DEF float atomic_xchg(volatile global float *p, float val) {
  return __spirv_AtomicExchange(p, Device, SequentiallyConsistent, val);
}

_CLC_OVERLOAD _CLC_DEF float atomic_xchg(volatile local float *p, float val) {
  return __spirv_AtomicExchange(p, Device, SequentiallyConsistent, val);
}

#define IMPL(TYPE, AS)                                                         \
  _CLC_OVERLOAD _CLC_DEF TYPE atomic_xchg(volatile AS TYPE *p, TYPE val) {     \
    return __spirv_AtomicExchange(p, Device, SequentiallyConsistent, val);     \
  }

IMPL(int, global)
IMPL(unsigned int, global)
IMPL(int, local)
IMPL(unsigned int, local)
#undef IMPL
