// REQUIRES: cuda
// RUN: %clangxx %s -I%opencl_include_dir -I%cuda_toolkit_include -o %t.out -lcuda -lsycl
// RUN: env SYCL_DEVICE_TYPE=GPU %t.out

//==---------- primary_context.cpp - SYCL cuda primary context test --------==//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include <CL/sycl.hpp>
#include <CL/sycl/detail/pi_cuda.hpp>
#include <cuda.h>
#include <iostream>

using namespace cl::sycl;

class other_device_selector : public default_selector {
public:

  other_device_selector(const device &dev) : exclude_device{dev} {}

  int operator()(const device &dev) const {
    if (dev == exclude_device) {
      return -1;
    }
    return default_selector::operator()(dev);
  }
private:
  const device &exclude_device;
};

int main() {
  try {
    context c;
  } catch (device_error e) {
    std::cout << "Failed to create device for context" << std::endl;
  }

  device deviceA = default_selector().select_device();
  device deviceB = other_device_selector(deviceA).select_device();
  {
    std::cout << "create single context" << std::endl;
    context Context(deviceA, async_handler{}, true);

    CUdevice cudaDevice = reinterpret_cast<pi_device>(deviceA.get())->get();
    CUcontext cudaContext = reinterpret_cast<pi_context>(Context.get())->get();

    CUcontext primaryCudaContext;
    cuDevicePrimaryCtxRetain(&primaryCudaContext, cudaDevice);

    assert(cudaContext == primaryCudaContext);

    cuDevicePrimaryCtxRelease(cudaDevice);
  }
  {
    std::cout << "create multiple contexts for one device" << std::endl;
    context Context1(deviceA, async_handler{}, true);
    context Context2(deviceA, async_handler{}, true);

    CUcontext cudaContext1 =
        reinterpret_cast<pi_context>(Context1.get())->get();
    CUcontext cudaContext2 =
        reinterpret_cast<pi_context>(Context2.get())->get();

    assert(cudaContext1 == cudaContext2);
  }
  if (deviceA != deviceB) {
    std::cout << "create multiple contexts for multiple devices" << std::endl;
    context ContextA(deviceA, async_handler{}, true);
    context ContextB(deviceB, async_handler{}, true);

    CUcontext cudaContextA =
        reinterpret_cast<pi_context>(ContextA.get())->get();
    CUcontext cudaContextB =
        reinterpret_cast<pi_context>(ContextB.get())->get();

    assert(cudaContextA != cudaContextB);
  }
}
