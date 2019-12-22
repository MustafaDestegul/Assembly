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
					EXTERN	convrt
					EXPORT __main
						
__main	PROC
		BL	INIT
; start sampling routine
		LDR	R5,=0x20000400
		LDR R3, =ADC0_RIS ; interrupt address
		LDR R1, =ADC0_SSFIFO3 ; result address
		LDR R2, =ADC0_PSSI ; sample sequence initiate address
		LDR R6,= ADC0_ISC
; initiate sampling by enabling sequencer 3 in ADC0_PSSI
Smpl	LDR R0, [R2]		
		ORR R0, R0, #0x08 ; set bit 3 for SS3
		STR R0, [R2]
; check for sample complete (bit 3 of ADC0_RIS set)
Cont 	LDR R0, [R3]				; check RIS 
		ANDS R0, R0, #8
		BEQ	Cont
;branch fails if the flag is set so data can be read and flag is cleared
		LDR R0,[R1]			;ADC0_SSFIFO3		; write address
		STR R0,[R5] ;store the data
		MOV R1, #8
		STR R1, [R6] ; clear flag
		LDR	R4,[R5]		; R4 keeps the value 	
		BL	convrt		; to see the value 
		
		B 	Smpl
	
	
	
	
	
	
	
	
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
; Enable alternate functions
		LDR R1, =PORTE_AFSEL
		LDR R0, [R1]
		ORR R0, R0, #0x08 ; set bit 3 to enable alt functions on PE3
		STR R0, [R1]
; PCTL does not have to be configured
; since ADC0 is automatically selected when
; port pin is set to analog.

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