select distinct tipo from ly_curso
--EB, POS, EXT,MEST,ACAD

select distinct a.UNIDADE_FISICA, a.curso,c.NOME, a.ANO_INGRESSO, a.SEM_INGRESSO, a.sit_aluno, a.aluno, a.NOME_COMPL, case when vw.aluno is null then 'N' else 'S' end as MATRICULA from ly_aluno a
join ly_curso c on c.CURSO = a.CURSO
left join VW_MATRICULA_E_PRE_MATRICULA vw on vw.aluno = a.aluno
where 1=1 --a.SIT_ALUNO = 'Ativo'
and c.TIPO = 'pos-graduacao'
--and vw.SIT_MATRICULA <> 'Cancelado'
order by 1,2,4,5,6