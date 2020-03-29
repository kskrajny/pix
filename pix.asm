section .text
%macro addFract 0       ;dodaje cyfry rozwiniecia ulamka
    mov r9, 8           ;tworzymy mianownik
    imul r9, r12
    add r9, r8          ;mianownik: r9 <- 8r9+r8
    mov r8, r11         ;iterator jako r8
    mov rax, 1
%%loop:                 ;w petli tworzymy 16^(8r11)/q mod(2^64)
    mov rdx, 0
    cmp r8, 1
    jl %%minus
    je %%endLoop
    shl rax, 32
    div r9
    dec r8
    mov rax, rdx
    jmp %%loop
%%endLoop:
    shl rax, cl
    div r9
    mov rax, rdx
    mov rdx, 0
    shl rax, 48
    div r9
    jmp %%last
%%minus:  
    shl rax, cl
    shl rax, 16
    div r9
%%last:
    mov rdx, 0
    imul r10                        
    add rbx, rax        ;dodajemy wynik mod(2^64) 
%endmacro

global pix
extern pixtime
pix:
    push rdi
    push rdx
    push rcx
    push rbp
    push rsi

    rdtsc
    mov rdi, rdx
    shl rdi, 32
    add rdi, rax
    call pixtime
    
    pop rsi
    pop rbp
    pop rcx
    pop rdx
    pop rdi
    push r14
    push r13
    push r12
    push rbx
    mov r14, rdx
                            ;rdi - *ppi - wskaznik na tablic
                            ;rdx - max
                            ;rsi - *pidx - wskaznik na iterator
_takeNext:
    mov r12, 1
    lock xadd [rsi], r12
    inc r12
    cmp r12, r14
    jg _exit
    mov r13, r12
    dec r13
    imul r12, 8
    inc r12
                            ;r12 iterator
                            ;r9 przez to dzielimy w addFract
                            ;r8 pomaga stworzyc mianownik
                            ;r10 bedzie licznikiem ulamkow    
    mov cl, 0               ;to mnozyc razy 1/q
    mov r11, 0              ;ile razy mnozyc 1/q przez 2^32
    mov rbx, 0              ;tu bedzie wynik
_sumLoop:
    
    cmp cl, 32
    jne _skip
    mov cl, 0
    inc r11
    
_skip: 
    cmp r12, 0
    je _endSum
    dec r12

    mov r10, 4
    mov r8, 1
    addFract

    mov r10, -2
    mov r8, 4
    addFract

    mov r10, -1
    mov r8, 5
    addFract

    mov r10, -1
    mov r8, 6
    addFract

    add cl, 4
    jmp _sumLoop
_endSum:

    xor rax, rax
    mov rax, rbx
    shl rax, 16
    shr rax, 32
    shl r13, 2
    add r13, rdi
    mov [r13], eax

    jmp _takeNext
_exit:
      push rdi
    push rdx
    push rcx
    push rbp
    push rsi

    rdtsc
    mov rdi, rdx
    shl rdi, 32
    add rdi, rax
    call pixtime
    
    pop rsi
    pop rbp
    pop rcx
    pop rdx
    pop rdi
    pop rbx
    pop r12
    pop r13
    pop r14
    ret