USE LYCEUM
GO

--INSERT INTO LY_EP_TABELA (TABELA,OPERACAO,PRE_POS)
--VALUES ('LY_HISTMATRICULA','U','PR')
--GO
 
--INSERT INTO LY_EP_TABELA (TABELA,OPERACAO,PRE_POS)
--VALUES ('LY_HISTMATRICULA','I','PR')
--GO



IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.a_APRI_LY_HISTMATRICULA'))
   exec('CREATE PROCEDURE [dbo].[a_APRI_LY_HISTMATRICULA] AS BEGIN SET NOCOUNT OFF; END')
GO

ALTER PROCEDURE a_APRI_LY_HISTMATRICULA
@erro varchar(1024) OUTPUT,
@aluno T_CODIGO,
@ordem T_NUMERO_PEQUENO,
@ano T_ANO,
@semestre T_SEMESTRE2,
@disciplina T_CODIGO,
@turma T_CODIGO,
@nota_final T_ALFASMALL,
@situacao_hist T_SIT_HISTMATRICULA,
@perc_presenca T_PERCENTUAL54,
@horas_aula T_DECIMAL_MEDIO,
@creditos T_DECIMAL_MEDIO,
@nome_disc_orig varchar,
@aulas_dadas T_DECIMAL_MEDIO_PRECISO,
@observacao T_ALFAEXTRALARGE,
@num_func T_NUMFUNC,
@lanc_deb T_NUMERO,
@aulas_previstas T_DECIMAL_MEDIO_PRECISO,
@num_chamada T_NUMERO,
@nivel_presenca T_ALFASMALL,
@serie T_NUMERO_PEQUENO,
@grupo_eletiva T_CODIGO,
@subturma1 T_CODIGO,
@subturma2 T_CODIGO,
@sit_detalhe T_ALFAMEDIUM,
@dt_inicio T_DATA,
@dt_fim T_DATA,
@cobranca_sep T_SIMNAO,
@dt_ultalt T_DATA,
@dt_matricula T_DATA,
@nota_final_num T_DECIMAL_MEDIO,
@area_conhecimento T_ALFALARGE,
@tipo_aprovacao varchar,
@fl_field_01 T_ALFAEXTRALARGE,
@fl_field_02 T_ALFAEXTRALARGE,
@fl_field_03 T_ALFAEXTRALARGE,
@fl_field_04 T_ALFAEXTRALARGE,
@fl_field_05 T_ALFAEXTRALARGE,
@fl_field_06 T_ALFAEXTRALARGE,
@fl_field_07 T_ALFAEXTRALARGE,
@fl_field_08 T_ALFAEXTRALARGE,
@fl_field_09 T_ALFAEXTRALARGE,
@fl_field_10 T_ALFAEXTRALARGE

AS
-- [INÍCIO] Customização - Não escreva código antes desta linha
	IF @situacao_hist = 'Aprovado'
		BEGIN
		    SET @erro = 'aaaaaaTeste'  
		END

-- [FIM] Customização - Não escreva código após esta linha
RETURN
GO