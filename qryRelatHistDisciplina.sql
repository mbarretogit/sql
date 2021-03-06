SELECT DISTINCT
		UE.UNIDADE_ENS	AS COD_UNIDADE
		,UE.NOME_COMP	AS NOME_UNIDADE
		,A.CURSO		AS COD_CURSO
		,C.NOME			AS NOME_CURSO
		,HM.ANO
		,HM.SEMESTRE
		,D.DISCIPLINA	AS COD_DISCIPLINA
		,D.NOME			AS NOME_DISCIPLINA
		,A.ALUNO		AS ALUNO
		,A.NOME_COMPL	AS NOME_ALUNO
		,NOTA_FINAL		AS MEDIA_FINAL
		,SITUACAO_HIST	AS SITUACAO
FROM LY_HISTMATRICULA HM
JOIN LY_ALUNO A ON A.ALUNO = HM.ALUNO
JOIN LY_CURSO C ON C.CURSO = A.CURSO
JOIN LY_DISCIPLINA D ON D.DISCIPLINA = HM.DISCIPLINA
JOIN LY_UNIDADE_ENSINO UE ON UE.UNIDADE_ENS = C.FACULDADE
WHERE HM.DISCIPLINA IN (select DISCIPLINA from LY_DISCIPLINA where nome like '%termod%')
AND HM.ANO = 2015 AND HM.SEMESTRE IN (1,2) AND C.CURSO = '14'
ORDER BY HM.ANO, HM.SEMESTRE,D.DISCIPLINA,A.NOME_COMPL