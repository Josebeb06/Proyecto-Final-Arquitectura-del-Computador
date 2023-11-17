variableA: 0b0 
Q: 0b10000001 ; Multiplicador
Q_1: 0b0
M: 0b11111101; Multiplicando
count: 0x8
AUX: 0b0; auxiliar de XOR

condicion_if:
  CALL lsb
  MOV ACC, Q_1
  MOV DPTR, ACC
;			 // PROCESO XOR ------**
  MOV ACC, A
  INV ACC ;	hacemos NOT al LSB
  MOV A, ACC ;	Lo movemos a la casilla A
  MOV ACC, [DPTR] ;	accedemos al valor de Q-1
  AND ACC, A ;	hacemos la operación NOT A*B
  MOV A, ACC
  MOV ACC, AUX
  MOV DPTR, ACC ;	 dejamos apuntando el DTPR a AUX
  MOV ACC, A ;	movemos el resultado de la operación en ACC
  MOV [DPTR], ACC ;	Almacenamos la operación en AUX para llamarla después
  CALL lsb
  MOV ACC, Q_1
  MOV DPTR, ACC
  MOV ACC, [DPTR]
  INV ACC ;	Hacer NOT a Q-1
  AND ACC, A ;	hacemos la operación A*NOT B
  MOV A, ACC ;	guardamos la operación en A
  MOV ACC, AUX ;	inicializamos la variable que teníamos con la operación hecha
  MOV DPTR, ACC
  MOV ACC, [DPTR] ;	Accedemos al valor de la operación
  ADD ACC, A ;	Realizamos la operacion A*NOT B + NOT A*B
;		----Terminamos el proceso del XOR------**
JZ arithmetic_shift ; si el XOR suelta 0 es decir, son iguales los bits entra al JZ
CALL lsb
MOV ACC, A
INV ACC ; hacemos el NOT del lsb
MOV A, ACC
MOV ACC, 0b1
ADD ACC, A
MOV A, ACC ; realizamos el complemento a dos de lsb(-lsb)(-Q) 
MOV ACC, Q_1
MOV DPTR, ACC
MOV ACC, [DPTR]
ADD ACC, A
JN caso_10 ;	El caso de abajo es 01 ya que en 10 hace el salto a caso_10	y en caso de ser 00 o 11 realiza el salto previamente a arithmetic_shift
CALL iniciarM
MOV A, ACC
CALL iniciarA
ADD ACC, A ;	se realiza la suma de M y A
MOV [DPTR], ACC ;	se almacena el valor de la suma al DPTR apuntado a A
JMP arithmetic_shift
caso_10:
CALL iniciarM
INV ACC
MOV A, ACC
MOV ACC, 0b1
ADD ACC, A
MOV A, ACC
CALL iniciarA
ADD ACC, A ; realizamos la resta A= A-M
MOV [DPTR], ACC
arithmetic_shift:
CALL lsb
MOV ACC, Q_1
MOV DPTR, ACC
MOV ACC, A
MOV [DPTR], ACC ; guardar el lsb de Q para Q_1
CALL iniciarQ
 RSH ACC, 0b1 ; se desplaza a la derecha un bit y llena el MSB con 0
 MOV [DPTR], ACC ; guardamos el desplazamiento en Q
 CALL iniciarA
 MOV A, ACC ; movemos el valor de Q en A
 MOV ACC, 0b1
 AND ACC, A ; conseguimos el MSB por medio de la operación de máscara bit a bit
 MOV A, ACC
 JZ no_sumarMSBQ
 CALL iniciarQ
 MOV A, ACC
 MOV ACC, 0b10000000
 ADD ACC, A
 MOV [DPTR], ACC
 no_sumarMSBQ:
   CALL iniciarA
    MOV A, ACC ; movemos el valor de A en A
    MOV ACC, 0b10000000
    AND ACC, A ; conseguimos el MSB por medio de la operación de máscara bit a bit
 JZ no_sumarMSBA
 CALL corrimientoA
 CALL iniciarA
 MOV A, ACC
 MOV ACC, 0b10000000
 ADD ACC, A
 MOV [DPTR], ACC
 JMP seguir
  no_sumarMSBA:
  CALL corrimientoA
  seguir:
  MOV ACC, 0b1
  INV ACC
  MOV A, ACC
  MOV ACC, 0b1
  ADD ACC, A
  MOV A, ACC
  MOV ACC, count
  MOV DPTR, ACC
  MOV ACC, [DPTR]
  ADD ACC, A ; hacer N = N -1
  MOV A, ACC
  MOV [DPTR], ACC

     MOV ACC, count
     MOV DPTR, ACC
     MOV ACC, [DPTR]
     INV ACC
     MOV A, ACC
     MOV ACC, 0b1
     ADD ACC, A
     JN condicion_if
     hlt
     
     lsb: 
     CALL iniciarQ
     MOV A, ACC ; movemos el valor de Q en A
     MOV ACC, 0b1
     AND ACC, A ; conseguimos el LSB por medio de la operación de máscara bit a bit
     MOV A, ACC ; guardamos el LSB en A
     RET

    corrimientoA:
   CALL iniciarA
   RSH ACC, 0b1 ; se desplaza a la derecha un bit y llena el MSB con 0
   MOV [DPTR], ACC ; guardamos el desplazamiento en A
   RET
   iniciarA:
   MOV ACC, variableA
   MOV DPTR, ACC
   MOV ACC, [DPTR] ;
   RET
   iniciarM:
   MOV ACC, M
   MOV DPTR, ACC
   MOV ACC, [DPTR]
   RET
   iniciarQ:
    MOV ACC, Q
    MOV DPTR, ACC
    MOV ACC, [DPTR]
    RET