-- 1- Remo��o de Boleto e Desfaz Faturamento
exec PROC_REMOVE_BOLETO
-- 2- Remo��o de Cobran�as
exec PROC_REMOVE_COBRANCA_LOTE
-- 3- Gera��o de Calc/Recal de Matr�culas
exec PROC_GERACALCULO
-- 4- Gera��o de Cobran�as e Itens
exec PROC_GERA_COBRANCA_ALUNO
-- 5- Gera��o de Boletos e Faturamento
exec PROC_GERA_BOLETO
