USE LYCEUM
GO  
  
 --EXEC s_RENDIMENTO '2018','1','03',NULL,NULL,NULL,NULL,'GLOBAL','SEMESTRAL','INDICE'

ALTER PROCEDURE [dbo].[s_RENDIMENTO] (      
  @p_ANO  NUMERIC(5),      
  @p_SEMESTRE NUMERIC(5),      
  @p_FACULDADE VARCHAR(20),      
  @p_CURSO  VARCHAR(20),      
  @p_TURNO  VARCHAR(20),      
  @p_SERIE  VARCHAR(20),      
  @p_CURRRICULO VARCHAR(20),      
  @p_CRITERIO VARCHAR(20),      
  @p_AVALIACAO  VARCHAR(20),       
  @p_DESCRICAO  VARCHAR(20)      
)      
AS      
  
----====================PARAMETROS DE TESTE====================  
--DECLARE   
--@p_ANO  NUMERIC(5),      
--@p_SEMESTRE NUMERIC(5),      
--@p_FACULDADE VARCHAR(20),      
--@p_CURSO  VARCHAR(20),      
--@p_TURNO  VARCHAR(20),      
--@p_SERIE  VARCHAR(20),      
--@p_CURRRICULO VARCHAR(20),      
--@p_CRITERIO VARCHAR(20),      
--@p_AVALIACAO  VARCHAR(20),       
--@p_DESCRICAO  VARCHAR(20)       
  
  
--SET  @p_ANO =  '2015'     
--SET  @p_SEMESTRE = '2'   
--SET  @p_FACULDADE = '04'  
--SET  @p_CURSO = '333'  
--SET  @p_TURNO = NULL  
--SET  @p_SERIE = NULL  
--SET  @p_CURRRICULO = NULL  
--SET  @p_CRITERIO =   'Periodo' -- 'geral'   
--SET  @p_AVALIACAO =  NULL   
--SET  @p_DESCRICAO  =  NULL    
----====================PARAMETROS DE TESTE====================  
  
IF @p_CURSO   = '' SET @p_CURSO = NULL        
IF @p_TURNO   = '' SET @p_TURNO = NULL        
IF @p_CURRRICULO = '' SET @p_CURRRICULO = NULL        
IF @p_SERIE   = '' SET @p_SERIE = NULL    
  
IF @p_CRITERIO = 'PERIODO'    
 BEGIN        
        
   IF OBJECT_ID('TEMPDB..#TMP_IND') IS NOT NULL  
   BEGIN  
   DROP TABLE #TMP_IND  
   END  

--CRIAR TABELA TEMPORARIA #TMP_IND

CREATE TABLE #TMP_IND (
	ALUNO VARCHAR(20),
	UNIDADE_FISICA VARCHAR(20),
	CURSO VARCHAR(20),
	ANO NUMERIC(5),
	SEMESTRE NUMERIC(5),
	CR NUMERIC(10,2)
)      
  
  INSERT INTO #TMP_IND
  SELECT  ALUNO      
      ,UNIDADE_FISICA     
      ,CURSO      
      ,ANO  
      ,SEMESTRE                            
      ,CONVERT(NUMERIC(10,4),(avg(CONVERT(NUMERIC (10,2),CR)))) AS CR  -- Calcula o rendimento do aluno  
  --INTO #TMP_IND  
  FROM  
    -- Seleciona somente aluno com dsiciplina ANO <= 2013 e com notas <= 10  
   (SELECT A.ALUNO,      
    A.UNIDADE_FISICA,      
    A.CURSO,      
    H.ANO,  
    H.SEMESTRE,                            
      CONVERT(NUMERIC(10,2),replace(isnull(H.NOTA_FINAL,'0'),',','.'))  AS CR   
   FROM LY_ALUNO   A        
   JOIN LY_HISTMATRICULA H   
    ON H.ALUNO = A.ALUNO   
   JOIN LY_GRADE         G     
    ON  G.CURSO             =   A.CURSO      
    AND G.TURNO         =   A.TURNO      
    AND G.CURRICULO     =   A.CURRICULO      
    AND (G.DISCIPLINA   =   H.DISCIPLINA      
     OR  G.FORMULA_EQUIV LIKE '%'+H.DISCIPLINA+'%')
	JOIN LY_CURSO C 
		ON C.CURSO = A.CURSO         
   WHERE 1=1      
    AND ISNUMERIC(replace(isnull(H.NOTA_FINAL,'0'),',','.')) = 1   
    AND replace(isnull(H.NOTA_FINAL,'0'),',','.') <> '-'   
    AND CONVERT(NUMERIC(10,2),replace(isnull(H.NOTA_FINAL,'0'),',','.')) <= 10  
    AND H.ANO <= 2013  
    AND H.SITUACAO_HIST IN ('APROVADO','REP NOTA','REP FREQ')          
    AND (A.SIT_ALUNO = 'ATIVO'     
       OR EXISTS (SELECT 1    
        FROM LY_H_CURSOS_CONCL    
        WHERE ALUNO = A.ALUNO    
        AND  MOTIVO in ('Conclusao', 'Jubilamento', 'Transferencia')    
        AND  dbo.fn_anomes(ANO_ENCERRAMENTO,SEM_ENCERRAMENTO) >= dbo.fn_anomes(@p_ANO, @p_SEMESTRE)))        
    AND  H.ANO     = ISNULL(@p_ANO, H.ANO)  
    AND  H.SEMESTRE   =  ISNULL(@p_SEMESTRE, H.SEMESTRE)  
    AND  C.FACULDADE   =  ISNULL(@p_FACULDADE, C.FACULDADE)   --ALTERADO PARA C.FACULDADE POIS EXISTEM ALUNOS SEM O REGISTRO A.UNIDADE_ENSINO (MIGUEL EM 27mar2018)
    AND  A.CURSO    =  ISNULL(@p_CURSO, A.CURSO)  
    AND  A.TURNO    = ISNULL(@P_TURNO,A.TURNO)   
    AND  A.SERIE            =  ISNULL(@p_SERIE, A.SERIE)       
    AND  A.CURRICULO   = ISNULL(@P_CURRRICULO,A.CURRICULO)        
     
  UNION ALL --ACRESCENTADO O ALL POIS APENAS UNION ESTAVA ALTERANDO O CALCULO (MIGUEL EM 27mar2018)
  
  -- Seleciona somente aluno com dsiciplina ANO >= 2014  
  SELECT A.ALUNO,      
    A.UNIDADE_FISICA,      
    A.CURSO,      
    H.ANO,  
    H.SEMESTRE,                            
      CONVERT(NUMERIC(10,2),replace(isnull(H.NOTA_FINAL,'0'),',','.'))  AS CR   
   FROM LY_ALUNO   A        
   JOIN LY_HISTMATRICULA H   
    ON H.ALUNO = A.ALUNO   
   JOIN LY_GRADE         G     
    ON  G.CURSO             =   A.CURSO      
    AND G.TURNO         =   A.TURNO      
    AND G.CURRICULO     =   A.CURRICULO      
    AND (G.DISCIPLINA   =   H.DISCIPLINA      
     OR  G.FORMULA_EQUIV LIKE '%'+H.DISCIPLINA+'%')   
	 JOIN LY_CURSO C 
		ON C.CURSO = A.CURSO      
   WHERE 1 = 1      
    AND ISNUMERIC(replace(isnull(H.NOTA_FINAL,'0'),',','.')) = 1   
    AND replace(isnull(H.NOTA_FINAL,'0'),',','.')    <> '-'   
    AND H.SITUACAO_HIST      IN ('APROVADO','REP NOTA','REP FREQ')          
    AND (A.SIT_ALUNO = 'ATIVO'     
      OR EXISTS (SELECT 1    
       FROM LY_H_CURSOS_CONCL    
       WHERE ALUNO = A.ALUNO    
       AND  MOTIVO in ('Conclusao', 'Jubilamento', 'Transferencia')    
       AND  dbo.fn_anomes(ANO_ENCERRAMENTO,SEM_ENCERRAMENTO) >= dbo.fn_anomes(@p_ANO, @p_SEMESTRE)))        
    AND H.ANO >= 2014   
    AND H.ANO    = ISNULL(@p_ANO, H.ANO)  
    AND H.SEMESTRE   = ISNULL(@p_SEMESTRE, H.SEMESTRE)  
    AND C.FACULDADE   = ISNULL(@p_FACULDADE, C.FACULDADE)  --ALTERADO PARA C.FACULDADE POIS EXISTEM ALUNOS SEM O REGISTRO A.UNIDADE_ENSINO (MIGUEL EM 27mar2018)
    AND A.CURSO   = ISNULL(@p_CURSO, A.CURSO)  
    AND A.TURNO   = ISNULL(@P_TURNO,A.TURNO)   
    AND A.SERIE            = ISNULL(@p_SERIE, A.SERIE)       
    AND A.CURRICULO  = ISNULL(@P_CURRRICULO,A.CURRICULO)        
  
  
    ) C  
   
  GROUP BY ALUNO      
      ,UNIDADE_FISICA     
      ,CURSO      
      ,ANO  
      ,SEMESTRE       
   
  
  -- Remove tabela temporaria que será inserido o rank  
   IF OBJECT_ID('TEMPDB..#TMP_INDICE') IS NOT NULL  
   BEGIN  
    DROP TABLE #TMP_INDICE  
   END  
  

  --CRIAR TABELA TEMPORARIA #TMP_INDICE

  CREATE TABLE #TMP_INDICE (
	INDICE VARCHAR(70),
	ALUNO VARCHAR(20),
	CR NUMERIC(10,2),
	CLASSIFICACAO INT,
	CURSO VARCHAR(20),
	DESCRICAO VARCHAR (20),
	DT_DIVULG DATETIME,
	ANO NUMERIC(5),
	SEMESTRE NUMERIC(5),
	UNIDADE_FIS VARCHAR(20),
	
)      


  -- Ranquear por curso, ano e Periodo  
  INSERT INTO #TMP_INDICE
   SELECT   
     INDICE   = CONVERT(VARCHAR(50),'INDICE' + '_' + CONVERT(VARCHAR(4),@p_ANO) + CONVERT(VARCHAR(2),@p_SEMESTRE)),  
     ALUNO,          
     CR  ,      
     CLASSIFICACAO = RANK() OVER(PARTITION BY CURSO, ANO, SEMESTRE ORDER BY CR DESC),      
     CURSO ,      
     DESCRICAO  = 'INDICE SEMESTRAL',      
     DT_DIVULG   = DBO.FN_GetDataDiaSemHora(GETDATE()),      
     ANO,      
     SEMESTRE,      
     UNIDADE_FIS = UNIDADE_FISICA      
   --INTO #TMP_INDICE      
   FROM #TMP_IND  T    
   
  -- Delete CR do ano para do aluno para o ano e periodo do parametro rodado no processo  
   DELETE LY_INDICE_ALUNO      
   FROM LY_INDICE_ALUNO I      
   JOIN #TMP_IND  T   
   ON T.ALUNO  = I.ALUNO      
   AND T.ANO  = I.ANO      
   AND T.SEMESTRE  = I.PERIODO  
   
  -- Inseri o CR do aluno por ano e perido     
   INSERT INTO LY_INDICE_ALUNO (ALUNO, INDICE, VALOR, CLASSIFICACAO, CURSO, DESCRICAO, DT_DIVULG, ANO, PERIODO, UNIDADE_FIS)      
   SELECT ALUNO, INDICE, CR, CLASSIFICACAO, CURSO, DESCRICAO, DT_DIVULG, ANO, SEMESTRE, UNIDADE_FIS  FROM #TMP_INDICE      
   
 END  
  
IF @p_CRITERIO in ('GLOBAL')      
BEGIN            
      
 IF OBJECT_ID('TEMPDB..#TMP_IND2') IS NOT NULL  
  BEGIN  
   DROP TABLE #TMP_IND2  
  END 
  
  --CRIAR TABELA TEMPORARIA #TMP_IND2

CREATE TABLE #TMP_IND2 (
	ALUNO VARCHAR(20),
	UNIDADE_FISICA VARCHAR(20),
	CURSO VARCHAR(20),
	CR NUMERIC(10,2)
)    
  
 INSERT INTO #TMP_IND2
 SELECT   
  A.ALUNO      
 ,A.UNIDADE_FISICA      
 ,A.CURSO                              
 , CONVERT(NUMERIC(10,4),(avg(CONVERT(NUMERIC(10,2),CR)))) AS CR -- Calcula o rendimento do aluno  
 --INTO #TMP_IND2    
 FROM  
 (  
  -- Seleciona somente aluno com dsiciplina ANO <= 2013 e com notas <= 10  
   SELECT    
   A.ALUNO      
  ,A.UNIDADE_FISICA      
  ,A.CURSO                              
  ,CONVERT(NUMERIC(10,2),replace(isnull(H.NOTA_FINAL,'0'),',','.')) * 10 AS  CR    
  FROM LY_ALUNO   A        
  JOIN LY_HISTMATRICULA H   
   ON H.ALUNO = A.ALUNO  
  JOIN LY_GRADE         G     
   ON  G.CURSO         =   A.CURSO      
            AND G.TURNO         =   A.TURNO      
            AND G.CURRICULO     =   A.CURRICULO      
            AND (G.DISCIPLINA   =   H.DISCIPLINA      
                OR  G.FORMULA_EQUIV LIKE '%'+H.DISCIPLINA+'%') 
		         
  WHERE 1=1      
   AND ISNUMERIC(replace(isnull(H.NOTA_FINAL,'0'),',','.')) = 1   
   AND replace(isnull(H.NOTA_FINAL,'0'),',','.') <> '-'   
   AND H.ANO <= 2013   
   AND CONVERT(NUMERIC(10,2),replace(isnull(H.NOTA_FINAL,'0'),',','.')) <= 10       
   AND H.SITUACAO_HIST IN ('APROVADO','REP NOTA','REP FREQ')    
   AND (A.SIT_ALUNO = 'ATIVO'      
     OR EXISTS (SELECT 1    
      FROM LY_H_CURSOS_CONCL    
      WHERE ALUNO = A.ALUNO    
      AND  MOTIVO in ('Conclusao', 'Jubilamento', 'Transferencia')))         
   AND  A.CURSO    =  ISNULL(@p_CURSO, A.CURSO)    
   AND  A.TURNO    = ISNULL(@P_TURNO,A.TURNO)   
   AND  A.SERIE            =  ISNULL(@p_SERIE, A.SERIE)       
   AND  A.CURRICULO   = ISNULL(@P_CURRRICULO,A.CURRICULO)    
       
 UNION   ALL --ACRESCENTADO O ALL POIS APENAS UNION ESTAVA ALTERANDO O CALCULO (MIGUEL EM 27mar2018)
   
 -- Seleciona somente aluno com dsiciplina ANO >= 2014  
  SELECT    
  A.ALUNO      
 ,A.UNIDADE_FISICA      
 ,A.CURSO                              
 ,CONVERT(NUMERIC(10,2),replace(isnull(H.NOTA_FINAL,'0'),',','.')) AS CR  
  FROM LY_ALUNO   A        
  JOIN LY_HISTMATRICULA H   
   ON H.ALUNO = A.ALUNO   
  JOIN LY_GRADE G     
   ON  G.CURSO             =   A.CURSO      
            AND G.TURNO         =   A.TURNO      
            AND G.CURRICULO     =   A.CURRICULO      
            AND (G.DISCIPLINA   =   H.DISCIPLINA      
                OR  G.FORMULA_EQUIV LIKE '%'+H.DISCIPLINA+'%')
		   
  WHERE 1=1      
   AND ISNUMERIC(replace(isnull(H.NOTA_FINAL,'0'),',','.')) = 1   
   AND replace(isnull(H.NOTA_FINAL,'0'),',','.') <> '-'   
   AND H.SITUACAO_HIST IN ('APROVADO','REP NOTA','REP FREQ')    
   AND H.ANO >= 2014        
   AND (A.SIT_ALUNO = 'ATIVO'    
      OR EXISTS (SELECT 1    
       FROM LY_H_CURSOS_CONCL    
       WHERE ALUNO = A.ALUNO    
       AND  MOTIVO in ('Conclusao', 'Jubilamento', 'Transferencia')))       
   AND  A.CURSO    =  ISNULL(@p_CURSO, A.CURSO)    
   AND  A.TURNO    = ISNULL(@P_TURNO,A.TURNO)   
   AND  A.SERIE            =  ISNULL(@p_SERIE, A.SERIE)       
   AND  A.CURRICULO   = ISNULL(@P_CURRRICULO,A.CURRICULO)     
 ) A  
  GROUP BY A.ALUNO      
    ,A.UNIDADE_FISICA      
    ,A.CURSO     
  
     
 IF OBJECT_ID('TEMPDB..#TMP_INDICE2') IS NOT NULL  
  BEGIN  
  DROP TABLE #TMP_INDICE2  
  END  

    --CRIAR TABELA TEMPORARIA #TMP_INDICE2

	CREATE TABLE #TMP_INDICE2 (
	INDICE VARCHAR(70),
	ALUNO VARCHAR(20),
	CR NUMERIC(10,2),
	CLASSIFICACAO INT,
	CURSO VARCHAR(20),
	DESCRICAO VARCHAR (20),
	DT_DIVULG DATETIME,
	UNIDADE_FIS VARCHAR(20),
	
)   
  
 -- Ranquear por Curso      
  INSERT INTO #TMP_INDICE2
  SELECT   
    INDICE   = 'GLOBAL',  
    ALUNO,          
    CR  ,      
    CLASSIFICACAO = RANK() OVER(PARTITION BY CURSO ORDER BY CR DESC),      
    CURSO ,      
    DESCRICAO  = 'INDICE GLOBAL' ,      
    DT_DIVULG   = DBO.FN_GetDataDiaSemHora(GETDATE()),        
    UNIDADE_FIS = UNIDADE_FISICA      
  --INTO #TMP_INDICE2      
  FROM  #TMP_IND2  T    
  
 -- Delete CR do ano para do aluno quando o indice for GLOBAL  
  DELETE LY_INDICE_ALUNO      
  FROM LY_INDICE_ALUNO I      
  JOIN #TMP_INDICE2  T  
  ON T.ALUNO  = I.ALUNO      
  AND I.INDICE = 'GLOBAL'    
     
      
  INSERT INTO LY_INDICE_ALUNO (ALUNO, INDICE, VALOR, CLASSIFICACAO, CURSO, DESCRICAO, DT_DIVULG, ANO, PERIODO, UNIDADE_FIS)      
  SELECT ALUNO, INDICE, CR, CLASSIFICACAO, CURSO, DESCRICAO, DT_DIVULG, null, null, UNIDADE_FIS  FROM #TMP_INDICE2      
   
 END  
     
SET NOCOUNT OFF  
RETURN  