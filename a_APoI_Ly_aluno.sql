USE LYCEUM
GO

ALTER PROCEDURE a_APoI_Ly_aluno        
  @erro VARCHAR(1024) OUTPUT,        
  @aluno VARCHAR(20), @concurso VARCHAR(20), @candidato VARCHAR(20), @curso VARCHAR(20),         
  @turno VARCHAR(20), @curriculo VARCHAR(20), @serie NUMERIC(3), @nome_compl VARCHAR(100),         
  @nome_abrev VARCHAR(50), @anoconcl_2g NUMERIC(4), @tipo_ingresso VARCHAR(20), @ano_ingresso NUMERIC(4),         
  @sem_ingresso NUMERIC(2), @sit_aluno VARCHAR(15), @cred_educativo VARCHAR(1), @turma_pref VARCHAR(20),         
  @grupo VARCHAR(20), @areacnpq VARCHAR(20), @discipoutraserie VARCHAR(1), @ref_aluno_ant VARCHAR(20),         
  @sit_aprov VARCHAR(1), @cod_cartao VARCHAR(20), @dt_ingresso DATETIME, @e_mail_interno VARCHAR(100),         
  @num_chamada NUMERIC(10), @curso_ant VARCHAR(100), @unidade_fisica VARCHAR(20), @pessoa NUMERIC(10),         
  @outra_faculdade VARCHAR(100), @cidade_2g VARCHAR(50), @pais_2g VARCHAR(50), @creditos NUMERIC(3),         
  @obs_aluno_finan VARCHAR(3000), @representante_turma VARCHAR(1), @tipo_aluno VARCHAR(50),         
  @faculdade_conveniada VARCHAR(20), @stamp_atualizacao DATETIME, @unidade_ensino VARCHAR(20),         
  @instituicao VARCHAR(20), @classif_aluno VARCHAR(40), @dist_aluno_unidade NUMERIC(15), @nome_social VARCHAR(100)        
AS          
  -- [INÍCIO] Customização - Não escreva código antes desta linha          
BEGIN        
        
DECLARE @v_tipo_curso VARCHAR(20)        
DECLARE @v_grupo_aluno VARCHAR(100)  
        
SELECT @v_tipo_curso = TIPO        
FROM LY_CURSO        
WHERE CURSO = @curso        
        
--#################### INICIO - Tratamentos de bloqueio do ingresso do aluno #######################################        
        
-- Validando o preenchimento do Concurso na Graduação        
 --  IF @v_tipo_curso = 'GRADUACAO'        
 --  and (@concurso IS NULL OR @concurso NOT IN (SELECT CONCURSO FROM LY_CONCURSO))        
 --  BEGIN        
  --     set @erro = 'CUSTOM - Este aluno deve estar vinculado a um Concurso válido'        
 --      RETURN        
 --  END        
        
--## INICIO -RAUL - 03/05/2016 - 0003 - Verificar se para cursos do colégio, academia e pós-graduação só permitir periodo 0        
-- Deve ser sempre no inicio deste EP para que nao execute os outros tratamentos caso retorne erro.        
        
 If @sem_ingresso <> 0       -- Valida se o semestre é diferente de zero, pois o colégio so permite zero.         
 and @v_tipo_curso in ('ENS BASICO','ACADEMIA','POS-GRADUACAO')  -- verifica se o curso do aluno é do ensino básico ou da academia        
  Begin        
   set @erro = 'CUSTOM - Este aluno deve estar vinculados ao período 0.'        
   RETURN        
  End        
        
--## FIM -RAUL - 04/05/2016 - 0003 - Verificar se para cursos do colégio, academia e pós-graduação só permitir periodo 0        
        
--## INICIO -RAUL - 03/05/2016 - 0004 - Verificar se para cursos do faculdade só permitir periodo 1 ou 2        
-- Deve ser sempre no inicio deste EP para que nao execute os outros tratamentos caso retorne erro.        
        
 If @sem_ingresso = 0       -- Valida se o semestre é diferente de zero, pois o colégio so permite zero.         
 and @v_tipo_curso in ('GRADUACAO','LINGUAS')    -- verifica se o curso do aluno é do ensino básico        
  Begin        
   set @erro = 'CUSTOM - Este aluno deve estar vinculado ao período 1 ou 2.'        
   RETURN        
  End        
        
--## FIM -RAUL - 04/05/2016 - 0004 - Verificar se para cursos do faculdade só permitir periodo 1 ou 2        
        
--## INICIO - RAUL - 02/06/2016 - 0006 - Tratar para não permitir criar um aluno sem ter unidade fisica vinculada        
-- Deve ser sempre no inicio deste EP para que nao execute os outros tratamentos caso retorne erro.        
        
 If @unidade_fisica is null           -- Verifica se a unidade fisica veio null         
  Begin        
   set @erro = 'CUSTOM - O campo Unidade Física é obrigatório.'        
   RETURN        
  End        
        
 If NOT exists  (select top 1 1        -- Verifica se a unidade ensino do curso tem a unidade fisica indicada no relacionamento de unidades        
     from LY_UNIDADES_ASSOCIADAS ua        
     join  ly_curso c         
    on c.FACULDADE = ua.UNIDADE_ENS          
       where ua.UNIDADE_FIS = @unidade_fisica        
       and c.curso   = @curso        
)        
  Begin        
   set @erro = 'CUSTOM - O curso do aluno não é oferecido nesta Unidade Física.'        
   RETURN        
  End        
        
        
--## FIM -RAUL - 02/06/2016 - 0006 - Tratar para não permitir criar um aluno sem ter unidade fisica vinculada        
        
--#################### FIM - Tratamentos de bloqueio do ingresso do aluno #######################################        
        
        
          
--## INICIO -RAUL - 13/01/2016 - 0001 - Atualizar senha da pessoa do aluno novo quando a senha for NULL          
 -- Atualiza senha do aluno com o CPF          
 --## 28/06/2016 - ajustado filtro        
 --## 30/06/2016 - incluido p campo senha_alterada = 'N'        
 Update P             
 Set SENHA_TAC = DBO.CRYPT(CPF)          
 , SENHA_ALTERADA = 'N'   --## 30/06/2016        
 from LY_PESSOA p        
 Where PESSOA = @pessoa            
 and SENHA_TAC IS NULL           
 and isnull(p.cpf,'')  <> ''        
 and cpf   <> '00000000000'        
        
 --# Usa data de nascimento         
 --## 28/06/2016 - ajustado mes para 2 digitos e filtro        
 --## 30/06/2016 - incluido p campo senha_alterada = 'N'        
 Update P             
 Set SENHA_TAC = DBO.CRYPT(right('00'+convert(varchar,day(dt_nasc)),2) +right('00'+convert(varchar,month(dt_nasc)),2)+convert(varchar,year(dt_nasc)))             
 , SENHA_ALTERADA = 'N'   --## 30/06/2016        
 from LY_PESSOA p         
 Where p.PESSOA = @pessoa            
 and p.SENHA_TAC IS NULL           
 and (isnull(p.cpf,'')  = '' or cpf = '00000000000')        
 and p.DT_NASC is not null        
        
--## FIM - RAUL - 13/01/2016 - 0001 -  Atualizar senha da pessoa do aluno novo quando a senha for NULL          
          
--## INICIO - RAUL - 24/03/2016 - 0002 - Inserir todos os documentos como pendentes para facilitar o lançamento pela tela de documentos          
         
 insert into ly_aluno_doc_ingresso        
 --## Todos os documentos, exceto os restritos de outros cursos        
 SELECT di.doc  as doc,         
   --di.nome  as nome,  -- Utilizado para testes        
   --@curso  as Curso,   -- Utilizado para testes        
   @aluno  as aluno,        
   'Pendente' as Status,        
   NULL   as comentario,        
   1   as quantidade,        
   null   as caminho_imagem        
   --, 1 as flag    -- Utilizado para testes        
 FROM   ly_documentos_ingresso di         
 WHERE 1 = 1          
 and NOT EXISTS (SELECT 1         
      FROM  ly_aluno_doc_ingresso adi         
      WHERE di.doc = adi.doc         
      AND adi.aluno = @aluno)         
 and not exists (select 1 from ly_doc_restrito_curso drc         
     where di.doc = drc.doc         
     aND drc.curso <> @curso)        
 union        
 --## Documentos restritos do curso do aluno        
 SELECT di.doc  as doc,         
   --di.nome  as nome,    -- Utilizado para testes        
   --@curso  as Curso,  -- Utilizado para testes        
   @aluno  as aluno,        
   'Pendente' as Status,        
   NULL   as comentario,        
   1   as quantidade,        
   null   as caminho_imagem         
   --, 2 as flag     -- Utilizado para testes        
 FROM   ly_documentos_ingresso di         
 JOIN ly_doc_restrito_curso drc         
   ON di.doc = drc.doc         
 WHERE 1 = 1          
 and NOT EXISTS (SELECT 1         
      FROM  ly_aluno_doc_ingresso adi         
      WHERE di.doc = adi.doc         
      AND adi.aluno = @aluno)         
 AND drc.curso = @curso        
        
--## FIM - RAUL - 24/03/2016 - 0002 - Inserir todos os documentos como pendentes para facilitar o lançamento pela tela de documentos            
        
        
--## INICIO - RANIERE VIANA - 01/10/2019 - Cadastrar Bolsas Campanhas Automática        
  exec FTC_PR_CADASTRA_BOLSA @aluno        
--## FIM - RANIERE VIANA - 01/10/2019 - Cadastrar Bolsas Campanhas Automática        
      
      
  -- INTEGRAÇÃO COM CATRACA - 0009 - Ajustado por Douglas        
  EXEC FTC_PR_INTEGRACAO_CATRACA_ALUNO @aluno        
        
----## INICIO - RAUL - 05/08/2016 - Pergamum - Código de integração do Pergamum        
----## 09/02/2017 - O codigo deste tratamento foi aplicado em uma procedure agendada junto a integração do pergamum        
         
-- --## 13/01/2017 - tratamento para não incluir informações dos cursos do tipo linguas        
-- if @curso not in (select curso from ly_curso where tipo IN ('LINGUAS','ENS BASICO','ACADEMIA'))        
--  exec insert_aluno_pergamum @aluno, @curso, @nome_compl, @sit_aluno, @unidade_fisica, @pessoa        
----## FIM - RAUL - 05/08/2016 - Pergamum - Código de integração do Pergamum         
        
        
--## INICIO - RAUL - 12/12/2016 - 0008 - Enviar e-mail para aluno calouro  com acesso ao portal        
 exec FTC_SP_SEND_MAIL_LOTE 'AlunoIngresso', @aluno, null, null, null, null        
--## FIM - RAUL - 12/12/2016 - 0008 - Enviar e-mail para aluno calouro com acesso ao portal   

 -- #INICIO Miguel 05/02/2021 # - Customização para vincular o Grupo de dívida para o aluno de concursos específicos
 IF @concurso IN ('360','361','362','363','364','365')
	BEGIN
		IF @CURSO = '722'
			BEGIN
				SET @V_GRUPO_ALUNO = (SELECT   
				'GPA'+CURSO+'- '+CAST(ANO_INGRESSO AS VARCHAR) + CAST(SEM_INGRESSO AS VARCHAR)   
				FROM LY_ALUNO   
				WHERE ALUNO = @aluno  
			  )
			END
		IF @CURSO = '507'
			BEGIN
				SET @V_GRUPO_ALUNO = (SELECT   
				'GPA'+CURSO+'-'+CAST(ANO_INGRESSO AS VARCHAR) + CAST(SEM_INGRESSO AS VARCHAR)   
				FROM LY_ALUNO   
				WHERE ALUNO = @aluno  
			  )
			END
		ELSE
			BEGIN
				SET @V_GRUPO_ALUNO = (SELECT   
				'GPA_'+UNIDADE_ENSINO+'_'+CAST(ANO_INGRESSO AS VARCHAR) + CAST(SEM_INGRESSO AS VARCHAR)   
				FROM LY_ALUNO   
				WHERE ALUNO = @aluno  
      )  
			END
			
	END

 ELSE
	BEGIN

 -- #FIM Miguel 05/02/2021 #     

-- #INICIO Luth 28/12/2020 # - Customização para vincular o Grupo de dívida para o aluno  
	SET @V_GRUPO_ALUNO = (SELECT   
		  'GPA_'+UNIDADE_ENSINO+'_'+CAST(ANO_INGRESSO AS VARCHAR) + CAST(SEM_INGRESSO AS VARCHAR)   
		  FROM LY_ALUNO   
		  WHERE ALUNO = @aluno  
      )  
	END

IF(EXISTS(SELECT 1 FROM LY_GRUPO_ALUNO WHERE GRUPO = @V_GRUPO_ALUNO))  
BEGIN   
 UPDATE LY_ALUNO SET GRUPO = @V_GRUPO_ALUNO WHERE ALUNO = @aluno  
END  
-- #FIM Luth 28/12/2020 #   
  
-- [FIM] Customização - Não escreva código após esta linha          
RETURN        
        
END 