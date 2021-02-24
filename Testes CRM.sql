select * from ly_concurso c 
where not exists (select top 1 1 from ly_oferta_curso where concurso = c.concurso)
and c.ano = 2018 and c.semestre = 1
order by 1

select * from ly_concurso c 
where not exists (select top 1 1 from LY_CANDIDATO where concurso = c.concurso)
and c.ano = 2018 and c.semestre = 1
order by 1


select * from LY_CONCURSO where concurso IN ('190','191')
select * from LY_CANDIDATO where concurso = '134'
select concurso from LY_CONCURSO where dt_vest is null

select * from LY_CONCURSO where concurso IN ('198')
select * FROM LY_OFERTA_CURSO WHERE CONCURSO = '198'
select * FROM LY_CONVOCADOS_VEST WHERE CONCURSO = '198'

select top 20 * from LY_INTEGRACAO_LOG order by TIME_INI desc
select * from LY_INTEGRACAO_ANDAMENTO_LOG where parametros_execucao like '%198%Teste%Ti%'
