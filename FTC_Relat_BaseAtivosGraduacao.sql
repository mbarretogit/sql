USE LYCEUM
GO

--EXEC FTC_Relat_BaseAtivosGraduacao 2018,1,NULL,NULL,NULL

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.FTC_Relat_BaseAtivosGraduacao'))
   exec('CREATE PROCEDURE [dbo].[FTC_Relat_BaseAtivosGraduacao] AS BEGIN SET NOCOUNT OFF; END')
GO 
      
ALTER PROCEDURE dbo.FTC_Relat_BaseAtivosGraduacao
(            
  @p_ano VARCHAR(4)      
, @p_semestre VARCHAR(2)      
, @p_unidade VARCHAR(20)
, @p_tipo VARCHAR(30)      
, @p_curso  VARCHAR(20)        
--, @p_tipo_relatorio VARCHAR(1)
)            
AS            
-- [IN�CIO]                    
BEGIN     

--1.0 CRIACAO DA TABELA TEMPORARIA DE ATIVOS

CREATE TABLE #TEMP_ATIVOS 
(
	[STATUS_FTC] VARCHAR(50),
	[UNIDADE_ENSINO_ALUNO]	VARCHAR(20),
	[NOME_UNIDADE_ENSINO_ALUNO] VARCHAR(100),
	[UNIDADE_FISICA_ALUNO] VARCHAR(30),
	[TIPO_CURSO] VARCHAR(50),
	[CURSO] VARCHAR(20),
	[NOME_CURSO] VARCHAR(100),
	[CURRICULO] VARCHAR(20),
	[TURNO] VARCHAR(20),
	[SERIE] SMALLINT,
	[TIPO_ALUNO] VARCHAR(50),
	[TIPO_INGRESSO] VARCHAR(50),
	[ANO_INGRESSO] VARCHAR(4),
	[SEM_INGRESSO] VARCHAR(2),
	[ALUNO] VARCHAR(20),
	[CPF] VARCHAR(20),
	[NOME_ALUNO] VARCHAR(100),
	[E_MAIL] VARCHAR(100),
	[DDD] VARCHAR(10),
	[FONE] VARCHAR(30),
	[CELULAR] VARCHAR(30),
	[SIT_MATRICULA] VARCHAR(50),
	[PAGO] SMALLINT,
	[NAO_PAGO] SMALLINT
	
)       

--2.0 PRIMEIRA CARGA COM ALUNOS QUE ESTUDARAM NO PERIODO ANTERIOR AO SELECIONADO

--SE FOR PERIODO LETIVO FORA DO ATUAL, DEVE UTILIZAR APENAS DADO DO HIST�RICO
IF CONCAT(@p_ano,@p_semestre) < CONCAT(YEAR(GETDATE()),CASE WHEN MONTH(GETDATE()) < 7 THEN 1 ELSE 2 END)

BEGIN
	
INSERT INTO #TEMP_ATIVOS
SELECT DISTINCT
	NULL AS STATUS_FTC,
	C.FACULDADE AS UNIDADE_ENSINO_ALUNO,
	UE.NOME_COMP AS NOME_UNIDADE_ENSINO_ALUNO,
	A.UNIDADE_FISICA AS UNIDADE_FISICA_ALUNO,
	C.TIPO AS TIPO_CURSO,
	C.CURSO AS CURSO,
	C.NOME AS NOME_CURSO,
	A.CURRICULO AS CURRICULO,
	A.TURNO AS TURNO,
	A.SERIE AS SERIE,
	'VETERANO' AS TIPO_ALUNO,
	A.TIPO_INGRESSO AS TIPO_INGRESSO,
	A.ANO_INGRESSO AS ANO_INGRESSO,
	A.SEM_INGRESSO AS SEM_INGRESSO,
	A.ALUNO AS ALUNO,
	P.CPF AS CPF,
	A.NOME_COMPL AS NOME_ALUNO,
	P.E_MAIL AS E_MAIL,
	ISNULL(P.DDD_FONE_CELULAR,P.DDD_FONE) AS DDD,
	ISNULL(P.FONE,'') AS FONE,
	ISNULL(P.CELULAR,'') AS CELULAR,
	'MATRICULADO' AS SIT_MATRICULA,
	0 AS PAGO,
	0 AS NAO_PAGO
FROM LY_HISTMATRICULA HM
JOIN LY_ALUNO A ON A.ALUNO = HM.ALUNO
JOIN LY_PESSOA P ON P.PESSOA = A.PESSOA
JOIN LY_CURSO C ON C.CURSO = A.CURSO AND C.TIPO IN ('GRADUACAO','TECNOLOGO')
JOIN LY_UNIDADE_ENSINO UE ON UE.UNIDADE_ENS = C.FACULDADE
WHERE 1=1 AND HM.SITUACAO_HIST NOT IN ('Dispensado','Cancelado','Trancado','Inconcluido')
AND ((@p_ano IS NOT NULL AND HM.ANO = CASE @p_semestre WHEN '1' THEN @p_ano-1 WHEN '2' THEN @p_ano WHEN '11' THEN @p_ano-1 WHEN '22' THEN @p_ano ELSE @p_ano END) OR @p_ano IS NULL)        
AND ((@p_semestre IS NOT NULL AND HM.SEMESTRE = CASE @p_semestre WHEN '1' THEN '2' WHEN '2' THEN '1' WHEN '22' THEN '11' WHEN '11' THEN '22' ELSE @p_semestre END)  OR @p_semestre IS NULL)       
AND ((@p_unidade IS NOT NULL AND C.FACULDADE = @p_unidade) OR @p_unidade IS NULL)       
AND ((@p_tipo IS NOT NULL AND C.TIPO = @p_tipo) OR @p_tipo IS NULL)        
AND ((@p_curso IS NOT NULL AND A.CURSO = @p_curso) OR @p_curso IS NULL)

--APAGANDO ALUNOS DE REINGRESSO QUE ENTRAR�O COMO CALOUROS
DELETE FROM #TEMP_ATIVOS WHERE ANO_INGRESSO = @p_ano AND SEM_INGRESSO = @p_semestre



--INSERINDO ALUNOS CALOUROS NO PERIODO ATUAL
INSERT INTO #TEMP_ATIVOS
SELECT DISTINCT
	NULL AS STATUS_FTC,
	C.FACULDADE AS UNIDADE_ENSINO_ALUNO,
	UE.NOME_COMP AS NOME_UNIDADE_ENSINO_ALUNO,
	A.UNIDADE_FISICA AS UNIDADE_FISICA_ALUNO,
	C.TIPO AS TIPO_CURSO,
	C.CURSO AS CURSO,
	C.NOME AS NOME_CURSO,
	A.CURRICULO AS CURRICULO,
	A.TURNO AS TURNO,
	A.SERIE AS SERIE,
	'CALOURO' AS TIPO_ALUNO,
	A.TIPO_INGRESSO AS TIPO_INGRESSO,
	A.ANO_INGRESSO AS ANO_INGRESSO,
	A.SEM_INGRESSO AS SEM_INGRESSO,
	A.ALUNO AS ALUNO,
	P.CPF AS CPF,
	A.NOME_COMPL AS NOME_ALUNO,
	P.E_MAIL AS E_MAIL,
	ISNULL(P.DDD_FONE_CELULAR,P.DDD_FONE) AS DDD,
	ISNULL(P.FONE,'') AS FONE,
	ISNULL(P.CELULAR,'') AS CELULAR,
	'SEM-MATRICULA' AS SIT_MATRICULA,
	0 AS PAGO,
	0 AS NAO_PAGO
FROM LY_ALUNO A
JOIN LY_PESSOA P ON P.PESSOA = A.PESSOA
JOIN LY_CURSO C ON C.CURSO = A.CURSO AND C.TIPO IN ('GRADUACAO','TECNOLOGO')
JOIN LY_UNIDADE_ENSINO UE ON UE.UNIDADE_ENS = C.FACULDADE
WHERE 1=1
AND ((@p_ano IS NOT NULL AND A.ANO_INGRESSO = @p_ano) OR @p_ano IS NULL)        
AND ((@p_semestre IS NOT NULL AND A.SEM_INGRESSO = @p_semestre)  OR @p_semestre IS NULL)       
AND ((@p_unidade IS NOT NULL AND C.FACULDADE = @p_unidade) OR @p_unidade IS NULL)       
AND ((@p_tipo IS NOT NULL AND C.TIPO = @p_tipo) OR @p_tipo IS NULL)        
AND ((@p_curso IS NOT NULL AND A.CURSO = @p_curso) OR @p_curso IS NULL) 


--CLASSIFICANDO ALUNOS CONCLUINTES E EVADIDOS
UPDATE T SET STATUS_FTC = 'CONCLUIDO'
FROM #TEMP_ATIVOS T 
JOIN LY_H_CURSOS_CONCL H ON H.ALUNO = T.ALUNO
WHERE H.MOTIVO = 'Conclusao'

UPDATE T SET STATUS_FTC = 'EVADIDO'
FROM #TEMP_ATIVOS T 
JOIN LY_H_CURSOS_CONCL H ON H.ALUNO = T.ALUNO
WHERE H.MOTIVO IN ('Abandono','Evasao')

UPDATE T SET STATUS_FTC = 'CANCELADO'
FROM #TEMP_ATIVOS T 
JOIN LY_H_CURSOS_CONCL H ON H.ALUNO = T.ALUNO
WHERE H.MOTIVO IN ('Cancelameto')

--VERIFICANDO MATRICULA ATUAL

UPDATE T SET T.SIT_MATRICULA = CASE VW.SITUACAO_HIST WHEN 'Aprovado' THEN 'MATRICULADO' WHEN 'Rep Nota' THEN 'MATRICULADO' WHEN 'Rep Freq' THEN 'MATRICULADO'	ELSE UPPER(VW.SITUACAO_HIST) END
FROM #TEMP_ATIVOS T
JOIN LY_HISTMATRICULA VW ON VW.ALUNO = T.ALUNO
WHERE 1=1
AND VW.ANO = @p_ano
AND VW.SEMESTRE = @p_semestre
AND VW.SITUACAO_HIST NOT IN ('Cancelado','Trancado','Dispensado','Inconcluido')


--DEFININDO STATUS FTC
	--REMOVE ALUNOS CALUROS QUE NAO SE MATRICULARAM NO PERIODO
	DELETE FROM #TEMP_ATIVOS WHERE SIT_MATRICULA = 'SEM-MATRICULA' AND TIPO_ALUNO = 'CALOURO'
	--ATUALIZA PARA REMATRICULADO OS VETERANOS
	UPDATE #TEMP_ATIVOS SET STATUS_FTC = 'REMATRICULADO'
	WHERE UPPER(SIT_MATRICULA) = 'MATRICULADO' AND TIPO_ALUNO = 'VETERANO' AND STATUS_FTC IS NULL
	--ATUALIZA PARA REMATRICULADO OS CALOUROS
	UPDATE #TEMP_ATIVOS SET STATUS_FTC = 'MATRICULADO'
	WHERE UPPER(SIT_MATRICULA) = 'MATRICULADO' AND TIPO_ALUNO = 'CALOURO' AND STATUS_FTC IS NULL

--IF @p_tipo_relatorio = '1'
--BEGIN

----RESULTADO FINAL
		SELECT 
			STATUS_FTC,
			UNIDADE_ENSINO_ALUNO,
			NOME_UNIDADE_ENSINO_ALUNO,
			UNIDADE_FISICA_ALUNO,
			TIPO_CURSO,
			CURSO,
			NOME_CURSO,
			CURRICULO,
			TURNO,
			SERIE,
			TIPO_ALUNO,
			TIPO_INGRESSO,
			ANO_INGRESSO,
			SEM_INGRESSO,
			ALUNO,
			CPF,
			NOME_ALUNO,
			E_MAIL,
			DDD,
			FONE,
			CELULAR
		FROM #TEMP_ATIVOS
--END

--IF @p_tipo_relatorio = '0'
--BEGIN
--	SELECT STATUS_FTC, COUNT(ALUNO) AS TOTAL_ALUNOS FROM #TEMP_ATIVOS
--	GROUP BY STATUS_FTC
--	UNION
--	SELECT 'TOTAL', COUNT(ALUNO) AS TOTAL_ALUNOS FROM #TEMP_ATIVOS

--END

RETURN

END 



INSERT INTO #TEMP_ATIVOS
SELECT DISTINCT
	NULL AS STATUS_FTC,
	C.FACULDADE AS UNIDADE_ENSINO_ALUNO,
	UE.NOME_COMP AS NOME_UNIDADE_ENSINO_ALUNO,
	A.UNIDADE_FISICA AS UNIDADE_FISICA_ALUNO,
	C.TIPO AS TIPO_CURSO,
	C.CURSO AS CURSO,
	C.NOME AS NOME_CURSO,
	A.CURRICULO AS CURRICULO,
	A.TURNO AS TURNO,
	A.SERIE AS SERIE,
	'VETERANO' AS TIPO_ALUNO,
	A.TIPO_INGRESSO AS TIPO_INGRESSO,
	A.ANO_INGRESSO AS ANO_INGRESSO,
	A.SEM_INGRESSO AS SEM_INGRESSO,
	A.ALUNO AS ALUNO,
	P.CPF AS CPF,
	A.NOME_COMPL AS NOME_ALUNO,
	P.E_MAIL AS E_MAIL,
	ISNULL(P.DDD_FONE_CELULAR,P.DDD_FONE) AS DDD,
	ISNULL(P.FONE,'') AS FONE,
	ISNULL(P.CELULAR,'') AS CELULAR,
	'Sem-Matricula' AS SIT_MATRICULA,
	0 AS PAGO,
	0 AS NAO_PAGO
FROM LY_HISTMATRICULA HM
JOIN LY_ALUNO A ON A.ALUNO = HM.ALUNO
JOIN LY_PESSOA P ON P.PESSOA = A.PESSOA
JOIN LY_CURSO C ON C.CURSO = A.CURSO AND C.TIPO IN ('GRADUACAO','TECNOLOGO')
JOIN LY_UNIDADE_ENSINO UE ON UE.UNIDADE_ENS = C.FACULDADE
WHERE 1=1 AND HM.SITUACAO_HIST NOT IN ('Dispensado','Cancelado','Trancado','Inconcluido')
AND ((@p_ano IS NOT NULL AND HM.ANO = CASE @p_semestre WHEN '1' THEN @p_ano-1 WHEN '2' THEN @p_ano WHEN '11' THEN @p_ano-1 WHEN '22' THEN @p_ano ELSE @p_ano END) OR @p_ano IS NULL)        
AND ((@p_semestre IS NOT NULL AND HM.SEMESTRE = CASE @p_semestre WHEN '1' THEN '2' WHEN '2' THEN '1' WHEN '22' THEN '11' WHEN '11' THEN '22' ELSE @p_semestre END)  OR @p_semestre IS NULL)       
AND ((@p_unidade IS NOT NULL AND C.FACULDADE = @p_unidade) OR @p_unidade IS NULL)       
AND ((@p_tipo IS NOT NULL AND C.TIPO = @p_tipo) OR @p_tipo IS NULL)        
AND ((@p_curso IS NOT NULL AND A.CURSO = @p_curso) OR @p_curso IS NULL)


--2.1 APAGANDO ALUNOS DE REINGRESSO QUE ENTRAR�O COMO CALOUROS
DELETE FROM #TEMP_ATIVOS WHERE ANO_INGRESSO = @p_ano AND SEM_INGRESSO = @p_semestre


--3.0 INSERINDO ALUNOS CALOUROS NO PERIODO ATUAL
INSERT INTO #TEMP_ATIVOS
SELECT DISTINCT
	NULL AS STATUS_FTC,
	C.FACULDADE AS UNIDADE_ENSINO_ALUNO,
	UE.NOME_COMP AS NOME_UNIDADE_ENSINO_ALUNO,
	A.UNIDADE_FISICA AS UNIDADE_FISICA_ALUNO,
	C.TIPO AS TIPO_CURSO,
	C.CURSO AS CURSO,
	C.NOME AS NOME_CURSO,
	A.CURRICULO AS CURRICULO,
	A.TURNO AS TURNO,
	A.SERIE AS SERIE,
	'CALOURO' AS TIPO_ALUNO,
	A.TIPO_INGRESSO AS TIPO_INGRESSO,
	A.ANO_INGRESSO AS ANO_INGRESSO,
	A.SEM_INGRESSO AS SEM_INGRESSO,
	A.ALUNO AS ALUNO,
	P.CPF AS CPF,
	A.NOME_COMPL AS NOME_ALUNO,
	P.E_MAIL AS E_MAIL,
	ISNULL(P.DDD_FONE_CELULAR,P.DDD_FONE) AS DDD,
	ISNULL(P.FONE,'') AS FONE,
	ISNULL(P.CELULAR,'') AS CELULAR,
	'Sem-Matricula' AS SIT_MATRICULA,
	0 AS PAGO,
	0 AS NAO_PAGO
FROM LY_ALUNO A
JOIN LY_PESSOA P ON P.PESSOA = A.PESSOA
JOIN LY_CURSO C ON C.CURSO = A.CURSO AND C.TIPO IN ('GRADUACAO','TECNOLOGO')
JOIN LY_UNIDADE_ENSINO UE ON UE.UNIDADE_ENS = C.FACULDADE
WHERE 1=1
AND ((@p_ano IS NOT NULL AND A.ANO_INGRESSO = @p_ano) OR @p_ano IS NULL)        
AND ((@p_semestre IS NOT NULL AND A.SEM_INGRESSO = @p_semestre)  OR @p_semestre IS NULL)       
AND ((@p_unidade IS NOT NULL AND C.FACULDADE = @p_unidade) OR @p_unidade IS NULL)       
AND ((@p_tipo IS NOT NULL AND C.TIPO = @p_tipo) OR @p_tipo IS NULL)        
AND ((@p_curso IS NOT NULL AND A.CURSO = @p_curso) OR @p_curso IS NULL) 

--4.0 CLASSIFICANDO ALUNOS CONCLUINTES E EVADIDOS
UPDATE T SET STATUS_FTC = 'CONCLUIDO'
FROM #TEMP_ATIVOS T 
JOIN LY_H_CURSOS_CONCL H ON H.ALUNO = T.ALUNO
WHERE H.MOTIVO = 'Conclusao'

UPDATE T SET STATUS_FTC = 'EVADIDO'
FROM #TEMP_ATIVOS T 
JOIN LY_H_CURSOS_CONCL H ON H.ALUNO = T.ALUNO
WHERE H.MOTIVO IN ('Abandono','Evasao')

UPDATE T SET STATUS_FTC = 'CANCELADO'
FROM #TEMP_ATIVOS T 
JOIN LY_H_CURSOS_CONCL H ON H.ALUNO = T.ALUNO
WHERE H.MOTIVO IN ('Cancelameto')

--5.0 VERIFICANDO MATRICULA ATUAL

UPDATE T SET T.SIT_MATRICULA = CASE VW.SIT_MATRICULA WHEN 'Aprovado' THEN 'MATRICULADO' WHEN 'Rep Nota' THEN 'MATRICULADO' WHEN 'Rep Freq' THEN 'MATRICULADO' ELSE VW.SIT_MATRICULA END
FROM #TEMP_ATIVOS T
JOIN VW_MATRICULA_E_PRE_MATRICULA VW ON VW.ALUNO = T.ALUNO
WHERE 1=1
AND VW.ANO = @p_ano
AND VW.SEMESTRE = @p_semestre
AND VW.SIT_MATRICULA NOT IN ('Cancelado','Trancado')

--6.0 VERIFICANDO PAGAMENTOS
UPDATE T SET T.PAGO = 1
FROM #TEMP_ATIVOS T
WHERE EXISTS (SELECT TOP 1 'S' AS TIPO FROM LY_ITEM_CRED IC
				JOIN LY_ITEM_LANC IL ON IL.COBRANCA = IC.COBRANCA
				JOIN LY_LANC_DEBITO LD ON LD.LANC_DEB = IL.LANC_DEB
				WHERE LD.ANO_REF = @p_ano
				AND TIPO_ENCARGO IS NULL AND TIPODESCONTO IS NULL
				AND LD.PERIODO_REF = @p_semestre
				AND LD.ALUNO = T.ALUNO 
				AND LD.CODIGO_LANC IN ('MS','MS_EB')
UNION

--BOLSA 100% NO SEMESTRE
	SELECT TOP 1 'S' AS TIPO FROM LY_BOLSA B
					WHERE B.ALUNO = T.ALUNO AND B.DATA_CANCEL IS NULL 
					AND PERC_VALOR = 'Percentual' AND VALOR = 1
					AND (B.ANOINI >= YEAR(GETDATE()) 
					AND (B.MESINI = CASE WHEN @p_semestre IN ('1','11') THEN 1 WHEN @p_semestre IN ('2','22') THEN 7 ELSE 1 END))
					
UNION
--BOLSA 100% ABERTA		
	SELECT TOP 1 'S' AS TIPO FROM LY_BOLSA B 
					WHERE B.ALUNO = T.ALUNO AND B.DATA_CANCEL IS NULL 
					AND B.PERC_VALOR = 'Percentual' AND B.VALOR = 1
					AND B.ANOFIM IS NULL
					AND B.MESFIM IS NULL
		
UNION
--BOLSA CREDEDUC
	SELECT TOP 1 'S' AS TIPO FROM LY_BOLSA B WHERE B.TIPO_BOLSA = 'CREDEDUC' 
					AND B.ALUNO = T.ALUNO
					AND B.DATA_CANCEL IS NULL
					AND (B.ANOFIM >= YEAR(GETDATE()) OR B.ANOFIM IS NULL) 
					AND (B.MESFIM >= MONTH(GETDATE()) OR B.MESFIM IS NULL)

UNION
--ALUNO CONTRATO FIES
	SELECT TOP 1 'S' AS TIPO FROM LY_CONTRATO_FIES CF
					JOIN LY_CONTRATO_FIES_PERIODO CFP ON CFP.ID_CONTRATO = CF.ID_CONTRATO
					WHERE CFP.ANO = @p_ano AND CFP.PERIODO = @p_semestre AND CF.ALUNO = T.ALUNO
UNION
--COBRAN�A DE MENSALIDADE SEM SALDO A PAGAR
	SELECT TOP 1 'S' FROM VW_COBRANCA VW
					JOIN LY_COBRANCA CO ON CO.COBRANCA = VW.COBRANCA
					JOIN LY_ITEM_LANC IL ON IL.COBRANCA = VW.COBRANCA
					WHERE IL.CODIGO_LANC IN ('Acerto','MS')
					AND CO.NUM_COBRANCA = 1
					AND VW.ALUNO = T.ALUNO
					AND VW.ANO = @p_ano
					AND VW.VALOR <= 0
					AND VW.MES BETWEEN CASE WHEN @p_semestre IN ('1','11') THEN 1 WHEN @p_semestre IN ('2','22') THEN 7 ELSE 1 END AND CASE WHEN @p_semestre IN ('1','11') THEN 6 WHEN @p_semestre IN ('2','22') THEN 12 ELSE 12 END)
					

UPDATE #TEMP_ATIVOS SET NAO_PAGO = 1 WHERE PAGO = 0

--7.0 DEFININDO STATUS FTC

		UPDATE #TEMP_ATIVOS SET STATUS_FTC = 'PRE-MATRICULADO PAGO'
		WHERE SIT_MATRICULA = 'Pre-Matriculado' AND PAGO = 1 AND STATUS_FTC IS NULL

		UPDATE #TEMP_ATIVOS SET STATUS_FTC = 'PRE-MATRICULADO N�O-PAGO'
		WHERE SIT_MATRICULA = 'Pre-Matriculado' AND PAGO = 0 AND STATUS_FTC IS NULL

		UPDATE #TEMP_ATIVOS SET STATUS_FTC = 'MATRICULADO PAGO'
		WHERE SIT_MATRICULA = 'Matriculado' AND PAGO = 1 AND STATUS_FTC IS NULL

		UPDATE #TEMP_ATIVOS SET STATUS_FTC = 'MATRICULADO N�O-PAGO'
		WHERE SIT_MATRICULA = 'Matriculado' AND PAGO = 0 AND STATUS_FTC IS NULL

		UPDATE #TEMP_ATIVOS SET STATUS_FTC = 'N�O REMATRICULADO PAGO'
		WHERE SIT_MATRICULA = 'Sem-Matricula' AND PAGO = 1 AND STATUS_FTC IS NULL

		UPDATE #TEMP_ATIVOS SET STATUS_FTC = 'N�O REMATRICULADO N�O-PAGO'
		WHERE SIT_MATRICULA = 'Sem-Matricula' AND PAGO = 0 AND STATUS_FTC IS NULL

--RESULTADO FINAL
		SELECT 
			STATUS_FTC,
			UNIDADE_ENSINO_ALUNO,
			NOME_UNIDADE_ENSINO_ALUNO,
			UNIDADE_FISICA_ALUNO,
			TIPO_CURSO,
			CURSO,
			NOME_CURSO,
			CURRICULO,
			TURNO,
			SERIE,
			TIPO_ALUNO,
			TIPO_INGRESSO,
			ANO_INGRESSO,
			SEM_INGRESSO,
			ALUNO,
			CPF,
			NOME_ALUNO,
			E_MAIL,
			DDD,
			FONE,
			CELULAR
		FROM #TEMP_ATIVOS

--[FIM]
END
GO

DELETE FROM LY_CUSTOM_CLIENTE    
where NOME = 'FTC_Relat_BaseAtivosGraduacao'    
and IDENTIFICACAO_CODIGO = '0001' 
GO

INSERT INTO LY_CUSTOM_CLIENTE
(NOME, IDENTIFICACAO_CODIGO, AUTOR, DATA_CRIACAO, OBJETIVO, SOLICITADO_POR, ATIVO, TIPOCOMPONENTE, TIPO, CLIENTE)
SELECT
  'FTC_Relat_BaseAtivosGraduacao' NOME
, '0001' IDENTIFICAO_CODIGO
, 'Miguel' AUTOR
, '2018-10-16' DATA_CRIACAO
, 'Relat�rio - Base de Ativos Gradua��o' OBJETIVO
, 'Josane Oliveira' SOLICITADO_POR
, 'S' ATIVO
, 'PROCEDURE' TIPOCOMPONENTE
, 'CLIENTE' TIPO
, 'FTC' CLIENTE
GO 
