;
;
;
;
    
#include "p18f4620.inc"

   CONFIG  OSC = XT              ; Oscillator Selection bits (XT oscillator) 
   CONFIG  WDT = OFF             ; Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit)) 
   CONFIG  BOREN = ON            ; Brown-out Reset Enable bits (Brown-out Reset enabled and controlled by software (SBOREN is enabled))
   
   org 0x00
   
inicio:	    
	    bcf	TRISB,0
	    bsf PORTB,0
	    
	    goto $
	    
	    end
	    
	    