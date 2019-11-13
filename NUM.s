

;LABEL		DIRECTIVE	VALUE		COMMENT
			AREA    	Pre1Q_2, READONLY, CODE
			THUMB
			;ALIGN
			EXTERN		InChar	; Reference external subroutine	
			EXTERN		OutStr	; Reference external subroutine	
			EXTERN		convrt	; Reference external subroutine	
		
			EXPORT  	__main	; Make available


NUM			EQU			0x20000070   	


__main		PROC
			LDR		R1,=NUM     ; Load the address to a register to be consistent
			LDR		R2,=4		;counter for the bytes
			BFC		R4,#0,#31	; clearing the r4 register
Forever		BL		InChar		; wait for character from the keyboard
Loop		LDR		R4,[R1],#1	; R4 is loaded with the data and send to the convrt subroutine to be sent to screen
			BL		convrt  	;the pointer pointing to R5 register should be passed the compareconvrt2 subroutine...	
			SUBS	R2,#1		; counter to sent the 4 bytes data
			BNE		Loop		; If the bytes not completed go loop
			B		Forever		; IF the 4 bytes data is sent go and wait for another 4 bytes data 

