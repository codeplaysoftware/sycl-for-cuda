//==---- test_base_objects.cpp --- PI unit tests ---------------------------==//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "gtest/gtest.h"

#include <cuda.h>

#include <CL/sycl.hpp>
#include <CL/sycl/backend/cuda.hpp>
#include <CL/sycl/detail/pi.hpp>
#include <pi_cuda.hpp>
#include <thread>

const unsigned int LATEST_KNOWN_CUDA_DRIVER_API_VERSION = 3020u;

using namespace cl::sycl;

class DISABLED_CudaBaseObjectsTest : public ::testing::Test {
protected:

  DISABLED_CudaBaseObjectsTest() { detail::pi::initialize(); }

  ~DISABLED_CudaBaseObjectsTest() = default;
};

TEST_F(DISABLED_CudaBaseObjectsTest, piContextCreate) {
  pi_uint32 numPlatforms = 0;
  pi_platform platform = nullptr;
  pi_device device;

  ASSERT_EQ((PI_CALL_NOCHECK(piPlatformsGet)(0, nullptr, &numPlatforms)),
            PI_SUCCESS)
      << "piPlatformsGet failed.\n";

  ASSERT_EQ(
      (PI_CALL_NOCHECK(piPlatformsGet)(numPlatforms, &platform, nullptr)),
      PI_SUCCESS)
      << "piPlatformsGet failed.\n";

  ASSERT_GE(numPlatforms, 1u);
  ASSERT_NE(platform, nullptr);

  ASSERT_EQ((PI_CALL_NOCHECK(piDevicesGet)(platform, PI_DEVICE_TYPE_GPU, 1, &device, nullptr)),
              PI_SUCCESS) << "piDevicesGet failed.\n";

  pi_context ctxt = nullptr;
  ASSERT_EQ((PI_CALL_NOCHECK(piContextCreate)(nullptr, 1, &device, nullptr, nullptr, &ctxt)), PI_SUCCESS) << "piContextCreate failed.\n";

  EXPECT_NE(ctxt, nullptr);
  EXPECT_EQ(ctxt->get_device(), device);

  // Retrieve the cuCtxt to check information is correct
  CUcontext cudaContext = ctxt->get();
  unsigned int version = 0;
  cuCtxGetApiVersion(cudaContext, &version);
  EXPECT_EQ(version, LATEST_KNOWN_CUDA_DRIVER_API_VERSION);

  CUresult cuErr = cuCtxDestroy(cudaContext);
  ASSERT_EQ(cuErr, CUDA_SUCCESS);
}

TEST_F(DISABLED_CudaBaseObjectsTest, piContextCreatePrimary) {
  pi_uint32 numPlatforms = 0;
  pi_platform platform;
  pi_device device;

  ASSERT_EQ((PI_CALL_NOCHECK(piPlatformsGet)(0, nullptr, &numPlatforms)),
            PI_SUCCESS)
      << "piPlatformsGet failed.\n";

  ASSERT_EQ(
      (PI_CALL_NOCHECK(piPlatformsGet)(numPlatforms, &platform, nullptr)),
      PI_SUCCESS)
      << "piPlatformsGet failed.\n";

  ASSERT_EQ((PI_CALL_NOCHECK(piDevicesGet)(platform, PI_DEVICE_TYPE_GPU, 1, &device, nullptr)), PI_SUCCESS);
  cl_context_properties properties = PI_CONTEXT_PROPERTIES_CUDA_PRIMARY;

  pi_context ctxt;
  ASSERT_EQ((PI_CALL_NOCHECK(piContextCreate)(&properties, 1, &device, nullptr, nullptr,
                                      &ctxt)), PI_SUCCESS);
  EXPECT_NE(ctxt, nullptr);
  EXPECT_EQ(ctxt->get_device(), device);
  EXPECT_TRUE(ctxt->is_primary());

  // Retrieve the cuCtxt to check information is correct
  CUcontext cudaContext = ctxt->get();
  unsigned int version = 0;
  CUresult cuErr = cuCtxGetApiVersion(cudaContext, &version);
  ASSERT_EQ(cuErr, CUDA_SUCCESS);
  EXPECT_EQ(version, LATEST_KNOWN_CUDA_DRIVER_API_VERSION);

  // Current context in the stack?
  CUcontext current;
  cuErr = cuCtxGetCurrent(&current);
  ASSERT_EQ(cuErr, CUDA_SUCCESS);
  ASSERT_EQ(current, cudaContext);
  ASSERT_EQ((PI_CALL_NOCHECK(piContextRelease)(ctxt)), PI_SUCCESS);
}

TEST_F(DISABLED_CudaBaseObjectsTest, piContextCreateChildThread) {
  pi_uint32 numPlatforms = 0;
  pi_platform platform;
  pi_device device;

  ASSERT_EQ((PI_CALL_NOCHECK(piPlatformsGet)(0, nullptr, &numPlatforms)),
            PI_SUCCESS)
      << "piPlatformsGet failed.\n";

  ASSERT_EQ(
      (PI_CALL_NOCHECK(piPlatformsGet)(numPlatforms, &platform, nullptr)),
      PI_SUCCESS)
      << "piPlatformsGet failed.\n";

  ASSERT_EQ((PI_CALL_NOCHECK(
      piDevicesGet)(platform, PI_DEVICE_TYPE_GPU, 1, &device, nullptr)), PI_SUCCESS);

  pi_context ctxt;
  ASSERT_EQ((PI_CALL_NOCHECK(piContextCreate)(nullptr, 1, &device, nullptr, nullptr, &ctxt)), PI_SUCCESS);
  EXPECT_NE(ctxt, nullptr);

  // Retrieve the cuCtxt to check information is correct
  auto checkValue = [=]() {
    CUcontext cudaContext = ctxt->get();
    unsigned int version = 0;
    auto cuErr = cuCtxGetApiVersion(cudaContext, &version);
    EXPECT_EQ(cuErr, CUDA_SUCCESS);
    EXPECT_EQ(version, LATEST_KNOWN_CUDA_DRIVER_API_VERSION);

    // The current context is different from the current thread
    CUcontext current;
    cuErr = cuCtxGetCurrent(&current);
    EXPECT_EQ(cuErr, CUDA_SUCCESS);
    EXPECT_NE(cudaContext, current);

    // Set the context from PI API as the current one
    cuErr = cuCtxPushCurrent(cudaContext);
    EXPECT_EQ(cuErr, CUDA_SUCCESS);

    cuErr = cuCtxGetCurrent(&current);
    EXPECT_EQ(cuErr, CUDA_SUCCESS);
    EXPECT_EQ(cudaContext, current);
  };
  auto callContextFromOtherThread = std::thread(checkValue);

  callContextFromOtherThread.join();

  ASSERT_EQ((PI_CALL_NOCHECK(piContextRelease)(ctxt)), PI_SUCCESS);
}
