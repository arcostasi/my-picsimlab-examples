;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* UNICESUMAR - MARING�                                                      *
;* CURSO DE EXTENS�O EM MICROCONTROLADORES PIC                               *
;* PROFESSOR EMERSON MARTINS                                                 *
;*---------------------------------------------------------------------------*
;* EXEMPLO 01 - CONTADOR CRESCENTE POR PULSOS COM DISPLAY DE 7 SEGMENTOS     *
;* DESENVOLVIDO POR ANDERSON COSTA                                           *
;* VERS�O 1.0                                               DATA: 09/06/2007 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* CONTADOR CRESCENTE DE 0 A F, APLICANDO PULSOS POSITIVOS NO BOT�O RA1      *
;* O VALOR DO CONTADOR DEVER� SER MOSTRADO EM UM DISPLAY DE 7 SEGMENTOS,     *
;* QUANDO O VALOR CHEGAR A F DEVER� VOLTAR A ZERO.                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                          ARQUIVOS DE DEFINI��ES                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;LIST      p=16F628A    ;DIRETIVA PARA DEFINIR O PROCESSADOR
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

        CBLOCK  0X20           ;ENDERE�O INICIAL DA MEM�RIA
                ANTDEB
                ANTDEB2
                CONTADOR
        ENDC                   ;FIM DO BLOCO DE MEM�RIA


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                                CONSTANTES                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* DEFINI��O DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

MAX             EQU     .16    ;VALOR M�XIMO PARA O CONTADOR

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                                 ENTRADAS                                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO ENTRADA
;* SEGUE ABAIXO DE CADA DEFINI��O O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

#DEFINE BOTAO   PORTA,1        ;PORTA DO BOT�O
                               ; 0 -> LIBERADO
                               ; 1 -> PRESSIONADO


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                                  SA�DAS                                   *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO SA�DA
;* SEGUE ABAIXO DE CADA DEFINI��O O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

#DEFINE DISPLAY PORTB          ;DISPLAY PARA CONTADOR


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
                               ;RA1 COMO ENTRADA, OS OUTROS PINOS COMO SA�DA

        MOVLW   B'00000000'    ;MOVE LITERAL BIN�RIO PARA WORK
        MOVWF   TRISB          ;DEFINI��O DE ENTRADA E SA�DA DO PORTB
                               ;TODOS OS PINOS COMO SA�DA PARA O DISPLAY

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
        CLRF    ANTDEB         ;LIMPA O REGISTRADOR ANTDEB
        CLRF    ANTDEB2        ;LIMPA O REGISTRADOR ANTDEB2
        CLRF    CONTADOR       ;LIMPA O CONTADOR

CONVERSAO
        MOVF    CONTADOR,W     ;MOVE O VALOR DO CONTADOR PARA W
        CALL    CONVERTE       ;CHAMA A ROTINA DE CONVERS�O PARA 7 SEGMENTOS
        MOVWF   DISPLAY        ;MOVE O VALOR DE W J� CONVERTIDO EM 7 SEGMENTOS
                               ;PARA DISPLAY (PORTB)

BOTAO_PRESS
        BTFSC   BOTAO          ;TESTA O BOT�O PARA DETECTAR SE EST� PRESSIONADO
        GOTO    BOTAO_PRESS    ;BOT�O N�O PRESSIONADO, CONTINUA TESTANDO
        GOTO    FILTRO         ;BOT�O PRESSIONADO, V� PARA A ROTINA DE FILTRO

FILTRO
        DECFSZ  ANTDEB,1       ;DECREMENTA O REGISTRADOR ANTDEB E
                               ;PULA UMA LINHA SE FOR ZERO
        GOTO    FILTRO         ;RESULTADO DO DECREMENTO DIFERENTE DE ZERO,
                               ;CONTINUA DECREMENTANDO
        GOTO    FILTRO2        ;RESULTADO DO DECREMENTO DE ANTDEB IGUAL A
                               ;ZERO V� PARA FILTRO2

FILTRO2
        DECFSZ  ANTDEB2,1      ;DECREMENTA O REGISTRADOR ANTDEB2 E PULA
                               ;UMA LINHA SE FOR ZERO
        GOTO    FILTRO2        ;RESULTADO DO DECREMENTO DIFERENTE DE ZERO,
                               ;CONTINUA DECREMENTANDO
        GOTO    INCREMENTA     ;RESULTADO DO DECREMENTO DE ANTDEB2 IGUAL A ZERO
                               ;V� PARA INCREMENTA

INCREMENTA
        INCF    CONTADOR,F     ;INCREMENTA O CONTADOR E GUARDA O RESULTADO
                               ;NELE MESMO
        MOVLW   MAX            ;MOVE A CONSTANTE M�XIMA DO CONTADOR PARA W
        XORWF   CONTADOR,W     ;FAZ A LOGICA XOR ENTRE CONTADOR E W
        BTFSS   STATUS,Z       ;TESTA O FLAG Z, PARA DETECTAR SE O VALOR
                               ;DO CONTADOR � IGUAL AO VALOR DE W
        GOTO    BOTAO_LIB      ;FLAG Z, DIFERENTE DE ZERO, VAI PARA
                               ;TESTE DO BOT�O LIBERADO
        GOTO    MAIN           ;FLAG Z EM 1, LOGO O CONTADOR � IGUAL A W,
                               ;VOLTA PARA MAIN

BOTAO_LIB
        BTFSS   BOTAO          ;TESTA O BOT�O PARA DETECTAR SE FOI LIBERADO
        GOTO    BOTAO_LIB      ;BOT�O AINDA N�O LIBERADO,
                               ;CONTINUA TESTANDO O MESMO
        GOTO    CONVERSAO      ;SE LIBERADO, V� PARA ROTINA CONVERS�O

CONVERTE
        ADDWF   PCL,F          ;ADICIONA O VALOR DE W AO REGISTRADOR PCL
                               ;PCL � UM REGISTRADOR QUE MONITORA OS ENDERE�OS

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

        END                    ;OBRIGAT�RIO
