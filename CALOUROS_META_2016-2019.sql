--ALTER TABLE BI_REMATRICULA
--DROP COLUMN DT_CANCELAMENTO

--UPDATE T SET T.DT_CANCELAMENTO = CONVERT(VARCHAR(10),H.DT_ENCERRAMENTO,103)
--FROM BI_REMATRICULA T 
--JOIN LYCEUM..LY_H_CURSOS_CONCL H ON H.ALUNO = T.ALUNO
--WHERE H.MOTIVO IN ('Cancelamento') AND (H.ANO_ENCERRAMENTO = T.ANO AND H.SEM_ENCERRAMENTO = T.SEMESTRE OR (H.ANO_INGRESSO = T.ANO AND H.SEM_INGRESSO = T.SEMESTRE AND T.TIPO_ALUNO = 'CALOURO'))
--AND H.DT_REABERTURA IS NULL AND SIT_MATRICULA <> 'MATRICULADO'
----AND T.ANO = 2015 AND T.SEMESTRE = 2

SELECT * FROM BI_REMATRICULA
WHERE ANO > 2015
AND TIPO_ALUNO = 'CALOURO'
AND TIPO_FINAN IN ('PAGANTES','FIES')
AND TIPO_CURSO IN ('GRADUACAO','TECNOLOGO')
AND TIPO_INGRESSO NOT IN ('Reingresso','Ouvinte')
--AND SIT_MATRICULA IN ('Matriculado','Pre-Matriculado','Dispensado')
ORDER BY ANO, SEMESTRE

select distinct ano, semestre from BI_REMATRICULA