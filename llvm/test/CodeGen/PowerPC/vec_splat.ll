; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -verify-machineinstrs < %s -mtriple=ppc32-- -mcpu=g3 | FileCheck %s --check-prefixes=ALL,G3
; RUN: llc -verify-machineinstrs < %s -mtriple=ppc32-- -mcpu=g5 | FileCheck %s --check-prefixes=ALL,G5

; Test that vectors are scalarized/lowered correctly.

%f4 = type <4 x float>
%i4 = type <4 x i32>

define void @splat(%f4* %P, %f4* %Q, float %X) nounwind {
; G3-LABEL: splat:
; G3:       # %bb.0:
; G3-NEXT:    lfs 0, 12(4)
; G3-NEXT:    lfs 2, 8(4)
; G3-NEXT:    lfs 3, 4(4)
; G3-NEXT:    fadds 0, 0, 1
; G3-NEXT:    lfs 4, 0(4)
; G3-NEXT:    stfs 0, 12(3)
; G3-NEXT:    fadds 0, 2, 1
; G3-NEXT:    stfs 0, 8(3)
; G3-NEXT:    fadds 0, 3, 1
; G3-NEXT:    stfs 0, 4(3)
; G3-NEXT:    fadds 0, 4, 1
; G3-NEXT:    stfs 0, 0(3)
; G3-NEXT:    blr
;
; G5-LABEL: splat:
; G5:       # %bb.0:
; G5-NEXT:    stwu 1, -32(1)
; G5-NEXT:    stfs 1, 16(1)
; G5-NEXT:    addi 5, 1, 16
; G5-NEXT:    lvx 2, 0, 5
; G5-NEXT:    lvx 3, 0, 4
; G5-NEXT:    vspltw 2, 2, 0
; G5-NEXT:    vaddfp 2, 3, 2
; G5-NEXT:    stvx 2, 0, 3
; G5-NEXT:    addi 1, 1, 32
; G5-NEXT:    blr
  %tmp = insertelement %f4 undef, float %X, i32 0   ; <%f4> [#uses=1]
  %tmp2 = insertelement %f4 %tmp, float %X, i32 1   ; <%f4> [#uses=1]
  %tmp4 = insertelement %f4 %tmp2, float %X, i32 2    ; <%f4> [#uses=1]
  %tmp6 = insertelement %f4 %tmp4, float %X, i32 3    ; <%f4> [#uses=1]
  %q = load %f4, %f4* %Q         ; <%f4> [#uses=1]
  %R = fadd %f4 %q, %tmp6    ; <%f4> [#uses=1]
  store %f4 %R, %f4* %P
  ret void
}

define void @splat_i4(%i4* %P, %i4* %Q, i32 %X) nounwind {
; G3-LABEL: splat_i4:
; G3:       # %bb.0:
; G3-NEXT:    lwz 6, 12(4)
; G3-NEXT:    lwz 7, 8(4)
; G3-NEXT:    lwz 8, 4(4)
; G3-NEXT:    add 6, 6, 5
; G3-NEXT:    lwz 4, 0(4)
; G3-NEXT:    stw 6, 12(3)
; G3-NEXT:    add 6, 7, 5
; G3-NEXT:    stw 6, 8(3)
; G3-NEXT:    add 6, 8, 5
; G3-NEXT:    add 4, 4, 5
; G3-NEXT:    stw 6, 4(3)
; G3-NEXT:    stw 4, 0(3)
; G3-NEXT:    blr
;
; G5-LABEL: splat_i4:
; G5:       # %bb.0:
; G5-NEXT:    stwu 1, -32(1)
; G5-NEXT:    stw 5, 16(1)
; G5-NEXT:    addi 5, 1, 16
; G5-NEXT:    lvx 2, 0, 5
; G5-NEXT:    lvx 3, 0, 4
; G5-NEXT:    vspltw 2, 2, 0
; G5-NEXT:    vadduwm 2, 3, 2
; G5-NEXT:    stvx 2, 0, 3
; G5-NEXT:    addi 1, 1, 32
; G5-NEXT:    blr
  %tmp = insertelement %i4 undef, i32 %X, i32 0     ; <%i4> [#uses=1]
  %tmp2 = insertelement %i4 %tmp, i32 %X, i32 1     ; <%i4> [#uses=1]
  %tmp4 = insertelement %i4 %tmp2, i32 %X, i32 2    ; <%i4> [#uses=1]
  %tmp6 = insertelement %i4 %tmp4, i32 %X, i32 3    ; <%i4> [#uses=1]
  %q = load %i4, %i4* %Q         ; <%i4> [#uses=1]
  %R = add %i4 %q, %tmp6    ; <%i4> [#uses=1]
  store %i4 %R, %i4* %P
  ret void
}

define void @splat_imm_i32(%i4* %P, %i4* %Q, i32 %X) nounwind {
; G3-LABEL: splat_imm_i32:
; G3:       # %bb.0:
; G3-NEXT:    lwz 5, 12(4)
; G3-NEXT:    lwz 6, 8(4)
; G3-NEXT:    lwz 7, 4(4)
; G3-NEXT:    addi 5, 5, -1
; G3-NEXT:    lwz 4, 0(4)
; G3-NEXT:    stw 5, 12(3)
; G3-NEXT:    addi 5, 6, -1
; G3-NEXT:    stw 5, 8(3)
; G3-NEXT:    addi 5, 7, -1
; G3-NEXT:    addi 4, 4, -1
; G3-NEXT:    stw 5, 4(3)
; G3-NEXT:    stw 4, 0(3)
; G3-NEXT:    blr
;
; G5-LABEL: splat_imm_i32:
; G5:       # %bb.0:
; G5-NEXT:    lvx 2, 0, 4
; G5-NEXT:    vspltisb 3, -1
; G5-NEXT:    vadduwm 2, 2, 3
; G5-NEXT:    stvx 2, 0, 3
; G5-NEXT:    blr
  %q = load %i4, %i4* %Q         ; <%i4> [#uses=1]
  %R = add %i4 %q, < i32 -1, i32 -1, i32 -1, i32 -1 >       ; <%i4> [#uses=1]
  store %i4 %R, %i4* %P
  ret void
}

define void @splat_imm_i16(%i4* %P, %i4* %Q, i32 %X) nounwind {
; G3-LABEL: splat_imm_i16:
; G3:       # %bb.0:
; G3-NEXT:    lwz 5, 8(4)
; G3-NEXT:    lwz 6, 0(4)
; G3-NEXT:    lwz 7, 4(4)
; G3-NEXT:    addi 5, 5, 1
; G3-NEXT:    lwz 4, 12(4)
; G3-NEXT:    addi 6, 6, 1
; G3-NEXT:    addi 7, 7, 1
; G3-NEXT:    addi 4, 4, 1
; G3-NEXT:    addis 4, 4, 1
; G3-NEXT:    stw 4, 12(3)
; G3-NEXT:    addis 4, 5, 1
; G3-NEXT:    stw 4, 8(3)
; G3-NEXT:    addis 4, 7, 1
; G3-NEXT:    stw 4, 4(3)
; G3-NEXT:    addis 4, 6, 1
; G3-NEXT:    stw 4, 0(3)
; G3-NEXT:    blr
;
; G5-LABEL: splat_imm_i16:
; G5:       # %bb.0:
; G5-NEXT:    lvx 2, 0, 4
; G5-NEXT:    vspltish 3, 1
; G5-NEXT:    vadduwm 2, 2, 3
; G5-NEXT:    stvx 2, 0, 3
; G5-NEXT:    blr
  %q = load %i4, %i4* %Q         ; <%i4> [#uses=1]
  %R = add %i4 %q, < i32 65537, i32 65537, i32 65537, i32 65537 >   ; <%i4> [#uses=1]
  store %i4 %R, %i4* %P
  ret void
}

define void @splat_h(i16 %tmp, <16 x i8>* %dst) nounwind {
; G3-LABEL: splat_h:
; G3:       # %bb.0:
; G3-NEXT:    sth 3, 14(4)
; G3-NEXT:    sth 3, 12(4)
; G3-NEXT:    sth 3, 10(4)
; G3-NEXT:    sth 3, 8(4)
; G3-NEXT:    sth 3, 6(4)
; G3-NEXT:    sth 3, 4(4)
; G3-NEXT:    sth 3, 2(4)
; G3-NEXT:    sth 3, 0(4)
; G3-NEXT:    blr
;
; G5-LABEL: splat_h:
; G5:       # %bb.0:
; G5-NEXT:    stwu 1, -32(1)
; G5-NEXT:    sth 3, 16(1)
; G5-NEXT:    addi 3, 1, 16
; G5-NEXT:    lvx 2, 0, 3
; G5-NEXT:    vsplth 2, 2, 0
; G5-NEXT:    stvx 2, 0, 4
; G5-NEXT:    addi 1, 1, 32
; G5-NEXT:    blr
  %tmp.upgrd.1 = insertelement <8 x i16> undef, i16 %tmp, i32 0
  %tmp72 = insertelement <8 x i16> %tmp.upgrd.1, i16 %tmp, i32 1
  %tmp73 = insertelement <8 x i16> %tmp72, i16 %tmp, i32 2
  %tmp74 = insertelement <8 x i16> %tmp73, i16 %tmp, i32 3
  %tmp75 = insertelement <8 x i16> %tmp74, i16 %tmp, i32 4
  %tmp76 = insertelement <8 x i16> %tmp75, i16 %tmp, i32 5
  %tmp77 = insertelement <8 x i16> %tmp76, i16 %tmp, i32 6
  %tmp78 = insertelement <8 x i16> %tmp77, i16 %tmp, i32 7
  %tmp78.upgrd.2 = bitcast <8 x i16> %tmp78 to <16 x i8>
  store <16 x i8> %tmp78.upgrd.2, <16 x i8>* %dst
  ret void
}

define void @spltish(<16 x i8>* %A, <16 x i8>* %B) nounwind {
; G3-LABEL: spltish:
; G3:       # %bb.0:
; G3-NEXT:    stwu 1, -48(1)
; G3-NEXT:    stw 30, 40(1) # 4-byte Folded Spill
; G3-NEXT:    lbz 5, 0(4)
; G3-NEXT:    lbz 30, 15(4)
; G3-NEXT:    stw 29, 36(1) # 4-byte Folded Spill
; G3-NEXT:    lbz 29, 13(4)
; G3-NEXT:    stw 28, 32(1) # 4-byte Folded Spill
; G3-NEXT:    lbz 28, 11(4)
; G3-NEXT:    stw 27, 28(1) # 4-byte Folded Spill
; G3-NEXT:    lbz 27, 9(4)
; G3-NEXT:    stw 24, 16(1) # 4-byte Folded Spill
; G3-NEXT:    stw 25, 20(1) # 4-byte Folded Spill
; G3-NEXT:    stw 26, 24(1) # 4-byte Folded Spill
; G3-NEXT:    lbz 6, 2(4)
; G3-NEXT:    lbz 7, 4(4)
; G3-NEXT:    lbz 8, 6(4)
; G3-NEXT:    lbz 9, 8(4)
; G3-NEXT:    lbz 10, 10(4)
; G3-NEXT:    lbz 11, 12(4)
; G3-NEXT:    lbz 12, 14(4)
; G3-NEXT:    lbz 26, 7(4)
; G3-NEXT:    lbz 25, 5(4)
; G3-NEXT:    lbz 24, 3(4)
; G3-NEXT:    lbz 4, 1(4)
; G3-NEXT:    stb 5, 0(3)
; G3-NEXT:    addi 5, 30, -15
; G3-NEXT:    stb 5, 15(3)
; G3-NEXT:    addi 5, 29, -15
; G3-NEXT:    stb 5, 13(3)
; G3-NEXT:    addi 5, 28, -15
; G3-NEXT:    stb 5, 11(3)
; G3-NEXT:    addi 5, 27, -15
; G3-NEXT:    stb 5, 9(3)
; G3-NEXT:    addi 5, 26, -15
; G3-NEXT:    stb 5, 7(3)
; G3-NEXT:    addi 5, 25, -15
; G3-NEXT:    stb 5, 5(3)
; G3-NEXT:    addi 5, 24, -15
; G3-NEXT:    addi 4, 4, -15
; G3-NEXT:    stb 12, 14(3)
; G3-NEXT:    stb 11, 12(3)
; G3-NEXT:    stb 10, 10(3)
; G3-NEXT:    stb 9, 8(3)
; G3-NEXT:    stb 8, 6(3)
; G3-NEXT:    stb 7, 4(3)
; G3-NEXT:    stb 6, 2(3)
; G3-NEXT:    stb 5, 3(3)
; G3-NEXT:    stb 4, 1(3)
; G3-NEXT:    lwz 30, 40(1) # 4-byte Folded Reload
; G3-NEXT:    lwz 29, 36(1) # 4-byte Folded Reload
; G3-NEXT:    lwz 28, 32(1) # 4-byte Folded Reload
; G3-NEXT:    lwz 27, 28(1) # 4-byte Folded Reload
; G3-NEXT:    lwz 26, 24(1) # 4-byte Folded Reload
; G3-NEXT:    lwz 25, 20(1) # 4-byte Folded Reload
; G3-NEXT:    lwz 24, 16(1) # 4-byte Folded Reload
; G3-NEXT:    addi 1, 1, 48
; G3-NEXT:    blr
;
; G5-LABEL: spltish:
; G5:       # %bb.0:
; G5-NEXT:    lvx 2, 0, 4
; G5-NEXT:    vspltish 3, 15
; G5-NEXT:    vsububm 2, 2, 3
; G5-NEXT:    stvx 2, 0, 3
; G5-NEXT:    blr
  %tmp = load <16 x i8>, <16 x i8>* %B         ; <<16 x i8>> [#uses=1]
  %tmp.s = bitcast <16 x i8> %tmp to <16 x i8>      ; <<16 x i8>> [#uses=1]
  %tmp4 = sub <16 x i8> %tmp.s, bitcast (<8 x i16> < i16 15, i16 15, i16 15, i16 15, i16 15, i16
 15, i16 15, i16 15 > to <16 x i8>)       ; <<16 x i8>> [#uses=1]
  %tmp4.u = bitcast <16 x i8> %tmp4 to <16 x i8>    ; <<16 x i8>> [#uses=1]
  store <16 x i8> %tmp4.u, <16 x i8>* %A
  ret void
}
