; *******************************************************************
; Practica 3: Rotacion de leds
;
; Como extension de la practica 2, encenderomos los leds de manera
; secuencial, simulando una rotacion en la matriz de leds de la placa
; MCE Starter Kit Student.
;
; Codigo desrrollado por MCElectronics
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
Delay1           ; Definimos las variables comenzando con la direccion 0x20
Delay2
Display          ; Variable que mantiene el resultado de la rotacion
     endc
     
     org 20
Inicio:
     clrf      TRISB          ; ponemos todos los pines del port B como salida
     movlw     0x80			  ; cargo el literal 10000000 en binario en el registro W
     movwf     Display		  ; cargamos lo que esta en W a la variable Display
LoopPrincipal:
     movf      Display,w      ; movemos el dato guardado en Display a W
     movwf     PORTB		  ; y lo llevamos a al puerto B
LoopEncendido:
     decfsz    Delay1,f       ; Comienza el retardo, Decremento Delay1 hasta llegar a cero
     goto      LoopEncendido  ; cada loop toma 3 ciclos de maquina * 256 loops= 768 instrucciones
     decfsz    Delay2,f       ; el proximo loop toma 3 ciclos en volver al primer loop, asi 256 veces
     goto      LoopEncendido  ; (768+3) * 256 = 197376 instrucciones / con ciclos de 1uSeg = 0.197 seg
                             
     
     bcf       STATUS,C       ; borramos el carry
     rrcf      Display,f      ; rotamos el registro
     btfsc     STATUS,C       ; el bit rotado entro al carry?
     bsf       Display,7      ; si, pongo a 1 el bit 7 de Display
     goto      LoopPrincipal  ; volvemos a empezar
     end