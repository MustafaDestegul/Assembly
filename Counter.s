
Counterfor100ms 	EQU		500000   ; approximately 100msec delay 

;LABEL		DIRECTIVE	VALUE		COMMENT
			AREA    main, READONLY, CODE
			THUMB
		
		
			EXPORT  	__main	; Make available

; R0 IS THE INITIAL VALUE TO THE COUNTER


__main		PROC
			PUSH	{R0}				; R0 CAN BE USED BY THE HIGH LEVEL PROGRAM, SO PUSH IT TO STACK 
			LDR		R0,=Counterfor100ms	;BEFORE THE OPERATIONS ON IT 
Delay   
			SUBS	R0,R0,#1
			BNE		Delay
			POP		{R0}
			BX		LR					; POP FROM THE STACK

			ENDP
			END
				