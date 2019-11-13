
;LABEL		DIRECTIVE	VALUE		COMMENT
			AREA    	main, READONLY, CODE
			THUMB
			;ALIGN 
			EXTERN		InChar	; Reference external subroutine
			EXTERN		OutStr	; Reference external subroutine	
			EXTERN		convrt	; Reference external subroutine	
			EXPORT  	__main	; This should be change as __ main with the first label when compiling alone otherwise will not work as subroutine. For now, make it CONVRT 

__main 		PROC
	
			LDR		R5,=100		; Number of soulstones TO BE entered from the TERMIT
			;MOV		SP,#0x20000200  ; Starting point of the stack
			LDR		R10,=0x20000060;	; Pointer to load the min numbers...
			LDR		R0,=21			
			BFC		R7,#0,#31 			; will keep track the number how maany times recursive function is entered
			LDR		R8,=2
			CMP		R5,#0				;first check the number if it is 0 or not.
			BEQ		CuttingExecution	;if 0 go directly result else go next line 
			BL		Recursive
			BL		FindingMinNumber	; after possible min numbers are decided, we will choose the min one omaung them.
			
			
FindingMinNumber  						;R11 STORES THE LENGTH AND R10 HOLDS THE ADDRESS OF CANDIDATE MIN. NUMBERS
									
			LDR 	R2, [R10],#4		; R2 holds the mininimum
			SUBS 	R11, #1 			; Decrement counter
			BEQ		Final				; If it is the end of the array, finish
Loop		LDR 	R3, [R10],#4 		; R3 holds the next data
			CMP 	R2, R3 				; R2 - R3
			BLO 	Continuos 				; If R2<R3, go to Cont
			LDR 	R2, [R10] 			; Else load the new data to min (R2)
Continuos 		
			SUBS 	R11, #1				; Decrement counter
			BEQ 	Final 				; If it is the end of the array, finish
			B		Loop 				; Else go to Loop
Final 		STR 	R2, [R4] 			; Store min
			BL		convrt
Forever 	B 		Forever	






Recursive	
			ADD		R7,#1	

CheckForBaseCondition
			CMP		R5,#0  		;Exit if THE left soulstone is 0
			BEQ		CuttingExecution		;Go and pop all solution from the Stack
			
StartOfPortal4	;started from the portal 4 for efficiency...
			UDIV	R3,R5,R0  	;Modulo operation. Divide by 21, mul divident by 21 and subtract each other. if 0 then the number is multiplican of 21	
			MUL		R4,R3,R0	; r0=21
			SUBS	R4,R5,R4	
			CMP		R4,#0			
			BEQ		CuttingExecution
			B		StartofProtal1	;If the number is not a multiplicant of 21 then go and process the other portal

StartofProtal1
			CMP		R5,#99		;compare R5 with 99
		;	ITTT	HI			;if higher then make necassary operations
			BLHI	Portal1
			PUSHHI	{LR,R5}		;Save the remaining soulstones and LR to the stack.
			BLHI	Recursive	;repeat the process again to find other possibilities
StartofProtal2					
			CMP		R5,#50		;Chech r5>50 && odd
			BHI		Cont		; if higher then check odd or not
			B		StartOfPortal3	
Cont		BL		IsitOdd
			BL		Portal2		;find the remaining soulstones after portal 2 is passed.
			PUSH	{LR,R5}		;Save the remaining soulstones and LR to the stack.
			BL		Recursive	;repeat the process again to find other possibilities
			
StartOfPortal3
			TST		R5,#1		;And with 1 but dont save the result. Just use for chechink evenness	
			BLEQ	Portal3		; we checked the LSB of r5 to decide even or odd
			PUSHEQ	{LR,R5}		;Save the remaining soulstones and LR to the stack.
			BLEQ    Recursive

AnotherBaseConditon				;If none of the function is entered then the number is the possible candidate to be the min number. Save it... 
							
			BL  	MinNumberDetection                 ; store the min number to the pointer address then go the the last LR

			BL		Recursive
			

MinNumberDetection
			ADD		R11,#1		;Stores the number of the possible min numbers length...
			POP		{R5}		;store the min. number to the address r10
			STR 	R5,[R10],#4	;store and increment the address for the new solution
			MUL		R7,R8		;Multiplied by 2 since each time saves 2 things. 
Counter		POP		{LR,R5}		;each time pop lr and r5 to be refreshed to go the other portal
			CMP		R7,#2		;last 2 stack number is protected S
		;	ITTEE	NE			
			SUBNE	R7,#2
			BNE		Counter
			LDREQ	R5,=100 ; 
			POP		{LR}
			MOVEQ	PC,LR
			BX		LR
			
;**************CUTTING THE EXECUTION SUDDENLY SINCE THE MINIMUM REMANININ SOULSTONE IS FOUND
CuttingExecution
			ldr		r4,=0
			BL		convrt
;B			Done	B

;***********************END********************************************************

;***********************PORTAL1 STARTS HERE**********************************
Portal1		    ; Make necassary operations on R5
			SUBS	R5,#47
		;	BEQ		CuttingExecution	
			BX		LR


;***********************PORTAL 1 ENDS HERE
;*****************PORTAL 2***************************************************

Portal2	      ;SoulStones - Multiplication of non zero digits
			LDR		R1, =0x3B9ACA00      ; Load R1=10^8
			LDR		R2, =0x0A            ;10 is loaded to R2
			LDR		R4, =0x01            ;R4 IS LOADED WITH 1  for the multiplication of non-zero digits
			PUSH	{R5}				; WILL CHANGE LATER, SO SAVED
			
Again		
			UDIV	R1,R2				; divide r1 to r2 each time
			UDIV	R3,R5,R1			; if r3 is 0 then check again till the result is not 0
			CMP		R3,#0
			BEQ		Again		
			MUL		R9,R3,R1			; if not zero, subtract r5 by division and save the multiplicant of non zero digits
			SUBSNE	R5,R5,R9			;
			MUL		R4,R4,R3			; save the non-zero digits
			CMP		R5,#0				; if r5 is zero then go result.
			BEQ		Result
			B		Again
Result		
			POP		{R5}				; since our r5 changes in portal 2 i pushed and pop it again 
			SUB		R5,R4				; after operations are done.
			BX		LR
			
;*****************PORTAL 2 ENDS HERE**************************************************			
;*****************PORTAL 3 STARTS HERE*************************************************

Portal3		
			UDIV	R5,R8				; R5 is divided by 2 to find the left soulstones
			BX		LR	
			
;****************PORTAL 3 ENDS HERE****************************************************
;****************PORTAL	4 STARTS HERE
;PORTAL4 WILL BE CHECKING DIRECTLY IN THE RECURSIVE FUNCTION...

;***************DECIDING REMAINING R5 IS ODD OR EVEN**************************
IsitOdd		TST		R5,#1  ; AND the R5 with 1 then updates the PSR flags.   LOOK AT THE USAGE...
			;ITE		EQ     ; if the LSB is 1 then odd else even		
			BEQ		StartOfPortal3
			BXNE		LR  ; zero flag not set - meaning it's odd. If this is ok then go Portal2 else Portal3			
			
;******************************************************************************	

	
			ENDP
			END