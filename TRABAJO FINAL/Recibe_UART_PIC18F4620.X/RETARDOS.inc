


    CBLOCK
	Conta1
	Conta2
	Conta3
    ENDC
;Retardo_20ms *********************
Retardo_20ms
    movlw  .247
    movwf  Conta1
    movlw  .26
    movwf  Conta2
Re_20ms
    decfsz Conta1, F  ;Salta cuando Conta1 llega a 0
    bra    Re_20ms    ;Salta a Repeat para Decrementar Conta1
    decfsz Conta2, F  ;Salta cuando Conta2 llega a 0
    bra    Re_20ms    ;Salta a Repeat
    Return
 
;Retardo_5ms *********************
Retardo_5ms
    movlw  .146
    movwf  Conta1
    movlw  .7
    movwf  Conta2
Re_5ms
    decfsz Conta1, F ;Salta cuando Conta1 llega a 0
    bra    Re_5ms    ;Salta a Repeat para Decrementar Conta1
    decfsz Conta2, F ;Salta cuando Conta2 llega a 0
    bra    Re_5ms    ;Salta a Repeat
    Return
 
;Retardo_200us *********************
Retardo_200us
    movlw  .65
    movwf  Conta1
Re_200us
    decfsz  Conta1, F ;Salta cuando Conta1 llega a 0
    bra     Re_200us  ;Salta a Repeat para Decrementar Conta1
    Return
 
;Retardo_2ms *********************
Retardo_2ms
    movlw  .151
    movwf  Conta1
    movlw  .3
    movwf  Conta2
Re_2ms
    decfsz  Conta1, F ;Salta cuando Conta1 llega a 0
    bra     Re_2ms    ;Salta a Repeat para Decrementar Conta1
    decfsz  Conta2, F ;Salta cuando Conta2 llega a 0
    bra     Re_2ms    ;Salta a Repeat
    Return
 
;Retardo_50us *********************
Retardo_50us
    movlw  .15
    movwf  Conta1
Re_50us
    decfsz Conta1, F ;Salta cuando Conta1 llega a 0
    bra    Re_50us   ;Salta a Repeat para Decrementar Conta1
    Return
 
Delay
    clrf   Conta1
    clrf   Conta2
    movlw  .3
    movwf  Conta3
Re_Delay
    decfsz Conta1, F ;Salta cuando Conta1 llega a 0
    bra    Re_Delay  ;Salta a Repeat para Decrementar Conta1
 
    decfsz Conta2, F ;Salta cuando Conta2 llega a 0
    bra    Re_Delay  ;Salta a Repeat
 
    decfsz Conta3, F
    bra    Re_Delay
 
    Return