; *******************************************************************
; Practica 2: Parpadeo
;
; En la primera practica vimos como encender un led, ahora haremos
; una rutina de encendido y apagado del led.
; Para poder ver el parpadeo debemos agregar un retardo a cada 
; encendido y apagado del led.
;
; *******************************************************************


    
    #include	"p18f4620.inc"		;Incluimos el archivo que contiene los registros del 
							;micro que utilizaremos

	;Palabra de configuracion
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
  CONFIG  PBADEN = OFF          ; PORTB A/D Enable bit (PORTB<4:0> pins are configured as analog input channels on Reset)
  CONFIG  LPT1OSC = OFF         ; Low-Power Timer1 Oscillator Enable bit (Timer1 configured for higher power operation)
  CONFIG  MCLRE = ON            ; MCLR Pin Enable bit (MCLR pin enabled; RE3 input pin disabled)

; CONFIG4L
  CONFIG  STVREN = ON           ; Stack Full/Underflow Reset Enable bit (Stack full/underflow will cause Reset)
  CONFIG  LVP = ON              ; Single-Supply ICSP Enable bit (Single-Supply ICSP enabled)
  CONFIG  XINST = OFF           ; Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode disabled (Legacy mode))

; CONFIG5L
  CONFIG  CP0 = OFF             ; Code Protection bit (Block 0 (000800-003FFFh) not code-protected)
  CONFIG  CP1 = OFF             ; Code Protection bit (Block 1 (004000-007FFFh) not code-protected)
  CONFIG  CP2 = OFF             ; Code Protection bit (Block 2 (008000-00BFFFh) not code-protected)
  CONFIG  CP3 = OFF             ; Code Protection bit (Block 3 (00C000-00FFFFh) not code-protected)

; CONFIG5H
  CONFIG  CPB = OFF             ; Boot Block Code Protection bit (Boot block (000000-0007FFh) not code-protected)
  CONFIG  CPD = OFF             ; Data EEPROM Code Protection bit (Data EEPROM not code-protected)

; CONFIG6L
  CONFIG  WRT0 = OFF            ; Write Protection bit (Block 0 (000800-003FFFh) not write-protected)
  CONFIG  WRT1 = OFF            ; Write Protection bit (Block 1 (004000-007FFFh) not write-protected)
  CONFIG  WRT2 = OFF            ; Write Protection bit (Block 2 (008000-00BFFFh) not write-protected)
  CONFIG  WRT3 = OFF            ; Write Protection bit (Block 3 (00C000-00FFFFh) not write-protected)

; CONFIG6H
  CONFIG  WRTC = OFF            ; Configuration Register Write Protection bit (Configuration registers (300000-3000FFh) not write-protected)
  CONFIG  WRTB = OFF            ; Boot Block Write Protection bit (Boot Block (000000-0007FFh) not write-protected)
  CONFIG  WRTD = OFF            ; Data EEPROM Write Protection bit (Data EEPROM not write-protected)

; CONFIG7L
  CONFIG  EBTR0 = OFF           ; Table Read Protection bit (Block 0 (000800-003FFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR1 = OFF           ; Table Read Protection bit (Block 1 (004000-007FFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR2 = OFF           ; Table Read Protection bit (Block 2 (008000-00BFFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR3 = OFF           ; Table Read Protection bit (Block 3 (00C000-00FFFFh) not protected from table reads executed in other blocks)

; CONFIG7H
  CONFIG  EBTRB = OFF           ; Boot Block Table Read Protection bit (Boot Block (000000-0007FFh) not protected from table reads executed in other blocks)




     cblock 0x20
Delay1               ; Definimos 2 registros que usaremos
Delay2               ; en los retardos (los mismo tendran 16bits y estaran consecutivos es decir
     endc	     ; Delay1 ocupar� la posici�n 0x20h y Delay2 la 0x21h)
     
     org 0x00
Inicio:
     bcf       TRISB,0        ; RB0 salida
LoopPrincipal:
     btg       PORTB,0        ; Encendemos o apagamos led conectado a RB0
     call      LoopMantener
     goto      LoopPrincipal   ; y volvemos todo de nuevo...
     
LoopMantener:
     decfsz    Delay1,1       ; Decremento Delay1 hasta llegar a cero
     goto      LoopMantener  ; cada loop toma 3 ciclos de maquina * 256 loops= 768 instrucciones
     decfsz    Delay2,1       ; el proximo loop toma 3 ciclos en volver al primer loop, asi 256 veces
     goto      LoopMantener  ; (768+3) * 256 = 197376 instrucciones / con ciclos de 1uSeg = 0.197 seg
     return
     
     end