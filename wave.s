;;; Optimized WAVE 3 (PLA, space saved)
;;; footprint 868.8 speed 25.0
;;; (c) 2015 harry zhang, daishiro nishida

;;; r1: instruction
;;; r2
;;; r3
;;; r4: wccr
;;; r6
;;; r7: rsp
;;; r8: opcode
;;; r9
;;; r10: src2
;;; r11: dest (number)
;;; r13: src1
;;; r14: src1 (number)
;;; r15: wadr

    lea    WARM, r0
    trap    $SysOverlay
    mov    r0, r15

nv:    add    $1, wpc

loop:    and    $0xffffff, wpc    ;*** INSTRUCTION START***
    mov    wpc, r2
    mov    WARM(r2), r1

    mov    r1, r0
    trap    $SysPLA
    mov    pla(r0), rip

;;; Check condition bits
getc3:    mov    $32, r8
    jmp    getcon
getc2:    mov    $43, r8
getcon:    mov    r1, r2
    shr    $29, r2
    mov    cond(r2), rip

eq:    mov    r4, ccr
    je    jump
    jmp    nv
ne:    mov    r4, ccr
    jne    jump
    jmp    nv
lt:    mov    r4, ccr
	 jl    jump
    jmp    nv
le:    mov    r4, ccr
    jle    jump
    jmp    nv
ge:    mov    r4, ccr
    jge    jump
    jmp    nv
gt:    mov    r4, ccr
    jg    jump
    jmp    nv

;;; Get registers
jump:    mov    pla3(r0), rip
    
getreg:    mov    r1, r8
    shr    $23, r8
    and    $0x3f, r8
    mov    regs(r8), rip

src1b:    mov    r1, r14
    shr    $15, r14
    and    $15, r14
    mov    wregs(r14), r13

src2b:    mov    r1, r9
    shr    $10, r9
    and    $0x1f, r9
    mov    format(r9), rip

src1:    mov    r1, r14
    shr    $15, r14
    and    $15, r14
    mov    wregs(r14), r13

dest:    mov    r1, r11
    shr    $19, r11
    and    $15, r11

src2:    mov    r1, r9
    shr    $10, r9
    and    $0x1f, r9
    mov    format(r9), rip

;;; Different formats for src2 (r6: shift count, r9: shop)
rsi:    mov    r1, r10
    shr    $6, r10
    and    $15, r10
    mov    wregs(r10), r10
    and    $0x3f, r1
    sub    $16, r9
    mov    shop(r9), rip

rsr:    mov    r1, r10
    shr    $6, r10
    and    $15, r10
    mov    wregs(r10), r10
    and    $15, r1
    mov    wregs(r1), r1
    sub    $16, r9
    mov    shop(r9), rip

lsl:    shl    r1, r10
    add    $1, wpc
    mov    pla2(r0), rip

lsr:    shr    r1, r10
    add    $1, wpc
    mov    pla2(r0), rip

asr:    sar    r1, r10
    add    $1, wpc
    mov    pla2(r0), rip

ror:    mov    r10, r9
    shr    r1, r10
    mov    $32, r2
    sub    r1, r2
    shl    r2, r9
    add    r9, r10
    add    $1, wpc
    mov    pla2(r0), rip
    
rpm:    mov    r1, r10
    shr    $6, r10
    and    $15, r10
    mov    wregs(r10), r10
    and    $15, r1
    mov    wregs(r1), r1
    mul    r1, r10
    add    $1, wpc
    mov    pla2(r0), rip
    
imm:    test    $0x8000000, r1
    je    type0

type1:    mov    r1, r10
    shl    $19, r10
    sar    $19, r10
    add    $1, wpc
    mov    pla2(r0), rip

type0:    mov    r1, r10
    and    $0x1ff, r10
    shr    $9, r1
    and    $0x1f, r1
    shl    r1, r10
    add    $1, wpc
    mov    pla2(r0), rip
    
;;; Jump to operation
getop:    mov    opcode(r8), rip

adc:    mov    r4, r9
    shr    $1, r9
    and    $1, r9
    add    r9, r13
    add    r10, r13
    mov    r13, wregs(r11)
    mov    setccr(r8), rip

addb:    mov    $0, r8
add:    add    r10, r13
    mov    r13, wregs(r11)
    mov    setccr(r8), rip

subb:    mov    $0, r8
sub:    sub    r10, r13
    mov    r13, wregs(r11)
    mov    setccr(r8), rip

cmpb:    mov    $32, r8
cmp:    sub    r10, r13
    mov    ccr, r4
    mov    setccr(r8), rip

eor:    xor    r10, r13
    mov    r13, wregs(r11)
    mov    setccr(r8), rip

orr:    or    r10, r13
    mov    r13, wregs(r11)
    mov    setccr(r8), rip

andb:    mov    $0, r8
and:    and    r10, r13
    mov    r13, wregs(r11)
    mov    setccr(r8), rip

tst:    and    r10, r13
    mov    ccr, r4
    mov    setccr(r8), rip

mulb:    mov    $0, r8
mul:    mul    r10, r13
    mov    r13, wregs(r11)
    mov    setccr(r8), rip

divb:    mov    $0, r8
div:    cmp    $0, r10
    je    x
    div    r10, r13
    mov    r13, wregs(r11)
    mov    setccr(r8), rip

movb:    mov    $0, r8
mov:    mov    r10, wregs(r11)
    mov    setccr(r8), rip

mvnb:    mov    $0, r8
mvn:    xor    $0xffffffff, r10
    mov    r10, wregs(r11)
    mov    setccr(r8), rip

swib:    mov    $0, r8
swi:    cmp    $16, r10
    jge    swi2
    mov    wregs, r0
    jge    swi2
    trap    r10
    mov    r0, wregs
    mov    setccr(r8), rip
swi2:    mov    r10, wr0
    mov    r10, wpc
    mov    $8, wlr
    jmp    loop

ldm:    mov    wregs(r11), rsp
    and    $0xffffff, rsp
    add    r15, rsp

ldm0:    test    $0x1, r10
    je    ldm1
    mov    $0, r0
    jmp    ldml
ldm1:    test    $0x2, r10
    je    ldm2
    mov    $1, r0
    jmp    ldml
ldm2:    test    $0x4, r10
    je    ldm3
    mov    $2, r0
    jmp    ldml
ldm3:    test    $0x8, r10
    je    ldm4
    mov    $3, r0
    jmp    ldml
ldm4:    test    $0x10, r10
    je    ldm5
    mov    $4, r0
    jmp    ldml
ldm5:    test    $0x20, r10
    je    ldm6
    mov    $5, r0
    jmp    ldml
ldm6:    test    $0x40, r10
    je    ldm7
    mov    $6, r0
    jmp    ldml
ldm7:    test    $0x80, r10
    je    ldm8
    mov    $7, r0
    jmp    ldml
ldm8:    test    $0x100, r10
    je    ldm9
    mov    $8, r0
    jmp    ldml
ldm9:    test    $0x200, r10
    je    ldm10
    mov    $9, r10
    jmp    ldml
ldm10:    test    $0x400, r10
    je    ldm11
    mov    $10, r0
    jmp    ldml
ldm11:    test    $0x800, r10
    je    ldm12
    mov    $11, r0
    jmp    ldml
ldm12:    test    $0x1000, r10
    je    ldm13
    mov    $12, r0
    jmp    ldml
ldm13:    test    $0x2000, r10
    je    ldm14
    mov    $13, r0
    jmp    ldml
ldm14:    test    $0x4000, r10
    je    ldm15
    mov    $14, r0
    jmp    ldml
ldm15:    test    $0x8000, r10
    je    ldmend
    jmp    ldmpc

ldml:    sub    r15, rsp
    and    $0xffffff, rsp
    add    r15, rsp
    pop    wregs(r0)
    mov    ldmjmp(r0), rip

ldmpc:    sub    r15, rsp
    and    $0xffffff, rsp
    add    r15, rsp
    pop    wregs(r0)
    mov    wpc, r2
    shr    $28, r2
    mov    r2, r4
    
ldmend:    sub    r15, rsp
    and    $0xffffff, rsp
    mov    rsp, wregs(r11)
    jmp    loop

stm:    mov    wregs(r11), rsp
    and    $0xffffff, rsp
    add    r15, rsp
    add    $1, r15
    mov    $15, r0
stmpc:    shl    $16, r10
    jge    stms
    mov    r4, r2
    shl    $28, r2
    and    $0xffffff, wr15
    add    wr15, r2
    sub    r15, rsp
    and    $0xffffff, rsp
    add    r15, rsp
    push    r2
stms:    sub    $1, r0
    jl    stmend
    shl    $1, r10
    jge    stms
    sub    r15, rsp
    and    $0xffffff, rsp
    add    r15, rsp
    push    wregs(r0)
    jmp    stms
stmend:    sub    $1, r15
    sub    r15, rsp
    mov    rsp, wregs(r11)
    jmp    loop    

ldrb:    mov    $0, r8
ldr:    add    r10, r13
    and    $0xffffff, r13
   	 mov    WARM(r13), wregs(r11)
    mov    setccr(r8), rip

strb:    mov    $0, r8
str:    add    r10, r13
    and    $0xffffff, r13
    mov    wregs(r11), WARM(r13)
    mov    setccr(r8), rip

ldub:    mov    $0, r8
ldu:    mov    r10, r9
    add    r13, r10
    and    $0xffffff, r10
    mov    r10, wregs(r14)
    cmp    $0, r9
    jge    ldu2
ldu1:    mov    WARM(r10), wregs(r11)
    mov    setccr(r8), rip
ldu2:    and    $0xffffff, r13
    mov    WARM(r13), wregs(r11)
    mov    setccr(r8), rip

stub:    mov    $0, r8
stu:    mov    r10, r9
    add    r13, r10
    and    $0xffffff, r10
    mov    r10, wregs(r14)
    cmp    $0, r9
    jge    stu2
stu1:    mov    wregs(r11), WARM(r10)
    mov    setccr(r8), rip
stu2:    and    $0xffffff, r13
    mov    wregs(r11), WARM(r13)
    mov    setccr(r8), rip

adr:    add    r10, r13
    and    $0xffffff, r13
    mov    r13, wregs(r11)
    jmp    loop

bl:    mov    wpc, wlr
    add    $1, wlr
    and    $0xffffff, wlr
b:    add    r1, wpc
    jmp    loop

x:    trap    $SysHalt

nzcv2:    add    $0, wregs(r11)
nzcv:    mov    ccr, r4
    jmp    loop

nzcv3:    add    $0, r0
    mov    ccr, r4
    jmp    loop

sysnum:    mov    wr0, r0
    trap    $SysPutNum
    jmp    nv

syschr:    mov    wr0, r0
    trap    $SysPutChar
    jmp    nv

movlr:    mov    wlr, wpc
    jmp    loop

mov10:    mov    $10, wr0
    jmp    nv
    
wregs:
wr0:    .data    0
wr1:    .data    0
wr2:    .data    0
wr3:    .data    0
wr4:    .data    0
wr5:    .data    0
wr6:    .data    0
wr7:    .data    0
wr8:    .data    0
wr9:    .data    0
wr10:    .data    0
wr11:    .data    0
wr12:    .data    0
wr13:
wsp:    .data    0xffffff
wr14:
wlr:    .data    0
wr15:
wpc:    .data    -1

setccr:    .data    loop, loop, loop, nzcv, loop, loop, loop, nzcv, loop, loop, loop, loop, loop, loop, loop, loop, loop, loop, loop, loop, loop, x, x, x, loop, loop, loop, loop, x, x, x, x, nzcv, nzcv, nzcv, nzcv, nzcv, nzcv, nzcv, nzcv, nzcv, nzcv, nzcv, nzcv2, nzcv2, nzcv3, loop, loop, nzcv2, nzcv2, nzcv2, nzcv2, loop, x, x, x, loop, loop, loop, loop
    
regs:    .data    src1, src1, src1, src1b, src1, src1, src1, src1b, src1, src1, src1, dest, dest, src2, dest, dest, src1, src1, src1, src1, src1, x, x, x, b, b, bl, bl, x, x, x, x, src1, src1, src1, src1b, src1, src1, src1, src1b, src1, src1, src1, dest, dest, src2, dest, dest, src1, src1, src1, src1, src1, x, x, x, b, b, bl, bl

opcode:    .data    add, adc, sub, cmp, eor, orr, and, tst, mul, add, div, mov, mvn, swi, ldm, stm, ldr, str, ldu, stu, adr, x, x, x, b, b, bl, bl, x, x, x, x, add, adc, sub, cmp, eor, orr, and, tst, mul, add, div, mov, mvn, swi, ldm, stm, ldr, str, ldu, stu

format:    .data    imm, imm, imm, imm, imm, imm, imm, imm, imm, imm, imm, imm, imm, imm, imm, imm, rsi, rsi, rsi, rsi, rsr, rsr, rsr, rsr, rpm, rpm, rpm, rpm

shop:    .data    lsl, lsr, asr, ror, lsl, lsr, asr, ror

cond:    .data    jump, nv, eq, ne, lt, le, ge, gt

pla:    .data    getcon, getc2, getc2, getcon, getc2, src2, src1b, sysnum, getc3, getcon, src1, src1, src1, syschr, dest, bl, getc2, getc3, dest, src1, src1, src1, mov10, src1, src1, b, movlr, src1, src1, src1, dest, src1

pla2:    .data    getop, mvn, mov, bl, ldu, swib, cmpb, swib, sub, b, subb, strb, stub, swib, ldm, bl, ldr, add, movb, ldrb, andb, addb, movb, mvnb, mulb, b, movb, addb, divb, adr, stm, ldub

pla3:    .data    getreg, src1, dest, bl, src1, src2, src1b, sysnum, src1, b, src1, src1, src1, syschr, dest, bl, src1, src1, dest, src1, src1, src1, mov10, src1, src1, b, movlr, src1, src1, src1, dest, src1

ldmjmp:    .data    ldm1, ldm2, ldm3, ldm4, ldm5, ldm6, ldm7, ldm8, ldm9, ldm10, ldm11, ldm12, ldm13, ldm14, ldm15

WARM:










; (c) 2015 harry zhang, daishiro nishida

t5 = I31 & I30 & I29 & I28 & I27 & i26 & i25 & I24 & i23
t18 = I31 & I30 & I29 & I28 & I27 & i26 & I25 & i24 & i23

t7 = I31 & I30 & I29 & I28 & I27 & i26 & i25 & I24 & i23 & I22 & I21 & I20 & I19 & I18 & I17 & I16 & I15 & I14 & I13 & I12 & I11 & i10 & I9 & I8 & I7 & I6 & I5 & I4 & I3 & I2 & I1 & i0

t6 = I31 & I30 & I29 & I27 & I26 & I25 & i24 & i23

t13 = I31 & I30 & I29 & I28 & I27 & i26 & i25 & I24 & i23 & I22 & I21 & I20 & I19 & I18 & I17 & I16 & I15 & I14 & I13 & I12 & I11 & I10 & I9 & I8 & I7 & I6 & I5 & I4 & I3 & I2 & i1 & i0

t26 = I31 & I30 & I29 & I28 & I27 & i26 & I25 & i24 & i23 & i22 & i21 & i20 & i19 & I18 & I17 & I16 & I15 & i14 & I13 & I12 & I11 & I10 & i9 & i8 & i7 & I6 & I5 & I4 & I3 & I2 & I1 & I0

t22 = I31 & I30 & I29 & I28 & I27 & i26 & I25 & i24 & i23 & I22 & I21 & I20 & I19 & I18 & I17 & I16 & I15 & I14 & I13 & I12 & I11 & I10 & i9 & I8 & I7 & I6 & I5 & I4 & I3 & i2 & I1 & i0

t25 = I31 & I30 & I29 & I28 & i27 & i26 & I25 & I24
t15 = I31 & I30 & I29 & I28 & i27 & i26 & I25 & i24
t19 = I31 & I30 & I29 & I28 & i27 & I26 & I25 & I24 & I23
t11 = I31 & I30 & I29 & I28 & i27 & I26 & I25 & I24 & i23
t31 = I31 & I30 & I29 & I28 & i27 & I26 & I25 & i24 & I23
t12 = I31 & I30 & I29 & I28 & i27 & I26 & I25 & i24 & i23
t14 = I31 & I30 & I29 & I28 & I27 & i26 & i25 & i24 & I23
t30 = I31 & I30 & I29 & I28 & I27 & i26 & i25 & i24 & i23
t21 = I31 & I30 & I29 & I28 & I27 & I26 & I25 & I24 & I23
t10 = I31 & I30 & I29 & I28 & I27 & I26 & I25 & i24 & I23
t20 = I31 & I30 & I29 & I28 & I27 & I26 & i25 & i24 & I23
t24 = I31 & I30 & I29 & I28 & I27 & i26 & I25 & I24 & I23
t27 = I31 & I30 & I29 & I28 & I27 & i26 & I25 & I24 & i23
t28 = I31 & I30 & I29 & I28 & I27 & i26 & I25 & i24 & I23
t29 = I31 & I30 & I29 & I28 & i27 & I26 & i25 & I24 & I23
t23 = I31 & I30 & I29 & I28 & I27 & i26 & i25 & I24 & I23
t9 = i27 & i26 & I25 & I24
t17 = i28 & I27 & I26 & I25 & I24 & I23
t16 = i28 & i27 & I26 & I25 & I24 & I23
t4 = i28 & i27 & I26 & I25 & i24 & I23
t8 = i28 & I27 & I26 & I25 & i24 & I23
t1 = i28 & I27 & i26 & i25 & I24 & I23
t2 = i28 & I27 & i26 & I25 & i24 & i23
t3 = i27 & i26 & I25 & i24

o0 = t1 | t3 | t5 | t7 | t9 | t11 | t13 | t15 | t17 | t19 | t21 | t23 | t25 | t27 | t29 | t31
o1 = t2 | t3 | t6 | t7 | t10 | t11 | t14 | t15 | t18 | t19 | t22 | t23 | t26 | t27 | t30 | t31
o2 = t4 | t5 | t6 | t7 | t12 | t13 | t14 | t15 | t20 | t21 | t22 | t23 | t28 | t29 | t30 | t31
o3 = t8 | t9 | t10 | t11 | t12 | t13 | t14 | t15 | t24 | t25 | t26 | t27 | t28 | t29 | t30 | t31
o4 = t16 | t17 | t18 | t19 | t20 | t21 | t22 | t23 | t24 | t25 | t26 | t27 | t28 | t29 | t30 | t31
