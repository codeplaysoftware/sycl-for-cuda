// RUN: %clang_cc1 -fdeclare-spirv-builtins -fsycl-is-device -fsyntax-only -verify -std=c++11 %s

// Verify that invalid call to __spv_GroupAsyncCopy (no viable overloads) get diagnosed

void async_copy([[clang::opencl_global]] int *ptr_to_global,
                [[clang::opencl_local]] int *ptr_to_local) {
  // wrong address spaces
  __spirv_GroupAsyncCopy(0, ptr_to_global, ptr_to_global, 0, 0, 0); // expected-error {{no matching function for call to '__spirv_GroupAsyncCopy'}}
  // expected-note@-1 + {{candidate function not viable: cannot pass pointer to address space}}
  // expected-note@-2 + {{candidate function not viable: no known conversion from}}
  // too many params
  __spirv_GroupAsyncCopy(0, ptr_to_global, ptr_to_local, 0, 0, 0, 0); // expected-error {{no matching function for call to '__spirv_GroupAsyncCopy'}}
  // expected-note@-1 + {{candidate function not viable: requires 6 arguments, but 7 were provided}}
}
