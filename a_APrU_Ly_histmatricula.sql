USE LYCEUM
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.a_APrU_Ly_histmatricula'))
   exec('CREATE PROCEDURE [dbo].[a_APrU_Ly_histmatricula] AS BEGIN SET NOCOUNT OFF; END')
GO

ALTER PROCEDURE a_APrU_Ly_histmatricula  
    @erro VARCHAR(1024) OUTPUT,  
    @oldAluno VARCHAR(20), @oldOrdem NUMERIC(3), @oldAno NUMERIC(4), @oldSemestre NUMERIC(2),   
    @oldDisciplina VARCHAR(20), @oldTurma VARCHAR(20), @oldNota_final VARCHAR(15), @oldSituacao_hist VARCHAR(20),   
    @oldPerc_presenca NUMERIC(5, 4), @oldHoras_aula NUMERIC(10, 2), @oldCreditos NUMERIC(10, 2),   
    @oldNome_disc_orig VARCHAR(150), @oldAulas_dadas NUMERIC(12, 4), @oldObservacao VARCHAR(2000),   
    @oldNum_func NUMERIC(15), @oldLanc_deb NUMERIC(10), @oldAulas_previstas NUMERIC(12, 4),   
    @oldNum_chamada NUMERIC(10), @oldNivel_presenca VARCHAR(15), @oldSerie NUMERIC(3),   
    @oldGrupo_eletiva VARCHAR(20), @oldSubturma1 VARCHAR(20), @oldSubturma2 VARCHAR(20),   
    @oldSit_detalhe VARCHAR(50), @oldDt_inicio DATETIME, @oldDt_fim DATETIME, @oldCobranca_sep VARCHAR(1),   
    @oldDt_ultalt DATETIME, @oldDt_matricula DATETIME, @oldNota_final_num NUMERIC(10, 2),   
    @oldArea_conhecimento VARCHAR(100), @oldTipo_aprovacao VARCHAR(40), @oldFl_field_01 VARCHAR(2000),   
    @oldFl_field_02 VARCHAR(2000), @oldFl_field_03 VARCHAR(2000), @oldFl_field_04 VARCHAR(2000),   
    @oldFl_field_05 VARCHAR(2000), @oldFl_field_06 VARCHAR(2000), @oldFl_field_07 VARCHAR(2000),   
    @oldFl_field_08 VARCHAR(2000), @oldFl_field_09 VARCHAR(2000), @oldFl_field_10 VARCHAR(2000),  
    @aluno VARCHAR(200), @ordem NUMERIC(20, 10), @ano NUMERIC(20, 10),   
    @semestre NUMERIC(20, 10), @disciplina VARCHAR(200), @turma VARCHAR(200),   
    @nota_final VARCHAR(200), @situacao_hist VARCHAR(200), @perc_presenca NUMERIC(20, 10),   
    @horas_aula NUMERIC(20, 10), @creditos NUMERIC(20, 10), @nome_disc_orig VARCHAR(250),   
    @aulas_dadas NUMERIC(22, 10), @observacao VARCHAR(2100), @num_func NUMERIC(25, 10),   
    @lanc_deb NUMERIC(20, 10), @aulas_previstas NUMERIC(22, 10), @num_chamada NUMERIC(20, 10),   
    @nivel_presenca VARCHAR(200), @serie NUMERIC(20, 10), @grupo_eletiva VARCHAR(200),   
    @subturma1 VARCHAR(200), @subturma2 VARCHAR(200), @sit_detalhe VARCHAR(200),   
    @dt_inicio DATETIME, @dt_fim DATETIME, @cobranca_sep VARCHAR(200),   
    @dt_ultalt DATETIME, @dt_matricula DATETIME, @nota_final_num NUMERIC(20, 10),   
    @area_conhecimento VARCHAR(200), @tipo_aprovacao VARCHAR(200), @fl_field_01 VARCHAR(2100),   
    @fl_field_02 VARCHAR(2100), @fl_field_03 VARCHAR(2100), @fl_field_04 VARCHAR(2100),   
    @fl_field_05 VARCHAR(2100), @fl_field_06 VARCHAR(2100), @fl_field_07 VARCHAR(2100),   
    @fl_field_08 VARCHAR(2100), @fl_field_09 VARCHAR(2100), @fl_field_10 VARCHAR(2100)  
  AS  
    -- [INÍCIO] Customização - Não escreva código antes desta linha  
    	  --DECLARE @V_USUARIO          T_CODIGO,    
   --         @V_RETURN_BUSCA_U   T_SIMNAO,    
   --         @V_MSG_BUSCA_U      VARCHAR(2000),    
   --         @V_NOME_USUARIO     VARCHAR(100)    
	IF @situacao_hist = 'Aprovado'
		BEGIN
		    SET @erro = 'Teste'  
			RETURN
		END
	

    -- [FIM] Customização - Não escreva código após esta linha