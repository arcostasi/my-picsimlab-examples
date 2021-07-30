;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* UNICESUMAR - MARING�                                                      *
;* CURSO DE EXTENS�O EM MICROCONTROLADORES PIC                               *
;* PROFESSOR EMERSON MARTINS                                                 *
;*---------------------------------------------------------------------------*
;* EXERC�CIO 08 - ROTINA PARA ACIONAR A INTERRUP��O RB0 E RB4                *
;* DESENVOLVIDO POR ANDERSON COSTA                                           *
;* VERS�O 1.0                                               DATA: 30/06/2007 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                          ARQUIVOS DE DEFINI��ES                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#INCLUDE <P16F628A.INC>        ;ARQUIVO PADR�O MICROCHIP PARA 16F628A
        __CONFIG  _BODEN_ON & _CP_OFF & _PWRTE_ON & _WDT_OFF & _LVP_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           PAGINA��O DE MEM�RIA                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINI��O DE COMANDOS DE USU�RIO PARA ALTERA��O DA P�GINA DE MEM�RIA

#DEFINE BANK0   BCF STATUS,RP0 ;SETA BANK 0 DE MEM�RIA
#DEFINE BANK1   BSF STATUS,RP0 ;SETA BANK 1 DE MAM�RIA


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                                 VARI�VEIS                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DOS NOMES E ENDERE�OS DE TODAS AS VARI�VEIS UTILIZADAS
; PELO SISTEMA

        CBLOCK  0X20
                CONTADOR
                CONTADOR2
                W_TEMP
                STATUS_TEMP
                PCLATH_TEMP
        ENDC


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                              VETOR DE RESET                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

        ORG     0x00           ;ENDERE�O INICIAL DE PROCESSAMENTO
        GOTO    INICIO


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                                 ENTRADAS                                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

#DEFINE BOT     PORTA,1
#DEFINE BOT2    PORTA,2

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                                  SA�DAS                                   *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO SA�DA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

#DEFINE LED     PORTB,7
#DEFINE LED2    PORTB,6


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                                  MACROS                                   *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

PUSH MACRO                     ;ROTINA QUE SALVA O ESTADO DO PROGRAMA
        MOVWF   W_TEMP
        SWAPF   STATUS,W
        CLRF    STATUS
        MOVF    PCLATH,W
        CLRF    PCLATH
        ENDM

POP MACRO                      ;ROTINA QUE RETORNA O ESTADO DO PROGRAMA
        MOVF    PCLATH_TEMP,W
        MOVWF   PCLATH
        SWAPF   STATUS_TEMP,W
        MOVWF   STATUS
        SWAPF   W_TEMP,F
        SWAPF   W_TEMP,W
        ENDM


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           IN�CIO DA INTERRUP��O                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

        ORG     0x04            ; ENDERE�O INICIAL DA INTERRUP��O
        PUSH
        CALL    ISR_INT_HANDLE
        POP
        RETFIE


INICIO
        CLRF    PORTA
        CLRF    PORTB

        BANK1
        MOVLW   B'00000110'    ;DEFINE ENTRADAS E SA�DAS DO PORTA
        MOVWF   TRISA
        MOVLW   B'00111011'    ;DEFINE ENTRADAS E SA�DAS DO PORTB
        MOVWF   TRISB

        ; OS 5 PRIMEIROS BITS S�O EM RELA��O AO TIMER 0
        ; BIT 0 -
        ; BIT 1 -
        ; BIT 2 -
        ; BIT 3 -
        ; BIT 4 - TOSE
        ; BIT 5 -
        ; BIT 6 - CONFIGURA��O DA BORDA DO RB0
        ; BIT 7 - HABILITA��O DO PULL-UP, ONDE 1 HABILITA E 0 DESABILITA

        MOVLW   B'01000001'
        MOVWF   OPTION_REG     ;DEFINE OP��ES DE OPERA��O

        ; BIT 0, 1, 2 GERADORES DE FLAG OU SINALIZADORES
        ; BIT 0 -
        ; BIT 1 - FLAG DE INTERRUP��O DO RB0
        ; BIT 2 - FLAG DE INTERRUP��O DO TMR0
        ; BIT 3 - HABILITA��O DO RB4, ONDE 1 HABILITA E 0 DESABILITA
        ; BIT 4 -
        ; BIT 5 - HABILITA��O DO TIMER 0, ONDE 1 HABILITA E 0 DESABILITA
        ; BIT 6 -
        ; BIT 7 - CHAVE GERAL

        ; BIT   76543210
        MOVLW   B'10111000'
        MOVWF   INTCON
        BANK0

MAIN
        MOVLW   .6
        MOVWF   TMR0
        MOVLW   .100
        MOVWF   CONTADOR
        MOVLW   .20
        MOVWF   CONTADOR

LOOP
        GOTO    LOOP

ISR_INT_HANDLE
        BTFSC   INTCON,0
        CALL    ISR_PORTB
        BTFSC   INTCON,1
        CALL    ISR_INT
        BTFSC   INTCON,2
        CALL    ISR_TMR0

ISR_SAIDA
        RETURN

ISR_PORTB
        BCF     INTCON,0
    BSF LED2
        RETURN

ISR_INT
        BCF     INTCON,1
        BSF LED
        RETURN

ISR_TMR0
        BCF     INTCON,2
        DECFSZ  CONTADOR
        GOTO    CARREGA_TMR0
        GOTO    DEC_2

CARREGA_TMR0
        MOVLW .6
        MOVWF TMR0
        RETURN

DEC_2
        DECFSZ  CONTADOR2
        GOTO    CARREGA_CONT
        BCF     LED
        BCF     LED2
        RETURN

CARREGA_CONT
        MOVLW   .100
        MOVWF   CONTADOR
        MOVLW   .6
        MOVWF   TMR0
        RETURN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

        END                     ;OBRIGAT�RIO

