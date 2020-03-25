//==---------- spirv_vars.hpp --- SPIRV variables -------------------------==//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
// ===-------------------------------------------------------------------=== //

#pragma once

#ifdef __SYCL_DEVICE_ONLY__

#ifdef __SYCL_NVPTX__

SYCL_EXTERNAL size_t __spirv_GlobalInvocationId_x();
SYCL_EXTERNAL size_t __spirv_GlobalInvocationId_y();
SYCL_EXTERNAL size_t __spirv_GlobalInvocationId_z();

SYCL_EXTERNAL size_t __spirv_GlobalSize_x();
SYCL_EXTERNAL size_t __spirv_GlobalSize_y();
SYCL_EXTERNAL size_t __spirv_GlobalSize_z();

SYCL_EXTERNAL size_t __spirv_GlobalOffset_x();
SYCL_EXTERNAL size_t __spirv_GlobalOffset_y();
SYCL_EXTERNAL size_t __spirv_GlobalOffset_z();

SYCL_EXTERNAL size_t __spirv_NumWorkgroups_x();
SYCL_EXTERNAL size_t __spirv_NumWorkgroups_y();
SYCL_EXTERNAL size_t __spirv_NumWorkgroups_z();

SYCL_EXTERNAL size_t __spirv_WorkgroupSize_x();
SYCL_EXTERNAL size_t __spirv_WorkgroupSize_y();
SYCL_EXTERNAL size_t __spirv_WorkgroupSize_z();

SYCL_EXTERNAL size_t __spirv_WorkgroupId_x();
SYCL_EXTERNAL size_t __spirv_WorkgroupId_y();
SYCL_EXTERNAL size_t __spirv_WorkgroupId_z();

SYCL_EXTERNAL size_t __spirv_LocalInvocationId_x();
SYCL_EXTERNAL size_t __spirv_LocalInvocationId_y();
SYCL_EXTERNAL size_t __spirv_LocalInvocationId_z();

#else // __SYCL_NVPTX__

typedef size_t size_t_vec __attribute__((ext_vector_type(3)));
extern "C" const __attribute__((opencl_constant)) size_t_vec __spirv_BuiltInGlobalInvocationId;
extern "C" const __attribute__((opencl_constant)) size_t_vec __spirv_BuiltInGlobalSize;
extern "C" const __attribute__((opencl_constant)) size_t_vec __spirv_BuiltInGlobalOffset;
extern "C" const __attribute__((opencl_constant)) size_t_vec __spirv_BuiltInNumWorkgroups;
extern "C" const __attribute__((opencl_constant)) size_t_vec __spirv_BuiltInWorkgroupSize;
extern "C" const __attribute__((opencl_constant)) size_t_vec __spirv_BuiltInWorkgroupId;
extern "C" const __attribute__((opencl_constant)) size_t_vec __spirv_BuiltInLocalInvocationId;

SYCL_EXTERNAL inline size_t __spirv_GlobalInvocationId_x() {
  return __spirv_BuiltInGlobalInvocationId.x;
}
SYCL_EXTERNAL inline size_t __spirv_GlobalInvocationId_y() {
  return __spirv_BuiltInGlobalInvocationId.y;
}
SYCL_EXTERNAL inline size_t __spirv_GlobalInvocationId_z() {
  return __spirv_BuiltInGlobalInvocationId.z;
}

SYCL_EXTERNAL inline size_t __spirv_GlobalSize_x() {
  return __spirv_BuiltInGlobalSize.x;
}
SYCL_EXTERNAL inline size_t __spirv_GlobalSize_y() {
  return __spirv_BuiltInGlobalSize.y;
}
SYCL_EXTERNAL inline size_t __spirv_GlobalSize_z() {
  return __spirv_BuiltInGlobalSize.z;
}

SYCL_EXTERNAL inline size_t __spirv_GlobalOffset_x() {
  return __spirv_BuiltInGlobalOffset.x;
}
SYCL_EXTERNAL inline size_t __spirv_GlobalOffset_y() {
  return __spirv_BuiltInGlobalOffset.y;
}
SYCL_EXTERNAL inline size_t __spirv_GlobalOffset_z() {
  return __spirv_BuiltInGlobalOffset.z;
}

SYCL_EXTERNAL inline size_t __spirv_NumWorkgroups_x() {
  return __spirv_BuiltInNumWorkgroups.x;
}
SYCL_EXTERNAL inline size_t __spirv_NumWorkgroups_y() {
  return __spirv_BuiltInNumWorkgroups.y;
}
SYCL_EXTERNAL inline size_t __spirv_NumWorkgroups_z() {
  return __spirv_BuiltInNumWorkgroups.z;
}

SYCL_EXTERNAL inline size_t __spirv_WorkgroupSize_x() {
  return __spirv_BuiltInWorkgroupSize.x;
}
SYCL_EXTERNAL inline size_t __spirv_WorkgroupSize_y() {
  return __spirv_BuiltInWorkgroupSize.y;
}
SYCL_EXTERNAL inline size_t __spirv_WorkgroupSize_z() {
  return __spirv_BuiltInWorkgroupSize.z;
}

SYCL_EXTERNAL inline size_t __spirv_WorkgroupId_x() {
  return __spirv_BuiltInWorkgroupId.x;
}
SYCL_EXTERNAL inline size_t __spirv_WorkgroupId_y() {
  return __spirv_BuiltInWorkgroupId.y;
}
SYCL_EXTERNAL inline size_t __spirv_WorkgroupId_z() {
  return __spirv_BuiltInWorkgroupId.z;
}

SYCL_EXTERNAL inline size_t __spirv_LocalInvocationId_x() {
  return __spirv_BuiltInLocalInvocationId.x;
}
SYCL_EXTERNAL inline size_t __spirv_LocalInvocationId_y() {
  return __spirv_BuiltInLocalInvocationId.y;
}
SYCL_EXTERNAL inline size_t __spirv_LocalInvocationId_z() {
  return __spirv_BuiltInLocalInvocationId.z;
}

#endif // __SYCL_NVPTX__

#define DEFINE_FUNC_ID_TO_XYZ_CONVERTER(POSTFIX)                               \
  template <int ID> static inline size_t get##POSTFIX();                       \
  template <> size_t get##POSTFIX<0>() { return __spirv_##POSTFIX##_x(); }     \
  template <> size_t get##POSTFIX<1>() { return __spirv_##POSTFIX##_y(); }     \
  template <> size_t get##POSTFIX<2>() { return __spirv_##POSTFIX##_z(); }

namespace __spirv {

DEFINE_FUNC_ID_TO_XYZ_CONVERTER(GlobalSize);
DEFINE_FUNC_ID_TO_XYZ_CONVERTER(GlobalInvocationId);
DEFINE_FUNC_ID_TO_XYZ_CONVERTER(GlobalOffset);
DEFINE_FUNC_ID_TO_XYZ_CONVERTER(NumWorkgroups);
DEFINE_FUNC_ID_TO_XYZ_CONVERTER(WorkgroupSize);
DEFINE_FUNC_ID_TO_XYZ_CONVERTER(WorkgroupId);
DEFINE_FUNC_ID_TO_XYZ_CONVERTER(LocalInvocationId);

} // namespace __spirv

#undef DEFINE_FUNC_ID_TO_XYZ_CONVERTER

extern "C" const __attribute__((opencl_constant)) uint32_t __spirv_BuiltInSubgroupSize;
extern "C" const __attribute__((opencl_constant)) uint32_t __spirv_BuiltInSubgroupMaxSize;
extern "C" const __attribute__((opencl_constant)) uint32_t __spirv_BuiltInNumSubgroups;
extern "C" const __attribute__((opencl_constant)) uint32_t __spirv_BuiltInNumEnqueuedSubgroups;
extern "C" const __attribute__((opencl_constant)) uint32_t __spirv_BuiltInSubgroupId;
extern "C" const __attribute__((opencl_constant)) uint32_t __spirv_BuiltInSubgroupLocalInvocationId;

#define DEFINE_INIT_SIZES(POSTFIX)                                             \
                                                                               \
  template <int Dim, class DstT> struct InitSizesST##POSTFIX;                  \
                                                                               \
  template <class DstT> struct InitSizesST##POSTFIX<1, DstT> {                 \
    static DstT initSize() { return {get##POSTFIX<0>()}; }                     \
  };                                                                           \
                                                                               \
  template <class DstT> struct InitSizesST##POSTFIX<2, DstT> {                 \
    static DstT initSize() { return {get##POSTFIX<1>(), get##POSTFIX<0>()}; }  \
  };                                                                           \
                                                                               \
  template <class DstT> struct InitSizesST##POSTFIX<3, DstT> {                 \
    static DstT initSize() {                                                   \
      return {get##POSTFIX<2>(), get##POSTFIX<1>(), get##POSTFIX<0>()};        \
    }                                                                          \
  };                                                                           \
                                                                               \
  template <int Dims, class DstT> static DstT init##POSTFIX() {                \
    return InitSizesST##POSTFIX<Dims, DstT>::initSize();                       \
  }

namespace __spirv {

DEFINE_INIT_SIZES(GlobalSize);
DEFINE_INIT_SIZES(GlobalInvocationId)
DEFINE_INIT_SIZES(WorkgroupSize)
DEFINE_INIT_SIZES(NumWorkgroups)
DEFINE_INIT_SIZES(LocalInvocationId)
DEFINE_INIT_SIZES(WorkgroupId)
DEFINE_INIT_SIZES(GlobalOffset)

} // namespace __spirv

#undef DEFINE_INIT_SIZES

#endif // __SYCL_DEVICE_ONLY__
