DECLARE
@P_TURMA VARCHAR(20),
@P_SUBTURMA1 VARCHAR(20),
@P_SUBTURMA2 VARCHAR(20)

EXEC PR_RETORNA_TURMA '2018','2','143016','04','FTC-SSA','722','I','TEOPRA','182041525',@P_TURMA OUTPUT,@P_SUBTURMA1 OUTPUT,@P_SUBTURMA2 OUTPUT

SELECT @P_TURMA, @P_SUBTURMA1, @P_SUBTURMA2

--182040915
select * FROM LY_ALUNO WHERE ALUNO = '182041524'
select * FROM LY_PRE_MATRICULA WHERE ALUNO = '182041525'
select TIPO, * from LY_DISCIPLINA WHERE DISCIPLINA = '143016'
select * FROM LY_PRE_MATRICULA WHERE DISCIPLINA = 'SPR426'
select NIVEL,* FROM LY_TURMA WHERE DISCIPLINA = '143016' AND ANO = 2018 AND SEMESTRE =2

select * FROM LY_ASSOC_TURMA_SUBTURMA WHERE ANO = '2018' AND PERIODO = '2' AND DISCIPLINA = '143016'
select TIPO,* FROM LY_DISCIPLINA WHERE DISCIPLINA IN ('PSI400','PSI410','PSI411','PSI412','PSI590','UDI412','UPR407')

SELECT *
			FROM LY_ASSOC_TURMA_SUBTURMA ATS
			WHERE ATS.ANO = 2018
			AND ATS.PERIODO = 2			--AJUSTE REALIZADO POR MIGUEL PARA VALIDAR SE A TURMA ESTA ASSOCIADA � SUBTURMA
			AND ATS.DISCIPLINA = 'ODT401'

--  @P_ANO INT
--, @P_SEMESTRE INT
--, @P_DISCIPLINA VARCHAR(20)
--, @P_UNIDADE_RESPONSAVEL VARCHAR(20)
--, @P_UNIDADE_FISICA VARCHAR(20)
--, @P_CURSO VARCHAR(20)
--, @P_TURNO VARCHAR(20)
--, @P_TIPO_DISCIPLINA VARCHAR(20)
--, @P_ALUNO VARCHAR(20)
--, @P_TURMA VARCHAR(20) OUTPUT
--, @P_SUBTURMA1 VARCHAR(20) OUTPUT
--, @P_SUBTURMA2 VARCHAR(20) OUTPUT