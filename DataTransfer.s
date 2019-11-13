;LABEL		DIRECTIVE	VALUE		COMMENT


;******PORTB CONFIGURATIONS******
GPIO_PORTB_DATA 	EQU		0x400053FC ; data a d d r e s s t o a l l pi n s
GPIO_PORTB_DIR 		EQU 	0x40005400
GPIO_PORTB_AFSEL 	EQU 	0x40005420
GPIO_PORTB_DEN 		EQU 	0x4000551C
IOB 				EQU 	0xF0		; Input/ output ports  0in, 1 out
SYSCTL_RCGCGPIO 	EQU 	0x400FE608			



CounterFor5sec		EQU		21258576	; Counter for 5 sec	

			
			AREA	main, READONLY, CODE, ALIGN=2
			THUMB
			;ALIGN
			EXTERN	Counter	; Reference external subroutine	
			EXPORT	__main
			

__main		PROC
		BL	GPIO_Init
	
		LDR R0,=GPIO_PORTB_DATA	 ; When we enabled the Digital enable register, The data register is loaded with all 0s
		LDR	R1,=0x0F        	 ; and LEDs are turning on since we apply 0 to the LEDs (due to hardware of the board connection)
		STR	R1,[R0]				 ; Therefore, to make LEDs turning off at the beginning, Data registers output pins are loaded with 1s


Loop
		BL	Input
		B	Output                 
		
	
Output 							 ; Read the data register address and during 5 sec. load the same value to the output. 
		LDR	R0,=GPIO_PORTB_DATA	 ; After 5 sec, take a new input 
		LSL	R1,#4  				 ; r1 is shifted left by 4 to SHIFT the input data to the output
		LDR	R2,=CounterFor5sec	 ; Since we need to keep output unchanged for 5 sec, we need to wait here for 5 sec.
Delay5sec	
		STR	R1,[R0] 			 ; R1 is stored to the address of port b data register.
		SUBS	R2,#1
		BNE	Delay5sec
		B	Loop				 ; go and loop again
		
		
		
Input 	; read the data register in port b 
		LDR	R0,=GPIO_PORTB_DATA
		LDR	R1,[R0] 				 ; R1 stores the data register. We know the output result is "1" if the leds are not pressed. 
		CMP	R1,#0x0F				 ; If there is a change in the input then reflect it to the output else wait for input.
		BEQ Input					 ; if no change, look forward for the input again. if there is change, then go output state.
		BX	LR
		




GPIO_Init

		LDR R1 , =SYSCTL_RCGCGPIO
		LDR R0 , [R1]
		ORR R0 , R0 , #0x02  		; B  port are enabled clock.
		STR R0 , [R1]
		NOP
		NOP
		NOP							;let GPIO clock stabilize

		LDR R1 , =GPIO_PORTB_DIR 	;config. of port B starts
		LDR R0 , [R1]
		BIC R0 , #0xFF
		ORR R0 , #IOB
		STR R0 , [R1]               ;b7-b5->input, b4-b0->output... (0x0f).
		
		LDR R1 , =GPIO_PORTB_AFSEL
		LDR R0 , [R1]
		BIC R0 , #0xFF
		STR R0 , [R1]
		
		LDR R1 , =GPIO_PORTB_DEN	; digital enable of the B port
		LDR R0 , [R1]
		ORR R0 , #0xFF
		STR R0 , [R1] 			

		BX	LR
		ENDP
		ALIGN
		END




	