			AREA	main, READONLY, CODE
			THUMB
			EXPORT	__main

GPIO_PORTB_DATA 	EQU		0x400053FC ; data address to all pins
GPIO_PORTB_DIR 		EQU 	0x40005400
GPIO_PORTB_AFSEL 	EQU 	0x40005420
;GPIO_PORTB_PDR 		EQU 	0x40005514  ;Pull down register address
;PDB 				EQU 	0xF0 		; o r #2 1 1 1 1 0 0 0 0 ;PDB will be activated dynamically
GPIO_PORTB_DEN 		EQU 	0x4000551C
IOB 				EQU 	0x0F		; B[7:4]= IN,  B[3:0]=OUT


SYSCTL_RCGCGPIO 	EQU 	0x400FE608	
; STCTRL CONTROL ADDRESSES

ST_CTRL 			EQU 	0xE000E010
ST_RELOAD 			EQU 	0xE000E014
ST_CURRENT 			EQU 	0xE000E018
SHP_SYSPRI3		    EQU 	0xE000ED20

	
__main		PROC
; In main code check if any button is pressed or not, and systick reload value will arrange the speed and handler will arrange the direction 
			BL	GPIO_Init
			LDR	R6,=8000000 			; 8*10^6  the period for 0.5 sec. this will be loaded at the beginning but later will be change according to the speed up and down buttons
			BL	Systick_Init 			; initialize the Systick timer. Systick timer will arrange the speed of the motor and will change according to the speed up and down buttons 
			LDR	R7,=0					; This register will keep the direction of the current process and will be used in handler mode.
			LDR	R9,=0
Loop		LDR	R0,=GPIO_PORTB_DATA		 
			LDR	R1, [R0]				; Load the portb data register value to the R1
			AND	R2,R1,#0x80				; R2 is the counter clockwise direction button PORT B7 
			AND	R3,R1,#0x40				; R3 is the clockwise button direction button PORT B6	(S3)
			AND	R4,R1,#0x20				; R4 register keeps the information of whether speed up button is pressed or not PORT B5 (S2)
			AND	R5,R1,#0x10				; R5 register keeps the information of whether speed down button is pressed or not PORT B4 (S1)
			AND	R8,R1,#0x0F				; Mask the output port and load the R8 register. will be used in HANDLER MODE to give output.
			
			
			;DEBOUNCING STARTS
		;	BL	Delay50m1				; Wait for 50m sec to prevent the unnecessary binary 0-1 changes
		
			ORR R9,R2,R3				;ORR R2 AND R3.If one of them pressed r9 is loaded with 1
			ORR	R9,R9,R4				;0RR R9 and R4.If one of them pressed r9 is loaded with 1
			ORR	R9,R9,R5				;ORR R9 and R5.If one of them pressed r9 is loaded with 1
			
			CMP	R9,#0xF0					; Compare r9 with 0 to detech if any button is pressed or not
			BEQ	Loop					; if none of them is pressed then Loop again.
			; DEBOUNCING ENDS
			
			CMP	R4,#0					; 00100000 speed up button is pressed or not
			BEQ	SpeedUp					; if speed up is pressed then change the systick RELOAD value to make motor faster or slower
			CMP	R5,#0					; 00010000 speed down button is pressed or not
			BEQ	SpeedDown				; if speed down is pressed then change the systick RELOAD value to make motor faster or slower
			CMP	R2,#0					; ccw direction button is pressed or not
			MOVEQ	R2,#1				; If button is pressed then load r2=1 to indicate that ccw direction is set, and used in the handler part
			BEQ	Loop
			CMP	R3,#0					; cw direction button is pressed or not
			MOVEQ	R3,#1				; If button is pressed then load r3=1 to indicate that cw direction is set, and used in the handler part			
			B	Loop

SpeedUp	
			LSR	R6,#1					; Increase the speed of the motor by dividing  RELOAD value by 2.
			BL	Systick_Init
			B	Loop

SpeedDown
			LSL	R6,#1					; decrease the speed of the motor by multiplying RELOAD value by 2.
			BL	Systick_Init
			B	Loop


		

;*****************************SYSTICK HANDLER***********************************************

SysTick_Handler	PROC
			EXPORT SysTick_Handler    ;No proc since the end point is not stabile.

			; R0 KEEPS  portb data register address 	
			; R1 KEEPS THE DATA IN GPIO_PORTB_DATA
			; r2 is to control CCW direction button is pressed or not 
			; r3 is to control CW direction button is pressed or not 
			; R7 is to learn about the current direction 
			
			CMP	R2,#1					; if Counter clock wise direction button is pressed 
			MOVEQ	R2,#0
			BEQ	CCW						; go CCW label
			CMP	R3,#1					; else if Counter clockwise direction is pressed
			MOVEQ	R3,#0
			BEQ	CW						; go  CW label 
			B	NoneOfDirectionButtonsArePressed		; if none of buttons are pressed then according to R7 ,which shows the current operation ,process will be continued 

		
CW						
			CMP	R8,#0					; If the degree is 0 then load 1000 for CW operation 
			BEQ	CWCont	
			LSR	R8,#1					; if the OUTPUTS value is not 0 after the button is pressed shift right 90 degree
			STRB	R8,[R0]				; then load the shifted value to the portb output ports.
			MOV	R7,#0				; IF the CW operation is done then R7 flag is set to 1 to understand the current process is CW in next operation 
			BX	LR						; EXIT THE HANDLER MODE 
		
CCW				
			CMP	R8,#0					; If the degree is 0 then load 0001 for CW operation 
			BEQ	CCWCont
			LSL	R8,#1					; if the degree is not 0 shift left by 90 degree
			STRB	R8,[R0]				; then load the shifted value to the portb output ports.
			MOV	R7,#1				;IF the CW operation is done then R7 flag is set to 0 to understand the current process is CCW in next operation 
			BX	LR						; EXIT THE HANDLER MODE 

	
			
CWCont
			LDR	R8,=8					; 1000 Value in binary
			STRB R8,[R0]				; load 1000 to PORTB output pins.	
			MOV	R7,#0				; IF the CW operation is done then R7 flag is set to 1 to understand the current process is CW in next operation 
			BX	LR

CCWCont
			LDR	R8,=1					; 0001 Value
			STRB R8,[R0]				; load 0001 to PORTB output pins.
			MOV	R7,#1				;IF the CW operation is done then R7 flag is set to 0 to understand the current process is CCW in next operation 
			BX	LR

NoneOfDirectionButtonsArePressed 		; if the motor turning in the CW direction then LSR otherwise LSL operation will be done
			
			CMP	R7,#0					; if the motor is turning in CW  then continue the operation by shifting right
			BEQ	TurnCW					
			B	TurnCCW					; Load the shifted value to the PORTB DATA register.


TurnCW
			CMP	R8,#0					; If the degree is 0 then load 1000 for CW operation 
			BEQ	TurnCWCont	
			LSR	R8,#1					; if the OUTPUTS value is not 0 after the button is pressed shift right 90 degree
			STRB	R8,[R0]				; then load the shifted value to the portb output ports.
			MOV	R7,#0				; IF the CW operation is done then R7 flag is set to 1 to understand the current process is CW in next operation 
			BX	LR			

TurnCCW	
			CMP	R8,#0					; If the degree is 0 then load 0001 for CW operation 
			BEQ	TurnCCWCont
			LSL	R8,#1					; if the degree is not 0 shift left by 90 degree
			STRB	R8,[R0]				; then load the shifted value to the portb output ports.
			MOV	R7,#1				;IF the CW operation is done then R7 flag is set to 0 to understand the current process is CCW in next operation 
			BX	LR	

TurnCWCont
			LDR	R8,=8			 		; 1000 Value in binary
			STRB R8,[R0]				; load 1000 to PORTB output pins.
			MOV	R7,#0				; IF the CW operation is done then R7 flag is set to 1 to understand the current process is CW in next operation 
			BX	LR



TurnCCWCont
			LDR	R8,=1				; 0001 Value
			STRB R8,[R0]				; load 0001 to PORTB output pins.	
			MOV	R7,#1				;IF the CW operation is done then R7 flag is set to 0 to understand the current process is CCW in next operation 
			BX	LR

			ENDP


;***************************************************************************************************************************

;Delay50m1	
			;PUSH	{R5}
			;LDR	R5,=800000				;	50m sec delay constant
;CONT1		SUBS	R5,#1
			;BNE		CONT1
			;POP	{R5}
			;BX	LR

						
			
			
			
Systick_Init	
			PUSH	{R0,R1}
			LDR R1 , =ST_CTRL
			MOV R0 , #0
			STR R0 , [R1]
; now set the time out period
			LDR R1 , =ST_RELOAD
			MOV R0 ,R6		; R6 is the reload value 
			STR R0 , [R1]
; time out period is set
; now set the current timer value to the time out value
			LDR R1 , =ST_CURRENT
			STR R0 , [R1]
; current timer = time out period
; now set the priority level
			LDR R1 , =SHP_SYSPRI3
			MOV R0 , #0x40000000
			STR R0 , [R1]
; priority is set to 2
; now enable system timer and the related interrupt
			LDR R1 , =ST_CTRL
			MOV R0 , #0x03
			STR R0 , [R1]
			POP	{R0,R1}
			BX LR









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