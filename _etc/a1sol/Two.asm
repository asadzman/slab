.MODEL SMALL
.STACK 100H
.DATA
    MSG1 DB 'Enter an uppercase letter: $'
    MSG2 DB 0DH,0AH,'Lowercase letter: $'
.CODE
MAIN PROC
    MOV AX,@DATA
    MOV DS,AX

    MOV AH,09H
    LEA DX,MSG1
    INT 21H

    MOV AH,01H
    INT 21H            ; character read into AL (echoed automatically)

    CMP AL,'A'
    JB SKIP
    CMP AL,'Z'
    JA SKIP
    ADD AL,20H         ; add 0x20 to convert upper -> lower
SKIP:
    MOV BL,AL          ; save converted char

    MOV AH,09H
    LEA DX,MSG2
    INT 21H

    MOV DL,BL
    MOV AH,02H
    INT 21H

    MOV AH,4CH
    INT 21H
MAIN ENDP
END MAIN
