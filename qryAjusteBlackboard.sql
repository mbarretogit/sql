delete
from LYCEUMINTEGRACAO..FTC_CLASSROOM_BASE_EMAILS
where pessoa = '181990'


update be 
set be.nome = replace(be.nome, 'та', ' '), be.username = replace(be.username, 'та', ''), be.email =  replace(be.email, 'та', '')
from LYCEUMINTEGRACAO..FTC_CLASSROOM_BASE_EMAILS be
where not exists (select top 1 1 from LYCEUMINTEGRACAO..FTC_CLASSROOM_BASE_EMAILS be2 where be2.email = replace(be.email, 'та', ''))
	and (be.nome like '%та%' or be.username like 'та%'  or be.email like 'та%')