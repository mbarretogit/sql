use lyceum
go

SELECT DISTINCT  
              PM.ANO, 
			  PM.SEMESTRE, 
			  C.CURSO,  
			  C.NOME AS NOME_CURSO, 
			  A.CURRICULO, 
			  A.TURNO, 
			  C.FACULDADE, 
              UE.NOME_COMP as NOME_FACULDADE, 
			  PM.SIT_MATRICULA, 
			  A.ALUNO, 
			  pes.NOME_COMPL,
              pes.CPF,
			  pes.RG_NUM, 
			  a.anoconcl_2g as ANO_CONCLUSAO_2G, 
			  pes.E_MAIL,
			  pes.ENDERECO,
              pes.END_NUM AS NUMERO,
              pes.END_COMPL AS COMPLEMENTO,
              pes.CEP,
              hm.NOME AS CIDADE,
              hm.UF AS ESTADO,	
              pes.FONE, 
			  pes.CELULAR, 
			  B.TIPO_BOLSA, 
			  TB.DESCRICAO AS NOME_BOLSA, 
              B.PERC_VALOR, 
			  B.VALOR, 
			  B.ANOINI, 
			  B.MESINI, 
			  B.ANOFIM, 
			  B.MESFIM, 
              B.DATA_BOLSA, 
			  B.DATA_CANCEL AS DATA_CANCELAMENTO_BOLSA,  
              PM.DISCIPLINA, 
			  D.NOME AS NOME_DISCIPLINA, 
			  PM.TURMA,
			  T.UNIDADE_RESPONSAVEL, 
			  T.NUM_FUNC AS COD_DOCENTE,
			  doc.NOME_COMPL AS NOME_DOCENTE,
			  PM.CONFIRMADA,
              a.sit_aluno
			  	
,ISNULL((SELECT TOP 1 'S' 
			FROM LY_ITEM_LANC IL
			JOIN LY_LANC_DEBITO LD
				ON IL.LANC_DEB = LD.LANC_DEB 
			JOIN VW_COBRANCA C
				ON IL.COBRANCA = C.COBRANCA
		WHERE LD.ALUNO = PM.ALUNO
		AND LD.ANO_REF = PM.ANO
		AND LD.PERIODO_REF = PM.SEMESTRE
		AND C.VALOR = 0
		AND LD.LANC_DEB = PM.LANC_DEB
		GROUP BY IL.COBRANCA
		HAVING MAX(IL.PARCELA) = 1
		),'N') AS PAGO
FROM (SELECT ANO, SEMESTRE, DISCIPLINA, TURMA, ALUNO, SIT_MATRICULA, LANC_DEB, DT_ULTALT , SERIE_CALCULO, COBRANCA_SEP, SIT_DETALHE, GRUPO_ELETIVA , DT_INSERCAO, 'S' AS CONFIRMADA
FROM LY_MATRICULA  
UNION ALL
SELECT ANO, SEMESTRE, DISCIPLINA, TURMA, ALUNO, 'Pre-Matriculado' SIT_MATRICULA, LANC_DEB, DT_ULTALT, SERIE_CALCULO, COBRANCA_SEP, SIT_DETALHE, GRUPO_ELETIVA, DT_INSERCAO, CONFIRMADA  
FROM LY_PRE_MATRICULA  ) PM	
join ly_aluno a							-- Para join com curso
	on pm.aluno = a.aluno
join ly_pessoa pes
    on pes.pessoa = a.pessoa
join ly_curso c							-- para saber nome do curso e join com unidade ensino
	on a.curso = c.curso
JOIN LY_DISCIPLINA D
	ON PM.DISCIPLINA = D.DISCIPLINA
join LY_UNIDADE_ENSINO ue				-- para saber nome unidade ensino
	on c.FACULDADE = ue.UNIDADE_ENS
left join ly_bolsa b
	on pm.aluno = b.aluno
left join ly_tipo_bolsa tb
	on b.tipo_bolsa = tb.tipo_bolsa
LEFT JOIN ly_turma t ON t.TURMA = pm.TURMA AND t.DISCIPLINA = pm.DISCIPLINA AND t.ANO = pm.ANO AND t.SEMESTRE = pm.SEMESTRE
join HD_MUNICIPIO hm
	ON hm.MUNICIPIO = pes.END_MUNICIPIO
JOIN LY_DOCENTE doc ON doc.num_func = t.NUM_FUNC 
where 1= 1 
and c.TIPO = 'GRADUACAO'	
--and C.FACULDADE = '04' AND C.CURSO = '722'
--group by c.curso, c.nome, c.FACULDADE, ue.NOME_COMP	, pm.sit_matricula
order by c.FACULDADE, ue.NOME_COMP,  c.curso, c.nome	
