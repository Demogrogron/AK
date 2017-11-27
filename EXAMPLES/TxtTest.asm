Sts segment stack
     DB 64 dup ('stack!!!')
Sts ends

Dane segment public
text1 DB "Przykladowy tekst ...",'$'
Dane ends

extrn pisz:proc,piszln:proc,czkl:proc

Kody segment public

assume DS:dane,CS:kody
main proc

start: mov ax,dane
       mov ds,ax
       lea dx,text1
       call piszln
       call czkl
       mov ah,4ch
       mov al,0
       int 21h

main endp

Kody ends

end start

