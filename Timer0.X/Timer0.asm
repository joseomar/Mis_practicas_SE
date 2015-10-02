; *******************************************************************
; Practica 7: Uso del Timer0
;
; Cada vez que desborda el timer(16bits), hago polling sobre el bit de flag
; e incremento un contador y lo muestro por PORTB(LEDs).
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
    Display
 endc
 
 org	0x20

Inicio:
     movlw     b'10000010'	; Configuro Timer0,pre-escaler Ftimer=Fosc/4
     movwf     T0CON		; flanco de subida, timer, 16bits, 
     clrf      TRISB		; Port B como salida
     clrf      Display		; Inicializo display
     
Loop:
     btfss     INTCON,TMR0IF    ; Esperamos aqui hasta que el Timer0 desborde
     goto      Loop
     bcf       INTCON,TMR0IF    ; borramos el flag de desborde
     incf      Display,f	; incrementamos la variable display
     movf      Display,w	; y se lo enviamos a lo leds
     movwf     PORTB
     goto      Loop
     
     end