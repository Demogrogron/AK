; biblioteczka procedur textowych
; ostatnia aktualizacja 27.X.1997

dane segment public

public crlf,pdre,sde,sok,spk,se

crlf db 0dh,0ah,'$' ;powrot karetki,nastepna linia
pdre dw 184fh       ;wspolzedne prawego,dolnego rogu ekranu
sde dw 1827h        ;wspolzedne srodkowego dolu ekranu
sok dw 0c4fh        ;wspolzedne srodka ostatniej kolumny (79)
spk dw 0c00h        ;wspolzedne srodka pierwszej kolumny (0)
se dw 0c27h         ;wspolzedne srodka ekranu
;ciazn dw 256 dup (' ')
dane ends

kody segment public

   public pisz,piszln,czkl
   assume cs:kody,ds:dane

pisz proc           ;wypisuje ciag znakow o przesunieciu w DX
   mov ah,09h       ;zaczyna wypisywac od biezacej pozycji kursora
   int 21h          ;wpisac offset do DX
   ret
pisz endp

piszln proc         ;wypisuje ciag znakow o przesunieciu w DX
   call pisz        ;oraz ustawia kursor na poczatku nastepnej linii
   lea dx,crlf      ;zaczyna wypisywac od biezacej pozycji kursora
   call pisz        ;wpisac offset do DX
   ret
piszln endp

czkl proc           ;wczytuje znak z klawiatury do AL
   mov ah,01h
   int 21h
   ret
czkl endp

;czln proc           ;wczytuje ciag 256 znakow z klawiatury
;        mov dx,256
;pocz:   call czkl   ;do zmiennej ciagzn
;
;        cmp al,0dh
;        je dalej
;        jmp pocz
;dalej:   ret
;czln endp

kody ends
end