
.model small

.stack 100h

.data
t1 db 'Podaj ci¥g znak¢w : $'
t2 db 'Ci¥g odwr¢cony :'
crlf db 0dh,0ah,'$'

.code
mov ax,@data
mov ds,ax
mov dx,offset t1
mov ah,09h
int 21h
mov cx,0

wpisz:
mov ah,01h
int 21h
push ax
add cx,1
cmp al,27
je dalej
jmp wpisz

dalej:
mov dx,offset crlf
mov ah,09h
int 21h
mov dx,offset t2
mov ah,09h
int 21h

wypisz:
pop dx
mov ah,02h
int 21h
loop wypisz
mov ah,01h
int 21h

koniec:
  mov ah,4ch
  int 21h
  end