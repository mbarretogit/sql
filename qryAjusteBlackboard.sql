delete
from LYCEUMINTEGRACAO..FTC_CLASSROOM_BASE_EMAILS
where pessoa = '181990'


update be 
set be.nome = replace(be.nome, '�', ' '), be.username = replace(be.username, '�', ''), be.email =  replace(be.email, '�', '')
from LYCEUMINTEGRACAO..FTC_CLASSROOM_BASE_EMAILS be
where not exists (select top 1 1 from LYCEUMINTEGRACAO..FTC_CLASSROOM_BASE_EMAILS be2 where be2.email = replace(be.email, '�', ''))
	and (be.nome like '%�%' or be.username like '�%'  or be.email like '�%')