Progr           segment
                assume  cs:Progr, ds:dane, ss:stosik

start:          mov     ax,dane
                mov     ds,ax
                mov     ax,stosik
                mov     ss,ax
                mov     sp,offset szczyt
              
			  lea DX,tekst1
			  mov AH,09H
			  int 21H
			  
			  lea DX,CRLF
			  mov AH,09H
			  int 21H

      		mov     ah,4ch
	        mov	    al,0
	        int	    21h
Progr           ends

dane            segment
				tekst1 DB "witaj swiecie",'$'
				CRLF DB 0DH,0AH,'$'

dane            ends

stosik          segment
                dw    100h dup(0)
szczyt          Label word
stosik          ends

end start