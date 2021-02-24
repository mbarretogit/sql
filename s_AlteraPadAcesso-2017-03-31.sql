USE LYCEUM
GO
--## 6.2.1-HF14


ALTER PROCEDURE s_AlteraPadAcesso  
   @p_codPessoa T_CODIGO, 
   @p_moduloAluno T_ALFAMEDIUM, 
   @p_moduloDocente T_ALFAMEDIUM, 
   @p_isDocente T_SIMNAO, 
   @p_isCoordenador T_SIMNAO, 
   @p_PadAcessoAlterado varchar(14) OUTPUT,
   @p_codAluno T_CODIGO --Acrescentado no 7.0 HF14 
   
   AS  
-- INICIO  

--## INICIO - RAUL - 11/12/2015 - Tratamento para definir o padrão de acesso do aluno
--## RAUL - 11/12/2015 - Programar o EP de acesso ao portal para que se o aluno estiver no conjunto de alunos "BLOQ_FIES_PORTAL" atribuir o padrão de acesso restrito, se ele não estiver no conjunto carrega o normal.

If @p_moduloAluno = 'AOnline'  
	Begin
			--## 0001 - Consulta se aluno esta no grupo bloqueia FIES e altera o perfil de acesso dele.
			if exists ( 
			            select 1
						from ly_curso c
						join LY_ALUNO a
							on a.CURSO    = c.CURSO
						join LY_PESSOA p
							on p.PESSOA = a.PESSOA	
						JOIN LY_CONJ_ALUNO CA
						    ON A.ALUNO  = CA.ALUNO
						where 1 = 1 
						and isnull(c.TIPO,'')   in ('GRADUACAO','TECNOLOGO')
						AND CA.CONJ_ALUNO       = 'BLOQ_FIES_PORTAL'
						and p.PESSOA            = @p_codPessoa
					  )	
				Begin
					--## Seta padrão de acesso
					SET @p_PadAcessoAlterado = 'AOL_ALUNO_FIES'
				END
						
			--## 0002 - Consulta se o aluno é do colégio DOM (OU DO THINK - MIUGEL 31/03/2017) -- ALTERADO POR MIGUEL 11/03/2016
			
			if exists ( 
			            select 1
						from ly_curso c
						join LY_ALUNO a
							on a.CURSO    = c.CURSO
						join LY_PESSOA p
							on p.PESSOA = a.PESSOA	
						--JOIN LY_CONJ_ALUNO CA
						--    ON A.ALUNO  = CA.ALUNO
						where 1 = 1 
						and isnull(c.TIPO,'')   in ('ENS BASICO','LINGUAS')
						--AND CA.CONJ_ALUNO       = 'BLOQ_FIES_PORTAL'
						and p.PESSOA            = @p_codPessoa
					  )	
				Begin
					--## Seta padrão de acesso
					SET @p_PadAcessoAlterado = 'AOL_ALUNO_CDB'
				END
			
	END  
	
IF @p_moduloAluno = 'DOnline'
	BEGIN
			--## 0003 - Consulta se o docente é do colégio DOM -- ALTERADO POR MIGUEL 08/04/2016
			if exists ( 
			            select 1
						from LY_DOCENTE d
						join LY_PESSOA p
							on p.PESSOA = d.PESSOA	
						JOIN LY_DOCENTE_UNIDADE DU
						    ON DU.NUM_FUNC  = D.NUM_FUNC
						where 1 = 1 
						AND DU.FACULDADE IN ('50','51','52','53','54')
						and p.PESSOA            = @p_codPessoa
					  )	
				Begin
					--## Seta padrão de acesso
					SET @p_PadAcessoAlterado = 'NG_DOM_DOCENTE'
				End

			--## 0004 - Consulta se o docente é também coordenador do colégio DOM -- ALTERADO POR MIGUEL 08/04/2016
			if exists ( 
			            select 1
						from LY_DOCENTE d
						JOIN LY_COORDENACAO lc
							ON lc.NUM_FUNC = d.NUM_FUNC
						join LY_PESSOA p
							on p.PESSOA = d.PESSOA	
						JOIN LY_DOCENTE_UNIDADE DU
						    ON DU.NUM_FUNC  = D.NUM_FUNC
						where 1 = 1 
						AND DU.FACULDADE IN ('50','51','52','53','54')
						AND GETDATE() >= isnull(lc.DT_INI,GETDATE())
						 AND GETDATE() <= isnull(lc.DT_FIM,GETDATE())
						and p.PESSOA = @p_codPessoa
					  )	
				Begin
					--## Seta padrão de acesso
					SET @p_PadAcessoAlterado = 'NG_DOM_COORD'
				End
	END
--## FIM - RAUL - 11/12/2015 - Tratamento para definir o padrão de acesso do aluno

-- FIM   
RETURN 
GO


DELETE FROM LY_CUSTOM_CLIENTE
WHERE NOME = 's_AlteraPadAcesso'
AND IDENTIFICACAO_CODIGO = '0002'
GO


INSERT INTO LY_CUSTOM_CLIENTE
(NOME, IDENTIFICACAO_CODIGO, AUTOR, DATA_CRIACAO, OBJETIVO, SOLICITADO_POR, ATIVO, TIPOCOMPONENTE, TIPO, CLIENTE)
SELECT
  's_AlteraPadAcesso' NOME
, '0002' IDENTIFICAO_CODIGO
, 'Miguel' AUTOR
, '2017-03-31' DATA_CRIACAO
, 'Inserção do THINK no padrão de acesso do colegio' OBJETIVO
, '' SOLICITADO_POR
, 'S' ATIVO
, 'ENTRY POINT' TIPOCOMPONENTE
, 'CLIENTE' TIPO
, 'FTC' CLIENTE
GO   