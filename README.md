## PICSimLab Exemplos

## McLab1

Esta é uma placa com o PIC16F628A, destinada aos usuários que estão começando no mundo do PIC.
Com ela você será capaz de realizar todas as experiências existentes no livro "Desbravando o PIC",
além de aperfeiçoar e inventar seus próprios experimentos.

## Exemplos do Curso

### Exemplo 01
```asm
;*---------------------------------------------------------------------------*
;* EXEMPLO 01 - CONTADOR CRESCENTE POR PULSOS COM DISPLAY DE 7 SEGMENTOS     *
;*---------------------------------------------------------------------------*
;* CONTADOR CRESCENTE DE 0 A F, APLICANDO PULSOS POSITIVOS NO BOTÃO RA4.     *
;* O VALOR DO CONTADOR DEVERÁ SER MOSTRADO EM UM DISPLAY DE 7 SEGMENTOS,     *
;* QUANDO O VALOR CHEGAR A F DEVERÁ VOLTAR A ZERO.                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
```

### Exemplo 02
```asm
;*---------------------------------------------------------------------------*
;* EXEMPLO 02 - CONTADOR POR PULSOS E TEMPORIZADOR                           *
;*---------------------------------------------------------------------------*
;* CONTADOR POR PULSOS ATÉ 3, APLICANDO PULSOS NEGATIOS EM RA1, AO CHEGAR    *
;* A ESSE VALOR DEVE ACIONAR UM LED QUE FICARÁ ACESO POR 5 SEGUNDOS E        *
;* EM SEGUIDA DESLIGAR O LED.                                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
```

### Exemplo 03
```asm
;*---------------------------------------------------------------------------*
;* EXEMPLO 03 - CONTROLE DE NÍVEL                                            *
;*---------------------------------------------------------------------------*
;* CONTROLE DE NÍVEL UTILIZANDO DOIS SENSORES, QUANDO O LÍQUIDO CHEGAR AO    *
;* NÍVEL MÁXIMO (RA4) DEVERÁ DESLIGAR A BOMBA, QUANDO CHEGAR AO NÍVEL        *
;* MÍNIMO (RA3) DEVERÁ LIGAR A BOMBA, E SE POR ALGUM MOTIVO À ÁGUA ABAIXAR   *
;* O NÍVEL MÍNIMO E CHEGAR AO NÍVEL CRÍTICO (RB0) DEVERÁ LIGAR O LED (RB2)   *
;* SIMULANDO UM ALARME UTILIZANDO INTERRUPÇÃO EM RB0.                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
```

### Exemplo 04
```asm
;*---------------------------------------------------------------------------*
;* EXEMPLO 04 - CONTADOR DECRESCENTE TEMPORIZADO                             *
;*---------------------------------------------------------------------------*
;* CONTADOR TEMPORIZADO, QUE DECREMENTA O VALOR A CADA UM SEGUNDO,           *
;* MOSTRANDO O VALOR NO DISPLAY 7 SEGMENTOS NO PORTB. (VALOR INICIAL = 9)    *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
```

### Exemplo 05
```asm
;*---------------------------------------------------------------------------*
;* EXEMPLO 05 - CONTROLE SIMPLES DE MOTOR DE PASSO                           *
;*---------------------------------------------------------------------------*
;* CONTROLE SIMPLES DE MOTOR DE PASSO COM DUAS VELOCIDADES PARA A DIREITA    *
;* E DUAS VELOCIDADES PARA A ESQUERDA.                                       *
;* RA1 - ESQUERDA RÁPIDO                                                     *
;* RA2 - ESQUERDA LENTO                                                      *
;* RA3 - DIREITA LENTO                                                       *
;* RA4 - DIREITA RÁPIDO                                                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
```

### Exemplo 06
```asm
;*---------------------------------------------------------------------------*
;* EXEMPLO 06 - ROTINA PARA ACIONAR A INTERRUPÇÃO RB0                        *
;*---------------------------------------------------------------------------*
;* ADICIONAR ALGUMA PARTE NO SIMULADOR PARA TESTAR MELHOR A ROTINA.          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
```

### Exemplo 07
```asm
;*---------------------------------------------------------------------------*
;* EXEMPLO 07 - ROTINA PARA ACIONAR A INTERRUPÇÃO RB0 E RB4                  *
;*---------------------------------------------------------------------------*
;* ADICIONAR ALGUMA PARTE NO SIMULADOR PARA TESTAR MELHOR A ROTINA.          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
```

### Exemplo 08
```asm
;*---------------------------------------------------------------------------*
;* EXERCÍCIO 08 - ROTINA PARA ACIONAR A INTERRUPÇÃO RB0 E RB4                *
;*---------------------------------------------------------------------------*
;* ADICIONAR ALGUMA PARTE NO SIMULADOR PARA TESTAR MELHOR A ROTINA.          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
```

### Exemplo 09
```asm
;*---------------------------------------------------------------------------*
;* EXERCÍCIO 09 - ROTINA PARA ACIONAR O LED APÓS 250MS AO LIGAR O PIC        *
;*---------------------------------------------------------------------------*
;* AUMENTAR O TEMPO PARA CONSEGUIR VISUALIZAR MELHOR O ACIONAMENTO DO LED    *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
```
