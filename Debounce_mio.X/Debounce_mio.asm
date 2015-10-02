; *******************************************************************
; Practica 6: Eliminacion de Debounce (codigo propio)
;
; Eliminacion del debounce o efecto rebote del pulsador conectado en RA0.
; Un contador se va incrementando de a pulsos cuando hay un cambio de estado.
; Esto se puede visualizar en los LEDs (PORTB)
;
; Plataforma: MCE Starter KIT Student.
; Autor: Chelotti Jose Omar
;
; *******************************************************************


#include "p18f4620.inc"

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
     
 cblock 0x20
    Ultimo_estado
    Contador_cambio
    Contador_pulsos
    Contador_aux
    Delay
    Constante 
 endc
 
 org	0x20
 
Inicio:
	setf	 TRISA			;Como entrada el puerto A (el PIN RA0 va a ser la entrada)
	clrf	 TRISB			;Como salida el puerto B (LEDs)
	clrf	 Ultimo_estado		;El botón no va a estar apretado al ppio (conectado a masa bit 0)
	clrf	 Contador_cambio	;Inicializo el contador de cambios
	clrf	 Contador_pulsos	;Inicializo el contador de pulsos
	clrf	 Contador_aux
	clrf	 PORTB			;Inicializo el puerto B	
	movlw     0x0F               
	movwf     ADCON1		;Port A pines digitales
	movlw	 d'5'			
	movwf	 Constante		;La confirmacion de estado será después de 5ms
	
Principal:

	movf	    PORTA,0		;Muevo el valor del puerto A a w
	cpfseq	    Ultimo_estado	;Comparo valor de w y ultimo estado
	incf	    Contador_cambio	;Si son distintos comienza el conteo
	call	    Retardo_1ms		
	movf	    Contador_cambio,0	;Muevo el valor de contador a w
	cpfseq	    Constante		;Comparo w y constante(d'5')
	goto	    Principal		;Si son distintos no se ha llegado a estabilizar
	call	    Cambio_estado	;Si son iguales, confirmo el cambio de estado
	goto	    Principal
	
Cambio_estado:	
	movlw	    0x00		;Inicializo el registro w
	clrf	    Contador_cambio	;Limpio el Contador_cambio
	incf	    Contador_pulsos	;Incremeto el Contador_pulsos
	movf	    Contador_pulsos,0	
	btg	    Ultimo_estado,0	;toggle del ultimo bit
	movwf	    PORTB		;Muestro en los LEDs
	return
	
Retardo_1ms:				;(256+77)inst. x 3 ciclos/inst. = 999 ciclos
	movlw	d'77'			;Treloj=1/4Mhz => Tinst = 4*Treloj = 1us
	movwf	Delay			;999 ciclos * Tinst ~= 1ms
loop1:	decfsz	Delay
	goto loop1
loop2:	decfsz	Delay
	goto loop2
	return
	
	end