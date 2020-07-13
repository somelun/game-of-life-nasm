; this is for the help, because I always forget this
; db - 1
; dw - 2
; dd - 4

; list of syscalls
; /Library/Developer/CommandLineTools/SDKs/MacOSX10.15.sdk/usr/include/sys/syscall.h

; first param - what to print
; second param - size
%macro  PRINT 2
        mov     rax, 0x2000004     ; syscall write
        mov     rdi, 1              ; stdout identifier
        mov     rsi, %1
        mov     rdx, %2
        syscall
%endmacro

global start

section .bss

section .data

        ; check https://stackoverflow.com/a/30253373 for the details
        clrscrn     db 27, "[2J", 27, "[H"
        clrscrn_len equ $-clrscrn

        new_line:   equ 10  ; ascii code for new line

        rows        equ 64
        columns     equ 64
        array_len   equ rows * columns + rows

        ; initialize both arrays with new_line symbol
        array_one   times array_len db new_line
        array_two   times array_len db new_line

        live_cell   equ 111
        dead_cell   equ 110

        ;live_cell_symbol db '▊'
        ;dead_cell_symbol db '░'

        message:  db '░', '░', '░', '░', '░', '░', '░', '░', '░', '░', '░', '░', '░', '░', '░', '░', 10
        message_len: equ $-message

section .text

start:
        ; PRINT clrscrn, clrscrn_len
        PRINT message, message_len
        PRINT message, message_len
        PRINT message, message_len
        PRINT message, message_len
        PRINT message, message_len
        PRINT message, message_len
        PRINT message, message_len
        PRINT message, message_len
        PRINT message, message_len
        PRINT message, message_len
        PRINT message, message_len
        PRINT message, message_len
        PRINT message, message_len
        PRINT message, message_len
        PRINT message, message_len
        PRINT message, message_len


        ; call initialize

exit:
        mov       rax, 0x2000001   ; syscall exit
        xor       rdi, rdi          ; exit code 0
        syscall


initialize:
        mov rax, 0x02000139 ; store system time
        xor rdi, rdi
        syscall

        ; PRINT eax, 32
        ; mov r8w, ax  ; use only ax form it
        ; and ax, 1    ; check if this value is odd
        ; ret


