TITLE String Primitives and Macros     (Proj6_JOHNSZA5.asm)

; Author: Zachary J Johnson
; Last Modified: 3/19/2023
; OSU email address: johnsza5@oregonstate.edu
; Course number/section: CS271	Section 400
; Project Number: 6				Due Date: 3/19/2023
; Description: Performs a simple sum and average calculation for user inputs in an array
;              

INCLUDE Irvine32.inc

; constants
SIGNED_MAX			EQU		2147483647
SIGNED_MIN			EQU		-2147483648
CHARACTER_LIMIT			EQU		12				; 11 characters + 1 for null
INPUT_CAP			EQU		10				; limit as per assignment 

.data

; variables
header			BYTE	"Project 6: Designing Low-Level I/O Procedures",0
author			BYTE	"By: Zachary Johnson",0
line			BYTE	"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",0
instruction1		BYTE	"Please enter 10 signed integers. Please keep them within the signed integer range",0
instruction2		BYTE	"(-2147483648 through 2147483648). The integers will then be displayed in an array.",0
instruction3		BYTE	"The sum and truncated average will also be displayed.",0
usrStr			BYTE	CHARACTER_LIMIT	DUP	(?)									; FOR STORING THE STRING FORMAT INPUT
enterNum		BYTE	"Enter your integer choice: ",0								; FOR STORING THE CONVERTED VALUES FROM userString
signErr			BYTE	"Error: You did not enter a signed integer!",0
retry			BYTE	"Retry! Enter your choice integer choice: ",0
sign			BYTE	0	                                                ; SET 0 AS POSITIVE, -1 AS NEGATIVE
intArray		BYTE	"Your Signed Integers: ",0
commaSpace		BYTE    ", ",0
usrInputStr     	BYTE    CHARACTER_LIMIT   DUP (?)
sumStr			BYTE    CHARACTER_LIMIT   DUP (?)
avgStr			BYTE    CHARACTER_LIMIT   DUP (?)
sumHeader		BYTE    "Sum of signed integers: ",0
avgHeader		BYTE    "Truncated average of signed integers: ",0
bye1			BYTE	"Wasn't that fun! Bye now! ",0
usrInputLen		DWORD	?
usrInput		SDWORD	INPUT_CAP	DUP	(0)	
edgeCase		SDWORD	2147483648
sum             	SDWORD  0
avg			SDWORD  0

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
mGetString	MACRO	instruction, usrStr, usrInputCount, usrLen

; Macro responsible for reading string entered by user
; Preconditions: n/a
; Postconditions: input stored with usrStr; usrLen holds num of characters
; Receives: instruction, usrStr, usrLen and usrCount. usrString stores the input values
; Returns:	usrStr holds array of inputs, usrLen stores the length of the inputs
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	push		EAX
	push		ECX
	push		EDX
	mov		EDX,  instruction
	call		WriteString
	mov		EDX,	usrStr
	mov		ECX,	usrInputCount
	call		ReadString
	mov		usrLen,  EAX										
	pop		EDX
	pop		ECX
	pop		EAX

ENDM

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
mDisplayString	MACRO	displayStr

; Displays Strings in Terminal
; Preconditions: n/a
; Postconditions: n/a
; Receives:  displayStr	
; Returns: printed string
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	push		EDX
	mov		EDX,  displayStr
	call		WriteString
	pop		EDX

ENDM

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
mGetStringSimplified	MACRO  usrStr, usrCount, usrLen, 

; Preconditions: n/a
; Postconditions: input string will be stored on userString; userInputLength will be updated accordingly (number of characters entered)
; Receives: usrStr (array), usrCount which counts max lengeht for str, usrLen which stores the user's input's length
; Returns:	updated usrStr and updated UsrLen
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	push		EAX
	push		ECX
	push		EDX
	mov		EDX,	usrStr
	mov		ECX,	usrCount
	call		ReadString
	mov		usrLen,  EAX					; num of char entered in terminal
	pop		EDX
	pop		ECX
	pop		EAX

ENDM


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.code

main PROC
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	; Introduction PROC
	push			OFFSET	header					;28
	push			OFFSET	author					;24
	push			OFFSET	line					;20
	push			OFFSET	instruction1				;16
	push			OFFSET	instruction2				;12
	push			OFFSET	instruction3				;8
	call			introduction					;4

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	; ReadVal PROC
	mov			ECX,	INPUT_CAP			
	mov			EDX,	OFFSET	usrInput		

_getInt:
	push			OFFSET	usrStr					;36
	push			OFFSET	enterNum				;32
	push			OFFSET	edgeCase				;28
	push			OFFSET	usrInputLen				;24
	push			EDX						;20
	push			OFFSET	sign					;16
	push			OFFSET	retry					;12
	push			OFFSET	signErr					;8
	call			ReadVal						;4
	add			EDX,	4					;12
	loop			_getInt						;8
	call			CrLf						;4

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	; DisplayArray PROC
	push			OFFSET	usrInputStr				;28
	push			OFFSET	usrInput				;24
	push			OFFSET	intArray				;20
	push			OFFSET	commaSpace				;16
	push			OFFSET	sign					;12
	push			OFFSET	line					;8
	call			displayArray					;4
	call			CrLf						;4

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	; Calculate PROC
	push			OFFSET  usrInput				;16
	push			OFFSET  avg					;12
	push			OFFSET  sum					;8
	call			Calculate					;4

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	; WriteVal PROC			
	mDisplayString		OFFSET	line					;4
	call			Crlf							
	mDisplayString		OFFSET	sumheader				;4
	push			OFFSET	sign					;16
	push			OFFSET	sumStr					;12
	push			OFFSET	sum					;8
	call			WriteVal					;4
	mDisplayString		OFFSET	sumStr					;4
	call			CrLf							
	call			Crlf							
	mDisplayString		OFFSET	line					;4
	call			Crlf							
	mDisplayString		OFFSET	avgHeader				
	push			OFFSET	sign					;16
	push			OFFSET	avgStr					;12
	push			OFFSET	avg					;8
	call			WriteVal					;4
	mDisplayString		OFFSET	avgStr					;4

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	; Goodbye PROC
	push			OFFSET	line					    ;12
	push			OFFSET	bye1					    ;8
	call			goodbye						    ;4


	Invoke		ExitProcess,0
	
main ENDP


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Introduction PROC

; For header, author and instruction strings
; Preconditions: setup stackframe w/ neccessaey strings header author and instructions
; Postconditions: clear stack frame
; Receives: header author and instructions pushed onto runtime stack
; Returns: num of bytes pushed to stack
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	push		EBP															
	mov		EBP,	ESP

	call		CrLf
	mov		EDX,	[EBP+28]
	call		WriteString
	call		CrLf
	mov		EDX,	[EBP+24]
	call		WriteString
	call		CrLf
	mov		EDX,	[EBP+20]
	call		WriteString
	call		CrLf
	call		CrLf
	mov		EDX,	[EBP+16]
	call		WriteString
	call		CrLf
	mov		EDX,	[EBP+12]
	call		WriteString
	call		CrLf
	mov		EDX,	[EBP+8]
	call		WriteString
	call		CrLf
	mov		EDX,	[EBP+20]
	call		WriteString
	call		CrLf
	call		CrLf

	pop		EBP
	ret		20															

Introduction ENDP


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ReadVal PROC

; Gets user input in string form from mGetString macro, coverts ascii to num val, then stores into an array
; preconditions: push strings to the stack frame (edgeCase, enterNum, usrStr, usrInputLen,signErr, retry)
; postconditions: usrStr will store the validated values
; Receives:	edgeCase, enterNum, usrStr, usrInputLen,signErr, retry, sign to the stack
; Returns: 1) the array of user inputs are stored in usrInput
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	push		EBP
	mov		EBP,	ESP
	pushad

	mGetString	[EBP+32], [EBP+36], CHARACTER_LIMIT, [EBP+24]		; calls the macro mGetString
	mov		ESI,	[EBP+36]					; holds the string from usrs input
	mov		ECX,	[EBP+24]					; holds len
	mov		EDI,	[EBP+20]
	mov		EBX,	10													
	mov		EAX,	0													
	mov		EDX,	0					        ;accumulator


_innerLoop:
	lodsb
	cmp		AL,  45					      ; checks for negative num
	je		_negativeNum
	cmp		AL,  48
	jb		_invalid
	cmp		AL,  57
	ja		_invalid
	jmp		_validInt

_negativeNum:
	mov		EAX,  1
	mov		[EBP+16],  EAX                     ; 1 represnets neg num
	jmp		_increment

_validInt:
	sub		AL,  48
	push		EAX															
	mov		EAX,	[EDI]												
	mul		EBX
	mov		EDX,	EAX													
	pop		EAX
	add		EDX,	EAX
	cmp		ECX,	1													
	je		_edgeCase

_addUp:
	cmp		EDX,	SIGNED_MAX
	ja		_invalid
	cmp		EDX,	SIGNED_MIN
	jl		_invalid
	jmp		_increment

_invalid:
	mov		EDX,	[EBP+8]
	call		WriteString
	call		CrLf
	mov		EDX,	[EBP+12]
	call		WriteString
	mov		EAX,	0
	mov		[EDI],	EAX						 ; clears invalid ints
	mov		EDX,	0													
	mGetStringSimplified	[EBP+36], CHARACTER_LIMIT, [EBP+24]		; calls macro with error string

	mov		ESI,	[EBP+36]					; holds input string
	mov		ECX,	[EBP+24]											
	jmp		_innerLoop

_increment:
	mov		[EDI],	EDX						; saves the accumulated sum
	loop		_innerLoop
	mov		EAX,	1
	cmp		[EBP+8],	EAX
	je		_reset
	jmp		_endLoop

_edgeCase:							; (-2147483648)
	mov		EAX,  1
	cmp		[EBP+16],  EAX
	jne		_addUp
	cmp		EDX,	[EBP+28]  
	ja		_invalid
	jmp		_increment

_reset:
	pushad
	mov		EAX,  [EDI]
	mov		EBX,	-1
	mul		EBX
	mov		[EDI],	EAX
	mov		EAX,  0
	mov		[EBP+16],	EAX		  ; resets sign
	popad

_endLoop:
	popad
	pop		EBP
	ret		36

ReadVal ENDP


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
WriteVal PROC

; The PROC converts vals to ascii representations, stores them in usrInputStr, then uses the macro mDisplayString to print to terminal
; Preconditions: setup stack frame and access parameters on runtime stack using Base+Offset; EBX utilized to check sign
; Postconditions: the offset of the converted string
; Receives: usrInput usrInputStr
; Returns: an array with all ten inputs printed in termial 
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  	push     	EBP
  	mov      	EBP,    ESP
	pushad

	mov		EAX,	[EBP+8]
	mov		EAX,	[EAX]
	mov		EDI,	[EBP+12]
	mov		EBX,	0													
	mov		ECX,	1													
	cmp		EAX,	0						; check sign
	jl		_neg
	jmp		_asciiConversion

_neg:
	neg		EAX															
	mov		EBX,	1
	
_asciiConversion:
	push		EBX
	mov		EBX,	10
	cdq
	idiv		EBX				; quotient in eax, remainder in edx
	pop		EBX

	cmp		EAX,	0
	je		_previousDigit													
	add		EDX,	48				; more division
	push		EDX
	add		ECX,	1
	jmp		_asciiConversion												

_previousDigit:
	add		EDX,	48
	push		EDX														

	cmp		EBX,	1
	je		_makeNeg										
	jmp		_pop

_makeNeg:
	push		45			;adds negative sign back to negative nums
	add		ECX,	1

_pop:
	pop		EAX
	stosb																	
	loop		_pop
	mov		AL,		0
	stosb
	mov		EDI,	[EDI]

	popad
 	pop     	EBP
  	ret     	12

WriteVal ENDP

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Calculate PROC

;Calculates and displays the sum and average via macros
; Preconditions: usrInput, avg and sum pushed onto the stack
; Postconditions: sum and avg updated 
; Receives: usrInput, avg, sum 
; Returns: calculated sum and average
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    push        EBP
    mov         EBP,    ESP
    pushad

    mov         ESI,    [EBP+16]                                            
    mov         ECX,    INPUT_CAP               ; global variable for the hard cap of 10 inputs from usr
    mov		EAX,	0
    mov		EBX,	0

_calculate:						;calculate sum
    mov         EBX,    [ESI]                           ; moves from usrInput
    add         EAX,    EBX
    add         ESI,    4								
    loop        _calculate
    mov		EDX,	[EBP+8]
    mov         [EDX],	EAX								
    cdq							;calculates avg
    mov		EBX,	INPUT_CAP
    idiv	EBX
    mov		EDX,	[EBP+12]
    mov        [EDX],   EAX
    
    popad
    pop         EBP
    ret         8

Calculate ENDP

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
displayArray PROC

; Dispays in terminal
; Preconditions: UsrInputStr, usrInput, intArray, commaSpace, sign and line pushed onto stack
; Postconditions: prints output to terminal
; Receives: usrInputStr, usrInput, intArray, commaSpace, sign and line
; Returns: prints values in the terminal
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	push		EBP
	mov		EBP,	ESP
	pushad

	mov		EDX, [EBP+8]
	call		WriteString
	call		CrLf
	mov		ECX,	INPUT_CAP
	mov		EDX,	[EBP+24]
	mDisplayString	[EBP+20]

_output1:
	push		[EBP+12]
	push		[EBP+28]
	push		EDX
	call		WriteVal
	mDisplayString	[EBP+28]
	cmp		ECX,	1
	je		_output2		; the last item in the array is not appended with a comma
	mDisplayString	[EBP+16]

_output2:
	add		EDX,	4
	loop		_output1
	call		CrLf

	popad
	pop		EBP
	ret		20

displayArray ENDP

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
goodbye PROC

; Says Goodbye!

; Preconditions:setup stackframe with line and bye1
; Postconditions: goodbye message printed in the terminal
; Receives: 1) strings pushed onto the stack
; Returns: Prints goodbye
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	push		EBP
	mov		EBP,	ESP
	call		CrLf
	call		CrLf
	mDisplayString	[EBP+12]
	call		CrLf
	mDisplayString	[EBP+8]
	call		CrLf
	call		CrLf
	pop		EBP
	ret		4

goodbye ENDP

END main
