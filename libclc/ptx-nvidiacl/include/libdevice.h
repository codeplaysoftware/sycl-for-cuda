//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef PTX_NVIDIACL_LIBDEVICE_H
#define PTX_NVIDIACL_LIBDEVICE_H

#include <spirv/spirv.h>

#ifdef cl_khr_fp64
#pragma OPENCL EXTENSION cl_khr_fp64 : enable
#endif

#ifdef cl_khr_fp16
#pragma OPENCL EXTENSION cl_khr_fp16 : enable
#endif

int __nv_abs(int);
double __nv_acos(double);
float __nv_acosf(float);
double __nv_acosh(double);
float __nv_acoshf(float);
double __nv_asin(double);
float __nv_asinf(float);
double __nv_asinh(double);
float __nv_asinhf(float);
double __nv_atan(double);
double __nv_atan2(double, double);
float __nv_atan2f(float, float);
float __nv_atanf(float);
double __nv_atanh(double);
float __nv_atanhf(float);
int __nv_brev(int);
long __nv_brevll(long);
int __nv_byte_perm(int, int, int);
double __nv_cbrt(double);
float __nv_cbrtf(float);
double __nv_ceil(double);
float __nv_ceilf(float);
int __nv_clz(int);
int __nv_clzll(long);
double __nv_copysign(double, double);
float __nv_copysignf(float, float);
double __nv_cos(double);
float __nv_cosf(float);
double __nv_cosh(double);
float __nv_coshf(float);
double __nv_cospi(double);
float __nv_cospif(float);
double __nv_cyl_bessel_i0(double);
float __nv_cyl_bessel_i0f(float);
double __nv_cyl_bessel_i1(double);
float __nv_cyl_bessel_i1f(float);
double __nv_dadd_rd(double, double);
double __nv_dadd_rn(double, double);
double __nv_dadd_ru(double, double);
double __nv_dadd_rz(double, double);
double __nv_ddiv_rd(double, double);
double __nv_ddiv_rn(double, double);
double __nv_ddiv_ru(double, double);
double __nv_ddiv_rz(double, double);
double __nv_dmul_rd(double, double);
double __nv_dmul_rn(double, double);
double __nv_dmul_ru(double, double);
double __nv_dmul_rz(double, double);
float __nv_double2float_rd(double);
float __nv_double2float_rn(double);
float __nv_double2float_ru(double);
float __nv_double2float_rz(double);
int __nv_double2hiint(double);
int __nv_double2int_rd(double);
int __nv_double2int_rn(double);
int __nv_double2int_ru(double);
int __nv_double2int_rz(double);
long __nv_double2ll_rd(double);
long __nv_double2ll_rn(double);
long __nv_double2ll_ru(double);
long __nv_double2ll_rz(double);
int __nv_double2loint(double);
int __nv_double2uint_rd(double);
int __nv_double2uint_rn(double);
int __nv_double2uint_ru(double);
int __nv_double2uint_rz(double);
long __nv_double2ull_rd(double);
long __nv_double2ull_rn(double);
long __nv_double2ull_ru(double);
long __nv_double2ull_rz(double);
long __nv_double_as_longlong(double);
double __nv_drcp_rd(double);
double __nv_drcp_rn(double);
double __nv_drcp_ru(double);
double __nv_drcp_rz(double);
double __nv_dsqrt_rd(double);
double __nv_dsqrt_rn(double);
double __nv_dsqrt_ru(double);
double __nv_dsqrt_rz(double);
double __nv_dsub_rd(double, double);
double __nv_dsub_rn(double, double);
double __nv_dsub_ru(double, double);
double __nv_dsub_rz(double, double);
double __nv_erf(double);
double __nv_erfc(double);
float __nv_erfcf(float);
double __nv_erfcinv(double);
float __nv_erfcinvf(float);
double __nv_erfcx(double);
float __nv_erfcxf(float);
float __nv_erff(float);
double __nv_erfinv(double);
float __nv_erfinvf(float);
double __nv_exp(double);
double __nv_exp10(double);
float __nv_exp10f(float);
double __nv_exp2(double);
float __nv_exp2f(float);
float __nv_expf(float);
double __nv_expm1(double);
float __nv_expm1f(float);
double __nv_fabs(double);
float __nv_fabsf(float);
float __nv_fadd_rd(float, float);
float __nv_fadd_rn(float, float);
float __nv_fadd_ru(float, float);
float __nv_fadd_rz(float, float);
float __nv_fast_cosf(float);
float __nv_fast_exp10f(float);
float __nv_fast_expf(float);
float __nv_fast_fdividef(float, float);
float __nv_fast_log10f(float);
float __nv_fast_log2f(float);
float __nv_fast_logf(float);
float __nv_fast_powf(float, float);
void __nv_fast_sincosf(float, float *, float *);
float __nv_fast_sinf(float);
float __nv_fast_tanf(float);
double __nv_fdim(double, double);
float __nv_fdimf(float, float);
float __nv_fdiv_rd(float, float);
float __nv_fdiv_rn(float, float);
float __nv_fdiv_ru(float, float);
float __nv_fdiv_rz(float, float);
int __nv_ffs(int);
int __nv_ffsll(long);
int __nv_finitef(float);
ushort __nv_float2half_rn(float);
int __nv_float2int_rd(float);
int __nv_float2int_rn(float);
int __nv_float2int_ru(float);
int __nv_float2int_rz(float);
long __nv_float2ll_rd(float);
long __nv_float2ll_rn(float);
long __nv_float2ll_ru(float);
long __nv_float2ll_rz(float);
int __nv_float2uint_rd(float);
int __nv_float2uint_rn(float);
int __nv_float2uint_ru(float);
int __nv_float2uint_rz(float);
long __nv_float2ull_rd(float);
long __nv_float2ull_rn(float);
long __nv_float2ull_ru(float);
long __nv_float2ull_rz(float);
int __nv_float_as_int(float);
int __nv_float_as_uint(float);
double __nv_floor(double);
float __nv_floorf(float);
double __nv_fma(double, double, double);
double __nv_fma_rd(double, double, double);
double __nv_fma_rn(double, double, double);
double __nv_fma_ru(double, double, double);
double __nv_fma_rz(double, double, double);
float __nv_fmaf(float, float, float);
float __nv_fmaf_ieee_rd(float, float, float);
float __nv_fmaf_ieee_rn(float, float, float);
float __nv_fmaf_ieee_ru(float, float, float);
float __nv_fmaf_ieee_rz(float, float, float);
float __nv_fmaf_rd(float, float, float);
float __nv_fmaf_rn(float, float, float);
float __nv_fmaf_ru(float, float, float);
float __nv_fmaf_rz(float, float, float);
double __nv_fmax(double, double);
float __nv_fmaxf(float, float);
double __nv_fmin(double, double);
float __nv_fminf(float, float);
double __nv_fmod(double, double);
float __nv_fmodf(float, float);
float __nv_fmul_rd(float, float);
float __nv_fmul_rn(float, float);
float __nv_fmul_ru(float, float);
float __nv_fmul_rz(float, float);
float __nv_frcp_rd(float);
float __nv_frcp_rn(float);
float __nv_frcp_ru(float);
float __nv_frcp_rz(float);
double __nv_frexp(double, int *);
float __nv_frexpf(float, int *);
float __nv_frsqrt_rn(float);
float __nv_fsqrt_rd(float);
float __nv_fsqrt_rn(float);
float __nv_fsqrt_ru(float);
float __nv_fsqrt_rz(float);
float __nv_fsub_rd(float, float);
float __nv_fsub_rn(float, float);
float __nv_fsub_ru(float, float);
float __nv_fsub_rz(float, float);
int __nv_hadd(int, int);
float __nv_half2float(ushort);
double __nv_hiloint2double(int, int);
double __nv_hypot(double, double);
float __nv_hypotf(float, float);
int __nv_ilogb(double);
int __nv_ilogbf(float);
double __nv_int2double_rn(int);
float __nv_int2float_rd(int);
float __nv_int2float_rn(int);
float __nv_int2float_ru(int);
float __nv_int2float_rz(int);
float __nv_int_as_float(int);
int __nv_isfinited(double);
int __nv_isinfd(double);
int __nv_isinff(float);
int __nv_isnand(double);
int __nv_isnanf(float);
double __nv_j0(double);
float __nv_j0f(float);
double __nv_j1(double);
float __nv_j1f(float);
double __nv_jn(int, double);
float __nv_jnf(int, float);
double __nv_ldexp(double, int);
float __nv_ldexpf(float, int);
double __nv_lgamma(double);
float __nv_lgammaf(float);
double __nv_ll2double_rd(long);
double __nv_ll2double_rn(long);
double __nv_ll2double_ru(long);
double __nv_ll2double_rz(long);
float __nv_ll2float_rd(long);
float __nv_ll2float_rn(long);
float __nv_ll2float_ru(long);
float __nv_ll2float_rz(long);
long __nv_llabs(long);
long __nv_llmax(long, long);
long __nv_llmin(long, long);
long __nv_llrint(double);
long __nv_llrintf(float);
long __nv_llround(double);
long __nv_llroundf(float);
double __nv_log(double);
double __nv_log10(double);
float __nv_log10f(float);
double __nv_log1p(double);
float __nv_log1pf(float);
double __nv_log2(double);
float __nv_log2f(float);
double __nv_logb(double);
float __nv_logbf(float);
float __nv_logf(float);
double __nv_longlong_as_double(long);
int __nv_max(int, int);
int __nv_min(int, int);
double __nv_modf(double, double *);
float __nv_modff(float, float *);
int __nv_mul24(int, int);
long __nv_mul64hi(long, long);
int __nv_mulhi(int, int);
double __nv_nan(char *);
float __nv_nanf(char *);
double __nv_nearbyint(double);
float __nv_nearbyintf(float);
double __nv_nextafter(double, double);
float __nv_nextafterf(float, float);
double __nv_norm(int, double *);
double __nv_norm3d(double, double, double);
float __nv_norm3df(float, float, float);
double __nv_norm4d(double, double, double, double);
float __nv_norm4df(float, float, float, float);
double __nv_normcdf(double);
float __nv_normcdff(float);
double __nv_normcdfinv(double);
float __nv_normcdfinvf(float);
float __nv_normf(int, float *);
int __nv_popc(int);
int __nv_popcll(long);
double __nv_pow(double, double);
float __nv_powf(float, float);
double __nv_powi(double, int);
float __nv_powif(float, int);
double __nv_rcbrt(double);
float __nv_rcbrtf(float);
double __nv_rcp64h(double);
double __nv_remainder(double, double);
float __nv_remainderf(float, float);
double __nv_remquo(double, double, int *);
float __nv_remquof(float, float, int *);
int __nv_rhadd(int, int);
double __nv_rhypot(double, double);
float __nv_rhypotf(float, float);
double __nv_rint(double);
float __nv_rintf(float);
double __nv_rnorm(int, double *);
double __nv_rnorm3d(double, double, double);
float __nv_rnorm3df(float, float, float);
double __nv_rnorm4d(double, double, double, double);
float __nv_rnorm4df(float, float, float, float);
float __nv_rnormf(int, float *);
double __nv_round(double);
float __nv_roundf(float);
double __nv_rsqrt(double);
float __nv_rsqrtf(float);
int __nv_sad(int, int, int);
float __nv_saturatef(float);
double __nv_scalbn(double, int);
float __nv_scalbnf(float, int);
int __nv_signbitd(double);
int __nv_signbitf(float);
double __nv_sin(double);
void __nv_sincos(double, double *, double *);
void __nv_sincosf(float, float *, float *);
void __nv_sincospi(double, double *, double *);
void __nv_sincospif(float, float *, float *);
float __nv_sinf(float);
double __nv_sinh(double);
float __nv_sinhf(float);
double __nv_sinpi(double);
float __nv_sinpif(float);
double __nv_sqrt(double);
float __nv_sqrtf(float);
double __nv_tan(double);
float __nv_tanf(float);
double __nv_tanh(double);
float __nv_tanhf(float);
double __nv_tgamma(double);
float __nv_tgammaf(float);
double __nv_trunc(double);
float __nv_truncf(float);
int __nv_uhadd(int, int);
double __nv_uint2double_rn(int);
float __nv_uint2float_rd(int);
float __nv_uint2float_rn(int);
float __nv_uint2float_ru(int);
float __nv_uint2float_rz(int);
float __nv_uint_as_float(int);
double __nv_ull2double_rd(long);
double __nv_ull2double_rn(long);
double __nv_ull2double_ru(long);
double __nv_ull2double_rz(long);
float __nv_ull2float_rd(long);
float __nv_ull2float_rn(long);
float __nv_ull2float_ru(long);
float __nv_ull2float_rz(long);
long __nv_ullmax(long, long);
long __nv_ullmin(long, long);
int __nv_umax(int, int);
int __nv_umin(int, int);
int __nv_umul24(int, int);
long __nv_umul64hi(long, long);
int __nv_umulhi(int, int);
int __nv_urhadd(int, int);
int __nv_usad(int, int, int);
double __nv_y0(double);
float __nv_y0f(float);
double __nv_y1(double);
float __nv_y1f(float);
double __nv_yn(int, double);
float __nv_ynf(int, float);

#endif
