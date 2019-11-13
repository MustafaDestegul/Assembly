GPIO_PORTB_DATA 			EQU 0x400053FC ; data address to all pins 
GPIO_PORTB_DIR 				EQU 0x40005400 
GPIO_PORTB_AFSEL			EQU 0x40005420 
GPIO_PORTB_DEN				EQU 0x4000551C 
GPIU_PORTB03				EQU	0x4000503C
GPIU_PORTB47				EQU	0x400053C0
GPIOPORTBPUR				EQU 0x40005510 ;PUR actual address
GPIOPDR						EQU	0x40005514
SYSCTL_RCGCGPIO 			EQU 0x400FE608 

		AREA |.text| , READONLY, CODE, ALIGN=2 
		THUMB 
		EXTERN 			DELAY100
		EXTERN			OutChar
		EXPORT 			__main 

__main	LDR 	R1, =SYSCTL_RCGCGPIO 
		LDR 	R0, [R1] 
		ORR 	R0, R0, #0x12 
		STR 	R0, [R1] 
		NOP 
		NOP
		NOP 						 ; let GPIO clock stabilize 
 
LOOP	LDR 	R1, =GPIO_PORTB_DIR	 ; config . of port B starts
		LDR 	R0, [R1]
		BIC 	R0, #0xFF
		ORR 	R0, #0x0F			; Ports 0-3 output
		STR	 	R0, [R1]
		LDR 	R1, =GPIO_PORTB_AFSEL
		LDR 	R0, [R1]
		BIC 	R0, #0xFF 
		STR 	R0, [R1]
		LDR 	R1, =GPIO_PORTB_DEN 
		LDR 	R0, [R1]
		ORR 	R0, #0xFF
		STR 	R0, [R1]
		LDR		R0,	=GPIOPDR
		MOV		R1, #0xF0				;b4-7 pull down resistor
		STRB 	R1, [R0]				; config . of port B ends 		
bounc	LDR		R1, =GPIU_PORTB03		;L1-4  B0-3
		LDR		R2, =GPIU_PORTB47		;R1-4  B4-7
		BIC		R3, #0xFF
		ORR		R3, #0xF
		STRB	R3, [R1]
		LDRB	R4, [R2]				;R4=Column
		bl		DELAY100
		LDRB	R7,[R2]
		CMP		R7,#0
		BEQ		bounc
		CMP		R4,R7
		BNE		bounc
		LSR		R4,#4
		NOP
		NOP
		LDR 	R1, =GPIO_PORTB_DIR	 ; config . of port B starts
		LDR 	R0, [R1]
		BIC 	R0, #0xFF
		ORR 	R0, #0xF0			; Ports 4-7 output
		STR	 	R0, [R1]
		LDR		R0,	=GPIOPDR
		MOV		R1, #0x0F			;b03 pulDWNRSTR
		STRB 	R1, [R0]			; config . of port B ends 
bounc2	LDR		R1, =GPIU_PORTB03		;L1-4  B0-3
		LDR		R2, =GPIU_PORTB47		;R1-4  B4-7
		BIC		R3, #0xFF
		ORR		R3, #0xF0
		STRB	R3, [R2]
		LDRB	R6, [R1]				;R6=ROW
		bl		DELAY100
		LDRB	R7,	[R1]
		CMP		R6,R7
		BNE		bounc2
		BIC		R7,#0xFF
q		LSRS	R4,#1
		ADD		R7,#1			;r7=column number
		BNE		q
		BIC		R4,#0xFF
p		LSRS	R6,#1
		ADD		R4,#1			;r4=row number
		BNE		p
		SUB		R7,#1
		SUB		R4,#1
		MOV		R6,#4
		MUL		R6,R4
		ADD		R6,R7
		CMP		R6,#9
		BHI		harf
		BIC 	R5, #0xFF
		ADD		R5,R6,#0x30
bounc3	LDR		R1, =GPIU_PORTB03		; bu kisim 0 icin;L1-4  B0-3
		LDR		R2, =GPIU_PORTB47		; bu kisim 0 icin;R1-4  B4-7
		BIC		R3, #0xFF               ; bu kisim 0 icin
		ORR		R3, #0xF0               ; bu kisim 0 icin
		STRB	R3, [R2]                ; bu kisim 0 icin
		LDRB	R6, [R1]				; bu kisim 0 icin
		bl		DELAY100                ; bu kisim 0 icin
		LDRB	R7,	[R1]                ; bu kisim 0 icin
		CMP		R6,R7                   ; bu kisim 0 icin
		BNE		bounc3                  ; bu kisim 0 icin
		CMP		R7,#0					; bu kisim 0 icin;wait for 0 signal
		BNE		bounc3                  ; bu kisim 0 icin
		BL		OutChar
		B		done
harf	BIC 	R5, #0xFF
		ADD		R5,R6,#55
bounc4	LDR		R1, =GPIU_PORTB03		;bu kisim 0 icin	;L1-4  B0-3
		LDR		R2, =GPIU_PORTB47		;bu kisim 0 icin	;R1-4  B4-7
		BIC		R3, #0xFF                ;bu kisim 0 icin
		ORR		R3, #0xF0                ;bu kisim 0 icin
		STRB	R3, [R2]                 ;bu kisim 0 icin
		LDRB	R6, [R1]				 ;bu kisim 0 icin
		bl		DELAY100                 ;bu kisim 0 icin
		LDRB	R7,	[R1]                 ;bu kisim 0 icin
		CMP		R6,R7                    ;bu kisim 0 icin
		BNE		bounc4                   ;bu kisim 0 icin
		CMP		R7,#0					;bu kisim 0 icin	;wait for 0 signal
		BNE		bounc4                   ;bu kisim 0 icin
		BL		OutChar
done	NOP
		B		LOOP			;infinite loop for continuous operation
		ALIGN
		END