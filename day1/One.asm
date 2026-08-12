.MODEL SMALL
.STACK 100h

.DATA
## dos printing stop upon registering $
name db "Asaduz Zaman$"
title db "One.msm$"
    

; ax= ah + al
.CODE
MAIN PROC
    mov ax, @data
    mov ds, ax ; ds:= data segment
    ; ds provied services
; 01h  Read keyboard
; 02h  Print one character
; 09h  Print string
; 4Ch  Exit program
    mov ah, 09h
    lea dx,name ; load effective address: name vars to dx, 
    int 21h ; call Dos. : dos calls 'ah' which is set to 09h

    mov ah, 09h
    lea dx,title ; load effective address: name vars to dx, 
    int 21h


    mov ah, 4Ch
    int 21h
    

    mov ah, 4Ch
    int 21h
MAIN ENDP

END MAIN
