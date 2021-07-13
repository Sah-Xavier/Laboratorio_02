        PUBLIC  __iar_program_start
        PUBLIC  __vector_table

        SECTION .text:CODE:REORDER(1)
        
        ;; Keep vector table even if it's not referenced
        REQUIRE __vector_table
        
        THUMB
        
__iar_program_start
        
main    
        MOV R0, #10     ;carrega um valor da multiplicação
        MOV R1, #6      ; carrega o outro valor da multiplicação
        BL Mul16b       ; chama a função que vai multiplicar numeros de 16b
        B  fim
        
        
Mul16b  MOV R2, #0      ; Inicializa R2 com 0, para o caso de um dos valores da multiplicação serem 0
        CMP R0, #0      ; compara se o primeiro valor é 0
        IT EQ
          BXEQ LR
        CMP R1, #0      ; compara se o segundo valor é 0
        IT EQ
          BXEQ LR
        PUSH {LR}       ; armazena o retorno da subrotina
        BL loopdiv      ; chama a subrotina que calcula o loop 
        BL soma         ; chama a subrotina que faz a multiplicação por soma e deslocamento
        POP {LR}        ; resgata o endereço de retorno
        BX LR
        
        
loopdiv MOV R3, R0      ; copia o valor de R0 para usá-lo
        MOV R2, #0      ; inicializa o contador com 0
        PUSH {LR}       ; salva o endereço de retorno da subrotina
        BL div          ; chama a subrotina que divide por 2
        
        MOV R12, R0     ; copia o valor de R0 para usá-lo
        PUSH {R2}       ; salva o contador R2
        MOV R2,#0       ; zera o contador
        BL divshif      ; chama a subrotina que retorna o n do numero dividido por 2^n
       
        POP {R4}        ; resgata o contador da div de 2
        SUB R5,R4,R2    ; subtrai a div2 da div2^n para obter a dif (quantas x2 sobra) 
        ADD R3,R3,R5    ; Resto total, que será o i do for da soma após a multiplicação por 2^n
        POP {LR}        ; resgata o endereço de retorno
        BX LR
        
        
div     CMP R3,#2       ; compara se ainda é possivel dividir por 2 e obter um resultado positivo
        IT LO
          BXLO LR
        SUB R3, R3, #2  ; subtrai 2 (divide por 2)
        ADD R2,R2, #1   ; contador (quociente)
        B div
        
        
divshif CMP R12,#2      ; compara se ainda é possível dividir por 2^n
        IT LO
          BXLO LR
        LSR R12, R12, #1; desloca um bit
        ADD R2,R2, #1   ;contador (quociente)
        B divshif
        
        
soma    MOV R12,R2      ;salva R2 em R12 para manipular o registrador sem perder o quociente de deslocamento
        MOV R2, #0      ;zera o reg que receberá a multiplicação
        LSL R2, R1, R12 ; multiplica R1 por 2^n e salva em R2

loopsom ADD R2,R2,R1    ; multiplica R1 por ele mesmo o numero de vezes indicado pelo resto
        SUB R3,R3,#1
        CMP R3,#0
        IT HI
          BHI loopsom
        BX LR
        
fim     B fim
        
       

        ;; Forward declaration of sections.
        SECTION CSTACK:DATA:NOROOT(3)
        SECTION .intvec:CODE:NOROOT(2)
        
        DATA

__vector_table
        DCD     sfe(CSTACK)
        DCD     __iar_program_start

        DCD     NMI_Handler
        DCD     HardFault_Handler
        DCD     MemManage_Handler
        DCD     BusFault_Handler
        DCD     UsageFault_Handler
        DCD     0
        DCD     0
        DCD     0
        DCD     0
        DCD     SVC_Handler
        DCD     DebugMon_Handler
        DCD     0
        DCD     PendSV_Handler
        DCD     SysTick_Handler

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Default interrupt handlers.
;;

        PUBWEAK NMI_Handler
        PUBWEAK HardFault_Handler
        PUBWEAK MemManage_Handler
        PUBWEAK BusFault_Handler
        PUBWEAK UsageFault_Handler
        PUBWEAK SVC_Handler
        PUBWEAK DebugMon_Handler
        PUBWEAK PendSV_Handler
        PUBWEAK SysTick_Handler

        SECTION .text:CODE:REORDER:NOROOT(1)
        THUMB

NMI_Handler
HardFault_Handler
MemManage_Handler
BusFault_Handler
UsageFault_Handler
SVC_Handler
DebugMon_Handler
PendSV_Handler
SysTick_Handler
Default_Handler
__default_handler
        CALL_GRAPH_ROOT __default_handler, "interrupt"
        NOCALL __default_handler
        B __default_handler

        END
