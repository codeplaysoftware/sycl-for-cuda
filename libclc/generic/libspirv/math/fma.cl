//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include <spirv/spirv.h>

#include "../../lib/math/math.h"
#include "math/clc_fma.h"

#define __CLC_BODY <fma.inc>
#include <clc/math/gentype.inc>
