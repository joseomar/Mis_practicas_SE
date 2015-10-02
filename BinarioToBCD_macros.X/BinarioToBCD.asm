;******************************************************************************
; Practica 7: Un numero binario de 8 bits es convertido a BCD. El resultado se 
; guardara en 3 posiciones de la RAM de datos (centenas, decenas y unidades). 
; Finalmente en resultado de unidades y decenas sera visible en los LEDs conectados
; al puerto B.
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
  
  	cblock 0x20
	    Centenas
	    Decenas
	    Unidades
	    centena
	    decena
	    unidad
	endc
    
Numero EQU d'118'
 
BINaBCD macro Centenas, Decenas, Unidades, w
 
     Bin_a_BCD:
	clrf	Centenas	;Limpio las centenas
	clrf	Decenas		;Limpio las decenas
	movwf	Unidades	;Cargo el valor a convertir en unidades
	
    Resta10:
	movlw	d'10'		;Asigno 10 a w
	subwf	Unidades,0	;Resto 10 a unidades
	btfss	STATUS,C    
	goto	Fin_BIN_BCD
	
    IncrementaDecenas:
	movwf	Unidades
	incf	Decenas
	movlw	d'10'
	subwf	Decenas,0
	btfss	STATUS,C
	goto	Resta10

    IncrementaCentenas:
	clrf	Decenas
	incf	Centenas
	goto	Resta10
	
    Fin_BIN_BCD:
	swapf	Decenas,0
	addwf	Unidades,0
	return
    endm
    
    org 0x20
    
Inicio: 
	clrf	TRISB		;Configuro el puerto B como salida (LEDs)

Principal: 
	movlw	Numero		;Muevo Numero a w
	;call	Bin_a_BCD	;Llamo a la funcion de conversion
	BINaBCD centena, decena, unidad, w
	movwf	PORTB		;Muestro el resultado a traves de los LEDs
	goto	$		;Mequedo aca
	
	
;***********************Subrutina Bin_a_BCD*****************************
	
	end