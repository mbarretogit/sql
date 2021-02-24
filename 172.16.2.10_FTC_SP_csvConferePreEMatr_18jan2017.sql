USE LYCEUM
GO
  
ALTER PROCEDURE dbo.FTC_SP_csvConferePreEMatr     
(      
 @p_ano    T_ANO,  
 @p_semestre   T_Semestre2,  
 @p_unidade_ensino T_codigo,  
 @p_tipo_curso  T_codigo,  
 @p_curso   T_codigo,  
 @p_turno   T_codigo,  
 @p_curriculo  T_codigo,   
 @p_sit_matricula T_codigo,  
 @p_tem_turma  varchar(1)  
)      
AS      
-- [INÍCIO]              
BEGIN      
  
--## Zerar variavel se vier com branco  
If @p_sit_matricula = 'TODAS'  
 set @p_sit_matricula = null  
  
  
SET NOCOUNT ON  
  
select    
    TIPO,
    CPF,  
    ALUNO,  
    NOME_ALUNO,  
    CURSO,  
    NOME_CURSO,  
    ISNULL(TIPO_CURSO,'')     AS TIPO_CURSO,  
    ISNULL(FACULDADE,'')     AS UNIDADE_ENSINO,  
    ISNULL(NOME_UNIDADE_ENSINO,'')   as NOME_UNIDADE_ENSINO,  
    TURNO,  
    CURRICULO,  
    ISNULL(CONVERT(VARCHAR,SERIE),'')  AS SERIE_ALUNO,  
    DISCIPLINA,  
    NOME_DISCIPLINA,  
    ANO,  
    SEMESTRE,  
    ISNULL(TURMA,'')      AS TURMA,  
    ISNULL(SUBTURMA1,'')     AS SUBTURMA1,  
    ISNULL(SUBTURMA2,'')     AS SUBTURMA2,  
    ISNULL(SIT_DETALHE,'')     AS SIT_DETALHE,  
    ISNULL(SIT_MATRICULA,'')    AS SIT_MATRICULA,  
    ISNULL(CONVERT(VARCHAR,SERIE_IDEAL),'') AS SERIE_IDEAL_DISCIPLINA,  
    ISNULL(CONFIRMADA,'')     AS CONFIRMADA,  
    ISNULL(DISPENSADA,'')     AS DISPENSADA,  
    ISNULL(CONVERT(VARCHAR,DT_INSERCAO,103),'')  AS DATA_INSERCAO,  
    ISNULL(CONVERT(VARCHAR,DT_ULTALT,103),'')   AS DATA_ULTIMA_ALTERACAO,  
    ISNULL(CONVERT(VARCHAR,DT_CONFIRMACAO,103),'')  AS DATA_CONFIRMACAO,  
    ISNULL(CONVERT(VARCHAR,DT_MATRICULA,103),'')  AS DATA_MATRICULA,  
    ISNULL(DISPENSADA,'')     AS GRUPO_ELETIVA,  
    ISNULL(CONVERT(VARCHAR,LANC_DEB),'') AS LANC_DEB,  
    ISNULL(MANUAL,'')      AS MANUAL,  
    ISNULL(OBS,'')       AS OBS,  
    ISNULL(MENS_ERRO,'')     AS MENS_ERRO   
INTO #TEMP_MATRICULA  
from (  
   SELECT   
    'PRÉ-MATRÍCULA' AS TIPO,
    P.CPF,  
    A.ALUNO,  
    A.NOME_COMPL AS NOME_ALUNO,  
    A.CURSO,  
    C.NOME   AS NOME_CURSO,  
    C.TIPO   AS TIPO_CURSO,  
    C.FACULDADE,  
    ue.NOME_COMP as NOME_UNIDADE_ENSINO,  
    A.TURNO,  
    A.CURRICULO,  
    A.SERIE,  
    PM.DISCIPLINA,  
    D.NOME   AS NOME_DISCIPLINA,  
    PM.ANO,  
    PM.SEMESTRE,  
    PM.TURMA,  
    PM.SUBTURMA1,  
    PM.SUBTURMA2,  
    PM.SIT_DETALHE,  
    'Pré-Matriculado'  AS SIT_MATRICULA,  
    PM.SERIE_IDEAL,  
    PM.CONFIRMADA,  
    PM.DISPENSADA,  
    PM.DT_INSERCAO,  
    PM.DT_ULTALT,  
    PM.DT_CONFIRMACAO,  
    null AS dt_matricula,  
    PM.GRUPO_ELETIVA,  
    PM.LANC_DEB,  
    PM.MANUAL,  
    PM.OBS,  
    PM.MENS_ERRO   
   from LY_PRE_MATRICULA PM  
   JOIN VW_ALUNO A  
    on pm.aluno = a.aluno  
   JOIN VW_CURSO c  
    on a.CURSO = c.curso  
   join LY_DISCIPLINA d  
    on pm.DISCIPLINA = d.DISCIPLINA  
   LEFT JOIN VW_UNIDADE_ENSINO ue   
    ON c.FACULDADE = ue.FACULDADE 
    JOIN LY_PESSOA P
    ON P.PESSOA = A.PESSOA 
   WHERE 1 = 1  
   and pm.ano  = @p_ano  
   and pm.SEMESTRE = isnull(@p_semestre,semestre)  
   AND C.FACULDADE = ISNULL(@P_UNIDADE_ENSINO,C.FACULDADE)  
   AND C.TIPO  = ISNULL(@P_TIPO_CURSO, C.TIPO)  
   AND A.CURSO  = ISNULL(@P_CURSO,A.CURSO)  
   AND A.TURNO  = ISNULL(@P_TURNO,A.TURNO)  
   AND A.CURRICULO = ISNULL(@p_curriculo,A.CURRICULO)  
  
   union ALL  
     
   SELECT   
    'MATRÍCULA' AS TIPO, 
    P.CPF, 
    A.ALUNO,  
    A.NOME_COMPL AS NOME_ALUNO,  
    A.CURSO,  
    C.NOME   AS NOME_CURSO,  
    C.TIPO   AS TIPO_CURSO,  
    C.FACULDADE,  
    ue.NOME_COMP as NOME_UNIDADE_ENSINO,  
    A.TURNO,  
    A.CURRICULO,  
    A.SERIE,  
    M.DISCIPLINA,  
    D.NOME   AS NOME_DISCIPLINA,  
    M.ANO,  
    M.SEMESTRE,  
    M.TURMA,  
    M.SUBTURMA1,  
    M.SUBTURMA2,  
    M.SIT_DETALHE,  
    m.SIT_MATRICULA,  
    NULL    AS SERIE_IDEAL,  
    NULL    AS CONFIRMADA,  
    NULL    AS DISPENSADA,  
    M.DT_INSERCAO,  
    M.DT_ULTALT,  
    NULL    AS DT_CONFIRMACAO,  
    M.DT_MATRICULA,  
    M.GRUPO_ELETIVA,  
    M.LANC_DEB,  
    NULL    AS MANUAL,  
    M.OBS,  
    NULL    AS MENS_ERRO   
   from LY_MATRICULA M  
   JOIN VW_ALUNO A  
    on m.aluno = a.aluno  
   JOIN VW_CURSO c  
    on a.CURSO = c.curso  
   join LY_DISCIPLINA d  
    on m.DISCIPLINA = d.DISCIPLINA  
   LEFT JOIN VW_UNIDADE_ENSINO ue   
    ON c.FACULDADE = ue.FACULDADE  
    JOIN LY_PESSOA P
    ON P.PESSOA = A.PESSOA 
   WHERE 1 = 1  
   and m.ano  = @p_ano  
   and m.SEMESTRE = isnull(@p_semestre,semestre)  
   AND C.FACULDADE = ISNULL(@P_UNIDADE_ENSINO,C.FACULDADE)  
   AND C.TIPO  = ISNULL(@P_TIPO_CURSO, C.TIPO)  
   AND A.CURSO  = ISNULL(@P_CURSO,A.CURSO)  
   AND A.TURNO  = ISNULL(@P_TURNO,A.TURNO)  
   AND A.CURRICULO = ISNULL(@p_curriculo,A.CURRICULO)  
  
) A  
WHERE 1 = 1  
AND TIPO = ISNULL(@p_sit_matricula,tipo)    
  
  
IF @p_tem_turma = 'S'  
 BEGIN  
  SELECT * FROM #TEMP_MATRICULA  
  WHERE TURMA <> ''  
  order by UNIDADE_ENSINO, curso, turno, CURRICULO, SERIE_ALUNO  
 END  
ELSE  
 IF @p_tem_turma = 'N'  
  BEGIN  
   SELECT * FROM #TEMP_MATRICULA  
   WHERE TURMA = ''  
   order by UNIDADE_ENSINO, curso, turno, CURRICULO, SERIE_ALUNO  
  END  
 ELSE   
  BEGIN  
   SELECT * FROM #TEMP_MATRICULA  
   order by UNIDADE_ENSINO, curso, turno, CURRICULO, SERIE_ALUNO  
  END  
  
SET NOCOUNT OFF  
  
END              
-- [FIM]      