// RUN: %clang_cc1 -triple x86_64-unknown-linux-gnu -fdeclare-spirv-builtins -fsyntax-only -emit-llvm %s -o - | FileCheck %s

float acos(float val) {
  // CHECK: @_Z4acosf
  // CHECK: call float @__spirv_ocl_acos.f32.f32
  return __spirv_ocl_acos(val);
}

// CHECK: declare float @__spirv_ocl_acos.f32.f32(float)

double acos(double val) {
  // CHECK: @_Z4acosd
  // CHECK: call double @__spirv_ocl_acos.f64.f64
  return __spirv_ocl_acos(val);
}

// CHECK: declare double @__spirv_ocl_acos.f64.f64(double)
