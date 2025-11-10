%include 'mio.inc'

section .data
dec_prompt db "Adj meg egy elojeles decimalis szamot: ",0
hex_prompt db "Adj meg egy pozitiv hexadecimalis szamot: ",0
dec_out db "Decimalis alak: ",0
hex_out db "Hexadecimalis alak: ",0
sum_out db "Osszeg: ",0
hiba_dec db "Hiba: Nem megengedett karakter! Kerem ujra.",0
hiba_hex db "Hiba: Nem megengedett karakter! Kerem ujra.",0
hexa_prefix db "0x",0

section .bss
num1 resd 1
num2 resd 1
sum  resd 1

section .text
global main


main:

    mov eax,dec_prompt
    call mio_writestr
    call readDec
    mov [num1],eax
    call mio_writeln

    call writeDec
    call mio_writeln

    call writeHex
    call mio_writeln

    ;2. szam
    mov eax,hex_prompt
    call mio_writestr
    call readDec
    mov [num2],eax
    call mio_writeln

    call writeDec
    call mio_writeln

    call writeHex
    call mio_writeln

    mov eax,[num1]
    mov ebx,[num2]
    add eax,ebx
    call mio_writeln

    call writeDec
    call mio_writeln

    call writeHex
    call mio_writeln


    ret

readDec:
    ;xor eax,eax

    ; we dont want to destroy the values in the registers so we push them to the stack
    push ebx
    push esi

    ;initialize the registers
    mov esi,1 ; will show us if the num is negative or not
    mov eax, 0; here we read the digits one by one
    mov ebx, 0; here we calculate the digits -> ebx = ebx * 10 + eax(we just read a new digit)

    call mio_readchar

    call mio_writechar ; -> when we type in the terminal we want the char to apear so we see what we wrote

    cmp al,'-'
    jne .loop_start
    
    mov esi,-1
    call mio_readchar
    call mio_writechar ; same as the call above

.loop_start:
    cmp al,13
    je .done_zero
.loop:
    cmp al,13
    je .done
    
    cmp al,'0'
    jb .error_dec
    
    cmp al,'9'
    ja .error_dec

    sub al,'0'           
    

    imul ebx, 10
    add ebx, eax
    
    call mio_readchar
    call mio_writechar ; same as at the start
    
jmp .loop

.done:
    mov eax, ebx

    ; if we had '-' char at the start we will have -1 in esi else 1
    imul eax, esi
    
    pop esi
    pop ebx
    
    ret

.done_zero:
    mov eax, 0

    pop esi
    pop ebx
    
ret
.error_dec:
    mov eax,hiba_dec ; when calling mio_writestr it expects the code to be in eax not esi
    call mio_writeln
    call mio_writestr
    call mio_writeln

    mov eax, 0 ; we should handle the error in main
    pop esi
    pop ebx

    ;jmp readDec ; if error exit
ret

writeDec:
    push eax
    push ebx
    push ecx
    push edx

    cmp eax,0
    jge .pos    ; use jge instead of jns
    
    push eax    ; moving '-' into the lower part of eax will destroy eax, so we push it to the stack first
    mov al,'-'
    call mio_writechar
    pop eax
    neg eax

.pos:
    mov ecx,0
    mov ebx,10
.dec_loop:
    xor edx,edx
    div ebx
    push edx
    inc ecx
    test eax,eax
    jnz .dec_loop

.print_loop:
    cmp ecx,0
    je .done_print
    pop edx
    add dl,'0'
    mov al,dl
    call mio_writechar
    dec ecx
    jmp .print_loop

.done_print:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret


readHex:
    push esi
    push ebx
    push ecx
    push edx

    mov eax,0
    mov ecx,1
    mov edx,0

 .next:
    call mio_readchar
    call mio_writechar
    cmp eax,13
    je .vege
    cmp eax,'-'
    je .negativ
    cmp eax,'0'
    jl .error
    cmp eax,'9'
    jle .decimal
    cmp eax,'A'
    jl .error
    cmp eax,'F'
    jle .hexa
    cmp eax,'a'
    jl .error
    cmp eax,'f'
    jle .convert

    jmp .next

 .negativ:
    mov ecx,-1
    jmp .next

    
 .convert:
    sub eax,32
    jmp .hexa


 .hexa:
    sub eax,'A'
    add eax,10
    imul ebx,0x10
    add ebx,eax
    jmp .next

 .decimal:
    add ebx,eax
    imul ebx,0x10
    jmp .next

 .vege:
    mov eax,ebx
    imul eax,ecx
    pop ebx
    pop ecx
    pop edx
    pop esi
    ret
 .error:
    mov eax,hiba_hex
    call mio_writestr
    ret


writeHex:
    push ebx
    push ecx
    push edx
    push esi

    mov ebx,eax
    mov eax,hexa_prefix
    call mio_writestr

    mov ecx,8


 .loop:
    mov esi,ebx
    shr esi,28
    cmp esi,9
    jle .szamjegy
    jmp .hexa
    
 .hexa:
    add esi,'A'
    sub esi,10
    jmp .kiir


 .szamjegy:
    add esi,'0'
    mov eax,esi
    jmp .kiir

 .kiir:
    call mio_writechar

    shl ebx, 4

loop .loop

    pop ebx
    pop ecx
    pop edx
    pop esi

    ret
    
    
 



