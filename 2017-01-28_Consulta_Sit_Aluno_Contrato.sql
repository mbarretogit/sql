USE LYCEUM
GO

DECLARE 
	@ALUNO AS VARCHAR(20),
	@SERVICO AS VARCHAR(20),
	@RESP AS VARCHAR(20),
	@CURSO AS VARCHAR(10),
	@TURNO AS VARCHAR(1),
	@CURRICULO AS VARCHAR(20),
	@SERIE AS VARCHAR(2),
	@ANO AS VARCHAR(4),
	@SEMESTRE AS VARCHAR(2)
	
SET @ALUNO = '191040013'
SET @ANO = '2019'
SET @SEMESTRE = '1'
SET @CURSO = (SELECT CURSO FROM LY_ALUNO WHERE ALUNO = @ALUNO)
SET @TURNO = (SELECT TURNO FROM LY_ALUNO WHERE ALUNO = @ALUNO)
SET @CURRICULO = (SELECT CURRICULO FROM LY_ALUNO WHERE ALUNO = @ALUNO)
SET @SERIE = (SELECT SERIE FROM LY_ALUNO WHERE ALUNO = @ALUNO)
SET @SERVICO = (SELECT SERVICO_CRED FROM LY_SERIE WHERE CURSO = @CURSO AND TURNO = @TURNO AND CURRICULO = @CURRICULO AND SERIE = @SERIE)
SET @RESP = (SELECT RESP FROM LY_PLANO_PGTO_PERIODO WHERE ALUNO = @ALUNO AND ANO = @ANO AND PERIODO = @SEMESTRE)

--QUAL A SITUA��O DO ALUNO
SELECT SIT_ALUNO,* FROM LY_ALUNO WHERE ALUNO = @ALUNO
--EXISTE CONTRATO PARA ESSE CURSO/TURNO/CURRICULO/SERIE?
SELECT * FROM LY_CURRICULO_CONTRATO WHERE CURSO = @CURSO AND TURNO = @TURNO AND CURRICULO = @CURRICULO AND SERIE = @SERIE
--TEM CONTRATO?
SELECT * FROM LY_CONTRATO_ALUNO WHERE ALUNO = @ALUNO AND ANO = @ANO AND PERIODO = @SEMESTRE
--TEM CONTRATO REMOVIDO?
SELECT * FROM LY_CONTRATO_REMOVIDO WHERE ALUNO = @ALUNO AND ANO = @ANO AND PERIODO = @SEMESTRE
--TEM SERVI�O ASSOCIADO A SERIE DO ALUNO?
SELECT * FROM LY_SERIE WHERE CURSO = @CURSO AND TURNO = @TURNO AND CURRICULO = @CURRICULO AND SERIE = @SERIE
--TEM VALOR DE SERVI�O PARA A SERIE DO ALUNO?
SELECT * FROM LY_VALOR_SERV_PERIODO WHERE SERVICO = @SERVICO AND ANO = @ANO AND PERIODO = @SEMESTRE
--TEM PLANO DE PAGAMENTO?
SELECT * FROM LY_PLANO_PGTO_PERIODO WHERE ALUNO = @ALUNO AND ANO = @ANO AND PERIODO = @SEMESTRE
--COMO ESTA O CADASTRO DO RESPONSAVEL FINANCEIRO?
SELECT APENAS_FATURAMENTO,* FROM LY_RESP_FINAN WHERE RESP = @RESP
--POSSUI PRE/MATRICULA?
SELECT * FROM VW_MATRICULA_E_PRE_MATRICULA WHERE ALUNO = @ALUNO AND ANO = @ANO AND SEMESTRE = @SEMESTRE
--TEM BOLSA?
SELECT * FROM LY_BOLSA WHERE ALUNO = @ALUNO