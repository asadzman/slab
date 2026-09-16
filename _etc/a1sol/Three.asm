    .MODEL SMALL
    .STACK 100H
.DATA
    NUM1 DB 3AH          ; first hex number (change as needed)
    NUM2 DB 2FH          ; second hex number (change as needed)
    MSG  DB 'Sum in Hex: $'
    HEXTAB DB '0123456789ABCDEF'
.CODE
    MAIN PROC
        MOV  AX, @DATA
        MOV  DS, AX
        
        MOV  AH, 09H
        LEA  DX, MSG
        INT  21H
        
        MOV  AL, NUM1
        ADD  AL, NUM2 ; AL = sum (single byte result)
        CALL PRINT_HEX_BYTE
        
        MOV  AH, 4CH
        INT  21H
    MAIN ENDP
    
    ; Prints the byte in AL as two hex digits
    PRINT_HEX_BYTE PROC
        PUSH AX
        PUSH BX
        PUSH CX
        
        MOV  CH, AL ; save original byte
        MOV  CL, 4
        SHR  AL, CL ; high nibble
        AND  AL, 0FH
        LEA  BX, HEXTAB
        XLAT 
        MOV  DL, AL
        MOV  AH, 02H
        INT  21H
        
        MOV  AL, CH
        AND  AL, 0FH ; low nibble
        LEA  BX, HEXTAB
        XLAT 
        MOV  DL, AL
        MOV  AH, 02H
        INT  21H
        
        POP  CX
        POP  BX
        POP  AX
        RET  
    PRINT_HEX_BYTE ENDP
    END    MAIN