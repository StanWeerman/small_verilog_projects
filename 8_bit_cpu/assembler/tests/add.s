MAIN:
mov r0, #1
mov r1, #255
LOOP:
    add r0, r0, r0
    sub r1, r0, r1
    jmp @LOOP
