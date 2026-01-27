MAIN:
mov r0, #1
st r0, #01
ld r2, #01
mov r3, #241
mov r4, #31
and r5, r3, r4
or r6, r3, r4
mov r1, #255
LOOP:
    add r0, r0, r0
    sub r1, r1, r0
    jmp @LOOP
