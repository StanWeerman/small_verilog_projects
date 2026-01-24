MAIN:
mov r0, #1
store r0, #01
load r2, #01
mov r1, #255
LOOP:
    add r0, r0, r0
    sub r1, r1, r0
    jmp @LOOP
