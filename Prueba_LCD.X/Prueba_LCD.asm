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
  
  	cblock 0x20
	    Delay1
	    Delay2
	endc
    
Numero EQU d'18'
 
; ************** Comandos Constantes de Software *********************
LCDLinea1   	EQU h'80'	    ; Dir de comienzo linea 1
LCDLinea2   	EQU h'C0'	    ; Dir de comienzo linea 2
LCDCLR	      	EQU h'01'	    ; Borra pantalla cursos home
LCDCasa		EQU h'02'	    ; Cursor home, DDRAM sin cambios
LCDInc	    	EQU h'06'	    ; Modo incremento del cursor despues de cada caracter
LCDDec	    	EQU h'04'	    ; Modo decremento del cursor idem
LCDOn	    	EQU h'0C'	    ; Pantalla On
LCDOff	    	EQU h'08'	    ; Pantalla Off
CursOn	    	EQU h'0E'	    ; Pantalla On, Cursor On
CursOff	    	EQU h'0C'	    ; Pantalla On, Cursor Off
CursBlink   	EQU h'0F'	    ; Pantalla On, Cursor Parpadeo
LCDIzda	    	EQU h'18'	    ; Pantalla desplazada a la Izquierda
LCDDecha    	EQU h'1C'	    ; Pantalla desplazada a la Derecha
CursIzda    	EQU h'10C'	    ; Cursor a la izquierda
CursDecha   	EQU h'14C'	    ; Cursor a la derecha
LCDFuncion  	EQU h'38C'	    ; Inicializacion registro de Funcion (verificar DL)
LCDCGRAM	EQU h'40C'	    ; Dir origen CGRAM	    
 
;********************************************************************************
	
    org 0x20
    
Inicio: 
	clrf	TRISB		;Configuro el puerto B como salida (LEDs)
	movlw	  d'7'
	movwf	  Delay2

Principal: 
	call	LCD_Port
	call	LCD_Init
	call	LCD_Port
	movlw	Numero		;Muevo Numero a w
	call	LCD_Caracter
	goto	$		;Mequedo aca
		
;***********************Subrutina del LCD*****************************
	
;Description
;       This subroutine provides calls for LCD operation including:
;       - Port Configuration    
;       - Register mode commands
;       - LCD Busy check
;       - LCD Enable toggle

;Variables
;       None

;Requirements
;       Two free levels of processor stack are required for nested calls.
;       The LCD_Init subroutine requires a minimum 5ms delay to initialize
;       the LCD. Delays longer than 5ms are acceptable. LCD_Init calls a
;       subroutine by the name of Delay_5ms which must be included in your
;       calling program. If your calling program contains a delay loop of
;       longer than 5ms, you can use that delay by adding a Delay_5ms
;       label before the routine.

;Use
;       To initialize the LCD display after power-up:
;       1. Call LCD_Port to initialize Port E and Port D for the LCD display
;       2. Call LCD_Init to initialize the LCD controller
;       To write a command or character to the LCD display:
;       1. Call LCD_Port to initialize Port E and Port D for the LCD display
;       2. Move an LCD command or ASCII character into W
;       3. Call LCD_Reg or LCD_Data to send the command or
;          character to the LCD.

; ************** Conexion Hardware para LCD **************************
;LCDModo	    EQU	PORTE,0	    ; Seleccion de registro LCD
;LCDRW	    	EQU 	PORTE,1	    ; Lectura / Escritura LCD
;LCDE	    		EQU	PORTE,2	    ; Habilita LCD
	 
LCD_Port:
		; Inicializa los buffers triestado puerto D como salidas 
		; para líneas de datos LCD. Establece puerto de A como salida 
		; digital y establece el registro de seleccion del LCD, 
		; Read / Write y Habilitar.
		MOVLW			b'11111000'  ;Coloca los 3 bits bajos de RE a
		ANDWF			TRISE       	;salida digital en TRISE
		CLRF    		TRISD       ;Coloca el Puerto D como salida
		;BCF     		LCDE         ;Hahilita el LCD
		BCF			PORTE,2
		RETURN                  	;
    
LCD_Init:
		; Inicializacion del LCD segun el manual de datos OPTEX
		; Configura las funciones de LCD para pantalla DMC16207
		; Produce reset por software, borra mamoria y 
		; enciende pantalla
		MOVLW		LCDFuncion  	; Carga W con codigo inicializacion (38h)
		CALL		LCD_Comando	; y lo envia al LCD
		CALL		Pausa_5ms   	; ...espera
		MOVLW		LCDFuncion  	; Carga W con codigo inicializacion (38h)
		CALL		LCD_Comando	; y lo envia al LCD
		CALL		Pausa_5ms   	; ...espera
		MOVLW		LCDFuncion  	; Carga W con codigo inicializacion (38h)
		CALL		LCD_Comando	; y lo envia al LCD
		CALL		Pausa_5ms   	; ...espera
		; Cambie la constanter de la siguiente linea para activar
		; la pantalla ej. LCDOn, CursOn, CursBlink. La constante es 
		; de los comandos de software de la LCD
		MOVLW		LCDOn	    	; Comando LCD On y Cursor Off
		CALL		LCD_Comando	; y lo envia al LCD
		MOVLW		LCDCLR	    	; Carga W con codigo borrar LCD
		CALL		LCD_Comando	; y lo envia al LCD
		MOVLW		LCDInc	    	; Carga W con codigo modo Inc
		CALL		LCD_Comando	; y lo envia al LCD
		RETURN
		
LCD_Comando:
		; Carga W con una constante software LCD de la tabla 
		; de igualdades. LCD_Comando saca el comando a la LCD
		; y activa la linea de habilitacion E con LCD_Habilita 
		; para completar el comando.
		;BCF		LCDModo		; Entra en modo registro
		BCF 		PORTE,0
		MOVWF		PORTD	    	; Envia W a la puesta D
		CALL		LCD_Chequea	; Chequea la bandera de ocupado del LCD
		GOTO		LCD_Habilita	; Envia el comando
	
LCD_Caracter:
		; Carga W con el codigo del caracter ASCII para enviarlo
		; al LCD. LCD_Caracter saca el caracter al LCD y 
		; activa la linea de Habilitacion (Enable) con
		; LCD_Habilita para completar el envio
		;BCF		LCDModo		; Entra en modo registro
		BCF 		PORTE,0		
		MOVWF		PORTD	    	; Envia W al puerto D
		CALL		LCD_Chequea	; Chequea la bandera de ocupado
		;BSF		LCDModo		; Entra en modo ASCII
		BSF 		PORTE,0		
		GOTO		LCD_Habilita	; Envia el caracter ASCII

LCD_Chequea:
		; Comprueba el estado de la bandera ocupado y espera que cualquier
		; comando anterior termine, antes de volver a la rutina de llamada.
		;BSF    		LCDRW			;Coloca el LCD en modo lectura
		BSF			PORTE,1
		MOVLW			0xFF			;Coloca el Port D como entrada 
		MOVWF			TRISD			;Desabilita el triestado
		;BSF     		LCDE				;Habilita el LCD
		BSF			PORTE,2
		NOP                     			;Espera un ciclo
		
Loop:	        
		BTFSC			PORTD,7         ;chequea el bit de ocupado del LCD
		GOTO			Loop			;espera el alto. (Busy=1)
		;BCF     		LCDE				;desabilita el  LCD
		BCF			PORTE,2
		CLRF    		TRISD			;Coloca el Puerto D como salida
		;BCF     		LCDRW			;Vuleve el LCD al modo escritura
		BCF			PORTE,1		
		
		RETURN                  		
	
LCD_Habilita:	
		; Envia un pulso de habilitacion de 500ns a la LCD para 
		; completar la operacion de escribir un registro o un caracter.
		; La instruccion NOP es necesaria para procesadores de 
		; veloc sup a 8MHz. P Proc de mas de 16 añadir otro NOP.
		;BSF			LCDE	    		; Pone a 1 la linea Enable
		BSF			PORTE,2
		NOP		    					; Pausa 250 ns
		;BCF			LCDE	    		; pone a 0 la linea enable
		BCF			PORTE,2
		return

Pausa_5ms:	      
		decfsz    Delay1,1	  ; Decremento Delay1 hasta llegar a cero
		goto      Pausa_5ms	  ; cada loop toma 3 ciclos de maquina * 256 loops= 768 instrucciones
		decfsz    Delay2,1	  ; el proximo loop toma 3 ciclos en volver al primer loop, asi 256 veces
		goto      Pausa_5ms	  ; (768+3) * 256 = 197376 instrucciones / con ciclos de 1uSeg = 0.197 seg
		movlw	  d'7'
		movwf	  Delay2
		return

	
	end