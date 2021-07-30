;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* UNICESUMAR - MARING�                                                      *
;* CURSO DE EXTENS�O EM MICROCONTROLADORES PIC                               *
;* PROFESSOR EMERSON MARTINS                                                 *
;*---------------------------------------------------------------------------*
;* EXEMPLO 05 - CONTROLE SIMPLES DE MOTOR DE PASSO                           *
;* DESENVOLVIDO POR ANDERSON COSTA                                           *
;* VERS�O 1.0                                               DATA: 23/06/2007 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* CONTROLE SIMPLES DE MOTOR DE PASSO COM DUAS VELOCIDADES PARA A DIREITA    *
;* E DUAS VELOCIDADES PARA A ESQUERDA.                                       *
;* RA1 - ESQUERDA R�PIDO                                                     *
;* RA2 - ESQUERDA LENTO                                                      *
;* RA3 - DIREITA LENTO                                                       *
;* RA4 - DIREITA R�PIDO                                                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                          ARQUIVOS DE DEFINI��ES                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#INCLUDE <P16F628A.INC>        ;ARQUIVO PADR�O MICROCHIP PARA O PIC16F628A

        __CONFIG _CP_OFF & _LVP_OFF & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

        ERRORLEVEL      -302


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           PAGINA��O DE MEM�RIA                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* DEFINI��O DE COMANDOS PARA ALTERA��O DA P�GINA DE MEM�RIA

#DEFINE BANK0   BCF STATUS,RP0 ;SETA BANCO 0 DE MEM�RIA
#DEFINE BANK1   BSF STATUS,RP0 ;SETA BANCO 1 DE MEM�RIA


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                                 VARI�VEIS                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* ENDERE�O PARA DECLARAR OS REGISTRADORES UTILIZADOS PELO PROGRAMADOR

        CBLOCK  0X20           ;ENDERE�O INICIAL DE MEM�RIA
                TEMPO_3
                TEMPO_2
                TEMPO_1
                W_TEMP         ;REGISTRADORES TEMPOR�RIOS
                STATUS_TEMP
        ENDC                   ;FIM DO BLOCO DE MEM�RIA


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                                CONSTANTES                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* DEFINI��O DE TODAS AS CONSTANTES UTILIZADAS PELO PROGRAMADOR


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                                  ENTRADAS                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO ENTRADA
;* SEGUE ABAIXO DE CADA DEFINI��O O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

#DEFINE BOTAO_DIR_RAPIDO PORTA,4 ;BOT�O DIREITA R�PIDO
#DEFINE BOTAO_DIR_LENTO  PORTA,3 ;BOT�O DIREITA LENTO
#DEFINE BOTAO_ESQ_LENTO  PORTA,2 ;BOT�O ESQUERDA LENTO
#DEFINE BOTAO_ESQ_RAPIDO PORTA,1 ;BOT�O ESQUERDA R�PIDO


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                                   SA�DAS                                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO SA�DA
;* SEGUE ABAIXO DE CADA DEFINI��O O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

#DEFINE BOBINA1          PORTB,0 ;PORTA DA BOBINA 1
#DEFINE BOBINA2          PORTB,1 ;PORTA DA BOBINA 2
#DEFINE BOBINA3          PORTB,2 ;PORTA DA BOBINA 3
#DEFINE BOBINA4          PORTB,3 ;PORTA DA BOBINA 4

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                              VETOR DE RESET                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

        ORG     0X00           ;ENDERE�O INICIAL DE PROCESSAMENTO
        GOTO    INICIO         ;VAI PARA A ROTINA INICIO


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           IN�CIO DA INTERRUP��O                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

        ORG     0X04           ;ENDERE�O INICIAL DA INTERRUP��O
        RETFIE                 ;RETORNA DA INTERRUP��O


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                            INICIO DO PROGRAMA                             *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

INICIO

        BANK1                  ;SELECIONA O BANCO 1 PARA TRIS E OPTION_REG
        MOVLW   B'00011110'    ;MOVE LITERAL BIN�RIO PARA WORK
        MOVWF   TRISA          ;DEFINI��O DE ENTRADA E SA�DA DO PORTA
                               ;SETA RA1, RA2, RA3, RA4 COMO ENTRADA

        MOVLW   B'00000000'    ;MOVE LITERAL BIN�RIO PARA WORK
        MOVWF   TRISB          ;DEFINI��O DE ENTRADA E SA�DA DO PORTB
                               ;SETA O PORTB COMO SA�DA

        MOVLW   B'10000000'
        MOVWF   OPTION_REG     ;PULL_UPS DESABILITADOS <7>

        MOVLW   B'00000000'
        MOVWF   INTCON         ;TODAS AS INTERRUP��ES DESLIGADAS
        BANK0                  ;RETORNA PARA O BANCO 0

        MOVLW   B'00011110'
        MOVWF   CMCON          ;CONFIGURA RA4:RA1 COMO I/O <2:0>


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        INICIALIZA��O DAS VARI�VEIS                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

        CLRF    PORTA          ;LIMPA PORT A
        CLRF    PORTB          ;LIMPA PORT B


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                             ROTINA PRINCIPAL                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

MAIN
        CLRF    PORTB                    ;LIMPA O PORTB, PORTA DAS BOBINAS DO MOTOR

;TESTA SE OS BOT�ES FORAM PRESSIONADOS
BOTAO_DIR_LENTO_PRES
        BTFSS   BOTAO_DIR_LENTO          ;SE BOTAO_DIR_LENTO ESTIVER PRESSIONADO
                                         ;PULA UMA LINHA
        GOTO    BOTAO_DIR_RAPIDO_PRES    ;SE N�O, V� PARA A ROTINA
                                         ;BOTAO_DIR_RAPIDO_PRES
        GOTO    MOTOR_DIR_LENTO          ;V� PARA A ROTINA MOTOR_DIR_LENTO

BOTAO_DIR_RAPIDO_PRES
        BTFSS   BOTAO_DIR_RAPIDO         ;SE BOTAO_DIR_RAPIDO ESTIVER PRESSIONADO
                                         ;PULA UMA LINHA
        GOTO    BOTAO_ESQ_LENTO_PRES     ;SE N�O, V� PARA A ROTINA
                                         ;BOTAO_ESQ_LENTO_PRESS
        GOTO    MOTOR_DIR_RAPIDO         ;V� PARA A ROTINA MOTOR_DIR_RAPIDO

BOTAO_ESQ_LENTO_PRES
        BTFSC   BOTAO_ESQ_LENTO          ;SE BOTAO_ESQ_LENTO ESTIVER PRESSIONADO
                                         ;PULA UMA LINHA
        GOTO    BOTAO_ESQ_RAPIDO_PRES    ;SE N�O, V� PARA A ROTINA
                                         ;BOTAO_ESQ_RAPIDO_PRES
        GOTO    MOTOR_ESQ_LENTO          ;V� PARA A ROTINA MOTOR_ESQ_LENTO

BOTAO_ESQ_RAPIDO_PRES
        BTFSC   BOTAO_ESQ_RAPIDO         ;SE BOTAO_ESQ_RAPIDO ESTIVER PRESSIONADO
                                         ;PULA UMA LINHA
        GOTO    MAIN                     ;SE N�O, V� PARA ROTINA MAIN
        GOTO    MOTOR_ESQ_RAPIDO         ;V� PARA A ROTINA MOTOR_ESQ_RAPIDO

; TESTA SE OS BOT�ES FORAM LIBERADOS
BOTAO_DIR_LENTO_LIB
        BTFSS   BOTAO_DIR_LENTO          ;SE BOTAO_DIR_LENTO ESTIVER PRESSIONADO
                                         ;RETORNA PARA A ROTINA QUE A CHAMOU
        GOTO    MAIN                     ;SE N�O, RETORNA PARA A ROTINA DE INICIO
        RETURN

BOTAO_DIR_RAPIDO_LIB
        BTFSS   BOTAO_DIR_RAPIDO         ;SE BOTAO_DIR_RAPIDO ESTIVER PRESSIONADO
                                         ;RETORNA PARA A ROTINA QUE A CHAMOU
        GOTO    MAIN                     ;SE N�O, RETORNA PARA A ROTINA DE INICIO
        RETURN

BOTAO_ESQ_LENTO_LIB
        BTFSS   BOTAO_ESQ_LENTO          ;SE BOTAO_ESQ_LENTO ESTIVER PRESSIONADO
                                         ;RETORNA PARA A ROTINA QUE A CHAMOU
        GOTO    MAIN                     ;SE N�O, RETORNA PARA A ROTINA DE INICIO
        RETURN

BOTAO_ESQ_RAPIDO_LIB
        BTFSS   BOTAO_ESQ_RAPIDO         ;SE BOTAO_ESQ_RAPIDO ESTIVER PRESSIONADO
                                         ;RETORNA PARA A ROTINA QUE A CHAMOU
        GOTO    MAIN                     ;SE N�O, RETORNA PARA A ROTINA DE INICIO
        RETURN


MOTOR_DIR_LENTO
        BSF     BOBINA1                  ;LIGA A BOBINA 1 DO MOTOR
        CALL    BOTAO_DIR_LENTO_LIB      ;CHAMA A ROTINA DO BOT�O
        CALL    DELAY_LENTO              ;CHAMA A ROTINA DE ATRASO
        CALL    BOTAO_DIR_LENTO_LIB      ;CHAMA A ROTINA DO BOT�O
        BCF     BOBINA1                  ;DESLIGA A BOBINA 1 DO MOTOR
        CALL    BOTAO_DIR_LENTO_LIB      ;CHAMA A ROTINA DO BOT�O

        BSF     BOBINA2                  ;LIGA A BOBINA 2 DO MOTOR
        CALL    BOTAO_DIR_LENTO_LIB      ;CHAMA A ROTINA DO BOT�O
        CALL    DELAY_LENTO              ;CHAMA A ROTINA DE ATRASO
        CALL    BOTAO_DIR_LENTO_LIB      ;CHAMA A ROTINA DO BOT�O
        BCF     BOBINA2                  ;DESLIGA A BOBINA 2
        CALL    BOTAO_DIR_LENTO_LIB      ;CHAMA A ROTINA DO BOT�O

        BSF     BOBINA3                  ;LIGA A BOBINA 3 DO MOTOR
        CALL    BOTAO_DIR_LENTO_LIB      ;CHAMA A ROTINA DO BOT�O
        CALL    DELAY_LENTO              ;CHAMA A ROTINA DE ATRASO
        CALL    BOTAO_DIR_LENTO_LIB      ;CHAMA A ROTINA DO BOT�O
        BCF     BOBINA3                  ;DESLIGA A BOBINA 3 DO MOTOR
        CALL    BOTAO_DIR_LENTO_LIB      ;CHAMA A ROTINA DO BOT�O

        BSF     BOBINA4                  ;LIGA A BOBINA 4 DO MOTOR
        CALL    BOTAO_DIR_LENTO_LIB      ;CHAMA A ROTINA DO BOT�O
        CALL    DELAY_LENTO              ;CHAMA A ROTINA DE ATRASO
        CALL    BOTAO_DIR_LENTO_LIB      ;CHAMA A ROTINA DO BOT�O
        BCF     BOBINA4                  ;DESLIGA A BOBINA 3 DO MOTOR
        CALL    BOTAO_DIR_LENTO_LIB      ;CHAMA A ROTINA DO BOT�O

        GOTO    MOTOR_DIR_LENTO          ;VAI PARA A ROTINA DO MOTOR

MOTOR_DIR_RAPIDO
        BSF     BOBINA1                  ;LIGA A BOBINA 1 DO MOTOR
        CALL    BOTAO_DIR_RAPIDO_LIB     ;CHAMA A ROTINA DO BOT�O
        CALL    DELAY_RAPIDO             ;CHAMA A ROTINA DE ATRASO
        CALL    BOTAO_DIR_RAPIDO_LIB     ;CHAMA A ROTINA DO BOT�O
        BCF     BOBINA1                  ;DESLIGA A BOBINA 1 DO MOTOR
        CALL    BOTAO_DIR_RAPIDO_LIB     ;CHAMA A ROTINA DO BOT�O

        BSF     BOBINA2                  ;LIGA A BOBINA 2 DO MOTOR
        CALL    BOTAO_DIR_RAPIDO_LIB     ;CHAMA A ROTINA DO BOT�O
        CALL    DELAY_RAPIDO             ;CHAMA A ROTINA DE ATRASO
        CALL    BOTAO_DIR_RAPIDO_LIB     ;CHAMA A ROTINA DO BOT�O
        BCF     BOBINA2                  ;DESLIGA A BOBINA 2 DO MOTOR
        CALL    BOTAO_DIR_RAPIDO_LIB     ;CHAMA A ROTINA DO BOT�O

        BSF     BOBINA3                  ;LIGA A BOBINA 3 DO MOTOR
        CALL    BOTAO_DIR_RAPIDO_LIB     ;CHAMA A ROTINA DO BOT�O
        CALL    DELAY_RAPIDO             ;CHAMA A ROTINA DE ATRASO
        CALL    BOTAO_DIR_RAPIDO_LIB     ;CHAMA A ROTINA DO BOT�O
        BCF     BOBINA3                  ;DESLIGA A BOBINA 3 DO MOTOR
        CALL    BOTAO_DIR_RAPIDO_LIB     ;CHAMA A ROTINA DO BOT�O

        BSF     BOBINA4                  ;LIGA A BOBINA 4 DO MOTOR
        CALL    BOTAO_DIR_RAPIDO_LIB     ;CHAMA A ROTINA DO BOT�O
        CALL    DELAY_RAPIDO
        CALL    BOTAO_DIR_RAPIDO_LIB     ;CHAMA A ROTINA DO BOT�O
        BCF     BOBINA4                  ;DESLIGA A BOBINA 4 DO MOTOR
        CALL    BOTAO_DIR_RAPIDO_LIB     ;CHAMA A ROTINA DO BOT�O

        GOTO    MOTOR_DIR_RAPIDO         ;VAI PARA A ROTINA DO MOTOR

MOTOR_ESQ_LENTO
        BSF     BOBINA4                  ;LIGA A BOBINA 4 DO MOTOR
        CALL    BOTAO_ESQ_LENTO_LIB      ;CHAMA A ROTINA DO BOT�O
        CALL    DELAY_LENTO              ;CHAMA A ROTINA DE ATRASO
        CALL    BOTAO_ESQ_LENTO_LIB      ;CHAMA A ROTINA DO BOT�O
        BCF     BOBINA4                  ;DESLIGA A BOBINA 2 DO MOTOR
        CALL    BOTAO_ESQ_LENTO_LIB      ;CHAMA A ROTINA DO BOT�O

        BSF     BOBINA3                  ;LIGA A BOBINA 3 DO MOTOR
        CALL    BOTAO_ESQ_LENTO_LIB      ;CHAMA A ROTINA DO BOT�O
        CALL    DELAY_LENTO              ;CHAMA A ROTINA DE ATRASO
        CALL    BOTAO_ESQ_LENTO_LIB      ;CHAMA A ROTINA DO BOT�O
        BCF     BOBINA3                  ;DESLIGA A BOBINA 3 DO MOTOR
        CALL    BOTAO_ESQ_LENTO_LIB      ;CHAMA A ROTINA DO BOT�O

        BSF     BOBINA2                  ;LIGA A BOBINA 2 DO MOTOR
        CALL    BOTAO_ESQ_LENTO_LIB      ;CHAMA A ROTINA DO BOT�O
        CALL    DELAY_LENTO              ;CHAMA A ROTINA DE ATRASO
        CALL    BOTAO_ESQ_LENTO_LIB      ;CHAMA A ROTINA DO BOT�O
        BCF     BOBINA2                  ;DESLIGA A BOBINA 2 DO MOTOR
        CALL    BOTAO_ESQ_LENTO_LIB      ;CHAMA A ROTINA DO BOT�O

        BSF     BOBINA1                  ;LIGA A BOBINA 1 DO MOTOR
        CALL    BOTAO_ESQ_LENTO_LIB      ;CHAMA A ROTINA DO BOT�O
        CALL    DELAY_LENTO              ;CHAMA A ROTINA DE ATRASO
        CALL    BOTAO_ESQ_LENTO_LIB      ;CHAMA A ROTINA DO BOT�O
        BCF     BOBINA1                  ;DESLIGA A BOBINA 1 DO MOTOR
        CALL    BOTAO_ESQ_LENTO_LIB      ;CHAMA A ROTINA DO BOT�O

        GOTO    MOTOR_ESQ_LENTO

MOTOR_ESQ_RAPIDO
        BSF     BOBINA4                  ;LIGA A BOBINA 4 DO MOTOR
        CALL    BOTAO_ESQ_RAPIDO_LIB     ;CHAMA A ROTINA DO BOT�O
        CALL    DELAY_RAPIDO             ;CHAMA A ROTINA DE ATRASO
        CALL    BOTAO_ESQ_RAPIDO_LIB     ;CHAMA A ROTINA DO BOT�O
        BCF     BOBINA4                  ;DESLIGA A BOBINA 4 DO MOTOR
        CALL    BOTAO_ESQ_RAPIDO_LIB     ;CHAMA A ROTINA DO BOT�O

        BSF     BOBINA3                  ;LIGA A BOBINA 3 DO MOTOR
        CALL    BOTAO_ESQ_RAPIDO_LIB     ;CHAMA A ROTINA DO BOT�O
        CALL    DELAY_RAPIDO             ;CHAMA A ROTINA DE ATRASO
        CALL    BOTAO_ESQ_RAPIDO_LIB     ;CHAMA A ROTINA DO BOT�O
        BCF     BOBINA3                  ;DESLIGA A BOBINA 3 DO MOTOR
        CALL    BOTAO_ESQ_RAPIDO_LIB     ;CHAMA A ROTINA DO BOT�O

        BSF     BOBINA2                  ;LIGA A BOBINA 2 DO MOTOR
        CALL    BOTAO_ESQ_RAPIDO_LIB     ;CHAMA A ROTINA DO BOT�O
        CALL    DELAY_RAPIDO             ;CHAMA A ROTINA DE ATRASO
        CALL    BOTAO_ESQ_RAPIDO_LIB     ;CHAMA A ROTINA DO BOT�O
        BCF     BOBINA2                  ;DESLIGA A BOBINA 2 DO MOTOR
        CALL    BOTAO_ESQ_RAPIDO_LIB     ;CHAMA A ROTINA DO BOT�O

        BSF     BOBINA1                  ;LIGA A BOBINA 1 DO MOTOR
        CALL    BOTAO_ESQ_RAPIDO_LIB     ;CHAMA A ROTINA DO BOT�O
        CALL    DELAY_RAPIDO             ;CHAMA A ROTINA DE ATRASO
        CALL    BOTAO_ESQ_RAPIDO_LIB     ;CHAMA A ROTINA DO BOT�O
        BCF     BOBINA1                  ;DESLIGA A BOBINA 1 DO MOTOR
        CALL    BOTAO_ESQ_RAPIDO_LIB     ;CHAMA A ROTINA DO BOT�O

        GOTO    MOTOR_ESQ_RAPIDO         ;VAI PARA A ROTINA DO MOTOR


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                          ROTINAS DE TEMPORIZA��O                          *
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

;TEMPORIZADOR PADR�O
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

        END                    ;OBRIGAT�RIO
