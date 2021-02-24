select p.[type] ,p.[name] ,c.[text] 
from sysobjects p 
join syscomments c on p.id = c.id 
where p.[type] = 'P' 
and c.[text] like '%ingresso%não%existe%'
--and p.name like 'PROC_%'
order by 2