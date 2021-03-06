--CREATE PROCEDURE a_calcula_valor_disciplina
--  @p_aluno T_CODIGO, 
--  @p_ano T_ANO,
--  @p_periodo T_SEMESTRE2,
--  @p_curso T_CODIGO, 
--  @p_turno T_CODIGO,  
--  @p_curriculo T_CODIGO, 
--  @p_serie T_NUMERO_PEQUENO, 
--  @p_disciplina T_CODIGO, 
--  @p_valor_disciplina DECIMAL(14,2) output, 
--  @p_codigo_lanc T_CODIGO output, 
--  @p_descricao T_ALFALARGE OUTPUT,
--  @p_calc_serie_incompl T_SIMNAO
--AS
--  RETURN

USE LYCEUM
GO

-- EP PROGRAMADO
ALTER PROCEDURE a_calcula_valor_disciplina
  @p_aluno T_CODIGO, 
  @p_ano T_ANO,
  @p_periodo T_SEMESTRE2,
  @p_curso T_CODIGO, 
  @p_turno T_CODIGO,  
  @p_curriculo T_CODIGO, 
  @p_serie T_NUMERO_PEQUENO, 
  @p_disciplina T_CODIGO, 
  @p_valor_disciplina DECIMAL(14,2) output, 
  @p_codigo_lanc T_CODIGO output, 
  @p_descricao T_ALFALARGE OUTPUT,
  @p_calc_serie_incompl T_SIMNAO
AS
BEGIN
	DECLARE @v_disciplina_grade VARCHAR(20)
	DECLARE @v_creditos DECIMAL(10,2)
	DECLARE @v_valor_unitario DECIMAL(14,6)
	DECLARE @v_servico VARCHAR(20)
	DECLARE @v_ErrorsCount int

	-- VERIFICA SE A DISCIPLINA FAZ PARTE DA GRADE
	-- CASO FA�A PARTE DA GRADE, UTILIZA O C�LCULO PADR�O DO LYCEUM
	IF EXISTS
	(
		SELECT TOP 1 1
		FROM LY_GRADE G
		WHERE G.CURSO       = @p_curso  
		AND G.TURNO         = @p_turno  
		AND G.CURRICULO     = @p_curriculo
		AND G.DISCIPLINA	= @p_disciplina
	)
		RETURN

	-- VERIFICA SE A DISCIPLINA FAZ PARTE DA GRADE DE ELETIVAS
	-- CASO FA�A PARTE DA GRADE, UTILIZA O C�LCULO PADR�O DO LYCEUM
	IF EXISTS
	(
		SELECT TOP 1 1
		FROM LY_GRADE_ELETIVAS G
		WHERE G.CURSO       = @p_curso  
		AND G.TURNO         = @p_turno  
		AND G.CURRICULO     = @p_curriculo
		AND G.DISCIPLINA	= @p_disciplina
	)
		RETURN

	-- REGRA DE C�LCULO V�LIDA A PARTIR DE 2018/2
	IF(CONVERT(VARCHAR,@p_ano) + SUBSTRING(CONVERT(VARCHAR,@p_periodo + 100),2,2) <= '201801')
		RETURN
	
	-- CONSULTA SE A DISCIPLINA � EQUIVALENTE NA GRADE CURRICULAR
	SELECT TOP 1 
		@v_disciplina_grade = G.DISCIPLINA
	,	@v_creditos = D.CREDITOS
	FROM LY_GRADE G
	JOIN LY_DISCIPLINA D
		ON (D.DISCIPLINA = G.DISCIPLINA)
	WHERE G.CURSO       = @p_curso  
	AND G.TURNO         = @p_turno  
	AND G.CURRICULO     = @p_curriculo  
	AND G.FORMULA_EQUIV LIKE '%' + @p_disciplina + '%'
	AND G.FORMULA_EQUIV IS NOT NULL

	-- CONSULTA SE A DISCIPLINA � EQUIVALENTE NA TABELA DE DISCIPLINAS
	IF @v_disciplina_grade IS NULL
	BEGIN
		SELECT TOP 1 
			@v_disciplina_grade = G.DISCIPLINA
		,	@v_creditos = D.CREDITOS
		FROM LY_GRADE G
		JOIN LY_DISCIPLINA D
			ON (D.DISCIPLINA = G.DISCIPLINA)
		WHERE G.CURSO       = @p_curso  
		AND G.TURNO         = @p_turno  
		AND G.CURRICULO     = @p_curriculo  
		AND G.FORMULA_EQUIV IS NULL
		AND D.FORMULA_EQUIV LIKE '%' + @p_disciplina + '%'
	END

	IF @v_disciplina_grade IS NOT NULL
	AND EXISTS
	(
		SELECT TOP 1 1
		FROM LY_CURSO
		WHERE CURSO = @p_curso
		AND VALOR_CRED_ASSOC_DISC = 'N'
		AND USA_SERIE_IDEAL = 'S'
	)
	BEGIN
		SELECT @v_servico = SERVICO_CRED
		FROM LY_SERIE S
		WHERE S.CURSO       = @p_curso  
		AND S.TURNO         = @p_turno  
		AND S.CURRICULO     = @p_curriculo  
		AND EXISTS
		(
			SELECT TOP 1 1
			FROM LY_GRADE G
			WHERE G.CURSO = S.CURSO
			AND G.TURNO = S.TURNO
			AND G.CURRICULO = S.CURRICULO
			AND G.SERIE_IDEAL = S.SERIE
			AND G.DISCIPLINA = @v_disciplina_grade
			UNION
			SELECT TOP 1 1
			FROM LY_GRADE_ELETIVAS GE
			WHERE GE.CURSO = S.CURSO
			AND GE.TURNO = S.TURNO
			AND GE.CURRICULO = S.CURRICULO
			AND GE.SERIE_IDEAL = S.SERIE
			AND GE.DISCIPLINA = @v_disciplina_grade
		)

		-- REFAZER O C�LCULO DO VALOR DA DISCIPLINA
		EXEC calcula_valor_servico @v_servico, @p_aluno, @p_ano, @p_periodo, @v_valor_unitario OUTPUT, @p_codigo_lanc OUTPUT, @p_descricao OUTPUT

		-- VERIFICA SE OCORRERAM ERROS DURANTE A EXECU��O DA FUN��O
		EXEC GetErrorsCount @v_ErrorsCount output
		IF @v_ErrorsCount <> 0
		GOTO FIM_ERRO

		SELECT @p_valor_disciplina = @v_valor_unitario * CREDITOS
		FROM LY_DISCIPLINA
		WHERE DISCIPLINA = @v_disciplina_grade

		IF @p_valor_disciplina > 0
			SET @p_descricao = @p_descricao + ' - Disc Orig: ' + @v_disciplina_grade
	END

FIM_ERRO:
  RETURN

	RETURN
END
GO

/*-----------------------------------------------
              SELECT CASOS DE TESTE
------------------------------------------------*/
--SELECT A.CURSO, A.TURNO, A.CURRICULO, A.SERIE, C.NOME, D.CREDITOS, D.NOME_COMPL, M.*
--FROM LY_MATRICULA M
--JOIN LY_DISCIPLINA D
--	ON M.DISCIPLINA = D.DISCIPLINA
--JOIN LY_ALUNO A
--	ON M.ALUNO = A.ALUNO
--JOIN LY_CURSO C
--	ON C.CURSO = A.CURSO
--WHERE  C.VALOR_CRED_ASSOC_DISC = 'N'
--AND C.USA_SERIE_IDEAL = 'S'
--AND C.TIPO = 'GRADUACAO'
--AND NOT EXISTS
--(
--	SELECT TOP 1 1
--	FROM LY_GRADE G
--	WHERE G.CURSO = A.CURSO AND G.TURNO = A.TURNO AND G.CURRICULO = A.CURRICULO AND G.DISCIPLINA = M.DISCIPLINA
--	UNION
--	SELECT TOP 1 1
--	FROM LY_GRADE GE
--	WHERE GE.CURSO = A.CURSO AND GE.TURNO = A.TURNO AND GE.CURRICULO = A.CURRICULO AND GE.DISCIPLINA = M.DISCIPLINA
--)
--AND NOT EXISTS
--(
--	SELECT TOP 1 1
--	FROM LY_GRADE G
--	JOIN LY_DISCIPLINA DG
--		ON (G.DISCIPLINA = DG.DISCIPLINA)
--	WHERE G.CURSO = A.CURSO AND G.TURNO = A.TURNO AND G.CURRICULO = A.CURRICULO AND G.FORMULA_EQUIV LIKE '%' + M.DISCIPLINA + '%'
--	AND DG.NOME_COMPL LIKE '%Optativa%'
--)
--AND EXISTS
--(
--	SELECT TOP 1 1
--	FROM LY_GRADE G
--	JOIN LY_DISCIPLINA DG
--		ON (G.DISCIPLINA = DG.DISCIPLINA)
--	WHERE G.CURSO = A.CURSO AND G.TURNO = A.TURNO AND G.CURRICULO = A.CURRICULO AND G.FORMULA_EQUIV LIKE '%' + M.DISCIPLINA + '%'
--	AND DG.CREDITOS <> D.CREDITOS
--)

DECLARE 
  @V_VALOR_DISCIPLINA DECIMAL(14,2)
, @V_CODIGO_LANC T_CODIGO
, @V_DESCRICAO T_ALFALARGE

EXEC A_CALCULA_VALOR_DISCIPLINA
  '012030101'			--  @P_ALUNO T_CODIGO, 
, 2018					--  @P_ANO T_ANO,
, 2						--  @P_PERIODO T_SEMESTRE2,
, '2054'				--  @P_CURSO T_CODIGO, 
, 'N'					--  @P_TURNO T_CODIGO,  
, '23827'				--  @P_CURRICULO T_CODIGO, 
, NULL					--  @P_SERIE T_NUMERO_PEQUENO, 
, '147427'				--  @P_DISCIPLINA T_CODIGO, 
, @V_VALOR_DISCIPLINA	OUTPUT 
, @V_CODIGO_LANC		OUTPUT
, @V_DESCRICAO			OUTPUT
, NULL					--  @P_CALC_SERIE_INCOMPL T_SIMNAO

SELECT
  @V_VALOR_DISCIPLINA 
, @V_CODIGO_LANC
, @V_DESCRICAO 

SELECT * FROM zzCRO_Erros WHERE SPID = @@SPID