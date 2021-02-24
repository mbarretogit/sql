select distinct a.ALUNO, a.nome_compl, a.CURRICULO, a.TURNO, c.CURSO, c.NOME, d.disciplina, d.nome, m.lanc_deb as DIVIDA
from ly_matricula m
join ly_aluno a on a.aluno = m.aluno
join ly_curso c on c.curso = a.curso
join LY_DISCIPLINA d on d.disciplina = m.disciplina
where LANC_DEB is null and ANO = 2017 and SEMESTRE = 2
order by 5,2