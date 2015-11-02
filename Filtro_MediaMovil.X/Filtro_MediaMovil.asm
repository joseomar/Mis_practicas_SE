;******************************************************************************
;Practica 11: Filtro de media movil
;
;Crearemos un filtro de media movil utilizando direccionamiento indirecto. Se    
;deberá crear un buffer de 8 posiciones, y mostrar el promedio en los LEDs. 
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
  
    cblock  0x20
	Display:1		; Variable que guarda el estado de los LEDs
	Delay:2			; Registro de 2 bytes para retardo
	Buffer:8		; Buffer de 8 bytes para almacenar los 8 resultados
	SumaTotal:2		; Suma de los ultimos 8 valores
	Rotar:2			; Registro auxiliar para dividir por 8 realizando una rotación.
	temp:1			; Almacena temporalmente el resultado de la conversión
    endc
    
    org 0x20
    
Inicio:
	setf	TRISA		; Selecciono el puerto A como entrada
	clrf	TRISB		; Selecciono el puerto B como salida
	movlw	b'00001011'
	movwf	ADCON1		; VREFs normales (VSS y VDD) y AN3, AN2,AN1, AN0 como analogicos, el resto como digital
	movlw	b'00001101'	
	movwf	ADCON0		; Elijo el canal AN3, y habilito el conversor, si bien no arranco la conversion (bit1-GO = 0)
	movlw	b'00010010'	
	movwf	ADCON2		; Elijo left justified del resultado, 4Tad y Fosc/32
	call	Ini_Filtro	; Inicializo el filtro

Principal:
	call	Retardo_200ms
	bsf       ADCON0,GO_DONE ; Comienza conversion
poll:	btfss     ADCON0,GO_DONE ; Termino conversion?
	goto      poll

	movf      ADRESH,w       ; Leemos resultado
	call      Filtro         ; Y lo enviamos a la funcion filtro
	movwf     Display        ; cargamos la media calculada por el filtro
	movwf     PORTB          ; lo enviamos al diplay
	goto      Principal


Ini_Filtro:
	movlw	Buffer
	movwf	FSR0		; Cargo en FSR (puntero) la primera direccion del registro buffer
	clrf	SumaTotal	; Limpio el primer byte (byte bajo) de clrf SumaTotal
	clrf	SumaTotal+1	; Limpio el segundo byte (byte alto) de clrf SumaTotal
	clrf	Buffer		; Limpio los 8 bytes del buffer
	clrf	Buffer+1
	clrf	Buffer+2
	clrf	Buffer+3
	clrf	Buffer+4
	clrf	Buffer+5
	clrf	Buffer+6
	clrf	Buffer+7
	return
	
Filtro:
	movwf	temp		; Salva el nuevo valor convertido en la variable temp
	movf	INDF0,w		; Salva en w el valor a ser descartado
	subwf   SumaTotal,f	; Hace SumaTotal-w, es decir restamos el valor a descartar
	btfss   STATUS,C        ; Se produjo un borrow? (C=0)
	decf    SumaTotal+1,f   ; si, restamos en una unidad parte alta
	
	movf    temp,w
	movwf   INDF0           ; cargo la entrada en la tabla
	addwf   SumaTotal,f     ; y lo sumo a la variable SumaTotal
	btfsc   STATUS,C	; Se produjo un carry? (C=1)
	incf    SumaTotal+1,f	; Si, incrementamos el byte alto
	
	incf      FSR0,f	; Avanzo el puntero
	movf      FSR0,w	; Lo vuelco en w
	xorlw     Buffer+8        ; es el ultimo registro?
	movlw     Buffer          ; cargamos W con direccion inicial
	btfsc     STATUS,Z
	movwf     FSR0            ; si, cargamos el puntero con la direccion inicial
	
	;Dividimos por 8: Rotamos 3 veces
	bcf       STATUS,C       ; borro el carry
	rrcf      SumaTotal+1,w
	movwf     Rotar+1
	rrcf      SumaTotal,w   ; divido por 2 y cargo el resultado en la variable rotar
	movwf     Rotar
     
	bcf       STATUS,C       ; borro el carry
	rrcf      Rotar+1,f
	rrcf      Rotar,f        ; divido por 4

	bcf       STATUS,C       ; borro el carry
	rrcf      Rotar+1,f
	rrcf      Rotar,f        ; divido por 8
     
	btfsc     STATUS,C       ; si llego el bit al carry, incremento resultado
	incf      Rotar,f          
	movf      Rotar,w        ; cargamos el resultado en W
	return  
	
Retardo_200ms:
ret1:	decfsz    Delay,f        ; delay 
	goto      ret1
	decfsz    Delay+1,f      ; delay 768uS porque con "+1" se refiere al byte alto
	goto      ret1
	return

    end