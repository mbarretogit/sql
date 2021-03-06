USE FTC_DATAMART
GO

		DECLARE  @p_ano VARCHAR(4), @p_semestre VARCHAR(2)
		DECLARE cursor1 CURSOR FOR
		SELECT DISTINCT SUBSTRING(PERIODO_LETIVO,0,5) AS ANO, SUBSTRING(PERIODO_LETIVO,6,7) AS SEMESTRE  
		FROM BI_ALUNOS_UNIDADE ORDER BY 1,2

		OPEN cursor1

		FETCH NEXT FROM cursor1 INTO @p_ano, @p_semestre

		WHILE @@FETCH_STATUS = 0
		BEGIN
			
		EXEC BI_ALUNOS_UNIDADE_JOB @p_ano, @p_semestre

		FETCH NEXT FROM cursor1 INTO @p_ano, @p_semestre
		END
		CLOSE cursor1
		DEALLOCATE cursor1