; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=aarch64-linux-gnu -mattr=+sve < %s | FileCheck %s

; These tests are here to ensure we don't get a selection error caused
; by performPostLD1Combine, which should bail out if the return
; type is a scalable vector

define <vscale x 4 x i32> @test_post_ld1_insert(i32* %a, i32** %ptr, i64 %inc) {
; CHECK-LABEL: test_post_ld1_insert:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ldr w8, [x0]
; CHECK-NEXT:    add x9, x0, x2, lsl #2
; CHECK-NEXT:    str x9, [x1]
; CHECK-NEXT:    fmov s0, w8
; CHECK-NEXT:    ret
  %load = load i32, i32* %a
  %ins = insertelement <vscale x 4 x i32> undef, i32 %load, i32 0
  %gep = getelementptr i32, i32* %a, i64 %inc
  store i32* %gep, i32** %ptr
  ret <vscale x 4 x i32> %ins
}

define <vscale x 2 x double> @test_post_ld1_dup(double* %a, double** %ptr, i64 %inc) {
; CHECK-LABEL: test_post_ld1_dup:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ldr d0, [x0]
; CHECK-NEXT:    add x8, x0, x2, lsl #3
; CHECK-NEXT:    mov z0.d, d0
; CHECK-NEXT:    str x8, [x1]
; CHECK-NEXT:    ret
  %load = load double, double* %a
  %dup = call <vscale x 2 x double> @llvm.aarch64.sve.dup.x.nxv2f64(double %load)
  %gep = getelementptr double, double* %a, i64 %inc
  store double* %gep, double** %ptr
  ret <vscale x 2 x double> %dup
}

declare <vscale x 2 x double> @llvm.aarch64.sve.dup.x.nxv2f64(double)
