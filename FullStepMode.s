			
			AREA	main, READONLY, CODE 
			THUMB
			EXPORT	__main


GPIO_PORTB_DATA 	EQU		0x400053FC ; data address to all pins

__main		PROC
			
			PUSH	{R0-R5}
			
			LDR	R0,=GPIO_PORTB_DATA   	; data register address
			LDR	R1,[R0]					; r1 keeps the data register value	
			AND	R2,R1,#0x0F				; R2 keeps the output ports data.
	
	
CW		
			CMP	R2,#0					; If the output port is 0000 then set it to turn on right
			LDREQ	R5,=0x08			; load 00001000 to r5	 
			STREQ R5,[R0]				; load 00001000 to the output
			LSR	R5,#1					; rotate the step motor by 90 degree CW by shifting the register right
			

CCW		
			CMP R2,#0					; If the output port is 0000 then set it to turn on left
			LDREQ	R5,=0x01			; load 00000001 to r5	
			STREQ R5,[R0]				; load 00000001 to the output
			LSL	R5,#1					; rotate the step motor by 90 degree CCW by shifting the register left
		
			ALIGN
			ENDP
			END