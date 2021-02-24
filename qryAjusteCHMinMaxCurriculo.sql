USE LYCEUM
GO

--UPDATE LY_CURRICULO SET CREDMAX_MATR = 999, CREDMIN_MATR = 0

--## ESTABELECENDO MÍNIMO E MÁXIMO PARA CADA GRADE ##--

select	cc.nome,g.CURSO, g.TURNO, g.CURRICULO
		,round(SUM(d.CREDITOS)/COUNT(distinct g.serie_ideal),0) AS MEDIA_SEMESTRAL
		,round(SUM(d.CREDITOS)/COUNT(distinct g.serie_ideal)*1.3,0) AS ACIMA30
		,round(SUM(d.CREDITOS)/COUNT(distinct g.serie_ideal)*0.7,0) AS ABAIXO30
--INTO #TEMP1 --DROP TABLE #TEMP1
from LY_GRADE g
join LY_DISCIPLINA d on d.DISCIPLINA = g.DISCIPLINA
join LY_CURRICULO c on c.CURRICULO = g.CURRICULO and c.CURSO = g.CURSO and c.TURNO = g.TURNO
join LY_CURSO cc on cc.CURSO = c.CURSO
where c.DT_EXTINCAO is null and cc.ATIVO = 'S' and cc.TIPO IN ('GRADUACAO','TECNOLOGO') AND cc.FACULDADE <> '02'
and exists (select top 1 1 from LY_ALUNO a where a.CURRICULO = c.CURRICULO and a.CURSO = c.CURSO and a.TURNO = c.TURNO and a.SIT_ALUNO = 'Ativo')
group by g.CURSO,g.TURNO, g.CURRICULO,cc.nome
order by 2 desc
GO

--SELECT * FROM #TEMP1 ORDER BY 2

--##  Verificando Total de CH de cada série  ##--
select	g.CURSO, g.TURNO, g.CURRICULO, g.SERIE_IDEAL
		,round(SUM(d.CREDITOS),0) AS TOTAL_HORA_SERIE
--INTO #TEMP2 --DROP TABLE #TEMP2
from LY_GRADE g
join LY_DISCIPLINA d on d.DISCIPLINA = g.DISCIPLINA
join LY_CURRICULO c on c.CURRICULO = g.CURRICULO and c.CURSO = g.CURSO and c.TURNO = g.TURNO
join LY_CURSO cc on cc.CURSO = c.CURSO
where c.DT_EXTINCAO is null and cc.ATIVO = 'S' and cc.TIPO IN ('GRADUACAO','TECNOLOGO') AND cc.FACULDADE <> '02'
and exists (select top 1 1 from LY_ALUNO a where a.CURRICULO = c.CURRICULO and a.CURSO = c.CURSO and a.TURNO = c.TURNO and a.SIT_ALUNO = 'Ativo')
group by g.CURSO,g.TURNO, g.CURRICULO,cc.nome,g.SERIE_IDEAL
GO


---##  Ajuste de casos que fogem da regra  ##-

UPDATE T1 SET ABAIXO30 = (SELECT MIN(T2.TOTAL_HORA_SERIE) FROM #TEMP2 T2 WHERE T2.CURRICULO = T1.CURRICULO AND T2.CURSO = T1.CURSO AND T2.TURNO = T1.TURNO)
FROM #TEMP1 T1 
JOIN #TEMP2 T2 ON T2.CURRICULO = T1.CURRICULO AND T2.CURSO = T1.CURSO AND T2.TURNO = T1.TURNO
WHERE T1.ABAIXO30 > T2.TOTAL_HORA_SERIE
GO

UPDATE T1 SET ACIMA30 = (SELECT MAX(T2.TOTAL_HORA_SERIE) FROM #TEMP2 T2 WHERE T2.CURRICULO = T1.CURRICULO AND T2.CURSO = T1.CURSO AND T2.TURNO = T1.TURNO)
FROM #TEMP1 T1 
JOIN #TEMP2 T2 ON T2.CURRICULO = T1.CURRICULO AND T2.CURSO = T1.CURSO AND T2.TURNO = T1.TURNO
WHERE T1.ACIMA30 < T2.TOTAL_HORA_SERIE
GO

-- ## UPDATE EM CH MIN E MAX DOS CURRICULOS ## --

UPDATE C SET C.CREDMIN_MATR = T1.ABAIXO30, C.CREDMAX_MATR = T1.ACIMA30
FROM LY_CURRICULO C
JOIN #TEMP1 T1 ON T1.CURRICULO = C.CURRICULO AND T1.CURSO = C.CURSO AND T1.TURNO = C.TURNO
GO

--select * from #TEMP1 where curso = '2087' and turno = 'N' and curriculo = '23823'
--select sum(d.creditos) from ly_pre_matricula pm, ly_disciplina d where pm.aluno = '122030403' and d.disciplina = pm.disciplina
--select disciplina, curriculo, turno, curso, serie_ideal,* from ly_grade where curso = '3176' and turno = 'N' and curriculo = '25030'
--order by 5

--select * from ly_aluno where aluno = '122030403'
--select * from vw_matricula_e_pre_matricula where aluno = '182040100'
--select * FROM ly_disciplina where disciplina in ('143060','143062','143063')