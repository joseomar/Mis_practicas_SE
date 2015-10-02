;******************************************************************************
; Practica 5: variacion de la velocidad de rotacion de LED con el POTE (ADC)
; Este programa muestrea permitirá la variacion de la velocidad de rotacion de los
; LED, por medio de la tension variable en el terminal del potencionmetro conectado
; al PIN RA3.
;MCE Starter KIT Student.
;Autor: José O. Chelotti
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
	Display
    endc
   
    org 0x20			;Pongo el origen aca porque hasta 18h estan los vectores de interrupcion
   
Inicio:
	setf	TRISA		;Pongo todo el puerto A como entrada
	clrf	TRISB		;Pongo todo el puerto B como salida
	movlw	0x0B
	movwf	ADCON1		;VREFs normales (VSS y VDD) y AN3, AN2,AN1, AN0 como analogicos, el resto como digital
	movlw	b'00001101'	
	movwf	ADCON0		;Elijo el canal AN3, y habilito el conversor, si bien no arranco la conversion (bit1-GO = 0)
	movlw	b'00010010'	; Elijo left justified del resultado, 4Tad y Fosc/32
	movwf	ADCON2
	
	movlw     0x80		; cargo el literal 10000000 en binario en el registro W
	movwf     Display	; cargamos lo que esta en W a la variable Display

principal:
	bsf	ADCON0,1	;Doy inicio a la conversion seteando el GO_DONE	
aca:	btfsc	ADCON0,1	;Pulling sobre GO_DONE. Si esta seteado salta
	goto	aca
	movf	ADRESH,w	;Muevo el dato convertido para alterar el delay
	movwf	Delay2
	
	movf      Display,w      ; movemos el dato guardado en Display a W
	movwf     PORTB		  ; y lo llevamos a al puerto B
	
LoopEncendido:
        decfsz    Delay1,f       ; Comienza el retardo, Decremento Delay1 hasta llegar a cero
	goto      LoopEncendido  ; cada loop toma 3 ciclos de maquina * 256 loops= 768 instrucciones
	decfsz    Delay2,f       ; el proximo loop toma 3 ciclos en volver al primer loop, asi 256 veces
	goto      LoopEncendido  ; (768+3) * 256 = 197376 instrucciones / con ciclos de 1uSeg = 0.197 seg
	
	
	bcf	  STATUS,C
	rrcf      Display,f      ; rotamos el registro
	btfsc     STATUS,C       ; el bit rotado entro al carry?
	bsf       Display,7      ; si, pongo a 1 el bit 7 de Display
	goto	  principal
	
    end