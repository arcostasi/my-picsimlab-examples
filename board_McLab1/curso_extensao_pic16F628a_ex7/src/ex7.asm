;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* UNICESUMAR - MARING�                                                      *
;* CURSO DE EXTENS�O EM MICROCONTROLADORES PIC                               *
;* PROFESSOR EMERSON MARTINS                                                 *
;*---------------------------------------------------------------------------*
;* EXEMPLO 07 - ROTINA PARA ACIONAR A INTERRUP��O RB0 E RB4                  *
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
#DEFINE LED2    PORTB,2


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

        ORG     0x04           ;ENDERE�O INICIAL DA INTERRUP��O
        PUSH
        CALL    ISR_INT_HANDLE
        POP
        RETFIE


INICIO
        CLRF    PORTA
        CLRF    PORTB

        BANK1
        MOVLW   B'00000110'      ;SETA AS ENTRADAS NO PORTA
        MOVWF   TRISA
        MOVLW   B'01111011'      ;SETA AS SA�DAS NO PORTB
        MOVWF   TRISB

        ; BIT 3 -
        ; BIT 4 - TOSE
        ; BIT 5 -
        ; OS 5 PRIMEIROS BITS S�O EM RELA��O AO TIMER 0

        ; BIT 6 - CONFIGURA��O DA BORDA DO RB0
        ; BIT 7 -

        MOVLW   B'11000000'
        MOVWF   OPTION_REG

        ; BIT 0, 1, 2 GERADORES DE FLAG OU SINALIZADORES
        ; BIT 1 - FLAG DE INTERRUP��O DO RB0
        ; BIT 2 - FLAG DE INTERRUP��O DO TMR0
        ; BIT 3 - HABILITA��O DO RB4 - 0 DESLIGA E 1 LIGA
        ; BIT 5 - TOSE
        ; BIT 7 - CHAVE GERAL

        ; BIT   B'76543210
        MOVLW   B'10011000'
        MOVWF   INTCON
        BANK0

LOOP
        GOTO    LOOP

ISR_INT_HANDLE
        BTFSC   INTCON,0
        CALL    ISR_PORTB
        BTFSC   INTCON,1
        CALL    ISR_INT
        BTFSC   INTCON,2
        CALL    ISR_TMR0

SAIDA_ISR
        RETURN

ISR_PORTB
        BCF    INTCON,0
        BSF    LED2
        RETURN

ISR_INT
        BCF     INTCON,1
        BSF     LED
        RETURN

ISR_TMR0
        BCF     INTCON,2
        RETURN


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

        END                    ;OBRIGAT�RIO
