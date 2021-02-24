USE FTC_DATAMART
GO

		DECLARE  @p_ano VARCHAR(4), @p_semestre VARCHAR(2)
		DECLARE cursor1 CURSOR FOR
		SELECT DISTINCT ANO_COMPETENCIA, MES_COMPETENCIA  FROM BI_GESTAO_PESSOAS ORDER BY ANO, SEMESTRE

		OPEN cursor1

		FETCH NEXT FROM cursor1 INTO @p_ano, @p_semestre

		WHILE @@FETCH_STATUS = 0
		BEGIN
			
		 execute ('begin rm.p_ftc_folha_mensal(''1'',''2018''); end; ') at [DBRM];
	 
		 DELETE FROM BI_GESTAO_PESSOAS WHERE ANO_COMPETENCIA = 2019 AND MES_COMPETENCIA = 9
	 
		 INSERT INTO BI_GESTAO_PESSOAS
		 select * from openquery(DBRM,'select * from rm.ftc_folha_mensal where ano_competencia = 2019 and mes_competencia = 9');

		FETCH NEXT FROM cursor1 INTO @p_ano, @p_semestre
		END
		CLOSE cursor1
		DEALLOCATE cursor1

		EXEC BI_ACOMP_MATR_POS_JOB

		EXEC BI_ACOMP_MATR_JOB 2019,0

		EXEC BI_ACOMP_MATR_JOB 2019,1
