; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -instcombine -instcombine-infinite-loop-threshold=2 < %s | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@a = dso_local local_unnamed_addr global i64 0, align 8
@d = dso_local local_unnamed_addr global i64 0, align 8
@c = external dso_local local_unnamed_addr global i8, align 1

define void @test(i16* nocapture readonly %arg) local_unnamed_addr {
; CHECK-LABEL: @test(
; CHECK-NEXT:  bb:
; CHECK-NEXT:    [[I:%.*]] = load i64, i64* @d, align 8
; CHECK-NEXT:    [[I1:%.*]] = icmp eq i64 [[I]], 0
; CHECK-NEXT:    [[I2:%.*]] = load i64, i64* @a, align 8
; CHECK-NEXT:    [[I3:%.*]] = icmp ne i64 [[I2]], 0
; CHECK-NEXT:    br i1 [[I1]], label [[BB13:%.*]], label [[BB4:%.*]]
; CHECK:       bb4:
; CHECK-NEXT:    [[I5:%.*]] = load i16, i16* [[ARG:%.*]], align 2
; CHECK-NEXT:    [[I6:%.*]] = trunc i16 [[I5]] to i8
; CHECK-NEXT:    store i8 [[I6]], i8* @c, align 1
; CHECK-NEXT:    tail call void @llvm.assume(i1 [[I3]])
; CHECK-NEXT:    br label [[BB22:%.*]]
; CHECK:       bb13:
; CHECK-NEXT:    [[I14:%.*]] = load i16, i16* [[ARG]], align 2
; CHECK-NEXT:    [[I15:%.*]] = trunc i16 [[I14]] to i8
; CHECK-NEXT:    store i8 [[I15]], i8* @c, align 1
; CHECK-NEXT:    br label [[BB22]]
; CHECK:       bb22:
; CHECK-NEXT:    [[STOREMERGE2_IN:%.*]] = load i16, i16* [[ARG]], align 2
; CHECK-NEXT:    [[STOREMERGE2:%.*]] = trunc i16 [[STOREMERGE2_IN]] to i8
; CHECK-NEXT:    store i8 [[STOREMERGE2]], i8* @c, align 1
; CHECK-NEXT:    [[STOREMERGE1_IN:%.*]] = load i16, i16* [[ARG]], align 2
; CHECK-NEXT:    [[STOREMERGE1:%.*]] = trunc i16 [[STOREMERGE1_IN]] to i8
; CHECK-NEXT:    store i8 [[STOREMERGE1]], i8* @c, align 1
; CHECK-NEXT:    [[STOREMERGE_IN:%.*]] = load i16, i16* [[ARG]], align 2
; CHECK-NEXT:    [[STOREMERGE:%.*]] = trunc i16 [[STOREMERGE_IN]] to i8
; CHECK-NEXT:    store i8 [[STOREMERGE]], i8* @c, align 1
; CHECK-NEXT:    br label [[BB23:%.*]]
; CHECK:       bb23:
; CHECK-NEXT:    br label [[BB23]]
;
bb:
  %i = load i64, i64* @d, align 8
  %i1 = icmp eq i64 %i, 0
  %i2 = load i64, i64* @a, align 8
  %i3 = icmp ne i64 %i2, 0
  br i1 %i1, label %bb13, label %bb4

bb4:                                              ; preds = %bb
  %i5 = load i16, i16* %arg, align 2
  %i6 = trunc i16 %i5 to i8
  store i8 %i6, i8* @c, align 1
  tail call void @llvm.assume(i1 %i3)
  %i7 = load i16, i16* %arg, align 2
  %i8 = trunc i16 %i7 to i8
  store i8 %i8, i8* @c, align 1
  %i9 = load i16, i16* %arg, align 2
  %i10 = trunc i16 %i9 to i8
  store i8 %i10, i8* @c, align 1
  %i11 = load i16, i16* %arg, align 2
  %i12 = trunc i16 %i11 to i8
  store i8 %i12, i8* @c, align 1
  br label %bb22

bb13:                                             ; preds = %bb
  %i14 = load i16, i16* %arg, align 2
  %i15 = trunc i16 %i14 to i8
  store i8 %i15, i8* @c, align 1
  %i16 = load i16, i16* %arg, align 2
  %i17 = trunc i16 %i16 to i8
  store i8 %i17, i8* @c, align 1
  %i18 = load i16, i16* %arg, align 2
  %i19 = trunc i16 %i18 to i8
  store i8 %i19, i8* @c, align 1
  %i20 = load i16, i16* %arg, align 2
  %i21 = trunc i16 %i20 to i8
  store i8 %i21, i8* @c, align 1
  br label %bb22

bb22:                                             ; preds = %bb13, %bb4
  br label %bb23

bb23:                                             ; preds = %bb23, %bb22
  br label %bb23
}

; Function Attrs: nounwind willreturn
declare void @llvm.assume(i1) #0

attributes #0 = { nounwind willreturn }
