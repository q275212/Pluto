; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -instcombine < %s | FileCheck %s
; Check that we don't crash on unreasonable constant indexes

define i32 @test_out_of_bounds(i32 %a, i1 %x, i1 %y) {
; CHECK-LABEL: @test_out_of_bounds(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[AND1:%.*]] = and i32 [[A:%.*]], 3
; CHECK-NEXT:    tail call void @llvm.assume(i1 poison)
; CHECK-NEXT:    ret i32 [[AND1]]
;
entry:
  %and1 = and i32 %a, 3
  %B = lshr i32 %and1, -2147483648
  %cmp = icmp eq i32 %B, 1
  tail call void @llvm.assume(i1 %cmp)
  ret i32 %and1
}

define i128 @test_non64bit(i128 %a) {
; CHECK-LABEL: @test_non64bit(
; CHECK-NEXT:    [[AND1:%.*]] = and i128 [[A:%.*]], 3
; CHECK-NEXT:    tail call void @llvm.assume(i1 poison)
; CHECK-NEXT:    ret i128 [[AND1]]
;
  %and1 = and i128 %a, 3
  %B = lshr i128 %and1, -1
  %cmp = icmp eq i128 %B, 1
  tail call void @llvm.assume(i1 %cmp)
  ret i128 %and1
}

declare void @llvm.assume(i1)

define <4 x double> @inselt_bad_index(<4 x double> %a) {
; CHECK-LABEL: @inselt_bad_index(
; CHECK-NEXT:    ret <4 x double> poison
;
  %I = insertelement <4 x double> %a, double 0.0, i64 4294967296
  ret <4 x double> %I
}
