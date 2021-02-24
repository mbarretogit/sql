-- 1- Remoção de Boleto e Desfaz Faturamento
exec PROC_REMOVE_BOLETO
-- 2- Remoção de Cobranças
exec PROC_REMOVE_COBRANCA_LOTE
-- 3- Geração de Calc/Recal de Matrículas
exec PROC_GERACALCULO
-- 4- Geração de Cobranças e Itens
exec PROC_GERA_COBRANCA_ALUNO
-- 5- Geração de Boletos e Faturamento
exec PROC_GERA_BOLETO
