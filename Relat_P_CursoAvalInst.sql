USE LYCEUM
GO

CREATE PROCEDURE [dbo].[Relat_P_CursoAvalInst] (
	@p_unid_fisica VARCHAR(20)
	)  
  
AS  
BEGIN  
  
SELECT '' AS CURSO,'TODOS OS CURSOS' AS NOME
UNION
select c.curso,c.nome
from ly_curso c
inner join LY_UNIDADE_FISICA uf on uf.fl_field_01 = c.faculdade
where
uf.unidade_fis=@p_unid_fisica
and c.ativo = 'S'
order by NOME
  
END;  