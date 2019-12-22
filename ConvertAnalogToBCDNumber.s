; ADC Registers
RCGCADC 		EQU 0x400FE638 ; ADC clock register
; ADC0 base address EQU 0x40038000
ADC0_ACTSS	 	EQU	0x40038000 ; Sample sequencer (ADC0 base address)
ADC0_RIS 		EQU	0x40038004 ; Interrupt status
ADC0_IM 		EQU 0x40038008 ; Interrupt select
ADC0_ISC		EQU	0x4003800C ; Interrupt status clear
ADC0_EMUX	    EQU 0x40038014 ; Trigger select
ADC0_PSSI 		EQU 0x40038028 ; Initiate sample
ADC0_SSMUX3 	EQU 0x400380A0 ; Input channel select
ADC0_SSCTL3 	EQU 0x400380A4 ; Sample sequence control
ADC0_SSFIFO3	EQU 0x400380A8 ; Channel 3 results
ADC0_PC 		EQU 0x40038FC4 ; Sample rate

; GPIO Registers
RCGCGPIO	    EQU 0x400FE608 ; GPIO clock register
;PORT E base address EQU 0x40024000
PORTE_DEN 		EQU 0x4002451C ; Digital Enable
PORTE_PCTL 		EQU 0x4002452C ; Alternate function select
PORTE_AFSEL	    EQU 0x40024420 ; Enable Alt functions
PORTE_AMSEL 	EQU 0x40024528 ; Enable analog
	
	
					AREA main , CODE, READONLY 
					THUMB 
					 ; Reference external subroutine
					EXPORT __main
						
__main	PROC
		BL	INIT
		LDR	R5,=0x20000400
; start sampling routine
		;LDR R3, =ADC0_RIS ; interrupt address
		;LDR R4, =ADC0_SSFIFO3 ; result address
		;LDR R2, =ADC0_PSSI 
		;LDR R6,= ADC0_ISC
; initiate sampling by enabling sequencer 3 in ADC0_PSSI
Smpl 	LDR R0,=ADC0_PSSI	;; sample sequence initiate address	
		LDR	R1,[R0]
		ORR R1, R1, #0x08 ; set bit 3 for SS3
		STR R1, [R0]
; check for sample complete (bit 3 of ADC0_RIS set)
Cont 	LDR R0, =ADC0_RIS ; interrupt address				; check RIS 
		LDR	R1,[R0]
		ANDS R1, R1, #8
		BEQ	Cont
;branch fails if the flag is set so data can be read and flag is cleared
		LDR R0,=ADC0_SSFIFO3		;ADC0_SSFIFO3 result address
		LDR	R1,[R0]
		STR R1,[R5] ;store the data
		LDR R2, =0x08
		LDR	R1,=ADC0_ISC	;INTERRUPT STATUS CLEAR
		STR R2, [R1] ; clear flag
		
		
		
		BL	BCD		 ;XYZ is obtained in this subroutine. To be clearer, proceed on one example step by step.
					;X,Y,Z=R4,R5,R6
		
		B 	Smpl
	
	
BCD	
		;3.3/4096=80564*10^-9. 
		;if we multiply the result by 8056 The most significant 3 bits will approximately give the BCD values.
		;Since we need 3 most significant value we divide the result by 10^8, 10^7 and 10^6 respectively and 
		; save the datas as BCD numbers.
	
		LDR	R0,=100000000	;10^8	
		LDR	R1,=80564		;the resolution is 80564*10^-9 
		LDR	R2,=10
		LDR R3,[R5],#4   ;		; READ THE DATA. R3 keeps the data taken from r5
		MUL	R3,R1			; then divide by 10^9  ;4096*80564=329990144
		UDIV	R4,R3,R0	; R4 is the most significant bit of the resultant BCD number ;329990144/1000000000 =3 =X
		MUL	R7,R4,R0		; 3*100000000=300000000	
		SUB	R3,R7			; 329990144-300000000=29990144
		UDIV	R0,R2		; DIVIDE 10^9 by 10= 10^8
		; R4 keeps the most significant bit. R3=29990144 for example 
		
		UDIV	R6,R3,R0	; R6 is the second most significant bit of the resultant BCD number ;29990144/10000000 =2=Y
		MUL	R7,R6,R0		; 2*10000000=20000000	
		SUB	R3,R7			; 29990144-20000000=9990144
		UDIV	R0,R2		; 10^7
	;
		UDIV	R8,R3,R0	; R8 is the third most significant bit of the resultant BCD number ;9990144/1000000 =9 =Z
	; R4,R6 AND R8 keeps the resultant 3 digit bcd numbers
		BX	LR
	
	
INIT	
; Start clocks for features to be used
		LDR R1, =RCGCADC ; Turn on ADC clock
		LDR R0, [R1]
		ORR R0, R0, #0x01 ; set bit 0 to enable ADC0 clock
		STR R0, [R1]
		NOP
		NOP
		NOP ; Let clock stabilize
		LDR R1, =RCGCGPIO ; Turn on GPIO clock
		LDR R0, [R1]
		ORR R0, R0, #0x10 ; set bit 4 to enable port E clock 
		STR R0, [R1]
		NOP
		NOP
		NOP ; Let clock stabilize
; Setup GPIO to make PE3 input for ADC0
; Enable alternate functions
		LDR R1, =PORTE_AFSEL
		LDR R0, [R1]
		ORR R0, R0, #0x08 ; set bit 3 to enable alt functions on PE3
		STR R0, [R1]
; PCTL does not have to be configured
; since ADC0 is automatically selected when
; port pin is set to analog.
; Disable digital on PE3
		LDR R1, =PORTE_DEN
		LDR R0, [R1]
		BIC R0, R0, #0x08 ; clear bit 3 to disable digital on PE3
		STR R0, [R1]
; Enable analog on PE3
		LDR R1, =PORTE_AMSEL
		LDR R0, [R1]
		ORR R0, R0, #0x08 ; set bit 3 to enable analog on PE3
		STR R0, [R1]
; Disable sequencer while ADC setup
		LDR R1, =ADC0_ACTSS
		LDR R0, [R1]
		BIC R0, R0, #0x08 ; clear bit 3 to disable seq 3
		STR R0, [R1]
; Select trigger source
		LDR R1, =ADC0_EMUX
		LDR R0, [R1]
		BIC R0, R0, #0xF000 ; clear bits 15:12 to select SOFTWARE
		STR R0, [R1] ; trigger
; Select input channel
		LDR R1, =ADC0_SSMUX3
		LDR R0, [R1]
		BIC R0, R0, #0x000F ; clear bits 3:0 to select AIN0
		STR R0, [R1]
; Config sample sequence
		LDR R1, =ADC0_SSCTL3
		LDR R0, [R1]
		ORR R0, R0, #0x06 ; set bits 2:1 (IE0, END0)
		STR R0, [R1]
; Set sample rate
		LDR R1, =ADC0_PC
		LDR R0, [R1] 
		ORR R0, R0, #0x01 ; set bits 3:0 to 1 for 125k sps
		STR R0, [R1]
; Done with setup, enable sequencer
		LDR R1, =ADC0_ACTSS
		LDR R0, [R1]
		ORR R0, R0, #0x08 ; set bit 3 to enable seq 3
		STR R0, [R1] ; sampling enabled but not initiated yet
		BX	LR
		

		ENDP
		ALIGN
		END