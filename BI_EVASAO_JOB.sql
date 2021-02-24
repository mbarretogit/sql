USE FTC_DATAMART
GO

--EXEC BI_EVASAO_JOB

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.BI_EVASAO_JOB'))
   exec('CREATE PROCEDURE [dbo].[BI_EVASAO_JOB] AS BEGIN SET NOCOUNT OFF; END')
GO 
 
ALTER PROCEDURE dbo.BI_EVASAO_JOB       
         
AS            
-- [IN�CIO]                    
BEGIN 

IF (NOT EXISTS (SELECT * 
                 FROM FTC_DATAMART.INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_NAME = 'BI_EVASAO'))
BEGIN


CREATE TABLE BI_EVASAO
(
	COD_UNIDADE_FISICA VARCHAR(20),
	NOME_UNIDADE_FISICA VARCHAR(200),
	TIPO_CURSO VARCHAR(20),
	COD_CURSO VARCHAR(20),
	NOME_CURSO VARCHAR(200),
	CURRICULO VARCHAR(20),
	TURNO VARCHAR(20),
	TIPO_INGRESSO VARCHAR(20),
	ANO_INGRESSO VARCHAR(4),
	SEM_INGRESSO VARCHAR(2),
	SITUACAO_ALUNO VARCHAR(30),
	ALUNO VARCHAR(20),
	NOME_ALUNO VARCHAR(200),
	DT_ENCERRAMENTO DATETIME,
	ANO_ENCERRAMENTO VARCHAR(4),
	SEM_ENCERRAMENTO VARCHAR(2),
	MOTIVO_ENCERRAMENTO VARCHAR(30),
	CAUSA_ENCERRAMENTO VARCHAR(20)	,
	PERIODO_ENCERRAMENTO VARCHAR(7)
)

END
ELSE 
	DELETE FROM BI_EVASAO


INSERT INTO BI_EVASAO 
SELECT  UF.UNIDADE_FIS AS COD_UNIDADE_FISICA, 
		UF.NOME_COMP AS NOME_UNIDADE_FISICA, 
		C.TIPO AS TIPO_CURSO, 
		C.CURSO AS COD_CURSO, 
		C.NOME AS NOME_CURSO, 
		A.CURRICULO, 
		A.TURNO,
		A.TIPO_INGRESSO, 
		A.ANO_INGRESSO, 
		A.SEM_INGRESSO,
		A.SIT_ALUNO AS SITUACAO_ALUNO,
		A.ALUNO, 
		A.NOME_COMPL AS NOME_ALUNO, 
		HCC.DT_ENCERRAMENTO, 
		HCC.ANO_ENCERRAMENTO, 
		HCC.SEM_ENCERRAMENTO,
		HCC.MOTIVO AS MOTIVO_ENCERRAMENTO,
		HCC.CAUSA_ENCERR AS CAUSA_ENCERRAMENTO,
		'1900/1' AS PERIODO_ENCERRAMENTO
FROM LYCEUM..LY_ALUNO A
JOIN LYCEUM..LY_H_CURSOS_CONCL HCC ON HCC.ALUNO = A.ALUNO
JOIN LYCEUM..LY_CURSO C ON C.CURSO = A.CURSO
JOIN LYCEUM..LY_UNIDADE_FISICA UF ON UF.UNIDADE_FIS = A.UNIDADE_FISICA
WHERE 1=1
AND A.SIT_ALUNO IN ('Evadido','Cancelado') AND HCC.DT_REABERTURA IS NULL


-- ## SANEAMENTO DE CASOS AN�MALOS ## --

--1. DATA ENCERRAMENTO 1900
--1.1 CASOS QUE POSSUI ANO E SEMESTRE ENCERRAMENTO COLOCAR ULTIMA DATA DO PERIODO CORRESPONDENTE
UPDATE E 
	SET E.DT_ENCERRAMENTO = CONCAT(E.ANO_ENCERRAMENTO,'-',CASE WHEN E.SEM_ENCERRAMENTO = 1 THEN '06' ELSE '12' END,'-','30')
FROM BI_EVASAO E
WHERE E.DT_ENCERRAMENTO = '1900-01-01' AND E.ANO_ENCERRAMENTO <> 1900


--1.2 CASOS QUE NAO POSSUI ANO E SEMESTRE DE ENCERRAMENTO MAS POSSUI HISTORICO DEVEM TER INSERIDO O ULTIMO PERIODO ESTUDADO PELO ALUNO
IF EXISTS (SELECT * FROM sys.tables WHERE type = 'U' AND OBJECT_ID = OBJECT_ID('dbo.TEMP_PERIODO_ENCERRAMENTO'))   
BEGIN
	DROP TABLE TEMP_PERIODO_ENCERRAMENTO
END


SELECT	MAX(CONCAT(HM.ANO,HM.SEMESTRE)) AS PERIODO_ENCERRAMENTO, 
		E.ALUNO, 
		NULL AS ANO_ENCERRAMENTO, 
		NULL AS SEM_ENCERRAMENTO
INTO TEMP_PERIODO_ENCERRAMENTO --DROP TABLE TEMP_PERIODO_ENCERRAMENTO
FROM BI_EVASAO E 
JOIN LYCEUM..LY_HISTMATRICULA HM ON HM.ALUNO = E.ALUNO
WHERE E.DT_ENCERRAMENTO = '1900-01-01'  OR E.ANO_ENCERRAMENTO = 1900
GROUP BY E.ALUNO
ORDER BY E.ALUNO


UPDATE	TEMP_PERIODO_ENCERRAMENTO 
	SET	ANO_ENCERRAMENTO = SUBSTRING(PERIODO_ENCERRAMENTO,1,4), 
		SEM_ENCERRAMENTO = SUBSTRING(PERIODO_ENCERRAMENTO,5,2)


-- CASO DE ENCERRAMENTO EM PERIODO DE FERIAS ALTERAR PARA PERIODO REGULAR
UPDATE	TEMP_PERIODO_ENCERRAMENTO
	SET SEM_ENCERRAMENTO = '1' 
WHERE SEM_ENCERRAMENTO = '11'


UPDATE	TEMP_PERIODO_ENCERRAMENTO 
	SET SEM_ENCERRAMENTO = '2' 
WHERE SEM_ENCERRAMENTO = '22'


UPDATE	E 
	SET E.DT_ENCERRAMENTO = CONCAT(T.ANO_ENCERRAMENTO,'-',CASE WHEN T.SEM_ENCERRAMENTO = 1 THEN '06' ELSE '12' END,'-','30'), 
		E.ANO_ENCERRAMENTO = T.ANO_ENCERRAMENTO,
		E.SEM_ENCERRAMENTO =  T.SEM_ENCERRAMENTO
FROM BI_EVASAO E
JOIN TEMP_PERIODO_ENCERRAMENTO T ON T.ALUNO = E.ALUNO
WHERE E.DT_ENCERRAMENTO = '1900-01-01'  OR E.ANO_ENCERRAMENTO = 1900

IF EXISTS (SELECT * FROM sys.tables WHERE type = 'U' AND OBJECT_ID = OBJECT_ID('dbo.TEMP_PERIODO_ENCERRAMENTO'))   
BEGIN
	DROP TABLE TEMP_PERIODO_ENCERRAMENTO
END

--1.3 CASOS QUE NAO POSSUI ANO E SEMESTRE DE ENCERRAMENTO E N�O POSSUI HISTORICO COLOCAR O ANO E SEMESTRE DE INGRESSO

UPDATE	E 
	SET E.DT_ENCERRAMENTO = CONCAT(E.ANO_INGRESSO,'-',CASE WHEN E.SEM_INGRESSO = 1 THEN '06' ELSE '12' END,'-','30'), 
		E.ANO_ENCERRAMENTO = E.ANO_INGRESSO, 
		E.SEM_ENCERRAMENTO =  E.SEM_INGRESSO
FROM BI_EVASAO E
WHERE E.DT_ENCERRAMENTO = '1900-01-01'  OR E.ANO_ENCERRAMENTO = 1900


-- 2. MOTIVO DE ENCERRAMENTO
--2.1 MOTIVO ABANDONO E ALUNO CANCELADO ALTERAR PARA ALUNO EVADIDO
UPDATE BI_EVASAO
	SET SITUACAO_ALUNO = 'Evadido'
WHERE MOTIVO_ENCERRAMENTO = 'ABANDONO' AND SITUACAO_ALUNO = 'Cancelado'


--2.2 MOTIVO ABANDONO E ALUNO EVADIDO ALTERAR PARA EVASAO
UPDATE BI_EVASAO
	SET MOTIVO_ENCERRAMENTO = 'Evasao'
WHERE MOTIVO_ENCERRAMENTO = 'ABANDONO' AND SITUACAO_ALUNO = 'Evadido'


--2.3 MOTIVO CANCELAMENTO OU TRANSFERENCIA E ALUNO EVADIDO ALTERAR PARA ALUNO CANCELADO
UPDATE BI_EVASAO
	SET SITUACAO_ALUNO = 'Cancelado'
WHERE MOTIVO_ENCERRAMENTO IN ('Cancelamento','Transferencia') AND SITUACAO_ALUNO = 'Evadido'


--2.4 MOTIVO CONCLUSAO DEVE SER RETIRADO DA DIMENSAO
DELETE FROM BI_EVASAO WHERE MOTIVO_ENCERRAMENTO = 'CONCLUSAO'


--2.5 UNIFICANDO CAUSAS_ENCERRAMENTO
UPDATE BI_EVASAO
	SET CAUSA_ENCERRAMENTO = 'OUTROS'
WHERE CAUSA_ENCERRAMENTO IN ('outos','outro','OUTRAS')


UPDATE BI_EVASAO
	SET CAUSA_ENCERRAMENTO = 'NI'
WHERE CAUSA_ENCERRAMENTO IS NULL OR CAUSA_ENCERRAMENTO = ''


--2.6 ALUNO COM MOTIVO_ENCERRAMENTO EVASAO O SITUACAO_ALUNO EVADIDO
UPDATE BI_EVASAO
	SET SITUACAO_ALUNO = 'Evadido'
WHERE MOTIVO_ENCERRAMENTO = 'Evasao' AND SITUACAO_ALUNO = 'Cancelado'



--3 POPULANDO A PERIODO ENCERRAMENTO

UPDATE BI_EVASAO
	SET PERIODO_ENCERRAMENTO = CONCAT(ANO_ENCERRAMENTO,'/',SEM_ENCERRAMENTO)

--## REMOVENDO CASOS RESTANTES E QUE N�O DEVEM SER UTILIZADOS ##--

--1. CASOS DE DATA 1900
DELETE FROM BI_EVASAO 
where ano_encerramento = 1900

--[FIM]
END