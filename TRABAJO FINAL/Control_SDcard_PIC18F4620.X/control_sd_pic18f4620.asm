#include "p18f4620.inc"
    
    errorlevel  -302 

    ; Configuraciones
    CONFIG OSC = XT
    CONFIG BOREN = ON
    CONFIG WDT = OFF

SCK equ 3			    ; TRISC
SDI equ 4			    ; SDI es controlado automaticamente por el módulo SPI
SDO equ 5			    ; TRISC
SS_ equ 5			    ; TRISA

    
    org 0x00
    
Inicio:
    clrf TRISC
    clrf TRISA
    clrf SSPCON1		    ; Borra registro SSPCON1
    clrf SSPSTAT		    ; Borra registro SSPSTAT
    movlw b'11000000'
    movwf SSPSTAT		    ; SPI modo maestro - Bit CKE=0
    movlw b'00100000'		    ; Setear SPI en modo maestro
    movwf SSPCON1		    ; Habilita puerto serie. Configura SDI, SDO SCK y SS  como pines del puerto serie
    
    ; Los pines de conexion se deben comportar como funcion del puerto serie
    ; SDI es controlado automaticamente por SPI
    
    bcf TRISC,SDO		    ; SDO como salida
    bcf TRISC,SCK		    ; En modo maestro se pone en 0
    bsf TRISA,SS_		    ; SS_ se pone en 1
    
    
Inicializar_mmc:
    call CMD0			    ; Comando de reset
    call CMD1			    ; Comando de inicializacion
    call CMD16			    ; Comando de configuracion del bloque de 512 bytes
    
SD_a_SPI:			    ; Al iniciar, la memoria lo hace en modo SD. Por eso se debe poner en modo SPI
    call CMD0
    bsf PORTA,SS_

    
    goto Termina
  
; RESET DE SD    
CMD0:		    
    movlw 0x40
    movwf SSPBUF
    call Delay
    movlw 0x00
    movwf SSPBUF
    call Delay
    movlw 0x00
    movwf SSPBUF
    call Delay
    movlw 0x00
    movwf SSPBUF
    call Delay
    movlw 0x00
    movwf SSPBUF
    call Delay
    movlw 0x95
    movwf SSPBUF
    call Delay
    return

; INICIALIZACION DE SD    
CMD1:
    movlw 0x41
    movwf SSPBUF
    call Delay
    movlw 0x00
    movwf SSPBUF
    call Delay
    movlw 0x00
    movwf SSPBUF
    call Delay
    movlw 0x00
    movwf SSPBUF
    call Delay
    movlw 0x00
    movwf SSPBUF
    call Delay
    movlw 0xFF
    movwf SSPBUF
    call Delay
    return

; CONFIGURACION DEL BLOQUE DE 512 Bytes    
CMD16:
    movlw 0x50
    movwf SSPBUF
    call Delay
    movlw 0x00
    movwf SSPBUF
    call Delay
    movlw 0x00
    movwf SSPBUF
    call Delay
    movlw 0x00
    movwf SSPBUF
    call Delay
    movlw 0x00
    movwf SSPBUF
    call Delay
    movlw 0xFF
    movwf SSPBUF
    call Delay
    return

; LECTURA DE UN BLOQUE DE 512 Bytes    
CMD17:
    movlw 0x51
    movwf SSPBUF
    call Delay
    movlw 0x00
    movwf SSPBUF
    call Delay
    movlw 0x00
    movwf SSPBUF
    call Delay
    movlw 0x02
    movwf SSPBUF
    call Delay
    movlw 0x00
    movwf SSPBUF
    call Delay
    movlw 0xFF
    movwf SSPBUF
    call Delay
    return
 
; ESCRITURA DE UN BLOQUE DE 512 Bytes    
CMD24:
    movlw 0x58
    movwf SSPBUF
    call Delay
    movlw 0x00
    movwf SSPBUF
    call Delay
    movlw 0x00
    movwf SSPBUF
    call Delay
    movlw 0x02
    movwf SSPBUF
    call Delay
    movlw 0x00
    movwf SSPBUF
    call Delay
    movlw 0xFF
    movwf SSPBUF
    call Delay
    return
    
; RESPUESTAS DE LOS COMANDOS
CMD0_RESPUESTA:
    movlw 0xff
    movwf SSPBUF
    call Delay
    movlw 0x01
    subwf SSPBUF,0
    btfss STATUS,DC
    goto CMD0_RESPUESTA
    movlw 0xff
    movwf SSPBUF
    call Delay
    
Termina:   
    bcf TRISA,5
    goto Termina
    
    #include <RETARDOS.inc>
    
    end


