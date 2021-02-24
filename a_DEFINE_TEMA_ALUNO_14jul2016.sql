USE LYCEUM
GO

ALTER PROCEDURE a_DEFINE_TEMA_ALUNO  
 @Pessoa         as T_NUMERO_GRANDE,    
 @Tema           as T_ALFALARGE OUTPUT    
 AS    
 --[INICIO]    
 --## INICIO - MIGUEL - 14/07/2016 - Tratamento para definir o tema do Lyceum de acordo com a Unidade de Ensino
 
	Begin
			--## 0001 - Consulta se aluno esta no grupo bloqueia FIES e altera o perfil de acesso dele.
			if exists ( 
			            select 1
						from ly_curso c
						join LY_ALUNO a
							on a.CURSO    = c.CURSO
						join LY_PESSOA p
							on p.PESSOA = a.PESSOA	
						where 1 = 1 
						and isnull(c.TIPO,'')   in ('ACADEMIA','GRADUACAO','EXTENSAO','MESTRADO','POS-GRADUACAO','TECNICO')
						AND C.FACULDADE NOT IN ('29')
						and p.PESSOA            = @Pessoa
					  )	
				Begin
					--## Seta padrão de acesso
					SET @Tema = ''
					RETURN
				END
						
			--## 0002 - Consulta se o aluno é do colégio DOM -- ALTERADO POR MIGUEL 11/03/2016
			if exists ( 
			            select 1
						from ly_curso c
						join LY_ALUNO a
							on a.CURSO    = c.CURSO
						join LY_PESSOA p
							on p.PESSOA = a.PESSOA	
						where 1 = 1 
						and isnull(c.TIPO,'')   in ('ENS BASICO')
						and p.PESSOA            = @Pessoa
					  )	
				Begin
					--## Seta padrão de acesso
					SET @Tema = 'DOM'
					RETURN
				END
			--## 0003 - Consulta se aluno é da Faculdade da Cidade.
			if exists ( 
			            select 1
						from ly_curso c
						join LY_ALUNO a
							on a.CURSO    = c.CURSO
						join LY_PESSOA p
							on p.PESSOA = a.PESSOA	
						where 1 = 1 
						and isnull(c.TIPO,'')   in ('ACADEMIA','GRADUACAO','EXTENSAO','MESTRADO','POS-GRADUACAO','TECNICO')
						AND C.FACULDADE IN ('29')
						and p.PESSOA            = @Pessoa
					  )	
				Begin
					--## Seta padrão de acesso
					SET @Tema = 'FCS'
					RETURN
				END
			
	END  
 RETURN    
 --[FIM]  
 GO