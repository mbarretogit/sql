use CRMEDUCACIONAL
go


SELECT 
		IC.createdon AS DATA,
		C.cad_nome AS CONCURSO,
		IC.cad_numeroinscricao AS CRM_INSCRICAO,
		IC.cad_clientepotencialnome,
		IC.cad_cpf
FROM DY_Inscricao_Candidato IC
JOIN DY_Concurso C ON C.cad_codigo = IC.cad_concursoid
WHERE 1=1
AND cad_cpf = '920.502.635-20'

DY_Consultores


DY_Ofertas WHERE cad_nome like '%Online%'
DY_Inscricao_Candidato WHERE cad_cpf = '920.502.635-20'
DY_Concurso WHERE cad_periodoletivo = '2019.2'