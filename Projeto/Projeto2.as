;Projeto de IAC

;Afonso Ribeiro 89400
;Margarida Ferro 86375


SP_INICIAL 		EQU 		FDFFh 
JANELA	   		EQU			FFFEh
JANELA_CTR		EQU			FFFCh
MASCARA    		EQU			8016h   ;Mascara para o numero aleatorio
INT_MASK_ADDR 	EQU 		FFFAh
INT_MASK 		EQU 		0000010000000000b
INT_MASK2		EQU			1000010001111110b
DISPLAY	  		EQU 		FFF0h
DISPLAY2		EQU			FFF1h
LCD		   		EQU			FFF5h
LCD_CONTROL		EQU 		FFF4h
LCD_INI			EQU    		1000000000000001b
LCD_CONTROLL	EQU			1000000000000010b
FIM_STR			EQU			'@'
TIME_CONT		EQU			FFF6h
TIME_CTRL		EQU			FFF7h
LEDS			EQU			FFF8h

;Definir interrupcoes

		ORIG FE01h
INT1	WORD	INT1F
INT2	WORD	INT2F
INT3	WORD	INT3F
INT4	WORD	INT4F
INT5	WORD	INT5F
INT6	WORD	INT6F
OLA		TAB 	3
INTIA	WORD 	INT_IA   ; Botao IA
OLA2	TAB 	4
INTT	WORD	INT_TEMP

        ORIG 8000h
INICIAL    		TAB 		1						;Espaco na memoria para o numero do jogador (Em 12 bits, 3 bits para cada algarismo)				
FINAL      		TAB         1       				;Espaco na memoria para os 'x','o' e '-' (Codificados em 1,2,3 respetivamente)
SECRETO			TAB			1						;Espaco na memoria para o numero secreto
Jogadas	   		TAB			1						;Contador do numero de jogadas realizadas ate ao momento
LCD_Melhor	   	TAB			1						;Melhor resultado ate ao momento
CURSOR			TAB			1						;Posicao atual do cursor
TICK			TAB			1						;Numero de intervalos de 500ms
LEDSS			TAB			1						;Estado dos Leds
GAME_OVER		TAB			1						;Quando estiver com o valor 1, o jogador ficou sem tempo, logo salta-se a parte do LCD e nao se contabiliza a pontuacao do respetivo jogo
MENSAGEM   		STR			'Carregue no Botao IA para Iniciar',FIM_STR
MENSAGEM_F		STR			'Fim do Jogo!',FIM_STR
MENSAGEM_R		STR			'Carregue no Botao IA para Recomecar',FIM_STR		

;Atribuicoes Iniciais

		ORIG 0000h
		MOV   R7,SP_INICIAL	
		MOV	  SP,R7
		MOV   R7,FFFFh
		MOV   M[JANELA_CTR],R7
		MOV   R7,INT_MASK
		MOV   M[INT_MASK_ADDR],R7
		MOV   M[DISPLAY],R0
		MOV   R7,LCD_INI
		MOV   M[LCD_CONTROL],R7
		ENI
		JMP   PRE_IA


;	;	;	;  	INTERRUPCOES	;	;	;	;			 

		
;Interrupcao inicio de jogo --> Preenche a janela de texto com espacos e comeca/recomeca o jogo


INT_IA: 	 PUSH 	R2							;Guarda o valor incrementado inicial
			 PUSH 	R6
			 PUSH 	R7
			 MOV 	R7,R0
Colunas:	 MOV 	R6,R0
			 MVBL 	R6,R7						;Pega no octeto de menor peso de R7 (Ou seja, o ponteiro das colunas da janela de texto)		
			 CMP 	R6,004Fh					;79 Colunas
			 BR.Z 	Linhas
			 MOV 	M[JANELA_CTR],R7
			 MOV 	R6,' '						
			 MOV 	M[JANELA],R6
			 INC 	R7							;Passa para a proxima coluna
			 BR 	Colunas
Linhas:		 MOV 	R6,R0
			 MVBH 	R6,R7	 					;Pega no octeto de maior peso de R7 (Ou seja, o ponteiro das linhas da janela de texto)
			 CMP 	R6,1800h					;24 Linhas
			 BR.Z 	Fim_IA
			 AND  	R7,FF00h
			 ADD  	R7,0100h					;Passa para a linha de baixo
			 MOV  	M[JANELA_CTR],R7
			 MOV  	R6,' '
			 MOV  	M[JANELA],R6
			 BR 	Colunas			
Fim_IA:		 ENI
			 MOV 	M[JANELA_CTR],R0			;Coloca o cursor na primeira posicao
			 MOV 	M[CURSOR],R0
			 MOV 	R7,INT_MASK2
			 MOV 	M[INT_MASK_ADDR],R7			;Ativa os botoes 1,2,3,4,5,6 e 15 para a escrita do numero do utilizador + Temporizador
			 POP 	R7
			 POP 	R6
			 JMP 	Jogo_Novo
			 
;Interrupcao temporizador

INT_TEMP:	PUSH 	R7

			MOV   	R7,M[TICK]		
			INC   	R7
			MOV   	M[TICK],R7
			
			MOV   	R7,M[LEDSS]
			SHR	  	R7,1						;Apaga o Led mais a esquerda
			MOV   	M[LEDSS],R7					;Memoria que guarda o valor dos Leds
			MOV   	M[LEDS],R7					;Porto de controlo dos Leds
	
			MOV   	R7,5						;O temporizador e ativado aos 5 interrvalos de 100ms, ou seja 500ms
			MOV  	M[TIME_CONT],R7				
			MOV  	R7,1
			MOV   	M[TIME_CTRL],R7				;Ativa o temporizador
			POP 	R7
			RTI

;Interrupcoes de Introducao do numero do utlizador 
;Int1 --> Coloca o algarismo 1 na posicao atual respetiva
;Int2 --> Coloca o algarismo 2 na posicao atual respetiva
;... 

INT1F:		PUSH R1
			MOV R1,M[INICIAL]
			ROL	R1,3
			ADD R1,1
			MOV M[INICIAL],R1
			POP R1
			RTI

INT2F:		PUSH R1
			MOV R1,M[INICIAL]
			ROL	R1,3
			ADD R1,2
			MOV M[INICIAL],R1
			POP R1
			RTI

INT3F:		PUSH R1
			MOV R1,M[INICIAL]
			ROL	R1,3
			ADD R1,3
			MOV M[INICIAL],R1
			POP R1
			RTI
			
INT4F:		PUSH R1
			MOV R1,M[INICIAL]
			ROL	R1,3
			ADD R1,4
			MOV M[INICIAL],R1
			POP R1
			RTI

INT5F:		PUSH R1
			MOV R1,M[INICIAL]
			ROL	R1,3
			ADD R1,5
			MOV M[INICIAL],R1
			POP R1
			RTI

INT6F:		PUSH R1
			MOV R1,M[INICIAL]
			ROL	R1,3
			ADD R1,6
			MOV M[INICIAL],R1
			POP R1
			RTI
						

;	;	;	; 	INICIO	;	;	;	;

			
;Atualiza o LCD, a partir do final do primeiro jogo, com a melhor pontuacao ate ao momento	
;No inicio do primeiro jogo, esta parte do codigo e ignorada
			
LCD1:		MOV 	R7,M[GAME_OVER]		;Quando estiver com o valor 1, o jogador ficou sem tempo ou nao acertou nas 12 jogadas, logo salta-se a parte do LCD
			CMP 	R7,1
			JMP.Z	RReset
			CMP 	M[LCD_Melhor],R0	;Se nao houver melhor pontuacao, a melhor pontuacao é a da jogada atual, logo salta-se a parte das comparacoes
			BR.NZ 	LCD1_Aux
			MOV 	R7,M[Jogadas]
			BR 		LCD2_Aux
LCD1_Aux:	MOV 	R7,M[Jogadas]		;Compara a pontuacao atual com a melhor
			CMP 	R7,M[LCD_Melhor]
			JMP.P 	RReset				
LCD2_Aux:	MOV 	M[LCD_Melhor],R7	;Substitui a melhor pela atual
			MOV 	R6,10				;Ao fazer a divisao da pontuacao em hexadecimal por 10, ficamos com o equivalente em decimal 
			DIV 	R7,R6				;O primeiro algarismo da pontuacao fica no resultado (R7) e o segundo no resto (R6)
			ADD 	R7,'0'				;Coloca o valor em ASCII
			ADD 	R6,'0'
			MOV 	M[LCD],R7
			MOV 	R5,LCD_CONTROLL		;Escolhe a segunda coluna do LCD
			MOV 	M[LCD_CONTROL],R5
			MOV 	M[LCD],R6
			JMP 	RReset
			
;Escreve "Carregue no botao IA para iniciar" na janela de texto
					
PRE_IA:		MOV R7, MENSAGEM 		; R7 ponteiro para o caracter actual 
			MOV R3,R0
Mensagem:	MOV R2,M[R7]        
			CMP R2,FIM_STR
			BR.Z RReset				;Se for igual, cheguei ao fim da string 
			MOV M[JANELA],R2
			INC R3					;Incrementa o ponteiro da string
			MOV M[JANELA_CTR],R3	
			INC R7					;Incrementa a coluna na janela
			BR Mensagem
			
;Fica em loop ate se carregar em IA
			
RReset:		MOV  R2,R0				
Reset:		INC  R2					;Numero usado para gerar o numero pseudo-aleatorio
			BR	 Reset         

;Inicia um novo jogo

Jogo_Novo:	MOV   M[Jogadas],R0			;Reset a pontuacao
			MOV   M[DISPLAY],R0			;0 no display da pontuacao
			MOV   M[DISPLAY2],R0		;0 no segundo display da pontuacao
			MOV   M[GAME_OVER],R0		
			MOV   R7,LCD_INI
			MOV   M[LCD_CONTROL],R7
			PUSH  R0					;Guarda espaco na pilha para o numero pseudo-aleatorio que ira ser gerado
			Call  Random          		;Chama a sub-rotina que gera um valor secreto pseudo-aleatorio
			POP   R1					;Coloca o número pseudo-aleatorio gerado em R1
			MOV   M[SECRETO],R1
			
;Inicia uma nova jogada
	
Inicio:		MOV   M[FINAL],R0			;Reset a pontuacao final
			MOV   M[INICIAL],R0			;Reset ao numero inicial
			MOV   R7,R0

;Preenche os 12 bits do resultado com tracos (Podem ser mais tarde substituidos por x ou o)

Tracos: 	CMP 	R7,001100110100b     	 ;Numero imediatamente a seguir ao equivalente a 3 tracos, logo testa se foram preenchidos menos de 3 tracos
			BR.P 	I_Temp					 ;Se ja foram preenchidos os 4 tracos, avanca no programa
			MOV 	R7,M[FINAL]
			ROL		R7,3
			ADD 	R7,3					 ;Codigo para escolhido para  - : 3 (Mais tarde e descodificado)
			MOV 	M[FINAL],R7
			BR 		Tracos		

;Ativacao do Temporizador

I_Temp: MOV	  M[TICK],R0
		MOV   R7,FFFFh
		MOV   M[LEDS],R7			;Porto dos Leds
		MOV   M[LEDSS],R7			;Memoria que guarda o valor dos Leds
		MOV   R7,5					;5 = 5 x 100ms, logo a interrupcao do temporizador ativa apos 500ms
		MOV   M[TIME_CONT],R7
		MOV   R7,1					;Ativa o temporizador
		MOV   M[TIME_CTRL],R7	
	
;Fica a espera que o utilizador meta os numeros

Loop_User:	 MOV   	 	R7,M[TICK]					;Testa se o tempo acabou, ou seja, se ja passaram 16 intervalos de 500ms (Equivalente aos LEDs todos se desligarem)
		     CMP	   	R7,16	
		     JMP.Z 		Times_Up					;Se o tempo acabou, o jogo acaba
			 MOV 		R1,M[INICIAL]
			 CMP 		R1,111111111b               ;Se o valor em memoria for menor que este numero, significa que ainda so foram introduzidos no maximo 3 algarismos
			 BR.NP 		Loop_User					;Fica em loop ate serem introduzidos os 4 algarismos 
			 
		
;Codigo que mete os algarismos do numero secreto na pilha
		
		MOV   R1,M[SECRETO]
		AND   R1,0007h              ;Fica apenas com o ultimo algarismo
		PUSH  R1
		MOV	  R1,M[SECRETO]
		SHR   R1,3                  ;Coloca o 3 algarismo como 4 algarismo
		AND	  R1,0007h           
		PUSH  R1
		MOV   R1,M[SECRETO]
		SHR   R1,6					;Coloca o 2 algarismo como 4 algarismo
		AND	  R1,0007h
		PUSH  R1
		MOV   R1,M[SECRETO]
		SHR   R1,9					;Coloca o 1 algarismo como 4 algarismo 
		PUSH  R1	
		
		
;Codigo que mete os algarismos do numero introduzido pelo utilizador na pilha
		
		
		MOV   R2,M[INICIAL]
		AND	  R2,0007h   
		PUSH  R2	
		MOV   R2,M[INICIAL]
		SHR   R2,3
		AND	  R2,0007h
		PUSH  R2
		MOV   R2,M[INICIAL]
		SHR   R2,6
		AND	  R2,0007h
		PUSH  R2
		MOV   R2,M[INICIAL]
		SHR   R2,9
		AND	  R2,0007h
		PUSH  R2
		
;Corpo do programa, que chama as varias rotinas

				CALL 	Xis					
				CALL  	Bola		
				CALL  	Fim_Ciclo
				MOV   	R7,M[FINAL]
				CMP   	R7,0249h 				 ;Codigo para 4 x's, se o resultado final for igual a este valor, o jogador acertou no numero
				JMP.Z 	Mensagem_Fim
				MOV   	R6,M[Jogadas]
				CMP   	R6,12                  	 ;Se ja tiverem sido feitas 12 jogadas, acaba a execucão do programa
				JMP.NZ Inicio
				JMP 	Times_Up
				
;Quando acaba o tempo de jogada (Ou nao se acerta nas 12 jogadas), nao se quer contabilizar a pontuacao atual

Times_Up:			MOV R7,1
					MOV M[GAME_OVER],R7     	 ;Se esta variavel em memoria estiver ativa, salta-se a parte do LCD, logo nao se contabiliza a pontuacao do jogo atual
		
; Mensagem "Fim do Jogo", "Carregue em IA para recomecar" e desativa o temporizador		
Mensagem_Fim:		PUSH R7
					PUSH R3
					PUSH R2
					PUSH R6
					
					MOV  R7,0
					MOV  M[TIME_CTRL],R7	;Desativa o temporizador
					MOV  R7,0			
					MOV  M[LEDS],R7			;Reset aos LEDs
					
					MOV  R7,MENSAGEM_F 		;R7 ponteiro para o caracter da string "Fim de Jogo!"
					MOV  R6,MENSAGEM_R		;R6 ponteiro para o caracter da string "Carregue em IA para recomecar"
					MOV  R3,0C00h			;Linha pre-definida na janela para aparecer a mensagem "Fim de Jogo!"
Mensagem_F:			MOV  R2,M[R7]        	;Move o caracter atual para R2
					CMP  R2,FIM_STR
					BR.Z Mensagem_R			;Se for igual, cheguei ao fim da string 
					MOV  M[JANELA_CTR],R3
					MOV  M[JANELA],R2
					INC  R3					;Avanca 1 posicao de coluna na janela de texto
					INC  R7					;Incrementa o ponteiro, ou seja, passa para o proximo caracter
					BR   Mensagem_F
Mensagem_R:			MOV  R3,0D00h			;Linha pre-definida na janela para aparecer a mensagem "Carregue em IA para recomecar"
Mensagem_R_Aux:		MOV  R2,M[R6]
					CMP  R2,FIM_STR
					BR.Z Mensagem_FimFim	
					MOV  M[JANELA_CTR],R3
					MOV  M[JANELA],R2
					INC  R3
					INC  R6
					BR   Mensagem_R_Aux
Mensagem_FimFim:	POP  R6
					POP  R2
					POP  R3
					POP  R7
					JMP  LCD1							;Fim: Proximo jogo					


;Codigo que testa se ha numeros no sitio certo e coloca 'x' no endereco de memoria reservado inicialmente

Xis: 	  PUSH R4
		  PUSH R6
		  PUSH R7
		  MOV R6,R0
		  MOV R4,SP
		  
Xis_Aux:  CMP R6,4				;Quando for igual a 4, ja foram testados os 4 algarismos
		  BR.NZ Xis_Next
		  POP R7
		  POP R6
		  POP R4
		  RET
		  
Xis_Next: MOV R2,M[R4+5]        ;Mete em R2 o primeiro algarismo do número do jogador
		  CMP R2,M[R4+9]        ;Compara o primeiro algarismo do número secreto com o primeiro algarismo do número do jogador
		  BR.NZ Xis_Final        ;Se não forem iguais, salta para a proxima comparacão
		  MOV R7,M[FINAL]
		  SHL R7,3
		  ADD R7,1                
		  AND R7,0FFFh			;Volta a deixar o resultado com 12 bits
		  MOV M[FINAL],R7
		  MOV M[R4+9],R0        ;Se for 'x', mete o algarismo correspondente a 0 (Para mais tarde não contabilizar como 'o')	  
		  MOV M[R4+5],R0		;Tambem mete o algarismo do numero do utilizador a 0 (Para nao ser sequer considerado no CicloBola)
		  
Xis_Final:INC R4				;Incrementa a posicao do novo 'SP' (R4)
		  INC R6				;Contador dos 4 algarismos 
		  JMP Xis_Aux



;Codigo que testa os 'o', ou seja, testa se ha algarismos certos, mas em posicões erradas		  
		  
Bola: 		PUSH  R4	 	;Primeiro substituto do SP
			PUSH  R1  		;Segundo substituto do SP	
			PUSH  R6  		;Primeiro contador
			PUSH  R3  		;Segundo contador
			PUSH  R2
			MOV   R6,R0
			MOV   R1,SP

Bola_Loop:	CMP   R6,4
			BR.NZ Bola_Aux
			POP   R2
			POP   R3
			POP   R6
			POP   R1
			POP   R4
			RET
			
Bola_Aux:	MOV   R4,SP								
			MOV   R3,0
			MOV   R2,M[R1+7]			;Coloca o algarismo do utilizador atual em R2
			CMP   R2,R0					;Se o algarismo do utilizador for 0, ja foi contabilizado como X mais cedo, logo passa-se para o proximo
			BR.NZ Bola_Loop2
			INC   R1					;Avanca para o proximo algarismo do utilizador na pilha
			INC   R6					;Contador dos algarismos do utilizador (Vai ate 4)
			BR    Bola_Loop
						
Bola_Loop2:	CMP   R3,4					;Se o contador das comparacoes for 4, ja se comparou o algarismo atual com todos os algarismos do numero secreto
			BR.NZ Bola_Aux2
			INC   R1					;Avanca para o proximo algarismo do utilizador na pilha
			INC   R6					;Contador dos algarismos do utilizador (Vai ate 4)
			JMP   Bola_Loop			
			
Bola_Aux2:	CMP   R2,M[R4+11]			;Compara o algarismo do utilizador atual com os 4 algarismos do numero secreto (Um de cada vez)
			BR.NZ Bola_Final			;Se uma das comparacoes der 0, significa que esse algarismo existe, mas esta na posicao errada (Contabiliza-se como 'o')
			MOV   R7,M[FINAL]
			SHL   R7,3					;"Arrasta" um dos '-' metidos inicialmente no resultado final para a esquerda (Para deixar espaco na direita para o 'o')
			ADD   R7,2                
			AND   R7,0FFFh				;Volta a meter o resultado final com 12 bits (Apaga o traco mais a esquerda)
			MOV   M[FINAL],R7
			MOV   M[R4+11],R0		    ;Muda o valor do algarismo do número secreto respetivo para 0, para não voltar a ser contabilizado
			INC   R1					;Avanca para o proximo algarismo do utilizador na pilha
			INC   R6					;Contador dos algarismos do utilizador (Vai ate 4)
			JMP   Bola_Loop
			
Bola_Final: INC   R4					;Avanca para a proxima comparacao, ou seja, para o proximo algarismo do numero secreto
			INC   R3					;Contador do numero de comparacoes (Vai ate 4)
			JMP   Bola_Loop2
			
			
;Codigo que descodifica o resultado e o coloca na janela de texto
;		x = 1 = 001b
;		o = 2 = 010b
;		- = 3 = 011b
		
Fim_Ciclo:	PUSH 	R7
			PUSH 	R5					
			PUSH 	R4					
			PUSH 	R6
			MOV 	R5,R0				 ;Contador
			MOV 	R4,M[FINAL]			 ;Guarda o resultado final codificado
			BR 		Primeiro_F
			
Loop_F:		CMP 	R5,4				 ;Se for igual a 4, ja foram descodificados os 4 "algarismos" do resultado
			JMP.Z  	Fim_F
			SHR 	R4,3				 ;Se nao, passa-se para o proximo "algarismo"
Primeiro_F:	MOV 	R7,R4
			AND 	R7,0007h			 ;Ficamos so com os ultimos 3 bits do resultado
			CMP 	R7,2				 ;Compara-se o "algarismo" atual com 2
			BR.N  	Res_X				 ;Se a comparacao for negativa, o valor do algarismo e 1 (X)
			BR.Z  	Res_O				 ;Se a comparacao der zero, o valor do algarismo e 2 (O)
			BR.P  	Res_Traco			 ;Se a comparacao for positiva, o valor do algarismo e 3(-)
Res_X:		MOV 	R7,'x'				
			MOV 	M[JANELA],R7		 ;Coloca 'x' na janela de texto
			MOV 	R7,M[CURSOR]
			ADD 	R7,1				 ;Avanca o cursor 1 posicao de coluna na janela de texto
			MOV 	M[JANELA_CTR],R7
			MOV 	M[CURSOR],R7
			INC 	R5
			JMP 	Loop_F	
Res_O:		MOV 	R7,'o'				 ;Coloca 'o' na janela de texto
			MOV 	M[JANELA],R7
			MOV 	R7,M[CURSOR]
			ADD 	R7,1
			MOV 	M[JANELA_CTR],R7	 ;Avanca o cursor 1 posicao de coluna na janela de texto
			MOV 	M[CURSOR],R7
			INC 	R5
			JMP 	Loop_F	
Res_Traco:	MOV 	R7,'-'				 ;Coloca '-' na janela de texto
			MOV 	M[JANELA],R7
			MOV 	R7,M[CURSOR]
			ADD 	R7,1
			MOV 	M[JANELA_CTR],R7	 ;Avanca o cursor 1 posicao de coluna na janela de texto
			MOV		M[CURSOR],R7
			INC 	R5
			JMP 	Loop_F			
			
Fim_F:		MOV 	R6,M[Jogadas]
			INC 	R6                   ;Incrementa o contador das 12 jogadas
			MOV 	M[Jogadas],R6
			MOV 	R7,10				 
			DIV 	R6,R7				 ;Converte a jogada atual para decimal
			MOV 	M[DISPLAY],R7		 ;Coloca o resto no primeiro display (a contar da direita)
			MOV	 	M[DISPLAY2],R6		 ;Coloca o resultado no segundo display (a contar da direita)
			MOV 	R7,M[CURSOR]
			AND 	R7,FF00h			 ;Coloca o cursor na posicao 0 das colunas
			ADD 	R7,0100h			 ;Avanca o cursor 1 linha 
			MOV 	M[JANELA_CTR],R7
			MOV 	M[CURSOR],R7
			POP 	R6
			POP 	R4
			POP 	R5
			POP 	R7	
			RETN 	8					 ;Apaga os algarismos do numero do utilizador e do numero secreto da pilha 

			
;Funcao que gera um pseudo-aleatorio, tal como demonstrado no enunciado		
	
Random:     PUSH R4
			PUSH R3
			PUSH R7
			MOV R4,M[SP+6] 		;Numero "aleatorio" incrementado antes de se carregar no botao IA
			MOV R3,R4
			ROR R3,1
			BR.C Bit1
Bit0:       ROR R4,1
			BR Final_R
Bit1:       XOR R4,MASCARA
			ROR R4,1
			BR Final_R

			
;Parte final da funcao aleatoria, que transforma cada algarismo do numero aleatorio em um algarismo de 1 a 6

Final_R:    MOV R7,6                 
			PUSH R4            ;Guarda o valor inicial do Pseudo-aleatorio gerado
			AND R4,000Fh       ;Fica so com o ultimo algarismo do numero
			DIV R4,R7          ;Faz a divisao do algarismo por 6, colocando o resto em R7 (Vai dar um numero de 0 a 5)
			ADD R7,1           ;Soma 1 ao numero obtido anteriormente, ficando assim com um numero de 1 a 6 (Tal como pretendido)
			ADD M[SP+6],R7     ;Coloca o numero obtido como 4º algarismo do resultado
			
;A forma de obter um numero de 1 a 6 nos outros algarismos é igual a forma do ultimo
			
			MOV R4,M[SP+1]  
			SHR R4,4           ;Coloca o 3 algarismo no lugar do ultimo algarismo
			AND R4,000Fh
			MOV R7,6
			DIV R4,R7
			ADD R7,1
			SHL R7,3           ;Coloca o 3 algarismo no sitio certo
			ADD M[SP+6],R7     ;Coloca o numero obtido como 3 algarismo do resultado
			
			MOV R4,M[SP+1]
			SHR R4,8           ;Coloca o 2 algarismo no lugar do ultimo algarismo
			AND R4,000Fh
			MOV R7,6
			DIV R4,R7
			ADD R7,1
			SHL R7,6           ;Coloca o 2 algarismo no sitio certo
			ADD M[SP+6],R7     ;Coloca o numero obtido como 2 algarismo do resultado
			
			MOV R4,M[SP+1]
			SHR R4,12           ;Coloca o 1 algarismo no lugar do ultimo algarismo
			AND R4,000Fh
			MOV R7,6
			DIV R4,R7
			ADD R7,1
			SHL R7,9          ;Coloca o 1 algarismo no sitio certo
			ADD M[SP+6],R7     ;Coloca o numero obtido como 1 algarismo do resultado
			MOV R4,M[SP+1]
			
			POP R7
			POP R3
			POP R4
			POP R0                      ;Retira da pilha o pseudo-aleatorio inicial 
			RET