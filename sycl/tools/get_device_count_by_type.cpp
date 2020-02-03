//==-- get_device_count_by_type.cpp - Get device count by type -------------==//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include <CL/cl.h>
#include <CL/cl_ext.h>

#include <cstdlib>

#ifdef USE_PI_CUDA
#include <cuda_device_runtime_api.h>
#include <cuda.h>
#endif // USE_PI_CUDA

#include <iostream>
#include <sstream>
#include <string>
#include <vector>

static const std::string help =
    "   Help\n"
    "   Example: ./get_device_count_by_type cpu opencl\n"
    "   Support types: cpu/gpu/accelerator/default/all\n"
    "   Support backends: cuda/opencl \n"
    "   Output format: <number_of_devices>:<additional_Information>";

const char *deviceTypeToString(cl_device_type deviceType) {
  const char *str = "unknown";
  switch (deviceType) {
  case CL_DEVICE_TYPE_CPU:
    str = "cpu";
    break;
  case CL_DEVICE_TYPE_GPU:
    str = "gpu";
    break;
  case CL_DEVICE_TYPE_ACCELERATOR:
    str = "accelerator";
    break;
  case CL_DEVICE_TYPE_CUSTOM:
    str = "custom";
    break;
  case CL_DEVICE_TYPE_DEFAULT:
    str = "default";
    break;
  case CL_DEVICE_TYPE_ALL:
    str = "all";
    break;
  default:
    // str already set to express unknown device type.
    break;
  }

  return str;
}

static bool queryOpenCL(cl_device_type deviceType, cl_uint &deviceCount,
                        std::string &msg) {
  deviceCount = 0u;
  cl_int iRet = CL_SUCCESS;
  cl_uint platformCount = 0;

  iRet = clGetPlatformIDs(0, nullptr, &platformCount);
  if (iRet != CL_SUCCESS) {
    if (iRet == CL_PLATFORM_NOT_FOUND_KHR) {
      msg = "OpenCL error runtime not found";
    } else {
      std::stringstream stream;
      stream << "OpenCL error calling clGetPlatformIDs " << iRet << std::endl;
      msg = stream.str();
    }
    return false;
  }

  std::vector<cl_platform_id> platforms(platformCount);
  iRet = clGetPlatformIDs(platformCount, &platforms[0], nullptr);
  if (iRet != CL_SUCCESS) {
    std::stringstream stream;
    stream << "OpenCL error calling clGetPlatformIDs " << iRet << std::endl;
    msg = stream.str();
    return false;
  }

  for (cl_uint i = 0; i < platformCount; i++) {
    cl_uint deviceCountPart = 0;
    iRet =
        clGetDeviceIDs(platforms[i], deviceType, 0, nullptr, &deviceCountPart);
    if (iRet == CL_SUCCESS || iRet == CL_DEVICE_NOT_FOUND) {
      deviceCount += deviceCountPart;
    } else {
      deviceCount = 0u;
      std::stringstream stream;
      stream << "OpenCL error calling clGetDeviceIDs " << iRet << std::endl;
      msg = stream.str();
      return false;
    }
  }

  msg = "opencl ";
  msg += deviceTypeToString(deviceType);
  return true;
}

static bool queryCUDA(cl_device_type deviceType, cl_uint &deviceCount,
                      std::string &msg) {
  deviceCount = 0u;
#ifdef USE_PI_CUDA
  const unsigned int defaultFlag = 0;
  CUresult err = cuInit(defaultFlag);
  if (err != CUDA_SUCCESS) {
    msg = "CUDA initialization error";
    return false;
  }

  const int minRuntimeVersion = 10010;
  int runtimeVersion = 0;
  err = cuDriverGetVersion(&runtimeVersion);
  if (err != CUDA_SUCCESS) {
    msg = "CUDA error querying driver version";
    return false;
  }

  if (runtimeVersion < minRuntimeVersion) {
    std::stringstream stream;
    stream << "CUDA version not supported " << runtimeVersion;
    msg = stream.str();
    return false;
  }

  switch (deviceType) {
  case CL_DEVICE_TYPE_DEFAULT: // Fall through.
  case CL_DEVICE_TYPE_ALL:     // Fall through.
  case CL_DEVICE_TYPE_GPU: {
    int count = 0;
    CUresult err = cuDeviceGetCount(&count);
    if (err != CUDA_SUCCESS || count < 0) {
      msg = "CUDA error querying device count";
      return false;
    }

    deviceCount = static_cast<cl_uint>(count);
    msg = "cuda ";
    msg += deviceTypeToString(deviceType);
    return true;
  } break;
  default:
    msg = "CUDA unsupported device type ";
    msg += deviceTypeToString(deviceType);
    return false;
  }
#else
  msg = "CUDA not supported";
  deviceCount = 0u;

  return false;
#endif
}

int main(int argc, char *argv[]) {
  if (argc < 3) {
    std::cout << "0:Please set a device type and backend to find" << std::endl
              << help << std::endl;
    return EXIT_FAILURE;
  }

  std::string type = argv[1];
  std::string backend{argv[2]};

  cl_device_type deviceType = CL_DEVICE_TYPE_DEFAULT;
  if (type == "cpu") {
    deviceType = CL_DEVICE_TYPE_CPU;
  } else if (type == "gpu") {
    deviceType = CL_DEVICE_TYPE_GPU;
  } else if (type == "accelerator") {
    deviceType = CL_DEVICE_TYPE_ACCELERATOR;
  } else if (type == "default") {
    deviceType = CL_DEVICE_TYPE_DEFAULT;
  } else if (type == "all") {
    deviceType = CL_DEVICE_TYPE_ALL;
  } else {
    std::cout << "0:Incorrect device type " << type << "\n"
              << help << std::endl;
    return EXIT_FAILURE;
  }

  std::string msg;
  cl_uint deviceCount = 0;

  bool querySuccess = false;

  if (backend == "opencl" || backend == "OpenCL" || backend == "OPENCL" ||
      backend == "PI_OPENCL") {
    querySuccess = queryOpenCL(deviceType, deviceCount, msg);
  } else if (backend == "cuda" || backend == "CUDA" || backend == "PI_CUDA") {
    querySuccess = queryCUDA(deviceType, deviceCount, msg);
  } else {
    std::stringstream stream;
    stream << "Unknown backend" << backend << "\n" << help << std::endl;
    msg = stream.str();
  }

  std::cout << deviceCount << ":" << msg << std::endl;

  if (!querySuccess) {
    return EXIT_FAILURE;
  }

  return EXIT_SUCCESS;
}
