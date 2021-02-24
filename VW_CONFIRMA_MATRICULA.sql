ALTER VIEW VW_CONFIRMA_MATRICULA  
  
  
/**************  
*  
*CRIADA POR FABIO ;p 06/03/2018  
*  
*****************/  
  
AS  
  
  
SELECT   
 A.ALUNO  
,U.CPF   
,M.disciplina  
,M.TURMA  
,M.ANO  
,M.SEMESTRE  
,C.CURSO_ID  
,U.eadboxid  
FROM Usuario U  
INNER JOIN LYCEUM..LY_PESSOA P ON P.CPF=U.cpf  
INNER JOIN LYCEUM..LY_ALUNO  A ON A.PESSOA=P.PESSOA  
INNER JOIN MATRICULA  M ON M.ALUNO =A.ALUNO  
INNER JOIN LYCEUM..VW_MATRICULA_E_PRE_MATRICULA MPM   
         ON  MPM.ALUNO=M.ALUNO   
         AND MPM.DISCIPLINA=M.disciplina   
         AND MPM.TURMA=M.TURMA   
         AND MPM.ANO=M.ANO  
         AND MPM.SEMESTRE=M.semestre  
INNER JOIN Curso C ON C.disciplina=MPM.DISCIPLINA AND C.ANO=M.ANO AND C.semestre=M.SEMESTRE           
WHERE 1=1  
--AND U.cpf='80793100500'  
AND M.ANO=2018  
AND A.UNIDADE_FISICA NOT IN ('OTE-JUA','OTE-PET', 'OTE-SP')
--AND A.UNIDADE_FISICA = 'FTC-SSA'
--AND m.dt_criacao >'2018-03-09'  
AND M.DISCIPLINA NOT IN ('DINV01','DINV02','DINV03')  
AND M.SEMESTRE=1  
AND M.dt_integracao IS NULL  
AND M.matricula_eadbox IS NULL  
--ORDER BY  m.dt_criacao DESC