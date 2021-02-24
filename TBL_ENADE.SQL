USE MIGRACAO
go

SET NOCOUNT ON 
GO

Print 'INICIO DO TABELAO PROCESSO SELETIVO:' + CAST(GETDATE() AS VARCHAR)
GO
------------------------------------------------------------------------    
-- CRIA ESTRUTURA
------------------------------------------------------------------------    
PRINT ''    
PRINT '### -> Dropa e Cria Tabela TBL_ENADE'    
go

--## Dropa Tabela TBL_ENADE
IF dbo.fn_ExisteTabela('TBL_ENADE') = 'S'
    DROP TABLE TBL_ENADE
go

CREATE TABLE [dbo].[TBL_ENADE]
(
--## [LY_PROVAO_MEC_CURSO]
	[PROVA]	[dbo].[T_CODIGO] NOT NULL,	
    [AREA]	VARCHAR (40) NOT NULL,	
    [CURSO]	[dbo].[T_CODIGO] NOT NULL,	
--## [LY_PROVAO_MEC]
	[DATA]		[dbo].[T_DATA] NULL,
	[DESCRICAO]	[dbo].[T_ALFALARGE] NULL,
	[PERC_INGR_INI]	[dbo].[T_DECIMAL_PRECISO] NULL,
	[PERC_INGR_FIM]	[dbo].[T_DECIMAL_PRECISO] NULL,
	[PERC_CONC_INI]	[dbo].[T_DECIMAL_PRECISO] NULL,
	[PERC_CONC_FIM]	[dbo].[T_DECIMAL_PRECISO] NULL,
--## [LY_MATRICULA_PROVAO]
	[ALUNO]			[dbo].[T_CODIGO] NOT NULL,
	[TIPO]			[dbo].[T_ALFASMALL] NOT NULL,
	[COMPARECEU]	[dbo].[T_SIMNAO] NULL,
	[CONCEITO]		[dbo].[T_ALFASMALL] NULL,
	[DISPENSADO]	[dbo].[T_SIMNAO] NULL,
	[PERCENTUAL]	[dbo].[T_DECIMAL_PRECISO] NULL,
	[SITUACAO_ENADE] VARCHAR	(40) NULL,
	[MIGRAR] [dbo].[T_SIMNAO] NULL,
	[ORDEM]	  [dbo].[T_NUMERO_PEQUENO],
	[CPF]     [dbo].[T_CODIGO] NOT NULL,
	[SIT_ALUNO]	 [dbo].[T_SIT_ALUNO] NULL,
	[NOME_COMPL] VARCHAR (200) NOT NULL,
	[UNIDADE_ENSINO]  VARCHAR (200)  NULL
	  	
)
go


--## Dropa TabelA TMP_ENADE
IF dbo.fn_ExisteTabela('TMP_ENADE') = 'S'
    DROP TABLE TMP_ENADE
go


--#####################################################################################
-- Inserção no tabelão TMP_ENADE
--#####################################################################################

PRINT ''    
PRINT '### -> Cria tabela  auxiliar TMP_ENADE - ' + CAST(GETDATE() AS VARCHAR)   
go

SELECT DISTINCT
PROVAO,
P.CURSO,
'Geral' as area,
P.NOME_COMPL,
P.CPF,
I.TIPO,
P.ALUNO,
'N' AS MIGRAR,
P.SIT_ALUNO,
P.UNIDADE_ENSINO

INTO TMP_ENADE
FROM  [INTEGRACAO_ENADE] I
JOIN TBL_PESSOA_ALUNO_DOCENTE_RESP P ON P.CPF = REPLACE(REPLACE(REPLACE(RTRIM(LTRIM(I.CPF)),' ',''),'-',''),'.','') -- Retira Caracteres do CPF
WHERE P.TIPO_AGENTE = 'ALUNO' AND P.MIGRAR = 'S' AND P.SIT_ALUNO <> 'CANCELADO'		  
go


CREATE INDEX IDX1_TMP_ENADE ON TMP_ENADE(CPF)

GO


--#####################################################################################
-- Criação do Tabelão Auxiliar
--#####################################################################################

PRINT ''    
PRINT '### -> Cria tabela  auxiliar TMP_ENADE_AUX - ' + CAST(GETDATE() AS VARCHAR)   
go

--## Dropa TabelA Auxiliar
IF dbo.fn_ExisteTabela('TMP_ENADE_AUX') = 'S'
    DROP TABLE TMP_ENADE_AUX
go

-- Cria tabela temporaria auxiliar
select * 
into TMP_ENADE_AUX
from TBL_ENADE
where 1 = 0
go


PRINT ''    
Print '#########################################################'
PRINT '### -> Insere na TMP_ENADE_AUX dados da tabela TMP_ENADE - ' + CAST(GETDATE() AS VARCHAR)    
Print '#########################################################'
go

-- Insere na tabela temporaria
insert into TMP_ENADE_AUX 
(
--## [LY_PROVAO_MEC_CURSO]
 [PROVA]	
,[AREA]			
,[CURSO]	
--## [LY_PROVAO_MEC]
,[DATA]		
,[DESCRICAO]	
,[PERC_INGR_INI]	
,[PERC_INGR_FIM]	
,[PERC_CONC_INI]
,[PERC_CONC_FIM]	
--## [LY_MATRICULA_PROVAO]
--,[CURSO]			
,[ALUNO]			
,[TIPO]			
,[COMPARECEU]	
,[CONCEITO]		
,[DISPENSADO]	
,[PERCENTUAL]	
,[SITUACAO_ENADE]
,[CPF]
,[MIGRAR]
,[SIT_ALUNO]
,[NOME_COMPL]
,[UNIDADE_ENSINO]	

)

SELECT DISTINCT 

--## [LY_PROVAO_MEC_CURSO]
 'PROVA ENADE' AS [PROVAO]	
,[AREA]			
,[CURSO]	
--## [LY_PROVAO_MEC]
, NULL AS [DATA]		
,'ENADE 2015' AS [DESCRICAO]	
,NULL AS [PERC_INGR_INI]	
,NULL AS [PERC_INGR_FIM]	
,NULL AS [PERC_CONC_INI]
,NULL AS [PERC_CONC_FIM]	
--## [LY_MATRICULA_PROVAO]
--,[CURSO]			
,[ALUNO]			
,[TIPO]			
,'N'[COMPARECEU]	
,NULL AS [CONCEITO]		
,NULL AS [DISPENSADO]	
,NULL AS [PERCENTUAL]	
,NULL AS [SITUACAO_ENADE]
,[CPF]
,MIGRAR
,SIT_ALUNO
,NOME_COMPL
,UNIDADE_ENSINO

FROM TMP_ENADE 

go

PRINT ''    
Print '#########################################################'
PRINT '### -> Início ajustes na Tabela TMP_ENADE_AUX - ' + CAST(GETDATE() AS VARCHAR)    
Print '#########################################################'
go

-- Atualiza o tipo CONCLUINTE para minusculo, com a primeira leta maiuscula  
update TMP_ENADE_AUX
set tipo = 'Concluinte'
where tipo = 'CONCLUINTE'

-- Atualiza o tipo INGRESSANTE para minusculo, com a primeira leta maiuscula  
update TMP_ENADE_AUX
set tipo = 'Ingressante '
where tipo = 'INGRESSANTE'


-- Atualiza Migrar = s somente os alunos que tem apenas um código de aluno cadastrado por CPF
UPDATE A
SET A.MIGRAR = 'S'
FROM TMP_ENADE_AUX A
JOIN ( select  cpf
	  FROM TMP_ENADE_AUX 
	  group by cpf
	  having count (cpf) =1
	  ) B ON A.CPF = B.CPF
  
GO