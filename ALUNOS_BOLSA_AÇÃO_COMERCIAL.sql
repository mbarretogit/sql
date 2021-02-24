SELECT DISTINCT B.ALUNO, B.TIPO_BOLSA, B.PERC_VALOR, B.VALOR, B.ANOINI, B.MESINI, B.ANOFIM, B.MESFIM
FROM LY_BOLSA B
JOIN #TEMP_CAIO C ON C.ALUNO = B.ALUNO
ORDER BY 1,5,6