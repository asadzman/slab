; ============================================================
; Problem 2: Simple Command-Line Shell Emulator using MASM
; Supports: DIR, TYPE <filename>, COPY <src> <dest>, EXIT
; Uses DOS INT 21h services for all I/O (09h, 0Ah, 02h, 4Ch)
; Mock in-memory "files" are used to simulate the file system.
; ============================================================
.MODEL SMALL
.STACK 200h

.DATA
    prompt      DB 13,10,"TWO.EXE:\>$"
    dirMsg      DB 13,10,"FILE1.TXT   FILE2.TXT   FILE3.TXT",13,10,"$"
    invalidMsg  DB 13,10,"Invalid command or file not found$"
    exitMsg     DB 13,10,"Exiting shell...$"
    copyMsg     DB "Copy successful.$"
    crlf        DB 13,10,"$"

    inputBuf    DB 51
    inputLenSlot DB ?
    inputData   DB 51 DUP(0)
    inputStr    DB 60 DUP(0)         ; working copy, '$' terminated

    cmdDIR      DB "DIR$"
    cmdTYPE     DB "TYPE$"
    cmdCOPY     DB "COPY$"
    cmdEXIT     DB "EXIT$"

    fname1      DB "FILE1.TXT$"
    fcontent1   DB "This is the content of FILE1.$"
    fname2      DB "FILE2.TXT$"
    fcontent2   DB "This is the content of FILE2.$"
    fname3      DB "FILE3.TXT$"
    fcontent3   DB "This is the content of FILE3.$"

    token1      DB 20 DUP(0)
    token2      DB 20 DUP(0)
    token3      DB 20 DUP(0)

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

SHELL_LOOP:
    LEA DX, prompt
    MOV AH, 09h
    INT 21h

    MOV inputBuf, 50
    LEA DX, inputBuf
    MOV AH, 0Ah                      ; buffered keyboard input
    INT 21h

    LEA DX, crlf
    MOV AH, 09h
    INT 21h

    ; copy typed characters into inputStr, append '$'
    MOV AL, inputBuf+1               ; actual number of chars typed
    XOR AH, AH
    MOV CX, AX
    LEA SI, inputBuf+2
    LEA DI, inputStr
COPY_INPUT:
    JCXZ COPY_DONE
    MOV AL, [SI]
    MOV [DI], AL
    INC SI
    INC DI
    LOOP COPY_INPUT
COPY_DONE:
    MOV BYTE PTR [DI], '$'

    CALL PARSE_TOKENS                ; splits inputStr into token1/2/3

    LEA SI, token1
    LEA DI, cmdDIR
    CALL STRCMP
    JC DO_DIR

    LEA SI, token1
    LEA DI, cmdEXIT
    CALL STRCMP
    JC DO_EXIT

    LEA SI, token1
    LEA DI, cmdTYPE
    CALL STRCMP
    JC DO_TYPE

    LEA SI, token1
    LEA DI, cmdCOPY
    CALL STRCMP
    JC DO_COPY

    LEA DX, invalidMsg
    MOV AH, 09h
    INT 21h
    JMP SHELL_LOOP

; ---------------- DIR ----------------
DO_DIR:
    LEA DX, dirMsg
    MOV AH, 09h
    INT 21h
    JMP SHELL_LOOP

; ---------------- TYPE ----------------
DO_TYPE:
    LEA SI, token2
    LEA DI, fname1
    CALL STRCMP
    JC PRINT_F1
    LEA SI, token2
    LEA DI, fname2
    CALL STRCMP
    JC PRINT_F2
    LEA SI, token2
    LEA DI, fname3
    CALL STRCMP
    JC PRINT_F3

    LEA DX, invalidMsg
    MOV AH, 09h
    INT 21h
    JMP SHELL_LOOP

PRINT_F1:
    LEA DX, crlf
    MOV AH, 09h
    INT 21h
    LEA DX, fcontent1
    MOV AH, 09h
    INT 21h
    JMP SHELL_LOOP
PRINT_F2:
    LEA DX, crlf
    MOV AH, 09h
    INT 21h
    LEA DX, fcontent2
    MOV AH, 09h
    INT 21h
    JMP SHELL_LOOP
PRINT_F3:
    LEA DX, crlf
    MOV AH, 09h
    INT 21h
    LEA DX, fcontent3
    MOV AH, 09h
    INT 21h
    JMP SHELL_LOOP

; ---------------- COPY ----------------
; Simplified: verifies the source is one of the known mock files
; and reports success (mock filesystem, so no real destination
; write is performed -- educational simulation only).
DO_COPY:
    LEA SI, token2
    LEA DI, fname1
    CALL STRCMP
    JC COPY_OK
    LEA SI, token2
    LEA DI, fname2
    CALL STRCMP
    JC COPY_OK
    LEA SI, token2
    LEA DI, fname3
    CALL STRCMP
    JC COPY_OK

    LEA DX, invalidMsg
    MOV AH, 09h
    INT 21h
    JMP SHELL_LOOP

COPY_OK:
    LEA DX, crlf
    MOV AH, 09h
    INT 21h
    LEA DX, copyMsg
    MOV AH, 09h
    INT 21h
    JMP SHELL_LOOP

; ---------------- EXIT ----------------
DO_EXIT:
    LEA DX, exitMsg
    MOV AH, 09h
    INT 21h
    MOV AH, 4Ch
    INT 21h

MAIN ENDP

; ============================================================
; PARSE_TOKENS: splits inputStr (space-separated, '$'-terminated)
; into token1 (command), token2, token3 (arguments), uppercased.
; ============================================================
PARSE_TOKENS PROC
    PUSH AX
    PUSH CX
    PUSH SI
    PUSH DI

    LEA DI, token1
    MOV CX, 20
    MOV AL, 0
CLR1: MOV [DI], AL
    INC DI
    LOOP CLR1
    LEA DI, token2
    MOV CX, 20
CLR2: MOV [DI], AL
    INC DI
    LOOP CLR2
    LEA DI, token3
    MOV CX, 20
CLR3: MOV [DI], AL
    INC DI
    LOOP CLR3

    LEA SI, inputStr
    LEA DI, token1
    CALL GET_TOKEN
    LEA DI, token2
    CALL GET_TOKEN
    LEA DI, token3
    CALL GET_TOKEN

    POP DI
    POP SI
    POP CX
    POP AX
    RET
PARSE_TOKENS ENDP

; SI = pointer into inputStr (advances past token), DI = dest buffer
GET_TOKEN PROC
SKIP_SPACES:
    MOV AL, [SI]
    CMP AL, ' '
    JNE COPY_TOKEN_LOOP
    INC SI
    JMP SKIP_SPACES
COPY_TOKEN_LOOP:
    MOV AL, [SI]
    CMP AL, '$'
    JE END_TOKEN
    CMP AL, ' '
    JE END_TOKEN
    CMP AL, 'a'
    JB STORE_CHAR
    CMP AL, 'z'
    JA STORE_CHAR
    SUB AL, 20h                      ; to uppercase
STORE_CHAR:
    MOV [DI], AL
    INC DI
    INC SI
    JMP COPY_TOKEN_LOOP
END_TOKEN:
    MOV BYTE PTR [DI], '$'
    RET
GET_TOKEN ENDP

; STRCMP: compares '$'-terminated strings at SI, DI.
; Sets Carry Flag if equal, clears it otherwise.
STRCMP PROC
    PUSH AX
    PUSH SI
    PUSH DI
CMP_LOOP:
    MOV AL, [SI]
    MOV AH, [DI]
    CMP AL, AH
    JNE NOT_EQUAL
    CMP AL, '$'
    JE EQUAL_STR
    INC SI
    INC DI
    JMP CMP_LOOP
EQUAL_STR:
    POP DI
    POP SI
    POP AX
    STC
    RET
NOT_EQUAL:
    POP DI
    POP SI
    POP AX
    CLC
    RET
STRCMP ENDP

END MAIN
