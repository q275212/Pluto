; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -verify-machineinstrs -mtriple=powerpc64-unknown-linux-gnu -O2 \
; RUN:   -ppc-gpr-icmps=all -ppc-asm-full-reg-names -mcpu=pwr8 < %s | FileCheck %s \
; RUN:  --implicit-check-not cmpw --implicit-check-not cmpd --implicit-check-not cmpl
; RUN: llc -verify-machineinstrs -mtriple=powerpc64le-unknown-linux-gnu -O2 \
; RUN:   -ppc-gpr-icmps=all -ppc-asm-full-reg-names -mcpu=pwr8 < %s | FileCheck %s \
; RUN:  --implicit-check-not cmpw --implicit-check-not cmpd --implicit-check-not cmpl

@glob = dso_local local_unnamed_addr global i16 0, align 2

; Function Attrs: norecurse nounwind readnone
define dso_local signext i32 @test_ileus(i16 zeroext %a, i16 zeroext %b) {
; CHECK-LABEL: test_ileus:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sub r3, r4, r3
; CHECK-NEXT:    not r3, r3
; CHECK-NEXT:    rldicl r3, r3, 1, 63
; CHECK-NEXT:    blr
entry:
  %cmp = icmp ule i16 %a, %b
  %conv2 = zext i1 %cmp to i32
  ret i32 %conv2
}

; Function Attrs: norecurse nounwind readnone
define dso_local signext i32 @test_ileus_sext(i16 zeroext %a, i16 zeroext %b) {
; CHECK-LABEL: test_ileus_sext:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sub r3, r4, r3
; CHECK-NEXT:    rldicl r3, r3, 1, 63
; CHECK-NEXT:    addi r3, r3, -1
; CHECK-NEXT:    blr
entry:
  %cmp = icmp ule i16 %a, %b
  %sub = sext i1 %cmp to i32
  ret i32 %sub
}

; Function Attrs: norecurse nounwind readnone
define dso_local signext i32 @test_ileus_z(i16 zeroext %a) {
; CHECK-LABEL: test_ileus_z:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cntlzw r3, r3
; CHECK-NEXT:    srwi r3, r3, 5
; CHECK-NEXT:    blr
entry:
  %cmp = icmp ule i16 %a, 0
  %conv1 = zext i1 %cmp to i32
  ret i32 %conv1
}

; Function Attrs: norecurse nounwind readnone
define dso_local signext i32 @test_ileus_sext_z(i16 zeroext %a) {
; CHECK-LABEL: test_ileus_sext_z:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cntlzw r3, r3
; CHECK-NEXT:    srwi r3, r3, 5
; CHECK-NEXT:    neg r3, r3
; CHECK-NEXT:    blr
entry:
  %cmp = icmp ule i16 %a, 0
  %sub = sext i1 %cmp to i32
  ret i32 %sub
}

; Function Attrs: norecurse nounwind
define dso_local void @test_ileus_store(i16 zeroext %a, i16 zeroext %b) {
; CHECK-LABEL: test_ileus_store:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sub r3, r4, r3
; CHECK-NEXT:    addis r5, r2, glob@toc@ha
; CHECK-NEXT:    not r3, r3
; CHECK-NEXT:    rldicl r3, r3, 1, 63
; CHECK-NEXT:    sth r3, glob@toc@l(r5)
; CHECK-NEXT:    blr
entry:
  %cmp = icmp ule i16 %a, %b
  %conv3 = zext i1 %cmp to i16
  store i16 %conv3, i16* @glob
  ret void
}

; Function Attrs: norecurse nounwind
define dso_local void @test_ileus_sext_store(i16 zeroext %a, i16 zeroext %b) {
; CHECK-LABEL: test_ileus_sext_store:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sub r3, r4, r3
; CHECK-NEXT:    addis r5, r2, glob@toc@ha
; CHECK-NEXT:    rldicl r3, r3, 1, 63
; CHECK-NEXT:    addi r3, r3, -1
; CHECK-NEXT:    sth r3, glob@toc@l(r5)
; CHECK-NEXT:    blr
entry:
  %cmp = icmp ule i16 %a, %b
  %conv3 = sext i1 %cmp to i16
  store i16 %conv3, i16* @glob
  ret void
}

; Function Attrs: norecurse nounwind
define dso_local void @test_ileus_z_store(i16 zeroext %a) {
; CHECK-LABEL: test_ileus_z_store:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cntlzw r3, r3
; CHECK-NEXT:    addis r4, r2, glob@toc@ha
; CHECK-NEXT:    srwi r3, r3, 5
; CHECK-NEXT:    sth r3, glob@toc@l(r4)
; CHECK-NEXT:    blr
entry:
  %cmp = icmp ule i16 %a, 0
  %conv2 = zext i1 %cmp to i16
  store i16 %conv2, i16* @glob
  ret void
}

; Function Attrs: norecurse nounwind
define dso_local void @test_ileus_sext_z_store(i16 zeroext %a) {
; CHECK-LABEL: test_ileus_sext_z_store:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cntlzw r3, r3
; CHECK-NEXT:    addis r4, r2, glob@toc@ha
; CHECK-NEXT:    srwi r3, r3, 5
; CHECK-NEXT:    neg r3, r3
; CHECK-NEXT:    sth r3, glob@toc@l(r4)
; CHECK-NEXT:    blr
entry:
  %cmp = icmp ule i16 %a, 0
  %conv2 = sext i1 %cmp to i16
  store i16 %conv2, i16* @glob
  ret void
}

