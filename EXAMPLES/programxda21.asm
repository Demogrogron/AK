assume cs:kod, ds:dane,ss:stosik

kod segment
error1:
mov dx,offset blad1
mov ah, 09h
int 21h
jmp koniec
error2:
mov dx,offset blad2
mov ah, 09h
int 21h
jmp koniec
error3:
mov dx,offset blad3
mov ah, 09h
int 21h
jmp koniec

start: mov ax,dane
mov ds,ax
mov ax,stosik
mov ss,ax
mov sp,offset szczyt

;pobranie liczby
mov dx,offset powitanie
mov ah,09h
int 21h

;dlugosc wpisanej liczby
mov dx,offset bufor
mov ah,0Ah
int 21h

;czy pobrana rozna od zera
cmp ile,0h
je error1

;czy liczba nie za duza
xor bx,bx
xor cx,cx
mov cl,ile
et1: xor ax,ax
mov al,tab[bx]
sub al,’0′
push ax
;sprawdzenie czy wartosc jest 0-9
cmp ax,10
jnc error2

mov ax,suma
mov dx,10d
mul dx
mov suma,ax
jc error3

pop ax
add suma,ax
jc error3

inc bx
loop et1

;wstawienie $ na koncu tablicy
xor bx,bx
mov bl,ile
mov tab[bx],’$’

;dziesietnie
mov dx,offset dziesietna
mov ah,09h
int 21h

mov dx,offset tab
int 21h

;binarnie
mov dx,offset binarna
mov ah,09h
int 21h
mov cx,16
mov ah,02h
mov dx,suma
rol dx,1
push dx

petla: and dx,0000000000000001b
add dx,’0′
int 21h
pop dx
rol dx,1
push dx
loop petla

;hexadecymalnie
mov dx,offset hexadecymalna
mov ah,09h
int 21h

mov ah,02h
mov cx,4
mov bx,suma
rol bx,4
push bx

petla2: and bx,0000000000001111b
mov dl,hex[bx]
int 21h
pop bx
rol bx,4
push bx
loop petla2

;zakonczenie
mov al,0
mov ah,4Ch
int 21h
koniec: mov al,0
mov ah,4Ch
int 21h

kod ends

dane segment
bufor db 6
ile db ?
tab db 6 dup(?)
suma dw 0
hex db ‘0’,’1′,’2′,’3′,’4′,’5′,’6′,’7′,’8′,’9′,’A’,’B’,’C’,’D’,’E’,’F’,’$’

powitanie db 13,10,’podaj liczbe (0-65535): $’
dziesietna db 13,10,’liczba dziesietnie wynosi: $’
binarna db 13,10,’liczba binarnie wynosi: $’
hexadecymalna db 13,10,’liczba szestnastkowo wynosi: $’
blad1 db 13,10,’nie wpisano zadnej wartosci$’
blad2 db 13,10,’wpisana wartosc nie jest liczba$’
blad3 db 13,10,’wpisana liczba jest zbyt duza$’

dane ends

stosik segment
dw 100h dup(?)
szczyt dw 0

stosik ends

end start