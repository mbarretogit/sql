USE LYCEUM
GO


SELECT DISTINCT A.ALUNO
FROM LY_ALUNO A
JOIN LY_CURSO C ON C.CURSO = A.CURSO
WHERE 1=1 AND CONCAT(A.ANO_INGRESSO,A.SEM_INGRESSO) < '20182'
AND A.SIT_ALUNO = 'Ativo'
AND C.TIPO IN ('GRADUACAO','TECNOLOGO')
AND EXISTS (SELECT TOP 1 1 FROM LY_HISTMATRICULA WHERE ALUNO = A.ALUNO AND ANO = 2018 AND SEMESTRE = 1 AND SITUACAO_HIST NOT IN ('Dispensado','Cancelado')) --HISTORICO EM 2018.1 NAO CANCELADO NEM DISPENSADO
AND NOT EXISTS (SELECT TOP 1 1 FROM VW_MATRICULA_E_PRE_MATRICULA WHERE ALUNO = A.ALUNO AND ANO = 2018 AND SEMESTRE = 2) --SEM MATRICULA EM 2018.2
AND NOT EXISTS (SELECT TOP 1 1 FROM LY_BOLSA 
					WHERE ALUNO = A.ALUNO AND DATA_CANCEL IS NULL 
					AND PERC_VALOR = 'Percentual' AND VALOR = 1				--SEM BOLSA 100%
					AND (ANOFIM >= YEAR(GETDATE()) OR ANOFIM IS NULL) 
					AND (MESFIM >= MONTH(GETDATE()) OR MESFIM IS NULL)
					)
AND NOT EXISTS (SELECT TOP 1 1 FROM LY_ITEM_CRED IC
				JOIN LY_ITEM_LANC IL ON IL.COBRANCA = IC.COBRANCA
				JOIN LY_LANC_DEBITO LD ON LD.LANC_DEB = IL.LANC_DEB
				WHERE LD.ANO_REF = 2018
				AND TIPO_ENCARGO IS NULL AND TIPODESCONTO IS NULL		--SEM PAGAMENTO
				AND LD.PERIODO_REF = 2
				AND LD.ALUNO = A.ALUNO 
				AND LD.CODIGO_LANC IN ('MS','MS_EB'))