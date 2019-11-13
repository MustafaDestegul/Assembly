;LABEL		DIRECTIVE	VALUE		COMMENT
;******PORTB CONFIGURATIONS******
GPIO_PORTB_DATA 	EQU		0x400053FC  ; data a d d r e s s t o a l l pi n s
GPIO_PORTB_DIR 		EQU 	0x40005400
GPIO_PORTB_AFSEL 	EQU 	0x40005420
GPIO_PORTB_PDR 		EQU 	0x40005514  ;Pull down register address
PDB 				EQU 	0xF0 		; o r #2 1 1 1 1 0 0 0 0 ;PDB will be activated dynamically
GPIO_PORTB_DEN 		EQU 	0x4000551C
IOB 				EQU 	0x0F		; B[7:4]= IN,  B[3:0]=OUT


SYSCTL_RCGCGPIO 	EQU 	0x400FE608			
			
;CounterFor5sec		EQU		400000000	; Counter for 5 sec	
CounterFor100ms		EQU		1200000 	; Counter for 100ms  for debouncing problems 	
			
			AREA	main, READONLY, CODE, ALIGN=2
			THUMB
			EXTERN	Counter	; Reference external subroutine
			EXTERN	convrt	; Reference external subroutine	
			EXPORT	__main
			
			;R2 is the pull-up, which changing for each pin for b[3:0]
			;R1 IS THE INPUTS FROM THE PORT B FROM KEYPAD B[7:4]
			;R4 IS FOR THE CONVRT SUBROUTINE TO SEND THE RELATED KEY TO THE TERMIT
			;
__main		PROC
		BL		GPIO_Init     		; initialize the port B
		ldr		r1,=0x01				; load r1=1 for the writing 1 to the bits for the first time 
		LDR		R2,=0x00 			; To keep the the data which we write to the output.
		BFC		R3,#0,#31			; R3 is the integer value of the keypad 
		
Loop														
		BL	Write1ToOutput			; make the output colums 1 by one by  and read the input
		LSL	R1,#1					; shift left each time  to make the output we want to write as 1. 
		BL	ReadTheInputs			; input is loaded to R1. r1 is 1 for first button, 2 for second ,4  for third,8 for forth
		BL	Comparator				; compare the key pressed and the pull up register activation	
Cont
		BL	convrt					; output the resultant key to the TERMIT.
		B	Loop					; branch to loop again. There is a latency which can miss the key  while convrt sunroutine is working but it is low and ignored 

		
Write1ToOutput						; write 1 to the output colums by one by for the one we want to write. 		
		LDR	R0, = GPIO_PORTB_DATA	; read the data register 
		STRB	R1,[R0]				; Store the r1 to the data register TO R2 
		MOV	R2,R1				; R2 is for the storage of r1 which the value we write to the output port.
		CMP	R1,#0x08				; If r1 is 8 then make it 1 
		MOVEQ	R1,#0x01			; load r1=1
		BX	LR						; go back
		
ReadTheInputs  						; read the data register in port b
		PUSH	{LR}				; Since we came here with LR, we need to save it to the stack.  else it is lost
		BL	Counter					; wait for the button to be high because of Debouncing problems 
		POP	{LR}					; pop the LR
		LDR	R0,=GPIO_PORTB_DATA		; Load the data registers address to the R0
		LDR	R3,[R0] 				; R3 stores the value of data register's current value 
		PUSH	{LR}				;Since we came here with LR, we need to save it to the stack.  else it is lost
		BL	Counter					; wait for the input to be 1ow because of Debouncing problems . 
		POP	{LR}
;		CMP R3, 0xF0	
;		BEQ ReadTheInputs
		BX	LR

  

;For the comparison purposes the value at the left side(data register value)  corresponds the key number at the right side 
;0001 0001=KEY1
;0001 0010=KEY5		      ; NOTE!!!
;0001 0100=KEY9		      ; IF DATA REGISTER HAS THE XXXXXX0 VALUE , THEN NO KEY IS PRESSED THEN WAI FOR THE INPUT
;0001 1000=KEY13

;0010 0001=KEY2
;0010 0010=KEY6
;0010 0100=KEY10
;0010 1000=KEY14

;0100 0001=KEY3
;0100 0010=KEY7
;0100 0100=KEY11
;0100 1000=KEY15

;1000 0001=KEY4
;1000 0010=KEY8
;1000 0100=KEY12
;1000 1000=KEY16


Comparator 							; r3 keeps the last modified value of the data register and r4 is the pressed keys values.
		MOV	R5,R3				; first check any key is pressed or not. if pressed then send to the convrt subroutine ,else dont send the the convrt subroutine and continue to scan 
		AND	R5,#0x000000F0			; mask the outputs and take the inputs 
		ORR R5,#0x00				; orr with 0 to find out key is pressed or not
		CMP	R5,#0					; compare with 0 to learn pressed or not
		BEQ	Loop					; if not pressed go and Loop again for the next scan
	
		CMP	R3,#0x11				; If any key is pressed, the number is loaded to the data register. Read and decide the value which one is presssed.
		MOVEQ R4,#1					; R4 keeps the value of the key pressed 
		BEQ	Cont
		CMP	R3,#0x12
		MOVEQ R4,#5
		BEQ	Cont
		CMP	R3,#0x14
		MOVEQ R4,#9
		BEQ	Cont
		CMP	R3,#0x18
		MOVEQ R4,#13
		BEQ	Cont
		CMP	R3,#0x21
		MOVEQ R4,#2
		BEQ	Cont
		CMP	R3,#0x22
		MOVEQ R4,#6
		BEQ	Cont
		CMP	R3,#0x24
		MOVEQ R4,#10
		BEQ	Cont
		CMP	R3,#0x28
		MOVEQ R4,#14
		BEQ	Cont
		CMP	R3,#0x41
		MOVEQ R4,#3
		BEQ	Cont
		CMP	R3,#0x42
		MOVEQ R4,#7
		BEQ	Cont
		CMP	R3,#0x44
		MOVEQ R4,#11
		BEQ	Cont
		CMP	R3,#0x48
		MOVEQ R4,#15
		BEQ	Cont
		CMP	R3,#0x81
		MOVEQ R4,#4
		BEQ	Cont
		CMP	R3,#0x82
		MOVEQ R4,#8
		BEQ	Cont
		CMP	R3,#0x84
		MOVEQ R4,#12
		BEQ	Cont
		CMP	R3,#0x88
		MOVEQ R4,#16
		BEQ	Cont
	



		


		



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
	
		LDR R0 , =GPIO_PORTB_PDR	; initializatioin of the pull down resistors 
		MOV R1 , #PDB		
		STR R1 , [R0]

		BX	LR

		
		ENDP
		END




	