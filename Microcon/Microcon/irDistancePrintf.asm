; file target ATmega128L-4MHz-STK300
; purpose button triggered ADC with semaphore

		;

; === interrupt table ===
.org	0
	jmp	reset
.org 	ADCCaddr
	jmp	ADCCaddr_sra
	
.org	0x30

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions
.include "uart.asm"	
.include "printf.asm"
	
; === interrupt service routines
ADCCaddr_sra:
		
	in	b0,ADCL				; read low byte first
	in	b1,ADCH				; store 2 MSB
	out PORTC, b1			;
	PRINTF	UART0_putc		; print formatted
	.db	CR,CR,"CACA=",FHEX2,b,"=",FDEC2,b,"    ",0	
	reti					
; === initialization (reset) ====
reset:
	LDSP	RAMEND			; set up stack pointer (SP)
	OUTI	DDRB,0xff		; configure portC to output
	OUTI	DDRC,0xff
	sei
	OUTI	ADCSR,(1<<ADEN)+(1<<ADIE)+6 ; AD Enable, AD int. enable, PS=CK/64	
	OUTI	ADMUX,3			; select channel irdistance
	sbi	ADCSR,ADSC			; start conversion

	rcall	UART0_init		; initialize UART

	rjmp	main			; jump ahead to the main program
	

; === main program ===
main:
	
	sbi	ADCSR,ADSC			; AD start conversion
	WAIT_MS 100				;
	rjmp	main			; jump back to main
