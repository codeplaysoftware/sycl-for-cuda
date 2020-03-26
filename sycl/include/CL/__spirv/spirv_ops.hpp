//==---------- spirv_ops.hpp --- SPIRV operations -------------------------==//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#pragma once
#include <CL/__spirv/spirv_types.hpp>
#include <CL/sycl/detail/defines.hpp>
#include <cstddef>
#include <cstdint>
#include <type_traits>

// Convergent attribute
#ifdef __SYCL_DEVICE_ONLY__
#define __SYCL_CONVERGENT__ __attribute__((convergent))
#else
#define __SYCL_CONVERGENT__
#endif

#ifdef __SYCL_DEVICE_ONLY__

#ifndef __SPIRV_BUILTIN_DECLARATIONS__
#error                                                                         \
    "SPIR-V built-ins are not available. Please set -fdeclare-spirv-builtins flag."
#endif

template <typename RetT, typename ImageT>
extern SYCL_EXTERNAL RetT __spirv_ImageQueryFormat(ImageT);

template <typename RetT, typename ImageT>
extern SYCL_EXTERNAL RetT __spirv_ImageQueryOrder(ImageT);

template <typename RetT, typename ImageT>
extern SYCL_EXTERNAL RetT __spirv_ImageQuerySize(ImageT);

template <typename ImageT, typename CoordT, typename ValT>
extern SYCL_EXTERNAL void __spirv_ImageWrite(ImageT, CoordT, ValT);

template <class RetT, typename ImageT, typename TempArgT>
extern SYCL_EXTERNAL RetT __spirv_ImageRead(ImageT, TempArgT);

template <typename ImageT, typename SampledType>
extern SYCL_EXTERNAL SampledType __spirv_SampledImage(ImageT, __ocl_sampler_t);

template <typename SampledType, typename TempRetT, typename TempArgT>
extern SYCL_EXTERNAL TempRetT __spirv_ImageSampleExplicitLod(SampledType,
                                                             TempArgT, int,
                                                             float);

#define OpGroupAsyncCopyGlobalToLocal __spirv_GroupAsyncCopy
#define OpGroupAsyncCopyLocalToGlobal __spirv_GroupAsyncCopy

template <typename dataT>
__SYCL_CONVERGENT__ extern SYCL_EXTERNAL dataT
__spirv_SubgroupShuffleINTEL(dataT Data, uint32_t InvocationId) noexcept;
template <typename dataT>
__SYCL_CONVERGENT__ extern SYCL_EXTERNAL dataT __spirv_SubgroupShuffleDownINTEL(
    dataT Current, dataT Next, uint32_t Delta) noexcept;
template <typename dataT>
__SYCL_CONVERGENT__ extern SYCL_EXTERNAL dataT __spirv_SubgroupShuffleUpINTEL(
    dataT Previous, dataT Current, uint32_t Delta) noexcept;
template <typename dataT>
__SYCL_CONVERGENT__ extern SYCL_EXTERNAL dataT
__spirv_SubgroupShuffleXorINTEL(dataT Data, uint32_t Value) noexcept;

template <typename dataT>
__SYCL_CONVERGENT__ extern SYCL_EXTERNAL dataT __spirv_SubgroupBlockReadINTEL(
    const __attribute__((opencl_global)) uint8_t *Ptr) noexcept;

template <typename dataT>
__SYCL_CONVERGENT__ extern SYCL_EXTERNAL void
__spirv_SubgroupBlockWriteINTEL(__attribute__((opencl_global)) uint8_t *Ptr,
                                dataT Data) noexcept;

template <typename dataT>
__SYCL_CONVERGENT__ extern SYCL_EXTERNAL dataT __spirv_SubgroupBlockReadINTEL(
    const __attribute__((opencl_global)) uint16_t *Ptr) noexcept;

template <typename dataT>
__SYCL_CONVERGENT__ extern SYCL_EXTERNAL void
__spirv_SubgroupBlockWriteINTEL(__attribute__((opencl_global)) uint16_t *Ptr,
                                dataT Data) noexcept;

template <typename dataT>
__SYCL_CONVERGENT__ extern SYCL_EXTERNAL dataT __spirv_SubgroupBlockReadINTEL(
    const __attribute__((opencl_global)) uint32_t *Ptr) noexcept;

template <typename dataT>
__SYCL_CONVERGENT__ extern SYCL_EXTERNAL void
__spirv_SubgroupBlockWriteINTEL(__attribute__((opencl_global)) uint32_t *Ptr,
                                dataT Data) noexcept;

template <typename dataT>
extern SYCL_EXTERNAL int32_t __spirv_ReadPipe(RPipeTy<dataT> Pipe, dataT *Data,
                                              int32_t Size,
                                              int32_t Alignment) noexcept;
template <typename dataT>
extern SYCL_EXTERNAL int32_t __spirv_WritePipe(WPipeTy<dataT> Pipe,
                                               const dataT *Data, int32_t Size,
                                               int32_t Alignment) noexcept;
template <typename dataT>
extern SYCL_EXTERNAL void
__spirv_ReadPipeBlockingINTEL(RPipeTy<dataT> Pipe, dataT *Data, int32_t Size,
                              int32_t Alignment) noexcept;
template <typename dataT>
extern SYCL_EXTERNAL void
__spirv_WritePipeBlockingINTEL(WPipeTy<dataT> Pipe, const dataT *Data,
                               int32_t Size, int32_t Alignment) noexcept;
template <typename dataT>
extern SYCL_EXTERNAL RPipeTy<dataT> __spirv_CreatePipeFromPipeStorage_read(
    const ConstantPipeStorage *Storage) noexcept;
template <typename dataT>
extern SYCL_EXTERNAL WPipeTy<dataT> __spirv_CreatePipeFromPipeStorage_write(
    const ConstantPipeStorage *Storage) noexcept;

extern SYCL_EXTERNAL void
__spirv_ocl_prefetch(const __attribute__((opencl_global)) char *Ptr,
                     size_t NumBytes) noexcept;

#else // if !__SYCL_DEVICE_ONLY__

template <typename dataT>
__SYCL_CONVERGENT__ extern __ocl_event_t
OpGroupAsyncCopyGlobalToLocal(__spv::Scope::Flag Execution, dataT *Dest,
                              dataT *Src, size_t NumElements, size_t Stride,
                              __ocl_event_t E) noexcept {
  for (size_t i = 0; i < NumElements; i++) {
    Dest[i] = Src[i * Stride];
  }
  // A real instance of the class is not needed, return dummy pointer.
  return nullptr;
}

template <typename dataT>
__SYCL_CONVERGENT__ extern __ocl_event_t
OpGroupAsyncCopyLocalToGlobal(__spv::Scope::Flag Execution, dataT *Dest,
                              dataT *Src, size_t NumElements, size_t Stride,
                              __ocl_event_t E) noexcept {
  for (size_t i = 0; i < NumElements; i++) {
    Dest[i * Stride] = Src[i];
  }
  // A real instance of the class is not needed, return dummy pointer.
  return nullptr;
}

extern void __spirv_ocl_prefetch(const char *Ptr, size_t NumBytes) noexcept;

__SYCL_CONVERGENT__ extern SYCL_EXTERNAL void
__spirv_ControlBarrier(__spv::Scope Execution, __spv::Scope Memory,
                       uint32_t Semantics) noexcept;

__SYCL_CONVERGENT__ extern SYCL_EXTERNAL void
__spirv_MemoryBarrier(__spv::Scope Memory, uint32_t Semantics) noexcept;

__SYCL_CONVERGENT__ extern SYCL_EXTERNAL void
__spirv_GroupWaitEvents(__spv::Scope Execution, uint32_t NumEvents,
                        __ocl_event_t *WaitEvents) noexcept;

#endif // !__SYCL_DEVICE_ONLY__
