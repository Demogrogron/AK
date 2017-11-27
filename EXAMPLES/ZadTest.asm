;dlugosc bufora - 4000
Progr           	segment
					assume  cs:Progr, ds:dane, ss:stosik
;-------------------makra------------------------------
Czysc MACRO

		mov di,0												;Wybieramy 0 pixel do czyszczenia
		mov cx, 320*200									;do CXa wpisujemy rozmiar ekranu
		mov al,0												;0-czarny ekran, tym czyscimy calosc. Adresacja natychmiastowa.
		rep stosb												;wykona si� CX razy, wysyla do bufora ekranu 0, w wyniku czego uzyskujemy czarny ekran.
		
ENDM


Load MACRO
		LES DI,DWORD PTR VidOrigin 				;wpisz do ES:DI adres bufora ekranu 
		MOV CX,2000										;wpisuje dlugosc bufora
		MOV BX,0												;zerujemy, bo BX przesuwamy
wczyt:															;wczytuje zrzut, zeby bylo tlo
		MOV AX,zrzut[BX]									;do AX przesyla kolejne 16bitow z zrzutu ekranu 
		ADD BX,2												;zwiekszamy BX, wskazuje na nastepna wartosc
		STOSW													;STOSW przesylanie 16bitow do bufora ekranu
		LOOP WCZYT								
ENDM



;---------------------------program-------------------------------
start:         mov     ax,dane
                mov     ds,ax
                mov     ax,stosik
                mov     ss,ax
                mov     sp,offset szczyt
;----------------------------kod---------------------------------------	
		JMP wybor

Kwadrat:
		MOV DI, txtWsp										;do rejestru DI wrzuca warto�� etykiety txtWsp, wskazuje lew� g�rn� cz�� kwadratu, skad zaczynamy go rysowa�

		MOV AH,2											;10-kolor kwadratu
		MOV AL,'0'											;znak X
		
		MOV CX,5												;wysokosc na 5 wierszy
petlagraf:			
		MOV BX,CX											;licznik petli wrzucamy do BXa
		MOV CX,80											;wrzucamy 10 do CX, �eby 5 razy 10 "X" narysowa�o
		REP STOSW											;STOSW wykona si� 10 razy, STOSW przesylanie 16bitow do bufora ekranu
		ADD DI,140											;Dodajemy 140, �eby w nastepnej linii narysowa�o kolejne, 140 poniewa� 			
		MOV CX,BX											;Cofamy licznik, zeby wydobyc t� "5" 																
		;LOOP petlagraf										;petla sie wykona 5 razy. 
RET					

Save:															;zapisuje bufor ekranu do pami�ci komputera, �eby przy poruszaniu si� kwadratu ekran si� od�wie�a� ca�y czas
		MOV AX,dane										;te 4 liniki wrzucaj� do ES:DI adres etykiety zrzut
		MOV ES,AX
		LEA AX,zrzut
	    MOV DI,ax
		
		LDS SI,DWORD PTR VidOrigin					;wrzucamy do DS:SI adres bufora ekranu 
		MOV CX,2000
		REP MOVSW											;REP oznacza tyle, ze MOVSW wykona sie tyle razy ile jest w CX czyli 2000 razy.  MOVSW przesyla dane z DS:SI do ES:DI. Prze�le z bufora ekranu do zrzutu po 16bajt�w
		MOV AX,dane										;nadpisywalismy DS, musismy z powrotem przywrocic pierwotna wartosc na segment danych. Zmienialismy, bo MOVSW korzysta z DSa 
		MOV DS,AX											

RET

wybor:					
		LEA DX, Tekst										;�aduje adres efektywny etykiety Tekst do rejestru DX
        MOV AH, 09H											;wypisywanie
        INT 21H
				
        LEA DX, max
        MOV ah, 0Ah											;0Ah parametr  przerwania, wczytywanie
		INT 21h												;przerwanie DOS obslugujacy klawiature
		

		CMP tab,'1'
		JZ txt
		CMP tab,'2'
		JZ graf1												;skacze max o 128bajt�w i wykoczy�by b��d, �e chcemy wykona� "za daleki" skok
		JMP wybor


;-----------------------Tryb tekstowy------------------------------
txt:
		LES DI,DWORD PTR VidOrigin					;wpisuje do pary rejestr�w ES:DI adres bufora ekranu
		CALL Save											;wywoluje "Save"

tgora:
		CMP txtWsp,160									;Warunek ko�ca, �eby�my nie wyszli poza ekran,
		JL txtloop												;jest wartosc 160 jest mniejsza to skok do etykiety txtloop
		sub txtWsp,160										;odejmujemy 160, je�li chcemy przej�� linike wy�ej, jesli jest poni�ej "160" to nie mo�emy przej�� linik� wy�ej, tak samo dzia�a "tdol"
		JMP txtloop
tdol:
		CMP txtWsp,3198									;3198 nie mozemy nizej tej wartosci, ostatnia linia do ktorej mozemy przejsc
		JA txtloop												;JA-jesli wieksze
		add txtWsp,160
		JMP txtloop
		
graf1:
		JMP graf
tprawo:															;0-158 to jest max, po kt�rym mo�emy si� porusza�. 
		MOV AX,txtWsp										;do AX wrzucamy wspl�rz�dn� kwadratu.		
		MOV BL,160											;dzielimy przez 160
		DIV BL
		CMP AH,140											;porownujemy z 140, poniewa� nasz kwadrat ma d�ugos� 20 bajt�w i �eby�my nie wyszli poza ekran.
		JE txtloop												;Je�li reszta z dzielenia AX z BL bedzie r�wna 140 ( koniec ekranu ) to skaczemy od razu do txtloop bez przesuniecia ekranu, je�li r�na to kwadrat sie przesunie w prawo. To samo dla tlewo. 
		ADD txtWsp,2										
		JMP txtloop
tlewo:
		MOV AX,txtWsp
		MOV BL,160
		DIV BL
		CMP AH,0
		JE txtloop
		SUB txtWsp,2
		JMP txtloop

txtloop:	
		Load														;zaladuj makro.
		CALL Kwadrat										;wywolanie kwadratu

		xor ah, ah											;zerowanko AH, adresacja bezpo�rednia
		int 16h													;przerwanie, czeka na znak z klawiatury i umie�ci go w AH
	
		CMP ah,48h          									;48H-strzalka w gore
		JZ tgora
		CMP ah,4Dh          								;prawo
		JZ tprawo
		CMP ah,4Bh          								;lewo
		JZ tlewo
		CMP ah,50h          									;dol
		JZ tdol

      		mov     ah,4ch									;koniec programu w tym miejscu!
	        mov	    al,0
	        int	    21h

;-----------------------/Tryb tekstowy------------------------------

;-----------------------Tryb graficzny------------------------------
graf:

		MOV AX, 13h
		INT 10h												;uruchom tryb graficzny 13h (320x200 256 kolor�w.10h przerwanie bios

		mov ax, 0a000h									;0A000:0000 - pierwszy piksel (bajt)
		mov es, ax											;adres 1 pixela ( lewy g�rny r�g )

gora:															;obs�uga klawiszy, dzia�aj� tak samo jak tgora. ekran 320x200, Jak chcesz w gore odejmuje 320, jak chce w dol dodaje 320
		CMP rysWsp,320
		JB grafloop
		sub rysWsp,320
		JMP grafloop
dol:
		CMP rysWsp,48000								;32000 ostatnia linia. 
		JA grafloop
		add rysWsp,320
		JMP grafloop
prawo:
		MOV DX,0
		MOV AX,rysWsp
		MOV BX,320
		DIV BX
		CMP DX,270
		JE grafloop											;IDZIE DO GRAFLOOP JESLI ROWNE PO DZIELELNIU. Jesli 220=220
		inc rysWsp
		JMP grafloop
lewo:
		MOV DX,0
		MOV AX,rysWsp
		MOV BX,320
		DIV BX
		CMP DX,0
		JE grafloop
		dec rysWsp
		JMP grafloop

grafloop:
		Czysc													;wyczyscilismy ekran
		mov di,rysWsp										;wybieramy skad rysujemy kwadrat i wrzucamy do rejestru DI
		mov al,15												;3-kolor kwadratu
		call Ryss												;funkcja rysujaca kwadrat
	
		
		xor ah, ah											;oczekiwanie na naci�ni�cie klawisza, zerujemy ah
		int 16h
		CMP ah,48h          									;gora
		JZ gora
		CMP ah,50h          									;dol
		JZ dol
		CMP ah,4Dh          								;prawo
		JZ prawo
		CMP ah,4Bh          								;lewo
		JZ lewo

		MOV AX, 3
		INT 10h												;powr�t do trybu tekstowego

		mov     ah,4ch										;koniec programu
	        mov	    al,0
	        int	    21h

;-----------------------/Tryb graficzny------------------------------		
Ryss:															;kwadrat 100x100
		mov cx,50											;Wysokosc kwadratu wrzucamy do rejestru CX
petlarys:
		mov bx,cx											;petla wykonuje si� 100 razy, �eby�my narysowali 100x100pixeli kwadrata
		mov cx,50											
		rep stosb												;przesy�a bajt do bufora ekranu 100 razy 
		mov cx,bx											;przywracamy poprzedni CX
		add	di, 270											;dodajemy 220, �eby�my w nowej lini zaczeli rysowa� kolejn� linik� kwadrata
		loop petlarys										;petla sie wykona 100 razy.
		RET

;----------------------------/kod---------------------------------------	
Progr           ends

dane            segment
		rysWsp dw 320*65+125
		txtWsp dw 0
                Tekst db 13,10,'Wybierz tryb 1.Tekstowy: $'
                max db 2
                ile db ?
                tab db 2 dup(0)				
		zrzut Dw 4000 dup(1443)
		VidOrigin DD 0B8000000H
		dlugosc dw 320
dane            ends

stosik          segment stack
                dw    100h dup(0)
szczyt          Label word
stosik          ends

end start