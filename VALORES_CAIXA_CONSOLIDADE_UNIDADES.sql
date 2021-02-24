use lyceum

select unidade_fisica UNIDADE,nome_unidade_fisica NOME,tipo_pagamento TIPO_PAGAMENTO,tipo_credito TIPO_CREDITO,
convert(varchar,data_geracao_credito,103) DATA_BAIXA, convert(varchar,data_credito,103) DATA_RECEBIMENTO,sum(valor_pago) VALOR_RECEBIDO
from vw_fluxo_caixa_rel 

where TIPO_CREDITO = 'BANCO'--usuario = '04901153579' and 
--data_geracao_credito = '2016-06-01' --and unidade_fisica='04'
--year(data_credito)=2015
group by unidade_fisica,nome_unidade_fisica,tipo_pagamento,tipo_credito,data_geracao_credito,data_credito

order by unidade_fisica,nome_unidade_fisica,tipo_pagamento,data_geracao_credito,data_credito,tipo_credito


SELECT ic.ITEM_ESTORNADO AS 'ITEM ESTORNADO?',vw.*FROM vw_fluxo_caixa_rel vw
JOIN ly_item_cred ic ON ic.LANC_CRED = vw.LANC_CRED

SELECT * FROM VW_FLUXO_CAIXA_REL vfcr WHERE vfcr.ALUNO = '160520025'
SELECT * FROM LY_LANC_CREDITO WHERE LANC_CRED = '22101'