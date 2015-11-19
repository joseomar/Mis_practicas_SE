#include "p18f4620.inc"

    ; Configuraciones
    CONFIG OSC = XT
    CONFIG BOREN = ON
    CONFIG WDT = OFF
    
    cblock 0x20
	delay1
	delay2
    endc
    
    org 0x00
    
    goto Inicio
    
    org 0x08
    
    goto ISR
    
Inicio:
    ; ISR
    movlw b'11000000'
    movwf INTCON
    movlw b'00100000'
    movwf PIE1
    
    ; Inicializar los registros para la velocidad adecuada (1200 baudios)
    ; **** ME FALTA VER EL ERROR DEL PIC12F ASI COMPARO PARA CARGAR ESTE VALOR

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
    
    ;call LCD_Inicializa
  
    
Principal:
;    movff RCREG,WREG
;    addlw 30h
;    call LCD_Caracter
 
    goto Principal
    
ISR:
    movff RCREG,PORTB
;    movff PORTB,WREG
;    addlw 30h
;    call LCD_Caracter
    
    bcf PIR1,RCIF
    
    retfie
    
    #include <LCD8_LIB.inc>
    #include <RETARDOS.inc>
    end


