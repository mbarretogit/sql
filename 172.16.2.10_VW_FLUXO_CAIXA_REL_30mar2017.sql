  
ALTER  VIEW VW_FLUXO_CAIXA_REL    
AS    
  SELECT LANC_CRED = LC.LANC_CRED,    
         ALUNO = A.ALUNO,    
         NOME_COMPLETO = UPPER(A.NOME_COMPL),    
         RESP = C.RESP,  
         NOME_RESP = UPPER(R.TITULAR),  
         CURSO = A.CURSO,    
         VALOR_PAGO = IC.VALOR * -1,  
         TIPO_PAGAMENTO = UPPER(LC.TIPO_PAGAMENTO),    
         USUARIO = UPPER(IC.USUARIO),    
         DATA_GERACAO_CREDITO = LC.DATA,    
         TIPO_CREDITO = LC.TIPO_CRED,    
         BOLETO = LC.BOLETO,    
         DATA_RECEBIMENTO = CH.DT_RECEB,    
         DATA_PREVISAO_DEPOSITO = CH.DT_PREV_DEP,    
         DATA_CREDITO  = LC.DT_CREDITO,  
         UNIDADE_FISICA = CUR.FACULDADE,   
         NOME_UNIDADE_FISICA = UND.NOME_COMP,  
         C.COBRANCA   
FROM LY_ALUNO A    
 JOIN LY_COBRANCA C ON C.ALUNO = A.ALUNO    
 JOIN LY_RESP_FINAN R ON C.RESP = R.RESP  
 JOIN LY_ITEM_CRED IC ON IC.COBRANCA = C.COBRANCA    
 JOIN LY_LANC_CREDITO LC ON LC.LANC_CRED = IC.LANC_CRED    
 JOIN LY_CURSO CUR ON CUR.CURSO = A.CURSO    
 JOIN LY_UNIDADE_ENSINO UND ON UND.UNIDADE_ENS = CUR.FACULDADE  
 LEFT JOIN LY_CHEQUES CH ON CH.BANCO = LC.BANCO    
       AND CH.AGENCIA = LC.AGENCIA    
       AND CH.CONTA_BANCO = LC.CONTA_BANCO    
       AND CH.SERIE = LC.SERIE    
       AND CH.NUMERO = LC.NUMERO    
WHERE IC.TIPODESCONTO IS NULL      
  AND IC.TIPO_ENCARGO IS NULL      
   AND LC.ID_ABERTURA IS NOT NULL  
   AND (LC.TIPO_PAGAMENTO <> 'BANCO' OR (LC.TIPO_PAGAMENTO = 'BANCO' AND LC.BANCO_DEPOSITO IS NOT NULL)) 
   AND ((0 > (SELECT SUM(VALOR) FROM LY_ITEM_CRED WHERE LANC_CRED = IC.LANC_CRED))
	or (0 = (SELECT SUM(VALOR) FROM LY_ITEM_CRED WHERE LANC_CRED = IC.LANC_CRED))
	--or (EXISTS (SELECT 1 FROM LY_ITEM_CRED WHERE LANC_CRED = IC.LANC_CRED AND VALOR < 0 AND TIPO_ENCARGO IS NULL AND TIPODESCONTO IS NULL)) 
	AND NOT EXISTS (SELECT 1 FROM VW_LANC_CREDITO_REMOVIDO WHERE LANC_CRED = IC.LANC_CRED))
GO

DELETE FROM LY_CUSTOM_CLIENTE
WHERE NOME = 'VW_FLUXO_CAIXA_REL'
AND IDENTIFICACAO_CODIGO = '0002'
GO

INSERT INTO LY_CUSTOM_CLIENTE
(NOME, IDENTIFICACAO_CODIGO, AUTOR, DATA_CRIACAO, OBJETIVO, SOLICITADO_POR, ATIVO, TIPOCOMPONENTE, TIPO, CLIENTE)
SELECT
  'VW_FLUXO_CAIXA_REL' NOME
, '0002' IDENTIFICAO_CODIGO
, 'Miguel' AUTOR
, CONVERT(VARCHAR(10),GETDATE(),121) DATA_CRIACAO
, 'Corre��o de VIEW' OBJETIVO
, 'Tesouraria' SOLICITADO_POR
, 'S' ATIVO
, 'Relat�rio' TIPOCOMPONENTE
, 'CLIENTE' TIPO
, 'FTC' CLIENTE
GO