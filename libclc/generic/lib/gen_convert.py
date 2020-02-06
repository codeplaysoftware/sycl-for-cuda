#!/usr/bin/env python3
import os
import sys
from os.path import dirname, join, abspath
sys.path.insert(0, abspath(join(dirname(__file__), '..')))

from gen_convert_common import (
  types, int_types, signed_types, unsigned_types, float_types, int64_types, float64_types,
  vector_sizes, half_sizes, saturation, rounding_modes, float_prefix, float_suffix, bool_type,
  unsigned_type, sizeof_type, limit_max, limit_min, conditional_guard, spirv_fn_name
)

# OpenCL built-in library: type conversion functions
#
# Copyright (c) 2013 Victor Oliveira <victormatheus@gmail.com>
# Copyright (c) 2013 Jesse Towner <jessetowner@lavabit.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# This script generates the file convert-clc.cl, which contains all of the
# OpenCL functions in the form:
#
# convert_<destTypen><_sat><_roundingMode>(<sourceTypen>)


print("""/* !!!! AUTOGENERATED FILE generated by convert_type.py !!!!!

   DON'T CHANGE THIS FILE. MAKE YOUR CHANGES TO convert_type.py AND RUN:
   $ ./generate-conversion-type-cl.sh

   OpenCL type conversion functions

   Copyright (c) 2013 Victor Oliveira <victormatheus@gmail.com>
   Copyright (c) 2013 Jesse Towner <jessetowner@lavabit.com>

   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the "Software"), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in
   all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
   THE SOFTWARE.
*/

#include <clc/clc.h>
#include <spirv/spirv.h>

#ifdef cl_khr_fp64
#pragma OPENCL EXTENSION cl_khr_fp64 : enable

#if defined(__EMBEDDED_PROFILE__) && !defined(cles_khr_int64)
#error Embedded profile that supports cl_khr_fp64 also has to support cles_khr_int64
#endif

#endif

#ifdef cles_khr_int64
#pragma OPENCL EXTENSION cles_khr_int64 : enable
#endif

""")


def generate_ocl_fn(src, dst, size='', mode='', sat=''):
  close_conditional = conditional_guard(src, dst)
  name = spirv_fn_name(src, dst, size, mode, sat)
  op = "{NAME}(x)".format(NAME=name)
  if name is None:
    # If there isn't a `__spirv` function for this conversion then just call other CL functions.
    if size == '':
      op = "({DST}{N})(x)".format(DST=dst, N=size)
    elif size == '3':
      op = "({DST}{N})({FN2}(x.s01), {FN1}(x.s2))".format(
        DST=dst, N=size,
        FN1="convert_{DST}{N}{S}{M}".format(DST=dst, N='', M=mode, S=sat),
        FN2="convert_{DST}{N}{S}{M}".format(DST=dst, N='2', M=mode, S=sat))
    else:
      op = "({DST}{N})({FN}(x.lo), {FN}(x.hi))".format(
        DST=dst, N=size,
        FN="convert_{DST}{N}{S}{M}".format(DST=dst, N=half_sizes[size], M=mode, S=sat))

  print("""_CLC_DEF _CLC_OVERLOAD
{DST}{N} convert_{DST}{N}{S}{M}({SRC}{N} x)
{{
  return {OP};
}}""".format(SRC=src, DST=dst, N=size, M=mode, S=sat, OP=op))

  if close_conditional:
    print("#endif")


for src in types:
  for dst in types:
    for size in vector_sizes:
      for sat in saturation:
        generate_ocl_fn(src, dst, size, '', sat)
        for mode in rounding_modes:
          generate_ocl_fn(src, dst, size, mode, sat)
