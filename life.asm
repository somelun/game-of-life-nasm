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

;TODO: refactor this
%macro RANDOM 0
        push rcx
        push rdx
        rdtsc
        xor     edx, edx        ; Required because there's no division of EAX solely
        mov     ecx, 2          ; 2 possible values
        div     ecx             ; EDX:EAX / ECX --> EAX quotient, EDX remainder
        mov     eax, edx        ; -> EAX = [0,1]
        pop rdx
        pop rcx

        ; rdtsc
        ; xor al, ah
        ; xor ax, si
        ; xor ax, cx
%endmacro

; TODO: later try to use special symbols
%define live_cell 35 ; '▊'
%define dead_cell 46 ; '░'

        default rel

        global start
        extern _printf
        extern _sleep

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

        test_array:     db   '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', 10
                        db   '.', '.', '#', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', 10
                        db   '.', '.', '.', '#', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', 10
                        db   '.', '#', '#', '#', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', 10
                        db   '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', 10
                        db   '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', 10
                        db   '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', 10
                        db   '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', 10
                        db   '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', 10
                        db   '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', 10
                        db   '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', 10
                        db   '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', 10
                        db   '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', 10
                        db   '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', 10
                        db   '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', 10
                        db   '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', 10
        test_array_len: equ $-test_array

        section .text

    ; used for _printf call
    format          db  "%d", 10, 0


start:
        PRINT clrscrn, clrscrn_len

        mov r9, test_array  ; array_one ; this is current generation
        mov r8, array_two   ; this is next generation

        .step:
                xchg r8, r9
                PRINT r8, array_len

                mov     rdi, 1
                call    _sleep
                PRINT clrscrn, clrscrn_len

                ; jmp .next_generation
                jmp exit    ; for now just skip next generation


.next_generation:
        xor rbx, rbx
        .handle_cell:
                lea r11, [r8 + rbx] ; TODO: i bet this can be optimized
                cmp r11, new_line
                je .next_cell

                ; insert neighbor cells check here

                .next_cell:
                        inc rbx
                        cmp rbx, array_len
                        jne .handle_cell
                        jmp start.step


exit:
        mov       rax, 0x2000001   ; syscall exit
        xor       rdi, rdi          ; exit code 0
        syscall


first_generation:
        RANDOM

        push    rbx
        mov     rdi, format
        mov     rsi, rax
        call    _printf
        pop     rbx

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

                RANDOM

                push    rbx
                mov     rdi, format
                mov     rsi, rax
                call    _printf
                pop     rbx


                loop .init_cell

        .next_line:
                inc     rdx
                mov     rcx, columns
                dec     r9
                cmp     r9, 0
                jne     .init_cell

        ret
