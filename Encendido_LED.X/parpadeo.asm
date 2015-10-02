;******************************************************************************
;Practica 1 - Encendido de un Led
;Este programa enciende un led conectado al puerto B del micro en el placa 
;MCE Starter KIT Student.
;Codigo desarrolloado por mcelectronics 
;******************************************************************************
                                        
    ;list p=18f4620
    #include	<p18f4620.inc>		;Incluimos el archivo que contiene los registros del 
							;micro que utilizaremos

;Palabra de configuracion
;	__CONFIG    _CONFIG1, _LVP_OFF & _FCMEN_OFF & _IESO_OFF & _BOR_OFF & _CPD_OFF & _CP_OFF & _MCLRE_OFF & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT
;	__CONFIG    _CONFIG2, _WRT_OFF & _BOR21V

     org 0				 	;Instruccion al compilador, esta indica que el codigo precedente
							;a esta instruccion se situara en la direccion indicada, en este
							;caso la direccion 0 Hexa
Inicio:
     bcf     TRISB,0		;Configuro el pin RB0 como salida
     bsf     PORTB,0		;Enciendo el Led
     goto     $				;Me quedo esperando
     end