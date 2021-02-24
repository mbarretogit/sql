use lyceum
go

Update p     
Set SENHA_TAC = DBO.CRYPT(CPF)    
--select aluno, dbo.decrypt(senha_tac) as senha, p.pessoa, p.cpf, p.DT_NASC
from ly_pessoa p
join ly_aluno a
on p.pessoa = a.pessoa
where 1 =1 
and isnull(p.cpf,'')  <> ''
and cpf			<> '00000000000'
go

Update p     
Set SENHA_TAC = DBO.CRYPT(right('00'+convert(varchar,day(dt_nasc)),2) +right('00'+convert(varchar,month(dt_nasc)),2)+convert(varchar,year(dt_nasc)))    
--select aluno, dbo.decrypt(senha_tac) as senha, p.pessoa, p.cpf, p.DT_NASC
from ly_pessoa p
join ly_aluno a
on p.pessoa = a.pessoa
where 1 =1 
and (isnull(p.cpf,'')  = '' or cpf	= '00000000000')
and p.DT_NASC	is not null
go