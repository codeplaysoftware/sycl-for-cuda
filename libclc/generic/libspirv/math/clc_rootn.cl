//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include <spirv/spirv.h>

#include "tables.h"
#include <clcmacro.h>
#include <config.h>
#include <math/math.h>

// compute pow using log and exp
// x^y = exp(y * log(x))
//
// we take care not to lose precision in the intermediate steps
//
// When computing log, calculate it in splits,
//
// r = f * (p_invead + p_inv_tail)
// r = rh + rt
//
// calculate log polynomial using r, in end addition, do
// poly = poly + ((rh-r) + rt)
//
// lth = -r
// ltt = ((xexp * log2_t) - poly) + logT
// lt = lth + ltt
//
// lh = (xexp * log2_h) + logH
// l = lh + lt
//
// Calculate final log answer as gh and gt,
// gh = l & higher-half bits
// gt = (((ltt - (lt - lth)) + ((lh - l) + lt)) + (l - gh))
//
// yh = y & higher-half bits
// yt = y - yh
//
// Before entering computation of exp,
// vs = ((yt*gt + yt*gh) + yh*gt)
// v = vs + yh*gh
// vt = ((yh*gh - v) + vs)
//
// In calculation of exp, add vt to r that is used for poly
// At the end of exp, do
// ((((expT * poly) + expT) + expH*poly) + expH)

_CLC_DEF _CLC_OVERLOAD float __clc_rootn(float x, int ny) {
  float y = MATH_RECIP((float)ny);

  int ix = as_int(x);
  int ax = ix & EXSIGNBIT_SP32;
  int xpos = ix == ax;

  int iy = as_int(y);
  int ay = iy & EXSIGNBIT_SP32;
  int ypos = iy == ay;

  // Extra precise log calculation
  // First handle case that x is close to 1
  float r = 1.0f - as_float(ax);
  int near1 = __spirv_ocl_fabs(r) < 0x1.0p-4f;
  float r2 = r * r;

  // Coefficients are just 1/3, 1/4, 1/5 and 1/6
  float poly = __spirv_ocl_mad(
      r,
      __spirv_ocl_mad(
          r,
          __spirv_ocl_mad(r, __spirv_ocl_mad(r, 0x1.24924ap-3f, 0x1.555556p-3f),
                          0x1.99999ap-3f),
          0x1.000000p-2f),
      0x1.555556p-2f);

  poly *= r2 * r;

  float lth_near1 = -r2 * 0.5f;
  float ltt_near1 = -poly;
  float lt_near1 = lth_near1 + ltt_near1;
  float lh_near1 = -r;
  float l_near1 = lh_near1 + lt_near1;

  // Computations for x not near 1
  int m = (int)(ax >> EXPSHIFTBITS_SP32) - EXPBIAS_SP32;
  float mf = (float)m;
  int ixs = as_int(as_float(ax | 0x3f800000) - 1.0f);
  float mfs = (float)((ixs >> EXPSHIFTBITS_SP32) - 253);
  int c = m == -127;
  int ixn = c ? ixs : ax;
  float mfn = c ? mfs : mf;

  int indx = (ixn & 0x007f0000) + ((ixn & 0x00008000) << 1);

  // F - Y
  float f = as_float(0x3f000000 | indx) -
            as_float(0x3f000000 | (ixn & MANTBITS_SP32));

  indx = indx >> 16;
  float2 tv = USE_TABLE(log_inv_tbl_ep, indx);
  float rh = f * tv.s0;
  float rt = f * tv.s1;
  r = rh + rt;

  poly = __spirv_ocl_mad(r, __spirv_ocl_mad(r, 0x1.0p-2f, 0x1.555556p-2f),
                         0x1.0p-1f) *
         (r * r);
  poly += (rh - r) + rt;

  const float LOG2_HEAD = 0x1.62e000p-1f;  // 0.693115234
  const float LOG2_TAIL = 0x1.0bfbe8p-15f; // 0.0000319461833
  tv = USE_TABLE(loge_tbl, indx);
  float lth = -r;
  float ltt = __spirv_ocl_mad(mfn, LOG2_TAIL, -poly) + tv.s1;
  float lt = lth + ltt;
  float lh = __spirv_ocl_mad(mfn, LOG2_HEAD, tv.s0);
  float l = lh + lt;

  // Select near 1 or not
  lth = near1 ? lth_near1 : lth;
  ltt = near1 ? ltt_near1 : ltt;
  lt = near1 ? lt_near1 : lt;
  lh = near1 ? lh_near1 : lh;
  l = near1 ? l_near1 : l;

  float gh = as_float(as_int(l) & 0xfffff000);
  float gt = ((ltt - (lt - lth)) + ((lh - l) + lt)) + (l - gh);

  float yh = as_float(iy & 0xfffff000);

  float fny = (float)ny;
  float fnyh = as_float(as_int(fny) & 0xfffff000);
  float fnyt = (float)(ny - (int)fnyh);
  float yt = MATH_DIVIDE(
      __spirv_ocl_mad(-fnyt, yh, __spirv_ocl_mad(-fnyh, yh, 1.0f)), fny);

  float ylogx_s = __spirv_ocl_mad(gt, yh, __spirv_ocl_mad(gh, yt, yt * gt));
  float ylogx = __spirv_ocl_mad(yh, gh, ylogx_s);
  float ylogx_t = __spirv_ocl_mad(yh, gh, -ylogx) + ylogx_s;

  // Extra precise exp of ylogx
  const float R_64_BY_LOG2 = 0x1.715476p+6f; // 64/log2 : 92.332482616893657
  int n = __spirv_ConvertFToS_Rint(ylogx * R_64_BY_LOG2);
  float nf = (float)n;

  int j = n & 0x3f;
  m = n >> 6;
  int m2 = m << EXPSHIFTBITS_SP32;

  const float R_LOG2_BY_64_LD = 0x1.620000p-7f; // log2/64 lead: 0.0108032227
  const float R_LOG2_BY_64_TL =
      0x1.c85fdep-16f; // log2/64 tail: 0.0000272020388
  r = __spirv_ocl_mad(nf, -R_LOG2_BY_64_TL,
                      __spirv_ocl_mad(nf, -R_LOG2_BY_64_LD, ylogx)) +
      ylogx_t;

  // Truncated Taylor series for e^r
  poly = __spirv_ocl_mad(
      __spirv_ocl_mad(__spirv_ocl_mad(r, 0x1.555556p-5f, 0x1.555556p-3f), r,
                      0x1.000000p-1f),
      r * r, r);

  tv = USE_TABLE(exp_tbl_ep, j);

  float expylogx =
      __spirv_ocl_mad(tv.s0, poly, __spirv_ocl_mad(tv.s1, poly, tv.s1)) + tv.s0;
  float sexpylogx = __clc_fp32_subnormals_supported()
                        ? expylogx * as_float(0x1 << (m + 149))
                        : 0.0f;

  float texpylogx = as_float(as_int(expylogx) + m2);
  expylogx = m < -125 ? sexpylogx : texpylogx;

  // Result is +-Inf if (ylogx + ylogx_t) > 128*log2
  expylogx = ((ylogx > 0x1.62e430p+6f) |
              (ylogx == 0x1.62e430p+6f & ylogx_t > -0x1.05c610p-22f))
                 ? as_float(PINFBITPATT_SP32)
                 : expylogx;

  // Result is 0 if ylogx < -149*log2
  expylogx = ylogx < -0x1.9d1da0p+6f ? 0.0f : expylogx;

  // Classify y:
  //   inty = 0 means not an integer.
  //   inty = 1 means odd integer.
  //   inty = 2 means even integer.

  int inty = 2 - (ny & 1);

  float signval = as_float((as_uint(expylogx) ^ SIGNBIT_SP32));
  expylogx = ((inty == 1) & !xpos) ? signval : expylogx;
  int ret = as_int(expylogx);

  // Corner case handling
  ret = (!xpos & (inty == 2)) ? QNANBITPATT_SP32 : ret;
  int xinf = xpos ? PINFBITPATT_SP32 : NINFBITPATT_SP32;
  ret = ((ax == 0) & !ypos & (inty == 1)) ? xinf : ret;
  ret = ((ax == 0) & !ypos & (inty == 2)) ? PINFBITPATT_SP32 : ret;
  ret = ((ax == 0) & ypos & (inty == 2)) ? 0 : ret;
  int xzero = xpos ? 0 : 0x80000000;
  ret = ((ax == 0) & ypos & (inty == 1)) ? xzero : ret;
  ret =
      ((ix == NINFBITPATT_SP32) & ypos & (inty == 1)) ? NINFBITPATT_SP32 : ret;
  ret = ((ix == NINFBITPATT_SP32) & !ypos & (inty == 1)) ? 0x80000000 : ret;
  ret = ((ix == PINFBITPATT_SP32) & !ypos) ? 0 : ret;
  ret = ((ix == PINFBITPATT_SP32) & ypos) ? PINFBITPATT_SP32 : ret;
  ret = ax > PINFBITPATT_SP32 ? ix : ret;
  ret = ny == 0 ? QNANBITPATT_SP32 : ret;

  return as_float(ret);
}
_CLC_BINARY_VECTORIZE(_CLC_DEF _CLC_OVERLOAD, float, __clc_rootn, float, int)

#ifdef cl_khr_fp64
_CLC_DEF _CLC_OVERLOAD double __clc_rootn(double x, int ny) {
  const double real_log2_tail = 5.76999904754328540596e-08;
  const double real_log2_lead = 6.93147122859954833984e-01;

  double dny = (double)ny;
  double y = 1.0 / dny;

  long ux = as_long(x);
  long ax = ux & (~SIGNBIT_DP64);
  int xpos = ax == ux;

  long uy = as_long(y);
  long ay = uy & (~SIGNBIT_DP64);
  int ypos = ay == uy;

  // Extended precision log
  double v, vt;
  {
    int exp = (int)(ax >> 52) - 1023;
    int mask_exp_1023 = exp == -1023;
    double xexp = (double)exp;
    long mantissa = ax & 0x000FFFFFFFFFFFFFL;

    long temp_ux = as_long(as_double(0x3ff0000000000000L | mantissa) - 1.0);
    exp = ((temp_ux & 0x7FF0000000000000L) >> 52) - 2045;
    double xexp1 = (double)exp;
    long mantissa1 = temp_ux & 0x000FFFFFFFFFFFFFL;

    xexp = mask_exp_1023 ? xexp1 : xexp;
    mantissa = mask_exp_1023 ? mantissa1 : mantissa;

    long rax = (mantissa & 0x000ff00000000000) +
               ((mantissa & 0x0000080000000000) << 1);
    int index = rax >> 44;

    double F = as_double(rax | 0x3FE0000000000000L);
    double Y = as_double(mantissa | 0x3FE0000000000000L);
    double f = F - Y;
    double2 tv = USE_TABLE(log_f_inv_tbl, index);
    double log_h = tv.s0;
    double log_t = tv.s1;
    double f_inv = (log_h + log_t) * f;
    double r1 = as_double(as_long(f_inv) & 0xfffffffff8000000L);
    double r2 = __spirv_ocl_fma(-F, r1, f) * (log_h + log_t);
    double r = r1 + r2;

    double poly = __spirv_ocl_fma(
        r,
        __spirv_ocl_fma(
            r,
            __spirv_ocl_fma(r, __spirv_ocl_fma(r, 1.0 / 7.0, 1.0 / 6.0),
                            1.0 / 5.0),
            1.0 / 4.0),
        1.0 / 3.0);
    poly = poly * r * r * r;

    double hr1r1 = 0.5 * r1 * r1;
    double poly0h = r1 + hr1r1;
    double poly0t = r1 - poly0h + hr1r1;
    poly = __spirv_ocl_fma(r1, r2, __spirv_ocl_fma(0.5 * r2, r2, poly)) + r2 +
           poly0t;

    tv = USE_TABLE(powlog_tbl, index);
    log_h = tv.s0;
    log_t = tv.s1;

    double resT_t = __spirv_ocl_fma(xexp, real_log2_tail, +log_t) - poly;
    double resT = resT_t - poly0h;
    double resH = __spirv_ocl_fma(xexp, real_log2_lead, log_h);
    double resT_h = poly0h;

    double H = resT + resH;
    double H_h = as_double(as_long(H) & 0xfffffffff8000000L);
    double T = (resH - H + resT) + (resT_t - (resT + resT_h)) + (H - H_h);
    H = H_h;

    double y_head = as_double(uy & 0xfffffffff8000000L);
    double y_tail = y - y_head;

    double fnyh = as_double(as_long(dny) & 0xfffffffffff00000);
    double fnyt = (double)(ny - (int)fnyh);
    y_tail =
        __spirv_ocl_fma(-fnyt, y_head, __spirv_ocl_fma(-fnyh, y_head, 1.0)) /
        dny;

    double temp =
        __spirv_ocl_fma(y_tail, H, __spirv_ocl_fma(y_head, T, y_tail * T));
    v = __spirv_ocl_fma(y_head, H, temp);
    vt = __spirv_ocl_fma(y_head, H, -v) + temp;
  }

  // Now calculate exp of (v,vt)

  double expv;
  {
    const double max_exp_arg = 709.782712893384;
    const double min_exp_arg = -745.1332191019411;
    const double sixtyfour_by_lnof2 = 92.33248261689366;
    const double lnof2_by_64_head = 0.010830424260348081;
    const double lnof2_by_64_tail = -4.359010638708991e-10;

    double temp = v * sixtyfour_by_lnof2;
    int n = (int)temp;
    double dn = (double)n;
    int j = n & 0x0000003f;
    int m = n >> 6;

    double2 tv = USE_TABLE(two_to_jby64_ep_tbl, j);
    double f1 = tv.s0;
    double f2 = tv.s1;
    double f = f1 + f2;

    double r1 = __spirv_ocl_fma(dn, -lnof2_by_64_head, v);
    double r2 = dn * lnof2_by_64_tail;
    double r = (r1 + r2) + vt;

    double q = __spirv_ocl_fma(
        r,
        __spirv_ocl_fma(
            r,
            __spirv_ocl_fma(r,
                            __spirv_ocl_fma(r, 1.38889490863777199667e-03,
                                            8.33336798434219616221e-03),
                            4.16666666662260795726e-02),
            1.66666666665260878863e-01),
        5.00000000000000008883e-01);
    q = __spirv_ocl_fma(r * r, q, r);

    expv = __spirv_ocl_fma(f, q, f2) + f1;
    expv = __spirv_ocl_ldexp(expv, m);

    expv = v > max_exp_arg ? as_double(0x7FF0000000000000L) : expv;
    expv = v < min_exp_arg ? 0.0 : expv;
  }

  // See whether y is an integer.
  // inty = 0 means not an integer.
  // inty = 1 means odd integer.
  // inty = 2 means even integer.

  int inty = 2 - (ny & 1);

  expv *= ((inty == 1) & !xpos) ? -1.0 : 1.0;

  long ret = as_long(expv);

  // Now all the edge cases
  ret = (!xpos & (inty == 2)) ? QNANBITPATT_DP64 : ret;
  long xinf = xpos ? PINFBITPATT_DP64 : NINFBITPATT_DP64;
  ret = ((ax == 0L) & !ypos & (inty == 1)) ? xinf : ret;
  ret = ((ax == 0L) & !ypos & (inty == 2)) ? PINFBITPATT_DP64 : ret;
  ret = ((ax == 0L) & ypos & (inty == 2)) ? 0L : ret;
  long xzero = xpos ? 0L : 0x8000000000000000L;
  ret = ((ax == 0L) & ypos & (inty == 1)) ? xzero : ret;
  ret =
      ((ux == NINFBITPATT_DP64) & ypos & (inty == 1)) ? NINFBITPATT_DP64 : ret;
  ret = ((ux == NINFBITPATT_DP64) & !ypos & (inty == 1)) ? 0x8000000000000000L
                                                         : ret;
  ret = ((ux == PINFBITPATT_DP64) & !ypos) ? 0L : ret;
  ret = ((ux == PINFBITPATT_DP64) & ypos) ? PINFBITPATT_DP64 : ret;
  ret = ax > PINFBITPATT_DP64 ? ux : ret;
  ret = ny == 0 ? QNANBITPATT_DP64 : ret;
  return as_double(ret);
}
_CLC_BINARY_VECTORIZE(_CLC_DEF _CLC_OVERLOAD, double, __clc_rootn, double, int)
#endif

#ifdef cl_khr_fp16
#pragma OPENCL EXTENSION cl_khr_fp16 : enable

_CLC_DEF _CLC_OVERLOAD half __clc_rootn(half x, int ny) {
  return __clc_rootn((float)x, ny);
}

_CLC_BINARY_VECTORIZE(_CLC_DEF _CLC_OVERLOAD, half, __clc_rootn, half, int)
#endif
