; LIBRERIA PARA MANEJO DEL LCD LM016L
 
#define LCD_RS PORTD,0
#define LCD_RW PORTD,1
#define LCD_E PORTD,2
    
LCDLinea1 equ 80h	    ; Direccion comienzo linea 1
LCDLinea2 equ 0C0h	    ; Direccion comienzo linea 2
CursorOn equ 0eh	    ; Pantalla On, Cursor On		
CursorOff equ 0ch	    ; Pantalla On, Cursor Off
CursorBlink equ 0fh	    ; Pantalla On, Cursor parpadeo
LCDDec equ 04h		    ; Decrementar cursor
 
LCD_Inicializa:
    clrf PORTB
    clrf PORTD
 
    clrf TRISB
    clrf TRISD
    
   call   Retardo_20ms ;Esperar 20 ms
   movlw  b'00110000' ;Mandar 0x30 -> W
   movwf  PORTB ;Enviar W -> PORTB
 
   call   Retardo_5ms ;Esperar 5ms
   movlw  b'00110000' ;Enviar 0x30 -> W
   movwf  PORTB
 
   call   Retardo_50us ;Acumular 100us
   call   Retardo_50us ;Acumular 100us
   movlw  b'00110000'
   movwf  PORTB
 
   movlw  0x0F
   movwf  PORTB
 
   bsf    LCD_E
   bcf    LCD_E
   return
 
LCD_Caracter:
   bsf    LCD_RS ;Modo Caracter RS = 1
   movwf  PORTB ;Lo que se cargó previamente en W -> PORTB
   bsf    LCD_E ;Activar Enable
   call   Retardo_50us ;Esperar 50us para enviar información
   bcf    LCD_E ;Transición del Enable a 0
   call   Delay ;Esperar a poner la siguiente llamada
   return
 
LCD_Borrar:
   movlw  b'00000001' ;Comando para Borrar
   call   LCD_Comando ;Enviar un comando
   return
 
LCD_Comando:
   bcf    LCD_RS ;Modo Comando RS = 0
   movwf  PORTB ;Envia W -> PORTB
   bsf    LCD_E ;Activa Enable
   call   Retardo_50us ;Espera que se envie la información
   bcf    LCD_E ;Transición del Enable
   return
   
LCD_Decrementar:
    movlw LCDDec
    call LCD_Comando
    return
    
LCD_Decrementarx3:
    movlw LCDDec
    call LCD_Comando
    movlw LCDDec
    call LCD_Comando
    movlw LCDDec
    call LCD_Comando
    return
    
LCD_ApagarCursor:
    movlw CursorOff
    call LCD_Comando
   
Escribir_Presion:
    movlw  'P'
    call   LCD_Caracter
    movlw  'r'
    call   LCD_Caracter
    movlw  'e'
    call   LCD_Caracter
    movlw  's'
    call   LCD_Caracter
    movlw  'i'
    call   LCD_Caracter
    movlw  'o'
    call   LCD_Caracter
    movlw  'n'
    call   LCD_Caracter
    movlw  '('
    call   LCD_Caracter
    movlw  'K'
    call   LCD_Caracter
    movlw  'p'
    call   LCD_Caracter
    movlw  'a'
    call   LCD_Caracter
    movlw  ')'
    call   LCD_Caracter
    movlw  ':'
    call   LCD_Caracter
    return
 









