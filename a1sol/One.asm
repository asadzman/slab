    .MODEL SMALL
    .STACK 100H
.DATA
    MSG1 DB 'Name: Asaduz Zaman$'
    MSG2 DB 0DH,0AH,'Program: One.asm$'
.CODE
    MAIN PROC
        MOV AX, @DATA
        MOV DS, AX
        
        MOV AH, 09H
        LEA DX, MSG1
        INT 21H
        
        MOV AH, 09H
        LEA DX, MSG2
        INT 21H
        
        MOV AH, 4CH
        INT 21H
    MAIN ENDP
    END    MAIN