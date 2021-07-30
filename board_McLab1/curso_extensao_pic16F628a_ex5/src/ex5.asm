;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* UNICESUMAR - MARINGÁ                                                      *
;* CURSO DE EXTENSÃO EM MICROCONTROLADORES PIC                               *
;* PROFESSOR EMERSON MARTINS                                                 *
;*---------------------------------------------------------------------------*
;* EXEMPLO 05 - CONTROLE SIMPLES DE MOTOR DE PASSO                           *
;* DESENVOLVIDO POR ANDERSON COSTA                                           *
;* VERSÃO 1.0                                               DATA: 23/06/2007 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* CONTROLE SIMPLES DE MOTOR DE PASSO COM DUAS VELOCIDADES PARA A DIREITA    *
;* E DUAS VELOCIDADES PARA A ESQUERDA.                                       *
;* RA1 - ESQUERDA RÁPIDO                                                     *
;* RA2 - ESQUERDA LENTO                                                      *
;* RA3 - DIREITA LENTO                                                       *
;* RA4 - DIREITA RÁPIDO                                                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                          ARQUIVOS DE DEFINIÇÕES                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#INCLUDE <P16F628A.INC>        ;ARQUIVO PADRÃO MICROCHIP PARA O PIC16F628A

        __CONFIG _CP_OFF & _LVP_OFF & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

        ERRORLEVEL      -302


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           PAGINAÇÃO DE MEMÓRIA                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* DEFINIÇÃO DE COMANDOS PARA ALTERAÇÃO DA PÁGINA DE MEMÓRIA

#DEFINE BANK0   BCF STATUS,RP0 ;SETA BANCO 0 DE MEMÓRIA
#DEFINE BANK1   BSF STATUS,RP0 ;SETA BANCO 1 DE MEMÓRIA


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                                 VARIÁVEIS                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* ENDEREÇO PARA DECLARAR OS REGISTRADORES UTILIZADOS PELO PROGRAMADOR

        CBLOCK  0X20           ;ENDEREÇO INICIAL DE MEMÓRIA
                TEMPO_3
                TEMPO_2
                TEMPO_1
                W_TEMP         ;REGISTRADORES TEMPORÁRIOS
                STATUS_TEMP
        ENDC                   ;FIM DO BLOCO DE MEMÓRIA


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                                CONSTANTES                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* DEFINIÇÃO DE TODAS AS CONSTANTES UTILIZADAS PELO PROGRAMADOR


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                                  ENTRADAS                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO ENTRADA
;* SEGUE ABAIXO DE CADA DEFINIÇÃO O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

#DEFINE BOTAO_DIR_RAPIDO PORTA,4 ;BOTÃO DIREITA RÁPIDO
#DEFINE BOTAO_DIR_LENTO  PORTA,3 ;BOTÃO DIREITA LENTO
#DEFINE BOTAO_ESQ_LENTO  PORTA,2 ;BOTÃO ESQUERDA LENTO
#DEFINE BOTAO_ESQ_RAPIDO PORTA,1 ;BOTÃO ESQUERDA RÁPIDO


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                                   SAÍDAS                                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO SAÍDA
;* SEGUE ABAIXO DE CADA DEFINIÇÃO O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

#DEFINE BOBINA1          PORTB,0 ;PORTA DA BOBINA 1
#DEFINE BOBINA2          PORTB,1 ;PORTA DA BOBINA 2
#DEFINE BOBINA3          PORTB,2 ;PORTA DA BOBINA 3
#DEFINE BOBINA4          PORTB,3 ;PORTA DA BOBINA 4

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                              VETOR DE RESET                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

        ORG     0X00           ;ENDEREÇO INICIAL DE PROCESSAMENTO
        GOTO    INICIO         ;VAI PARA A ROTINA INICIO


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           INÍCIO DA INTERRUPÇÃO                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

        ORG     0X04           ;ENDEREÇO INICIAL DA INTERRUPÇÃO
        RETFIE                 ;RETORNA DA INTERRUPÇÃO


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                            INICIO DO PROGRAMA                             *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

INICIO

        BANK1                  ;SELECIONA O BANCO 1 PARA TRIS E OPTION_REG
        MOVLW   B'00011110'    ;MOVE LITERAL BINÁRIO PARA WORK
        MOVWF   TRISA          ;DEFINIÇÃO DE ENTRADA E SAÍDA DO PORTA
                               ;SETA RA1, RA2, RA3, RA4 COMO ENTRADA

        MOVLW   B'00000000'    ;MOVE LITERAL BINÁRIO PARA WORK
        MOVWF   TRISB          ;DEFINIÇÃO DE ENTRADA E SAÍDA DO PORTB
                               ;SETA O PORTB COMO SAÍDA

        MOVLW   B'10000000'
        MOVWF   OPTION_REG     ;PULL_UPS DESABILITADOS <7>

        MOVLW   B'00000000'
        MOVWF   INTCON         ;TODAS AS INTERRUPÇÕES DESLIGADAS
        BANK0                  ;RETORNA PARA O BANCO 0

        MOVLW   B'00011110'
        MOVWF   CMCON          ;CONFIGURA RA4:RA1 COMO I/O <2:0>


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        INICIALIZAÇÃO DAS VARIÁVEIS                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

        CLRF    PORTA          ;LIMPA PORT A
        CLRF    PORTB          ;LIMPA PORT B


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                             ROTINA PRINCIPAL                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

MAIN
        CLRF    PORTB                    ;LIMPA O PORTB, PORTA DAS BOBINAS DO MOTOR

;TESTA SE OS BOTÕES FORAM PRESSIONADOS
BOTAO_DIR_LENTO_PRES
        BTFSS   BOTAO_DIR_LENTO          ;SE BOTAO_DIR_LENTO ESTIVER PRESSIONADO
                                         ;PULA UMA LINHA
        GOTO    BOTAO_DIR_RAPIDO_PRES    ;SE NÃO, VÁ PARA A ROTINA
                                         ;BOTAO_DIR_RAPIDO_PRES
        GOTO    MOTOR_DIR_LENTO          ;VÁ PARA A ROTINA MOTOR_DIR_LENTO

BOTAO_DIR_RAPIDO_PRES
        BTFSS   BOTAO_DIR_RAPIDO         ;SE BOTAO_DIR_RAPIDO ESTIVER PRESSIONADO
                                         ;PULA UMA LINHA
        GOTO    BOTAO_ESQ_LENTO_PRES     ;SE NÃO, VÁ PARA A ROTINA
                                         ;BOTAO_ESQ_LENTO_PRESS
        GOTO    MOTOR_DIR_RAPIDO         ;VÁ PARA A ROTINA MOTOR_DIR_RAPIDO

BOTAO_ESQ_LENTO_PRES
        BTFSC   BOTAO_ESQ_LENTO          ;SE BOTAO_ESQ_LENTO ESTIVER PRESSIONADO
                                         ;PULA UMA LINHA
        GOTO    BOTAO_ESQ_RAPIDO_PRES    ;SE NÃO, VÁ PARA A ROTINA
                                         ;BOTAO_ESQ_RAPIDO_PRES
        GOTO    MOTOR_ESQ_LENTO          ;VÁ PARA A ROTINA MOTOR_ESQ_LENTO

BOTAO_ESQ_RAPIDO_PRES
        BTFSC   BOTAO_ESQ_RAPIDO         ;SE BOTAO_ESQ_RAPIDO ESTIVER PRESSIONADO
                                         ;PULA UMA LINHA
        GOTO    MAIN                     ;SE NÃO, VÁ PARA ROTINA MAIN
        GOTO    MOTOR_ESQ_RAPIDO         ;VÁ PARA A ROTINA MOTOR_ESQ_RAPIDO

; TESTA SE OS BOTÕES FORAM LIBERADOS
BOTAO_DIR_LENTO_LIB
        BTFSS   BOTAO_DIR_LENTO          ;SE BOTAO_DIR_LENTO ESTIVER PRESSIONADO
                                         ;RETORNA PARA A ROTINA QUE A CHAMOU
        GOTO    MAIN                     ;SE NÃO, RETORNA PARA A ROTINA DE INICIO
        RETURN

BOTAO_DIR_RAPIDO_LIB
        BTFSS   BOTAO_DIR_RAPIDO         ;SE BOTAO_DIR_RAPIDO ESTIVER PRESSIONADO
                                         ;RETORNA PARA A ROTINA QUE A CHAMOU
        GOTO    MAIN                     ;SE NÃO, RETORNA PARA A ROTINA DE INICIO
        RETURN

BOTAO_ESQ_LENTO_LIB
        BTFSS   BOTAO_ESQ_LENTO          ;SE BOTAO_ESQ_LENTO ESTIVER PRESSIONADO
                                         ;RETORNA PARA A ROTINA QUE A CHAMOU
        GOTO    MAIN                     ;SE NÃO, RETORNA PARA A ROTINA DE INICIO
        RETURN

BOTAO_ESQ_RAPIDO_LIB
        BTFSS   BOTAO_ESQ_RAPIDO         ;SE BOTAO_ESQ_RAPIDO ESTIVER PRESSIONADO
                                         ;RETORNA PARA A ROTINA QUE A CHAMOU
        GOTO    MAIN                     ;SE NÃO, RETORNA PARA A ROTINA DE INICIO
        RETURN


MOTOR_DIR_LENTO
        BSF     BOBINA1                  ;LIGA A BOBINA 1 DO MOTOR
        CALL    BOTAO_DIR_LENTO_LIB      ;CHAMA A ROTINA DO BOTÃO
        CALL    DELAY_LENTO              ;CHAMA A ROTINA DE ATRASO
        CALL    BOTAO_DIR_LENTO_LIB      ;CHAMA A ROTINA DO BOTÃO
        BCF     BOBINA1                  ;DESLIGA A BOBINA 1 DO MOTOR
        CALL    BOTAO_DIR_LENTO_LIB      ;CHAMA A ROTINA DO BOTÃO

        BSF     BOBINA2                  ;LIGA A BOBINA 2 DO MOTOR
        CALL    BOTAO_DIR_LENTO_LIB      ;CHAMA A ROTINA DO BOTÃO
        CALL    DELAY_LENTO              ;CHAMA A ROTINA DE ATRASO
        CALL    BOTAO_DIR_LENTO_LIB      ;CHAMA A ROTINA DO BOTÃO
        BCF     BOBINA2                  ;DESLIGA A BOBINA 2
        CALL    BOTAO_DIR_LENTO_LIB      ;CHAMA A ROTINA DO BOTÃO

        BSF     BOBINA3                  ;LIGA A BOBINA 3 DO MOTOR
        CALL    BOTAO_DIR_LENTO_LIB      ;CHAMA A ROTINA DO BOTÃO
        CALL    DELAY_LENTO              ;CHAMA A ROTINA DE ATRASO
        CALL    BOTAO_DIR_LENTO_LIB      ;CHAMA A ROTINA DO BOTÃO
        BCF     BOBINA3                  ;DESLIGA A BOBINA 3 DO MOTOR
        CALL    BOTAO_DIR_LENTO_LIB      ;CHAMA A ROTINA DO BOTÃO

        BSF     BOBINA4                  ;LIGA A BOBINA 4 DO MOTOR
        CALL    BOTAO_DIR_LENTO_LIB      ;CHAMA A ROTINA DO BOTÃO
        CALL    DELAY_LENTO              ;CHAMA A ROTINA DE ATRASO
        CALL    BOTAO_DIR_LENTO_LIB      ;CHAMA A ROTINA DO BOTÃO
        BCF     BOBINA4                  ;DESLIGA A BOBINA 3 DO MOTOR
        CALL    BOTAO_DIR_LENTO_LIB      ;CHAMA A ROTINA DO BOTÃO

        GOTO    MOTOR_DIR_LENTO          ;VAI PARA A ROTINA DO MOTOR

MOTOR_DIR_RAPIDO
        BSF     BOBINA1                  ;LIGA A BOBINA 1 DO MOTOR
        CALL    BOTAO_DIR_RAPIDO_LIB     ;CHAMA A ROTINA DO BOTÃO
        CALL    DELAY_RAPIDO             ;CHAMA A ROTINA DE ATRASO
        CALL    BOTAO_DIR_RAPIDO_LIB     ;CHAMA A ROTINA DO BOTÃO
        BCF     BOBINA1                  ;DESLIGA A BOBINA 1 DO MOTOR
        CALL    BOTAO_DIR_RAPIDO_LIB     ;CHAMA A ROTINA DO BOTÃO

        BSF     BOBINA2                  ;LIGA A BOBINA 2 DO MOTOR
        CALL    BOTAO_DIR_RAPIDO_LIB     ;CHAMA A ROTINA DO BOTÃO
        CALL    DELAY_RAPIDO             ;CHAMA A ROTINA DE ATRASO
        CALL    BOTAO_DIR_RAPIDO_LIB     ;CHAMA A ROTINA DO BOTÃO
        BCF     BOBINA2                  ;DESLIGA A BOBINA 2 DO MOTOR
        CALL    BOTAO_DIR_RAPIDO_LIB     ;CHAMA A ROTINA DO BOTÃO

        BSF     BOBINA3                  ;LIGA A BOBINA 3 DO MOTOR
        CALL    BOTAO_DIR_RAPIDO_LIB     ;CHAMA A ROTINA DO BOTÃO
        CALL    DELAY_RAPIDO             ;CHAMA A ROTINA DE ATRASO
        CALL    BOTAO_DIR_RAPIDO_LIB     ;CHAMA A ROTINA DO BOTÃO
        BCF     BOBINA3                  ;DESLIGA A BOBINA 3 DO MOTOR
        CALL    BOTAO_DIR_RAPIDO_LIB     ;CHAMA A ROTINA DO BOTÃO

        BSF     BOBINA4                  ;LIGA A BOBINA 4 DO MOTOR
        CALL    BOTAO_DIR_RAPIDO_LIB     ;CHAMA A ROTINA DO BOTÃO
        CALL    DELAY_RAPIDO
        CALL    BOTAO_DIR_RAPIDO_LIB     ;CHAMA A ROTINA DO BOTÃO
        BCF     BOBINA4                  ;DESLIGA A BOBINA 4 DO MOTOR
        CALL    BOTAO_DIR_RAPIDO_LIB     ;CHAMA A ROTINA DO BOTÃO

        GOTO    MOTOR_DIR_RAPIDO         ;VAI PARA A ROTINA DO MOTOR

MOTOR_ESQ_LENTO
        BSF     BOBINA4                  ;LIGA A BOBINA 4 DO MOTOR
        CALL    BOTAO_ESQ_LENTO_LIB      ;CHAMA A ROTINA DO BOTÃO
        CALL    DELAY_LENTO              ;CHAMA A ROTINA DE ATRASO
        CALL    BOTAO_ESQ_LENTO_LIB      ;CHAMA A ROTINA DO BOTÃO
        BCF     BOBINA4                  ;DESLIGA A BOBINA 2 DO MOTOR
        CALL    BOTAO_ESQ_LENTO_LIB      ;CHAMA A ROTINA DO BOTÃO

        BSF     BOBINA3                  ;LIGA A BOBINA 3 DO MOTOR
        CALL    BOTAO_ESQ_LENTO_LIB      ;CHAMA A ROTINA DO BOTÃO
        CALL    DELAY_LENTO              ;CHAMA A ROTINA DE ATRASO
        CALL    BOTAO_ESQ_LENTO_LIB      ;CHAMA A ROTINA DO BOTÃO
        BCF     BOBINA3                  ;DESLIGA A BOBINA 3 DO MOTOR
        CALL    BOTAO_ESQ_LENTO_LIB      ;CHAMA A ROTINA DO BOTÃO

        BSF     BOBINA2                  ;LIGA A BOBINA 2 DO MOTOR
        CALL    BOTAO_ESQ_LENTO_LIB      ;CHAMA A ROTINA DO BOTÃO
        CALL    DELAY_LENTO              ;CHAMA A ROTINA DE ATRASO
        CALL    BOTAO_ESQ_LENTO_LIB      ;CHAMA A ROTINA DO BOTÃO
        BCF     BOBINA2                  ;DESLIGA A BOBINA 2 DO MOTOR
        CALL    BOTAO_ESQ_LENTO_LIB      ;CHAMA A ROTINA DO BOTÃO

        BSF     BOBINA1                  ;LIGA A BOBINA 1 DO MOTOR
        CALL    BOTAO_ESQ_LENTO_LIB      ;CHAMA A ROTINA DO BOTÃO
        CALL    DELAY_LENTO              ;CHAMA A ROTINA DE ATRASO
        CALL    BOTAO_ESQ_LENTO_LIB      ;CHAMA A ROTINA DO BOTÃO
        BCF     BOBINA1                  ;DESLIGA A BOBINA 1 DO MOTOR
        CALL    BOTAO_ESQ_LENTO_LIB      ;CHAMA A ROTINA DO BOTÃO

        GOTO    MOTOR_ESQ_LENTO

MOTOR_ESQ_RAPIDO
        BSF     BOBINA4                  ;LIGA A BOBINA 4 DO MOTOR
        CALL    BOTAO_ESQ_RAPIDO_LIB     ;CHAMA A ROTINA DO BOTÃO
        CALL    DELAY_RAPIDO             ;CHAMA A ROTINA DE ATRASO
        CALL    BOTAO_ESQ_RAPIDO_LIB     ;CHAMA A ROTINA DO BOTÃO
        BCF     BOBINA4                  ;DESLIGA A BOBINA 4 DO MOTOR
        CALL    BOTAO_ESQ_RAPIDO_LIB     ;CHAMA A ROTINA DO BOTÃO

        BSF     BOBINA3                  ;LIGA A BOBINA 3 DO MOTOR
        CALL    BOTAO_ESQ_RAPIDO_LIB     ;CHAMA A ROTINA DO BOTÃO
        CALL    DELAY_RAPIDO             ;CHAMA A ROTINA DE ATRASO
        CALL    BOTAO_ESQ_RAPIDO_LIB     ;CHAMA A ROTINA DO BOTÃO
        BCF     BOBINA3                  ;DESLIGA A BOBINA 3 DO MOTOR
        CALL    BOTAO_ESQ_RAPIDO_LIB     ;CHAMA A ROTINA DO BOTÃO

        BSF     BOBINA2                  ;LIGA A BOBINA 2 DO MOTOR
        CALL    BOTAO_ESQ_RAPIDO_LIB     ;CHAMA A ROTINA DO BOTÃO
        CALL    DELAY_RAPIDO             ;CHAMA A ROTINA DE ATRASO
        CALL    BOTAO_ESQ_RAPIDO_LIB     ;CHAMA A ROTINA DO BOTÃO
        BCF     BOBINA2                  ;DESLIGA A BOBINA 2 DO MOTOR
        CALL    BOTAO_ESQ_RAPIDO_LIB     ;CHAMA A ROTINA DO BOTÃO

        BSF     BOBINA1                  ;LIGA A BOBINA 1 DO MOTOR
        CALL    BOTAO_ESQ_RAPIDO_LIB     ;CHAMA A ROTINA DO BOTÃO
        CALL    DELAY_RAPIDO             ;CHAMA A ROTINA DE ATRASO
        CALL    BOTAO_ESQ_RAPIDO_LIB     ;CHAMA A ROTINA DO BOTÃO
        BCF     BOBINA1                  ;DESLIGA A BOBINA 1 DO MOTOR
        CALL    BOTAO_ESQ_RAPIDO_LIB     ;CHAMA A ROTINA DO BOTÃO

        GOTO    MOTOR_ESQ_RAPIDO         ;VAI PARA A ROTINA DO MOTOR


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                          ROTINAS DE TEMPORIZAÇÃO                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;TEMPORIZADOR PARA IR MAIS DEVAGAR
DELAY_LENTO
        MOVLW   .2
        MOVWF   TEMPO_3

DELAY_LENTO_AUX
        NOP
        CALL    DELAY_RAPIDO
        NOP
        DECFSZ  TEMPO_3,1
        GOTO    DELAY_LENTO_AUX
        RETURN

;TEMPORIZADOR PARA IR MAIS RAPIDO
DELAY_RAPIDO
        MOVLW   .7
        MOVWF   TEMPO_2

DELAY_RAPIDO_AUX
        CALL    DELAY
        NOP
        DECFSZ  TEMPO_2,1
        GOTO    DELAY_RAPIDO_AUX
        RETURN

;TEMPORIZADOR PADRÃO
DELAY
        MOVLW   .90
        MOVWF   TEMPO_1

DELAY_AUX
        NOP
        DECFSZ  TEMPO_1,1
        GOTO    DELAY_AUX
        NOP
        RETURN


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                              FIM DO PROGRAMA                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

        END                    ;OBRIGATÓRIO
