;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* UNICESUMAR - MARINGÁ                                                      *
;* CURSO DE EXTENSÃO EM MICROCONTROLADORES PIC                               *
;* PROFESSOR EMERSON MARTINS                                                 *
;*---------------------------------------------------------------------------*
;* EXEMPLO 03 - CONTROLE DE NÍVEL                                            *
;* DESENVOLVIDO POR ANDERSON COSTA                                           *
;* VERSÃO 1.0                                               DATA: 16/06/2007 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* CONTROLE DE NÍVEL UTILIZANDO DOIS SENSORES, QUANDO O LÍQUIDO CHEGAR AO    *
;* NÍVEL MÁXIMO (RA4) DEVERÁ DESLIGAR A BOMBA, QUANDO CHEGAR AO NÍVEL        *
;* MÍNIMO (RA3) DEVERÁ LIGAR A BOMBA, E SE POR ALGUM MOTIVO À ÁGUA ABAIXAR   *
;* DO NÍVEL MÍNIMO E CHEGAR AO NÍVEL CRÍTICO (RB0) DEVERÁ LIGAR O LED (RB2)  *
;* SIMULANDO UM ALARME UTILIZANDO INTERRUPÇÃO EM RB0.                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                          ARQUIVOS DE DEFINIÇÕES                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#INCLUDE <P16F628A.INC>        ;ARQUIVO PADRÃO MICROCHIP PARA O PIC16F628A   *

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
                CONTADOR
                ANTDEB1
                ANTDEB2
                D_250MS_1
                D_250MS_2
                D_500MS
                D_1S
        ENDC                   ;FIM DO BLOCO DE MEMÓRIA


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                                CONSTANTES                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* DEFINIÇÃO DE TODAS AS CONSTANTES UTILIZADAS PELO PROGRAMADOR


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                                 ENTRADAS                                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO ENTRADA
;* SEGUE ABAIXO DE CADA DEFINIÇÃO O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

#DEFINE BOTAO1  PORTA,3        ;PORTA DO BOTÃO
                               ; 0 -> PRESSIONADO
                               ; 1 -> LIBERADO

#DEFINE BOTAO2  PORTA,4        ;PORTA DO BOTÃO
                               ; 0 -> PRESSIONADO
                               ; 1 -> LIBERADO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                                  SAÍDAS                                   *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO SAÍDA
;* SEGUE ABAIXO DE CADA DEFINIÇÃO O SIGNIFICADO DE SEUS ESTADOS (0 E 1)


#DEFINE BOMBA   PORTB,1        ;LED DA BOMBA
#DEFINE LED     PORTB,2        ;LED DO ALARME


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
        MOVLW   B'00011000'    ;MOVE LITERAL BINÁRIO PARA WORK
        MOVWF   TRISA          ;DEFINIÇÃO DE ENTRADA E SAÍDA DO PORTA

        MOVLW   B'00000000'    ;MOVE LITERAL BINÁRIO PARA WORK
        MOVWF   TRISB          ;DEFINIÇÃO DE ENTRADA E SAÍDA DO PORTB

        MOVLW   B'10000000'
        MOVWF   OPTION_REG     ;PULL_UPS DESABILITADOS <7>

        ; BIT   B'76543210
        MOVLW   B'10000010'
        MOVWF   INTCON         ;INTERRUPÇÃO RB0 ATIVADA
        BANK0                  ;RETORNA PARA O BANCO 0

        MOVLW   B'00000111'
        MOVWF   CMCON          ;CONFIGURA RA3:RA0 COMO I/O <2:0>


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        INICIALIZAÇÃO DAS VARIÁVEIS                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

        CLRF    PORTA          ;LIMPA PORT A
        CLRF    PORTB          ;LIMPA PORT B


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                             ROTINA PRINCIPAL                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

MAIN
        BCF     LED            ;DESLIGA LED, CASO LIGADO

BOTAO1_PRESS
        BTFSC   BOTAO1         ;TESTA O BOTÃO 1 PARA DETECTAR SE ESTÁ PRESSIONADO
        GOTO    ANTDEB_1       ;BOTÃO PRESSIONADO, VÁ PARA A ROTINA DE FILTRO
        GOTO    BOTAO2_PRESS   ;BOTÃO NÃO PRESSIONADO, VERIFICA BOTÃO 2

BOTAO2_PRESS
        BTFSC   BOTAO2         ;TESTA O BOTÃO 2 PARA DETECTAR SE ESTÁ PRESSIONADO
        GOTO    ANTDEB_1       ;BOTÃO PRESSIONADO, VÁ PARA A ROTINA DE FILTRO
        GOTO    BOTAO1_PRESS   ;BOTÃO NÃO PRESSIONADO, RETORNA PARA O BOTÃO 1

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
        GOTO    DEC_ANTDEB_2   ;REGISTRADOR ANTIDEB EM ZERO, VÁ PARA
                               ;DECREMENTO DO REGISTRADOR ANTIDEB2

DEC_ANTDEB_2
        DECFSZ  ANTDEB2        ;DECREMENTE O REGISTRADOR ANTIDEB2, E PULE
                               ;UMA LINHA QUANDO O REGISTRADOR FOR ZERO
        GOTO    DEC_ANTDEB_1   ;RESULTADO DIFERENTE DE ZERO,
                               ;VOLTA PARA O DECREMENTO DO ANTIDEB1
        GOTO    BOTAO_LIB      ;REGISTRADOR ANTIDEB2 EM ZERO,
                               ;VÁ PARA O TESTE DO BOTÃO LIBERADO

BOTAO_LIB                      ;ROTINA DO BOTÃO 1 LIBERADO
        BTFSS   BOTAO1         ;TESTA O BOTÃO PARA DETECTAR
        GOTO    LIGA_BOMBA     ;BOTÃO LIBERADO, VÁ PARA ROTINA LIGA BOMBA

        BTFSS   BOTAO2         ;TESTA O BOTÃO PARA DETECTAR
        GOTO    DESLIGA_BOMBA  ;BOTÃO LIBERADO, VÁ PARA ROTINA DESLIGA BOMBA
        GOTO    BOTAO_LIB      ;BOTÃO AINDA PRESSIONADO, CONTINUA VERIFICANDO

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
;*                          ROTINAS DE TEMPORIZAÇÃO                          *
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

        END                    ;OBRIGATÓRIO
