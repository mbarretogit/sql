IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.FTC_SP_csvListaTurmas'))
   exec('CREATE PROCEDURE [dbo].[FTC_SP_csvListaTurmas] AS BEGIN SET NOCOUNT OFF; END')
GO 

ALTER PROCEDURE dbo.FTC_SP_csvListaTurmas
(      
  @P_ANO VARCHAR(4)
, @P_SEMESTRE VARCHAR(1)
, @P_FACULDADE VARCHAR(20)
, @P_TIPO_CURSO VARCHAR(20)  
, @P_CURSO  VARCHAR(20)  
, @P_TURNO  VARCHAR(20)  
, @P_CURRICULO VARCHAR(20)  
)      
AS      
-- [IN�CIO]              
BEGIN      
  
SET NOCOUNT ON  
  
  SELECT	T.UNIDADE_RESPONSAVEL				AS [UNIDADE_ENSINO],
		UE.NOME_COMP							AS [NOME_UNIDADE_ENS],
		T.FACULDADE								AS [UNIDADE_FISICA],
		UF.NOME_COMP							AS [NOME_UNIDADE_FIS],
		T.ANO									AS [ANO],
		T.SEMESTRE								AS [SEMESTRE],
		T.SIT_TURMA								AS [SIT_TURMA],
		T.TURMA									AS [TURMA],
		T.DISCIPLINA							AS [DISCIPLINA],
		isnull(T.NIVEL,'')						AS [NIVEL],
		D.NOME									AS [NOME_DISCIPLINA],
		T.CURSO									AS [CURSO],
		C.NOME									AS [NOME_CURSO]
FROM LY_TURMA T
JOIN LY_DISCIPLINA D ON D.DISCIPLINA = T.DISCIPLINA
JOIN LY_UNIDADE_ENSINO UE ON UE.UNIDADE_ENS = T.UNIDADE_RESPONSAVEL
JOIN LY_UNIDADE_FISICA UF ON UF.UNIDADE_FIS = T.FACULDADE
JOIN LY_CURSO C ON C.CURSO = T.CURSO
WHERE  ((@P_ANO IS NOT NULL AND T.ANO = @P_ANO) OR @P_ANO IS NULL)
AND ((@P_SEMESTRE IS NOT NULL AND T.SEMESTRE = @P_SEMESTRE) OR @P_SEMESTRE IS NULL)
AND ((@P_FACULDADE IS NOT NULL AND C.FACULDADE = @P_FACULDADE) OR @P_FACULDADE IS NULL) 
AND ((@P_TIPO_CURSO IS NOT NULL AND C.TIPO = @P_TIPO_CURSO) OR @P_TIPO_CURSO IS NULL)  
AND ((@P_CURSO IS NOT NULL AND C.CURSO = @P_CURSO) OR @P_CURSO IS NULL)
AND ((@P_TURNO IS NOT NULL AND T.TURNO = @P_TURNO) OR @P_TURNO IS NULL)  
AND ((@P_CURRICULO IS NOT NULL AND T.CURRICULO = @P_CURRICULO) OR @P_CURRICULO IS NULL)   
ORDER BY 1,3,8  
  
SET NOCOUNT OFF  
  
END              
GO
-- [FIM]      



--##
--## PARAMETRIZA��O/CADASTRO DA LISTA NO LYCEUM
--##

DECLARE @V_CONSULTA_DINAMICA INT
DECLARE @V_NOME_CONSULTA_DINAMICA varchar(100)

-- Colocar nome da lista (que ser� apresentada no combo)
set @V_NOME_CONSULTA_DINAMICA ='Custom - Lista de Turmas Cadastradas por Per�odo Letivo'

-- Consulta ID da Lista
SELECT @V_CONSULTA_DINAMICA = ID FROM LY_CONSULTA_DINAMICA WHERE TITULO = @V_NOME_CONSULTA_DINAMICA

-- armazena padr�es de acesso
SELECT PADACES
INTO #TEMP_CONSULTA_DINAMICA
FROM LY_CONSULTA_DINAMICA_PADACES WHERE ID = @V_CONSULTA_DINAMICA


DELETE LY_CONSULTA_DINAMICA_PADACES WHERE ID_CONSULTA_DINAMICA = @V_CONSULTA_DINAMICA
DELETE LY_CONSULTA_DINAMICA_PARAMETROS WHERE ID_CONSULTA_DINAMICA = @V_CONSULTA_DINAMICA
DELETE LY_CONSULTA_DINAMICA WHERE ID = @V_CONSULTA_DINAMICA

BEGIN

IF NOT EXISTS(SELECT 1 FROM LY_CONSULTA_DINAMICA C WHERE C.TITULO = @V_NOME_CONSULTA_DINAMICA)
INSERT INTO LY_CONSULTA_DINAMICA(TITULO, TIPO, STORED_PROCEDURE)
VALUES(@V_NOME_CONSULTA_DINAMICA,'CSV','sp:FTC_SP_csvListaTurmas(@P_ANO@,@P_SEMESTRE@,@P_FACULDADE@,@P_TIPO_CURSO@,@P_CURSO@,@P_TURNO@,@P_CURRICULO@)')

SET @V_CONSULTA_DINAMICA = @@IDENTITY

-- Insere padr�es de acesso
INSERT INTO LY_CONSULTA_DINAMICA_PADACES (ID_CONSULTA_DINAMICA, PADACES)
SELECT @V_CONSULTA_DINAMICA, PADACES FROM #TEMP_CONSULTA_DINAMICA

-- Insere parametros

	--@p_ano				T_ANO,
	--@p_semestre			T_Semestre2,
	--@p_unidade_ensino	T_codigo,
	--@p_tipo_curso		T_codigo,
	--@p_curso			T_codigo,
	--@p_turno			T_codigo,
	--@p_curriculo		T_codigo,	
	--@p_sit_matricula	T_codigo,
	--@p_tem_turma		varchar(1)

INSERT INTO LY_CONSULTA_DINAMICA_PARAMETROS(ID_CONSULTA_DINAMICA,ORDEM,PARAMETRO,TIPO,DESCRICAO,OBRIGATORIO,SQL_TEXTO,COL_VALOR,COL_DESCR)
SELECT @V_CONSULTA_DINAMICA, 1, 'P_ANO', 5, 'Ano', 'N', 'SELECT DISTINCT ANO AS CODIGO, (''ANO: '' + convert(varchar,ANO)) AS DESCRICAO FROM LY_PERIODO_LETIVO ORDER BY ANO DESC', 'CODIGO' COL_VALOR, 'DESCRICAO' COL_DESCR

INSERT INTO LY_CONSULTA_DINAMICA_PARAMETROS(ID_CONSULTA_DINAMICA,ORDEM,PARAMETRO,TIPO,DESCRICAO,OBRIGATORIO,SQL_TEXTO,COL_VALOR,COL_DESCR)
SELECT @V_CONSULTA_DINAMICA, 2, 'P_SEMESTRE', 5, 'Per�odo', 'N', 'SELECT DISTINCT PERIODO AS CODIGO, (''PER�ODO: '' + convert(varchar,PERIODO)) AS DESCRICAO FROM LY_PERIODO_LETIVO WHERE ANO = ISNULL(@p_ano@,ANO) ORDER BY PERIODO', 'CODIGO' COL_VALOR, 'DESCRICAO' COL_DESCR

INSERT INTO LY_CONSULTA_DINAMICA_PARAMETROS(ID_CONSULTA_DINAMICA,ORDEM,PARAMETRO,TIPO,DESCRICAO,OBRIGATORIO,SQL_TEXTO,COL_VALOR,COL_DESCR)
SELECT @V_CONSULTA_DINAMICA, 3, 'P_FACULDADE', 5, 'Unidade Ensino', 'N', 'Select unidade_ens as codigo, nome_comp as descricao from ly_unidade_ensino order by unidade_ens', 'CODIGO' COL_VALOR, 'DESCRICAO' COL_DESCR

INSERT INTO LY_CONSULTA_DINAMICA_PARAMETROS(ID_CONSULTA_DINAMICA,ORDEM,PARAMETRO,TIPO,DESCRICAO,OBRIGATORIO,SQL_TEXTO,COL_VALOR,COL_DESCR)
SELECT @V_CONSULTA_DINAMICA, 4, 'P_TIPO_CURSO', 5, 'Tipo de Curso', 'N', 'Select tipo as codigo, descricao from ly_tipo_curso order by tipo', 'CODIGO' COL_VALOR, 'DESCRICAO' COL_DESCR

INSERT INTO LY_CONSULTA_DINAMICA_PARAMETROS(ID_CONSULTA_DINAMICA,ORDEM,PARAMETRO,TIPO,DESCRICAO,OBRIGATORIO,SQL_TEXTO,COL_VALOR,COL_DESCR)
SELECT @V_CONSULTA_DINAMICA, 5, 'P_CURSO', 5, 'Curso', 'N', 'Select Curso as codigo, nome as descricao from ly_curso where tipo = isnull(@p_tipo_curso@,tipo) order by tipo', 'CODIGO' COL_VALOR, 'DESCRICAO' COL_DESCR

INSERT INTO LY_CONSULTA_DINAMICA_PARAMETROS(ID_CONSULTA_DINAMICA,ORDEM,PARAMETRO,TIPO,DESCRICAO,OBRIGATORIO,SQL_TEXTO,COL_VALOR,COL_DESCR)
SELECT @V_CONSULTA_DINAMICA, 6, 'P_TURNO', 5, 'Turno', 'N', 'Select turno as codigo, descricao from ly_turno order by turno', 'CODIGO' COL_VALOR, 'DESCRICAO' COL_DESCR

INSERT INTO LY_CONSULTA_DINAMICA_PARAMETROS(ID_CONSULTA_DINAMICA,ORDEM,PARAMETRO,TIPO,DESCRICAO,OBRIGATORIO,SQL_TEXTO,COL_VALOR,COL_DESCR)
SELECT @V_CONSULTA_DINAMICA, 7, 'P_CURRICULO', 5, 'Curriculo', 'N', 'Select Curriculo as CODIGO, (''Curr�culo: '' + convert(varchar,Curriculo)) AS DESCRICAO FROM LY_curriculo WHERE curso = ISNULL(@p_curso@,curso) AND turno = ISNULL(@p_turno@,turno) and dt_extincao is null ORDER BY curriculo', 'CODIGO' COL_VALOR, 'DESCRICAO' COL_DESCR

--SELECT * FROM LY_CONSULTA_DINAMICA WHERE ID = @V_CONSULTA_DINAMICA
--SELECT * FROM LY_CONSULTA_DINAMICA_PARAMETROS WHERE ID_CONSULTA_DINAMICA = @V_CONSULTA_DINAMICA

drop table  #TEMP_CONSULTA_DINAMICA

END
GO

delete from LY_CUSTOM_CLIENTE
where NOME = 'FTC_SP_csvListaTurmas'
and IDENTIFICACAO_CODIGO = '0001'
go

INSERT INTO LY_CUSTOM_CLIENTE
(NOME, IDENTIFICACAO_CODIGO, AUTOR, DATA_CRIACAO, OBJETIVO, SOLICITADO_POR, ATIVO, TIPOCOMPONENTE, TIPO, CLIENTE)
SELECT
  'FTC_SP_csvListaTurmas' NOME
, '0001' IDENTIFICAO_CODIGO
, 'Miguel' AUTOR
, '2016-11-17' DATA_CRIACAO
, 'ListaNG - Lista de Turmas por Per�odo Letivo' OBJETIVO
, 'Andr� Britto' SOLICITADO_POR
, 'S' ATIVO
, 'PROCEDURE' TIPOCOMPONENTE
, 'CLIENTE' TIPO
, 'FTC' CLIENTE
go 