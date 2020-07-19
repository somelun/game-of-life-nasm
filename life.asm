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
%define live_cell 35 ; '▊'
%define dead_cell 46 ; '░'

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

        equal_str       db "Equal", 10
        not_equal_str   db "Not Equal", 10


        section .text

    format:
        db  "%d", 10, 0


start:
        ; PRINT clrscrn, clrscrn_len
        ; PRINT message, message_len

        call initialize

        PRINT array_one, array_len

exit:
        mov       rax, 0x2000001   ; syscall exit
        xor       rdi, rdi          ; exit code 0
        syscall


initialize:
        rdtsc
        xor     edx, edx        ; Required because there's no division of EAX solely
        mov     ecx, 2          ; 2 possible values
        div     ecx             ; EDX:EAX / ECX --> EAX quotient, EDX remainder
        mov     eax, edx        ; -> EAX = [0,116]
        ; add     eax, 2

        ; push    rbx     ; we need to align stack
        ; call    _msws
        ; pop     rbx
        ; now rax contains random sequence from _msws function call
        ; int 3


        ; push    rbx
        ; mov     rdi, format
        ; mov     rsi, rax
        ; call    _printf
        ; pop     rbx

        mov     rdx, array_one  ; address of next byte to write
        mov     rcx, columns    ; use rcx for loop
        mov     r9, rows

        .init_cell:
                mov rbx, 0
                cmp rax, rbx

                jnz .init_as_dead
                mov byte [rdx], live_cell
                jmp .continue_init
                .init_as_dead:
                    mov byte [rdx], dead_cell
        .continue_init:
                inc rdx
                ; push    rbx
                ; call    _msws
                ; pop     rbx
                ; int 3

                push rcx
                push rdx
                rdtsc
                xor     edx, edx        ; Required because there's no division of EAX solely
                mov     ecx, 2          ; 2 possible values
                div     ecx             ; EDX:EAX / ECX --> EAX quotient, EDX remainder
                mov     eax, edx
                pop rdx
                pop rcx


                loop .init_cell

        .next_line:
                inc     rdx
                mov     rcx, columns
                dec     r9
                cmp     r9, 0
                jne     .init_cell

        ret
