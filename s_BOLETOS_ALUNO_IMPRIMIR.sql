  
--## 6.2.1-HF14  
  
ALTER PROCEDURE s_BOLETOS_ALUNO_IMPRIMIR(  
 @P_ALUNO     [T_CODIGO],   
        @P_SUBSTITUI VARCHAR(1) output)   
AS   
BEGIN  
-- [INÍCIO]            
    --campos necessários no retorno: codBoleto, dataVencimento, valor,    
    --tipoCobranca (de acordo com num_cobranca 0 = Diversos, 1 = Mensalidade, 2 = Serviço, 3 = Acordo, 4 = Outros, 5 = Cheque),  
    --codBanco, agencia, conta e carteira   
set @p_substitui = 'S'  --## habilitado para usar o codigo abaixo 24/03/2016  
  
  
--## INICIO - Raul - 24/03/2016 - 0001 - Listar os boletos no portal (vencidos, a vencer, não cancelados, on line, nao removidos, nao FIES)    
SELECT DISTINCT   
 B.BOLETO codBoleto  
, C.DATA_DE_VENCIMENTO AS dataVencimento  
, SUM(L.VALOR) AS valor  
, CASE(  
   SELECT COUNT(DISTINCT NUM_COBRANCA)   
   FROM LY_ITEM_LANC IL    
   JOIN LY_COBRANCA C2   
    ON IL.COBRANCA = C2.COBRANCA  
   WHERE IL.BOLETO = B.BOLETO  
  ) WHEN 1  THEN C.NUM_COBRANCA  
 ELSE 0  
 END tipoCobranca
, B.BANCO as codBanco
, B.AGENCIA as agencia
, B.CONTA_BANCO as conta
, B.CARTEIRA as carteira    
FROM  LY_COBRANCA C   
INNER JOIN LY_ALUNO A   
 ON (C.ALUNO = A.ALUNO)  
INNER JOIN LY_ITEM_LANC L   
 ON (C.COBRANCA = L.COBRANCA)  
INNER JOIN LY_BOLETO B   
 ON (L.BOLETO = B.BOLETO)  
inner join ly_opcoes_boleto ob  
 on b.banco = ob.banco  
 and b.agencia = ob.agencia  
 and b.conta_banco = ob.conta_banco  
WHERE L.BOLETO  IS NOT NULL -- tem que ter boleto   
AND B.NOSSO_NUMERO <> 0  -- tem nosso numero gerado   
AND B.REMOVIDO  <> 'S'  -- boletos não removidos  
AND B.CANCEL_BANCO <> 'S'  -- boletos não cancelados  
AND B.ON_LINE  =  'S'  -- só boletos marcados para liberar no on line  
AND C.RESP   <> 'FIES' -- não TRAZER BOLETO PARA O RESPONSÁVEL FIES  
and isnull(c.COBR_JUDICIAL,'N') = 'N' -- não trazer boletos de cobranças marcadas como cobranca judicial - RAUL -24/11/2016  
--## 18/10/2016 - RAUL - Incluido tratamento para validar se a conta esta como registrada e validar o enviado e aceito  
AND B.ENVIADO  =  (case ob.ARQUIVO_COBRANCA  
       When 'Registrada' Then 'S'  
       else 'N'  
      end) -- 'S' -- Indica que o boleto foi enviado para registro  
--## 18/10/2016 - RAUL - Incluido tratamento para validar se a conta esta como registrada e validar o enviado e aceito  
AND B.ACEITO  =  (case ob.ARQUIVO_COBRANCA  
       When 'Registrada' Then 'S'  
       else 'N'  
      end) -- 'S' -- Indica que o boleto foi aceito pelo banco - o Boleto só é valido se aceito pelo banco  
AND C.ALUNO   =  @p_aluno  
AND NOT EXISTS   
 (  
  SELECT TOP 1 1   
  FROM LY_ITEM_CRED D   
  INNER JOIN LY_ITEM_LANC IL   
   ON D.COBRANCA = IL.COBRANCA   
  WHERE IL.BOLETO = B.BOLETO   
  AND D.BOLETO IS NULL  
 )  
AND NOT EXISTS   
 (  
  SELECT TOP 1 1   
  FROM LY_ITEM_LANC D   
  WHERE D.COBRANCA = C.COBRANCA   
  AND D.BOLETO IS NULL  
 )  
AND NOT EXISTS   
 (  
  SELECT DISTINCT IC.BOLETO   
  FROM  LY_COBRANCA COB  
  INNER JOIN LY_ALUNO_MATRICULA A   
   ON (A.ALUNO = COB.ALUNO AND A.ANO = COB.ANO)  
  INNER JOIN LY_ITEM_LANC IC   
   ON (COB.COBRANCA = IC.COBRANCA)  
  WHERE COB.ALUNO = @p_aluno  
  AND IC.BOLETO  = L.BOLETO   
  AND BOLETO_CUMULATIVO = 'S'   
  AND NOT EXISTS   
  (  
   SELECT TOP 1 1   
   FROM LY_ITEM_LANC IL   
   WHERE IL.COBRANCA = COB.COBRANCA   
   AND (PARCELA IS NOT NULL AND PARCELA <> 1)   
  )   
  AND EXISTS   
  (  
   SELECT TOP 1 1   
   FROM LY_ITEM_LANC IL2  
   WHERE IL2.LANC_DEB = A.LANC_DEB   
   AND IL2.COBRANCA = COB.COBRANCA   
   AND (PARCELA IS NOT NULL AND PARCELA = 1)   
   AND NOT EXISTS   
   (  
    SELECT TOP 1 1   
    FROM LY_ITEM_LANC IL3   
    WHERE IL3.COBRANCA = COB.COBRANCA   
    AND (PARCELA IS NOT NULL AND PARCELA <> 1)   
   )   
  )   
 )  
GROUP BY B.BOLETO, C.DATA_DE_VENCIMENTO, C.NUM_COBRANCA, B.BANCO, B.AGENCIA , B.CONTA_BANCO , B.CARTEIRA
ORDER BY C.DATA_DE_VENCIMENTO  
--## FIM - Raul - 24/03/2016 - 0001 - Listar os boletos no portal (vencidos, a vencer, não cancelados, on line, nao removidos, nao FIES)  
  
RETURN        
-- [FIM]  
END  
