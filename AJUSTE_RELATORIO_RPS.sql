select   
 convert(varchar,c.COBRANCA) as COBRANCA,    
 ISNULL(C.ESTORNO,'N') AS COBRANCA_ESTORNADA,    
 isnull((select top 1 ld.descricao from LY_LANC_DEBITO ld join ly_item_lanc il  on ld.LANC_DEB = il.LANC_DEB where COBRANCA = c.COBRANCA),'') as DESCRICAO,    
 c.ALUNO,    
 a.nome_compl as ALUNO_NOME,    
 isnull(c.RESP,'') as RESP,    
 isnull(rf1.TITULAR,'') AS RESP_NOME,    
 isnull(convert(varchar,isnull(rf1.CPF_TITULAR,rf1.CGC_TITULAR)),'') as RESP_CPF_CGC,    
 isnull(rf1.E_MAIL,'') as RESP_EMAIL,    
 convert(varchar,c.ANO) as ANO,    
 convert(varchar,c.MES) AS MES,    
 isnull(c.CURSO,'') as CODIGO_CURSO,    
 convert(varchar,c.DATA_DE_GERACAO,103) as COBRANCA_DATA_GERACAO,    
 convert(varchar,c.DATA_DE_VENCIMENTO,103) as COBRANCA_DATA_VENCIMENTO,    
 --isnull(convert(varchar,c.DATA_DE_VENCIMENTO_ORIG,103),'') as COBRANCA_DATA_VENCIMENTO_ORIG,    
 isnull(convert(varchar,cnf.NUMERO_RPS),'') as RPS_NUMERO,    
 isnull(convert(varchar,cnf.DATA_EMISSAO_RPS,103),'') as RPS_DATA_EMISSAO,    
 isnull(convert(varchar,cnf.DATA_ENVIO_RPS,103),'') as RPS_DATA_ENVIO,    
 --SUM(isnull(convert(varchar,cnf.VALOR_SERVICO_RPS),'')) as  RPS_VALOR_SERVICO, 
 SUM(cnf.VALOR_SERVICO_RPS),
 --SUM(isnull(convert(varchar,(select SUM(valor) from LY_ITEM_LANC where COBRANCA = c.COBRANCA)),'')) as COBRANCA_VALOR,    
 isnull(convert(varchar,cnf.NUMERO_NFE),'') as  NFE_NUMERO,    
 isnull(convert(varchar,cnf.DATA_EMISSAO_NFE,103),'') as NFE_DATA_EMISSAO,    
 isnull(convert(varchar,cnf.COD_VERIFICACAO),'') as NFE_CODIGO_VERIFICACAO,    
 isnull(convert(varchar,cnf.ALIQUOTA),'') as  RPS_ALIQUOTA,    
 isnull(convert(varchar,cnf.CODIGO_SERVICO),'') as RPS_CODIGO_SERVICO,    
 --## precisa ajustar link para as unidades FTC    
 --(case     
 -- when cnf.NUMERO_NFE is not null then ('https://nfe.prefeitura.ba.gov.br/notaprint.aspx?inscricao=32909420&nf='+convert(varchar,cnf.NUMERO_NFE)+'&verificacao='+convert(varchar,cnf.COD_VERIFICACAO))     
 -- else ''    
 --end)     
 '' AS NFE_LINK,  
 C.UNID_FISICA UNIDADE,
isnull(convert(varchar,ra.DATACONTAB,103),'') as DATA_CONTABIL,
ra.EVENTO_NUM,
ra.EVENTO_DESCR
from LY_COBRANCA_NOTA_FISCAL cnf    
inner join LY_COBRANCA c    
 on cnf.COBRANCA = c.COBRANCA    
inner join LY_RESP_FINAN rf1    
 on c.RESP = rf1.RESP    
inner join ly_aluno a    
 on c.aluno = a.aluno     
inner join ay_resumo_ato ra  
on ra.cobranca = c.cobranca  
where cnf.NUMERO_RPS is not null  
and ra.EVENTO_NUM in ('1','1001','4','1004')  
--and c.ano = 2017
--and c.mes = 1 
--and ra.UNIDADE_FISICA = 'FCS'
--and cnf.DATA_EMISSAO_RPS >= '2017-01-01'
--and cnf.DATA_EMISSAO_RPS <= '2017-01-31'
and ra.DATACONTAB >= '2017-01-01' 
and ra.DATACONTAB <= '2017-01-31'

group by 
c.COBRANCA,
c.ESTORNO,
c.ALUNO,
a.NOME_COMPL,
c.RESP,
rf1.TITULAR,
 isnull(convert(varchar,isnull(rf1.CPF_TITULAR,rf1.CGC_TITULAR)),'') ,
 rf1.E_MAIL,
 c.ANO,
 c.MES,
 c.CURSO,
 c.DATA_DE_GERACAO,
 c.DATA_DE_VENCIMENTO,
 cnf.NUMERO_RPS,
 cnf.DATA_EMISSAO_RPS,
 cnf.DATA_ENVIO_RPS,
 cnf.NUMERO_NFE,
 cnf.DATA_EMISSAO_NFE,
 cnf.COD_VERIFICACAO,
 cnf.ALIQUOTA,
 cnf.CODIGO_SERVICO,
 C.UNID_FISICA,
 ra.DATACONTAB,
 ra.EVENTO_NUM,
ra.EVENTO_DESCR


-- convert(varchar,c.COBRANCA),
-- C.ESTORNO,'N',
-- isnull((select top 1 ld.descricao from LY_LANC_DEBITO ld join ly_item_lanc il  on ld.LANC_DEB = il.LANC_DEB where COBRANCA = c.COBRANCA),''),
-- c.ALUNO,    
-- a.nome_compl,
-- isnull(c.RESP,''),
-- isnull(rf1.TITULAR,'') ,
-- isnull(convert(varchar,isnull(rf1.CPF_TITULAR,rf1.CGC_TITULAR)),'') ,
-- isnull(rf1.E_MAIL,'') ,
-- convert(varchar,c.ANO),
-- convert(varchar,c.MES),
-- isnull(c.CURSO,'') ,
-- convert(varchar,c.DATA_DE_GERACAO,103) ,
-- convert(varchar,c.DATA_DE_VENCIMENTO,103),
-- isnull(convert(varchar,c.DATA_DE_VENCIMENTO_ORIG,103),''),
-- isnull(convert(varchar,cnf.NUMERO_RPS),'') ,
-- isnull(convert(varchar,cnf.DATA_EMISSAO_RPS,103),'') ,
-- isnull(convert(varchar,cnf.DATA_ENVIO_RPS,103),'') ,
-- --SUM(isnull(convert(varchar,cnf.VALOR_SERVICO_RPS),'')) as  RPS_VALOR_SERVICO, 
-- SUM(cnf.VALOR_SERVICO_RPS),
-- --SUM(isnull(convert(varchar,(select SUM(valor) from LY_ITEM_LANC where COBRANCA = c.COBRANCA)),'')) as COBRANCA_VALOR,    
-- isnull(convert(varchar,cnf.NUMERO_NFE),''),
-- isnull(convert(varchar,cnf.DATA_EMISSAO_NFE,103),'') ,
-- isnull(convert(varchar,cnf.COD_VERIFICACAO),'') ,
-- isnull(convert(varchar,cnf.ALIQUOTA),'') ,
-- isnull(convert(varchar,cnf.CODIGO_SERVICO),''),
-- --## precisa ajustar link para as unidades FTC    
--  C.UNID_FISICA,
--isnull(convert(varchar,ra.DATACONTAB,103),''),
--ra.EVENTO_NUM,
--ra.EVENTO_DESCR
ORDER BY cnf.DATA_EMISSAO_RPS, C.COBRANCA    