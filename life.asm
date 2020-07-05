; first param - what to print
; second param - size
%macro  PRINT 2
    pusha   ; save registers to stack
    pushf   ; save FLAGS to stack

    push    dword %2
    push    dword %1
    push    dword 1 ; stdout descriptor
    mov     eax, 4  ; sys_write number is 4
    push    eax
    int     80h
    add     esp, 16

    popf    ; restore FLAGS from stack
    popa    ; restore registers from stack
%endmacro

global start

section .bss

section .data

    new_line:   equ 10  ; ascii code for new line

    rows        equ 64
    columns     equ 64
    array_len   equ rows * columns + rows

    ; check https://stackoverflow.com/a/30253373 for the details
    clrscrn     db 27, "[2J", 27, "[H"
    clrscrn_len equ $-clrscrn

section .text

start:
    xor     eax, eax
    PRINT clrscrn, clrscrn_len

exit:
    push    dword 0
    mov     eax, 1
    push    eax
    int     80h
