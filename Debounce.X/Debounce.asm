; *******************************************************************
; Practica 6: Eliminacion de Debounce
;
; Eliminacion del debounce o efecto rebote del pulsador conectado en RA0
;
; MCE Starter KIT Student.
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
     
     
     
    cblock     0x20
    Delay               ; Asignamos una direccion a la etiqueta Delay
    Display             ; Variable que retiene el Displaydefine a variable to hold the diplay
    LastStableState     ; Mantiene el ultimo estado estable del switch(open-1; closed-0)
    Counter				; Contador
    endc
     
     org 0x20
Inicio:
     movlw     0xFF
     movwf     TRISA               ; Port A entrada
     clrf      TRISB               ; Port B salida
     movlw     0x0F               
     movwf     ADCON1               ; Port A pines digitales
     clrf      PORTB               ; Inicializo los leds
     
     clrf      Display
     movlw     0x00
     movwf     LastStableState     ; Asumimos el switch esta sin apretar
     clrf      Counter
     
LoopPrincipal:
     btfss     LastStableState,0
     goto      LookingForUp
     
LookingForDown:
     movlw     0x00                ; asumimos que no esta en bajo
     btfss     PORTA,0             ; Esta el pulsdor en Bajo?
     incf      Counter,w           ; si lo esta, incremento contador
     movwf     Counter             ; el valor del contador sera cero si esta en alto
     goto      EndDebounce
     
LookingForUp:
     movlw     0x00                          
     btfsc     PORTA,0             ; Esta en Alto?
     incf      Counter,w		   ; si lo esta, incremento contador
     movwf     Counter

EndDebounce:
     movf      Counter,w           ; Comparamos si tenemos el contador en 5
     xorlw     5
     btfss     STATUS,Z     
     goto      Delay1mS
     
     comf      LastStableState,f   ; Cambiamos el estado
     clrf      Counter
     btfsc     LastStableState,0   ; se oprimio el pulsador
     goto      Delay1mS            ; no, no hacer nada
     
     incf      Display,f           ; si hubo toque del pulsador
     movf      Display,w           ; enviamos el incremento al display de leds
     movwf     PORTB
     
Delay1mS:
	movlw     d'71'                 ; delay ~1000uS
	movwf     Delay
Ret1:   decfsz    Delay,f             ; este bucle toma 215 ciclos
	goto      Ret1          
Ret2:	decfsz    Delay,f             ; este bucle toma 786 ciclos
	goto      Ret2
	
	goto      LoopPrincipal
     end