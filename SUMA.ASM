Progr           segment
                assume  cs:Progr, ds:dane, ss:stosik

start:          mov ax,dane
                mov ds,ax
                mov ax,stosik
                mov ss,ax
                mov sp,offset szczyt

		lea dx,Tekst1
      		mov ah,09H
      		int 21H
 
      		lea dx,max
        	mov ah,0Ah
        	int 21h		;wczytanie ³añcucha znaków

		mov ch,0
        	mov cl,ile
		mov bx,0
		mov dx,0
		mov ah,0
petla:        	mov al,tab[bx]	;w pêtli sumowane s¹ cyfry
		sub al,30H
		add dx,ax
                inc bx
		loop petla

		mov bx,10
		mov cx,0
		mov ax,dx
konwersja:	mov dx,0	;konwersja liczby na znaki (tekst)
		div bx
		add dx,30H
		push dx
		inc cx 
		cmp ax,0
		jne konwersja

		mov ah,09H
		lea dx,Tekst2
      		int 21H
wyswietl:	pop dx		;wyœwietlanie kolejnych znaków (cyfr)
		mov ah,02H
		int 21H
		loop wyswietl
               
      		mov ah,4ch
	        mov al,0
	        int 21h
Progr           ends

dane            segment
		Tekst1 db 13,10,'Prosze o podanie cyfr (do 10 cyfr): $'
		
		Tekst2 db 10,13,'suma cyfr = $'

		max db 11
		ile db ?
		tab db 11 dup(0)

dane            ends

stosik          segment stack
                dw    100h dup(0)
szczyt          Label word
stosik          ends

end start