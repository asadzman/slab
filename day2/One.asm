; ============================================================
; Program 1: Boot-level Password Verification System
; - Hidden password input (no echo) using BIOS INT 16h
; - Compares with hardcoded password "SECRET"
; - Up to 3 retries before locking
; ============================================================

.MODEL SMALL
.STACK 100h

.DATA
    password    DB 'SECRET', 0
    prompt      DB 'Enter password: $'
    wrong_msg   DB 0Dh, 0Ah, 'Wrong password! Try again.', 0Dh, 0Ah, '$'
    locked_msg  DB 0Dh, 0Ah, 'System Locked! Too many failed attempts.', 0Dh, 0Ah, '$'
    success_msg DB 0Dh, 0Ah, 'Access Granted! Welcome.', 0Dh, 0Ah, '$'
    retry_msg   DB 'Retries left: $'
    input_buf   DB 20 DUP(0)
    asterisk    DB '*$'
    newline     DB 0Dh, 0Ah, '$'
    count       DB 0
    max_retries DB 3

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    MOV count, 0

CHECK_PASSWORD:
    ; Display prompt
    LEA DX, prompt
    MOV AH, 09h
    INT 21h

    ; Clear input buffer
    LEA SI, input_buf
    MOV CX, 20
CLEAR_BUF:
    MOV BYTE PTR [SI], 0
    INC SI
    LOOP CLEAR_BUF

    ; Read password character by character (no echo)
    LEA SI, input_buf
    XOR CX, CX          ; CX = character count

READ_CHAR:
    MOV AH, 00h         ; BIOS INT 16h - Read key (no echo)
    INT 16h

    CMP AL, 0Dh         ; Enter key?
    JE END_INPUT

    CMP AL, 08h         ; Backspace?
    JE HANDLE_BACKSPACE

    ; Store character
    MOV [SI], AL
    INC SI
    INC CX

    ; Display asterisk
    LEA DX, asterisk
    MOV AH, 09h
    INT 21h

    JMP READ_CHAR

HANDLE_BACKSPACE:
    CMP CX, 0
    JE READ_CHAR
    DEC SI
    DEC CX
    MOV BYTE PTR [SI], 0

    ; Move cursor back and erase asterisk
    MOV AH, 02h
    MOV DL, 08h
    INT 21h
    MOV DL, ' '
    INT 21h
    MOV DL, 08h
    INT 21h

    JMP READ_CHAR

END_INPUT:
    ; Null-terminate input
    MOV BYTE PTR [SI], 0

    ; Compare input with password
    LEA SI, input_buf
    LEA DI, password
    XOR CX, CX

COMPARE_LOOP:
    MOV AL, [SI]
    CMP AL, 0
    JE CHECK_LEN
    MOV BL, [DI]
    CMP AL, BL
    JNE WRONG_PASSWORD
    INC SI
    INC DI
    INC CX
    JMP COMPARE_LOOP

CHECK_LEN:
    MOV BL, [DI]
    CMP BL, 0
    JNE WRONG_PASSWORD

    ; Password correct
    LEA DX, newline
    MOV AH, 09h
    INT 21h
    LEA DX, success_msg
    MOV AH, 09h
    INT 21h
    JMP EXIT_PROG

WRONG_PASSWORD:
    LEA DX, newline
    MOV AH, 09h
    INT 21h
    LEA DX, wrong_msg
    MOV AH, 09h
    INT 21h

    INC count
    MOV AL, count
    CMP AL, max_retries
    JGE SYSTEM_LOCKED

    ; Show retries left
    LEA DX, retry_msg
    MOV AH, 09h
    INT 21h

    MOV AL, max_retries
    SUB AL, count
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02h
    INT 21h

    LEA DX, newline
    MOV AH, 09h
    INT 21h

    JMP CHECK_PASSWORD

SYSTEM_LOCKED:
    LEA DX, locked_msg
    MOV AH, 09h
    INT 21h

EXIT_PROG:
    MOV AH, 4Ch
    INT 21h
MAIN ENDP
END MAIN