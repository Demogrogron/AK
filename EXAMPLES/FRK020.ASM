assume cs:code,ds:code,es:nothing
code segment
org 100h
.386
start:
; Zaalokuj pamiec
  mov  ah,4ah
  mov  bx,8192
  int  21h

  mov  ah,48h
  mov  bx,4096
  int  21h
  mov  gs,ax

  mov  ah,48h
  mov  bx,4096
  int  21h
  mov  fs,ax

; Ustaw tryb graficzny 320x200x256 ...
  mov  ax,13h
  int  10h
  push 0A000h
  pop  es

; Generuj zbior Julii ...
    xor  di,di
    mov  bp,-512
    mov  si,bp
    mov  cl,200
  firstloop:
    push   si
    mov    dx,320
  secondloop:
    push   si
    push   bp
    xor    al,al
    lastloop:
     inc   al
     jz    endloop
     movsx ebp,bp
     movsx esi,si
     mov   ebx,ebp
     imul  ebp,esi
     sar   ebp,7
     add   bp,220
     imul  ebx,ebx
     imul  esi,esi
     add   ebx,esi
     sar   ebx,8
     sar   esi,7
     sub   si,bx
     cmp   bh,4
    jbe lastloop
    endloop:
     pop  bp
     pop  si
     sal  al,1
     mov  fs:[di],al
     inc  di
     add  si,3
     dec  dx
    jnz secondloop
     pop  si
     add  bp,5
  loop firstloop

; Generuj zbior Mandelbrota ...
  xor   di,di
  mov   ebp,-512
  mov   cu,ebp
  mov   esi,ebp
  mov   cr,esi
  mov   cl,200
PerY:
  push  cx
  mov   cx,320
PerX:
  xor   ax,ax
  push  esi
  push  ebp
ByPixel:
  inc   al
  jz    EndPixel
  mov   ebx,esi
  imul  ebx,ebp
  sar   ebx,7
  imul  esi,esi
  sar   esi,8
  imul  ebp,ebp
  sar   ebp,8
  mov   dx,si
  add   dx,bp
  add   ebx,cu
  sub   esi,ebp
  add   esi,cr
  mov   ebp,ebx
  cmp   dh,4
  jb    ByPixel
EndPixel:
  pop   ebp
  pop   esi
  shl   al,2
  mov   gs:[di],al
  inc   di
  add   esi,3
  add   cr,3
  loop  PerX
  mov   esi,-512
  mov   cr,esi
  add   ebp,5
  add   cu,5
  pop   cx
  loop  PerY

; Generuj szachownice ...
  xor  si,si
  mov  cl,200
  WspY:
    xor  ax,ax
    WspX:
      push cx
      push ax
      shr  ax,5
      shr  cx,4
      add  ax,cx
      mov  bl,2
      idiv bl
      cmp  ah,0
      jnz  Pomin
        mov  al,6
        add  gs:[si],al
        add  fs:[si],al
      Pomin:
      pop  ax
      pop  cx
      inc  si
      inc  ax
      cmp  ax,320
    jnz  WspX
  loop WspY

; Wyswietl Mandelbrota i szachownice ...

  call _Paleta2
  call _JuliaEkran

; Generuj IFSy ...
  xor  di,di
  Petla1:
    push di
    mov  [Licznik],0
    Petla2:
      push  di

      MOV   AX,RandSeed.Word[0]
      MOV   BX,RandSeed.Word[2]
      MOV   CX,AX
      MOV   DX,37317
      MUL   DX
      SHL   CX,3
      ADD   CH,CL
      ADD   DX,CX
      ADD   DX,BX
      SHL   BX,2
      ADD   DX,BX
      ADD   DH,BL
      SHL   BX,5
      ADD   DH,BL
      INC   AX
      MOV   RandSeed.Word[0],AX
      MOV   RandSeed.Word[2],DX
      XOR   AX,AX
      XCHG  AX,DX
      DIV   Fraktale[DI]
      XCHG  DI,DX

      shl   di,1
      mov   ax,di
      shl   di,1
      add   di,ax
      shl   di,1

      pop   ax
      push  ax

      add   di,ax
      add   di,10

      mov   ax,Fraktale[di]
      cwde
      imul  ebp
      mov   ebx,eax

      add   di,2

      mov   ax,Fraktale[di]
      cwde
      imul  esi
      add   ebx,eax
      sar   ebx,10

      add   di,2

      mov   ax,Fraktale[di]
      cwde
      add   ebx,eax

      add   di,2

      mov   ax,Fraktale[di]
      cwde
      imul  ebp
      mov   ecx,eax

      add   di,2

      mov   ax,Fraktale[di]
      cwde
      imul  esi
      add   ecx,eax
      sar   ecx,10

      mov   ax,Fraktale[di+2]
      cwde
      add   ecx,eax

      mov   esi,ecx
      mov   ebp,ebx

      pop   di
      push  di

      push  cx
      mov   cx,Fraktale[di+6]
      sar   bx,cl
      pop   cx
      add   bx,Fraktale[di+2]

      mov   dx,cx
      mov   cx,Fraktale[di+8]
      sar   dx,cl
      mov   ax,Fraktale[di+4]
      sub   ax,dx

      ; Put pixel ....
      inc   [Licznik]
      cmp   [Licznik],100
      jb    Przeskocz

      xchg  AH, AL
      add   BX, AX
      shr   AX, 2
      add   BX, AX
      mov   AL, 255
      mov   ES:[BX], AL

      Przeskocz:

      pop   di

      mov   ah,0bh
      int   21h

      cmp   al,0
    jz Petla2

    mov  ah,08h
    int  21h
    cmp  al,27
    jz   koniec

    mov  ah,0ch
    int  21h

    cmp  [Licz],3
    jg   Szolem
      call _JuliaEkran
      jmp  Joolia
    Szolem:
      call _MandiEkran
    Joolia:

    inc  [Licz]

    pop  di
    add  di,70
    cmp  di,560
  jnz Petla1
    call _JuliaEkran
    mov  [Licz],1
    xor  di,di
  jmp Petla1

; Przejdz do trybu textowego i zakoncz ...
koniec:
  mov  ax,3
  int  10h
  mov  ah,4ch
  int  21h

; Procedurki
_JuliaEkran PROC
  call _Paleta1
  push ds
  push fs
  pop  ds
  xor  di,di
  xor  si,si
  mov  cx,16000
  rep  movsd
  pop  ds
  ret
ENDP

_MandiEkran PROC
  call _Paleta2
  push ds
  push gs
  pop  ds
  xor  di,di
  xor  si,si
  mov  cx,16000
  rep  movsd
  pop  ds
  ret
ENDP

_Paleta1 PROC

  mov   DX, 03C8h
  xor   AL, AL
  out   DX, AL
  inc   DX

  xor   CX,CX
 @1st:
  mov   AL, CL
  shl   AL, 1
  out   DX, AL
  xor   AL, AL
  out   DX, AL
  out   DX, AL
  inc   CX
  cmp   CX, 32
  jnz   @1st

  xor   CX, CX
 @2nd:
  mov   AL, 63
  out   DX, AL
  mov   AL, CL
  shl   AL, 1
  out   DX, AL
  xor   AL, AL
  out   DX, AL
  inc   CX
  cmp   CX, 32
  jnz   @2nd

  xor   CX, CX
 @3rd:
  mov   AL, 63
  out   DX, AL
  out   DX, AL
  mov   AL, CL
  out   DX, AL
  inc   CX
  cmp   CX, 64
  jnz   @3rd

  ret
ENDP

_Paleta2 PROC
 mov    dx,03c8h
 mov    al,1
 out    dx,al
 inc    dx

 mov    cx,63
sp1:
 push   cx

 mov    al,63
 add    al,cl
 mov    cx,2
sp2:
 push   ax
 out    dx,al
 xor    al,al
 out    dx,al
 pop    ax
 out    dx,al
 loop   sp2

 pop    cx
 loop   sp1

 mov    cx,63
sp3:
 push   cx
 mov    al,63
 add    al,cl

 mov    cx,2
sp4:
 push   ax
 push   ax
 add    al,32
 out    dx,al
 pop    ax
 out    dx,al
 mov    al,63
 out    dx,al
 pop    ax
 loop   sp4

 pop    cx
 loop   sp3

 mov    cl,9
 mov    al,63
sp5:
 out    dx,al
 loop   sp5

 ret
ENDP

; Zmienne ... i stale ...  (Wazna kolejnosc ...)

  RandSeed  dw   ?
  cr        dd   ?
  cu        dd   ?
  Licznik   db   ?
  Licz      db   1

; Dane do IFS'ow ...
  Fraktale dw 2,210,80,3,3
           dw -410,0,-1024,0,-410,103,778,-410,0,410,778,0
           dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
           dw 3,58,152,0,1
           dw 344,0,68,0,343,136,0,341,136,1024,0,0,0,-341,68,1024,0,0
           dw 0,0,0,0,0,0,0,0,0,0,0,0
           dw 5,32,160,2,3
           dw 391,0,315,0,391,634,391,0,618,0,391,414,391,0,14,0,391
           dw 414,391,0,128,0,391,61,391,0,504,0,391,61
           dw 3,32,160,2,3
           dw 0,-512,512,512,0,0,0,512,512,-512,0,512,512,0,256,0,512,512
           dw 0,0,0,0,0,0,0,0,0,0,0,0
           dw 4,161,160,2,3
           dw -686,-20,0,-184,829,307,410,410,0,-102,410,0,-410,-410
           dw 0,-102,410,0,-102,0,0,451,451,-41,0,0,0,0,0,0
           dw 5,30,160,2,3
           dw 200,-500,454,352,454,251,473,424,257,-258,370,583,-59,-72,612
           dw 464,-114,99,-36,72,500,-480,-23,519,-652,0,877,0,513,257
           dw 4,34,-20,2,2
           dw 261,0,382,0,261,688,261,0,117,0,261,229,261,0,646
           dw 0,261,229,379,-657,651,657,379,-6,0,0,0,0,0,0
           dw 3,34,-100,2,3
           dw 512,0,0,0,512,0,512,0,512,0,512,0,512,0,256,0,512,512

code ends
end start
