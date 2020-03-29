section .bss
    digitSpace resb 100
    digitSpacePos resb 8

section .text
    global _start

;pix:
    ;rdi *ppi - wskaznik na tablice
    ;rsi *pidx - wskaznik na iterator
    ;rdx max - liczba, przeniesc do r12

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

_start:

    mov r12, 32
    inc r12
    call _sum


print:
    xor rax, rax
    mov rax, rbx
oprint:
    shl rax, 16
    shr rax, 32
    call _printRAX

exit:
    mov rax, 60
    mov rdi, 0
    syscall


_sum:
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
    ret


_printRAX:
    mov rcx, digitSpace
    mov rbx, 10
    mov [rcx], rbx
    inc rcx
    mov [digitSpacePos], rcx

_printRAXLoop:
    mov rdx, 0
    mov rbx, 16
    div rbx
    push rax
    add rdx, 48
    cmp rdx, 58
    jl skip
    add rdx, 7

skip:
    mov rcx, [digitSpacePos]
    mov [rcx], dl

    inc rcx
    mov [digitSpacePos], rcx

    pop rax
    cmp rax, 0
    jne _printRAXLoop

_printRAXLoop2:
    mov rcx, [digitSpacePos]

    mov rax, 1
    mov rdi, 1
    mov rsi, rcx
    mov rdx, 1
    syscall

    mov rcx, [digitSpacePos]
    dec rcx
    mov [digitSpacePos], rcx

    cmp rcx, digitSpace
    jge _printRAXLoop2

    ret
