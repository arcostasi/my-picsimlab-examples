;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* UNICESUMAR - MARING�                                                      *
;* CURSO DE EXTENS�O EM MICROCONTROLADORES PIC                               *
;* PROFESSOR EMERSON MARTINS                                                 *
;*---------------------------------------------------------------------------*
;* EXEMPLO 04 - CONTADOR DECRESCENTE TEMPORIZADO                             *
;* DESENVOLVIDO POR ANDERSON COSTA                                           *
;* VERS�O 1.0                                               DATA: 16/06/2007 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* CONTADOR TEMPORIZADO, QUE DECREMENTA O VALOR A CADA UM SEGUNDO,           *
;* MOSTRANDO O VALOR NO DISPLAY 7 SEGMENTOS NO PORTB. (VALOR INICIAL = 9)    *
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
                ANTDEB
                ANTDEB2
                CONTADOR
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
;*                                  ENTRADA                                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO ENTRADA
;* SEGUE ABAIXO DE CADA DEFINI��O O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

#DEFINE BOTAO   PORTA,0        ;PORTA DO BOT�O
                               ; 0 -> PRESSIONADO
                               ; 1 -> LIBERADO


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                                   SA�DA                                   *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO SA�DA
;* SEGUE ABAIXO DE CADA DEFINI��O O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

#DEFINE DISPLAY PORTB          ;LED PARA CONTADOR


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
        MOVLW   B'00000001'    ;MOVE LITERAL BIN�RIO PARA WORK
        MOVWF   TRISA          ;DEFINI��O DE ENTRADA E SA�DA DO PORTA
                               ;SETA RA0 COMO ENTRADA

        MOVLW   B'00000000'    ;MOVE LITERAL BIN�RIO PARA WORK
        MOVWF   TRISB          ;DEFINI��O DE ENTRADA E SA�DA DO PORTB

        MOVLW   B'10000000'
        MOVWF   OPTION_REG     ;PULL_UPS DESABILITADOS <7>

        MOVLW   B'00000000'
        MOVWF   INTCON         ;TODAS AS INTERRUP��ES DESLIGADAS
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
        CALL    DELAY_250MS

        CLRF    CONTADOR       ;LIMPA O REGISTRADOR CONTADOR
        MOVF    CONTADOR,W     ;MOVE O VALOR DO CONTADOR PARA W (ZERO)
        CALL    CONVERTE       ;CHAMA A ROTINA DE CONVERS�O
                               ;COM VALOR DE ZERO EM W
        MOVWF   DISPLAY        ;MOVE O VALOR DE W J� CONVERTIDO PARA DISPLAY
        CALL    DELAY_1S       ;GASTA UM SEGUNDO, MOSTRANDO O VALOR
                               ;CONVERTIDO NO DISPLAY

SE_BT_PRESS
        BTFSC   BOTAO          ;TESTE O BOT�O PARA DETECTAR SE EST� PRESSIONADO
        GOTO    SE_BT_PRESS    ;BOT�O N�O PRESSIONADO, CONTINUA TESTANDO
        GOTO    ANT_DEB1       ;BOT�O PRESSIONADO, V� PARA A ROTINA DE FILTRO

ANT_DEB1
        DECFSZ  ANTDEB,1       ;DECREMENTA O REGISTRADOR ANTDEB E PULA UMA LINHA
                               ;SE FOR ZERO
        GOTO    ANT_DEB1       ;RESULTADO DO DECREMENTO DIFERENTE DE ZERO,
                               ;CONTINUA DECREMENTANDO
        GOTO    ANT_DEB2       ;RESULTADO DO DECREMENTO DE ANTDEB IGUAL A ZERO
                               ;VA PARA ANT_DEB2

ANT_DEB2
        DECFSZ  ANTDEB2,1      ;DECREMENTA O REGISTRADOR ANTDEB2 E PULA UMA
                               ;LINHA SE FOR ZERO
        GOTO    ANT_DEB2       ;RESULTADO DO DECREMENTO DIFERENTE DE ZERO,
                               ;CONTINUA DECREMENTANDO
        GOTO    DECREMENTO     ;RESULTADO DO DECREMENTO DE ANTDEB2 IGUAL A ZERO
                               ;VA PARA DECREMENTO

DECREMENTO
        INCF    CONTADOR,F     ;INCREMENTO O CONTADOR E GUARDA O RESULTADO
                               ;NELE MESMO
        MOVF    CONTADOR,W     ;MOVE O VALOR DO CONTADOR PARA W
        CALL    CONVERTE       ;CHAMA A ROTINA CALL CONVERTE
        MOVWF   DISPLAY        ;MOVE O VALOR DO W J� CONVERTIDO PARA DISPLAY
        CALL    DELAY_1S       ;GASTAR UM SEGUNDO, MOSTRANDO O VALOR
                               ;CONVERTIDO NO DISPLAY
        MOVLW   .9             ;MOVE O LITERAL 9 PARA W
        XORWF   CONTADOR,W     ;FAZ A LOGICA XOR ENTRE CONTADOR E W
        BTFSS   STATUS,Z       ;TESTA O FLAG Z, PARA DETECTAR SE O VALOR DO
                               ;CONTADOR
                               ;� IGUAL AO VALOR DE W
        GOTO    DECREMENTO     ;FLAG Z DIFERENTE DE W, CONTINUA DECREMENTANDO
                               ;O CONTADOR
        CLRF    CONTADOR       ;LIMPAR CONTADOR
        CALL    CONVERTE       ;CHAMA A ROTINA DE CONVERS�O PARA SETE SEGMENTOS
        MOVWF   DISPLAY        ;MOVE O VALOR CONVERTIDO PARA O DISPLAY
        CALL    DELAY_1S       ;AGUARDA 1 SEGUNDO
        GOTO    DECREMENTO     ;VA PARA INCREMENTO NOVAMENTE

CONVERTE
        ADDWF   PCL,F          ;ADICIONA O VALOR DE W AO REGISTRADOR PCL
                               ;PCL � UM REGISTRADOR QUE MONITORA OS ENDERE�OS
        RETLW   B'01101111'    ;NOVE
        RETLW   B'11101111'    ;OITO
        RETLW   B'00101100'    ;SETE
        RETLW   B'11100111'    ;SEIS
        RETLW   B'01100111'    ;CINCO
        RETLW   B'00101011'    ;QUATRO
        RETLW   B'01101101'    ;TRES
        RETLW   B'11001101'    ;DOIS
        RETLW   B'00101000'    ;UM
        RETLW   B'11101110'    ;ZERO
        RETURN


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
        MOVWF   D_250MS_1      ;+1     TOTAL 1 = 4us
DELAY_250A
        MOVLW   .249           ;+1
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
