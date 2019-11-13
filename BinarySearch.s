		
		AREA sdata , DATA, READONLY
		THUMB
MSG 	DCB 	"ENTER The Upper Bound Digit 'n' ..."	
		DCB 	0x0D
		DCB 	0x04



		AREA    	main, READONLY, CODE
		THUMB
	 	EXTERN		OutStr	; Reference external subroutine	
		EXTERN		convrt
		EXTERN		InChar
		EXTERN		OutStr
		EXPORT  	__main	; Make available

;n		EQU			10

; Notes: DONT USE R4 AND R5, only for CONVRT subroutine
__main	PROC	
				LDR		R5,=MSG
				BL		OutStr
				BL 		InChar
				BL		LoadTheNumber
				
				
				
	;***********************************Code starts here		
				;MOV 	R0, #n   		 ;n : the number given by the user
				LDR		R6, =0x20000070   ; Temporary storage location for changing the boundaries
				MOV		R1,	#1		;Set r1 as 0x01 
				LSL		R1, R0     ; R1 is loaded with the upper bound number as 2^n
				BFC		R0,#0,#31
				SUB		R2,R1,R0   ; ADD RO AND R1, UPPER AND LOWER BOUNDS
				MOV		R3, #2
				UDIV	R2,R2,R3   ; R2 IS THE MIDDLE NUMBER for the first guess TO BE SENT TO THE SECREEN	
				;MOV32	R4,#512		; SEND MIDDLE VALUE TO THE CONVRT; for know it is decided n=10 and mid value as 512; CHANGES LATER
				STR		R2,[R6]			; store the R0 (lower boundary) to a address		
				LDR		R4,[R6]			;Load the lower boundary  to r2 since up is pressed
				NOP
				BL		convrt		; Call CONVRT TO SEND THE MIDDLE VALUE TO BE SEEN ON THE SECREEN
				;LDR		R8,=222
NewGuess		BL		InChar		 ; Take character from the keybord and load the R5 register
				CMP 	R5,#0x55      ;If U is pressed 
				BEQ		UP
				CMP		R5,#0x44
				BEQ		DOWN
				CMP		R5,#0x43
Done			B		Done
				
		
UPBND	    
				
				B		NewGuess
			
UP      
	; r6 and r7 is used for 
				STR		R2,[R6]			; store the R0 (lower boundary) to a address		
				LDR		R0,[R6]			;Load the lower boundary  to r2 since up is pressed 
				SUB		R4,R1,R2
				UDIV	R4,R3      		;R4= (LAST- MIDDLE)/2 
				ADD		R2,R4           ;R2 IS UPDATED BY ADDING THe FIRST MIDDLE VALUE  to the second 
			;	MOV32	R4,R2			; r4 is the value which takes the updated midde value to send the user
				STR		R2,[R6]			; r4 is the value which takes the updated midde value to send the user
				LDR		R4,[R6]			; load R2 TO R4
				BL		convrt			;  UPDATED MIDDLE VALUE IS SENT TO THE USER TO BE DECIDED CORRECT Value or not  
				B		UPBND			


DOWN			
				;MOV32	R1,R2			;first arrange the UPPER boundary
				STR		R2,[R6]				
				LDR		R1,[R6]			; set middle value as upper boundary  
				SUB		R4,R2,R0
				UDIV	R4,R3      		;R4= (middle- first)/2 
				SUB		R2,R1,R4           ; REVERSE SUBTRACTION; R2 IS UPDATED BY ADDING THe FIRST MIDDLE VALUE  to the second 	
				;MOV32	R4,R2			; r4 is the value which takes the updated value as input 
				STR		R2,[R6]			; store the R0 (lower boundary) to a address		
				LDR		R4,[R6]			;Load the lower boundary  to r2 since up is pressed
				BL		convrt			;  UPDATED MIDDLE VALUE IS SENT TO THE USER TO BE DECIDED CORRECT Value or not  
				B		UPBND			
				
LoadTheNumber
				CMP		R5,#0x30
				MOVEQ	R0,#0
				BXEQ	LR
				CMP		R5,#0x31
				MOVEQ	R0,#1
				BXEQ	LR
				CMP		R5,#0x32
				MOVEQ	R0,#2
				BXEQ	LR
				CMP		R5,#0x33
				MOVEQ	R0,#3
				BXEQ	LR
				CMP		R5,#0x34
				MOVEQ	R0,#4
				BXEQ	LR
				CMP		R5,#0x35
				MOVEQ	R0,#5
				BXEQ	LR
				CMP		R5,#0x36
				MOVEQ	R0,#6
				BXEQ	LR
				CMP		R5,#0x37
				MOVEQ	R0,#7
				BXEQ	LR
				CMP		R5,#0x38
				MOVEQ	R0,#8
				BXEQ	LR
				CMP		R5,#0x39
				MOVEQ	R0,#9
				BXEQ	LR	
				
				ENDP
				END
