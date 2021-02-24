USE LYCEUM
GO
    
ALTER VIEW FTC_VW_APONTAMENTO_DOCENTE_HORAS        
AS   
  
  
SELECT DO.NUM_FUNC AS COD_DOCENTE  
  , DO.NOME_COMPL AS NOME  
  , PL.ANO AS ANO  
  , PL.PERIODO AS SEMESTRE  
  , PL.DESCRICAO AS PERIODO  
  , UE.UNIDADE_ENS AS COD_UNIDADE  
  , UE.NOME_COMP AS UNIDADE  
  , ISNULL(C.CURSO,'') AS COD_CURSO  
  , ISNULL(C.NOME,'') AS CURSO  
  , DI.DISCIPLINA AS COD_DISCIPLINA  
 , DI.NOME AS DISCIPLINA  
  , T.TURMA  
  , ISNULL(T.NIVEL,'TEORICA') AS TIPO_TURMA  
  , DI.CREDITOS AS CH_DISCIPLINA
  , DI.AULAS_SEMANAIS AS CH_SEMANAL
  , AD.DIA_SEMANA   
  , CONVERT(VARCHAR(11),T.DT_ULTALT,103)  AS DT_VINCULO  
  , CAST(ho.TURNO+' - '+CASE WHEN ad.DIA_SEMANA = 2 THEN 'Segunda-Feira'  
         WHEN ad.DIA_SEMANA = 3 THEN 'Ter�a-Feira'  
         WHEN ad.DIA_SEMANA = 4 THEN 'Quarta-Feira'   
                        WHEN ad.DIA_SEMANA = 5 THEN 'Quinta-Feira'  
                        WHEN ad.DIA_SEMANA = 6 THEN 'Sexta-Feira'  
                        WHEN ad.DIA_SEMANA = 7 THEN 'S�bado'  
                        WHEN ad.DIA_SEMANA = 1 THEN 'Domingo' END+' - '+CONVERT(VARCHAR(5),ho.HORAINI_AULA,114) AS VARCHAR(30)) AS HORARIO
	--, (SELECT COUNT(*) FROM LY_AULA_DOCENTE AD1 WHERE AD1.NUM_FUNC = T.NUM_FUNC AND AD1.DISCIPLINA = T.DISCIPLINA AND AD1.TURMA = T.TURMA AND AD1.ANO = T.ANO AND AD1.SEMESTRE = T.SEMESTRE AND AD1.AULA = HO.AULA AND AD1.DIA_SEMANA = HO.DIA_SEMANA) AS TOTAL_AULAS_SEMANAIS                            
FROM LY_TURMA T  
JOIN LY_DOCENTE DO ON DO.NUM_FUNC = T.NUM_FUNC  
JOIN LY_PERIODO_LETIVO PL ON PL.ANO = T.ANO AND PL.PERIODO = T.SEMESTRE  
JOIN LY_UNIDADE_ENSINO UE ON UE.UNIDADE_ENS = T.UNIDADE_RESPONSAVEL  
JOIN LY_DISCIPLINA DI ON DI.DISCIPLINA = T.DISCIPLINA  
JOIN LY_AULA_DOCENTE AD ON AD.NUM_FUNC = T.NUM_FUNC AND AD.DISCIPLINA = T.DISCIPLINA AND AD.TURMA = T.TURMA AND AD.ANO = T.ANO AND AD.SEMESTRE = T.SEMESTRE  
LEFT JOIN LY_CURSO C ON C.CURSO = T.CURSO AND C.FACULDADE = T.UNIDADE_RESPONSAVEL  
JOIN LY_HOR_OPER HO ON HO.TURNO = AD.TURNO AND HO.DIA_SEMANA = AD.DIA_SEMANA AND HO.AULA = AD.AULA AND HO.FACULDADE = AD.FACULDADE

--WHERE DO.NUM_FUNC = '712'
--GROUP BY DO.NUM_FUNC, DO.NOME_COMPL, PL.ANO, PL.PERIODO, PL.DESCRICAO, UE.UNIDADE_ENS, UE.NOME_COMP, C.CURSO, C.NOME,DI.DISCIPLINA,DI.NOME, T.TURMA, T.NIVEL, DI.CREDITOS, DI.AULAS_SEMANAIS, AD.DIA_SEMANA,T.DT_ULTALT, HO.TURNO, AD.DIA_SEMANA, ho.HORAINI_AULA
GO