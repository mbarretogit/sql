use LYCEUM
go

select p.cpf,p.nome_compl, a.aluno as matricula, c.tipo
from LY_ALUNO a, LY_PESSOA p, LY_CURSO c
where a.PESSOA = p.PESSOA
and a.curso= c.curso
and exists (select top 1 1 from vw_matricula_e_pre_matricula where aluno = a.aluno and SIT_MATRICULA not in ('Cancelado','Trancado'))
and c.tipo in ('graduacao','pos-graduacao')
and c.faculdade = '04'
and a.SIT_ALUNO = 'Ativo'

order by 4
