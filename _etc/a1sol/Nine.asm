.MODEL SMALL
.STACK 100H
.DATA
    MSG1 DB 0DH,0AH,'Looping...$'
    MSG2 DB 0DH,0AH,'Continue? (Y/N): $'
.CODE
MAIN PROC
    MOV AX,@DATA
    MOV DS,AX

AGAIN:
    MOV AH,09H
    LEA DX,MSG1
    INT 21H

    MOV AH,09H
    LEA DX,MSG2
    INT 21H

    MOV AH,01H
    INT 21H            ; read choice into AL
    AND AL,0DFH        ; force uppercase (clear bit 5)
    CMP AL,'Y'
    JE AGAIN

    MOV AH,4CH
    INT 21H
MAIN ENDP
END MAIN
