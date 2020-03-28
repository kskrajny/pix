section .bss
    digitSpace resb 100
    digitSpacePos resb 8

section .data
    text db "Hello, World!",10,0

section .text
    global _start

;pix:
    ;rdi *ppi - wskaznik na tablice
    ;rsi *pidx - wskaznik na iterator
    ;rdx max - liczba, przeniesc do r12

%macro addFract 0       ;dodaje czesc sumy do calosci
    mov r9, 8           ;tworzymy mianownik
    imul r9, r11
    add r9, r8
    mov rdx, 0          
    mov rax, r10        ;teraz chce miec r10/r9
    div r9
    mov rdx, 0      
    imul rcx            ;liczymy 2^32*rcx/r9
    add rbx, rax        ;dodajemy ulamek mod(2^32) 
%%skip:
%endmacro

_start:

    mov r12, 2
    imul r12, 8
    call _sum

    movsx rax, ebx
    call _printRAX

    mov rax, 60
    mov rdi, 0
    syscall


_sum:
            ;r9 przez to dzielimy w addFract
            ;r8 pomaga stworzyc mianownik
            ;rcx bedzie licznikiem ulamkow
    mov r11, 9          
    mov rbx, 0              ;tu bedzie wynik
    mov r10, 1              ;to do mnozenia
_sumLoop:
 
    cmp 0, r12            ;czy konczyc petle
    je endSum
    
    mov rcx, 4
    mov r8, 1
    addFract

    mov rcx, -2
    mov r8, 4
    addFract

    mov rcx, -1
    mov r8, 5
    addFract

    mov rcx, -1
    mov r8, 6
    addFract

    dec r12
    imul r10, 4
    jmp _sumLoop
endSum:
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
