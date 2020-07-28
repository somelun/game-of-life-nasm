; MacOS x64 NASM implementation of Conway's Game of Life



; TODO: later try to use special symbols
%define live_cell 35 ; '▊'
%define dead_cell 46 ; '░'


; print to screen
;   %1 - what to print
;   %2 - size of memory
%macro  PRINT 2
        mov     rax, 0x2000004          ; syscall write
        mov     rdi, 1                  ; stdout identifier
        mov     rsi, %1
        mov     rdx, %2
        syscall
%endmacro


; check if cell is live
;   r8 - array begin,
;   r11 - index of cell,
;   rcx - live cells counter
%macro CHECK_IF_LIVE 0
        cmp byte [r8 + r11], live_cell
        jne %%done
        inc rcx

        %%done:
%endmacro

; move index left
;   current index in r11
;   return index in r11
%macro STEP_LEFT 0
        mov r15, columns
        add r15, 1                      ; +1, because extra column of 10

        xor rdx, rdx                    ; rdx must be zeroed before div
        mov rax, r11                    ; place current column to rax
        div r15                         ; calculate rax % r15
                                        ; reminder from div goes to rdx
        cmp rdx, 0                      ; compare rdx and 0
        je %%else_branch                ; if rdx == 0 -> left column, go to %%else_branch
        dec r11                         ; else just dec r11
        jmp %%done                      ;
                                        ;
        %%else_branch:                  ;
                add r11, r15            ; add r15 to make it looped from the right
                                        ;
        %%done:                         ; exit
%endmacro

; move index right
;   current index in r11
;   return index in r11
%macro STEP_RIGHT 0
        mov r15, columns
        add r15, 1                      ; +1, because extra column of 10

        xor rdx, rdx                    ; rdx must be zeroed before div
        mov rax, r11                    ; place current column to rax
        add rax, 2                      ; calculate (current column + 2) % r15, if == 0, then it is a right column
        div r15                         ; calculate rax % r15
                                        ; reminder from div goes to rdx
        cmp rdx, 0                      ; compare rdx and 0,
        je %%else_branch                ; if rdx == 0 -> right column, go to %%else_branch
        inc r11                         ; else just inc r11
        jmp %%done                      ;
                                        ;
        %%else_branch:                  ;
                sub r11, columns        ; sub columns number from r11
                inc r11                 ; and add 1 to make it looped from the left
                                        ;
        %%done:                         ; exit
%endmacro

; move index up
;   current index in r11
;   return index in r11
%macro STEP_UP 0                        ; TODO: add comments
        mov r15, columns
        add r15, 1                      ; +1, because extra column of 10
                                        ;
        sub r11, r15                    ;
        cmp r11, 0                      ;
        jl %%else_branch                ; if less, make it looped
        jmp %%done                      ;
                                        ;
        %%else_branch:                  ;
                mov r15, array_len      ;
                add r11, r15            ;
                                        ;
        %%done:                         ;
%endmacro

; move index down
;   current index in r11
;   return index in r11
%macro STEP_DOWN 0                      ; TODO: add comments
        mov r15, columns
        add r15, 1                      ; +1, because extra column of 10
                                        ;
        add r11, r15                    ;
        cmp r11, array_len              ;
        jae %%else_branch               ;
        jmp %%done                      ;
                                        ;
        %%else_branch:                  ;
                sub r11, array_len      ;
                                        ;
        %%done:                         ;
%endmacro


;random munber using rdtsc
;   TODO: fix and refactor this
%macro RANDOM 0                         ; TODO: add comments
        push rcx
        push rdx
        rdtsc
        xor     edx, edx        ; required because there's no division of EAX solely
        mov     ecx, 2          ; 2 possible values
        div     ecx             ; edx:eax / ecx --> eax quotient, edx remainder
        mov     eax, edx        ; -> eax = [0,1]
        pop rdx
        pop rcx

        ; rdtsc
        ; xor al, ah
        ; xor ax, si
        ; xor ax, cx
%endmacro


        default rel

        global start
        extern _printf
        extern _sleep


        section .data

        ; see https://stackoverflow.com/a/30253373 for the details
        clrscrn         db 27, "[2J", 27, "[H"
        clrscrn_len     equ $-clrscrn

        new_line        equ 10  ; ascii code for new line

        rows            equ 16
        columns         equ 16
        array_len       equ rows * columns + rows

        ; initialize both arrays with new_line symbol
        array_one       times array_len db new_line
        array_two       times array_len db new_line

        test_array      db   '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', 10
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
        test_array_len  equ $-test_array

        section .text

        ; used for _printf call
        format          db  "%d", 10, 0


start:
        PRINT clrscrn, clrscrn_len

        mov r9, test_array  ; array_one ; this is current generation
        mov r8, array_two   ; this is next generation

        ; int 3

        .step:
                xchg r8, r9
                PRINT r8, array_len

                push rax
                push r8
                push r9
                mov     rdi, 1
                call    _sleep
                PRINT clrscrn, clrscrn_len
                pop r9
                pop r8
                pop rax

                ; ; Begin Test
                ; xor rcx, rcx
                ; mov r11, 2
                ; ; call check_top
                ; STEP_LEFT
                ; CHECK_IF_LIVE

                ; mov rdi, format
                ; mov rsi, rcx
                ; call _printf
                ; ; End Test

                ; int 3
                jmp next_generation
                ; jmp exit    ; for now just skip next generation


next_generation:
        xor rbx, rbx
        .handle_cell:
                cmp byte [r8 + rbx], new_line
                je .next_cell

                xor rcx, rcx
                mov r11, rbx

                ; insert neighbor cells check here
                push r11
                        STEP_LEFT
                        CHECK_IF_LIVE
                pop r11

                push r11
                        STEP_RIGHT
                        CHECK_IF_LIVE
                pop r11

                push r11
                        STEP_UP
                        CHECK_IF_LIVE
                pop r11

                push r11
                        STEP_DOWN
                        CHECK_IF_LIVE
                pop r11

                push r11
                        STEP_LEFT
                        STEP_UP
                        CHECK_IF_LIVE
                pop r11

                push r11
                        STEP_LEFT
                        STEP_DOWN
                        CHECK_IF_LIVE
                pop r11

                push r11
                        STEP_RIGHT
                        STEP_UP
                        CHECK_IF_LIVE
                pop r11

                push r11
                        STEP_RIGHT
                        STEP_DOWN
                        CHECK_IF_LIVE
                pop r11

                mov r10, rcx
                xor rcx, rcx

                ; check current cell
                CHECK_IF_LIVE
                cmp rcx, 1  ; current cell is live
                je .is_live
                cmp r10, 3
                je .should_alive

                .should_alive:
                        mov byte [r8 + r11], live_cell
                        jmp .next_cell

                .is_live:
                        cmp r10, 2
                        jl .should_die
                        cmp r10, 3
                        jg .should_die
                        jmp .next_cell

                .should_die:
                        mov byte [r8 + r11], dead_cell
                        jmp .next_cell

                .next_cell:
                        inc rbx
                        cmp rbx, array_len
                        jne .handle_cell
                        jmp start.step


exit:
        mov       rax, 0x2000001    ; syscall exit
        xor       rdi, rdi          ; exit code 0
        syscall


; TODO: fix, refactor and use this part later
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
