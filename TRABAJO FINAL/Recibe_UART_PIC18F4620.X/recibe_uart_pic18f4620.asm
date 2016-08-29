#include "p18f4620.inc"

    ; Configuraciones
    CONFIG OSC = XT
    CONFIG BOREN = ON
    CONFIG WDT = OFF
    
    cblock 0x20
	centenas
	decenas
	unidades
    endc
    
    org 0x00
    
    goto Inicio
    
    org 0x08
    
    goto ISR
    
Inicio:
    ; Configuración de interrupcion ISR
    movlw b'11000000'
    movwf INTCON
    movlw b'00100000'
    movwf PIE1

    movlw d'207'		    ; Valor para 1200 baudios con un clock de 4 Mhz (207)
    movwf SPBRG			    ; 
    bcf TXSTA,SYNC
    bsf TXSTA,BRGH
    bcf BAUDCON,BRG16		; bcf	    
    ; Habilito el puerto serie
    bsf RCSTA,SPEN
    ; Habilitar recepcion
    bsf RCSTA,CREN
    
    
    clrf PORTB
    clrf TRISB
    
    call LCD_Inicializa		    ; Inicializa el LCD
    call Escribir_Presion	    ; Escribe la palabra "Presion(Kpa):"

  
    
Principal:
    call bin_to_bcd		    ; Llamada a funcion. (En WREG se encuentra el valor de la conversion)
    movff centenas,WREG		    ; Mueve el valor de la centena a W
    addlw 30h			    ; Suma 30h (segun hoja de datos de LCD para mostrar digito)
    call LCD_Caracter		    ; Muestra el dígito correspondiente a la centena
    movff decenas,WREG		    ; Se repite el proceso (como la visualizacion de la centena)
    addlw 30h
    call LCD_Caracter
    movff unidades,WREG
    addlw 30h
    call LCD_Caracter
 
    ; Se mantiene al final de la palabra 'Presion(Kpa):'
    ; De esta manera solo se actualiza el valor de la presion
    movlw b'10001101'		    ; Bit 7 en 1 para ingresar una direccion. 1101 es la posicion del caracter 14, fila 1
    call LCD_Comando		    ; Ejecuta el comando
    call Delay			    ; Espera tiempo para que LCD lea comando.
    
    goto Principal
    
ISR:
    movff RCREG,WREG
    bcf PIR1,RCIF
    retfie
    
bin_to_bcd:
    clrf decenas
    clrf centenas
    movwf unidades
    
resta10:
    movlw d'10'
    subwf unidades,0
    btfss STATUS,C
    goto fin_bcd
    
inc_decenas:
    movwf unidades
    incf decenas
    movlw d'10'
    subwf decenas,0
    btfss STATUS,C
    goto resta10
    
inc_centenas:
    clrf decenas
    incf centenas
    goto resta10
    
fin_bcd:
    swapf decenas,0
    addwf unidades,0
    return    
    
    #include <LCD8_LIB.inc>
    #include <RETARDOS.inc>
    end


