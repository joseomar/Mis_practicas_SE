;******************************************************************************
; Prueba de la libreria del LCD
; MCE Starter KIT Student.
; Autor: José O. Chelotti
;******************************************************************************
    
#include <p18f4620.inc>
    
  ; CONFIG1H
  CONFIG  OSC = XT              ; Oscillator Selection bits (XT oscillator)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor disabled)
  CONFIG  IESO = OFF            ; Internal/External Oscillator Switchover bit (Oscillator Switchover mode disabled)

; CONFIG2L
  CONFIG  PWRT = OFF            ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  BOREN = ON            ; Brown-out Reset Enable bits (Brown-out Reset enabled and controlled by software (SBOREN is enabled))
  CONFIG  BORV = 3              ; Brown Out Reset Voltage bits (Minimum setting)

; CONFIG2H
  CONFIG  WDT = OFF             ; Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
  CONFIG  WDTPS = 32768         ; Watchdog Timer Postscale Select bits (1:32768)

; CONFIG3H
  CONFIG  CCP2MX = PORTC        ; CCP2 MUX bit (CCP2 input/output is multiplexed with RC1)
  CONFIG  PBADEN = ON           ; PORTB A/D Enable bit (PORTB<4:0> pins are configured as analog input channels on Reset)
  CONFIG  LPT1OSC = OFF         ; Low-Power Timer1 Oscillator Enable bit (Timer1 configured for higher power operation)
  CONFIG  MCLRE = ON            ; MCLR Pin Enable bit (MCLR pin enabled; RE3 input pin disabled)

; CONFIG4L
  CONFIG  STVREN = ON           ; Stack Full/Underflow Reset Enable bit (Stack full/underflow will cause Reset)
  CONFIG  LVP = ON              ; Single-Supply ICSP Enable bit (Single-Supply ICSP enabled)
  CONFIG  XINST = OFF           ; Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode disabled (Legacy mode)) 
 
  
    cblock  0x20
	Delay1
	Delay2
	aux
	Contador
	Hello:5
    endc
  
    org	0x00
    
Inicializacion:
		clrf	Contador
		clrf	Delay1
		clrf	Delay2
		clrf	PORTD
		clrf	PORTE
		clrf	TRISD
		movlw	h'F8'
		andwf	TRISE,f

		movlw	Hello
		movwf	FSR0
		movff	A'H',Hello
		movff	A'E',Hello+1
		movff	A'L',Hello+2
		movff	A'L',Hello+3
		movff	A'O',Hello+4
LongDelay:				;Retardo en total de 197376 uS
		call	ShortDelay
		decfsz	Delay1,f
		goto	LongDelay
FunctionSet:
		bcf	PORTE,1		;RS a 0 (info tomada como comando)
		bcf	PORTE,0		;aca podria ir el seteo de read/write pero en la placa este pin esta a masa
		movlw	h'28'		;Comando para el seteo de funcion (ver tabla comando)
		call	Env_reg
		call	Pulse_e		;Pone E a alto por un tiempo determinado
		call	ShortDelay	;Retardo mientras el LCD esta ocupado
DisplayOn:
		bcf	PORTE,1		;RS a 0 (info tomada como comando)
		bcf	PORTE,0		;aca podria ir el seteo de read/write pero en la placa este pin esta a masa
		movlw	h'0F'		;Display on/off y comando cursor (ver tabla comando)
		call	Env_reg
		call	Pulse_e		;Pone E a alto por un tiempo determinado
		call	ShortDelay	;Retardo mientras el LCD esta ocupado
		
Caract_enter:
		bcf	PORTE,1		;RS a 0 (info tomada como comando)
		bcf	PORTE,0		;aca podria ir el seteo de read/write pero en la placa este pin esta a masa
		movlw	h'07'		;Display on/off y comando cursor (ver tabla comando)
		call	Env_reg
		call	Pulse_e		;Pone E a alto por un tiempo determinado
		call	ShortDelay	;Retardo mientras el LCD esta ocupado
		
ClearDisplay:
		bcf	PORTE,1		;RS a 0 (info tomada como comando)
		bcf	PORTE,0		;aca podria ir el seteo de read/write pero en la placa este pin esta a masa
		movlw	h'01'		;Display on/off y comando cursor (ver tabla comando)
		call	Env_reg
		call	Pulse_e		;Pone E a alto por un tiempo determinado
		call	ShortDelay	;Retardo mientras el LCD esta ocupado
		
		clrf	Contador
Message:    
		movf	Contador,w
		bsf	PORTE,1		;RS a 1 (info tomada como dato)
		bcf	PORTE,0		;aca podria ir el seteo de read/write pero en la placa este pin esta a masa
		movf	INDF0,0		;Mandamos el comando a w
		call	Env_reg
		call	Pulse_e		;Pone E a alto por un tiempo determinado
		call	ShortDelay	;Retardo mientras el LCD esta ocupado
		incf	Contador,w
		xorlw	d'5'
		btfsc	STATUS,Z
		goto	Stop		;Si el contador llego a 5 salta a "Stop"
		incf	Contador,f
		incf	FSR0,f
		goto	Message
Stop:
		goto	Stop
		
;*************************Subrutinas*******************************************	
ShortDelay: 
		decfsz	Delay2,f
		goto	ShortDelay
		retlw	0
		
Pulse_e:
		bsf	PORTE,2		;E a 1 
		nop			;Demora 1 ciclo de reloj
		bcf	PORTE,2		;E a 0 
		retlw	0
Env_reg:
		movwf	aux
		movwf	PORTD
		swapf	aux,w
		movwf	PORTD
		return
		
		end	
		