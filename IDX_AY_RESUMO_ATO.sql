/*
Detalhes de Índice Ausentes de qry_Relat_Faturamento_novo.sql - 10.20.0.65.LYCEUM_TECHNE (sa (62))
O Processador de Consultas estima que a implementação do índice a seguir pode melhorar o custo da consulta em 11.33%.
*/


USE [LYCEUM_TECHNE]
GO
CREATE NONCLUSTERED INDEX [AY_RESUMO_ATO_COBRANCA_CODIGO_LANC_IDX, LYCEUM_TECHNE]
ON [dbo].[AY_RESUMO_ATO] ([COBRANCA])
INCLUDE ([CODIGO_LANC])
GO

DROP INDEX AY_RESUMO_ATO.[AY_RESUMO_ATO_COBRANCA_CODIGO_LANC_IDX, LYCEUM_TECHNE]

/*
Detalhes de Índice Ausentes de qry_Relat_Faturamento_novo.sql - 10.20.0.65.LYCEUM_TECHNE (sa (62))
O Processador de Consultas estima que a implementação do índice a seguir pode melhorar o custo da consulta em 95.8999%.
*/


USE [LYCEUM_TECHNE]
GO
CREATE NONCLUSTERED INDEX [AY_RESUMO_ATO_CODIGO_LANC_ATO_ID_COBRANCA_IDX, LYCEUM_TECHNE]
ON [dbo].[AY_RESUMO_ATO] ([CODIGO_LANC])
INCLUDE ([ATO_ID],[COBRANCA])
GO

DROP INDEX AY_RESUMO_ATO.[AY_RESUMO_ATO_CODIGO_LANC_ATO_ID_COBRANCA_IDX, LYCEUM_TECHNE]

/*
Detalhes de Índice Ausentes de qry_Relat_Faturamento_novo.sql - 10.20.0.65.LYCEUM_TECHNE (sa (62)) Executando...
O Processador de Consultas estima que a implementação do índice a seguir pode melhorar o custo da consulta em 27.7074%.
*/


USE [LYCEUM_TECHNE]
GO
CREATE NONCLUSTERED INDEX [AY_RESUMO_ATO_EVENTO_NUM_COMPOSTA_IDX, LYCEUM_TECHNE]
ON [dbo].[AY_RESUMO_ATO] ([EVENTO_NUM])
INCLUDE ([DATACONTAB],[COBRANCA],[ALUNO],[RESP],[UNIDADE],[UNIDADE_FISICA],[TIPO_CURSO],[CURSO],[COB_ESTORNADA],[ANO_REF],[MES_REF],[DT_GERACAO_COB],[DT_FATURAMENTO_COB],[DT_VENC],[DT_VENC_ORIG])
GO

DROP INDEX AY_RESUMO_ATO.[AY_RESUMO_ATO_EVENTO_NUM_COMPOSTA_IDX, LYCEUM_TECHNE]