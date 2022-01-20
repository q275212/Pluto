; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -loop-deletion -S | FileCheck %s

@G = external global i32

define void @test_trivial() {
; CHECK-LABEL: @test_trivial(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    store i32 0, i32* @G, align 4
; CHECK-NEXT:    br i1 false, label [[LOOP_LOOP_CRIT_EDGE:%.*]], label [[EXIT:%.*]]
; CHECK:       loop.loop_crit_edge:
; CHECK-NEXT:    unreachable
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  store i32 0, i32* @G
  br i1 false, label %loop, label %exit

exit:
  ret void
}


define void @test_bottom_tested() {
; CHECK-LABEL: @test_bottom_tested(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    store i32 0, i32* @G, align 4
; CHECK-NEXT:    [[IV_INC:%.*]] = add i32 [[IV]], 1
; CHECK-NEXT:    [[BE_TAKEN:%.*]] = icmp ne i32 [[IV_INC]], 1
; CHECK-NEXT:    br i1 [[BE_TAKEN]], label [[LOOP_LOOP_CRIT_EDGE:%.*]], label [[EXIT:%.*]]
; CHECK:       loop.loop_crit_edge:
; CHECK-NEXT:    unreachable
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %iv = phi i32 [ 0, %entry], [ %iv.inc, %loop ]
  store i32 0, i32* @G
  %iv.inc = add i32 %iv, 1
  %be_taken = icmp ne i32 %iv.inc, 1
  br i1 %be_taken, label %loop, label %exit

exit:
  ret void
}

define void @test_early_exit() {
; CHECK-LABEL: @test_early_exit(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    store i32 0, i32* @G, align 4
; CHECK-NEXT:    [[IV_INC:%.*]] = add i32 [[IV]], 1
; CHECK-NEXT:    [[BE_TAKEN:%.*]] = icmp ne i32 [[IV_INC]], 1
; CHECK-NEXT:    br i1 [[BE_TAKEN]], label [[LATCH:%.*]], label [[EXIT:%.*]]
; CHECK:       latch:
; CHECK-NEXT:    br label [[LATCH_SPLIT:%.*]]
; CHECK:       latch.split:
; CHECK-NEXT:    unreachable
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %iv = phi i32 [ 0, %entry], [ %iv.inc, %latch ]
  store i32 0, i32* @G
  %iv.inc = add i32 %iv, 1
  %be_taken = icmp ne i32 %iv.inc, 1
  br i1 %be_taken, label %latch, label %exit
latch:
  br label %loop

exit:
  ret void
}

define void @test_multi_exit1() {
; CHECK-LABEL: @test_multi_exit1(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    store i32 0, i32* @G, align 4
; CHECK-NEXT:    [[IV_INC:%.*]] = add i32 [[IV]], 1
; CHECK-NEXT:    [[BE_TAKEN:%.*]] = icmp ne i32 [[IV_INC]], 1
; CHECK-NEXT:    br i1 [[BE_TAKEN]], label [[LATCH:%.*]], label [[EXIT:%.*]]
; CHECK:       latch:
; CHECK-NEXT:    store i32 1, i32* @G, align 4
; CHECK-NEXT:    [[COND2:%.*]] = icmp ult i32 [[IV_INC]], 30
; CHECK-NEXT:    br i1 [[COND2]], label [[LATCH_LOOP_CRIT_EDGE:%.*]], label [[EXIT]]
; CHECK:       latch.loop_crit_edge:
; CHECK-NEXT:    unreachable
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %iv = phi i32 [ 0, %entry], [ %iv.inc, %latch ]
  store i32 0, i32* @G
  %iv.inc = add i32 %iv, 1
  %be_taken = icmp ne i32 %iv.inc, 1
  br i1 %be_taken, label %latch, label %exit
latch:
  store i32 1, i32* @G
  %cond2 = icmp ult i32 %iv.inc, 30
  br i1 %cond2, label %loop, label %exit

exit:
  ret void
}

define void @test_multi_exit2() {
; CHECK-LABEL: @test_multi_exit2(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    store i32 0, i32* @G, align 4
; CHECK-NEXT:    br i1 true, label [[LATCH:%.*]], label [[EXIT:%.*]]
; CHECK:       latch:
; CHECK-NEXT:    store i32 1, i32* @G, align 4
; CHECK-NEXT:    br i1 false, label [[LATCH_LOOP_CRIT_EDGE:%.*]], label [[EXIT]]
; CHECK:       latch.loop_crit_edge:
; CHECK-NEXT:    unreachable
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  store i32 0, i32* @G
  br i1 true, label %latch, label %exit
latch:
  store i32 1, i32* @G
  br i1 false, label %loop, label %exit

exit:
  ret void
}

; TODO: SCEV seems not to recognize this as a zero btc loop
define void @test_multi_exit3(i1 %cond1) {
; CHECK-LABEL: @test_multi_exit3(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[IV_INC:%.*]], [[LATCH:%.*]] ]
; CHECK-NEXT:    store i32 0, i32* @G, align 4
; CHECK-NEXT:    br i1 [[COND1:%.*]], label [[LATCH]], label [[EXIT:%.*]]
; CHECK:       latch:
; CHECK-NEXT:    store i32 1, i32* @G, align 4
; CHECK-NEXT:    [[IV_INC]] = add i32 [[IV]], 1
; CHECK-NEXT:    [[BE_TAKEN:%.*]] = icmp ne i32 [[IV_INC]], 1
; CHECK-NEXT:    br i1 [[BE_TAKEN]], label [[LOOP]], label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %iv = phi i32 [ 0, %entry], [ %iv.inc, %latch ]
  store i32 0, i32* @G
  br i1 %cond1, label %latch, label %exit
latch:
  store i32 1, i32* @G
  %iv.inc = add i32 %iv, 1
  %be_taken = icmp ne i32 %iv.inc, 1
  br i1 %be_taken, label %loop, label %exit

exit:
  ret void
}

; Subtle - This is either zero btc, or infinite, thus, can't break
; backedge
define void @test_multi_exit4(i1 %cond1, i1 %cond2) {
; CHECK-LABEL: @test_multi_exit4(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    store i32 0, i32* @G, align 4
; CHECK-NEXT:    br i1 [[COND1:%.*]], label [[LATCH:%.*]], label [[EXIT:%.*]]
; CHECK:       latch:
; CHECK-NEXT:    store i32 1, i32* @G, align 4
; CHECK-NEXT:    br i1 [[COND2:%.*]], label [[LOOP]], label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  store i32 0, i32* @G
  br i1 %cond1, label %latch, label %exit
latch:
  store i32 1, i32* @G
  br i1 %cond2, label %loop, label %exit

exit:
  ret void
}

; A simple case with multiple exit blocks
define void @test_multi_exit5() {
; CHECK-LABEL: @test_multi_exit5(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    store i32 0, i32* @G, align 4
; CHECK-NEXT:    br i1 true, label [[LATCH:%.*]], label [[EXIT1:%.*]]
; CHECK:       latch:
; CHECK-NEXT:    store i32 1, i32* @G, align 4
; CHECK-NEXT:    br i1 false, label [[LATCH_LOOP_CRIT_EDGE:%.*]], label [[EXIT2:%.*]]
; CHECK:       latch.loop_crit_edge:
; CHECK-NEXT:    unreachable
; CHECK:       exit1:
; CHECK-NEXT:    ret void
; CHECK:       exit2:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  store i32 0, i32* @G
  br i1 true, label %latch, label %exit1
latch:
  store i32 1, i32* @G
  br i1 false, label %loop, label %exit2

exit1:
  ret void
exit2:
  ret void
}

define void @test_live_inner() {
; CHECK-LABEL: @test_live_inner(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    store i32 0, i32* @G, align 4
; CHECK-NEXT:    br label [[INNER:%.*]]
; CHECK:       inner:
; CHECK-NEXT:    [[IV:%.*]] = phi i32 [ 0, [[LOOP]] ], [ [[IV_INC:%.*]], [[INNER]] ]
; CHECK-NEXT:    store i32 [[IV]], i32* @G, align 4
; CHECK-NEXT:    [[IV_INC]] = add i32 [[IV]], 1
; CHECK-NEXT:    [[CND:%.*]] = icmp ult i32 [[IV_INC]], 200
; CHECK-NEXT:    br i1 [[CND]], label [[INNER]], label [[LATCH:%.*]]
; CHECK:       latch:
; CHECK-NEXT:    br i1 false, label [[LATCH_LOOP_CRIT_EDGE:%.*]], label [[EXIT:%.*]]
; CHECK:       latch.loop_crit_edge:
; CHECK-NEXT:    unreachable
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  store i32 0, i32* @G
  br label %inner

inner:
  %iv = phi i32 [0, %loop], [%iv.inc, %inner]
  store i32 %iv, i32* @G
  %iv.inc = add i32 %iv, 1
  %cnd = icmp ult i32 %iv.inc, 200
  br i1 %cnd, label %inner, label %latch

latch:
  br i1 false, label %loop, label %exit

exit:
  ret void
}

define void @test_live_outer() {
; CHECK-LABEL: @test_live_outer(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[IV_INC:%.*]], [[LATCH:%.*]] ]
; CHECK-NEXT:    br label [[INNER:%.*]]
; CHECK:       inner:
; CHECK-NEXT:    store i32 0, i32* @G, align 4
; CHECK-NEXT:    br i1 false, label [[INNER_INNER_CRIT_EDGE:%.*]], label [[LATCH]]
; CHECK:       inner.inner_crit_edge:
; CHECK-NEXT:    unreachable
; CHECK:       latch:
; CHECK-NEXT:    store i32 [[IV]], i32* @G, align 4
; CHECK-NEXT:    [[IV_INC]] = add i32 [[IV]], 1
; CHECK-NEXT:    [[CND:%.*]] = icmp ult i32 [[IV_INC]], 200
; CHECK-NEXT:    br i1 [[CND]], label [[LOOP]], label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %iv = phi i32 [0, %entry], [%iv.inc, %latch]
  br label %inner

inner:
  store i32 0, i32* @G
  br i1 false, label %inner, label %latch

latch:
  store i32 %iv, i32* @G
  %iv.inc = add i32 %iv, 1
  %cnd = icmp ult i32 %iv.inc, 200
  br i1 %cnd, label %loop, label %exit

exit:
  ret void
}

; Key point is that inner_latch drops out of the outer loop when
; the inner loop is deleted, and thus the lcssa phi needs to be
; in the inner_latch block to preserve LCSSA.  We either have to
; insert the LCSSA phi, or not break the inner backedge.
define void @loop_nest_lcssa() {
; CHECK-LABEL: @loop_nest_lcssa(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = add i32 1, 2
; CHECK-NEXT:    br label [[OUTER_HEADER:%.*]]
; CHECK:       outer_header:
; CHECK-NEXT:    br label [[INNER_HEADER:%.*]]
; CHECK:       inner_header:
; CHECK-NEXT:    br i1 false, label [[INNER_LATCH:%.*]], label [[OUTER_LATCH:%.*]]
; CHECK:       inner_latch:
; CHECK-NEXT:    [[DOTLCSSA:%.*]] = phi i32 [ [[TMP0]], [[INNER_HEADER]] ]
; CHECK-NEXT:    br i1 false, label [[INNER_LATCH_INNER_HEADER_CRIT_EDGE:%.*]], label [[LOOPEXIT:%.*]]
; CHECK:       inner_latch.inner_header_crit_edge:
; CHECK-NEXT:    unreachable
; CHECK:       outer_latch:
; CHECK-NEXT:    br label [[OUTER_HEADER]]
; CHECK:       loopexit:
; CHECK-NEXT:    [[DOTLCSSA32:%.*]] = phi i32 [ [[DOTLCSSA]], [[INNER_LATCH]] ]
; CHECK-NEXT:    unreachable
;
entry:
  br label %outer_header

outer_header:
  %0 = add i32 1, 2
  br label %inner_header

inner_header:
  br i1 false, label %inner_latch, label %outer_latch

inner_latch:
  br i1 false, label %inner_header, label %loopexit

outer_latch:
  br label %outer_header

loopexit:
  %.lcssa32 = phi i32 [ %0, %inner_latch ]
  unreachable
}
