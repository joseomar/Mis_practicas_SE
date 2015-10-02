;******************************************************************************
;Practica 9: Interrupciones Timer y ADC
;
;Este programa muestrea la entrada analogica en el pin de RA3 a través de la 
;variacion de voltage en los terminales de un potenciometro. La salida se 
;mostrará en los LED's. Con el Timer0 definiremos la frecuencia de muestreo de 
;la señal analogica. y dispararemos la conversion utilizando la interrpcion del 
;ADC para que nos avise cuando termino de convertir. Deberemos asignar prioridades
;ya que el ADC tiene que interrumpir dentro de la ISR del timer0.
;
;Plataforma: MCE Starter KIT Student.
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
  
    cblock
	Delay
    endc
  
    
    org 0x00			;Pongo el origen aca porque hasta 18h estan los vectores de interrupcion
	goto Inicio
    org 0x08			;Direccion de alta prioridad
	goto ISRADC
    org 0x18
	goto ISRtimer		;Direccion de baja prioridad

Inicio:
	setf	TRISA		; Pongo todo el puerto A como entrada (PIN analogico)
	clrf	TRISB		; Pongo todo el puerto B como salida (LEDs)
	movlw	b'00001011'
	movwf	ADCON1		; VREFs normales (VSS y VDD) y AN3, AN2,AN1, AN0 como analogicos, el resto como digital
	movlw	b'00001101'	
	movwf	ADCON0		; Elijo el canal AN3, y habilito el conversor, si bien no arranco la conversion (bit1-GO = 0)
	movlw	b'00010010'	
	movwf	ADCON2		; Elijo left justified del resultado, 4Tad y Fosc/32
	bsf	RCON,IPEN	; Habilito los niveles de interrupcion de prioridades
	movlw	b'11100000'
	movwf	INTCON		; Habilito todas las interrupciones generales, la de los perisfericos y la del timer0
	bsf	PIE1,ADIE	; Habilito la interrupcion del ADC
	bsf	IPR1,ADIP	; Le doy prioridad alta a la interrupcion del ADC
	bcf	INTCON2,TMR0IP	; Le doy prioridad baja em TMR0
	movlw	h'00'
	movwf	TMR0H
	movlw	h'00'
	movwf	TMR0L
	movlw   b'10000011'	; Configuro Timer0,pre-escaler Ftimer=Fosc/4
	movwf   T0CON		; flanco de subida, timer, 16bits, 
	movlw	d'50'		; Delay dentro de la interrupcion del timer, solo
	movwf	Delay		; a fines de ver el tema de prioridades.
	
principal:
	nop
	goto	principal

ISRtimer:
	bcf	INTCON,TMR0IF	; Limpio el flag de interrupcion del Timer0 para evitar llamadas recursivas
	bsf	ADCON0,1	; Doy inicio a la conversion seteando el GO_DONE
	movlw	h'00'
	movwf	TMR0H
	movlw	h'00'
	movwf	TMR0L
Retardo:
	decfsz    Delay,f       ; Comienza el retardo, Decremento Delay1 hasta llegar a cero
	goto      Retardo       ; Cada loop toma 3 ciclos de maquina * 256 loops= 768 instrucciones
	retfie

ISRADC:
	bcf	PIR1,ADIF	;Limpio el flag de interrupcion del ADC para evitar llamadas recursivas
	movf	ADRESH,0	; Muevo el ADRESH al registro w
	movwf	PORTB		; Muevo el resgistro w a los LEDs (puerto RB)
	retfie
	
    end