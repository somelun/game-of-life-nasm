; this is for the help, because I always forget this
; db - 1
; dw - 2
; dd - 4

; first param - what to print
; second param - size
%macro  PRINT 2
        mov     rax, 0x02000004
        mov     rdi, 1
        mov     rsi, %1
        mov     rdx, %2
        syscall
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
        ; xor     eax, eax
        PRINT clrscrn, clrscrn_len

        ;call initialize

exit:
        mov       rax, 0x02000001
        xor       rdi, rdi
        syscall


initialize:
        ;

