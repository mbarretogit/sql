select  --DISTINCT 
		bl.RESP,
		co.ALUNO,
		em.NOSSO_NUMERO,
		bl.BOLETO,
		co.DATA_DE_VENCIMENTO,
		co.COBRANCA,
		em.AGENCIA,
		em.CONTA_BANCO

from ly_erro_movimento em

join ly_boleto bl

on em.nosso_numero = bl.nosso_numero

and em.banco = bl.banco

and em.AGENCIA = bl.AGENCIA

and em.CONTA_BANCO = bl.CONTA_BANCO

and em.convenio =  bl.convenio

join VW_cobranca co

on bl.resp = co.resp  

left join (select distinct boleto,cobranca from LY_ITEM_LANC) il

on co.cobranca = il.cobranca

left join (select distinct boleto,cobranca from LY_ITEM_LANC) il2

on em.boleto = il2.boleto

where --em.data_pagto = '2017-04-25'
em.NOSSO_NUMERO = '0503060694'

and co.valor > 0

and em.valor_pago >= co.valor

--and e_lyceum = 'S'

and not exists(select top 1 1 from  ly_erro_mov_pagamento where erro_mov = em.erro_mov)

--and em.nome_arq like '%20170210COB03P0089001324391%'

order by 3,2