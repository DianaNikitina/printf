%include 'macros.inc'
global _start

section .bss
char resb 1
; text_buffer resb 1024

;0) str macr putchar
;1) in consol macr putchar
;2) %c jmp -> %x -> %o, %b (made general func) -> %d -> in c

section .data
filename db "printf.txt", 0

section .text
_start:
                    ;prologue
                    ;to save old data
                    ;put rbp (base pointer) in stack
                    push rbp
                    ;mov in rbp new stack pointer after push rbp
                    mov rbp, rsp
                    ;end prologue

                    ;2 - sys_open (file) 
                    mov rax, 2
                    ;put rbx beginning address file
                    mov rdi, filename
                    ;only read 
                    mov rsi, 0
                    ;while reeding you can put 0
                    mov rdx, 0
                    ;rax = file description (number)
                    syscall

                    ;save descriptor 
                    mov r8, rax

                    ;0 - sys_read (file)
read_file:          mov rax, 0
                    ;rdi = file descriptor 
                    mov rdi, r8
                    ;rsi = char (space for read)
                    mov rsi, char
                    ;read 1 byte
                    mov rdx, 1
                    ;rax = number of bytes read
                    syscall

                    ;compare rax vs 0
                    cmp rax, 0
                    ;if rax == 0 goto end_file
                    jle end_file

                    ;put char in consol
                    PUTCHAR char

                    ;goto read_file
                    jmp read_file

end_file:           ;close file, 3 - sys_close
                    mov rax, 3
                    mov rsi, r8
                    syscall

                    FINISH 1