.ORIG x3000

; --------- Instructions ---------
LEA R0, PROMPT
PUTS

LD R0, ARRAY_START
AND R1, R1, #0
ADD R1, R1, #-1

FETCH_NUMBERS
	LD R6, SUB_GET_NUMBER_PTR
	JSRR R6
	STR R2, R0, #0
	ADD R0, R0, #1
	ADD R1, R1, #1
	ADD R6, R6, #0
BRz FETCH_NUMBERS ; Take decimal numbers from input and store them at x4000

LD R2, ARRAY_START
LD R6, SUB_SELECTION_SORT_PTR
JSRR R6

LD R0, ASCII_NEWLINE
OUT
OUT
LEA R0, DISPLAY
PUTS

PRINT_NUMBERS
	LD R6, SUB_PRINT_BINARY_PTR
	JSRR R6
	ADD R1, R1, #-1
	BRz SKIP_PRINT
		LD R0, ASCII_COMMA
		OUT
		LD R0, ASCII_SPACE
		OUT
	SKIP_PRINT
	ADD R1, R1, #1
	ADD R2, R2, #1
	ADD R1, R1, #-1
BRp PRINT_NUMBERS

HALT

; --------- Data ---------
PROMPT	.STRINGZ	"Input a list of decimal numbers (range -32768 to 32767), each followed by ENTER. Numbers 5 digits long will automatically be inputted with no enter. Type \"d\" to finish inputting numbers.\n"
DISPLAY	.STRINGZ	"Sorted list:\n"
ASCII_COMMA	.FILL	#44
ASCII_SPACE	.FILL	#32
ASCII_NEWLINE	.FILL	#10
ARRAY_START	.FILL	x4000
SUB_GET_NUMBER_PTR	.FILL	x3200
SUB_SELECTION_SORT_PTR	.FILL	x3400
SUB_PRINT_BINARY_PTR	.FILL	x3600



; =====================================================================================
; Subroutine: SUB_GET_NUMBER
; No parameters
; Postcondition: The subroutine has asked the user for a decimal number from the range
;				 -32768 to 32767 and stored it in R2. No error checking is done if
;				 the magnitude is greater than the given range, but the program will
;				 ask for another number if any invlaid characters are inputted.		 
; Return Value (R2): The decimal number entered by the user, converted to two's
;				     complement binary
; Return Value (R6): Returns 1 if the user inputs a 'd' as the first character, 0
;					 otherwise
; =====================================================================================

.ORIG x3200		

; --------- Instructions ---------
ST R0, BACKUP_R0_3200
ST R1, BACKUP_R1_3200
ST R4, BACKUP_R4_3200
ST R5, BACKUP_R5_3200
ST R7, BACKUP_R7_3200

AND R6, R6, #0
ADD R6, R6, #1

ASK_AGAIN_3200	
			
GETC
OUT

AND R2, R2, #0
AND R5, R5, #0
ST R5, IS_NEGATIVE_3200
ADD R5, R5, #5

CHECK_NEWLINE_OR_d_3200
	ADD R1, R0, #0 ; Load the inputted character into R1
	LD R3, NEG_ASCII_NEWLINE_3200
	ADD R0, R0, R3 
	BRz END_3200 ; if the first character is '\n'
	ADD R0, R1, #0
	LD R3, NEG_ASCII_d_3200
	ADD R0, R0, R3
	BRz END_3200 ; if the first character is 'd'
	BRnzp CHECK_PLUS_3200

CHECK_PLUS_3200
	ADD R0, R1, #0
	LD R3, NEG_ASCII_PLUS_3200
	ADD R0, R0, R3
	BRnp CHECK_MINUS_3200
		GETC ; else if the first character is '+'
		OUT
		ADD R1, R0, #0
		BRnzp CHECK_LESS_THAN_ZERO_3200 ; Get another character and check if the newly inputted character is a digit

CHECK_MINUS_3200
	ADD R0, R1, #0
	LD R3, NEG_ASCII_MINUS_3200
	ADD R0, R0, R3
	BRnp CHECK_LESS_THAN_ZERO_3200
		AND R0, R0, #0 ; else if the first character is '-'
		ADD R0, R0, #1
		ST R0, IS_NEGATIVE_3200
		GETC
		OUT
		ADD R1, R0, #0				; Set IS_NEGATIVE to 1 and get another character
		BRnzp CHECK_LESS_THAN_ZERO_3200  ; and check if the newly inputted character is a digit
	
CHECK_LESS_THAN_ZERO_3200
	ADD R0, R1, #0
	LD R3, NEG_ASCII_ZERO_3200
	ADD R0, R0, R3
	BRzp CHECK_GREATER_THAN_NINE_3200 ; else if the first character is less than '0'
		LD R0, ASCII_NEWLINE_3200
		OUT
		LEA R0, ERROR_MESSAGE_3200
		PUTS
		BRnzp ASK_AGAIN_3200
	
CHECK_GREATER_THAN_NINE_3200
	ADD R0, R1, #0
	LD R3, NEG_ASCII_NINE_3200
	ADD R0, R0, R3
	BRnz FETCH_DIGITS_3200 ; else if the first character is greater than '9'
		LD R0, ASCII_NEWLINE_3200
		OUT
		LEA R0, ERROR_MESSAGE_3200
		PUTS
		BRnzp ASK_AGAIN_3200
	
FETCH_DIGITS_3200 ; else (At this point, R1 holds the inputted value and contains an inputted digit)
	ADD R2, R2, R2
	ADD R4, R2, #0
	ADD R2, R2, R4
	ADD R2, R2, R4
	ADD R2, R2, R4
	ADD R2, R2, R4
	LD R3, NEG_ASCII_ZERO_3200
	ADD R1, R1, R3
	ADD R2, R2, R1 ; Mutliply R2 by 10 and add the newly inputted digit
	
	ADD R5, R5, #-1
	BRp COUNTER_IS_NOT_ZERO_3200 ; Counter has hit zero and 5 digits have been input, send a newline
		LD R0, ASCII_NEWLINE_3200
		OUT
		BRnzp FINISH_3200
	
	COUNTER_IS_NOT_ZERO_3200

	GETC
	OUT
	CHECK_NEWLINE_NEW_DIGIT_3200
		ADD R1, R0, #0
		LD R3, NEG_ASCII_NEWLINE_3200
		ADD R0, R0, R3 
		BRnp CHECK_LESS_THAN_ZERO_3200 ; Go back and check if the inputted character is a digit
			BRnzp FINISH_3200 ; Runs if a newline is entered after digits
			
FINISH_3200 ; Lastly, make R2 negative if the IS_NEGATIVE flag is 1
	LD R0, IS_NEGATIVE_3200
	BRz NOT_NEGATIVE_3200
		NOT R2, R2
		ADD R2, R2, #1
	NOT_NEGATIVE_3200

AND R6, R6, #0

END_3200
LD R0, BACKUP_R0_3200
LD R1, BACKUP_R1_3200
LD R4, BACKUP_R4_3200
LD R5, BACKUP_R5_3200
LD R7, BACKUP_R7_3200
			
RET

; --------- Data ---------
NEG_ASCII_NEWLINE_3200	.FILL	#-10
NEG_ASCII_PLUS_3200	.FILL	#-43
NEG_ASCII_MINUS_3200	.FILL	#-45
NEG_ASCII_ZERO_3200	.FILL	#-48
NEG_ASCII_NINE_3200	.FILL	#-57
NEG_ASCII_d_3200	.FILL	#-100
ASCII_NEWLINE_3200	.FILL	#10
IS_NEGATIVE_3200	.FILL	#0		
ERROR_MESSAGE_3200	.STRINGZ	"ERROR: invalid input. Please try again\n"

BACKUP_R0_3200	.BLKW	#1
BACKUP_R1_3200	.BLKW	#1
BACKUP_R4_3200	.BLKW	#1
BACKUP_R5_3200	.BLKW	#1
BACKUP_R7_3200	.BLKW	#1

; =====================================================================================
; End subroutine
; =====================================================================================



; =====================================================================================
; Subroutine: SUB_SELECTION_SORT
; Parameter (R1): The size of the array to be sorted
; Parameter (R2): The starting address of the array to be sorted
; Postcondition: The subroutine has sorted the array at the address specified by R2
;				 using the selection sort algorithm.
; No return values
; =====================================================================================

.ORIG x3400		

; --------- Instructions ---------
ST R0, BACKUP_R0_3400
ST R1, BACKUP_R1_3400
ST R2, BACKUP_R2_3400
ST R3, BACKUP_R3_3400
ST R4, BACKUP_R4_3400
ST R5, BACKUP_R5_3400
ST R6, BACKUP_R6_3400
ST R7, BACKUP_R7_3400

;	if (size < 2) {
;		return;
;	}
;	for (int i = 0; i < size - 1; i++) {
;		int smallestIndex = i;
; 		for (int j = i + 1; j < size; j++) {
;			if (array[j] < array[smallestIndex]) {
;				smallestIndex = j;
;			}
;		}
;		int temp = array[smallestIndex];
;		array[smallestIndex] = array[i];
;		array[i] = temp;
;	}

ADD R6, R1, #0
ADD R6, R6, #-1
BRp CONTINUE_3400
	BRnzp END_3400
CONTINUE_3400

AND R6, R6, #0 ; int i = 0
OUTER_LOOP_3400
	ADD R0, R6, #0 ; int smallestIndex = i;
	ADD R3, R6, #1 ; int j = i + 1

	INNER_LOOP_3400
		ADD R4, R3, R2
		ADD R5, R0, R2
		LDR R4, R4, #0 ; array[j]
		LDR R5, R5, #0 ; array[smallestIndex]
		NOT R5, R5
		ADD R5, R5, #1
		ADD R4, R4, R5 ; array[j] - array[smallestIndex]
		BRzp NOT_SMALLER_3400 ; if (array[j] < array[smallestIndex]) {
			ADD R0, R3, #0 ; smallestIndex = j;
		NOT_SMALLER_3400 ; }
		
		ADD R3, R3, #1 ; j++
		ADD R4, R3, #0 ; j
		ADD R5, R1, #0 ; size
		NOT R5, R5
		ADD R5, R5, #1
		ADD R4, R4, R5 ; j - size
	BRn INNER_LOOP_3400 ; j < size

	ADD R5, R0, R2
	LDR R5, R5, #0 ; array[smallestIndex]
	ADD R4, R2, R6
	LDR R4, R4, #0 ; array[i]
	ADD R3, R0, R2
	STR R4, R3, #0 ; array[smallestIndex] = array[i]
	ADD R3, R2, R6
	STR R5, R3, #0 ; array[i] = array[smallestIndex]
	
	ADD R6, R6, #1 ; i++
	ADD R4, R6, #0 ; i
	ADD R5, R1, #0 ; size
	ADD R5, R5, #-1 ; size - 1
	NOT R5, R5
	ADD R5, R5, #1
	ADD R4, R4, R5 ; i - (size - 1)
BRn OUTER_LOOP_3400 ; i < size - 1

END_3400
LD R0, BACKUP_R0_3400
LD R1, BACKUP_R1_3400
LD R2, BACKUP_R2_3400
LD R3, BACKUP_R3_3400
LD R4, BACKUP_R4_3400
LD R5, BACKUP_R5_3400
LD R6, BACKUP_R6_3400
LD R7, BACKUP_R7_3400
			
RET

; --------- Data ---------
BACKUP_R0_3400	.BLKW	#1
BACKUP_R1_3400	.BLKW	#1
BACKUP_R2_3400	.BLKW	#1
BACKUP_R3_3400	.BLKW	#1
BACKUP_R4_3400	.BLKW	#1
BACKUP_R5_3400	.BLKW	#1
BACKUP_R6_3400	.BLKW	#1
BACKUP_R7_3400	.BLKW	#1

; =====================================================================================
; End subroutine
; =====================================================================================



; =====================================================================================
; Subroutine: SUB_PRINT_BINARY
; Parameter (R2): Holds the address to be printed
; Postcondition: The subroutine has printed the decimal value at the address R2 holds
; No return values
; =====================================================================================

.ORIG x3600

; --------- Instructions ---------
ST R0, BACKUP_R0_3600
ST R1, BACKUP_R1_3600
ST R2, BACKUP_R2_3600
ST R3, BACKUP_R3_3600
ST R7, BACKUP_R7_3600

AND R3, R3, #0

LDR R1, R2, #0
BRzp IS_POSITIVE
	NOT R1, R1
	ADD R1, R1, #1
	LD R0, ASCII_MINUS
	OUT
IS_POSITIVE

AND R0, R0, #0
ADD R0, R0, #-1
GET_TEN_THOUSANDS_LOOP ; Subtract 10000 from R1 until R1 is negative. Count how many times it can be subtracted
	ADD R0, R0, #1
	LD R2, NEG_TEN_THOUSAND
	ADD R1, R1, R2
BRzp GET_TEN_THOUSANDS_LOOP
LD R2, TEN_THOUSAND
ADD R1, R1, R2
ADD R0, R0, #0
BRz SKIP_PRINT_TEN_THOUSAND
	ADD R3, R3, #1
	LD R2, NUM_TO_CHAR
	ADD R0, R0, R2
	OUT
SKIP_PRINT_TEN_THOUSAND

AND R0, R0, #0
ADD R0, R0, #-1
GET_THOUSANDS_LOOP ; Subtract 1000 from R1 until R1 is negative. Count how many times it can be subtracted
	ADD R0, R0, #1
	LD R2, NEG_ONE_THOUSAND
	ADD R1, R1, R2
BRzp GET_THOUSANDS_LOOP
LD R2, ONE_THOUSAND
ADD R1, R1, R2
ADD R3, R3, #0
BRp GOTO_PRINT_ONE_THOUSAND
ADD R0, R0, #0
BRz SKIP_PRINT_ONE_THOUSAND
	GOTO_PRINT_ONE_THOUSAND
	ADD R3, R3, #1
	LD R2, NUM_TO_CHAR
	ADD R0, R0, R2
	OUT
SKIP_PRINT_ONE_THOUSAND

AND R0, R0, #0
ADD R0, R0, #-1
GET_HUNDREDS_LOOP ; Subtract 100 from R1 until R1 is negative. Count how many times it can be subtracted
	ADD R0, R0, #1
	LD R2, NEG_ONE_HUNDRED
	ADD R1, R1, R2
BRzp GET_HUNDREDS_LOOP
LD R2, ONE_HUNDRED
ADD R1, R1, R2
ADD R3, R3, #0
BRp GOTO_PRINT_ONE_HUNDRED
ADD R0, R0, #0
BRz SKIP_PRINT_ONE_HUNDRED
	GOTO_PRINT_ONE_HUNDRED
	ADD R3, R3, #1
	LD R2, NUM_TO_CHAR
	ADD R0, R0, R2
	OUT
SKIP_PRINT_ONE_HUNDRED

AND R0, R0, #0
ADD R0, R0, #-1
GET_TENS_LOOP ; Subtract 10 from R1 until R1 is negative. Count how many times it can be subtracted
	ADD R0, R0, #1
	ADD R1, R1, #-10
BRzp GET_TENS_LOOP
ADD R1, R1, #10
ADD R3, R3, #0
BRp GOTO_PRINT_TEN
ADD R0, R0, #0
BRz SKIP_PRINT_TEN
	GOTO_PRINT_TEN
	LD R2, NUM_TO_CHAR
	ADD R0, R0, R2
	OUT
SKIP_PRINT_TEN

AND R0, R0, #0
ADD R0, R0, #-1
GET_ONES_LOOP ; Subtract 1 from R1 until R1 is negative. Count how many times it can be subtracted
	ADD R0, R0, #1
	ADD R1, R1, #-1
BRzp GET_ONES_LOOP
ADD R1, R1, #1
LD R2, NUM_TO_CHAR
ADD R0, R0, R2
OUT

LD R0, BACKUP_R0_3600
LD R1, BACKUP_R1_3600
LD R2, BACKUP_R2_3600
LD R3, BACKUP_R3_3600
LD R7, BACKUP_R7_3600

RET

; --------- Data ---------
TEN_THOUSAND	.FILL	#10000
ONE_THOUSAND	.FILL	#1000
ONE_HUNDRED	.FILL	#100
NEG_TEN_THOUSAND	.FILL	#-10000
NEG_ONE_THOUSAND	.FILL	#-1000
NEG_ONE_HUNDRED	.FILL	#-100
ASCII_MINUS	.FILL	#45
NUM_TO_CHAR	.FILL	#48

BACKUP_R0_3600	.BLKW	#1
BACKUP_R1_3600	.BLKW	#1
BACKUP_R2_3600	.BLKW	#1
BACKUP_R3_3600	.BLKW	#1
BACKUP_R7_3600	.BLKW	#1

; ===================================================== ;
;                     End subroutine
; ===================================================== ;

.END
