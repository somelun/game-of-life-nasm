; this is for the help, because I always forget this
; db - 1
; dw - 2
; dd - 4

; list of syscalls
; /Library/Developer/CommandLineTools/SDKs/MacOSX10.15.sdk/usr/include/sys/syscall.h

; first param - what to print
; second param - size
%macro  PRINT 2
        mov     rax, 0x2000004      ; syscall write
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


;   0 1 0 0 10
;   0 0 1 0 10
;   1 1 1 0 10
;   0 0 0 0 10
;   0 0 0 0 10
;
;   0 1 0 0 10 0 0 1 0 10 1 1 1 0 10 0 0 0 0 10 0 0 0 0 10
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   P P P 0 10
;   P T P 0 10
;   P P P 0 10
;   0 0 0 0 10
;   0 0 0 0 10
;
;   P P P 0 10 P T P 0 10 P P P 0 10 0 0 0 0 10 0 0 0 0 10
;   6 5 4 3  2 1 0 1 2  3 4 5 6
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   0 1 0 0 10
;   0 P P P 10
;   1 P T P 10
;   0 P P P 10
;   0 0 0 0 10
;
;   0 1 0 0 10 0 P P P 10 1 P T P 10 0 P P P 10 0 0 0 0 10
;                6 5 4  3 2 1 0 1  2 3 4 5 6
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   P P 0 0 10
;   P P 1 0 10
;   1 1 1 0 10
;   0 0 P P 10
;   0 0 P T 10
;
;   P P 0 0 10 P P 1 0 10 1 1 1 0 10 0 0 P P 10 0 0 P T 10
;   1 2                                  6 5  4 3 2 1 0  1
;
;
;
;   0 1 0 0 10
;   0 0 1 0 10
;   P P 1 P 10
;   T P 0 P 10
;   P P 0 P 10
;
;   P P 0 0 10 P P 1 0 10 1 1 1 0 10 0 0 P P 10 0 0 P T 10
;   1 2                                  6 5  4 3 2 1 0  1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

        new_line    equ 10  ; ascii code for new line

        rows        equ 16
        columns     equ 16
        array_len   equ rows * columns + rows

        ; initialize both arrays with new_line symbol
        array_one   times array_len db new_line
        array_two   times array_len db new_line

        test_array      db   '#', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '#', 10
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
                        db   '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '#', 10
                    ;        255                                                                        270
        test_array_len  equ $-test_array

        section .text

        ; used for _printf call
        format          db  "%d", 10, 0


start:
        ; PRINT clrscrn, clrscrn_len

        mov r9, test_array  ; array_one ; this is current generation
        mov r8, array_two   ; this is next generation

        .step:
                xchg r8, r9
                ; PRINT r8, array_len

                ; mov     rdi, 1
                ; call    _sleep
                ; PRINT clrscrn, clrscrn_len

                ; ; Begin Test
                ; xor rcx, rcx
                ; mov r11, 255
                ; call check_left

                ; mov     rdi,    format
                ; mov     rsi,    rcx
                ; call    _printf
                ; ; End Test

                ; jmp next_generation
                jmp exit    ; for now just skip next generation


next_generation:
        xor rbx, rbx
        .handle_cell:
                cmp byte [r8 + rbx], new_line
                je .next_cell

                xor rcx, rcx
                mov r11, rbx

                ; insert neighbor cells check here
                call check_left
                call check_right
                call check_top_left
                call check_top
                call check_top_right
                call check_bottom_left
                call check_bottom
                call check_bottom_right

                .next_cell:
                        inc rbx
                        cmp rbx, array_len
                        jne .handle_cell
                        jmp start.step


exit:
        mov       rax, 0x2000001    ; syscall exit
        xor       rdi, rdi          ; exit code 0
        syscall


; rcx - live cells counter
; r11 - current cell to check
check_left:
        push r11
        mov r15, columns
        add r15, 1  ; +1 here, because i have additional column of 10

        ; calculate current column % r15, if ==0, then its left column
        xor rdx, rdx
        mov rax, r11
        div r15

        cmp rdx, 0  ; reminder from div goes to rdx
        je .else_branch
        dec r11
        jmp .continue
        .else_branch:
                add r11, columns
                dec r11

        .continue:
                cmp byte [r8 + r11], live_cell
                jne .done
                inc rcx
                .done:
                        pop r11
                        ret

; rcx - live cells counter
; r11 - current cell to check
check_right:
        push r11
        pop r11
        ret

; rcx - live cells counter
; r11 - current cell to check
check_top_left:
        push r11
        pop r11
        ret

; rcx - live cells counter
; r11 - current cell to check
check_top:
        push r11
        pop r11
        ret

; rcx - live cells counter
; r11 - current cell to check
check_top_right:
        push r11
        pop r11
        ret

; rcx - live cells counter
; r11 - current cell to check
check_bottom_left:
        push r11
        pop r11
        ret

; rcx - live cells counter
; r11 - current cell to check
check_bottom:
        push r11
        pop r11
        ret

; rcx - live cells counter
; r11 - current cell to check
check_bottom_right:
        push r11
        pop r11
        ret


; use this one later
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
