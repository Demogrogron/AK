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
        	int 21h

		mov ch,0
        	mov cl,ile
		mov bx,0
petla:        	mov al,tab[bx]
		sub al,20H
		mov tab2[bx],al
                inc bx
		loop petla
		
		mov ah,09H
		lea dx,Tekst2
      		int 21H
               
      		mov ah,4ch
	        mov al,0
	        int 21h
Progr           ends

dane            segment
		Tekst1 db 13,10,'Prosze o podanie lancucha znakow (do 10 znakow): $'
		
		Tekst2 db 10,13 
		tab2 db 12 dup('$')

		max db 11
		ile db ?
		tab db 11 dup(0)

dane            ends

stosik          segment stack
                dw    100h dup(0)
szczyt          Label word
stosik          ends

end start