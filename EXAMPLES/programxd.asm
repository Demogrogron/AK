Progr           segment
                assume  cs:Progr, ds:dane, ss:stosik

start:          mov     ax,dane
                mov     ds,ax
                mov     ax,stosik
                mov     ss,ax
                mov     sp,offset szczyt

                mov     dx, offset WYPISZ  ;============================
                mov     ah, 09h            ;=======WYPISZ TEKST=========
                int     21h                ;============================

                mov     dx, offset ENT     ;============================
                mov     ah, 09h            ;=======ENTER NEW LINE=======
                int     21h                ;============================


                ;mov     bx, offset LICZBA
                ;mov     dx, [bx]
                ;mov     ah, 2
                ;int     21h
                mov cx, 0
        ZAMIANA_SZESN:
                inc      cx
                mov      bx, offset LICZBA
                mov      ax, [bx]
                mov      dl, 16    ; do rejestru dl przypisz wartosc 2
                div      dl     ; wykonaj dzielenie ax div dl

                mov      [LICZBA], al
                                
                                ;mov      bx, offset LICZBA
                                ;mov      dx, [bx]
                                ;mov      ah, 2
                                ;int      21h

                cmp      ah, 10
                JB       ZALADUJ_CYFRE
                JMP              ZALADUJ_ZNAK
                        ZALADUJ_CYFRE:
                                add ah, 48
                                mov TYMCZ, al
                                xor al, al
                                push ax
                                mov al, TYMCZ
                                JMP KONTYNUJ            
                        ZALADUJ_ZNAK:
                                add ah, 55
                                mov TYMCZ, al
                                xor al, al
                                push ax
                                mov al, TYMCZ
                                JMP KONTYNUJ
           KONTYNUJ:     

                cmp      al, 0 ;sprawdz czy wynik dzielenia div nie jest rowny 0
                JE       WYPISZ_SZESN ; jesli tak skocz do wypisania binarnych
                JMP      ZAMIANA_SZESN

        
                
                WYPISZ_SZESN:

                pop      ax
                mov      dx, ax
                mov      ah, 2
                int      21h
                LOOP WYPISZ_SZESN
                        
                                
                
                                
                                
                mov     ah,4ch                  ;==========================================
                mov         al,0                ;============KONIEC PROGRAMU===============
                int         21h                 ;==========================================
Progr           ends

dane            segment
                                WYPISZ db 'Zamiana z dziesietnego na binarny$'
                                ENT db 0Ah,'$'
                                LICZBA db 93
                                                                ;LICZBA2 db 78
                                CYFRA   db 0
                                                                TYMCZ   db 0
                               
dane            ends

stosik          segment
                dw    100h dup(0)
szczyt          Label word
stosik          ends

end start