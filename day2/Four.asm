; ============================================================
; Problem 4: Sort an array of n elements (bubble sort)
; n and all elements are taken as user input; sorted array is
; printed to the terminal.
; ============================================================
.MODEL SMALL
.STACK 100h

.DATA
    msgN        DB "Enter number of elements: $"
    msgElem     DB "Enter element: $"
    msgSorted   DB 13,10,"Sorted array: $"
    space       DB " $"
    crlf        DB 13,10,"$"

    n           DB 0
    arr         DW 50 DUP(0)
    outerCount  DB 0
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

    XOR CH, CH
    MOV CL, n
    LEA BX, arr
READ_ARR:
    PUSH CX
    LEA DX, msgElem
    MOV AH, 09h
    INT 21h
    CALL READ_NUM
    MOV [BX], AX
    ADD BX, 2
    POP CX
    LOOP READ_ARR

    ; ---- Bubble sort ----
    MOV CL, n
    DEC CL
    MOV outerCount, CL

OUTER_LOOP:
    MOV CL, outerCount
    CMP CL, 0
    JE SORT_DONE

    LEA BX, arr
    XOR CH, CH
    MOV CL, n
    DEC CL
INNER_LOOP:
    CMP CX, 0
    JE INNER_DONE
    MOV AX, [BX]
    MOV DX, [BX+2]
    CMP AX, DX
    JLE NO_SWAP
    MOV [BX], DX
    MOV [BX+2], AX
NO_SWAP:
    ADD BX, 2
    LOOP INNER_LOOP
INNER_DONE:
    DEC outerCount
    JMP OUTER_LOOP
SORT_DONE:

    LEA DX, msgSorted
    MOV AH, 09h
    INT 21h

    XOR CH, CH
    MOV CL, n
    LEA BX, arr
PRINT_LOOP:
    PUSH CX
    MOV AX, [BX]
    CALL PRINT_NUM
    LEA DX, space
    MOV AH, 09h
    INT 21h
    ADD BX, 2
    POP CX
    LOOP PRINT_LOOP

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
