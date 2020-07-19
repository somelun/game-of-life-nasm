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

; TODO: later try to use special symbols
%define live_cell_symbol '*' ; '▊'
%define dead_cell_symbol '.' ; '░'

        default rel

        global start
        extern _printf
        extern _msws

        section .data

        ; check https://stackoverflow.com/a/30253373 for the details
        clrscrn     db 27, "[2J", 27, "[H"
        clrscrn_len equ $-clrscrn

        new_line:   equ 10  ; ascii code for new line

        rows        equ 16
        columns     equ 16
        array_len   equ rows * columns + rows

        ; initialize both arrays with new_line symbol
        array_one   times array_len db new_line
        array_two   times array_len db new_line

        live_cell   equ 111
        dead_cell   equ 110

        equal_str       db "Equal", 10
        not_equal_str   db "Not Equal", 10


        section .text

    format:
        db  "%d", 10, 0


start:
        ; PRINT clrscrn, clrscrn_len
        ; PRINT message, message_len

        ; int 3

        ; mov eax, 1
        ; mov ebx, 1

        ; cmp eax, ebx
        ; jz short .equal
        ; PRINT not_equal_str, 10
        ; jmp .continue

        ; .equal:
        ;     PRINT equal_str, 6
        ; .continue:

        call initialize

        PRINT array_one, array_len

exit:
        mov       rax, 0x2000001   ; syscall exit
        xor       rdi, rdi          ; exit code 0
        syscall


initialize:
        push    rbx
        call    _msws
        pop     rbx
        ; now rax contains random sequence

        ; push    rbx
        ; mov     rdi, format
        ; mov     rsi, rax
        ; call    _printf
        ; pop     rbx

        mov     rdx, array_one  ; address of next byte to write
        mov     rcx, columns    ; use rcx for loop
        mov     r9, rows

        .init_cell:
                ; mov rax, 1
                mov rbx, 1
                ; ; int 3
                cmp rax, rbx
                ; int 3

                jnz .init_as_dead
                mov byte [rdx], live_cell_symbol
                jmp .continue
                .init_as_dead:
                    mov byte [rdx], dead_cell_symbol
        .continue:
                inc rdx
                loop .init_cell

        .next_line:
                inc     rdx
                mov     rcx, columns
                dec     r9
                cmp     r9, 0
                jne     .init_cell

        ret
