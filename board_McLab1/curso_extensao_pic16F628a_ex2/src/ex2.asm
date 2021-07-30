;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* UNICESUMAR - MARING�                                                      *
;* CURSO DE EXTENS�O EM MICROCONTROLADORES PIC                               *
;* PROFESSOR EMERSON MARTINS                                                 *
;*---------------------------------------------------------------------------*
;* EXEMPLO 02 - CONTADOR POR PULSOS E TEMPORIZADOR                           *
;* DESENVOLVIDO POR ANDERSON COSTA                                           *
;* VERS�O 1.0                                               DATA: 09/06/2007 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* CONTADOR POR PULSOS AT� 3, APLICANDO PULSOS NEGATIOS EM RA1, AO CHEGAR   *
;* A ESSE VALOR DEVE ACIONAR UM LED QUE FICAR� ACESO POR 5 SEGUNDOS E        *
;* EM SEGUIDA DESLIGAR O LED                                                 *
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
                ANTIDEB1
                ANTIDEB2
                D_250MS_1
                D_250MS_2
                D_500MS
                D_1S
                D_5S
        ENDC                   ;FIM DO BLOCO DE MEM�RIA


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                                CONSTANTES                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* DEFINI��O DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                                 ENTRADAS                                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO ENTRADA
;* SEGUE ABAIXO DE CADA DEFINI��O O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

#DEFINE BOTAO   PORTA,1        ;PORTA DO BOT�O
                               ; 0 -> PRESSIONADO
                               ; 1 -> LIBERADO


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                                  SA�DAS                                   *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO SA�DA
;* SEGUE ABAIXO DE CADA DEFINI��O O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

#DEFINE LED     PORTB,1        ;LED PARA CONTADOR


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
        MOVLW   B'00000010'    ;MOVE LITERAL BIN�RIO PARA WORK
        MOVWF   TRISA          ;DEFINI��O DE ENTRADA E SA�DA DO PORTA
                               ;RA1 � ENTRADA, OS OUTROS PINOS COMO SA�DA

        MOVLW   B'00000000'    ;MOVE LITERAL BIN�RIO PARA WORK
        MOVWF   TRISB          ;DEFINI��O DE ENTRADA E SA�DA DO PORTB
                               ;TODOS OS PINOS COMO SA�DA

        MOVLW   B'10000000'
        MOVWF   OPTION_REG     ;PULL_UPS DESABILITADOS <7>

        MOVLW   B'00000000'
        MOVWF   INTCON         ;TODAS AS INTERRUP��ES DESLIGADAS
        BANK0                  ;RETORNA PARA O BANCO 0

        MOVLW   B'00000111'
        MOVWF   CMCON          ;CONFIGURA RA3:RA1 COMO I/O <2:0>


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        INICIALIZA��O DAS VARI�VEIS                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

        CLRF    PORTA          ;LIMPA PORT A
        CLRF    PORTB          ;LIMPA PORT B


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                             ROTINA PRINCIPAL                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

MAIN
        CLRF    CONTADOR       ;LIMPA O CONTADOR
        BCF     LED            ;DESLIGA LED, CASO LIGADO

BOTAO_PRESS
        BTFSS   BOTAO          ;TESTA O BOT�O
        GOTO    $-1            ;BOT�O EM ZERO, N�O PRESSIONADO
                               ;VOLTA PARA TESTE DO BOT�O
        GOTO    ANTIDEB_1      ;BOT�O EM UM, PRESSIONADO
                               ;V� PARA TRATAMENTO ANTI-DEBOUNCE

; ROTINA DE ANTI-DEBOUNCE
ANTIDEB_1
        MOVLW   .250           ;MOVE O LITERAL 250 PARA W (WORK)
        MOVWF   ANTIDEB1       ;MOVE O VALOR DE W PARA REGISTRADOR ANTIDEB1
        MOVLW   .200           ;MOVE O LITERAL 200 PARA W
        MOVWF   ANTIDEB2       ;MOVE O VALOR DE W PARA O REGISTRADOR ANTIDEB2

DEC_ANTIDEB_1
        DECFSZ  ANTIDEB1,1     ;DECREMENTA O REGISTRADOR E SALTA UMA LINHA
                               ;SE O RESULTADO ESTIVER EM ZERO
        GOTO    $-1            ;RESULTAO AINDA DIFERENTE DE ZERO, VOLTA
                               ;PARA DECREMENTAR O REGISTRADOR ANTIDEB1
        GOTO    DEC_ANTIDEB_2  ;REGISTRADOR ANTIDEB EM ZERO, V� PARA
                               ;DECREMENTO DO REGISTRADOR ANTIDEB2

DEC_ANTIDEB_2
        DECFSZ  ANTIDEB2,1     ;DECREMENTE O REGISTRADOR ANTIDEB2, E PULE
                               ;UMA LINHA QUANDO O REGISTRADOR FOR ZERO
        GOTO    DEC_ANTIDEB_1  ;RESULTADO DIFERENTE DE ZERO,
                               ;VOLTA PARA O DECREMENTO DO ANTIDEB1
        GOTO    BOTAO_LIB      ;REGISTRADOR ANTIDEB2 EM ZERO,
                               ;V� PARA O TESTE DO BOT�O LIBERADO

BOTAO_LIB                      ;ROTINA DO BOT�O LIBERADO
        BTFSC   BOTAO          ;TESTA O BOT�O PARA DETECTAR
                               ;SE O MESMO FOR LIBERADO
        GOTO    $-1            ;BOT�O AINDA PRESSIONADO, CONTINUA TESTANDO
        GOTO    INCREMENTO     ;BOT�O LIBERADO, V� PARA ROTINA DE
                               ;INCREMENTO DE CONTADOR

INCREMENTO
        MOVLW   .3             ;MOVE O LITERAL 3 PARA W
        INCF    CONTADOR,F     ;INCREMENTA O CONTADOR E GUARDA O
                               ;RESULTADO NELE MESMO
        XORWF   CONTADOR,W     ;FAZ A LOGICA XOR ENTRE O VALOR DO
                               ;CONTADOR EM W, PARA IDENTIFICAR SE S�O IGUAIS
        BTFSS   STATUS,Z       ;TESTA O BIT Z DO REGISTRADOR STATUS,
                               ;SE FOR UM INDICA QUE W E CONTADOR S�O
                               ;IGUAIS E PULA UMA LINHA
        GOTO    BOTAO_PRESS    ;FLAG, Z AINDA EM ZERO, INDICA QUE W
                               ;E CONTADOR AINDA S�O DIFERENTES,
                               ;VOLTA PARA TESTE DO BOT�O
        GOTO    LIGA_LED       ;FLAG, Z EM UM, INDICA QUE W E STATUS S�O IGUAIS,
                               ;LOGO A CONTAGEM CHEGOU
                               ;A DEZENOVE, V� PARA LIGA_LED
LIGA_LED
        BSF     LED            ;ACENDE LED
        CALL    DELAY_5S       ;CHAMA ROTINA DE 5 SEGUNDOS
        GOTO    MAIN           ;RETORNA A ROTINA PRINCIPAL


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                          ROTINAS DE TEMPORIZA��O                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;TEMPORIZADOR PARA 5 SEGUNDOS EM 4MHz
DELAY_5S
        MOVLW   .5
        MOVWF   D_5S
DELAY_5A
        CALL    DELAY_1S
        DECFSZ  D_5S,1
        GOTO    DELAY_5A
        RETURN

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
        MOVWF   D_250MS_1      ;+1     TOTAL 1 = 4us
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
