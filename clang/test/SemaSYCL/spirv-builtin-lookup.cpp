// RUN: %clang_cc1 -fdeclare-spirv-builtins -fsycl-is-device -fsyntax-only -verify -std=c++11 %s
// expected-no-diagnostics

// Verify that __spv_GroupAsyncCopy overload is recognize as a builtin

void async_copy([[clang::opencl_global]] int *ptr_to_global,
                [[clang::opencl_local]] int *ptr_to_local) {
  __spirv_GroupAsyncCopy(0, ptr_to_local, ptr_to_global, 0, 0, 0);
  __spirv_GroupAsyncCopy(0, ptr_to_global, ptr_to_local, 0, 0, 0);
}

void async_copy([[clang::opencl_global]] char *ptr_to_global,
                [[clang::opencl_local]] char *ptr_to_local) {
  __spirv_GroupAsyncCopy(0, ptr_to_local, ptr_to_global, 0, 0, 0);
  __spirv_GroupAsyncCopy(0, ptr_to_global, ptr_to_local, 0, 0, 0);
}
