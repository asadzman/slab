.MODEL SMALL
.STACK 100H
.DATA
    MSG1   DB 'Enter first digit (0-9): $'
    MSG2   DB 0DH,0AH,'Enter second digit (0-9): $'
    MSGYES DB 0DH,0AH,'Second number IS less than first.$'
    MSGNO  DB 0DH,0AH,'Second number is NOT less than first.$'
.CODE
MAIN PROC
    MOV AX,@DATA
    MOV DS,AX

    MOV AH,09H
    LEA DX,MSG1
    INT 21H
    MOV AH,01H
    INT 21H
    SUB AL,'0'
    MOV BL,AL          ; first number

    MOV AH,09H
    LEA DX,MSG2
    INT 21H
    MOV AH,01H
    INT 21H
    SUB AL,'0'         ; second number

    CMP AL,BL
    JL LESS
    MOV AH,09H
    LEA DX,MSGNO
    INT 21H
    JMP DONE
LESS:
    MOV AH,09H
    LEA DX,MSGYES
    INT 21H
DONE:
    MOV AH,4CH
    INT 21H
MAIN ENDP
END MAIN
