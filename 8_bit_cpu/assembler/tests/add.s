MAIN:
mov r1, #0
mov r2, #1
mov r0, #5
nop
st r0, r1, r2
ld r2, r1, r2
mov r3, #241
mov r4, #31
and r5, r3, r4
or r6, r3, r4
mov r1, #255
mov r6, #0
mov r7 #12
LOOP:
    add r0, r0, r0
    sub r1, r1, r0
    beq r6, r6, r7
