USE FTC_DATAMART
GO

--EXEC BI_BB_MAPA_ACESSOS_JOB 2020,1

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.BI_BB_MAPA_ACESSOS_JOB'))
   exec('CREATE PROCEDURE [dbo].[BI_BB_MAPA_ACESSOS_JOB] AS BEGIN SET NOCOUNT OFF; END')
GO 

ALTER PROCEDURE dbo.BI_BB_MAPA_ACESSOS_JOB
(				
  @p_ano VARCHAR(4)      
, @p_semestre VARCHAR(2)      

)            
AS            
-- [IN�CIO]                    
BEGIN 

IF EXISTS (SELECT * FROM sys.tables WHERE type = 'U' AND OBJECT_ID = OBJECT_ID('dbo.#DATAS'))   
BEGIN
	DROP TABLE #DATAS
END 

CREATE TABLE #DATAS 
(
	DATA VARCHAR(10)
)

SET DATEFIRST  7, -- 1 = Monday, 7 = Sunday
    DATEFORMAT mdy, 
    LANGUAGE   US_ENGLISH;
-- assume the above is here in all subsequent code blocks.
DECLARE @StartDate  date = '20200323';

DECLARE @CutoffDate date = GETDATE();

;WITH seq(n) AS 
(
  SELECT 0 UNION ALL SELECT n + 1 FROM seq
  WHERE n < DATEDIFF(DAY, @StartDate, @CutoffDate)
),
d(d) AS 
(
  SELECT DATEADD(DAY, n, @StartDate) FROM seq
)

INSERT INTO #DATAS
SELECT d DATA FROM d
ORDER BY d
OPTION (MAXRECURSION 0);


IF EXISTS (SELECT * FROM sys.tables WHERE type = 'U' AND OBJECT_ID = OBJECT_ID('dbo.BI_BB_MAPA_ACESSOS'))   
BEGIN
	DROP TABLE BI_BB_MAPA_ACESSOS
END 

CREATE TABLE BI_BB_MAPA_ACESSOS (
	ANO VARCHAR(4),
	SEMESTRE VARCHAR(2),
	DATA VARCHAR(10),
	ALUNO VARCHAR(20),
	ACESSOU SMALLINT,
    PRIMARY KEY (ANO,SEMESTRE,DATA,ALUNO)
)


INSERT INTO BI_BB_MAPA_ACESSOS
SELECT DISTINCT ANO,SEMESTRE,DATA, BI.ALUNO, 0 AS ACESSOU 
FROM #DATAS D
LEFT JOIN BI_REMATRICULA BI
ON BI.ALUNO = BI.ALUNO
WHERE BI.ANO = @p_ano AND BI.SEMESTRE = @p_semestre
--AND EXISTS (SELECT TOP 1 1 FROM BI_BB_ACESSO_ALUNO BB WHERE BB.ALUNO = BI.ALUNO)
ORDER BY DATA,ALUNO

--SELECT COUNT(DATA),ALUNO FROM BI_BB_MAPA_ACESSOS 
--GROUP BY ALUNO

UPDATE BB SET ACESSOU = 1
FROM BI_BB_MAPA_ACESSOS BB
WHERE EXISTS (
				SELECT TOP 1 1
				FROM BI_BB_ACESSO_ALUNO BB2
				WHERE BB2.ALUNO = BB.ALUNO AND BB.DATA = CONVERT(VARCHAR(10),BB2.ULTIMO_LOGIN,23)
)

END