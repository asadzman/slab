.MODEL SMALL
.STACK 100H
.DATA
    MSG1 DB 'Enter a character: $'
    MSG2 DB 0DH,0AH,'You entered: $'
.CODE
MAIN PROC
    MOV AX,@DATA
    MOV DS,AX

    MOV AH,09H
    LEA DX,MSG1
    INT 21H

    MOV AH,01H
    INT 21H            ; char read into AL (echoed automatically)
    MOV BL,AL

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
