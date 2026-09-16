.MODEL SMALL
.STACK 100H

.DATA
    msg DB 'Hello from MASM on macOS!', 13, 10, '$'

.CODE
MAIN PROC
    ; Initialize DS
    MOV AX, @DATA
    MOV DS, AX

    ; Print string
    MOV AH, 09H
    LEA DX, msg
    INT 21H

    ; Exit to DOS
    MOV AH, 4CH
    INT 21H

MAIN ENDP
END MAIN
