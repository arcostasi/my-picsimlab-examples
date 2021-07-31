;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* UNICESUMAR - MARINGÁ                                                      *
;* CURSO DE EXTENSÃO EM MICROCONTROLADORES PIC                               *
;* PROFESSOR EMERSON MARTINS                                                 *
;*---------------------------------------------------------------------------*
;* EXEMPLO 01 - CONTADOR CRESCENTE POR PULSOS COM DISPLAY DE 7 SEGMENTOS     *
;* DESENVOLVIDO POR ANDERSON COSTA                                           *
;* VERSÃO 1.0                                               DATA: 09/06/2007 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* CONTADOR CRESCENTE DE 0 A F, APLICANDO PULSOS POSITIVOS NO BOTÃO RA1      *
;* O VALOR DO CONTADOR DEVERÁ SER MOSTRADO EM UM DISPLAY DE 7 SEGMENTOS,     *
;* QUANDO O VALOR CHEGAR A F DEVERÁ VOLTAR A ZERO.                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                          ARQUIVOS DE DEFINIÇÕES                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;LIST      p=16F628A    ;DIRETIVA PARA DEFINIR O PROCESSADOR
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

        CBLOCK  0X20           ;ENDEREÇO INICIAL DA MEMÓRIA
                ANTDEB
                ANTDEB2
                CONTADOR
        ENDC                   ;FIM DO BLOCO DE MEMÓRIA


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                                CONSTANTES                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* DEFINIÇÃO DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

MAX             EQU     .16    ;VALOR MÁXIMO PARA O CONTADOR

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                                 ENTRADAS                                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO ENTRADA
;* SEGUE ABAIXO DE CADA DEFINIÇÃO O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

#DEFINE BOTAO   PORTA,1        ;PORTA DO BOTÃO
                               ; 0 -> LIBERADO
                               ; 1 -> PRESSIONADO


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                                  SAÍDAS                                   *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO SAÍDA
;* SEGUE ABAIXO DE CADA DEFINIÇÃO O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

#DEFINE DISPLAY PORTB          ;DISPLAY PARA CONTADOR


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
        MOVLW   B'00000010'    ;MOVE LITERAL BINÁRIO PARA WORK
        MOVWF   TRISA          ;DEFINIÇÃO DE ENTRADA E SAÍDA DO PORTA
                               ;RA1 COMO ENTRADA, OS OUTROS PINOS COMO SAÍDA

        MOVLW   B'00000000'    ;MOVE LITERAL BINÁRIO PARA WORK
        MOVWF   TRISB          ;DEFINIÇÃO DE ENTRADA E SAÍDA DO PORTB
                               ;TODOS OS PINOS COMO SAÍDA PARA O DISPLAY

        MOVLW   B'10000000'
        MOVWF   OPTION_REG     ;PULL_UPS DESABILITADOS <7>

        MOVLW   B'00000000'
        MOVWF   INTCON         ;TODAS AS INTERRUPÇÕES DESLIGADAS
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
        CLRF    ANTDEB         ;LIMPA O REGISTRADOR ANTDEB
        CLRF    ANTDEB2        ;LIMPA O REGISTRADOR ANTDEB2
        CLRF    CONTADOR       ;LIMPA O CONTADOR

CONVERSAO
        MOVF    CONTADOR,W     ;MOVE O VALOR DO CONTADOR PARA W
        CALL    CONVERTE       ;CHAMA A ROTINA DE CONVERSÃO PARA 7 SEGMENTOS
        MOVWF   DISPLAY        ;MOVE O VALOR DE W JÁ CONVERTIDO EM 7 SEGMENTOS
                               ;PARA DISPLAY (PORTB)

BOTAO_PRESS
        BTFSC   BOTAO          ;TESTA O BOTÃO PARA DETECTAR SE ESTÁ PRESSIONADO
        GOTO    BOTAO_PRESS    ;BOTÃO NÃO PRESSIONADO, CONTINUA TESTANDO
        GOTO    FILTRO         ;BOTÃO PRESSIONADO, VÁ PARA A ROTINA DE FILTRO

FILTRO
        DECFSZ  ANTDEB,1       ;DECREMENTA O REGISTRADOR ANTDEB E
                               ;PULA UMA LINHA SE FOR ZERO
        GOTO    FILTRO         ;RESULTADO DO DECREMENTO DIFERENTE DE ZERO,
                               ;CONTINUA DECREMENTANDO
        GOTO    FILTRO2        ;RESULTADO DO DECREMENTO DE ANTDEB IGUAL A
                               ;ZERO VÁ PARA FILTRO2

FILTRO2
        DECFSZ  ANTDEB2,1      ;DECREMENTA O REGISTRADOR ANTDEB2 E PULA
                               ;UMA LINHA SE FOR ZERO
        GOTO    FILTRO2        ;RESULTADO DO DECREMENTO DIFERENTE DE ZERO,
                               ;CONTINUA DECREMENTANDO
        GOTO    INCREMENTA     ;RESULTADO DO DECREMENTO DE ANTDEB2 IGUAL A ZERO
                               ;VÁ PARA INCREMENTA

INCREMENTA
        INCF    CONTADOR,F     ;INCREMENTA O CONTADOR E GUARDA O RESULTADO
                               ;NELE MESMO
        MOVLW   MAX            ;MOVE A CONSTANTE MÁXIMA DO CONTADOR PARA W
        XORWF   CONTADOR,W     ;FAZ A LOGICA XOR ENTRE CONTADOR E W
        BTFSS   STATUS,Z       ;TESTA O FLAG Z, PARA DETECTAR SE O VALOR
                               ;DO CONTADOR É IGUAL AO VALOR DE W
        GOTO    BOTAO_LIB      ;FLAG Z, DIFERENTE DE ZERO, VAI PARA
                               ;TESTE DO BOTÃO LIBERADO
        GOTO    MAIN           ;FLAG Z EM 1, LOGO O CONTADOR É IGUAL A W,
                               ;VOLTA PARA MAIN

BOTAO_LIB
        BTFSS   BOTAO          ;TESTA O BOTÃO PARA DETECTAR SE FOI LIBERADO
        GOTO    BOTAO_LIB      ;BOTÃO AINDA NÃO LIBERADO,
                               ;CONTINUA TESTANDO O MESMO
        GOTO    CONVERSAO      ;SE LIBERADO, VÁ PARA ROTINA CONVERSÃO

CONVERTE
        ADDWF   PCL,F          ;ADICIONA O VALOR DE W AO REGISTRADOR PCL
                               ;PCL É UM REGISTRADOR QUE MONITORA OS ENDEREÇOS

;                   a
;                *********
;               *         *
;             f *         * b
;               *    g    *
;                *********
;               *         *
;             e *         * c
;               *    d    *
;                *********  *.

;               B'gfed cba'
        RETLW   B'11101110'    ;0
        RETLW   B'00101000'    ;1
        RETLW   B'11001101'    ;2
        RETLW   B'01101101'    ;3
        RETLW   B'00101011'    ;4
        RETLW   B'01100111'    ;5
        RETLW   B'11100111'    ;6
        RETLW   B'00101100'    ;7
        RETLW   B'11101111'    ;8
        RETLW   B'01101111'    ;9
        RETLW   B'10101111'    ;a
        RETLW   B'11100011'    ;b
        RETLW   B'11000110'    ;c
        RETLW   B'11101001'    ;d
        RETLW   B'11000111'    ;e
        RETLW   B'10000111'    ;f

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                              FIM DO PROGRAMA                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

        END                    ;OBRIGATÓRIO
