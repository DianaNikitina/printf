%include 'macros.inc'

global my_printf

section .bss
char resb 1

;0) str macr putchar
;1) in consol macr putchar
;2) %c jmp -> %x -> %o, %b (made general func) -> %d -> in c

;read only data
section .rodata
jmp_table:
                    dq get_b
                    dq get_c
                    dq get_d
                    FILL_RANGE unget_spec, 'e', 'n'
                    dq get_o        
                    FILL_RANGE unget_spec, 'p', 'r'
                    dq get_s          
                    FILL_RANGE unget_spec, 't', 'w'
                    dq get_x            

section .text
;======================================
;r12d - save arg index
;r13 - save first address in stack
;======================================
get_next_arg:       ;push in stack
                    cmp r12d, 0
                    je first_arg_rsi
                    cmp r12d, 1
                    je second_arg_rdi
                    cmp r12d, 2
                    je third_arg_rcx
                    cmp r12d, 3
                    je forth_arg_r8
                    cmp r12d, 4
                    je fifth_arg_r9
                    jmp arg_stack


first_arg_rsi:
                    mov rax, r14
                    inc r12d
                    ret

second_arg_rdi:
                    mov rax, r15
                    inc r12d
                    ret

third_arg_rcx:
                    mov rax, r10
                    inc r12d
                    ret  

forth_arg_r8:
                    mov rax, r11
                    inc r12d
                    ret

fifth_arg_r9:
                    mov rax, rbx
                    inc r12d
                    ret

arg_stack:
                    mov eax, r12d
                    sub eax, 5
                    mov rax, [r13 + rax*8]
                    inc r12d
                    ret    


my_printf:
                    ;start prologue
                    ;to save old data
                    ;put rbp (base pointer) in stack
                    push rbp
                    ;mov in rbp new stack pointer after push rbp
                    mov rbp, rsp
                    push rbx
                    push r12
                    push r13
                    push r14
                    push r15
                    ;end prologue

                    ;str = const char* in printf, rdi = *str
                    ;rdi -> rsi -> rdx -> rcx -> r8 -> r9
                    mov r14, rsi
                    mov r15, rdx        
                    mov r10, rcx        
                    mov r11, r8        
                    mov rbx, r9 

                    mov rsi, rdi        ;format str

                    xor r12d, r12d

                    ;put r13 - start of stack
                    mov r13, rbp
                    add r13, 16       

                    ;al = 1st symbol in const str
put_str:            mov al, byte [rsi]
                    cmp al, 0
                    je exit
                    cmp al, '%'
                    je get_percent
                    ;output char in const str
                    PUTCHAR rsi
                    inc rsi
                    jmp put_str


get_percent:        inc rsi
                    cmp al, 'b'
                    jb unget_spec
                    cmp al, 'x'
                    ja unget_spec

                    ;bias from jmp_table
                    movzx eax, al
                    sub eax, 'b'
                    lea rbx, [rel jmp_table]        ; relocatable adress/ NOT ABSOLUT
                    jmp [rbx + rax*8]               ;8 byte each of element


;======================================
;SPECIFICATORS %c, %s, %d, %x, %o, %b
;======================================                           


;======================================
;get_c: char = c
;rsi++ 
;======================================
get_c:              call get_next_arg
                    mov [char], al
                    PUTCHAR char
                    inc rsi
                    jmp put_str

;======================================
;get_s: rdx = rax
;al = &rdx
;cycle: rsi++ -> read str
;======================================

get_s:              call get_next_arg
                    mov rdx, rax

print_str:          mov al, [rdx]
                    cmp al, 0
                    je done_str
                    mov [char], al
                    PUTCHAR char
                    inc rdx
                    jmp print_str

done_str:           inc rsi
                    jmp put_str

;======================================
;get_b: rdx = rax
;cl = degree 1 (2^1)
;rsi++
;======================================
get_b:
                    call get_next_arg
                    mov  rdx, rax
                    mov  cl, 1
                    call print_rec
                    inc  rsi
                    jmp  put_str

;======================================
;get_o: rdx = rax
;cl = degree 3 (2^3)
;rsi++
;======================================
get_o:
                    call get_next_arg
                    mov  rdx, rax
                    mov  cl, 3
                    call print_rec
                    inc  rsi
                    jmp  put_str

;======================================
;get_x: rdx = rax
;cl = degree 4 (2^4)
;rsi++
;======================================
get_x:
                    call get_next_arg
                    mov  rdx, rax
                    mov  cl, 4
                    call print_rec
                    inc  rsi
                    jmp  put_str
;======================================
;print_hex_oct_bin_rec
;rdx = rax
;push rdx
;cl - degree 2
;======================================
print_rec:
                    ;if one sign
                    mov eax, 1
                    shl eax, cl
                    cmp rdx, rax
                    jb one_digit

                    ;else
                    ;save rdx 
                    push rdx
                    shr  rdx, cl
                    call print_rec
                    pop  rdx

one_digit:
                    mov  rax, rdx
                    cmp cl, 4
                    je skip
                    cmp cl, 3
                    jne skip_2
                    and rax, 0x07
                    jmp digit
skip_2:             and rax, 0x01
                    jmp digit

skip:               and  rax, 0x0F
                    cmp  al, 10
                    jb   digit
                    add  al, 'a' - 10
                    jmp  out

digit:
                    add  al, '0'

out:
                    mov  [char], al
                    PUTCHAR char
                    ret


;======================================
;get_d
;rdx = eax with save sign
;rsi++
;======================================
get_d:              call get_next_arg
                    movsxd rdx, eax

                    ;test > 0 or < 0
                    test rdx, rdx
                    jge no_neg

                    ;number < 0
                    neg rdx
                    mov byte [char], '-'
                    PUTCHAR char
no_neg:             
                    call print_dec
                    inc rsi
                    jmp put_str

;======================================
;print_dec: rax = whole, rdx = remainder
;push rdx
;======================================
print_dec:          


                    cmp rdx, 10
                    jb one_digit_dec

                    mov rax, rdx
                    mov rcx, 10
                    xor rdx, rdx
                    div rcx
                    push rdx
                    mov rdx, rax
                    call print_dec
                    pop rdx


one_digit_dec:      mov al, dl
                    add al, '0'
                    mov [char], al
                    PUTCHAR char
                    ret
;======================================
;unget_spec
;rsi++
;======================================
unget_spec:         mov byte [char], '%'
                    PUTCHAR char

                    mov al, [rsi]
                    mov [char], al
                    PUTCHAR char

                    inc rsi
                    jmp put_str


                    ;restore regs
exit:               pop r15
                    pop r14
                    pop r13
                    pop r12
                    pop rbx

                    mov rsp, rbp
                    pop rbp

                    ret