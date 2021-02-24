use Lyceum
go

declare @cobranca t_numero

--##############################################################################
set @cobranca = 3807670

--##############################################################################

select 'VW_INTERFACE_CONTABILIDADE' as TIPO, * from VW_INTERFACE_CONTABILIDADE where cobranca = @cobranca

select 'VW_COBRANCA' as TIPO, * from VW_COBRANCA where cobranca = @cobranca
 
select 'LY_COBRANCA' as TIPO, * from LY_COBRANCA where cobranca = @cobranca

select 'LY_ITEM_LANC' as TIPO, * from LY_ITEM_LANC where cobranca = @cobranca ORDER BY COBRANCA, ITEMCOBRANCA

select 'LY_LANC_CREDITO' as TIPO, * FROM LY_LANC_CREDITO WHERE LANC_CRED IN (select LANC_CRED from LY_ITEM_CRED where cobranca = @cobranca)

select 'LY_ITEM_CRED' as TIPO, * from LY_ITEM_CRED where cobranca = @cobranca ORDER BY LANC_CRED, ITEMCRED

select 'LY_MOVIMENTO_TEMPORAL' as TIPO, * from LY_MOVIMENTO_TEMPORAL where id1 = @cobranca and entidade = 'ly_item_lanc' ORDER BY ID_MOVIMENTO_TEMPORAL

select 'LY_MOVIMENTO_TEMPORAL - CRED' as TIPO, * from LY_MOVIMENTO_TEMPORAL where id1 in (select distinct LANC_CRED from LY_ITEM_CRED where cobranca = @cobranca) and entidade = 'ly_item_cred' ORDER BY ID_MOVIMENTO_TEMPORAL

select 'AY_RESUMO_ATO' as TIPO, * from AY_RESUMO_ATO where cobranca = @cobranca
order by ATO_ID

SELECT  'AY_RAZAO - AY_RESUMO_ATO' as TIPO, * 
FROM AY_RAZAO R
JOIN AY_RESUMO_ATO RA
	ON R.ITEMATO_ID = RA.ITEMATO_ID
	AND R.ORC_ANO = RA.ORC_ANO
WHERE RA.COBRANCA = @cobranca

SELECT  'LY_COBRANCA_NOTA_FISCAL' as TIPO, *
FROM LY_COBRANCA_NOTA_FISCAL
WHERE COBRANCA = @cobranca


SELECT  'AY_EXPORTA_RECEBIMENTOS' as TIPO, * from AY_EXPORTA_RECEBIMENTOS
WHERE COBRANCA = @cobranca

SELECT  'AY_EXPORTA_MOV_CONTAB' as TIPO, * from AY_EXPORTA_MOV_CONTAB
WHERE COBRANCA = @cobranca

SELECT 'Data Contabil Primeiro Item da Cobrança' as TIPO, isnull(convert(varchar,dbo.fnGetDtContabil('LY_ITEM_LANC', @cobranca, 1, null, null, null),103),'-- NÃO TEM DATA CONTABIL--') as Data

SELECT 'Data Contabil Primeiro Item do Credito' as TIPO, isnull(convert(varchar,dbo.fnGetDtContabil('LY_ITEM_CRED', LANC_CRED, 1, null, null, null),103),'-- NÃO TEM DATA CONTABIL--') as Data
from LY_ITEM_CRED 
where cobranca = @cobranca ORDER BY LANC_CRED, ITEMCRED
