; *******************************************************************
; Practica 2: Parpadeo
;
; En la primera practica vimos como encender un led, ahora haremos
; una rutina de encendido y apagado del led.
; Para poder ver el parpadeo debemos agregar un retardo a cada 
; encendido y apagado del led.
;
; *******************************************************************

    list p=18f4620			;seleccionamos el micro a usar
    include	"p18f4620.inc"		;Incluimos la libreria
IMPAR   equ 0x09			;asignamos a impar la direccion 0x09	
	    ORG	    0x00		;comenzamos en la posicion 0x00
	    MOVLW   b'00000001'		;movemos el valor 00000001 a W
	    MOVWF   IMPAR		;movemos el valor de W a IMPAR
	    MOVLW   b'00000010'		;movemos el valor 00000010 a W
BUCLE:	    ADDWF   IMPAR,1		;hacemos IMPAR+W y lo metemos en IMPAR
	    NOP				;no hacemos nada
	    GOTO    BUCLE		;volvemos a BUCLE 
	    END				;fin del programa