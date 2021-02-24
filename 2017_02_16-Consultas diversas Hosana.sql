

--## Pre-matriculas sem turma - usar junto com enturmação
-- indico se tem turma e o tipo da disciplina
select distinct pm.aluno, a.curso, c.nome as nomeCurso,  pm.disciplina, isnull(pm.turma,'--') as turma, isnull(pm.MENS_ERRO,'--') as ERRO, isnull(d.TIPO,'--') as NIVEL, isnull((select distinct 'S' from ly_turma where disciplina = pm.disciplina and ano = pm.ano and SEMESTRE = pm.SEMESTRE),'N') as tem_turma
from LY_PRE_MATRICULA pm
join ly_disciplina d
	on pm.disciplina = d.disciplina
join ly_aluno a
	on  pm.aluno = a.aluno
join ly_curso c
	on a.curso = c.curso
where ano = 2017
and SEMESTRE = 1
and turma is null


--## cadastro de turmas com quantidade de alunos em cada
select 
	t.ano,
	t.SEMESTRE,
	t.DISCIPLINA,
	t.TURMA,
	t.UNIDADE_RESPONSAVEL,
	t.CURSO,
	t.turno,
	t.CURRICULO,
	t.SERIE,
	t.NUM_ALUNOS as VAGAS_TURMA,
	m.QNT_ALUNOS
from ly_turma t
join (select ano, semestre, disciplina, turma, count(*) as QNT_ALUNOS from VW_MATRICULA_E_PRE_MATRICULA where sit_matricula in ('Pre-Matriculado','Matriculado') group by  ano, semestre, disciplina, turma) m
		ON m.DISCIPLINA = t.DISCIPLINA
		and m.TURMA = t.turma
		and m.ano = t.ano
		and m.SEMESTRE = t.SEMESTRE
where t.ano		= 2017
and t.SEMESTRE	= 1
and t.SIT_TURMA	= 'Aberta'
  

-- Alunos com pre-matricula e estão na matricula -> precisam ser confirmados -> criar um conj de alunos e rodar a confirmação sem validar financeiro, pois se estão na matricula teoricamente ja passaram pela confirmação.
select * 
from LY_PRE_MATRICULA pm
where ano = 2017
and SEMESTRE = 1
and exists (select top 1 1 from ly_matricula 
			where aluno = pm.aluno
			and ano = pm.ano
			and SEMESTRE = pm.SEMESTRE)


--## Alunos qeu estão na pre-matricula, não estão na matricula e tem valor zero de saldo
-- Pode ser que nao tenha sido geradas as dividas
-- Pode ser que precisem de ajustes financeiros (analisar)
-- Pode ser que tenham problemas de turmas
select * 
from LY_PRE_MATRICULA pm
where ano = 2017
and SEMESTRE = 1
and not exists (select top 1 1 from ly_matricula 
			where aluno = pm.aluno
			and ano = pm.ano
			and SEMESTRE = pm.SEMESTRE)
and exists (select top 1 1 from VW_COBRANCA 
			where aluno = pm.aluno
			and valor = 0)
and not exists (select top 1 1 from VW_COBRANCA 
			where aluno = pm.aluno
			and valor <> 0)





--## Problemas em dividas que não tem item gerado.
select m.aluno,
m.disciplina,
m.turma,
m.lanc_deb,
ld.valor  
from LY_PRE_MATRICULA m
join LY_LANC_DEBITO ld
	on m.LANC_DEB = ld.LANC_DEB
where m.ano = 2017
and m.SEMESTRE = 1
and not exists (select top 1 1 from LY_ITEM_LANC
				where LANC_DEB = ld.LANC_DEB)
order by m.aluno
				 



--## Requerimentos
	--> Validar serviços sem andamento
select * 
from LY_SOLICITACAO_SERV ss
join LY_ITENS_SOLICIT_SERV iss
	on ss.SOLICITACAO = iss.SOLICITACAO
where 1 = 1
and exists (select top 1 1 from LY_FLUXO_DE_ANDAMENTO			
			where SERVICO = iss.SERVICO)	
and not exists (select top 1 1 from LY_ANDAMENTO
				 where SERVICO = iss.SERVICO
				 and iss.SOLICITACAO = iss.SOLICITACAO
				 and iss.ITEM_SOLICITACAO = iss.ITEM_SOLICITACAO)


--## Validação se tem servicos sem prox passo do andamento
--select s.servico, s.qnt, sp.qnt_prox
--from
--(
--select servico, count(prox_passo) as qnt_prox from LY_FLUXO_DE_ANDAMENTO 
--where prox_passo is not null
--group by servico)  sp
--join
--(select 
--	servico, 
--	count(*) as qnt 
--from LY_FLUXO_DE_ANDAMENTO
--group by SERVICO
--having count(*) > 1
--) s
--	on sp.servico = s.servico	
--where (s.qnt-1) <> sp.qnt_prox

