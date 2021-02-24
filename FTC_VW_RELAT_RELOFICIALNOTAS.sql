USE FTC_DATAMART
GO

ALTER VIEW FTC_VW_RELAT_RELOFICIALNOTAS
AS

   
  SELECT a.CURSO,  
         m.TURMA,  
         LYCEUM.dbo.fnRelatFaltas('N',NULL,m.DISCIPLINA,m.TURMA,m.ANO,m.SEMESTRE) AS LIMITE_FALTAS,  
         dc.NOME_COMPL AS PROFESSOR,  
         d.DISCIPLINA,  
         d.NOME_COMPL AS NOME_DISCIPLINA,  
         a.ALUNO,  
         a.PESSOA,  
         a.TURNO,  
         m.SIT_MATRICULA,  
         a.NOME_COMPL AS NOME_ALUNO,  
         m.ANO,  
         m.SEMESTRE,  
         p.PROVA AS CABECALHO,  
         p.ORDEM AS ORDEM_PROVA,  
         n.CONCEITO AS VALOR,  
         LYCEUM.dbo.fnRelatConcatenaProvas(t.TURMA,m.ano,m.semestre,NULL,d.DISCIPLINA) AS LEGENDA  
  FROM LYCEUM..LY_MATRICULA m INNER JOIN       
       LYCEUM..LY_ALUNO a ON m.ALUNO = a.ALUNO INNER JOIN  
       LYCEUM..LY_TURMA t ON m.DISCIPLINA = t.DISCIPLINA AND m.TURMA = t.TURMA AND m.ANO = t.ANO AND m.SEMESTRE = t.SEMESTRE INNER JOIN       
       LYCEUM..LY_DOCENTE dc ON t.NUM_FUNC = dc.NUM_FUNC INNER JOIN       
       LYCEUM..LY_CURSO c ON a.CURSO = c.CURSO INNER JOIN  
       LYCEUM..LY_DISCIPLINA d ON m.DISCIPLINA = d.DISCIPLINA INNER JOIN  
       LYCEUM..LY_PROVA p ON m.DISCIPLINA = p.DISCIPLINA AND  
                     m.TURMA = p.TURMA AND  
                     m.ANO = p.ANO AND  
                     m.SEMESTRE = p.SEMESTRE LEFT OUTER JOIN --INNER JOIN  
       LYCEUM..LY_NOTA n ON p.DISCIPLINA = n.DISCIPLINA AND  
                    p.TURMA = n.TURMA AND  
                    p.ANO = n.ANO AND  
                    p.SEMESTRE = n.SEMESTRE AND  
                    p.PROVA = n.PROVA AND  
                    m.ALUNO = n.ALUNO

  
  UNION  
    
  SELECT a.CURSO,  
         m.TURMA,  
         LYCEUM.dbo.fnRelatFaltas('N',NULL,m.DISCIPLINA,m.TURMA,m.ANO,m.SEMESTRE) AS LIMITE_FALTAS,  
         dc.NOME_COMPL AS PROFESSOR,  
         d.DISCIPLINA,  
         d.NOME_COMPL AS NOME_DISCIPLINA,  
         a.ALUNO,  
         a.PESSOA,  
         a.TURNO,  
         m.SITUACAO_HIST,  
         a.NOME_COMPL AS NOME_ALUNO,  
         m.ANO,  
         m.SEMESTRE,  
         p.PROVA AS CABECALHO,  
         p.ORDEM AS ORDEM_PROVA,  
         n.CONCEITO AS VALOR,  
         LYCEUM.dbo.fnRelatConcatenaProvas(t.TURMA,m.ano,m.semestre,NULL,d.DISCIPLINA) AS LEGENDA  
  FROM LYCEUM..LY_HISTMATRICULA m INNER JOIN  
       LYCEUM..LY_ALUNO a ON m.ALUNO = a.ALUNO INNER JOIN  
       LYCEUM..LY_TURMA t ON m.DISCIPLINA = t.DISCIPLINA AND m.TURMA = t.TURMA AND m.ANO = t.ANO AND m.SEMESTRE = t.SEMESTRE INNER JOIN  
       LYCEUM..LY_DOCENTE dc ON t.NUM_FUNC = dc.NUM_FUNC INNER JOIN  
       LYCEUM..LY_CURSO c ON a.CURSO = c.CURSO INNER JOIN  
       LYCEUM..LY_DISCIPLINA d ON m.DISCIPLINA = d.DISCIPLINA INNER JOIN  
       LYCEUM..LY_PROVA p ON m.DISCIPLINA = p.DISCIPLINA AND  
                     m.TURMA = p.TURMA AND  
              m.ANO = p.ANO AND  
                     m.SEMESTRE = p.SEMESTRE LEFT OUTER JOIN --INNER JOIN  
       LYCEUM..LY_NOTA_HISTMATR n ON p.DISCIPLINA = n.DISCIPLINA AND  
                             p.ANO = n.ANO AND  
                             p.SEMESTRE = n.SEMESTRE AND  
                             p.PROVA = n.NOTA_ID AND  
                             m.ALUNO = n.ALUNO
