/*
Alunos de Gradua��o que tem boletogerado para o MoneyPlus em Janeiro Banco 274
Que j�pa possuem disicplina N�O-FAKE na (pre)matr�cula 2021.1
N�o tem contrato aceito
E n�o tenha nenhum outro boleto gerado para outro banco diferente de 274

LY_BOLETO
LY_COBRANCA 
LY_ITEM_LANC

Colocar esses alunos em 1 conjunto

*/

USE LYCEUM
GO

DECLARE @ANO INT = 2021
DECLARE @SEMESTRE INT = 1
	
	--INSERT INTO LY_DEF_CONJ_ALUNO
	--SELECT 'SEM_CONTRATO_PRE_MP','alunos em pr� matr�cula que possuem boletos do banco 274 (Money Plus) e n�o possuem contrato'


	--INSERT INTO LY_CONJ_ALUNO
	--UPDATE G SET G.GRUPO = 'GP_'+C.FACULDADE+'_GRA'
	SELECT * 
	FROM LY_LANC_DEBITO G
	JOIN LY_ALUNO A ON A.ALUNO = G.ALUNO
	JOIN LY_CURSO C ON C.CURSO = A.CURSO
	WHERE G.ALUNO IN(
	SELECT DISTINCT ALUNO
	FROM LY_ALUNO A
	JOIN LY_CURSO C ON C.CURSO = A.CURSO
	WHERE 1=1
	--ALUNOS DE GRADUA��O
	AND C.TIPO IN ('GRADUACAO','TECNOLOGO')
	--POSSUEM DISCIPLINA NAO FAKE NA PRE OU MATRICULA
	AND EXISTS (SELECT TOP 1 1 FROM LY_MATRICULA WHERE ALUNO = A.ALUNO AND ANO = @ANO AND SEMESTRE = @SEMESTRE AND NOT (DISCIPLINA LIKE 'MF_%' OR DISCIPLINA LIKE 'AF_%' OR DISCIPLINA LIKE 'MFM_%')) 
	--POSSUEM BOLETO PRO BANCO 274 E NAO POSSUI NENHUM OUTRO BOLETO PRA 274
	AND EXISTS (
				  select TOP 1 1
				  from lyceum..LY_ITEM_LANC l
				  INNER JOIN LYCEUM..LY_LANC_DEBITO LD ON LD.LANC_DEB = L.LANC_DEB
				  INNER JOIN LYCEUM..LY_COBRANCA C ON C.COBRANCA = L.COBRANCA
				  where 1 = 1 
				  and l.boleto in ( select BOLETO from lyceum..ly_boleto WHERE BANCO = '274' )
				  AND C.NUM_COBRANCA = 1       
				  AND LD.ANO_REF = @ANO 
				  AND LD.PERIODO_REF = @SEMESTRE
				  AND l.aluno = a.aluno
				 AND NOT EXISTS (
								  select top 1 1     
								  from lyceum..LY_ITEM_LANC l
								  INNER JOIN LYCEUM..LY_LANC_DEBITO LD ON LD.LANC_DEB = L.LANC_DEB
								  INNER JOIN LYCEUM..LY_COBRANCA C ON C.COBRANCA = L.COBRANCA
								  where l.boleto in ( select BOLETO from lyceum..ly_boleto WHERE BANCO <> '274' )
								  AND C.NUM_COBRANCA = 1
								  AND LD.ANO_REF = @ANO 
								  AND LD.PERIODO_REF = @SEMESTRE
								  AND L.ALUNO = A.ALUNO
									)
	)
	--N�O TEM CONTRATO ACEITO NO PER�ODO
	AND NOT EXISTS (
		SELECT TOP 1 1 FROM LY_CONTRATO_ALUNO WHERE ALUNO = A.ALUNO AND ANO = @ANO AND PERIODO = @SEMESTRE AND CONTRATO_ACEITO = 'S'
	)
)