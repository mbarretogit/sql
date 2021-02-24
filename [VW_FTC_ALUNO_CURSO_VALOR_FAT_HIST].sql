  
CREATE VIEW [dbo].[VW_FTC_ALUNO_CURSO_VALOR_FAT_HIST]  
AS  
 select   
  
ma.ano ano,ma.semestre periodo,ma.aluno aluno,al.turno turno,al.curso curso,cu.nome nome,  
sum(la.valor) - sum(isnull(de.valor,0)) as valor  
  
from ly_histmatricula ma  
  
left join ly_lanc_debito la  
on la.lanc_deb = ma.lanc_deb  
  
left join ly_desconto_debito de  
on de.lanc_deb = la.lanc_deb  
  
left join ly_aluno al  
on al.aluno = ma.aluno  
  
left join ly_curso cu  
on cu.curso = al.curso  
  
group by ma.ano,ma.semestre,ma.aluno,al.turno,al.curso,cu.nome  
  
  