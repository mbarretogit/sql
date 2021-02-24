USE LYCEUM
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.Relat_AdiantamentosConciliacao'))
   exec('CREATE PROCEDURE [dbo].[Relat_AdiantamentosConciliacao] AS BEGIN SET NOCOUNT OFF; END')
GO
 
ALTER PROCEDURE dbo.Relat_AdiantamentosConciliacao  
(    
 @p_unid_resp VARCHAR(20),  
 @p_unid_fisica VARCHAR(20),  
 @p_curso VARCHAR(20),  
 @p_cpfoucnpj_resp VARCHAR(19),  
 @p_nome_resp VARCHAR(50),  
 @p_data_ini DATETIME,  
 @p_data_fim DATETIME  
)    
AS    
    
-- [INÍCIO]                  
BEGIN  
  
 -- Seta a variável @p_data_fim para a data atual, caso não seja informada  
 IF @p_data_fim IS NULL  
  SET @p_data_fim = GETDATE()  
  
 /* ---------------------------------------------------  
    Busca os Saldos das Unidades  
    --------------------------------------------------- */  
      
 SELECT RA.COBRANCA,  
        RA.UNIDADE,  
     RA.EVENTO_NUM,  
     CASE WHEN RA.EVENTO_NUM IN (49) THEN RA.VALOR_SINAL ELSE -1 * RA.VALOR_SINAL END VALOR_SINAL  
 INTO #SALDO_ADIANTAMENTO  
 FROM AY_RESUMO_ATO RA  
 LEFT JOIN LY_RESP_FINAN RF ON RA.RESP = RF.RESP  
 WHERE (  
 (  
  RA.ADIANTAMENTO = 'S'  -- eh adiantametno  
  AND RA.EVENTO_NUM IN (  
   16, 1016, -- Baixa por Recebimento  
   17, 1017  -- Baixa de Encargo por Recebimento  
  )  
 )  
 OR RA.EVENTO_NUM IN (   
   23, 1023,  -- Recebimento a Maior  
   63, 1063,  -- Desconto a Maior  
   26, 1026,  -- Devolução para o Aluno  
   --27, 1027,  -- Compensação em Outra Cobrança (cobrança maior)  
   51, 1051,  -- Compensação em Outra Cobrança (pagamento a maior)  
   53, 1053,  -- Devolução Retida  
   49, 1049 -- Reconhecimento de Adiantamento de Pagamento  
 )  
 )  
 AND ( @p_unid_resp IS NULL OR (@p_unid_resp IS NOT NULL AND RA.UNIDADE = @p_unid_resp) )  
 -- Filtros talvez sejam removidos  
 AND ( @p_unid_fisica IS NULL OR (@p_unid_fisica IS NOT NULL AND RA.UNIDADE_FISICA = @p_unid_fisica) )  
 AND ( @p_curso IS NULL OR (@p_curso IS NOT NULL AND RA.CURSO = @p_curso) )  
 AND ( @p_cpfoucnpj_resp IS NULL OR ( @p_cpfoucnpj_resp IS NOT NULL AND ( RA.CPF_RESP = @p_cpfoucnpj_resp OR  
                                                                          RA.CNPJ_RESP = @p_cpfoucnpj_resp )) )  
 AND ( @p_nome_resp IS NULL OR (@p_nome_resp IS NOT NULL AND rf.TITULAR LIKE '%' + @p_nome_resp + '%') )  
 AND ( @p_data_ini IS NULL OR (@p_data_ini IS NOT NULL AND RA.DATACONTAB < @p_data_ini) )  
      
 -- Remove cobranças que não tem adiantamento real  
 DELETE FROM #SALDO_ADIANTAMENTO  
 WHERE COBRANCA NOT IN (  
  SELECT DISTINCT COBRANCA  
  FROM #SALDO_ADIANTAMENTO  
  WHERE EVENTO_NUM IN (16, 1016, 17, 1017, 23, 1023, 63, 1063)  
 )  
   
 SELECT UNIDADE,  
     SUM(VALOR_SINAL) AS SALDO_ANTERIOR  
     --SUM(CASE WHEN VALOR_SINAL >= 0 THEN VALOR_SINAL ELSE 0 END) AS SALDO_ANTERIOR_CREDITO,  
     --SUM(CASE WHEN VALOR_SINAL < 0 THEN ABS(VALOR_SINAL) ELSE 0 END) AS SALDO_ANTERIOR_DEBITO  
 INTO #SALDO_ADIANTAMENTO_AGRUPADO  
 FROM #SALDO_ADIANTAMENTO  
 GROUP BY UNIDADE  
   
 /* *********************************************************************************************************************** */  
 /* *********************************************************************************************************************** */  
   
 /* ---------------------------------------------------  
    Obtém a lista de cobranças que possuem adiantamento  
    --------------------------------------------------- */  
  
 SELECT RA.COBRANCA,  
 --    ROW_NUMBER() OVER (ORDER BY RA.COBRANCA, CASE WHEN RA.EVENTO_NUM IN (16, 17, 23) THEN 1 ELSE 2 END, RA.ITEMATO_ID) ORDEM_GERAL,  
     ROW_NUMBER() OVER (PARTITION BY RA.COBRANCA ORDER BY ra.datacontab, case when ra.EVENTO_NUM IN (16, 17, 23, 63) then 1 else 2 end, ra.itemato_id) ORDEM_COBRANCA,  
     RA.EVENTO_NUM,  
     RA.EVENTO_DESCR + CASE WHEN RA.EVENTO_NUM IN (16, 1016, 17, 1017) THEN ' (Adiantamento)' ELSE '' END AS EVENTO_DESCR,  
     RA.DATACONTAB,  
     CASE WHEN RA.EVENTO_NUM IN (1049) THEN RA.VALOR_SINAL ELSE -1 * RA.VALOR_SINAL END VALOR_SINAL,  -- ## Acrescentado a pedido de José Bispo - Contabilidade HD12502 ## -- 
	 ---1 * RA.VALOR_SINAL AS VALOR_SINAL,
     CONVERT(NUMERIC(16,2), 0) SALDO_COBRANCA,  
 --    CONVERT(NUMERIC(16,2), 0) SALDO_GERAL,  
     RA.RESP,  
     RA.ALUNO,  
     RA.UNIDADE,  
     RA.UNIDADE_FISICA,  
     RA.ITEMATO_ID,  
     CASE WHEN RA.EVENTO_NUM IN (49,1049) THEN 'Automático' ELSE ic.USUARIO END AS USER_LYCEUM  
 INTO #HISTORICO_ADIANTAMENTO  
 FROM AY_RESUMO_ATO RA    
 LEFT JOIN LY_ITEM_CRED ic ON ( RA.LANC_CRED = IC.LANC_CRED AND RA.ITEMCRED = IC.ITEMCRED )  
 LEFT JOIN LY_RESP_FINAN RF ON RA.RESP = RF.RESP  
 WHERE (  
 (  
  RA.ADIANTAMENTO = 'S'  -- eh adiantametno  
  AND RA.EVENTO_NUM IN (  
   16, 1016, -- Baixa por Recebimento  
   17, 1017,  -- Baixa de Encargo por Recebimento  
   18, 1018 -- Baixa por Desconto  -- ## Acrescentado a pedido de José Bispo - Contabilidade HD12502 ## -- 
  )  
 )  
 OR RA.EVENTO_NUM IN (   
   23, 1023,  -- Recebimento a Maior  
   63, 1063,  -- Desconto a Maior  
   26, 1026,  -- Devolução para o Aluno  
   --27, 1027,  -- Compensação em Outra Cobrança (cobrança maior)  
   51, 1051,  -- Compensação em Outra Cobrança (pagamento a maior)  
   53, 1053,  -- Devolução Retida  
   49, 1049 -- Reconhecimento de Adiantamento de Pagamento  
 )  
 )  
 AND ( @p_unid_resp IS NULL OR (@p_unid_resp IS NOT NULL AND RA.UNIDADE = @p_unid_resp) )  
 -- Filtros talvez sejam removidos  
 AND ( @p_unid_fisica IS NULL OR (@p_unid_fisica IS NOT NULL AND RA.UNIDADE_FISICA = @p_unid_fisica) )  
 AND ( @p_curso IS NULL OR (@p_curso IS NOT NULL AND RA.CURSO = @p_curso) )  
 AND ( @p_cpfoucnpj_resp IS NULL OR ( @p_cpfoucnpj_resp IS NOT NULL AND ( RA.CPF_RESP = @p_cpfoucnpj_resp OR  
                                                                          RA.CNPJ_RESP = @p_cpfoucnpj_resp )) )  
 AND ( @p_nome_resp IS NULL OR (@p_nome_resp IS NOT NULL AND rf.TITULAR LIKE '%' + @p_nome_resp + '%') )  
 AND ( @p_data_ini IS NULL OR (@p_data_ini IS NOT NULL AND RA.DATACONTAB >= @p_data_ini) )  
    AND ( @p_data_fim IS NULL OR (@p_data_fim IS NOT NULL AND RA.DATACONTAB <= @p_data_fim) )  
 ORDER BY ra.COBRANCA,  
    ra.DATACONTAB,  
    CASE WHEN ra.EVENTO_NUM IN (16, 17, 23, 63) THEN 1 ELSE 2 END,  
    ra.ITEMATO_ID  
      
 /* ---------------------------------------------------  
    Ajustas as cobranças obtidas na consulta anterior  
    --------------------------------------------------- */  
   
 /*  
 -- CASO NECESSÁRIO APAGAR O EVENTO 17, APAGAR ASSIM OS RECONHECIMENTOS DE EVENTO 17  
  
 SELECT X.ITEMATO_ID ITEMATO_ID_REC, I.ATO_ID, I.ITEMATO_ID, I.EVENTO_NUM  
 INTO #ORIGEM_RECONHECIMENTOS  
 FROM AY_ATOADM A  
 JOIN AY_ITEMATO I ON (A.ATO_ID = I.ATO_ID)  
 JOIN (  
  
  SELECT I.ITEMATO_ID, C1.CONTEUDO TIPODOC, C2.CONTEUDO UG, C3.CONTEUDO ORC_ANO, C4.CONTEUDO ATO_NUM  
  FROM AY_ITEMATO I  
  JOIN AY_ITEMATOCC C1 ON (I.ITEMATO_ID = C1.ITEMATO_ID AND C1.ITEMCC_ITEMCC = 'TipodocOrig')  
  JOIN AY_ITEMATOCC C2 ON (I.ITEMATO_ID = C2.ITEMATO_ID AND C2.ITEMCC_ITEMCC = 'UgOrig')  
  JOIN AY_ITEMATOCC C3 ON (I.ITEMATO_ID = C3.ITEMATO_ID AND C3.ITEMCC_ITEMCC = 'OrcAnoOrig')  
  JOIN AY_ITEMATOCC C4 ON (I.ITEMATO_ID = C4.ITEMATO_ID AND C4.ITEMCC_ITEMCC = 'NumAtoOrig')  
  WHERE I.EVENTO_NUM = 49  
    
 ) X ON (A.TIPODOC = X.TIPODOC AND A.UG = X.UG AND A.ORC_ANO = X.ORC_ANO AND A.NUM = X.ATO_NUM)  
 WHERE I.EVENTO_NUM = 17  
  
 DELETE FROM #HISTORICO_ADIANTAMENTO  
 WHERE ITEMATO_ID IN (SELECT ITEMATO_ID_REC FROM #ORIGEM_RECONHECIMENTOS)  
 */  
   
 -- Remove cobranças que não tem adiantamento real (ou dentro do filtro)  
 DELETE FROM #HISTORICO_ADIANTAMENTO  
 WHERE COBRANCA NOT IN (  
  SELECT DISTINCT COBRANCA  
  FROM #HISTORICO_ADIANTAMENTO  
  WHERE EVENTO_NUM IN (16, 1016, 17, 1017, 23, 1023, 63, 1063)  
 )  
   
 -- TODO: APAGAR RECONHECIMENTOS DE EVENTOS QUE TEM ESTORNO **  
   
 -- Atualiza saldo para as que sobraram  
 /*  
 UPDATE #HISTORICO_ADIANTAMENTO  
 SET SALDO_COBRANCA = (SELECT SUM(X.VALOR_SINAL) FROM #HISTORICO_ADIANTAMENTO X WHERE X.COBRANCA = #HISTORICO_ADIANTAMENTO.COBRANCA AND X.ORDEM_COBRANCA <= #HISTORICO_ADIANTAMENTO.ORDEM_COBRANCA)  
 */  
  
 /* *********************************************************************************************************************** */  
 /* *********************************************************************************************************************** */  
   
 /* ---------------------------------------------------  
    Consulta Final do Relatório  
    --------------------------------------------------- */  
      
 SELECT rf.TITULAR,  
        ISNULL(dbo.fn_FormataNumeroCNPJ(rf.CGC_TITULAR), dbo.fn_FormataNumeroCPF(rf.CPF_TITULAR)) AS DOCUMENTO_TITULAR,  
        ha.COBRANCA,  
 --    ha.ORDEM_GERAL,  
     ha.ORDEM_COBRANCA,  
     ha.EVENTO_NUM,  
     ha.EVENTO_DESCR,  
     ha.DATACONTAB,  
 --    CASE WHEN ha.VALOR_SINAL >= 0 THEN ha.VALOR_SINAL ELSE 0 END AS VALOR_CREDITO,  
 --    CASE WHEN ha.VALOR_SINAL < 0 THEN ABS(ha.VALOR_SINAL) ELSE 0 END AS VALOR_DEBITO,  
     ha.VALOR_SINAL,  
     ha.SALDO_COBRANCA,  
 --    ha.SALDO_GERAL,  
     ha.RESP,  
     ha.ALUNO,  
     al.NOME_COMPL AS NOME_ALUNO,  
     ha.UNIDADE,  
        ue.NOME_COMP + ' - CNPJ: ' + dbo.fn_FormataNumeroCNPJ(ue.CGC) AS NOME_UNIDADE,  
     ha.ITEMATO_ID,  
     ha.USER_LYCEUM,  
     ISNULL(saag.SALDO_ANTERIOR, 0) AS SALDO_ANTERIOR  
 --    ISNULL(saag.SALDO_ANTERIOR_CREDITO, 0) AS SALDO_ANTERIOR_CREDITO,  
 --    ISNULL(saag.SALDO_ANTERIOR_DEBITO, 0) AS SALDO_ANTERIOR_DEBITO  
 FROM #HISTORICO_ADIANTAMENTO ha  
 JOIN LY_ALUNO al ON ha.ALUNO = al.ALUNO  
 JOIN LY_RESP_FINAN rf ON ha.RESP = rf.RESP  
 JOIN LY_UNIDADE_ENSINO ue ON ha.UNIDADE = ue.UNIDADE_ENS  
 LEFT JOIN #SALDO_ADIANTAMENTO_AGRUPADO saag ON ha.UNIDADE = saag.UNIDADE  
-- ORDER BY ha.UNIDADE, ha.DATACONTAB, ha.COBRANCA, ha.ORDEM_COBRANCA  
ORDER BY ha.COBRANCA, ha.DATACONTAB, CASE WHEN ha.EVENTO_NUM IN (16, 17, 23, 63) THEN 1 ELSE 2 END, ha.ITEMATO_ID  
END  
-- [FIM]
go
INSERT INTO LY_CUSTOM_CLIENTE
(NOME, IDENTIFICACAO_CODIGO, AUTOR, DATA_CRIACAO, OBJETIVO, SOLICITADO_POR, ATIVO, TIPOCOMPONENTE, TIPO, CLIENTE)
SELECT
  'dbo.Relat_AdiantamentosConciliacao' NOME
, '0001' IDENTIFICAO_CODIGO
, 'Miguel Barreto' AUTOR
, '2018-02-16' DATA_CRIACAO
, 'Ajuste calculo do evento 49, 1049' OBJETIVO
, 'José Bispo - Contabilidade' SOLICITADO_POR
, 'S' ATIVO
, 'PROCEDURE' TIPOCOMPONENTE
, 'CLIENTE' TIPO
, 'FTC' CLIENTE

GO 



