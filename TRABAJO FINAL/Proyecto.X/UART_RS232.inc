; *******************************************************************************************************
; * MODELO DE PIC: 12F675										*
; * IMPLEMENTACI�N DE UNA UART (RS232) POR SOFTWARE (Solo Transmisi�n)					*
; * UTILIZO EL CRISTAL INTERNO DEL uC. EL MISMO ES DE 4 Mhz.						*
; * VELOCIDAD DE TRANSMISI�N: 1200 bps									*
; * PERIODO DE TIEMPO DE TRANSICI�N DE BIT: 1/1200 bps = 833,33 us			                *
; * ALUMNO: Alejandro Debus										*
; *******************************************************************************************************
    
    cblock
	dato			    ; Para guardar el dato a transmitir
	nbits			    ; Numero de bits a transmitir
	num			    ; Carga del TIMER 0
    endc
 
#define UART_TX GPIO,5		    ; Pin 5 como transmisi�n
;#define UART_RX GPIO,2		    ; Pin 2 como recepci�n
#define UART_TX_DIR TRISIO,5	    ; Pin de direcci�n de registro para transmisi�n
;#define UART_RX_DIR TRISIO,2	    ; Pin de direcci�n de registro para recepci�n
    
    
Inicializa_UART:
    ; Configura TMR0
    bsf STATUS,RP0		    ; Selecciono Banco 1
    movlw b'00000001'		    ; Prescaler 1:4
    movwf OPTION_REG
    movlw d'47'			    ; Carga del TMR0
    movwf num
    
    bcf STATUS,RP0		    ; Selecciono Banco 0
    movlw d'8'			    ; Cantidad de bits que se van a transmitir.
    movwf nbits
    bsf UART_TX			    ; En el tiempo ocioso (idle state) queda en estado l�gico 1.
    bsf STATUS,RP0		    ; Selecciono Banco 1
    bcf UART_TX_DIR		    ; Como salida (para la transmisi�n)
    ;bsf UART_RX_DIR		    ; Como entrada (para la recepci�n)
    bcf STATUS,RP0		    ; Selecciono Banco 0 (vuelvo como una buena pr�ctica de programaci�n)
    return
    
    
Transmite_UART:
    ; Primero se transmite el "bit de inicio" que es un 0
    bcf STATUS,RP0		    ; Selecciono Banco 0
    movwf dato			    ; Guardo en "dato" el byte a transmitir
    ; Env�a "bit de inicio"	    ;
    bcf UART_TX			    ; Env�a bit de inicio
    call Temporizador0
Envia_Dato:
    ; Comienza a enviar el "dato" (8 bits)
    rrf dato,1			    ; Rotaci�n a la derecha
    btfsc STATUS,C		    ; Comprueba si el bit de CARRY es cero
    goto Carry_Uno		    ; El bit de Carry NO es cero
    goto Carry_Cero		    ; El bit de Carry ES cero

Carry_Cero:
    bcf UART_TX			    ; Env�a un "0"
    call Temporizador0		    ; Tiempo de transici�n
    goto Verifica_Fin
    
Carry_Uno:
    bsf UART_TX			    ; Env�a un "1"
    call Temporizador0		    ; Tiempo de transici�n
    goto Verifica_Fin
    
Verifica_Fin:
    decfsz nbits,1		    ; Decrementa nbits y verifica si termino. De ser as� env�a el bit de stop
    goto Envia_Dato		    ; No termino. Envia el siguiente bit
    bsf UART_TX			    ; Env�a bit de fin
    call Temporizador0		    ; Tiempo de transicion
    return
    
; T_temp= [ T_ciclomaquina ] * Prescaler * [ (Carga_maxima_registro (8 o 16 bits) - cargaTMR0 ] 
; El TMR0 es de 8 bits. Por tanto, su carga maxima es de 256
; Para T(temp)=833 us que es para transmision a 1200 baudios, la cargaTMR0 es igual a 47 (aprox)
; A este valor lo cargo al inicializar la UART
Temporizador0:
    movfw num			    ; Carga en W el valor de carga del TMR0
    movwf TMR0			    ; Cargo al TMR0 el valor de carga
Bucle:
    btfss INTCON,T0IF		    ; Verifica si ya desbord� el TMR0
    goto Bucle			    ; El TMR0 no desbord�
    bcf INTCON,T0IF		    ; Limpia la bandera de desborde del registro
    return
    