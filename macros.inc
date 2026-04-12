%ifndef MACROS_INC
%define MACROS_INC

;======================================
;macros PUTCHAR: get 1 arg(symbol) and 
;output in consol
;======================================
%macro PUTCHAR 1
;to save regs
push rax
push rsi
push rdi
push rdx

;rax = 1 sys_write
mov rax, 1
;rdi = 1 stdout (screen)
mov rdi, 1
;get arg 
mov rsi, %1
;print 1 byte
mov rdx, 1
syscall

pop rdx
pop rdi
pop rsi
pop rax
%endmacro

;======================================
;macros FINISH: exit programm
;======================================
%macro FINISH 1
mov rax, 60
mov rdi, 0
syscall
%endmacro

;======================================
;macro FILL_RANGE: fill unget_spec for
;not copy
;======================================
%macro FILL_RANGE 3
%rep %3 - %2 + 1
                    dq %1
%endrep
%endmacro

%endif