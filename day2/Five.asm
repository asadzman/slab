; ============================================================
; Problem 5: Balanced Brackets Checker
; Accepts a string with (), {}, [] and checks whether brackets
; are balanced and properly nested using a stack-based approach.
; Outputs "Balanced" or "Non-Balanced".
; ============================================================
.MODEL SMALL
.STACK 100h

.DATA
    msgPrompt       DB "Enter bracket expression: $"
    msgBalanced     DB 13,10,"Balanced$"
    msgNotBalanced  DB 13,10,"Non-Balanced$"
    crlf            DB 13,10,"$"

    inputBuf        DB 51
    inputLenSlot    DB ?
    inputData       DB 51 DUP(0)

    stackArr        DB 50 DUP(0)
    stackTop        DW 0

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, msgPrompt
    MOV AH, 09h
    INT 21h

    LEA DX, inputBuf
    MOV AH, 0Ah                      ; buffered input
    INT 21h

    LEA DX, crlf
    MOV AH, 09h
    INT 21h

    MOV AL, inputBuf+1               ; number of characters typed
    XOR AH, AH
    MOV CX, AX
    MOV stackTop, 0

    LEA SI, inputBuf+2

    CMP CX, 0
    JE CHECK_RESULT                  ; empty string -> balanced

CHECK_LOOP:
    MOV AL, [SI]
    CMP AL, '('
    JE PUSH_CHAR
    CMP AL, '{'
    JE PUSH_CHAR
    CMP AL, '['
    JE PUSH_CHAR
    CMP AL, ')'
    JE MATCH_PAREN
    CMP AL, '}'
    JE MATCH_BRACE
    CMP AL, ']'
    JE MATCH_BRACKET
    JMP NEXT_CHAR

PUSH_CHAR:
    MOV BX, stackTop
    LEA DI, stackArr
    ADD DI, BX
    MOV [DI], AL
    INC stackTop
    JMP NEXT_CHAR

MATCH_PAREN:
    CALL POP_STACK
    CMP AL, '('
    JNE NOT_BAL
    JMP NEXT_CHAR

MATCH_BRACE:
    CALL POP_STACK
    CMP AL, '{'
    JNE NOT_BAL
    JMP NEXT_CHAR

MATCH_BRACKET:
    CALL POP_STACK
    CMP AL, '['
    JNE NOT_BAL
    JMP NEXT_CHAR

NEXT_CHAR:
    INC SI
    LOOP CHECK_LOOP

CHECK_RESULT:
    CMP stackTop, 0
    JNE NOT_BAL

    LEA DX, msgBalanced
    MOV AH, 09h
    INT 21h
    JMP DONE_PROG

NOT_BAL:
    LEA DX, msgNotBalanced
    MOV AH, 09h
    INT 21h

DONE_PROG:
    MOV AH, 4Ch
    INT 21h
MAIN ENDP

; ----------------------------------------------------------
; POP_STACK: pops top char from stack into AL.
; If the stack is empty (unmatched closing bracket), returns
; AL = 0, which will never equal a valid opening bracket,
; correctly flagging the expression as Non-Balanced.
; ----------------------------------------------------------
POP_STACK PROC
    CMP stackTop, 0
    JE EMPTY_STACK
    DEC stackTop
    MOV BX, stackTop
    LEA DI, stackArr
    ADD DI, BX
    MOV AL, [DI]
    RET
EMPTY_STACK:
    MOV AL, 0
    RET
POP_STACK ENDP

END MAIN
