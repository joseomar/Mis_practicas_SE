; *******************************************************************************************************
; * MODELO DE PIC: 12F675										*
; * IMPLEMENTACION DEL UNA CONVERSION AD, UTILIZANDO UN SENSOR DE TEMPERATURA MPX4250 (FREESCALE).	*
; * SE REALIZO UNA INTERRUPCION POR POR DESBORDAMIENTO DEL TMR0 (TIMER 0)				*
; * EL RESULTADO DE LA CONVERSION SE MUESTRA EN 3 LEDS (SOLO A MODO ILUSTRATIVO PARA VER QUE FUNCIONA)	*
; *******************************************************************************************************
    
#include "p12f675.inc"
    
    errorlevel -302

    ; Configuración
    __CONFIG _FOSC_INTRCCLK & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _BOREN_ON & _CP_OFF & _CPD_OFF
    
    cblock 0x20
	; La variable suma es de 16 bits (con 8 bits solo puedo almacenar hasta 255 en decimal)
	suma:2			  ; Variable en la que sumo los valores de la conversion para luego calcular la media
	arreglo:8		  ; Vector en el que guardo los valores de cada conversion
	valor			  ; Auxiliar en el que voy guardando el valor actual de la conversion
	division:2
	ndatos			  ; Cantidad de datos
	media			  ; Variable que va a contener la media calculada
	delay1
	delay2
    endc

    org 0x00
    
    goto Inicio
    
    ;org 0x04	
    
    ;goto Interrupcion
    
    
Inicio:
    bsf STATUS,RP0	    ; Selecciono el Banco 1
    clrf TRISIO		    ; Pone a GPIO como salida (para los LEDS)
    bsf GPIO,GPIO0	    ; GP0 como entrada (para sensor de presión)
    
    ; Configuracion ADC
    movlw b'00010001'	    ; <6:4> (Fosc/4) 0: Entrada analogica (del sensor)
    movwf ANSEL
    bcf STATUS,RP0	    ; Selecciono Banco 0
    movlw b'00000001'	    ; (7: Justificado izq em 0) (0: Enable ADC)
    movwf ADCON0
    
    ; Configuracion de la Interrupcion
;    bsf STATUS,RP0	    ; Selecciono Banco 1
;    movlw b'00000001'       ; Configuracion de OPTION_REG
;    movwf OPTION_REG
;    bsf STATUS,RP0
;    movlw b'10100000'
;    movwf INTCON
    
    ; Cargo en FSR la primera direccion del vector "arreglo"
    movlw arreglo
    movwf FSR
    ; Pongo a cero todo el arreglo
    clrf arreglo
    clrf arreglo+1
    clrf arreglo+2
    clrf arreglo+3
    clrf arreglo+4
    clrf arreglo+5
    clrf arreglo+6
    clrf arreglo+7
    ; Pongo a cero la variable suma
    clrf suma
    clrf suma+1
    
    movlw d'8'
    movwf ndatos
    
    call Retardo
    
    
Principal:
    ; Como el resultado de la conversion esta en W llama a media movil
    bcf STATUS,RP0		; Selecciona Banco 0
    call Retardo
    call Retardo
    
    bsf ADCON0,GO		; ***
    btfss ADCON0,GO		; Verifica si la conversion termino ***
    goto $-1			; La conversion no termino  ***
    bsf STATUS,RP0		; Selecciona Banco 1	****
    movf ADRESH,w		
    call Media_Movil		
    	
    call Inicializa_UART
    ;movf ADRESH,w
    ;movfw media			; ***
    movfw media	
    call Transmite_UART		; ***

    
    decfsz ndatos,1
    goto Principal
    clrf suma
    clrf suma+1
    movlw d'8'
    movwf ndatos
    goto Principal
    
    
;Interrupcion:
;    bcf STATUS,RP0	    ; Selecciono Banco 0
;    bsf ADCON0,GO	    ; Inicio a la conversion
;    bsf STATUS,RP0	    ; Selecciono Banco 1
;    movf ADRESH,w
;    bcf INTCON,T0IF	    ; Limpia la bandera
;    retfie
    
    
Media_Movil:
    ;movwf valor
    ;movf INDF,w		    
    ;subwf suma,f	    ; Resto a suma el nuevo valor (para no comprobar en principal si tengo que borrar suma)
    ;btfss STATUS,C
    ;decf suma+1,f
    
    ;movf valor,w	    ; Valor a W
    movwf INDF		    ; INDF apunta a valor
    addwf suma,f	    ; El valor leido lo suma a la variable suma
    btfsc STATUS,C	    ; Verifica si el carry está en cero (si esta en 1 se debe pasar a suma:1)
    incf suma+1,f	    ; El carry no es cero
    incf FSR,f
    movf FSR,0		    ; A W
    xorlw arreglo+8	    ; Modifica el Z del registro STATUS. Así podemos saber si estamos en la ultima posicion
    movlw arreglo	    ; Carga Wreg con la posicion inicial del arreglo
    btfsc STATUS,Z
    movwf FSR
    
    ; Ahora se hace la division. Se divide por 2, tres veces.
    ; Primera division por 2
    bcf STATUS,C	    ; Borra el carry
    rrf suma+1,0
    movwf division+1
    rrf suma
    movwf division
    
    ; Segunda division por 2
    bcf STATUS,C	    ; Borra el carry
    rrf division+1,1
    rrf division,1
    
    ; Tercera division por 2
    bcf STATUS,C	    ; Borra el carry
    rrf division+1,1
    rrf division,1
    
    ; Esta es una decision de implementacion de dejar o no el carry. 
    ; Lo hago parte del resultado.
    btfsc STATUS,C	    ; Verifica si el carry es cero
    incf division,f	    ; Si el carry es uno se suma al resultado
    movf division,w	    ; Mueve el resultado de la division a Wreg
    
    return
    
    
Retardo:
    decfsz delay1
    goto Retardo
    decfsz delay2
    goto Retardo
    return
    

    #include <UART_RS232.inc>
    
    end




