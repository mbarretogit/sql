  
ALTER PROCEDURE dbo.Relat_ComprovanteCredito  
(  
  @p_usuario VARCHAR(20),  
  @p_maquina VARCHAR(20),  
  @p_lanc_cred NUMERIC(10,0)  
)  
AS  
-- [INÍCIO]          
BEGIN  
  
 IF (@p_usuario IS NULL OR @p_maquina IS NULL OR @p_lanc_cred IS NULL) RETURN  
  
 -- Exclui os dados remanescentes de outras execuções  
 DELETE LYREL_COMPRCREDITO  
 WHERE USUARIO = @p_usuario  
   AND MAQUINA_USER = @p_maquina  
   
 -- Declara variável que irá armazenar as cobranças obtidas  
 DECLARE @v_cobrancas TABLE(  
   COBRANCA NUMERIC(10,0) NOT NULL  
 )  
   
 -- Insere na variável criada acima as cobranças obtidas  
 -- através do lanc_cred informado  
 INSERT INTO @v_cobrancas  
 SELECT DISTINCT COBRANCA  
 FROM LY_ITEM_CRED  
 WHERE LANC_CRED = @p_lanc_cred  
 ORDER BY COBRANCA  
   
 -- Insere os dados na tabela do relatório  
 INSERT INTO LYREL_COMPRCREDITO (USUARIO,  
                                 MAQUINA_USER,  
                                 --Tipo Registro:  
                                 -- = 1 (ITENS POSITIVOS) Valor >= 0  
                                 -- = 2 (ITENS NEGATIVOS) Valor < 0  
                                 -- = 3 (ITENS PAGOS) Valor < 0 e TipoDesconto = NULL  
                                 TIPO_REGISTRO,  
                                 RESP,  
                                 COBRANCA,  
                                 ITEM_LANCADO,  
                                 DESC_ITEM,  
                                 BOLETO,  
                                 VALOR,  
                                 ANO,  
                                 MES)  
 -- Obtem o valor dos itens de débitos  
 SELECT @p_usuario,  
        @p_maquina,  
        CASE WHEN Il.VALOR >= 0 THEN '1'  
             WHEN Il.VALOR < 0 THEN '2' END AS TIPO_REGISTRO,  
        c.RESP,  
     c.COBRANCA,  
     il.LANC_DEB AS ITEM_LANCADO,  
     il.DESCRICAO,  
     il.BOLETO,  
     Il.VALOR,  
     c.ANO,  
     c.MES  
 FROM LY_ITEM_LANC il INNER JOIN  
   LY_COBRANCA c ON il.COBRANCA = c.COBRANCA  
 WHERE EXISTS (SELECT 1 FROM @v_cobrancas v WHERE v.COBRANCA = c.COBRANCA)  
 UNION  
 -- Obtem o valor dos itens de créditos  
 SELECT @p_usuario,  
        @p_maquina,  
        CASE WHEN ic.VALOR >= 0 THEN '1'  
             WHEN ic.VALOR < 0 AND ic.TIPODESCONTO IS NOT NULL THEN '2'  
             WHEN ic.VALOR < 0 AND ic.TIPODESCONTO IS NULL THEN '3' END AS TIPO_REGISTRO,  
        c.RESP,  
     c.COBRANCA,  
     ic.LANC_CRED AS ITEM_LANCADO,  
     ic.DESCRICAO,  
     lc.BOLETO,  
     ic.VALOR,  
     c.ANO,  
     c.MES  
 FROM LY_ITEM_CRED ic INNER JOIN  
   LY_LANC_CREDITO lc ON ic.LANC_CRED = lc.LANC_CRED INNER JOIN  
   LY_COBRANCA c ON ic.COBRANCA = c.COBRANCA  
 WHERE ic.LANC_CRED NOT IN (SELECT vlcr.LANC_CRED  
          FROM VW_LANC_CREDITO_REMOVIDO vlcr  
          WHERE vlcr.RESP = lc.RESP)  
   AND ic.LANC_CRED = @p_lanc_cred  
   AND EXISTS (SELECT 1 FROM @v_cobrancas v WHERE v.COBRANCA = ic.COBRANCA)  
 ORDER BY c.COBRANCA, ITEM_LANCADO  
   
 SELECT DISTINCT rf.RESP,  
                 cob.ALUNO,  
                 ic.LANC_CRED,  
                 lc.DT_CREDITO,  
                 lc.TIPO_PAGAMENTO,  
                 rf.TITULAR,  
                 al.NOME_COMPL,  
                 cur.FACULDADE,  
                 fac.NOME_COMP,  
                 cur.CURSO,  
                 cur.NOME,  
                 al.SERIE,  
                 al.TURNO,  
                 lrcc.MAQUINA_USER,  
                 lrcc.USUARIO,  
                 bol.NUMERO_RPS,  
                 bol.DATA_ENVIO_RPS,
                 lc.TIPO_CRED,
                 lc.DESCRICAO  
 FROM LY_COBRANCA cob INNER JOIN  
      LY_ALUNO al ON cob.ALUNO = al.ALUNO INNER JOIN  
      LY_RESP_FINAN rf ON cob.RESP = rf.RESP INNER JOIN  
      LY_ITEM_CRED ic ON cob.COBRANCA = ic.COBRANCA LEFT OUTER JOIN  
      LYREL_COMPRCREDITO lrcc ON cob.COBRANCA = lrcc.COBRANCA LEFT OUTER JOIN  
      LY_BOLETO bol ON lrcc.BOLETO = bol.BOLETO INNER JOIN  
      LY_CURSO cur ON al.CURSO = cur.CURSO INNER JOIN  
      LY_FACULDADE fac ON cur.FACULDADE = fac.FACULDADE INNER JOIN  
      LY_LANC_CREDITO lc ON ic.LANC_CRED = lc.LANC_CRED  
 WHERE ic.LANC_CRED = @p_lanc_cred  
 ORDER BY rf.RESP,  
          ic.LANC_CRED  
  
END          
-- [FIM]  