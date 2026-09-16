; ============================================================
; Problem 3: FCFS (First-Come-First-Served) Disk Scheduling
; Takes: number of requests, initial head position, and the
; request queue from the user. Outputs the seek sequence and
; total head movement.
; ============================================================
.MODEL SMALL
.STACK 100h

.DATA
    msgN        DB "Enter number of requests: $"
    msgHead     DB "Enter initial head position: $"
    msgReq      DB "Enter request: $"
    msgSeq      DB 13,10,"Seek Sequence: $"
    msgTotal    DB 13,10,"Total Head Movement = $"
    space       DB " $"
    crlf        DB 13,10,"$"

    n           DB 0
    head        DW 0
    requests    DW 20 DUP(0)
    totalMove   DW 0
    numBuf      DB 7 DUP(0)

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, msgN
    MOV AH, 09h
    INT 21h
    CALL READ_NUM
    MOV n, AL

    LEA DX, msgHead
    MOV AH, 09h
    INT 21h
    CALL READ_NUM
    MOV head, AX

    XOR CH, CH
    MOV CL, n
    LEA BX, requests
READ_LOOP:
    PUSH CX
    LEA DX, msgReq
    MOV AH, 09h
    INT 21h
    CALL READ_NUM
    MOV [BX], AX
    ADD BX, 2
    POP CX
    LOOP READ_LOOP

    ; print the seek sequence (head, then each request in order)
    LEA DX, msgSeq
    MOV AH, 09h
    INT 21h
    MOV AX, head
    CALL PRINT_NUM
    LEA DX, space
    MOV AH, 09h
    INT 21h

    XOR CH, CH
    MOV CL, n
    LEA BX, requests
PRINT_SEQ:
    PUSH CX
    MOV AX, [BX]
    CALL PRINT_NUM
    LEA DX, space
    MOV AH, 09h
    INT 21h
    ADD BX, 2
    POP CX
    LOOP PRINT_SEQ

    ; compute total head movement (FCFS = service in arrival order)
    MOV AX, head
    LEA BX, requests
    XOR CH, CH
    MOV CL, n
    MOV totalMove, 0
FCFS_LOOP:
    MOV DX, [BX]
    CMP AX, DX
    JAE NO_SWAP
    XCHG AX, DX
NO_SWAP:
    SUB AX, DX
    ADD totalMove, AX
    MOV AX, [BX]
    ADD BX, 2
    LOOP FCFS_LOOP

    LEA DX, msgTotal
    MOV AH, 09h
    INT 21h
    MOV AX, totalMove
    CALL PRINT_NUM

    MOV AH, 4Ch
    INT 21h
MAIN ENDP

; ---------------- READ_NUM: reads decimal number, returns in AX ----------------
READ_NUM PROC
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV numBuf, 6
    LEA DX, numBuf
    MOV AH, 0Ah
    INT 21h

    LEA DX, crlf
    MOV AH, 09h
    INT 21h

    XOR AX, AX
    XOR CH, CH
    MOV CL, numBuf+1
    LEA SI, numBuf+2
CONV_LOOP:
    JCXZ CONV_DONE
    MOV DL, [SI]
    SUB DL, '0'
    XOR DH, DH
    PUSH DX
    MOV BX, 10
    MUL BX
    POP DX
    ADD AX, DX
    INC SI
    LOOP CONV_LOOP
CONV_DONE:
    POP SI
    POP DX
    POP CX
    POP BX
    RET
READ_NUM ENDP

; ---------------- PRINT_NUM: prints decimal number in AX ----------------
PRINT_NUM PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV CX, 0
    MOV BX, 10
    CMP AX, 0
    JNE CONVERT_LOOP
    MOV DL, '0'
    MOV AH, 02h
    INT 21h
    JMP PRINT_DONE

CONVERT_LOOP:
    CMP AX, 0
    JE PRINT_DIGITS
    XOR DX, DX
    DIV BX
    PUSH DX
    INC CX
    JMP CONVERT_LOOP

PRINT_DIGITS:
    CMP CX, 0
    JE PRINT_DONE
    POP DX
    ADD DL, '0'
    MOV AH, 02h
    INT 21h
    DEC CX
    JMP PRINT_DIGITS

PRINT_DONE:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_NUM ENDP

END MAIN
