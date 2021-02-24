USE LYCEUM
GO

ALTER PROCEDURE FTC_Relatorio_Enade  
  
------------------################ Relatório ENADE ##########  
  
/*  
*- Cursos de Exatas e Licenciatura;  
* -Aluno calouros  com até 25% da CH  
*- Alunos que tenham em 31/agosto 80% da CH concluída ou prováveis concluintes até junho/2018;  
* -Alunos Tecnologos com até 75% da CH  
*- Alunos ingressantes em 2017.  
* CRIADA POR FABIO CORREIA   
*/  
  
  
        @curso    VARCHAR(60),  
        @unidade   VARCHAR (100),   
        @tipocurso VARCHAR(100),  
        @titulocurso VARCHAR(100),  
        @percentual_ini VARCHAR(20),  
        @percentual_fim VARCHAR(20)  
  
AS  
  
BEGIN  
	/*
	TESTE DE PROCEDURE
DECLARE 
    @curso    VARCHAR(60),  
    @unidade   VARCHAR (100),   
    @tipocurso VARCHAR(100),  
    @titulocurso VARCHAR(100),  
    @percentual_ini VARCHAR(20),  
    @percentual_fim VARCHAR(20)  

	SET @curso = NULL
	SET @unidade = NULL
	SET @tipocurso = NULL
	SET @titulocurso = NULL
	SET @percentual_ini = 70
	SET @percentual_fim = 100
	*/

        SELECT   
         a.aluno  
        ,a.nome_compl  
        ,P.CPF
		,c.TIPO AS TIPO_CURSO  
        ,a.curso  
        ,A.TURNO  
        ,A.ANOCONCL_2G  
        ,c.nome          
        ,C.INEP_CURSO  
        ,A.CURRICULO  
        ,A.ANO_INGRESSO  
        ,a.sem_ingresso  
        ,A.UNIDADE_FISICA  
        ,UE.INEP_FACULDADE  
        ,ISNULL((SELECT TOP 1 CONVERT(VARCHAR(20),'Matriculado') FROM LY_HISTMATRICULA WHERE ALUNO = A.ALUNO AND SITUACAO_HIST IN ('Aprovado','Dispensado') AND ANO=YEAR(GETDATE())),ISNULL((SELECT TOP 1 CONVERT(VARCHAR(20),'Matriculado') FROM VW_MATRICULA_E_PRE_MATRICULA WHERE SIT_MATRICULA IN ('Matriculado','Aprovado','Rep Nota','Rep Falta') AND ALUNO = A.ALUNO AND ANO = YEAR(GETDATE())),'Não-Matriculado')) as SITUACAO  
   ,(ISNULL((SELECT DISTINCT   
    CAST((SUM(H.HORAS_AULA)*100) / CUR.AULAS_PREVISTAS AS DECIMAL(16,0))   
   FROM  LY_HISTMATRICULA H
   INNER JOIN LY_ALUNO AA ON AA.ALUNO = H.ALUNO
   INNER JOIN LY_CURRICULO CUR ON CUR.CURSO = AA.CURSO AND CUR.TURNO = AA.TURNO AND CUR.CURRICULO = AA.CURRICULO 
   WHERE 1=1  
   AND AA.ALUNO=a.aluno  
   AND H.SITUACAO_HIST IN ('Aprovado','Dispensado')  
   GROUP BY CUR.AULAS_PREVISTAS),0)) as Percentual_Cursado  
   ,(ISNULL((SELECT DISTINCT   
    (SUM(H.HORAS_AULA))   
   FROM  LY_HISTMATRICULA H
   INNER JOIN LY_ALUNO AA ON AA.ALUNO = H.ALUNO
   INNER JOIN LY_CURRICULO CUR ON CUR.CURSO = AA.CURSO AND CUR.TURNO = AA.TURNO AND CUR.CURRICULO = AA.CURRICULO 
   WHERE 1=1  
   AND AA.ALUNO=a.aluno  
   AND H.SITUACAO_HIST IN ('Aprovado','Dispensado')  
   GROUP BY CUR.AULAS_PREVISTAS),0)) AS CH_Cursada   
        ,(CAST(CUR.AULAS_PREVISTAS AS DECIMAL(16,0))) as AULAS_PREVISTAS  
        FROM  LY_ALUNO A  
        INNER JOIN LY_PESSOA P ON P.PESSOA=A.PESSOA  
        INNER JOIN LY_grade g on g.curso=a.curso and g.curriculo=a.curriculo and g.turno=a.turno   
        INNER JOIN LY_CURRICULO CUR ON CUR.CURRICULO=g.CURRICULO AND CUR.CURSO=G.CURSO AND CUR.TURNO=G.TURNO   
        inner join ly_curso c on c.curso=a.curso  
		INNER JOIN LY_UNIDADE_ENSINO UE ON UE.UNIDADE_ENS= C.FACULDADE
        where 1=1  
        and c.tipo=(CASE WHEN @tipocurso IS NULL THEN c.tipo ELSE @tipocurso END)  
        and c.titulo=(CASE WHEN @titulocurso IS NULL THEN c.titulo ELSE @titulocurso END)  
        and A.UNIDADE_FISICA =( CASE WHEN @unidade IS NULL THEN  A.UNIDADE_FISICA ELSE @unidade END )  
        AND CUR.AULAS_PREVISTAS <>0  
        AND C.CURSO=(CASE WHEN @curso is NULL THEN C.CURSO else @curso END)  
        AND NOT EXISTS(SELECT 1 FROM LY_H_CURSOS_CONCL HCC WHERE HCC.ALUNO=A.ALUNO)
		AND C.TIPO IN ('GRADUACAO','TECNOLOGO','GRADUACAO-EAD')  
		group by a.aluno,a.nome_compl,P.CPF,C.tipo,a.curso,A.TURNO,A.ANOCONCL_2G,c.nome,C.INEP_CURSO,A.CURRICULO,A.ANO_INGRESSO,a.sem_ingresso,A.UNIDADE_FISICA,UE.INEP_FACULDADE,AULAS_PREVISTAS  
        HAVING   
   ISNULL((SELECT DISTINCT   
   isnull(CAST((SUM(H.HORAS_AULA)*100) / CUR.AULAS_PREVISTAS AS DECIMAL(16,0)),0)   
   FROM  LY_HISTMATRICULA H
   INNER JOIN LY_ALUNO AA ON AA.ALUNO = H.ALUNO
   INNER JOIN LY_CURRICULO CUR ON CUR.CURSO = AA.CURSO AND CUR.TURNO = AA.TURNO AND CUR.CURRICULO = AA.CURRICULO  
   WHERE 1=1  
   AND AA.ALUNO=a.aluno  
   AND H.SITUACAO_HIST IN ('Aprovado','Dispensado')  
   GROUP BY CUR.AULAS_PREVISTAS),0) BETWEEN @percentual_ini AND @percentual_fim  
END