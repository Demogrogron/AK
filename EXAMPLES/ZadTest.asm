;dlugosc bufora - 4000
Progr           	segment
					assume  cs:Progr, ds:dane, ss:stosik
;-------------------makra------------------------------
Czysc MACRO

		mov di,0												;Wybieramy 0 pixel do czyszczenia
		mov cx, 320*200									;do CXa wpisujemy rozmiar ekranu
		mov al,0												;0-czarny ekran, tym czyscimy calosc. Adresacja natychmiastowa.
		rep stosb												;wykona siê CX razy, wysyla do bufora ekranu 0, w wyniku czego uzyskujemy czarny ekran.
		
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
		MOV DI, txtWsp										;do rejestru DI wrzuca wartoœæ etykiety txtWsp, wskazuje lew¹ górn¹ czêœæ kwadratu, skad zaczynamy go rysowaæ

		MOV AH,2											;10-kolor kwadratu
		MOV AL,'0'											;znak X
		
		MOV CX,5												;wysokosc na 5 wierszy
petlagraf:			
		MOV BX,CX											;licznik petli wrzucamy do BXa
		MOV CX,80											;wrzucamy 10 do CX, ¿eby 5 razy 10 "X" narysowa³o
		REP STOSW											;STOSW wykona siê 10 razy, STOSW przesylanie 16bitow do bufora ekranu
		ADD DI,140											;Dodajemy 140, ¿eby w nastepnej linii narysowa³o kolejne, 140 poniewa¿ 			
		MOV CX,BX											;Cofamy licznik, zeby wydobyc t¹ "5" 																
		;LOOP petlagraf										;petla sie wykona 5 razy. 
RET					

Save:															;zapisuje bufor ekranu do pamiêci komputera, ¿eby przy poruszaniu siê kwadratu ekran siê odœwie¿a³ ca³y czas
		MOV AX,dane										;te 4 liniki wrzucaj¹ do ES:DI adres etykiety zrzut
		MOV ES,AX
		LEA AX,zrzut
	    MOV DI,ax
		
		LDS SI,DWORD PTR VidOrigin					;wrzucamy do DS:SI adres bufora ekranu 
		MOV CX,2000
		REP MOVSW											;REP oznacza tyle, ze MOVSW wykona sie tyle razy ile jest w CX czyli 2000 razy.  MOVSW przesyla dane z DS:SI do ES:DI. Przeœle z bufora ekranu do zrzutu po 16bajtów
		MOV AX,dane										;nadpisywalismy DS, musismy z powrotem przywrocic pierwotna wartosc na segment danych. Zmienialismy, bo MOVSW korzysta z DSa 
		MOV DS,AX											

RET

wybor:					
		LEA DX, Tekst										;£aduje adres efektywny etykiety Tekst do rejestru DX
        MOV AH, 09H											;wypisywanie
        INT 21H
				
        LEA DX, max
        MOV ah, 0Ah											;0Ah parametr  przerwania, wczytywanie
		INT 21h												;przerwanie DOS obslugujacy klawiature
		

		CMP tab,'1'
		JZ txt
		CMP tab,'2'
		JZ graf1												;skacze max o 128bajtów i wykoczy³by b³¹d, ¿e chcemy wykonaæ "za daleki" skok
		JMP wybor


;-----------------------Tryb tekstowy------------------------------
txt:
		LES DI,DWORD PTR VidOrigin					;wpisuje do pary rejestrów ES:DI adres bufora ekranu
		CALL Save											;wywoluje "Save"

tgora:
		CMP txtWsp,160									;Warunek koñca, ¿ebyœmy nie wyszli poza ekran,
		JL txtloop												;jest wartosc 160 jest mniejsza to skok do etykiety txtloop
		sub txtWsp,160										;odejmujemy 160, jeœli chcemy przejœæ linike wy¿ej, jesli jest poni¿ej "160" to nie mo¿emy przejœæ linikê wy¿ej, tak samo dzia³a "tdol"
		JMP txtloop
tdol:
		CMP txtWsp,3198									;3198 nie mozemy nizej tej wartosci, ostatnia linia do ktorej mozemy przejsc
		JA txtloop												;JA-jesli wieksze
		add txtWsp,160
		JMP txtloop
		
graf1:
		JMP graf
tprawo:															;0-158 to jest max, po którym mo¿emy siê poruszaæ. 
		MOV AX,txtWsp										;do AX wrzucamy wsplórzêdn¹ kwadratu.		
		MOV BL,160											;dzielimy przez 160
		DIV BL
		CMP AH,140											;porownujemy z 140, poniewa¿ nasz kwadrat ma d³ugosæ 20 bajtów i ¿ebyœmy nie wyszli poza ekran.
		JE txtloop												;Jeœli reszta z dzielenia AX z BL bedzie równa 140 ( koniec ekranu ) to skaczemy od razu do txtloop bez przesuniecia ekranu, jeœli ró¿na to kwadrat sie przesunie w prawo. To samo dla tlewo. 
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

		xor ah, ah											;zerowanko AH, adresacja bezpoœrednia
		int 16h													;przerwanie, czeka na znak z klawiatury i umieœci go w AH
	
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
		INT 10h												;uruchom tryb graficzny 13h (320x200 256 kolorów.10h przerwanie bios

		mov ax, 0a000h									;0A000:0000 - pierwszy piksel (bajt)
		mov es, ax											;adres 1 pixela ( lewy górny róg )

gora:															;obs³uga klawiszy, dzia³aj¹ tak samo jak tgora. ekran 320x200, Jak chcesz w gore odejmuje 320, jak chce w dol dodaje 320
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
	
		
		xor ah, ah											;oczekiwanie na naciœniêcie klawisza, zerujemy ah
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
		INT 10h												;powrót do trybu tekstowego

		mov     ah,4ch										;koniec programu
	        mov	    al,0
	        int	    21h

;-----------------------/Tryb graficzny------------------------------		
Ryss:															;kwadrat 100x100
		mov cx,50											;Wysokosc kwadratu wrzucamy do rejestru CX
petlarys:
		mov bx,cx											;petla wykonuje siê 100 razy, ¿ebyœmy narysowali 100x100pixeli kwadrata
		mov cx,50											
		rep stosb												;przesy³a bajt do bufora ekranu 100 razy 
		mov cx,bx											;przywracamy poprzedni CX
		add	di, 270											;dodajemy 220, ¿ebyœmy w nowej lini zaczeli rysowaæ kolejn¹ linikê kwadrata
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