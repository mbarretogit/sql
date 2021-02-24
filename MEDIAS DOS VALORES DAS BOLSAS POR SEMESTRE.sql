DECLARE @ANO_REF VARCHAR(4) = '2019'
		,@PERIODO_REF VARCHAR(2) = '2'

-----------------------------------------------------------------
-----------------------------------------------------------------

IF OBJECT_ID('TEMPDB..##FTC_TBL_VLR_DISCIPLINA') IS NOT NULL
BEGIN
	DROP TABLE ##FTC_TBL_VLR_DISCIPLINA;
END

-----------------------------------------------------------------
-----------------------------------------------------------------

SELECT
	UNIDADE_FIS
	,CURSO
	,TURNO
	,CURRICULO
	,CAST(AVG(VL_DISCP_SEMESTRE) AS DECIMAL(10,2)) AS VLR_REAL
INTO ##FTC_TBL_VLR_DISCIPLINA
FROM (
	SELECT distinct
		VSP.ANO
		,VSP.PERIODO
		,UE.UNIDADE_ENS
		,UF.UNIDADE_FIS
		,G.CURSO
		,G.CURRICULO
		,G.TURNO
		,G.DISCIPLINA
		,G.SERIE_IDEAL
		,D.CREDITOS
		,VSP.CUSTO_UNITARIO
		,D.CREDITOS * VSP.CUSTO_UNITARIO VL_DISCP_SEMESTRE
		--,CONVERT(DECIMAL(10,2),((D.CREDITOS * VSP.CUSTO_UNITARIO)/PPP.NUM_PARCELAS)) AS VALOR_MENSALIDADE
		--,PPP.NUM_PARCELAS
	FROM LY_GRADE G
	JOIN LY_CURSO C ON C.CURSO = G.CURSO AND C.CURSO IN ('GRADUACAO','TECNOLOGO')
	JOIN LY_UNIDADE_ENSINO UE ON UE.UNIDADE_ENS = C.FACULDADE
	--JOIN LYCEUM..LY_UNIDADE_FISICA UF ON UF.UNIDADE_FIS = UE.NOME_ABREV
	JOIN LYCEUM..LY_UNIDADE_FISICA UF ON UF.FL_FIELD_10 = UE.UNIDADE_ENS
	JOIN LY_DISCIPLINA D ON D.DISCIPLINA = G.DISCIPLINA
	JOIN LY_SERIE S ON S.CURSO = G.CURSO AND S.TURNO = G.TURNO AND S.CURRICULO = G.CURRICULO AND S.SERIE = G.SERIE_IDEAL
	JOIN LY_VALOR_SERV_PERIODO VSP ON VSP.SERVICO = S.SERVICO_CRED
	JOIN LY_TABELA_SERVICOS TS ON TS.SERVICO = VSP.SERVICO
	--JOIN LY_PLANO_PGTO_PERIODO PPP ON PPP.ALUNO = A.ALUNO AND PPP.ANO = VSP.ANO AND PPP.PERIODO = VSP.PERIODO
	WHERE 1 = 1
		AND VSP.ANO = @ANO_REF
		AND VSP.PERIODO = @PERIODO_REF
		AND EXISTS (
			SELECT TOP 1
				1
			FROM LYCEUM..LY_ALUNO A
			WHERE 1 = 1
				AND CURSO = G.CURSO
				AND CURRICULO = G.CURRICULO
				AND TURNO = G.TURNO
				AND EXISTS (
					SELECT TOP 1
						1
					FROM VW_MATRICULA_E_PRE_MATRICULA
					WHERE 1 = 1
						AND ALUNO = A.ALUNO
			
				)
		)
) tbl
GROUP BY
	UNIDADE_FIS
	,CURSO
	,TURNO
	,CURRICULO


-----------------------------------------------------------------
-----------------------------------------------------------------

IF OBJECT_ID('TEMPDB..##FTC_TBL_RESULTADO') IS NOT NULL
BEGIN
	DROP TABLE ##FTC_TBL_RESULTADO;
END


-----------------------------------------------------------------
-----------------------------------------------------------------


SELECT	DISTINCT
		A.UNIDADE_FISICA
		,A.CURSO
		,C.NOME AS CURSO_NOME
		,A.TURNO
		,A.CURRICULO
		,ISNULL(COUNT(DISTINCT A.ALUNO),0) AS QTD_ALUNOS_TOTAL
		,ISNULL((
		SELECT	TB.VLR_REAL
		FROM	##FTC_TBL_VLR_DISCIPLINA TB
		WHERE	TB.UNIDADE_FIS = A.UNIDADE_FISICA
				AND TB.CURSO = A.CURSO
				AND TB.TURNO = A.TURNO
				AND TB.CURRICULO = A.CURRICULO
		),0) AS VLR_MS_MEDIO_IDEAL
		,CAST(ISNULL((AVG(LD.VALOR)/6),0) AS DECIMAL(10,2)) AS VLR_MS_MEDIO_DIVIDA
		,0 AS QTD_ALUNOS_BOLSA
		,CAST(0 AS DECIMAL(10,2)) AS VLR_MEDIO_BOLSA
		,0 AS QTD_ALUNOS_BOLSA_GOV_E_FINAN
		,CAST(0 AS DECIMAL(10,2)) AS VLR_MEDIO_BOLSA_GOV_E_FINAN
INTO	##FTC_TBL_RESULTADO
FROM	LYCEUM..LY_ALUNO A
		INNER JOIN LYCEUM..LY_CURSO C
			ON A.CURSO = C.CURSO
		INNER JOIN LYCEUM..LY_LANC_DEBITO LD
			ON A.ALUNO = LD.ALUNO
WHERE	1 = 1
		AND LD.ANO_REF = @ANO_REF
		AND LD.PERIODO_REF = @PERIODO_REF
		AND LD.CODIGO_LANC = 'MS'
		AND C.TIPO IN ('GRADUACAO','TECNOLOGO')
GROUP BY
		A.UNIDADE_FISICA
		,A.CURSO
		,C.NOME
		,A.TURNO
		,A.CURRICULO

-----------------------------------------------------------------
-----------------------------------------------------------------

IF OBJECT_ID('TEMPDB..##FTC_TBL_BOLSAS') IS NOT NULL
BEGIN
	DROP TABLE ##FTC_TBL_BOLSAS;
END


-----------------------------------------------------------------
-----------------------------------------------------------------

SELECT	DISTINCT
		A.UNIDADE_FISICA
		,A.CURSO
		,C.NOME AS CURSO_NOME
		,A.TURNO
		,A.CURRICULO
		,ISNULL(COUNT(DISTINCT A.ALUNO),0) AS QTD_ALUNOS_BOLSA
		,CAST(ISNULL(SUM(IL.VALOR),0) AS DECIMAL(10,2)) AS VLR_BOLSA_TOTAL
		--,A.ALUNO
		--,IL.VALOR
INTO	##FTC_TBL_BOLSAS
FROM	LYCEUM..LY_ALUNO A
		INNER JOIN LYCEUM..LY_CURSO C
			ON A.CURSO = C.CURSO
		INNER JOIN LYCEUM..LY_LANC_DEBITO LD
			ON A.ALUNO = LD.ALUNO
		INNER JOIN LY_ITEM_LANC IL
			ON LD.LANC_DEB = IL.LANC_DEB
		INNER JOIN LY_BOLSA B
			ON IL.NUM_BOLSA = B.NUM_BOLSA
			AND IL.ALUNO = B.ALUNO
		INNER JOIN LY_TIPO_BOLSA TB
			ON TB.TIPO_BOLSA = B.TIPO_BOLSA
WHERE	1 = 1
		AND LD.ANO_REF = @ANO_REF
		AND LD.PERIODO_REF = @PERIODO_REF
		AND LD.CODIGO_LANC = 'MS'
		AND C.TIPO IN ('GRADUACAO','TECNOLOGO')
		AND IL.NUM_BOLSA IS NOT NULL
		AND IL.PARCELA <> 1
		AND (TB.GRUPO_BOLSA IS NULL OR TB.GRUPO_BOLSA NOT IN ('PROIES', 'FIES', 'PROUNI','CREDEDUC'))
		--AND A.ALUNO = '171060544'
GROUP BY
		A.UNIDADE_FISICA
		,A.CURSO
		,C.NOME
		,A.TURNO
		,A.CURRICULO

--SELECT * FROM ##FTC_TBL_BOLSAS
-----------------------------------------------------------------
-----------------------------------------------------------------


IF OBJECT_ID('TEMPDB..##FTC_TBL_BOLSAS_GOV_FINAN') IS NOT NULL
BEGIN
	DROP TABLE ##FTC_TBL_BOLSAS_GOV_FINAN;
END


-----------------------------------------------------------------
-----------------------------------------------------------------

SELECT	DISTINCT
		A.UNIDADE_FISICA
		,A.CURSO
		,C.NOME AS CURSO_NOME
		,A.TURNO
		,A.CURRICULO
		,ISNULL(COUNT(DISTINCT A.ALUNO),0) AS QTD_ALUNOS_BOLSA
		,CAST(ISNULL(SUM(IL.VALOR),0) AS DECIMAL(10,2)) AS VLR_BOLSA_TOTAL
		--,A.ALUNO
		--,IL.VALOR
INTO	##FTC_TBL_BOLSAS_GOV_FINAN
FROM	LYCEUM..LY_ALUNO A
		INNER JOIN LYCEUM..LY_CURSO C
			ON A.CURSO = C.CURSO
		INNER JOIN LYCEUM..LY_LANC_DEBITO LD
			ON A.ALUNO = LD.ALUNO
		INNER JOIN LY_ITEM_LANC IL
			ON LD.LANC_DEB = IL.LANC_DEB
		INNER JOIN LY_BOLSA B
			ON IL.NUM_BOLSA = B.NUM_BOLSA
			AND IL.ALUNO = B.ALUNO
		INNER JOIN LY_TIPO_BOLSA TB
			ON TB.TIPO_BOLSA = B.TIPO_BOLSA
WHERE	1 = 1
		AND LD.ANO_REF = @ANO_REF
		AND LD.PERIODO_REF = @PERIODO_REF
		AND LD.CODIGO_LANC = 'MS'
		AND C.TIPO IN ('GRADUACAO','TECNOLOGO')
		AND IL.NUM_BOLSA IS NOT NULL
		AND TB.GRUPO_BOLSA IN ('PROIES', 'FIES', 'PROUNI','CREDEDUC')
		--AND A.ALUNO = '171060544'
GROUP BY
		A.UNIDADE_FISICA
		,A.CURSO
		,C.NOME
		,A.TURNO
		,A.CURRICULO

--SELECT * FROM ##FTC_TBL_BOLSAS_GOV_FINAN
-----------------------------------------------------------------
-----------------------------------------------------------------

UPDATE	R
SET		R.QTD_ALUNOS_BOLSA = B.QTD_ALUNOS_BOLSA
		,R.VLR_MEDIO_BOLSA = (B.VLR_BOLSA_TOTAL / B.QTD_ALUNOS_BOLSA)
FROM	##FTC_TBL_RESULTADO R
		INNER JOIN ##FTC_TBL_BOLSAS B
			ON R.UNIDADE_FISICA = B.UNIDADE_FISICA
			AND R.CURSO = B.CURSO
			AND R.TURNO = B.TURNO
			AND R.CURRICULO = B.CURRICULO
WHERE	1 = 1

-----------------------------------------------------------------
-----------------------------------------------------------------

UPDATE	R
SET		R.QTD_ALUNOS_BOLSA_GOV_E_FINAN = B.QTD_ALUNOS_BOLSA
		,R.VLR_MEDIO_BOLSA_GOV_E_FINAN = (B.VLR_BOLSA_TOTAL / B.QTD_ALUNOS_BOLSA)
FROM	##FTC_TBL_RESULTADO R
		INNER JOIN ##FTC_TBL_BOLSAS_GOV_FINAN B
			ON R.UNIDADE_FISICA = B.UNIDADE_FISICA
			AND R.CURSO = B.CURSO
			AND R.TURNO = B.TURNO
			AND R.CURRICULO = B.CURRICULO
WHERE	1 = 1

-----------------------------------------------------------------
-----------------------------------------------------------------

--ALTER TABLE ##FTC_TBL_RESULTADO
--	ADD VLR_MEDIO_BOLSA_PERC DECIMAL(10,2)
--ALTER TABLE ##FTC_TBL_RESULTADO
--	ADD VLR_MEDIO_BOLSA_GOV_E_FINAN_PERC DECIMAL(10,2)


-------------------------------------------------------------------
-------------------------------------------------------------------

--UPDATE	R
--SET		R.QTD_ALUNOS_BOLSA_GOV_E_FINAN_PERC = B.QTD_ALUNOS_BOLSA
--		,R.VLR_MEDIO_BOLSA_GOV_E_FINAN = (B.VLR_BOLSA_TOTAL / B.QTD_ALUNOS_BOLSA)
--FROM	##FTC_TBL_RESULTADO R
--		INNER JOIN ##FTC_TBL_BOLSAS_GOV_FINAN B
--			ON R.UNIDADE_FISICA = B.UNIDADE_FISICA
--			AND R.CURSO = B.CURSO
--			AND R.TURNO = B.TURNO
--WHERE	1 = 1




SELECT	R.*
FROM	##FTC_TBL_RESULTADO R
WHERE	1 = 1
ORDER BY
		R.UNIDADE_FISICA
		,R.CURSO_NOME
		,R.TURNO
		,R.CURRICULO


-- SELECT * FROM LY_ITEM_LANC WHERE ALUNO = '171060544'



