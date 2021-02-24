
USE FTC_DATAMART
GO

--EXEC BI_REMATRICULA_JOB 2018,2

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.BI_REMATRICULA_JOB'))
   exec('CREATE PROCEDURE [dbo].[BI_REMATRICULA_JOB] AS BEGIN SET NOCOUNT OFF; END')
GO 

ALTER PROCEDURE dbo.BI_REMATRICULA_JOB
(            
  @p_ano VARCHAR(4)      
, @p_semestre VARCHAR(2)      

)            
AS            
-- [IN�CIO]                    
BEGIN  

IF EXISTS (SELECT * FROM sys.tables WHERE type = 'U' AND OBJECT_ID = OBJECT_ID('dbo.BI_REMATRICULA'))   
BEGIN
	DELETE FROM BI_REMATRICULA WHERE ANO = @p_ano AND SEMESTRE = @p_semestre
END

ELSE


CREATE TABLE BI_REMATRICULA 
(
	[ANO] VARCHAR(4),
	[SEMESTRE] VARCHAR(2),
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
	[NAO_PAGO] SMALLINT,
	[TIPO_FINAN] VARCHAR(50),
	[FINAN] VARCHAR(10)
	
)       


--1.0 CRIACAO DA TABELA TEMPORARIA DE ATIVOS

IF EXISTS (SELECT * FROM sys.tables WHERE type = 'U' AND OBJECT_ID = OBJECT_ID('dbo.TEMP_REMATRICULA'))   
BEGIN
	DROP TABLE TEMP_REMATRICULA 
END

CREATE TABLE TEMP_REMATRICULA 
(
	[ANO] VARCHAR(4),
	[SEMESTRE] VARCHAR(2),
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
	[NAO_PAGO] SMALLINT,
	[TIPO_FINAN] VARCHAR(50),
	[FINAN] VARCHAR(10)
	
)       

--2.0 PRIMEIRA CARGA COM ALUNOS QUE ESTUDARAM NO PERIODO ANTERIOR AO SELECIONADO
INSERT INTO TEMP_REMATRICULA
SELECT DISTINCT
	@p_ano AS ANO,
	@p_semestre AS SEMESTRE,
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
	0 AS NAO_PAGO,
	NULL AS TIPO_FINAN,
	NULL AS FINAN
FROM LYCEUM..LY_HISTMATRICULA HM
JOIN LYCEUM..LY_ALUNO A ON A.ALUNO = HM.ALUNO
JOIN LYCEUM..LY_PESSOA P ON P.PESSOA = A.PESSOA
JOIN LYCEUM..LY_CURSO C ON C.CURSO = A.CURSO AND C.TIPO IN ('GRADUACAO','TECNOLOGO','GRADUACAO-EAD','GRADUACAO-SP')
JOIN LYCEUM..LY_UNIDADE_ENSINO UE ON UE.UNIDADE_ENS = C.FACULDADE
WHERE 1=1 AND HM.SITUACAO_HIST NOT IN ('Dispensado','Cancelado','Trancado','Inconcluido')
AND ((@p_ano IS NOT NULL AND HM.ANO = CASE @p_semestre WHEN '1' THEN @p_ano-1 WHEN '2' THEN @p_ano WHEN '11' THEN @p_ano-1 WHEN '22' THEN @p_ano ELSE @p_ano END) OR @p_ano IS NULL)        
AND ((@p_semestre IS NOT NULL AND HM.SEMESTRE = CASE @p_semestre WHEN '1' THEN '2' WHEN '2' THEN '1' WHEN '22' THEN '11' WHEN '11' THEN '22' ELSE @p_semestre END)  OR @p_semestre IS NULL)       


--2.1 APAGANDO ALUNOS DE REINGRESSO QUE ENTRAR�O COMO CALOUROS
DELETE FROM TEMP_REMATRICULA WHERE ANO_INGRESSO = @p_ano AND SEM_INGRESSO = @p_semestre


--3.0 INSERINDO ALUNOS CALOUROS NO PERIODO ATUAL
INSERT INTO TEMP_REMATRICULA
SELECT DISTINCT
	A.ANO_INGRESSO AS ANO,
	A.SEM_INGRESSO AS SEMESTRE,
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
	0 AS NAO_PAGO,
	NULL AS TIPO_FINAN,
	NULL AS FINAN
FROM LYCEUM..LY_ALUNO A
JOIN LYCEUM..LY_PESSOA P ON P.PESSOA = A.PESSOA
JOIN LYCEUM..LY_CURSO C ON C.CURSO = A.CURSO AND C.TIPO IN ('GRADUACAO','TECNOLOGO')
JOIN LYCEUM..LY_UNIDADE_ENSINO UE ON UE.UNIDADE_ENS = C.FACULDADE
WHERE 1=1
AND ((@p_ano IS NOT NULL AND A.ANO_INGRESSO = @p_ano) OR @p_ano IS NULL)        
AND ((@p_semestre IS NOT NULL AND A.SEM_INGRESSO = @p_semestre)  OR @p_semestre IS NULL)       


--4.0 CLASSIFICANDO ALUNOS CONCLUINTES E EVADIDOS
UPDATE T SET STATUS_FTC = 'CONCLUIDO'
FROM TEMP_REMATRICULA T 
JOIN LYCEUM..LY_H_CURSOS_CONCL H ON H.ALUNO = T.ALUNO
WHERE H.MOTIVO = 'Conclusao'

UPDATE T SET STATUS_FTC = 'CONCLUIDO'
FROM TEMP_REMATRICULA T 
WHERE LYCEUM.dbo.fn_FTC_QTD_DISC_PENDENTE(T.ALUNO,'N') = 0

UPDATE T SET STATUS_FTC = 'EVADIDO'
FROM TEMP_REMATRICULA T 
JOIN LYCEUM..LY_H_CURSOS_CONCL H ON H.ALUNO = T.ALUNO
WHERE H.MOTIVO IN ('Abandono','Evasao')

UPDATE T SET STATUS_FTC = 'CANCELADO'
FROM TEMP_REMATRICULA T 
JOIN LYCEUM..LY_H_CURSOS_CONCL H ON H.ALUNO = T.ALUNO
WHERE H.MOTIVO IN ('Cancelameto')

--5.0 VERIFICANDO MATRICULA ATUAL

UPDATE T SET T.SIT_MATRICULA = CASE VW.SIT_MATRICULA WHEN 'Aprovado' THEN 'MATRICULADO' WHEN 'Rep Nota' THEN 'MATRICULADO' WHEN 'Rep Freq' THEN 'MATRICULADO' ELSE VW.SIT_MATRICULA END
FROM TEMP_REMATRICULA T
JOIN LYCEUM..VW_MATRICULA_E_PRE_MATRICULA VW ON VW.ALUNO = T.ALUNO
WHERE 1=1
AND VW.ANO = @p_ano
AND VW.SEMESTRE = @p_semestre
AND VW.SIT_MATRICULA NOT IN ('Cancelado','Trancado')

--6.0 VERIFICANDO PAGAMENTOS
UPDATE T SET T.PAGO = 1
FROM TEMP_REMATRICULA T
WHERE EXISTS (SELECT TOP 1 'S' AS TIPO FROM LYCEUM..LY_ITEM_CRED IC
				JOIN LYCEUM..LY_ITEM_LANC IL ON IL.COBRANCA = IC.COBRANCA
				JOIN LYCEUM..LY_LANC_DEBITO LD ON LD.LANC_DEB = IL.LANC_DEB
				WHERE LD.ANO_REF = @p_ano
				AND TIPO_ENCARGO IS NULL AND TIPODESCONTO IS NULL
				AND LD.PERIODO_REF = @p_semestre
				AND LD.ALUNO = T.ALUNO 
				AND LD.CODIGO_LANC IN ('MS','MS_EB')
UNION

--BOLSA 100% NO SEMESTRE
	SELECT TOP 1 'S' AS TIPO FROM LYCEUM..LY_BOLSA B
					WHERE B.ALUNO = T.ALUNO AND B.DATA_CANCEL IS NULL 
					AND PERC_VALOR = 'Percentual' AND VALOR = 1
					AND (B.ANOINI >= YEAR(GETDATE()) 
					AND (B.MESINI = CASE WHEN @p_semestre IN ('1','11') THEN 1 WHEN @p_semestre IN ('2','22') THEN 7 ELSE 1 END))
					
UNION
--BOLSA 100% ABERTA		
	SELECT TOP 1 'S' AS TIPO FROM LYCEUM..LY_BOLSA B 
					WHERE B.ALUNO = T.ALUNO AND B.DATA_CANCEL IS NULL 
					AND B.PERC_VALOR = 'Percentual' AND B.VALOR = 1
					AND B.ANOFIM IS NULL
					AND B.MESFIM IS NULL
		
UNION
--BOLSA CREDEDUC
	SELECT TOP 1 'S' AS TIPO FROM LYCEUM..LY_BOLSA B WHERE B.TIPO_BOLSA = 'CREDEDUC' 
					AND B.ALUNO = T.ALUNO
					AND B.DATA_CANCEL IS NULL
					AND (B.ANOFIM >= YEAR(GETDATE()) OR B.ANOFIM IS NULL) 
					AND (B.MESFIM >= MONTH(GETDATE()) OR B.MESFIM IS NULL)

UNION
--ALUNO CONTRATO FIES
	SELECT TOP 1 'S' AS TIPO FROM LYCEUM..LY_CONTRATO_FIES CF
					JOIN LYCEUM..LY_CONTRATO_FIES_PERIODO CFP ON CFP.ID_CONTRATO = CF.ID_CONTRATO
					WHERE CFP.ANO = @p_ano AND CFP.PERIODO = @p_semestre AND CF.ALUNO = T.ALUNO
UNION
--COBRAN�A DE MENSALIDADE SEM SALDO A PAGAR
	SELECT TOP 1 'S' FROM LYCEUM..VW_COBRANCA VW
					JOIN LYCEUM..LY_COBRANCA CO ON CO.COBRANCA = VW.COBRANCA
					JOIN LYCEUM..LY_ITEM_LANC IL ON IL.COBRANCA = VW.COBRANCA
					WHERE IL.CODIGO_LANC IN ('Acerto','MS')
					AND CO.NUM_COBRANCA = 1
					AND VW.ALUNO = T.ALUNO
					AND VW.ANO = @p_ano
					AND VW.VALOR <= 0
					AND VW.MES BETWEEN CASE WHEN @p_semestre IN ('1','11') THEN 1 WHEN @p_semestre IN ('2','22') THEN 7 ELSE 1 END AND CASE WHEN @p_semestre IN ('1','11') THEN 6 WHEN @p_semestre IN ('2','22') THEN 12 ELSE 12 END)
					

UPDATE TEMP_REMATRICULA SET NAO_PAGO = 1 WHERE PAGO = 0



--6.1 DEFININDO FINAN

UPDATE T SET FINAN = 'PAGO'
FROM TEMP_REMATRICULA T
WHERE T.PAGO = 1

UPDATE T SET FINAN = 'N�O-PAGO'
FROM TEMP_REMATRICULA T
WHERE T.PAGO = 0


--7.0 DEFININDO STATUS FTC

		UPDATE TEMP_REMATRICULA SET STATUS_FTC = 'PRE-MATRICULADO PAGO'
		WHERE SIT_MATRICULA = 'Pre-Matriculado' AND PAGO = 1 AND STATUS_FTC IS NULL

		UPDATE TEMP_REMATRICULA SET STATUS_FTC = 'PRE-MATRICULADO N�O-PAGO'
		WHERE SIT_MATRICULA = 'Pre-Matriculado' AND PAGO = 0 AND STATUS_FTC IS NULL

		UPDATE TEMP_REMATRICULA SET STATUS_FTC = 'MATRICULADO PAGO'
		WHERE SIT_MATRICULA = 'Matriculado' AND PAGO = 1 AND STATUS_FTC IS NULL

		UPDATE TEMP_REMATRICULA SET STATUS_FTC = 'MATRICULADO N�O-PAGO'
		WHERE SIT_MATRICULA = 'Matriculado' AND PAGO = 0 AND STATUS_FTC IS NULL

		UPDATE TEMP_REMATRICULA SET STATUS_FTC = 'N�O REMATRICULADO PAGO'
		WHERE SIT_MATRICULA = 'Sem-Matricula' AND PAGO = 1 AND STATUS_FTC IS NULL

		UPDATE TEMP_REMATRICULA SET STATUS_FTC = 'N�O REMATRICULADO N�O-PAGO'
		WHERE SIT_MATRICULA = 'Sem-Matricula' AND PAGO = 0 AND STATUS_FTC IS NULL

--8.0 DEFININDO TIPO_FINAN
UPDATE BI SET BI.TIPO_FINAN = 'PROUNI PARCIAL' 
FROM TEMP_REMATRICULA BI WHERE EXISTS (
select TOP 1 1 
FROM LYCEUM..LY_BOLSA B
JOIN LYCEUM..LY_TIPO_BOLSA TB ON TB.TIPO_BOLSA = B.TIPO_BOLSA
WHERE B.ALUNO = BI.ALUNO
AND B.TIPO_BOLSA IN ('PROUNI_50','PROUNI50') 
AND TB.GRUPO_BOLSA = 'PROUNI' 
AND (B.ANOFIM IS NULL OR B.ANOFIM >= YEAR(GETDATE())) 
AND (B.MESFIM IS NULL OR B.MESFIM >= MONTH(GETDATE())))

UPDATE BI SET BI.TIPO_FINAN = 'PROUNI INTEGRAL' 
FROM TEMP_REMATRICULA BI WHERE EXISTS (
select TOP 1 1 
FROM LYCEUM..LY_BOLSA B
JOIN LYCEUM..LY_TIPO_BOLSA TB ON TB.TIPO_BOLSA = B.TIPO_BOLSA
WHERE B.ALUNO = BI.ALUNO
AND B.TIPO_BOLSA IN ('PROUNI_100','PROUNI100') 
AND TB.GRUPO_BOLSA = 'PROUNI' 
AND (B.ANOFIM IS NULL OR B.ANOFIM >= YEAR(GETDATE())) 
AND (B.MESFIM IS NULL OR B.MESFIM >= MONTH(GETDATE())))

UPDATE BI SET BI.TIPO_FINAN = 'PROIES' 
FROM TEMP_REMATRICULA BI WHERE EXISTS (
select TOP 1 1 
FROM LYCEUM..LY_BOLSA B
JOIN LYCEUM..LY_TIPO_BOLSA TB ON TB.TIPO_BOLSA = B.TIPO_BOLSA
WHERE B.ALUNO = BI.ALUNO
AND B.TIPO_BOLSA = 'PROIES100'
AND TB.GRUPO_BOLSA = 'PROIES' 
AND (B.ANOFIM IS NULL OR B.ANOFIM >= YEAR(GETDATE())) 
AND (B.MESFIM IS NULL OR B.MESFIM >= MONTH(GETDATE())))

UPDATE BI SET BI.TIPO_FINAN = 'FIES' 
FROM TEMP_REMATRICULA BI WHERE EXISTS (
select TOP 1 1 
FROM LYCEUM..LY_BOLSA B
JOIN LYCEUM..LY_TIPO_BOLSA TB ON TB.TIPO_BOLSA = B.TIPO_BOLSA
WHERE B.ALUNO = BI.ALUNO
AND TB.GRUPO_BOLSA = 'FIES' 
AND (B.ANOFIM IS NULL OR B.ANOFIM >= YEAR(GETDATE())) 
AND (B.MESFIM IS NULL OR B.MESFIM >= MONTH(GETDATE())))

UPDATE TEMP_REMATRICULA SET TIPO_FINAN = 'PAGANTES'
WHERE TIPO_FINAN IS NULL



--RESULTADO FINAL
		INSERT INTO BI_REMATRICULA
		SELECT
			ANO,
			SEMESTRE, 
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
			CELULAR,
			SIT_MATRICULA,
			PAGO,
			NAO_PAGO,
			TIPO_FINAN,
			FINAN
		FROM TEMP_REMATRICULA


DROP TABLE TEMP_REMATRICULA

--[FIM]
END
GO