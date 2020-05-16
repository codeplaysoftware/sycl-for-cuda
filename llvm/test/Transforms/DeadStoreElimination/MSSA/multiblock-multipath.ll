; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -basicaa -dse -enable-dse-memoryssa -S | FileCheck %s

target datalayout = "e-m:e-p:32:32-i64:64-v128:64:128-a:0:32-n32-S64"

declare void @use(i32 *)

; Tests where the pointer/object is accessible after the function returns.

define void @accessible_after_return_1(i32* noalias %P, i1 %c1) {
; CHECK-LABEL: @accessible_after_return_1(
; CHECK-NEXT:    store i32 1, i32* [[P:%.*]], align 4
; CHECK-NEXT:    br i1 [[C1:%.*]], label [[BB1:%.*]], label [[BB2:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    store i32 0, i32* [[P]], align 4
; CHECK-NEXT:    br label [[BB5:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    store i32 3, i32* [[P]], align 4
; CHECK-NEXT:    br label [[BB5]]
; CHECK:       bb5:
; CHECK-NEXT:    call void @use(i32* [[P]])
; CHECK-NEXT:    ret void
;
  store i32 1, i32* %P
  br i1 %c1, label %bb1, label %bb2

bb1:
  store i32 0, i32* %P
  br label %bb5
bb2:
  store i32 3, i32* %P
  br label %bb5

bb5:
  call void @use(i32* %P)
  ret void
}

define void @accessible_after_return_2(i32* noalias %P, i1 %c.1, i1 %c.2) {
; CHECK-LABEL: @accessible_after_return_2(
; CHECK-NEXT:    store i32 1, i32* [[P:%.*]], align 4
; CHECK-NEXT:    br i1 [[C_1:%.*]], label [[BB1:%.*]], label [[BB2:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    store i32 0, i32* [[P]], align 4
; CHECK-NEXT:    br label [[BB5:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    br i1 [[C_2:%.*]], label [[BB3:%.*]], label [[BB4:%.*]]
; CHECK:       bb3:
; CHECK-NEXT:    store i32 3, i32* [[P]], align 4
; CHECK-NEXT:    br label [[BB5]]
; CHECK:       bb4:
; CHECK-NEXT:    store i32 5, i32* [[P]], align 4
; CHECK-NEXT:    br label [[BB5]]
; CHECK:       bb5:
; CHECK-NEXT:    call void @use(i32* [[P]])
; CHECK-NEXT:    ret void
;
  store i32 1, i32* %P
  br i1 %c.1, label %bb1, label %bb2
bb1:
  store i32 0, i32* %P
  br label %bb5

bb2:
  br i1 %c.2, label %bb3, label %bb4

bb3:
  store i32 3, i32* %P
  br label %bb5

bb4:
  store i32 5, i32* %P
  br label %bb5

bb5:
  call void @use(i32* %P)
  ret void
}

define void @accessible_after_return_3(i32* noalias %P, i1 %c1) {
; CHECK-LABEL: @accessible_after_return_3(
; CHECK-NEXT:    store i32 1, i32* [[P:%.*]], align 4
; CHECK-NEXT:    br i1 [[C1:%.*]], label [[BB1:%.*]], label [[BB2:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    store i32 0, i32* [[P]], align 4
; CHECK-NEXT:    br label [[BB5:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    br label [[BB5]]
; CHECK:       bb5:
; CHECK-NEXT:    call void @use(i32* [[P]])
; CHECK-NEXT:    ret void
;
  store i32 1, i32* %P
  br i1 %c1, label %bb1, label %bb2

bb1:
  store i32 0, i32* %P
  br label %bb5

bb2:
  br label %bb5

bb5:
  call void @use(i32* %P)
  ret void
}

define void @accessible_after_return_4(i32* noalias %P, i1 %c1) {
; CHECK-LABEL: @accessible_after_return_4(
; CHECK-NEXT:    store i32 1, i32* [[P:%.*]], align 4
; CHECK-NEXT:    br i1 [[C1:%.*]], label [[BB1:%.*]], label [[BB2:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    store i32 0, i32* [[P]], align 4
; CHECK-NEXT:    call void @use(i32* [[P]])
; CHECK-NEXT:    br label [[BB5:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    br label [[BB5]]
; CHECK:       bb5:
; CHECK-NEXT:    ret void
;
  store i32 1, i32* %P
  br i1 %c1, label %bb1, label %bb2

bb1:
  store i32 0, i32* %P
  call void @use(i32* %P)
  br label %bb5

bb2:
  br label %bb5

bb5:
  ret void
}


; Tests where the pointer/object is *NOT* accessible after the function returns.

; The store in the entry block can be eliminated, because it is overwritten
; on all paths to the exit.
define void @alloca_1(i1 %c1) {
; CHECK-LABEL: @alloca_1(
; CHECK-NEXT:    [[P:%.*]] = alloca i32
; CHECK-NEXT:    br i1 [[C1:%.*]], label [[BB1:%.*]], label [[BB2:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    store i32 0, i32* [[P]], align 4
; CHECK-NEXT:    br label [[BB5:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    store i32 3, i32* [[P]], align 4
; CHECK-NEXT:    br label [[BB5]]
; CHECK:       bb5:
; CHECK-NEXT:    call void @use(i32* [[P]])
; CHECK-NEXT:    ret void
;
  %P = alloca i32
  store i32 1, i32* %P
  br i1 %c1, label %bb1, label %bb2

bb1:
  store i32 0, i32* %P
  br label %bb5
bb2:
  store i32 3, i32* %P
  br label %bb5

bb5:
  call void @use(i32* %P)
  ret void
}

; The store in the entry block can be eliminated, because it is overwritten
; on all paths to the exit.
define void @alloca_2(i1 %c.1, i1 %c.2) {
; CHECK-LABEL: @alloca_2(
; CHECK-NEXT:    [[P:%.*]] = alloca i32
; CHECK-NEXT:    br i1 [[C_1:%.*]], label [[BB1:%.*]], label [[BB2:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    store i32 0, i32* [[P]], align 4
; CHECK-NEXT:    br label [[BB5:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    br i1 [[C_2:%.*]], label [[BB3:%.*]], label [[BB4:%.*]]
; CHECK:       bb3:
; CHECK-NEXT:    store i32 3, i32* [[P]], align 4
; CHECK-NEXT:    br label [[BB5]]
; CHECK:       bb4:
; CHECK-NEXT:    store i32 5, i32* [[P]], align 4
; CHECK-NEXT:    br label [[BB5]]
; CHECK:       bb5:
; CHECK-NEXT:    call void @use(i32* [[P]])
; CHECK-NEXT:    ret void
;
  %P = alloca i32
  store i32 1, i32* %P
  br i1 %c.1, label %bb1, label %bb2

bb1:
  store i32 0, i32* %P
  br label %bb5

bb2:
  br i1 %c.2, label %bb3, label %bb4

bb3:
  store i32 3, i32* %P
  br label %bb5

bb4:
  store i32 5, i32* %P
  br label %bb5

bb5:
  call void @use(i32* %P)
  ret void
}

; The store in the entry block cannot be eliminated. There's a path from the
; first store to the read in bb5, where the location is not overwritten.
define void @alloca_3(i1 %c1) {
; CHECK-LABEL: @alloca_3(
; CHECK-NEXT:    [[P:%.*]] = alloca i32
; CHECK-NEXT:    store i32 1, i32* [[P]], align 4
; CHECK-NEXT:    br i1 [[C1:%.*]], label [[BB1:%.*]], label [[BB2:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    store i32 0, i32* [[P]], align 4
; CHECK-NEXT:    br label [[BB5:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    br label [[BB5]]
; CHECK:       bb5:
; CHECK-NEXT:    call void @use(i32* [[P]])
; CHECK-NEXT:    ret void
;
  %P = alloca i32
  store i32 1, i32* %P
  br i1 %c1, label %bb1, label %bb2

bb1:
  store i32 0, i32* %P
  br label %bb5
bb2:
  br label %bb5

bb5:
  call void @use(i32* %P)
  ret void
}

; The store in the entry block can be eliminated, because it is overwritten
; before the use in bb1 and not read on other paths to the function exit. The
; object cannot be accessed by the caller.
define void @alloca_4(i1 %c1) {
; CHECK-LABEL: @alloca_4(
; CHECK-NEXT:    [[P:%.*]] = alloca i32
; CHECK-NEXT:    br i1 [[C1:%.*]], label [[BB1:%.*]], label [[BB2:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    store i32 0, i32* [[P]], align 4
; CHECK-NEXT:    call void @use(i32* [[P]])
; CHECK-NEXT:    br label [[BB5:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    br label [[BB5]]
; CHECK:       bb5:
; CHECK-NEXT:    ret void
;
  %P = alloca i32
  store i32 1, i32* %P
  br i1 %c1, label %bb1, label %bb2

bb1:
  store i32 0, i32* %P
  call void @use(i32* %P)
  br label %bb5

bb2:
  br label %bb5

bb5:
  ret void
}
