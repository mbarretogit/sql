select 
fac.faculdade,
fac.nome_abrev,
alu.aluno,
alu.nome_compl,
pes.cpf,
alu.serie,
alu.turno,
alu.curriculo,
cur.curso,
cur.nome,
(select sum(IL.valor) from LY_LANC_DEBITO LD JOIN LY_ITEM_LANC IL ON IL.LANC_DEB = LD.LANC_DEB WHERE LD.ALUNO = alu.aluno AND ANO_REF = 2018 and PERIODO_REF = 1 and LD.CODIGO_LANC = 'MS' AND IL.NUM_BOLSA IS NULL) as Valor_Divida,
(select VALOR_MENSAL*PARCELAS FROM LY_CONTRATO_FIES_PERIODO  FI JOIN LY_CONTRATO_FIES CF ON CF.ID_CONTRATO = FI.ID_CONTRATO WHERE CF.ALUNO = alu.ALUNO AND FI.ANO = 2018 AND FI.PERIODO = 1) as Valor_Contrato_Fies,
CONVERT(DECIMAL(10,2),b.valor*100) as perc_Bolsa_Fies
from ly_aluno alu
join ly_pessoa pes
on pes.pessoa = alu.pessoa
join ly_curso cur
on cur.curso = alu.curso
join ly_faculdade fac
on fac.faculdade = cur.faculdade
join ly_bolsa b on b.aluno = alu.aluno
where 1=1 
--AND  EXISTS ( SELECT TOP 1 1 FROM  LY_CONTRATO_FIES_PERIODO FI  JOIN LY_CONTRATO_FIES CF ON CF.ID_CONTRATO = FI.ID_CONTRATO WHERE CF.ALUNO = ALU.ALUNO AND FI.ANO = 2018 AND FI.PERIODO = 1)
and b.tipo_bolsa in ('FIES_TEMP','FIES','FIESGERAL','FIES100','FIESFNDE','FIESTA') and b.anoini = 2018
--and alu.aluno = '181070375'
order by 1,9,3