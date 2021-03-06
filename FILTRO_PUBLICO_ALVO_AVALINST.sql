--ALUNOS ATIVOS
SELECT DISTINCT ALUNO FROM LY_ALUNO A
JOIN LY_CURSO C ON C.CURSO = a.CURSO
WHERE A.SIT_ALUNO = 'Ativo'
AND C.TIPO = 'GRADUACAO'

--DOCENTES DO ALUNO
SELECT DISTINCT T.NUM_FUNC FROM LY_TURMA T, LY_MATRICULA M, LY_CURSO C 
WHERE T.ANO = M.ANO 
AND T.SEMESTRE = M.SEMESTRE 
AND T.DISCIPLINA = M.DISCIPLINA 
AND T.TURMA = M.TURMA 
AND T.NUM_FUNC <> 1
AND T.CURSO = C.CURSO
AND C.TIPO = 'GRADUACAO'
AND M.ALUNO = '%%CHAVE1' 

--DOCENTES ATIVOS 
SELECT DISTINCT D.NUM_FUNC FROM LY_DOCENTE D
JOIN LY_DOCENTE_UNIDADE DU ON DU.NUM_FUNC = DU.NUM_FUNC
JOIN LY_CURSO C ON C.FACULDADE = DU.FACULDADE
WHERE D.ATIVO = 'S' AND D.DT_DEMISSAO IS NULL AND D.NUM_FUNC <> '1'
AND C.TIPO =  'GRADUACAO'
AND D.NUM_FUNC = '265'

SELECT DISTINCT TIPO FROM LY_CURSO

--COORDENADORES DO DOCENTE
SELECT DISTINCT C.NUM_FUNC,t.NUM_FUNC FROM LY_COORDENACAO C
JOIN LY_DOCENTE D ON D.NUM_FUNC = C.NUM_FUNC 
JOIN LY_TURMA T ON T.CURSO = C.CURSO
JOIN LY_CURSO CUR ON CUR.CURSO = T.CURSO 
WHERE D.ATIVO = 'S' AND D.DT_DEMISS�O IS NULL
AND CUR.TIPO = 'GRADUACAO'
--AND C.NUM_FUNC <> 1011
AND T.NUM_FUNC = 265

--COORDENADORES ATIVOS
SELECT DISTINCT D.NUM_FUNC FROM LY_DOCENTE D
JOIN LY_DOCENTE_UNIDADE DU ON DU.NUM_FUNC = DU.NUM_FUNC
JOIN LY_CURSO C ON C.FACULDADE = DU.FACULDADE
JOIN LY_COORDENACAO CO ON CO.NUM_FUNC = D.NUM_FUNC
WHERE D.ATIVO = 'S' AND D.DT_DEMISSAO IS NULL AND D.NUM_FUNC <> '1'
AND C.TIPO =  'GRADUACAO'

--DOCENTES DO COORDENADOR
SELECT DISTINCT D.NUM_FUNC FROM LY_DOCENTE D 
JOIN LY_TURMA T ON T.NUM_FUNC = D.NUM_FUNC
JOIN LY_CURSO C ON C.CURSO = T.CURSO
WHERE D.ATIVO = 'S' AND D.DT_DEMISS�O IS NULL AND D.NUM_FUNC <> 1
AND C.TIPO = 'GRADUACAO'
AND EXISTS (SELECT 1 FROM LY_COORDENACAO C WHERE C.CURSO = T.CURSO AND C.NUM_FUNC = 1011)

SELECT * FROM LY_DOCENTE lc WHERE lc.NUM_FUNC = 265
SELECT * FROM LY_COORDENACAO lc WHERE lc.NUM_FUNC = 1579
SELECT * FROM LY_TURMA WHERE NUM_FUNC = '1011'
SELECT * FROM LY_DOCENTE_TURMA

SELECT * FROM LY_COORDENACAO lc WHERE lc.NUM_FUNC = '1011'

--DOCENTES DO COORDENADOR -> REGISTRO UNICO (NAO POR TURMA)

SELECT DISTINCT D.NUM_FUNC FROM LY_DOCENTE D 
JOIN LY_TURMA T ON T.NUM_FUNC = D.NUM_FUNC
JOIN LY_CURSO C ON C.CURSO = T.CURSO
JOIN LY_MATRICULA M ON M.ANO = T.ANO AND m.SEMESTRE = T.SEMESTRE AND M.DISCIPLINA = T.DISCIPLINA AND M.TURMA = T.TURMA  
WHERE D.ATIVO = 'S' AND D.DT_DEMISS�O IS NULL AND D.NUM_FUNC NOT IN ('1','388','825')
AND C.TIPO IN ('GRADUACAO','TECNOLOGO') AND M.SIT_MATRICULA NOT IN ('Cancelado','Trancado') AND T.SIT_TURMA = 'Aberta'
AND EXISTS (SELECT 1 FROM LY_COORDENACAO C WHERE C.CURSO = T.CURSO AND C.NUM_FUNC <> T.NUM_FUNC AND C.NUM_FUNC = 1687)



SELECT DISTINCT C.NUM_FUNC   FROM LY_COORDENACAO C   
JOIN LY_DOCENTE D ON D.NUM_FUNC = C.NUM_FUNC    
JOIN LY_TURMA T ON T.CURSO = C.CURSO
JOIN LY_CURSO CUR ON CUR.CURSO = T.CURSO  
JOIN LY_MATRICULA M ON M.ANO = T.ANO AND m.SEMESTRE = T.SEMESTRE AND M.DISCIPLINA = T.DISCIPLINA AND M.TURMA = T.TURMA  
WHERE D.ATIVO = 'S'   AND C.NUM_FUNC <> T.NUM_FUNC AND T.NUM_FUNC NOT IN ('1','388','825')  AND D.DT_DEMISS�O IS NULL   AND CUR.TIPO IN ('GRADUACAO','TECNOLOGO')    AND T.NUM_FUNC = '%%CHAVE1'