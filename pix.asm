section .text
%macro addFract 0       ;dodaje wartosc opisana nizej do rbx
    mov r9, 8           ;tworzymy mianownik z formuly BBP (8n+i)
    imul r9, r12        ;n=r12, i=r8
    add r9, r8          ;mianownik jest w r9
    mov r8, r11         ;zmiana roli r8 na iterator
    mov rax, 1          
%%loop:                 ;miedzy %%loop a %%last tworzymy wartosc
    mov rdx, 0          ;32 wazniejsze bity to cyfry na pozycjach,
    cmp r8, 1           ;   ktore chcemy aktulanie policzyc
    jl %%minus          ;kolejne 16 biów poprawia precyzje
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
    add rbx, rax        ;rax = (r10\(8r12+r8)*2^(32*(r11)+16))%2^48
%endmacro

global pix
extern pixtime
pix:
    push rdi            ;pushuje na stos aby uniknac problemow
    push rdx
    push rcx
    push rbp
    push rsi

    rdtsc               
    mov rdi, rdx        
    shl rdi, 32
    add rdi, rax        ;do rdi przenosze caly wynik rdtsc
    call pixtime

    pop rsi
    pop rbp
    pop rcx
    pop rdx
    pop rdi
    push r14            ;te rejestry bede chcial zmieniac
    push r13
    push r12
    push rbx
    mov r14, rdx        ;zapisuje argument max funkcji pix
                            ;rdi - *ppi - wskaznik na tablic
                            ;rdx - max
                            ;rsi - *pidx - wskaznik na iterator
_takeNext:
    mov r12, 1          ;zaraz pobiire wartosc spod wskaznika rsi
    lock xadd [rsi], r12;to wywolanie jest atomowe
    inc r12
    cmp r12, r14        ;porownuje z max,
    jg _exit    
    mov r13, r12        ;zapisuje do r13, bo ...
    dec r13
    imul r12, 8         ;... r12 pos;uzy jako iterator
    inc r12  
    mov cl, 0           ;2^cl, przez tyle beds mnozone ułamki
    mov r11, 0          ;ile razy mnozyc ulamek przez 2^32
    mov rbx, 0          ;tu bedzie wynik
_sumLoop:
    
    cmp cl, 32          ;jesli cl to 32 
    jne _skip           
    mov cl, 0           ;wyzerujemy cl oraz zwiekszymy r11
    inc r11             
    
_skip: 
    cmp r12, 0          ;r12 konczy zliczanie sumy z BBP
    je _endSum          
    dec r12

    mov r10, 4           ;r10 - licznik ulamkow z BBP {4,-2,-1}
    mov r8, 1            ;r8 pomoze zapisac mianownik z BBP do r9
    addFract             ;(r10\(8r12+r8)*2^(32*(r11)+16))%2^48
                         ;addFract powyzsza wartosc dodaje do rbx
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
    shl rax, 16         ;pozbywamy się zbędnych cyfr
    shr rax, 32         ;to tez
    shl r13, 2          ;szukamy adresu w tablicy ppi,
    add r13, rdi        ;   aby wisac wynik
    mov [r13], eax      

    jmp _takeNext
_exit:
    push rdi            ;pushuje na stos aby uniknac problemow
    push rdx
    push rcx
    push rbp
    push rsi

    rdtsc
    mov rdi, rdx
    shl rdi, 32
    add rdi, rax
    call pixtime
    
    pop rsi             ;zwracam do rejestrow to co zabralem
    pop rbp
    pop rcx
    pop rdx
    pop rdi
    pop rbx
    pop r12
    pop r13
    pop r14
    ret