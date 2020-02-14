SP_INICIAL EQU 			FDFFh
JANELA	   EQU			FFFEh
SPC 	   EQU 			000Ah   ;Espaco na janela
MASCARA    EQU			8016h   ;Máscara para o número aleatório
NINICIAL   EQU		    3453h   ;Pode ser alterado para gerar um aleatório novo (Ni)
        ORIG 8000h
FINAL      TAB          8       ;Reserva espaço na memoria para os 'x','o' e '-'

		ORIG 0000h		
		MOV   R1,SP_INICIAL
		MOV	  SP,R1
		MOV   R6,R0             ;Contador do numero de jogadas
		PUSH  R0				;Guarda espaço na pilha para o número pseudo-aleatório que irá ser gerado

Inicio:	Call   Random           ;Gera um valor secreto aleatório
		POP   R1				;Coloca o número pseudo-aleatório gerado em R1
		MOV   R5,FINAL    		;Endereço da tabela dos 'x' e 'o'
		MOV   R3,R0        		;Contador do CicloBola

		
		
;Código que mete os algarismos do numero secreto na pilha
		
		PUSH  R1          
		AND   R1,000Fh
		PUSH  R1
		MOV	  R1,M[SP+2]
		SHR   R1,4              
		AND	  R1,000Fh
		PUSH  R1
		MOV   R1,M[SP+3]
		SHR   R1,8
		AND	  R1,000Fh
		PUSH  R1
		MOV   R1,M[SP+4]
		SHR   R1,12
		PUSH  R1

		
;O programa nao avanca enquanto nao for introduzido um valor em R2 pelo utilizador
		
		MOV  R2,R0
Teste:	CMP  R2,R0
		BR.Z	Teste        
		
		
;Codigo que mete os algarismos do numero introduzido pelo utilizador na pilha
		
		PUSH  R2
		AND   R2,000Fh         
		PUSH  R2
		MOV   R2,M[SP+2]
		SHR   R2,4
		AND	  R2,000Fh
		PUSH  R2
		MOV   R2,M[SP+3]
		SHR   R2,8
		AND	  R2,000Fh
		PUSH  R2
		MOV   R2,M[SP+4]
		SHR   R2,12
		AND	  R2,000Fh
		PUSH  R2
		MOV   R2,M[SP+5]
		CALL  Xis
		
		CMP  R6,12                 ;Se já tiverem sido feitas 12 jogadas, acaba a execução do programa
		JMP.NZ Inicio	           
FIM:    BR	FIM


;Codigo que testa se há numeros no sitio certo e coloca 'x' nos endereços de memória reservados inicialmente

Xis: 	  MOV R2,M[SP+2]        ;Mete em R2 o último primeiro algarismo do número do jogador
		  CMP R2,M[SP+7]        ;Compara o primeiro algarismo do número secreto com o primeiro algarismo do número do jogador
		  BR.NZ NEXT_X2         ;Se não forem iguais, salta para a próxima comparação
		  MOV R7,'x'
		  MOV M[R5],R7          ;Se forem iguais coloca-se 'x' no endereço de memória reservado
		  INC R5                ;O R5 aponta para o próximo endereço reservado
		  MOV M[SP+7],R0        ;Se for 'x', mete os algarismos correspondentes a 0 (Para mais tarde não contabilizarem outra vez como 'o')
		  MOV R2,M[SP+6]        ;Mete em R2 o número do utilizador
		  AND R2,0FFFh          ;Apaga o algarismo que foi contabilizado como 'x' do número inicial, de modo a que, no CicloBola, não te comparem os algarismos a 0
		  MOV M[SP+6],R2        ;Volta a colocar o numero atualizado na pilha

		  
;O próximo código faz o mesmo de cima para cada um dos outros 3 algarismos do número do utilizador
	  
NEXT_X2:  MOV R2,M[SP+3] 
		  CMP R2,M[SP+8]
		  BR.NZ NEXT_X3
		  MOV R7,'x'
		  MOV M[R5],R7
		  INC R5
		  MOV M[SP+8],R0
		  MOV R2,M[SP+6]
		  AND R2,F0FFh
		  MOV M[SP+6],R2
		  
NEXT_X3:  MOV R2,M[SP+4] 
		  CMP R2,M[SP+9]
		  BR.NZ NEXT_X4
		  MOV R7,'x'
		  MOV M[R5],R7
		  INC R5
		  MOV M[SP+9],R0
		  MOV R2,M[SP+6]
		  AND R2,FF0Fh
		  MOV M[SP+6],R2
		  
NEXT_X4:  MOV R2,M[SP+5] 
		  CMP R2,M[SP+10]
		  BR.NZ Inicio3
		  MOV R7,'x'
		  MOV M[R5],R7
		  INC R5
		  MOV M[SP+10],R0
		  MOV R2,M[SP+6]
		  AND R2,FFF0h
		  MOV M[SP+6],R2


;Código que testa os 'o', ou seja, testa se há algarismos certos, mas em posições erradas		  
		  
Inicio3: 	MOV R1,M[SP+6]         ;Move o número do utilizador (Já possivelmente alterado pelo Ciclo dos 'x') para R1
			BR  Primeiro           ;Salta para a 'zona de teste' dos 'o'
CicloBola:	SHR R1,4               ;Vai buscar o próximo algarismo do número do utilizador
			INC R3                 ;Contador que só pode ir até 4 (Para correr o CicloBola para os 4 algarismos)
			CMP R3,4                
			JMP.Z Fim_Ciclo        ;Se já tiverem sido testados os 4 algarismos, salta para o Fim do Ciclo

			
;Código que compara o algarismo atual do número do utilizador com cada um dos algarismos do número secreto			
			
Primeiro:   MOV R2,R1              ;Move o número para R2, de modo a preservar o número inicial em R1, para os próximos ciclos 
			AND R2,000Fh		   ;Preserva apenas o último algarismo do número do utilizador
			CMP R2,R0			   ;Testa se esse algarismo já foi alterado por outro ciclo para 0
			BR.Z CicloBola         ;Se sim, passa ao próximo algarismo
			
Num1:		CMP R2,M[SP+10]        ;Compara os últimos algarismos dos dois numeros (Utilizador e Secreto)
			BR.NZ Num2			   ;Se não forem iguais, passa ao próximo algarismo do número secreto
			MOV R7,'o'			   
			MOV M[R5],R7		   ;Coloca 'o' no endereço reservado para o resultado
		    INC R5				   ;Passa para o próximo endereço reservado
			MOV M[SP+10],R0		   ;Muda o valor do algarismo do número secreto respetivo para 0, para não voltar a ser contabilizado
			JMP CicloBola          ;Passa para o próximo algarismo do número do utilizador

			
;O próximo código é igual, mas adaptado para os outros 3 algarismos do número secreto
			´
Num2:		CMP R2,M[SP+9]
			BR.NZ Num3
			MOV R7,'o'
			MOV M[R5],R7
		    INC R5
			MOV M[SP+9],R0
			JMP CicloBola
			
Num3:		CMP R2,M[SP+8]
			BR.NZ Num4
			MOV R7,'o'
			MOV M[R5],R7
		    INC R5
			MOV M[SP+8],R0
			JMP CicloBola
			
Num4:		CMP R2,M[SP+7]
			JMP.NZ CicloBola
			MOV R7,'o'
			MOV M[R5],R7
		    INC R5
			MOV M[SP+7],R0
			JMP CicloBola

			
;Após serem colocados todos os 'x' e 'o', preenche-se os 4 endereços de memória seguintes com '-', 
;de modo a completar todos os casos possiveis (O pior caso terá 4 '-' seguidos)
		
Fim_Ciclo:  MOV  R7,'-'
			MOV M[R5],R7
			INC R5
			MOV  R7,'-'
			MOV M[R5],R7
			INC R5
			MOV  R7,'-'
			MOV M[R5],R7
			INC R5
			MOV  R7,'-'
			MOV M[R5],R7
			MOV R5,FINAL

			
;Código que coloca na janela de texto o conteúdo dos primeiros 4 endereços reservados para o resultado	
		
			MOV R3,M[R5]
			MOV M[JANELA],R3
			INC R5                 ;Passa para o próximo endereço de memória
			MOV R3,M[R5]
			MOV M[JANELA],R3
			INC R5
			MOV R3,M[R5]
			MOV M[JANELA],R3
			INC R5
			MOV R3,M[R5]
			MOV M[JANELA],R3
			MOV R7,SPC             
			MOV M[JANELA],R7         ;Passa para a próxima linha na janela
			MOV R5,FINAL             ;Dá reset ao R5 para o primeiro endereço da TAB definida no inicio
			
			INC R6                   ;Incrementa o contador das 12 jogadas
			RETN 10

			
;Funcao que gera um pseudo-aleatorio, tal como demonstrado no enunciado		
	
Random:     MOV R4,NINICIAL
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
			AND R4,000Fh       ;Fica só com o ultimo algarismo do numero
			DIV R4,R7          ;Faz a divisao do algarismo por 6, colocando o resto em R7 (Vai dar um numero de 0 a 5)
			ADD R7,1           ;Soma 1 ao numero obtido anteriormente, ficando assim com um numero de 1 a 6 (Tal como pretendido)
			ADD M[SP+3],R7     ;Coloca o numero obtido como 4º algarismo do resultado
			
;A forma de obter um numero de 1 a 6 nos outros algarismos é igual à forma do ultimo
			
			MOV R4,M[SP+1]  
			SHR R4,4           ;Coloca o 3º algarismo no lugar do ultimo algarismo
			AND R4,000Fh
			MOV R7,6
			DIV R4,R7
			ADD R7,1
			SHL R7,4           ;Volta a colocar o 3º algarismo no sitio certo
			ADD M[SP+3],R7     ;Coloca o numero obtido como 3º algarismo do resultado
			
			MOV R4,M[SP+1]
			SHR R4,8           ;Coloca o 2º algarismo no lugar do ultimo algarismo
			AND R4,000Fh
			MOV R7,6
			DIV R4,R7
			ADD R7,1
			SHL R7,8           ;Volta a colocar o 2º algarismo no sitio certo
			ADD M[SP+3],R7     ;Coloca o numero obtido como 2º algarismo do resultado
			
			MOV R4,M[SP+1]
			SHR R4,12           ;Coloca o 1º algarismo no lugar do ultimo algarismo
			AND R4,000Fh
			MOV R7,6
			DIV R4,R7
			ADD R7,1
			SHL R7,12          ;Volta a colocar o 1º algarismo no sitio certo
			ADD M[SP+3],R7     ;Coloca o numero obtido como 1º algarismo do resultado
			MOV R4,M[SP+1]
			
			POP R0                      ;Retira da pilha o pseudo-aleatorio inicial
			RET
			
			
			
			
			
			

			
			

			
			
		  
		  
		


