			AREA	main, READONLY, CODE, ALIGN=2
			THUMB
			;ALIGN
			;EXTERN	Counter	; Reference external subroutine	
			EXPORT	__main


GPIO_PORTB_DATA 	EQU		0x400053FC ; data address to all pins
GPIO_PORTB_DIR 		EQU 	0x40005400
GPIO_PORTB_AFSEL 	EQU 	0x40005420
GPIO_PORTB_DEN 		EQU 	0x4000551C
IOB 				EQU 	0x0F		; B[7:4]= IN,  B[3:0]=OUT


SYSCTL_RCGCGPIO 	EQU 	0x400FE608			

__main		PROC

			BL	GPIO_Init
			
			LDR	R0,=GPIO_PORTB_DATA   	; data register address  B[7:4]-> Inputs for buttons B[3:0]-> outputs for step motor
			LDR	R1,=0					; load 0 to r1 to be loaded data register for initialization of the motor to 0 degree
			STR	R1,[R0]					; Go "0" degree at the beginning
			
Loop		LDR	R1,[R0]					; r1 keeps the data register value	
			AND	R2,R1,#0x0F				; r2 keeps the information of the PORTB outputs
			AND R3,R1,#0x40				; r3 keeps the clock wise direction information if pressed 0 o.w 1
			AND R4,R1,#0x80				; r4 keeps the counter clock wise direction information  if pressed 0 o.w 1
	; Deboucing part		
			BL	Delay50m				; for debouncing			
			AND	R5,R3,R4				; ORR r3 and r4. if the result is 0 then button is pressed
			CMP	R5,#0					; if r5 is 0 then loop again. otherwise chech the values 
			BNE	Loop
			BL	Delay50m
			
			CMP	R3,#0					; if clock wise direction button is pressed 		
			BEQ	CW						; go CW label
			CMP	R4,#0					; else if Counter clock wise direction is pressed
			BEQ	CCW						; go counter clock wise 
			B	Loop					; else go to Loop label back 
		
CW
		;	LDR	R1,[R0]
		;	AND R3,R1,#0x40		
		;	CMP	R3,#0	
		;	BEQ	Loop	
			CMP	R2,#0					; If the degree is 0 then load 1000 for CW operation 
			BEQ	CWCont
	
			LSR	R2,#1					; if the OUTPUTS value is not 0 after the button is pressed shift right one time
			STRB	R2,[R0]				; then load the shifted value to the portb output ports.
			B	Loop					; then Loop again
		
CCW
		;	LDR	R1,[R0]
		;	AND R4,R1,#0x80		
		;	CMP	R4,#0	
		;	BEQ	Loop
			CMP	R2,#0					; If the degree is 0 then load 0001 for CW operation 
			BEQ	CCWCont
			LSL	R2,#1					; if the degree is not 0 shift left one time
			STRB	R2,[R0]				; then load the shifted value to the portb output ports.
			B	Loop	

Delay50m	LDR	R5,=800000				;	50m sec delay constant
CONT		SUBS	R5,#1
			BNE		CONT
			BX	LR
			
CCWCont			
			LDR	R3,=1				   ; 0001 Value
			STRB R3,[R0]				; load 0001 to PORTB output pins.	
			B	Loop		
CWCont
			LDR	R3,=8				; 1000 Value in binary
			STRB R3,[R0]				; load 1000 to PORTB output pins.	
			B	Loop	



GPIO_Init
		LDR R1 , =SYSCTL_RCGCGPIO
		LDR R0 , [R1]
		ORR R0 , R0 , #0x02  		; B  port is enabled clock.
		STR R0 , [R1]
		NOP
		NOP
		NOP							;let GPIO clock stabilize

		LDR R1 , =GPIO_PORTB_DIR 	;config. of port B starts
		LDR R0 , [R1]
		BIC R0 , #0xFF
		ORR R0 , #IOB
		STR R0 , [R1]               ;b7-b5->input, b4-b0->output... (0x0f).
		
		LDR R1 , =GPIO_PORTB_AFSEL	; no alternating function option 
		LDR R0 , [R1]
		BIC R0 , #0xFF
		STR R0 , [R1]
		
		LDR R1 , =GPIO_PORTB_DEN	; digital enable of the B port
		LDR R0 , [R1]
		ORR R0 , #0xFF
		STR R0 , [R1] 		
	
		BX	LR
						
			
			ALIGN
			ENDP
			END