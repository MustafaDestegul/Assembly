

;LABEL		DIRECTIVE	VALUE		COMMENT
			AREA    	main, READONLY, CODE
			THUMB
			;ALIGN
			EXTERN		OutStr	; Reference external subroutine	
			EXPORT  	__main	; This should be change as __ main with the first label when compiling alone otherwise will not work as subroutine. For now, make it CONVRT 



__main		PROC        ;Push instructions for the usage of Subroutine... i.e, to prevent the register manipulation
			PUSH	{R0}
			PUSH	{R1}
			PUSH	{R2}
			PUSH	{R3}     
								;R4 WILL BE CHANGE ALWAYS WHENEVER THIS SUBROUTINE IS CALLED, SO NO NEED TO PUSH TO STACK
			PUSH	{R5}		; BUT OTHERS SHOULD BE STACKED.
			PUSH	{R6}
			PUSH	{R7}
			PUSH	{R8}
			
			LDR		R4 ,=55640		    ;For the usage AS MAIN ADD THIS LINE  
			LDR		R5, =0x20000040		;destiantion to ASCII characters
			BFC		R3,	#0,	#31 		;Clear the R3 register   
			LDR		R1, =0x3B9ACA00     ;Load R1=10^8
			LDR		R2, =0x0A           ;10 is loaded to R2
			MOV		R0 ,#10			    ;Counter starting from 10 since maximum number is 10 digit
			MOV		R8 ,#4				;To end the process add 0x04 to the R5's last address				
			
			
			
LeadingZeros
			UDIV	R3,R4,R1            ;To ignore the leading zeros chech the division 
			CMP		R3,#0
			BEQ		DeleteZeros
			B		Hex2Dec

DeleteZeros
			SUBS	R0, #1
			UDIV	R1,R2			;R1 is updated by dividing 10 all time 
			B		LeadingZeros
			
Hex2Dec		UDIV	R3,R4,R1   		; Founding the division
			B		ASCII			
		
Cont		STRB	R6,[R5],#1		;ascii code is loaded to the R5 pointer address
			MUL		R7,R1,R3		;r7 is the subract from the R3 and updated
			SUB		R4,R7			;whole number is subtracted by the sbtant
			UDIV	R1,R2			;R1 is updated by dividing 10 all time 
			SUBS	R0, #1			;Counter decreased by 1
			BNE		Hex2Dec			; go and find the next division 
			STRB	R8,[R5]			; load 0x04 to the end
			LDR		R5,=0x20000040	; reset the pointer for the OutStr subroutine
			BL		OutStr   		;go OutStr to press the numbers to the termit
			
						
;			
			POP		{R8}				
			POP		{R7}			; take the saved registers from the stack back
			POP		{R6}
			POP		{R5}
			POP		{R3}
			POP		{R2}
			POP		{R1}
			POP		{R0}
			
			BX		LR			
					
; LABELS to load the ascii characters of  division to save at R5 address pointer 					
			
load0		LDR		R6,=0x30		;ascii code of R3=0 ...
			B		Cont
load1		LDR		R6,=0x31		;ascii code 
			B		Cont
load2		LDR		R6,=0x32		;ascii code 
			B		Cont
load3		LDR		R6,=0x33		;ascii code 
			B		Cont
load4		LDR		R6,=0x34		;ascii code 
			B		Cont
load5		LDR		R6,=0x35		;ascii code 
			B		Cont
load6		LDR		R6,=0x36		;ascii code 
			B		Cont
load7		LDR		R6,=0x37		;ascii code 
			B		Cont
load8		LDR		R6,=0x38		;ascii code 
			B		Cont
load9		LDR		R6,=0x39		;ascii code 
			B		Cont

					

;Choosing which ASCII character will be loaded according to the division

ASCII		CMP 	R3, #0x00
			BEQ		load0
			CMP 	R3, #0x01
			BEQ		load1	
			CMP 	R3, #0x02
			BEQ		load2	
			CMP 	R3, #0x03
			BEQ		load3	
			CMP 	R3, #0x04
			BEQ		load4	
			CMP 	R3, #0x05
			BEQ		load5	
			CMP 	R3, #0x06
			BEQ		load6	
			CMP 	R3, #0x07
			BEQ		load7
			CMP 	R3, #0x08
			BEQ		load8
			CMP 	R3, #0x09 ; CHECK THEM
			BEQ		load9			
			
			

			
		ENDP


		END
