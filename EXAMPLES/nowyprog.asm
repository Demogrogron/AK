;przykład realizacji funkcji konwersji liczby 16 bitowej
;liczby szesnastkowej na BCD

.include "8515def.inc"
;zmienne przechowujące po konwersji:
.def    bcd_1 = R0                ;-jednostki
.def    bcd_10 = R1               ;-dziesiątki
.def    bcd_100 = R2              ;-setki
.def    bcd_1tys = R3             ;-tysiące
.def    bcd_10tys = R4            ;-dziesiątki tysięcy
.def    var1lsb = R5              ;zmienne dla operacji arytmetycznych
.def    var1msb = R6
.def    var2lsb = R19
.def    var2msb = R20
.def    temp = R16                ;zmienna ogólnego przeznaczenia
.def    A1 = R17                  ;tu liczba do konwersji (młodszy bajt)
.def    A2 = R18                  ;- / / - (starszy bajt)

.org      0
;---------------------------------------------
;wektory obsługi przerwań
;---------------------------------------------
    rjmp    RESET                 ;po Reset
    reti                          ;External Interrupt 0
    reti                          ;External Interrupt 1
    reti                          ;T/C1 Capture Event
    reti                          ;T/C1 Compare Match A
    reti                          ;T/C1 Compare Match B
    reti                          ;T/C1 Overflow
    reti                          ;T/C0 Overflow
    reti                          ;SPI Transfer Complete
    reti                          ;UART Rx Complete
    reti                          ;UART Data Register Empty
    reti                          ;UART Tx Complete
    reti                          ;Analog Comparator

;---------------------------------------------
;program główny
;---------------------------------------------
RESET:
    ldi    temp,low(RAMEND)       ;ustawienie wskaźnika stosu
    out    SPL,temp
    ldi    temp,high(RAMEND)
    out    SPH,temp
    ldi    A1,$A0                 ;liczba EAA0 (60064 dzies.) jako parametr
    ldi    A2,$EA                 ;wywołania funkcji konwersji
    rcall  hex2dec                ;uruchomienie konwersji
loop:
    rjmp   loop

;---------------------------------------------
;konwersja HEX na BCD
;wejście: liczba do konwersji w A2:A1
;zakończenie: wynik konwersji w bcd_1... bcd_10000
;---------------------------------------------
;wykonywana dla liczby 16-bitowej, to jest z zakresu
;od 0 do 65535
.equ       c10tys = 10000         ;stałe (odjemniki)
.equ       c1tys  = 1000
.equ       c100   = 100
.equ       c10    = 10
hex2dec:
    clr    bcd_1           ;zerowanie zmiennych - liczników
    clr    bcd_10
    clr    bcd_100
    clr    bcd_1tys
    clr    bcd_10tys
    mov    var1lsb,A1      ;załadowanie liczby do konwersji do
                           ;rejestrów roboczych
    mov    var1msb,A2
;KONWERSJA „10 TYS.”
    ldi    var2lsb,low(c10tys)  ;załadowanie odjemnika 10 tys.
    ldi    var2msb,high(c10tys)
loop_10tys:                ;liczenie ile razy 10 tys.zmieści się w liczbie
    inc    bcd_10tys       ;zwiększenie licznika 10-tysięcy o 1
    rcall  sub_16_16       ;wywołanie funkcji odejmowania
    brcc   loop_10tys      ;powtórka, jeśli nie było przeniesienia
    rcall  add_16_16       ;dodanie odjemnika aby wrócić do wartości
                           ;sprzed działania
    dec    bcd_10tys       ;zmniejszenie liczby 10-tysięcy
;KONWERSJA „1 TYS.”
    ldi    var2lsb,low(c1tys)  ;załadowanie odjemnika 1 tys.
    ldi    var2msb,high(c1tys)
loop_1tys:                 ;liczenie ile razy 1 tys. zmieści się w liczbie
    inc    bcd_1tys        ;zwiększenie licznika tysięcy o 1
    rcall  sub_16_16       ;wywołanie funkcji odejmowania
    brcc   loop_1tys       ;powtórka, jeśli nie było przeniesienia
    rcall  add_16_16       ;dodanie odjemnika aby wrócić do wartości
                           ;sprzed działania
    dec    bcd_1tys        ;zmniejszenie liczby tysięcy
;KONWERSJA „100”
    ldi    var2lsb,c100    ;załadowanie odjemnika 100
    clr    var2msb
loop_100:                  ;liczenie ile razy 100 zmieści się w liczbie 
    inc    bcd_100
    rcall  sub_16_16
    brcc   loop_100
    rcall  add_16_16
    dec    bcd_100
;KONWERSJA „10”
    ldi    var2lsb,c10     ;załadowanie odjemnika 10
    clr    var2msb
loop_10:                   ;liczenie ile razy 100 zmieści się w liczbie
    inc    bcd_10
    rcall  sub_16_16
    brcc   loop_10
    rcall  add_16_16
    dec    bcd_10
;KONWERSJA „1”
;pozostała reszta z operacji odejmowania to jednostki
    mov    bcd_1,var1lsb
    ret

;---------------------------------------------
;dodawanie dwóch liczb 16-bitowych
;pierwsza liczba w var1msb:var1lsb, druga w var2msb:var2lsb
;wynik przechowywany w var1msb:var1lsb + flaga C
;---------------------------------------------
add_16_16:
    add    var1lsb,var2lsb ;dodanie młodszych bajtów bez przeniesienia
    adc    var1msb,var2msb ;dodanie starszych bajtów z przeniesieniem
    ret                    ;powrót do wywołania z ustawioną lub nie flagą C
;---------------------------------------------
;odejmowanie dwóch liczb 16-bitowych
;pierwsza liczba w var1msb:var1lsb, druga w var2msb:var2lsb
;wynik przechowywany w var1msb:var1lsb + flaga C
;---------------------------------------------
sub_16_16:
    sub    var1lsb,var2lsb ;odejmowanie młodszych bajtów
    sbc    var1msb,var2msb ;odejmowanie starszych bajtów z przeniesieniem
    ret                    ;powrót do wywołania z ustawioną lub nie flagą C