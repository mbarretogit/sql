USE LYCEUM
GO

--CREATE NONCLUSTERED INDEX [#COBRANCA_IDX] ON [#COBRANCA] ([COBRANCA] ASC) GO
--CREATE NONCLUSTERED INDEX [#ITENS_COBRANCA_IDX] ON [#ITENS_COBRANCA] ([COBRANCA] ASC) GO
CREATE NONCLUSTERED INDEX [AY_RESUMO_ATO_COBRANCA_IDX] ON [AY_RESUMO_ATO] ([COBRANCA]) GO
