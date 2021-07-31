;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* UNICESUMAR - MARING�                                                      *
;* CURSO DE EXTENS�O EM MICROCONTROLADORES PIC                               *
;* PROFESSOR EMERSON MARTINS                                                 *
;*---------------------------------------------------------------------------*
;* EXEMPLO 03 - CONTROLE DE N�VEL                                            *
;* DESENVOLVIDO POR ANDERSON COSTA                                           *
;* VERS�O 1.0                                               DATA: 16/06/2007 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* CONTROLE DE N�VEL UTILIZANDO DOIS SENSORES, QUANDO O L�QUIDO CHEGAR AO    *
;* N�VEL M�XIMO (RA4) DEVER� DESLIGAR A BOMBA, QUANDO CHEGAR AO N�VEL        *
;* M�NIMO (RA3) DEVER� LIGAR A BOMBA, E SE POR ALGUM MOTIVO � �GUA ABAIXAR   *
;* DO N�VEL M�NIMO E CHEGAR AO N�VEL CR�TICO (RB0) DEVER� LIGAR O LED (RB2)  *
;* SIMULANDO UM ALARME UTILIZANDO INTERRUP��O EM RB0.                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                          ARQUIVOS DE DEFINI��ES                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#INCLUDE <P16F628A.INC>        ;ARQUIVO PADR�O MICROCHIP PARA O PIC16F628A   *

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
                CONTADOR
                ANTDEB1
                ANTDEB2
                D_250MS_1
                D_250MS_2
                D_500MS
                D_1S
        ENDC                   ;FIM DO BLOCO DE MEM�RIA


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                                CONSTANTES                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* DEFINI��O DE TODAS AS CONSTANTES UTILIZADAS PELO PROGRAMADOR


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                                 ENTRADAS                                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO ENTRADA
;* SEGUE ABAIXO DE CADA DEFINI��O O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

#DEFINE BOTAO1  PORTA,3        ;PORTA DO BOT�O
                               ; 0 -> PRESSIONADO
                               ; 1 -> LIBERADO

#DEFINE BOTAO2  PORTA,4        ;PORTA DO BOT�O
                               ; 0 -> PRESSIONADO
                               ; 1 -> LIBERADO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                                  SA�DAS                                   *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO SA�DA
;* SEGUE ABAIXO DE CADA DEFINI��O O SIGNIFICADO DE SEUS ESTADOS (0 E 1)


#DEFINE BOMBA   PORTB,1        ;LED DA BOMBA
#DEFINE LED     PORTB,2        ;LED DO ALARME


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
        MOVLW   B'00011000'    ;MOVE LITERAL BIN�RIO PARA WORK
        MOVWF   TRISA          ;DEFINI��O DE ENTRADA E SA�DA DO PORTA

        MOVLW   B'00000000'    ;MOVE LITERAL BIN�RIO PARA WORK
        MOVWF   TRISB          ;DEFINI��O DE ENTRADA E SA�DA DO PORTB

        MOVLW   B'10000000'
        MOVWF   OPTION_REG     ;PULL_UPS DESABILITADOS <7>

        ; BIT   B'76543210
        MOVLW   B'10000010'
        MOVWF   INTCON         ;INTERRUP��O RB0 ATIVADA
        BANK0                  ;RETORNA PARA O BANCO 0

        MOVLW   B'00000111'
        MOVWF   CMCON          ;CONFIGURA RA3:RA0 COMO I/O <2:0>


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        INICIALIZA��O DAS VARI�VEIS                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

        CLRF    PORTA          ;LIMPA PORT A
        CLRF    PORTB          ;LIMPA PORT B


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                             ROTINA PRINCIPAL                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

MAIN
        BCF     LED            ;DESLIGA LED, CASO LIGADO

BOTAO1_PRESS
        BTFSC   BOTAO1         ;TESTA O BOT�O 1 PARA DETECTAR SE EST� PRESSIONADO
        GOTO    ANTDEB_1       ;BOT�O PRESSIONADO, V� PARA A ROTINA DE FILTRO
        GOTO    BOTAO2_PRESS   ;BOT�O N�O PRESSIONADO, VERIFICA BOT�O 2

BOTAO2_PRESS
        BTFSC   BOTAO2         ;TESTA O BOT�O 2 PARA DETECTAR SE EST� PRESSIONADO
        GOTO    ANTDEB_1       ;BOT�O PRESSIONADO, V� PARA A ROTINA DE FILTRO
        GOTO    BOTAO1_PRESS   ;BOT�O N�O PRESSIONADO, RETORNA PARA O BOT�O 1

; ROTINA DE ANTI-DEBOUNCE
ANTDEB_1
        MOVLW   .250           ;MOVE O LITERAL 250 PARA W (WORK)
        MOVWF   ANTDEB1        ;MOVE O VALOR DE W PARA REGISTRADOR ANTIDEB1
        MOVLW   .200           ;MOVE O LITERAL 200 PARA W
        MOVWF   ANTDEB2        ;MOVE O VALOR DE W PARA O REGISTRADOR ANTIDEB2

DEC_ANTDEB_1
        DECFSZ  ANTDEB1        ;DECREMENTA O REGISTRADOR E SALTA UMA LINHA
                               ;SE O RESULTADO ESTIVER EM ZERO
        GOTO    $-1            ;RESULTAO AINDA DIFERENTE DE ZERO, VOLTA
                               ;PARA DECREMENTAR O REGISTRADOR ANTIDEB1
        GOTO    DEC_ANTDEB_2   ;REGISTRADOR ANTIDEB EM ZERO, V� PARA
                               ;DECREMENTO DO REGISTRADOR ANTIDEB2

DEC_ANTDEB_2
        DECFSZ  ANTDEB2        ;DECREMENTE O REGISTRADOR ANTIDEB2, E PULE
                               ;UMA LINHA QUANDO O REGISTRADOR FOR ZERO
        GOTO    DEC_ANTDEB_1   ;RESULTADO DIFERENTE DE ZERO,
                               ;VOLTA PARA O DECREMENTO DO ANTIDEB1
        GOTO    BOTAO_LIB      ;REGISTRADOR ANTIDEB2 EM ZERO,
                               ;V� PARA O TESTE DO BOT�O LIBERADO

BOTAO_LIB                      ;ROTINA DO BOT�O 1 LIBERADO
        BTFSS   BOTAO1         ;TESTA O BOT�O PARA DETECTAR
        GOTO    LIGA_BOMBA     ;BOT�O LIBERADO, V� PARA ROTINA LIGA BOMBA

        BTFSS   BOTAO2         ;TESTA O BOT�O PARA DETECTAR
        GOTO    DESLIGA_BOMBA  ;BOT�O LIBERADO, V� PARA ROTINA DESLIGA BOMBA
        GOTO    BOTAO_LIB      ;BOT�O AINDA PRESSIONADO, CONTINUA VERIFICANDO

LIGA_LED
        BSF     LED            ;ACENDE LED
        GOTO    MAIN           ;RETORNA A ROTINA PRINCIPAL

LIGA_BOMBA
        BSF     BOMBA          ;LIGA A BOMBA
        GOTO    MAIN           ;RETORNA A ROTINA PRINCIPAL

DESLIGA_BOMBA
        BCF     BOMBA          ;DESLIGA A BOMBA
        GOTO    MAIN           ;RETORNA A ROTINA PRINCIPAL

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                          ROTINAS DE TEMPORIZA��O                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;TEMPORIZADOR PARA 1 SEGUNDO EM 4MHz
DELAY_1S
        MOVLW   .2
        MOVWF   D_1S
DELAY_1A
        CALL    DELAY_500MS
        DECFSZ  D_1S,1
        GOTO    DELAY_1A
        RETURN

;TEMPORIZADOR PARA 500ms EM 4MHz
DELAY_500MS
        MOVLW   .2
        MOVWF   D_500MS
DELAY_500A
        CALL    DELAY_250MS
        DECFSZ  D_500MS,1
        GOTO    DELAY_500A
        RETURN

;TEMPORIZADOR PARA 250ms EM 4MHz
DELAY_250MS                    ;O CALL PARA A ROTINA LEVA 2us
        MOVLW   .250           ;+1
        MOVWF   D_250MS_1      ;+1 TOTAL 1 = 4us
DELAY_250A
        MOVLW   .248           ;+1
        MOVWF   D_250MS_2      ;+1 TOTAL 2 = 2us
DELAY_250B
        NOP                    ;+1
        DECFSZ  D_250MS_2,1    ;1 248 x 4 us +
        GOTO    DELAY_250B
        DECFSZ  D_250MS_1,1
        GOTO    DELAY_250A
        RETURN


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                              FIM DO PROGRAMA                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

        END                    ;OBRIGAT�RIO
