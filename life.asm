; MacOS x64 NASM implementation of Conway's Game of Life

%define live_cell 35
%define dead_cell 46

; print to screen
;   %1 - what to print
;   %2 - size of memory
%macro PRINT 2
        mov     rax, 0x2000004          ; syscall write
        mov     rdi, 1                  ; stdout identifier
        lea     rsi, [%1]               ; rip-relative for labels, plain copy for registers
        mov     rdx, %2
        syscall
%endmacro


; check if cell is live
;   r8 - array begin,
;   r11 - index of cell,
;   rcx - live cells counter
%macro CHECK_IF_LIVE 0
        cmp     byte [r8 + r11], live_cell
        jne     %%done
        inc     rcx

%%done:
%endmacro

; move index left, wrapping from the first column to the last
;   r8  - current board
;   r11 - index of cell in, index of left neighbor out
;   the cell left of column 0 is the previous row's newline (or -1 for index 0)
%macro STEP_LEFT 0
        dec     r11
        js      %%wrap                  ; index 0 -> -1: wrap
        cmp     byte [r8 + r11], new_line
        jne     %%done                  ; landed on a cell: done
%%wrap:
        add     r11, columns            ; back to the last column of the same row
%%done:
%endmacro

; move index right, wrapping from the last column to the first
;   r8  - current board
;   r11 - index of cell in, index of right neighbor out
;   the cell right of the last column is this row's newline
%macro STEP_RIGHT 0
        inc     r11
        cmp     byte [r8 + r11], new_line
        jne     %%done                  ; landed on a cell: done
        sub     r11, columns            ; back to the first column of the same row
%%done:
%endmacro

; move index up, wrapping from the top row to the bottom row
;   r11 - index of cell in, index of upper neighbor out
%macro STEP_UP 0
        sub     r11, row_len
        jns     %%done                  ; still inside the board: done
        add     r11, array_len          ; above the top: go to the bottom row
%%done:
%endmacro

; move index down, wrapping from the bottom row to the top row
;   r11 - index of cell in, index of lower neighbor out
%macro STEP_DOWN 0
        add     r11, row_len
        cmp     r11, array_len
        jb      %%done                  ; still inside the board: done
        sub     r11, array_len          ; below the bottom: go to the top row
%%done:
%endmacro


;random munber using rdtsc
;   TODO: fix and refactor this
%macro RANDOM 0                         ; TODO: add comments
        push    rcx
        push    rdx
        rdtsc
        xor     edx, edx                ; required because there's no division of EAX solely
        mov     ecx, 2                  ; 2 possible values
        div     ecx                     ; edx:eax / ecx --> eax quotient, edx remainder
        mov     eax, edx                ; -> eax = [0,1]
        pop     rdx
        pop     rcx

        ; rdtsc
        ; xor al, ah
        ; xor ax, si
        ; xor ax, cx
%endmacro


default rel

global _main
extern _printf
extern _usleep


section .data

; see https://stackoverflow.com/a/30253373 for the details
clrscrn         db 27, "[2J", 27, "[H"
clrscrn_len     equ $ - clrscrn

new_line        equ 10  ; ascii code for new line

live_glyph      db "██"
live_glyph_len  equ $ - live_glyph
dead_glyph      db "░░"
dead_glyph_len  equ $ - dead_glyph

rows            equ 10
columns         equ 10
row_len         equ columns + 1         ; cells in a row + its newline
render_buf_len  equ rows * columns * live_glyph_len + rows
render_buf      times render_buf_len db 0
array_len       equ rows * columns + rows

; initialize both arrays with new_line symbol
array_one       times array_len db new_line
array_two       times array_len db new_line

test_array      db   '.', '#', '.', '.', '.', '.', '.', '.', '.', '.', 10
                db   '.', '.', '#', '.', '.', '.', '.', '.', '.', '.', 10
                db   '#', '#', '#', '.', '.', '.', '.', '.', '.', '.', 10
                db   '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', 10
                db   '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', 10
                db   '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', 10
                db   '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', 10
                db   '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', 10
                db   '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', 10
                db   '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', 10
test_array_len  equ $ - test_array

section .text

; used for _printf call
format          db  "%d", 10, 0

_main:
        ; old-style binaries started at 'start' with rsp 16-byte aligned.
        ; now dyld calls _main, and that call pushes an 8-byte return address,
        ; so rsp is 16n-8 here. realign it so later calls (e.g. _sleep) get
        ; the 16-byte aligned stack the ABI requires
        sub     rsp, 8

        PRINT   clrscrn, clrscrn_len

        lea     r9, [rel test_array]    ; array_one ; this is current generation
        lea     r8, [rel array_two]     ; this is next generation

.step:
        xchg    r8, r9
        call    render
        PRINT   render_buf, render_buf_len

        push    r8
        push    r9
        mov     rdi, 50000
        call    _usleep
        pop     r9
        pop     r8

        PRINT   clrscrn, clrscrn_len

        jmp     next_generation


next_generation:
        xor     rbx, rbx
.handle_cell:
        cmp     byte [r8 + rbx], new_line
        je      .next_cell

        xor     rcx, rcx
        mov     r11, rbx

        ; insert neighbor cells check here
        push    r11
        STEP_LEFT
        CHECK_IF_LIVE
        pop     r11

        push    r11
        STEP_RIGHT
        CHECK_IF_LIVE
        pop     r11

        push    r11
        STEP_UP
        CHECK_IF_LIVE
        pop     r11

        push    r11
        STEP_DOWN
        CHECK_IF_LIVE
        pop     r11

        push    r11
        STEP_LEFT
        STEP_UP
        CHECK_IF_LIVE
        pop     r11

        push    r11
        STEP_LEFT
        STEP_DOWN
        CHECK_IF_LIVE
        pop     r11

        push    r11
        STEP_RIGHT
        STEP_UP
        CHECK_IF_LIVE
        pop     r11

        push    r11
        STEP_RIGHT
        STEP_DOWN
        CHECK_IF_LIVE
        pop     r11

        mov     r10, rcx
        xor     rcx, rcx

        ; check current cell
        CHECK_IF_LIVE
        cmp     rcx, 1                  ; current cell is live
        je      .is_live
        mov     byte [r9 + r11], dead_cell
        cmp     r10, 3
        je      .should_alive
        jmp     .next_cell

.should_alive:
        mov     byte [r9 + r11], live_cell
        jmp     .next_cell

.is_live:
        mov     byte [r9 + r11], live_cell
        cmp     r10, 2
        jl      .should_die
        cmp     r10, 3
        jg      .should_die
        jmp     .next_cell

.should_die:
        mov     byte [r9 + r11], dead_cell
        jmp     .next_cell

.next_cell:
        inc     rbx
        cmp     rbx, array_len
        jne     .handle_cell
        jmp     _main.step


render:
        xor     r12, r12                ; i = 0
        lea     r13, [rel render_buf]   ; dst = render_buf

.cell:
        ; check current cell
        mov     al, [r8 + r12]
        cmp     al, new_line
        je      .newline

        ; choose glyph: assume dead, switch to live if needed
        lea     rsi, [rel dead_glyph]   ; glyph = dead_glyph
        cmp     al, live_cell
        jne     .copy_start             ; not live → keep dead, skip next line
        lea     rsi, [rel live_glyph]   ; glyph = live_glyph

.copy_start:
        xor     rcx, rcx                ; k = 0

.copy:
        mov     al, [rsi + rcx]
        mov     [r13], al
        inc     rcx
        inc     r13
        cmp     rcx, live_glyph_len
        jb      .copy
        jmp     .next

.newline:
        mov     byte [r13], new_line
        inc     r13

.next:
        inc     r12
        cmp     r12, array_len
        jb      .cell
        ret


exit:
        mov     rax, 0x2000001          ; syscall exit
        xor     rdi, rdi                ; exit code 0
        syscall

