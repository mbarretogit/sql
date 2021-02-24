                          
ALTER PROCEDURE dbo.PROC_CARREGA_AY_EXPORTA_MOV_CONTAB                                    
AS                                    
-- [INÍCIO]                                            
BEGIN                                    
                                    
 DECLARE @v_id_proc T_NUMERO = NULL                                    
 DECLARE @v_percentual DECIMAL(3,2)                                    
 DECLARE @v_erros VARCHAR(8000)                                    
 DECLARE @v_qtd_ainserir INT                                    
 DECLARE @v_qtd_inseridos INT                                    
 DECLARE @v_msg VARCHAR(2000)                                    
 DECLARE @v_dtIni DATETIME                                      
 DECLARE @v_dtFim DATETIME                                       
                                    
 -- Guarda a data antes de rodar os updates                                      
 SELECT @v_dtIni = GETDATE()                                     
                                    
 DECLARE @V_SBLOTE VARCHAR(9)                                    
                                    
 -- Registra o inicio do processo                                    
 EXEC spProcIntegracaoInicia 'PROC_CARREGA_AY_EXPORTA_MOV_CONTAB', @v_id_proc OUT                                    
                                    
 -- Escreve a hora inicial no log                                    
 SELECT @v_msg = '[' + CONVERT(VARCHAR, GETDATE(), 113) + ']-> Processo iniciado'                                                    
 EXEC spProcIntegracaoLog @ID_PROC = @v_id_proc, @MSG = @v_msg                                    
                                    
 EXEC GET_NUMERO 'LOTE_INT_CONTAB', '', @V_SBLOTE OUTPUT                                    
                                    
 -- ################################################################### --                                    
 -- Verifica Registros sem centro de custo atualizado                                    
 -- ################################################################### --                                    
 DECLARE @V_UNIDADE_SEM_FILIAL T_CODIGO                                    
 DECLARE @V_QTDE_REG  T_NUMERO                                    
 SET @V_QTDE_REG = 0                                    
 DECLARE C_FILIAL CURSOR FAST_FORWARD FOR                                    
  SELECT DISTINCT RA.UNIDADE AS VAL, COUNT(*)                                    
  FROM  AY_RESUMO_ATO   RA (NOLOCK)                                    
  JOIN  LY_CURSO    CR (NOLOCK) ON CR.CURSO  = RA.CURSO                                    
  LEFT JOIN AY_INT_UNIDADE_FILIAL CC (NOLOCK) ON RA.UNIDADE  = CC.UNIDADE_ENS                                    
  where RA.DATACONTAB >= '20160101'                            
  --AND RA.CODIGO_LANC NOT IN ('SSI') -- incluido por Juliano Armentano em 26-11-2018 com afinalidade de filtrar os itens de SSI                                  
  AND NOT(RA.EVENTO_NUM  IN (17, 23, 26, 65, 1017, 1023, 1026)                                    
    OR (RA.EVENTO_NUM IN (16,1016)                                     
     AND (                                    
      (RA.TIPO_PAGAMENTO = 'Especial' AND RA.TIPO_CRED = 'FIES')                                    
      OR RA.[TIPO_PAGAMENTO] <> 'Especial'                                    
      )                                    
     )                                    
    )                                    
  AND NOT EXISTS (SELECT 1 FROM AY_EXPORTA_MOV_CONTAB WHERE ITEMATO_ID = RA.ITEMATO_ID)                                    
  AND CC.UNIDADE_ENS IS NULL                                    
  GROUP BY RA.UNIDADE                                    
                                      
                                     
 -- Abre o cursor                                    
 OPEN C_FILIAL                                    
 FETCH NEXT FROM C_FILIAL INTO @V_UNIDADE_SEM_FILIAL, @V_QTDE_REG                               
                                    
 -- Para cada item do cursor...                
 WHILE (@@FETCH_STATUS = 0)                                    
 BEGIN                                    
SELECT @v_msg = '      Atenção: Unidade-' + CONVERT(VARCHAR, @V_UNIDADE_SEM_FILIAL) + ' não possui FILIAL cadastrado! ' +  CAST(@V_QTDE_REG AS VARCHAR) + ' registros não foram consolidados/processados.'                                    
  EXEC spProcIntegracaoLog @ID_PROC = @v_id_proc, @MSG = @v_msg                                    
                                     
  FETCH NEXT FROM C_FILIAL INTO @V_UNIDADE_SEM_FILIAL, @V_QTDE_REG                                    
 END                                    
 CLOSE C_FILIAL                                    
 DEALLOCATE C_FILIAL                                    
                                     
                                    
 -- ################################################################### --                                    
 -- Verifica Registros sem centro de custo atualizado                                    
 -- ################################################################### --                                    
 DECLARE @V_CURSO_SEM_CC T_CODIGO                                    
 SET @V_QTDE_REG = 0                     
 DECLARE C_CENTRO_CURSO CURSOR FAST_FORWARD FOR                                    
  SELECT DISTINCT RA.CURSO AS VAL, COUNT(*)                                    
  FROM  AY_RESUMO_ATO   RA (NOLOCK)                                    
  JOIN  LY_CURSO    CR (NOLOCK) ON CR.CURSO  = RA.CURSO                                    
  LEFT JOIN LY_CENTRO_DE_CUSTO  CC (NOLOCK) ON RA.CURSO  = CC.CURSO                                    
  ---AND RA.EVENTO_NUM NOT IN (16, 17, 23, 26, 65, 1016, 1017, 1023, 1026)                                    
  WHERE RA.DATACONTAB >= '20160101'                            
  --AND RA.CODIGO_LANC NOT IN ('SSI')  -- incluido por Juliano Armentano em 26-11-2018 com afinalidade de filtrar os itens de SSI                                
  AND NOT(RA.EVENTO_NUM  IN (17, 23, 26, 65, 1017, 1023, 1026)                                    
    OR (RA.EVENTO_NUM IN (16,1016)                                     
     AND (                                    
      (RA.TIPO_PAGAMENTO = 'Especial' AND RA.TIPO_CRED = 'FIES')                                    
      OR RA.[TIPO_PAGAMENTO] <> 'Especial'                                    
      )                                    
     )                                    
    )                              
  AND NOT EXISTS (SELECT 1 FROM AY_EXPORTA_RECEBIMENTOS WHERE ITEMATO_ID = RA.ITEMATO_ID)                                    
  AND CC.CENTRO_DE_CUSTO IS NULL                                    
  GROUP BY RA.CURSO                                    
                                              
 -- Abre o cursor                                    
 OPEN C_CENTRO_CURSO                                    
 FETCH NEXT FROM C_CENTRO_CURSO INTO @V_CURSO_SEM_CC, @V_QTDE_REG                                    
                                    
 -- Para cada item do cursor...                                    
 WHILE (@@FETCH_STATUS = 0)                                    
 BEGIN                                    
  SELECT @v_msg = '      Atenção: CURSO-' + CONVERT(VARCHAR, @V_CURSO_SEM_CC) + ' não possui CENTRO DE CUSTO cadastrado! ' +  CAST(@V_QTDE_REG AS VARCHAR) + ' registros não foram consolidados/processados.'                                    
  EXEC spProcIntegracaoLog @ID_PROC = @v_id_proc, @MSG = @v_msg                                    
                                     
  FETCH NEXT FROM C_CENTRO_CURSO INTO @V_CURSO_SEM_CC, @V_QTDE_REG                                    
 END                                    
 CLOSE C_CENTRO_CURSO                                    
 DEALLOCATE C_CENTRO_CURSO                                     
 -- --------------------------------                               
 -- Inserção dos dados na tabela                                    
 -- de exportação                                    
 -- --------------------------------                  
                                     
 -- Escreve a mensagem inicial do processo                                    
 SELECT @v_msg = '[' + CONVERT(VARCHAR, GETDATE(), 113) + ']-> Inserindo novos registros de movimentação contábil...'                                                    
 EXEC spProcIntegracaoLog @ID_PROC = @v_id_proc, @MSG = @v_msg                                    
 EXEC spProcIntegracaoRefresh @v_id_proc, 0, @v_msg             
                                     
 -- Verifica quantos registros devem ser inseridos                                    
 SELECT @v_qtd_ainserir = COUNT(*)                                    
  FROM AY_RAZAO    R (NOLOCK)                                    
  JOIN AY_RESUMO_ATO   RA (NOLOCK) ON R.ITEMATO_ID = RA.ITEMATO_ID                                    
  --JOIN AY_EVENTOS_FATURAMENTO EF (NOLOCK) ON EF.EVENTO_NUM = RA.EVENTO_NUM                                    
  JOIN LY_UNIDADE_ENSINO  UE (NOLOCK) ON RA.UNIDADE = UE.UNIDADE_ENS                                    
  LEFT JOIN LY_RESP_FINAN  RF (NOLOCK) ON (RA.RESP = RF.RESP)                                    
  WHERE NOT EXISTS (SELECT 1 FROM AY_EXPORTA_MOV_CONTAB WHERE NUM = R.NUM)                                    
  AND RA.DATACONTAB >= '20160101'                      
  --AND RA.CODIGO_LANC NOT IN ('SSI')-- incluido por Juliano Armentano em 26-11-2018 com afinalidade de filtrar os itens de SSI                                   
  --AND RA.EVENTO_NUM NOT IN (16, 17, 23, 26, 65, 1016, 1017, 1023, 1026)                                    
  AND NOT(RA.EVENTO_NUM  IN (17, 23, 26, 65, 1017, 1023, 1026)                                    
    OR (RA.EVENTO_NUM IN (16,1016)                                     
     AND (                                    
      (RA.TIPO_PAGAMENTO = 'Especial' AND RA.TIPO_CRED = 'FIES')                                    
      OR RA.[TIPO_PAGAMENTO] <> 'Especial'                                    
      )                                    
     )                                    
    )                                    
  AND R.[CONTA] NOT IN ('1111111111','2222222222','111111111111','222222222222') --('111111111111', '1111111111', '222222222222')   --## Alterado por RAUL em 17/08/17 pois foram identificadas mais contas além das já cadastradas                           
  
   
  --AND UE.UNIDADE_ENS = '50'                                    
                                     
 -- Avisa quantos serão inseridos                                      
 SELECT @v_msg = '      Existem ' + CONVERT(VARCHAR, @v_qtd_ainserir) + ' registros de movimentação contábil para serem consolidados.'                                      
 EXEC spProcIntegracaoLog @ID_PROC = @v_id_proc, @MSG = @v_msg                                    
                                     
 -- Inicia a transacao para os itens                                    
 BEGIN TRANSACTION PROCESSA_EXPORTACAO                                      
                           
 -- Inicia a inserção com tratamento de erros                                    
 BEGIN TRY                                      
                                     
  -- Insere os dados processados pelo argyros                                    
  INSERT INTO AY_EXPORTA_MOV_CONTAB (NUM, ITEMATO_ID, DATACONTAB, CD, CONTA, VALOR, UNIDADE, CNPJ_UNIDADE,                                    
             CENTRO_DE_CUSTO, NATUREZA, DOCUMENTO,                                    
             EVENTO_NUM, EVENTO_DESCR, COBRANCA, LOTE,                                    
             CPF_RESP, CNPJ_RESP, NOME_RESP, DATA_INCLUSAO,                                    
             DATA_INTEGRACAO, DATA_ULTIMO_ERRO, ERRO_INTEGRACAO, CT2_LOTE, CONTA_CRED)                                    
  SELECT distinct top 100 PERCENT    -- Modificado por Igor Campos, add Distinct no retorno. erro de item ato duplicados -- 27/04/2020                               
      RA.ITEMATO_ID,                                    
      RA.ITEMATO_ID,                                    
      RA.DATACONTAB,                       
     '3',                                    
     -- CONTA DEB - MUDANÇA PARA PARTIDA DOBRADA                                    
      (SELECT TOP 1 dbo.fn_FormataNumeroConta(CONTA, ORC_ANO)                                    
      FROM  AY_RAZAO                                    
      WHERE ITEMATO_ID = RA.ITEMATO_ID                                    
      AND  CD = 'D'),                                    
      RA.VALOR,                                    
      RA.UNIDADE, -- CODIGO DO LYCEUM (DE PARA FEITO PELO CLIENTE)                                    
      dbo.fn_FormataNumeroCNPJ(UE.CGC),                                    
      --ISNULL(RA.CENTRO_DE_CUSTO,CC.CENTRO_DE_CUSTO) ,  -- 20/01/2021 -- ALTERADO POR MIGUEL BARRETO DEVIDO A ATUALIZAÇÃO DE CENTROS DE CUSTOS (UTILIZADO DE_PARA PREVIAMENTE).  
   CC.CENTRO_DE_CUSTO,  
      RA.NATUREZA, -- CONTA_FINANCEIRA                                    
      SUBSTRING(RA.TIPO_CURSO,1, 6)  DOCUMENTO,                                    
      RA.EVENTO_NUM,                                    
      RA.EVENTO_DESCR,                                    
      RA.COBRANCA,                     
      @V_SBLOTE,                                    
      dbo.fn_FormataNumeroCPF(RA.CPF_RESP),                                    
      dbo.fn_FormataNumeroCNPJ(RA.CNPJ_RESP),                                    
      SUBSTRING(RF.TITULAR,1,50),                                    
      GETDATE(), -- DATA_INCLUSAO                                    
      NULL, -- DATA_INTEGRACAO                       
      NULL, -- DATA_ULTIMO_ERRO                                    
      NULL, --ERRO_INTEGRACAO                                    
      'LY'+SUBSTRING(CAST(MONTH(RA.DATACONTAB)+100 AS VARCHAR),2,2)+ FI.FILIAL_SIGLA,                                    
      -- CONTA CRED - MUDANÇA PARA PARTIDA DOBRADA                                    
      (SELECT TOP 1 dbo.fn_FormataNumeroConta(CONTA, ORC_ANO)                                    
      FROM  AY_RAZAO                                    
      WHERE ITEMATO_ID = RA.ITEMATO_ID                                    
      AND  CD = 'C')                                    
  --FROM AY_RAZAO    R (NOLOCK)                                    
  --JOIN AY_RESUMO_ATO   RA (NOLOCK) ON R.ITEMATO_ID = RA.ITEMATO_ID                                    
  FROM AY_RESUMO_ATO  RA (NOLOCK)                                    
  --JOIN AY_EVENTOS_FATURAMENTO EF (NOLOCK) ON EF.EVENTO_NUM = RA.EVENTO_NUM                                    
  JOIN LY_UNIDADE_ENSINO  UE (NOLOCK) ON RA.UNIDADE = UE.UNIDADE_ENS                                    
  LEFT JOIN LY_RESP_FINAN  RF (NOLOCK) ON (RA.RESP = RF.RESP)                                    
  LEFT JOIN LY_CENTRO_DE_CUSTO CC (NOLOCK) ON CC.CURSO = RA.CURSO                                    
  LEFT JOIN AY_INT_UNIDADE_FILIAL FI (NOLOCK) ON FI.UNIDADE_ENS = RA.UNIDADE                                    
  WHERE NOT EXISTS (SELECT 1 FROM AY_EXPORTA_MOV_CONTAB WHERE ITEMATO_ID = RA.ITEMATO_ID)                                    
  AND RA.DATACONTAB >= '20160101'    --AND RA.EVENTO_NUM NOT IN (16, 17, 23, 26, 65, 1016, 1017, 1023, 1026)                               
  --AND RA.CODIGO_LANC NOT IN ('SSI') -- incluido por Juliano Armentano em 26-11-2018 com afinalidade de filtrar os itens de SSI                              
  AND NOT(RA.EVENTO_NUM  IN (17, 23, 26, 65, 1017, 1023, 1026)                            
    OR (RA.EVENTO_NUM IN (16,1016)                                     
     AND (                                    
      (RA.TIPO_PAGAMENTO = 'Especial' AND RA.TIPO_CRED = 'FIES')                                    
      OR RA.[TIPO_PAGAMENTO] <> 'Especial'                                    
      )                                    
     )                                    
    )                                    
  AND NOT EXISTS (SELECT TOP 1 1 FROM AY_RAZAO WHERE ITEMATO_ID = RA.ITEMATO_ID AND [CONTA] IN ('1111111111','2222222222','111111111111','222222222222'))  --## '111111111111', '1111111111', '222222222222' -- Alterado por RAUL em 17/08/17 pois foram criadas mais contas lixo.                                    
  AND  EXISTS (SELECT TOP 1 1 FROM AY_RAZAO WHERE ITEMATO_ID = RA.ITEMATO_ID )      
  AND (RA.TIPO_PAGAMENTO NOT IN ('Cheque')  OR RA.TIPO_PAGAMENTO IS NULL)
  --AND RA.ITEMATO_ID <> '18567307'             
  --AND UE.UNIDADE_ENS = '50'                                    
  --AND RA.UNIDADE_FISICA = 'DOM-JEQ'                                    
  ORDER BY RA.DATACONTAB, RA.ITEMATO_ID                                    
                                      
  -- Pega quantos itens foram afetados                             
  SET @v_qtd_inseridos = @@ROWCOUNT                                    
                
 ----------------------------------------------------------------------------------------------------------------------------------------              
 -- IMES               
 ----------------------------------------------------------------------------------------------------------------------------------------              
          INSERT INTO INT_CT2040 (ct2_filial,ct2_data,ct2_lote,ct2_sblote,ct2_doc,ct2_linha,ct2_moedlc,ct2_dc,ct2_debito,ct2_credit,ct2_dcd,ct2_dcc,ct2_valor,ct2_moedas,ct2_hp,ct2_hist,                                    
        ct2_ccd,ct2_ccc,ct2_itemd,ct2_itemc,ct2_clvldb,ct2_clvlcr,ct2_ativde,ct2_ativcr,ct2_empori,ct2_filori,ct2_interc,ct2_tpsald,ct2_sequen,ct2_manual,ct2_origem,                                    
        ct2_rotina,ct2_aglut,ct2_lp,ct2_seqhis,ct2_seqlan,ct2_dtvenc,ct2_slbase,ct2_dtlp,ct2_datatx,ct2_taxa,ct2_vlr01,ct2_vlr02,ct2_vlr03,ct2_vlr04,ct2_vlr05,                                    
        ct2_crconv,ct2_criter,ct2_usergi,ct2_userga,d_e_l_e_t_,r_e_c_n_o_,r_e_c_d_e_l_,ct2_identc,ct2_key,ct2_segofi,ct2_dtcv3,ct2_seqidx,ct2_codpar,ct2_mltsld,                                    
        ct2_ctlsld,ct2_codcli,ct2_codfor,ct2_diactb,ct2_confst,ct2_obscnf,ct2_nodia,ct2_usrcnf,ct2_dtconf,ct2_hrconf,ct2_at01db,ct2_at01cr,ct2_at02db,ct2_at02cr,                                    
        ct2_at03db,ct2_at03cr,ct2_at04db,ct2_at04cr,ct2_ctrlsd,ct2_moefdb,ct2_moefcr, LOTE)                                    
  SELECT DISTINCT TOP 100 percent                                    
      CT2_FILIAL  = FI.FILIAL_SIGLA,                                    
      CT2_DATA  = CONVERT(CHAR(8),DATACONTAB, 112),                                    
      CT2_LOTE  = 'LY'+SUBSTRING(CAST(MONTH(DATACONTAB)+100 AS VARCHAR),2,2)+ FI.FILIAL_SIGLA,                                    
      CT2_SBLOTE  = '',                                    
      CT2_DOC   = '000001',                                    
      CT2_LINHA  = '',                                    
      CT2_MOEDLC  = '01', -- MOEDA                                    
      CT2_DC   = '3',--CD, --CASE WHEN CONTA_DEB IS NOT NULL THEN '1' WHEN CONTA_CRED IS NOT NULL THEN '2' ELSE '3' END,  -- TIPO LANÇAMENTO PARTIDA DOBRADA                                    
      CT2_DEBITO  = CONTA,                                    
      CT2_CREDIT  = CONTA_CRED,                                    
      CT2_DCD   = '',                                    
      CT2_DCC   = '',                                    
      CT2_VALOR  = SUM(VALOR),                                    
      CT2_MOEDAS  = '',                                    
      CT2_HP   = '',                                    
      CT2_HIST  = --MAX(DBO.FN_AY_INT_HISTORICO(DOCUMENTO) + ' ' +                                    
     --SUBSTRING(CAST(MONTH(DATACONTAB)+100 AS VARCHAR(3)),2,2) + '/' +                                     
           --SUBSTRING(CAST(YEAR(DATACONTAB) AS VARCHAR(4)),3,2) + ' ' +                                    
     --FI.NOME_FILIAL)                                    
      DBO.FN_AY_INT_HISTORICO_CONTAB(MC.EVENTO_NUM, MC.DATACONTAB, MC.DOCUMENTO, FI.NOME_FILIAL),                                    
      CT2_CCD   = CENTRO_DE_CUSTO,                                    
      CT2_CCC   = CENTRO_DE_CUSTO,                                    
      CT2_ITEMD  = '',                                    
      CT2_ITEMC  = '',                                    
      CT2_CLVLDB  = '',                                    
    CT2_CLVLCR  = '',                                    
      CT2_ATIVDE  = '',                                    
      CT2_ATIVCR  = '',                                    
      CT2_EMPORI  = FI.EMPRESA_SIGLA,                                    
      CT2_FILORI  = FI.FILIAL_SIGLA,                                    
      CT2_INTERC  = '',                                    
      CT2_TPSALD  = '1',                                    
      CT2_SEQUEN  = '',                                    
      CT2_MANUAL  = '1',                                    
     CT2_ORIGEM  = '',                                    
      CT2_ROTINA  = 'LYCEUM',                                    
      CT2_AGLUT  = '',                                    
      CT2_LP   = '',                                    
      CT2_SEQHIS  = '',                                    
      CT2_SEQLAN  = '',                                    
      CT2_DTVENC  = '',                                    
      CT2_SLBASE  = '',                                    
      CT2_DTLP  = '',                                    
      CT2_DATATX  = '',                             
      CT2_TAXA  = 0,                                    
      CT2_VLR01  = 0,                                    
      CT2_VLR02  = 0,                                    
      CT2_VLR03  = 0,                                    
      CT2_VLR04 = 0,                                    
      CT2_VLR05  = 0,                                    
      CT2_CRCONV  = '',                                    
      CT2_CRITER  = '',                                    
      CT2_USERGI  = '',                                    
      CT2_USERGA  = '',                                    
      D_E_L_E_T_  = '',                                    
      R_E_C_N_O_  = 0,                                    
      R_E_C_D_E_L_ = 0,                                    
      CT2_IDENTC  = '',                                    
      CT2_KEY   = '',                                    
      CT2_SEGOFI  = '',                                    
      CT2_DTCV3  = '',                                    
      CT2_MLTSLD  = '',                                    
      CT2_SEQIDX  = '',                                    
      CT2_CTLSLD  = 0,                                    
      CT2_CODPAR  = '',                                    
      CT2_CODCLI  = '',                
      CT2_CODFOR  = '',                                    
      CT2_DIACTB  = '',                                    
      CT2_CONFST  = '',                                    
      CT2_OBSCNF  = '',                                    
      CT2_NODIA  = '',                                    
      CT2_USRCNF  = '',                                    
      CT2_DTCONF  = '',                                    
      CT2_HRCONF  = '',                                    
      CT2_AT01DB  = '',                                    
      CT2_AT01CR  = '',                                    
      CT2_AT02DB  = '',                                    
      CT2_AT02CR  = '',                                    
  CT2_AT03DB  = '',                                    
      CT2_AT03CR  = '',                                    
      CT2_AT04DB  = '',                                    
CT2_AT04CR  = '',                                    
      CT2_CTRLSD  = '',                                    
      CT2_MOEFDB  = '',                         
      CT2_MOEFCR  = '',                                    
      LOTE   = @V_SBLOTE                                    
    FROM AY_EXPORTA_MOV_CONTAB  MC (NOLOCK)           
    INNER JOIN LY_COBRANCA C ON C.COBRANCA = MC.COBRANCA          
    JOIN AY_INT_UNIDADE_FILIAL FI (NOLOCK) ON FI.UNIDADE_ENS = MC.UNIDADE -- and FI.NOME_ABREVIADO = C.UNID_FISICA   -- add ALTERADO - Igor Campos 04/06/2020                                                 
    where FI.FILIAL_SIGLA is not null                                    
    AND FI.NOME_EMPRESA = 'IMES'                                    
    AND MC.DATA_INTEGRACAO IS NULL                                    
    GROUP BY DATACONTAB, CD, CONTA, CONTA_CRED, CENTRO_DE_CUSTO, DOCUMENTO, FI.FILIAL_SIGLA, FI.EMPRESA_SIGLA, FI.NOME_FILIAL, EVENTO_NUM                                    
    ORDER BY 2, 1, 3                                    
                
 ----------------------------------------------------------------------------------------------------------------------------------------              
 -- DOM               
 ----------------------------------------------------------------------------------------------------------------------------------------              
                  
  INSERT INTO INT_CT2220 (ct2_filial,ct2_data,ct2_lote,ct2_sblote,ct2_doc,ct2_linha,ct2_moedlc,ct2_dc,ct2_debito,ct2_credit,ct2_dcd,ct2_dcc,ct2_valor,ct2_moedas,ct2_hp,ct2_hist,                                    
        ct2_ccd,ct2_ccc,ct2_itemd,ct2_itemc,ct2_clvldb,ct2_clvlcr,ct2_ativde,ct2_ativcr,ct2_empori,ct2_filori,ct2_interc,ct2_tpsald,ct2_sequen,ct2_manual,ct2_origem,                                    
        ct2_rotina,ct2_aglut,ct2_lp,ct2_seqhis,ct2_seqlan,ct2_dtvenc,ct2_slbase,ct2_dtlp,ct2_datatx,ct2_taxa,ct2_vlr01,ct2_vlr02,ct2_vlr03,ct2_vlr04,ct2_vlr05,                                    
        ct2_crconv,ct2_criter,ct2_usergi,ct2_userga,d_e_l_e_t_,r_e_c_n_o_,r_e_c_d_e_l_,ct2_identc,ct2_key,ct2_segofi,ct2_dtcv3,ct2_seqidx,ct2_codpar,ct2_mltsld,                                   
        ct2_ctlsld,ct2_codcli,ct2_codfor,ct2_diactb,ct2_confst,ct2_obscnf,ct2_nodia,ct2_usrcnf,ct2_dtconf,ct2_hrconf,ct2_at01db,ct2_at01cr,ct2_at02db,ct2_at02cr,                                    
        ct2_at03db,ct2_at03cr,ct2_at04db,ct2_at04cr,ct2_ctrlsd,ct2_moefdb,ct2_moefcr, LOTE)                                   
  SELECT DISTINCT TOP 100 percent                                    
      CT2_FILIAL  = FI.FILIAL_SIGLA,                                    
      CT2_DATA  = CONVERT(CHAR(8),DATACONTAB, 112),                                    
      CT2_LOTE  = 'LY'+SUBSTRING(CAST(MONTH(DATACONTAB)+100 AS VARCHAR),2,2)+ FI.FILIAL_SIGLA,                                    
      CT2_SBLOTE  = '',                                    
      CT2_DOC   = '000001',                                    
      CT2_LINHA  = '',                                    
      CT2_MOEDLC  = '01', -- MOEDA                                    
      CT2_DC   = '3',--CD, --CASE WHEN CONTA_DEB IS NOT NULL THEN '1' WHEN CONTA_CRED IS NOT NULL THEN '2' ELSE '3' END,  -- TIPO LANÇAMENTO PARTIDA DOBRADA                                    
      CT2_DEBITO  = CONTA,                                    
      CT2_CREDIT  = CONTA_CRED,                                    
      CT2_DCD   = '',                                    
      CT2_DCC   = '',                                    
      CT2_VALOR  = SUM(VALOR),                                    
      CT2_MOEDAS  = '',                                    
      CT2_HP   = '',                                
CT2_HIST  = --MAX(DBO.FN_AY_INT_HISTORICO(DOCUMENTO) + ' ' +                                    
           --SUBSTRING(CAST(MONTH(DATACONTAB)+100 AS VARCHAR(3)),2,2) + '/' +                                     
           --SUBSTRING(CAST(YEAR(DATACONTAB) AS VARCHAR(4)),3,2) + ' ' +                                    
           --FI.NOME_FILIAL)                                    
       DBO.FN_AY_INT_HISTORICO_CONTAB(MC.EVENTO_NUM, MC.DATACONTAB, MC.DOCUMENTO, FI.NOME_FILIAL)                                    
           ,                                    
      CT2_CCD   = CENTRO_DE_CUSTO,                                    
      CT2_CCC   = CENTRO_DE_CUSTO,                                    
      CT2_ITEMD  = '',                                    
      CT2_ITEMC  = '',                                    
      CT2_CLVLDB  = '',                                    
      CT2_CLVLCR  = '',                                    
      CT2_ATIVDE  = '',                                    
      CT2_ATIVCR  = '',                                    
      CT2_EMPORI  = FI.EMPRESA_SIGLA,                                    
      CT2_FILORI  = FI.FILIAL_SIGLA,                       
      CT2_INTERC  = '',                                    
      CT2_TPSALD  = '1',                                    
      CT2_SEQUEN  = '',                                    
      CT2_MANUAL  = '1',                                    
      CT2_ORIGEM  = '',                                    
      CT2_ROTINA  = 'LYCEUM',                                    
      CT2_AGLUT  = '',                                    
      CT2_LP   = '',                                    
      CT2_SEQHIS  = '',                                    
      CT2_SEQLAN  = '',                                    
      CT2_DTVENC  = '',                                    
      CT2_SLBASE  = '',                                    
      CT2_DTLP  = '',                                    
      CT2_DATATX  = '',                                    
      CT2_TAXA  = 0,                                    
      CT2_VLR01  = 0,                                    
      CT2_VLR02  = 0,                                    
      CT2_VLR03  = 0,                                    
      CT2_VLR04  = 0,                                    
      CT2_VLR05  = 0,                                    
      CT2_CRCONV  = '',                                    
      CT2_CRITER  = '',                                
      CT2_USERGI  = '',                                    
      CT2_USERGA  = '',                                    
      D_E_L_E_T_  = '',                                    
      R_E_C_N_O_  = 0,                                    
      R_E_C_D_E_L_ = 0,                                    
      CT2_IDENTC  = '',                                    
      CT2_KEY   = '',                                    
      CT2_SEGOFI  = '',                                    
      CT2_DTCV3  = '',                                    
      CT2_MLTSLD  = '',                                    
      CT2_SEQIDX  = '',                                    
      CT2_CTLSLD  = 0,                                    
      CT2_CODPAR  = '',                                    
      CT2_CODCLI  = '',                                    
      CT2_CODFOR  = '',                                    
      CT2_DIACTB  = '',                                    
      CT2_CONFST  = '',                                    
      CT2_OBSCNF  = '',                                    
      CT2_NODIA  = '',                                    
      CT2_USRCNF  = '',                     
      CT2_DTCONF  = '',                                    
      CT2_HRCONF  = '',                                    
      CT2_AT01DB  = '',                                    
      CT2_AT01CR  = '',                                    
      CT2_AT02DB  = '',                                    
      CT2_AT02CR  = '',                                    
      CT2_AT03DB  = '',                                    
      CT2_AT03CR  = '',                                    
      CT2_AT04DB  = '',                                    
      CT2_AT04CR  = '',                                    
      CT2_CTRLSD  = '',                                    
      CT2_MOEFDB  = '',                                    
      CT2_MOEFCR  = '',               
      LOTE   = @V_SBLOTE                                    
    FROM AY_EXPORTA_MOV_CONTAB  MC (NOLOCK)          
    INNER JOIN LY_COBRANCA C ON C.COBRANCA = MC.COBRANCA          
    JOIN AY_INT_UNIDADE_FILIAL FI (NOLOCK) ON FI.UNIDADE_ENS = MC.UNIDADE -- and FI.NOME_ABREVIADO = C.UNID_FISICA   -- add ALTERADO - Igor Campos 04/06/2020                                                      
    where FI.FILIAL_SIGLA is not null                                   
    AND FI.NOME_EMPRESA = 'DOM'                                    
    AND MC.DATA_INTEGRACAO IS NULL                                    
    GROUP BY DATACONTAB, CD, CONTA, CONTA_CRED, CENTRO_DE_CUSTO, DOCUMENTO, FI.FILIAL_SIGLA, FI.EMPRESA_SIGLA, FI.NOME_FILIAL, EVENTO_NUM                                    
    ORDER BY 2, 1, 3                                    
                  
 ----------------------------------------------------------------------------------------------------------------------------------------              
 -- OTE               
 ----------------------------------------------------------------------------------------------------------------------------------------              
                                  
  INSERT INTO INT_CT2070 (ct2_filial,ct2_data,ct2_lote,ct2_sblote,ct2_doc,ct2_linha,ct2_moedlc,ct2_dc,ct2_debito,ct2_credit,ct2_dcd,ct2_dcc,ct2_valor,ct2_moedas,ct2_hp,ct2_hist,                                    
        ct2_ccd,ct2_ccc,ct2_itemd,ct2_itemc,ct2_clvldb,ct2_clvlcr,ct2_ativde,ct2_ativcr,ct2_empori,ct2_filori,ct2_interc,ct2_tpsald,ct2_sequen,ct2_manual,ct2_origem,                                    
        ct2_rotina,ct2_aglut,ct2_lp,ct2_seqhis,ct2_seqlan,ct2_dtvenc,ct2_slbase,ct2_dtlp,ct2_datatx,ct2_taxa,ct2_vlr01,ct2_vlr02,ct2_vlr03,ct2_vlr04,ct2_vlr05,             
        ct2_crconv,ct2_criter,ct2_usergi,ct2_userga,d_e_l_e_t_,r_e_c_n_o_,r_e_c_d_e_l_,ct2_identc,ct2_key,ct2_segofi,ct2_dtcv3,ct2_seqidx,ct2_codpar,ct2_mltsld,                                    
        ct2_ctlsld,ct2_codcli,ct2_codfor,ct2_diactb,ct2_confst,ct2_obscnf,ct2_nodia,ct2_usrcnf,ct2_dtconf,ct2_hrconf,ct2_at01db,ct2_at01cr,ct2_at02db,ct2_at02cr,                                    
        ct2_at03db,ct2_at03cr,ct2_at04db,ct2_at04cr,ct2_ctrlsd,ct2_moefdb,ct2_moefcr, LOTE)                                    
  SELECT DISTINCT TOP 100 percent                                    
      --CT2_FILIAL  = '',--FI.FILIAL_SIGLA, --alterado por juliano armentano em 01/08/2017 empresa ote a contabilidade é compartilhada ct2_filial = ' '                               
   CT2_FILIAL  = FI.FILIAL_SIGLA, --alterado por igor campos armentano em 18/09/2019 empresa ote a contabilidade é compartilhada ct2_filial solicitação de bete analista sr do protheus                               
      CT2_DATA  = CONVERT(CHAR(8),DATACONTAB, 112),                                    
      CT2_LOTE  = 'LY'+SUBSTRING(CAST(MONTH(DATACONTAB)+100 AS VARCHAR),2,2)+ FI.FILIAL_SIGLA,                                    
      CT2_SBLOTE  = '',                                    
      CT2_DOC   = '000001',                                    
      CT2_LINHA  = '',                                    
      CT2_MOEDLC  = '01', -- MOEDA                                    
      CT2_DC   = '3',--CD, --CASE WHEN CONTA_DEB IS NOT NULL THEN '1' WHEN CONTA_CRED IS NOT NULL THEN '2' ELSE '3' END,  -- TIPO LANÇAMENTO PARTIDA DOBRADA                                    
      CT2_DEBITO  = CONTA,                                    
      CT2_CREDIT  = CONTA_CRED,                                    
      CT2_DCD   = '',                                    
      CT2_DCC   = '',                                    
      CT2_VALOR  = SUM(VALOR),                                    
      CT2_MOEDAS  = '',                                    
      CT2_HP   = '',                                    
      CT2_HIST  = --MAX(DBO.FN_AY_INT_HISTORICO(DOCUMENTO) + ' ' +                                    
           --SUBSTRING(CAST(MONTH(DATACONTAB)+100 AS VARCHAR(3)),2,2) + '/' +                                     
           --SUBSTRING(CAST(YEAR(DATACONTAB) AS VARCHAR(4)),3,2) + ' ' +                                    
           --FI.NOME_FILIAL)                                    
           DBO.FN_AY_INT_HISTORICO_CONTAB(MC.EVENTO_NUM, MC.DATACONTAB, MC.DOCUMENTO, FI.NOME_FILIAL)                                    
          ,                                    
      CT2_CCD   = CENTRO_DE_CUSTO,                                    
      CT2_CCC   = CENTRO_DE_CUSTO,                                    
      CT2_ITEMD  = FI.FILIAL_SIGLA, --''--alterado por juliano armentano em 01/08/2017 empresa ote a contabilidade é compartilhada ct2_filial = ' '                                   
      CT2_ITEMC  = FI.FILIAL_SIGLA, --''--alterado por juliano armentano em 01/08/2017 empresa ote a contabilidade é compartilhada ct2_filial = ' '                                        
      CT2_CLVLDB  = '',                        
      CT2_CLVLCR  = '',                                    
      CT2_ATIVDE  = '',                                    
      CT2_ATIVCR  = '',                                    
      CT2_EMPORI  = FI.EMPRESA_SIGLA,                                    
      CT2_FILORI  = FI.FILIAL_SIGLA,                                    
      CT2_INTERC  = '',                                    
      CT2_TPSALD  = '1',                            
      CT2_SEQUEN  = '',                                    
      CT2_MANUAL  = '1',                                    
      CT2_ORIGEM  = '',                                    
      CT2_ROTINA  = 'LYCEUM',                                    
      CT2_AGLUT  = '',                                    
      CT2_LP   = '',                                    
      CT2_SEQHIS  = '',                                    
      CT2_SEQLAN  = '',                                    
      CT2_DTVENC  = '',                                    
 CT2_SLBASE  = '',                                    
      CT2_DTLP  = '',                                    
      CT2_DATATX  = '',                            
      CT2_TAXA  = 0,                                    
      CT2_VLR01  = 0,                                    
      CT2_VLR02  = 0,                                    
      CT2_VLR03  = 0,                                    
      CT2_VLR04  = 0,                                    
      CT2_VLR05  = 0,                                    
      CT2_CRCONV  = '',                                    
      CT2_CRITER  = '',                                    
      CT2_USERGI  = '',                                    
      CT2_USERGA  = '',                                    
      D_E_L_E_T_  = '',                                    
      R_E_C_N_O_  = 0,                      R_E_C_D_E_L_ = 0,                                    
      CT2_IDENTC  = '',                                    
      CT2_KEY   = '',                                    
      CT2_SEGOFI  = '',                              
      CT2_DTCV3  = '',                                    
      CT2_MLTSLD  = '',                                    
      CT2_SEQIDX  = '',                                    
      CT2_CTLSLD  = 0,                                    
      CT2_CODPAR  = '',                                    
      CT2_CODCLI  = '',                                    
      CT2_CODFOR  = '',                                    
      CT2_DIACTB  = '',                                    
      CT2_CONFST  = '',                                    
      CT2_OBSCNF  = '',                                    
      CT2_NODIA  = '',                                    
      CT2_USRCNF  = '',                                    
      CT2_DTCONF  = '',                                    
      CT2_HRCONF  = '',                                    
      CT2_AT01DB  = '',                                    
      CT2_AT01CR  = '',                                    
      CT2_AT02DB  = '',                                
      CT2_AT02CR  = '',                                    
      CT2_AT03DB  = '',                                    
      CT2_AT03CR  = '',                                    
      CT2_AT04DB  = '',                                    
      CT2_AT04CR  = '',                                    
      CT2_CTRLSD  = '',                                    
      CT2_MOEFDB  = '',                                    
      CT2_MOEFCR  = '',                                    
      LOTE   = @V_SBLOTE                                    
    FROM AY_EXPORTA_MOV_CONTAB  MC (NOLOCK)          
    INNER JOIN LY_COBRANCA C ON C.COBRANCA = MC.COBRANCA          
    JOIN AY_INT_UNIDADE_FILIAL FI (NOLOCK) ON FI.UNIDADE_ENS = MC.UNIDADE -- and FI.NOME_ABREVIADO = C.UNID_FISICA   -- add ALTERADO - Igor Campos 04/06/2020                                                        
    where FI.FILIAL_SIGLA is not null                                    
    AND FI.NOME_EMPRESA = 'OTE'                                    
    AND MC.DATA_INTEGRACAO IS NULL                                   
    GROUP BY DATACONTAB, CD, CONTA, CONTA_CRED, CENTRO_DE_CUSTO, DOCUMENTO, FI.FILIAL_SIGLA, FI.EMPRESA_SIGLA, FI.NOME_FILIAL, EVENTO_NUM                                    
    ORDER BY 2, 1, 3                          
                 
    ----------------------------------------------------------------------------------------------------------------------------------------              
 -- UNECE - ADD unidade nova por Igor Campos 01/01/2020               
 ----------------------------------------------------------------------------------------------------------------------------------------              
              
   INSERT INTO INT_CT2250 (ct2_filial,ct2_data,ct2_lote,ct2_sblote,ct2_doc,ct2_linha,ct2_moedlc,ct2_dc,ct2_debito,ct2_credit,ct2_dcd,ct2_dcc,ct2_valor,ct2_moedas,ct2_hp,ct2_hist,                                    
        ct2_ccd,ct2_ccc,ct2_itemd,ct2_itemc,ct2_clvldb,ct2_clvlcr,ct2_ativde,ct2_ativcr,ct2_empori,ct2_filori,ct2_interc,ct2_tpsald,ct2_sequen,ct2_manual,ct2_origem,                                    
        ct2_rotina,ct2_aglut,ct2_lp,ct2_seqhis,ct2_seqlan,ct2_dtvenc,ct2_slbase,ct2_dtlp,ct2_datatx,ct2_taxa,ct2_vlr01,ct2_vlr02,ct2_vlr03,ct2_vlr04,ct2_vlr05,                                    
        ct2_crconv,ct2_criter,ct2_usergi,ct2_userga,d_e_l_e_t_,r_e_c_n_o_,r_e_c_d_e_l_,ct2_identc,ct2_key,ct2_segofi,ct2_dtcv3,ct2_seqidx,ct2_codpar,ct2_mltsld,                                    
        ct2_ctlsld,ct2_codcli,ct2_codfor,ct2_diactb,ct2_confst,ct2_obscnf,ct2_nodia,ct2_usrcnf,ct2_dtconf,ct2_hrconf,ct2_at01db,ct2_at01cr,ct2_at02db,ct2_at02cr,                                    
        ct2_at03db,ct2_at03cr,ct2_at04db,ct2_at04cr,ct2_ctrlsd,ct2_moefdb,ct2_moefcr, LOTE)                                    
  SELECT DISTINCT TOP 100 percent                                    
      --CT2_FILIAL  = '',--FI.FILIAL_SIGLA, --alterado por juliano armentano em 01/08/2017 empresa ote a contabilidade é compartilhada ct2_filial = ' '                         
      CT2_FILIAL  = FI.FILIAL_SIGLA, --alterado por igor campos armentano em 18/09/2019 empresa ote a contabilidade é compartilhada ct2_filial solicitação de bete analista sr do protheus                               
      CT2_DATA  = CONVERT(CHAR(8),DATACONTAB, 112),                                    
      CT2_LOTE  = 'LY'+SUBSTRING(CAST(MONTH(DATACONTAB)+100 AS VARCHAR),2,2)+ FI.FILIAL_SIGLA,                                    
      CT2_SBLOTE  = '',                                    
      CT2_DOC   = '000001',                                    
      CT2_LINHA  = '',                                    
      CT2_MOEDLC  = '01', -- MOEDA                                    
      CT2_DC   = '3',--CD, --CASE WHEN CONTA_DEB IS NOT NULL THEN '1' WHEN CONTA_CRED IS NOT NULL THEN '2' ELSE '3' END,  -- TIPO LANÇAMENTO PARTIDA DOBRADA                                    
      CT2_DEBITO  = CONTA,                                    
      CT2_CREDIT  = CONTA_CRED,                                    
      CT2_DCD   = '',                                    
      CT2_DCC   = '',                                    
      CT2_VALOR  = SUM(VALOR),                                    
      CT2_MOEDAS  = '',            
      CT2_HP   = '',                                    
      CT2_HIST  = --MAX(DBO.FN_AY_INT_HISTORICO(DOCUMENTO) + ' ' +                                    
           --SUBSTRING(CAST(MONTH(DATACONTAB)+100 AS VARCHAR(3)),2,2) + '/' +                                     
           --SUBSTRING(CAST(YEAR(DATACONTAB) AS VARCHAR(4)),3,2) + ' ' +                                    
           --FI.NOME_FILIAL)                                    
      DBO.FN_AY_INT_HISTORICO_CONTAB(MC.EVENTO_NUM, MC.DATACONTAB, MC.DOCUMENTO, FI.NOME_FILIAL)                                    
          ,                                    
      CT2_CCD   = CENTRO_DE_CUSTO,                                    
      CT2_CCC   = CENTRO_DE_CUSTO,                                    
      CT2_ITEMD  = FI.FILIAL_SIGLA, --''--alterado por juliano armentano em 01/08/2017 empresa ote a contabilidade é compartilhada ct2_filial = ' '                                   
      CT2_ITEMC  = FI.FILIAL_SIGLA, --''--alterado por juliano armentano em 01/08/2017 empresa ote a contabilidade é compartilhada ct2_filial = ' '                                        
      CT2_CLVLDB  = '',                                    
      CT2_CLVLCR  = '',                                    
      CT2_ATIVDE  = '',                                    
      CT2_ATIVCR  = '',                                    
      CT2_EMPORI  = FI.EMPRESA_SIGLA,                                    
      CT2_FILORI  = FI.FILIAL_SIGLA,                                    
      CT2_INTERC  = '',                                    
      CT2_TPSALD  = '1',                                    
      CT2_SEQUEN  = '',                                    
      CT2_MANUAL  = '1',                                    
      CT2_ORIGEM  = '',                                    
      CT2_ROTINA  = 'LYCEUM',                                    
      CT2_AGLUT  = '',                                    
      CT2_LP   = '',                                    
      CT2_SEQHIS  = '',                                    
      CT2_SEQLAN  = '',                                    
      CT2_DTVENC  = '',                                    
      CT2_SLBASE  = '',                                    
      CT2_DTLP  = '',                                    
      CT2_DATATX  = '',                                 
      CT2_TAXA  = 0,                                    
      CT2_VLR01  = 0,                                    
      CT2_VLR02  = 0,                                 
      CT2_VLR03  = 0,                                    
      CT2_VLR04  = 0,                                    
      CT2_VLR05  = 0,                                    
      CT2_CRCONV  = '',                                    
      CT2_CRITER  = '',                                    
      CT2_USERGI  = '',                                    
      CT2_USERGA  = '',                                    
      D_E_L_E_T_  = '',                                    
      R_E_C_N_O_  = 0,                                  
   R_E_C_D_E_L_ = 0,                                    
      CT2_IDENTC  = '',                                    
      CT2_KEY   = '',                                    
      CT2_SEGOFI  = '',                                    
      CT2_DTCV3  = '',                                    
      CT2_MLTSLD  = '',                                    
  CT2_SEQIDX  = '',                                    
      CT2_CTLSLD  = 0,                                    
      CT2_CODPAR  = '',                                    
      CT2_CODCLI  = '',                                    
      CT2_CODFOR  = '',                                    
      CT2_DIACTB  = '',                                    
      CT2_CONFST  = '',                                    
      CT2_OBSCNF  = '',                                    
      CT2_NODIA  = '',                           
      CT2_USRCNF  = '',                                    
      CT2_DTCONF  = '',                                    
      CT2_HRCONF  = '',                                    
      CT2_AT01DB  = '',                                    
      CT2_AT01CR  = '',                                    
      CT2_AT02DB  = '',                                    
      CT2_AT02CR  = '',                                    
      CT2_AT03DB  = '',                                    
      CT2_AT03CR  = '',                                    
      CT2_AT04DB  = '',                                    
      CT2_AT04CR  = '',                                    
      CT2_CTRLSD  = '',                                    
      CT2_MOEFDB  = '',                                    
      CT2_MOEFCR  = '',                                    
      LOTE   = @V_SBLOTE                                    
    FROM AY_EXPORTA_MOV_CONTAB  MC (NOLOCK)          
    INNER JOIN LY_COBRANCA C ON C.COBRANCA = MC.COBRANCA          
    JOIN AY_INT_UNIDADE_FILIAL FI (NOLOCK) ON FI.UNIDADE_ENS = MC.UNIDADE -- and FI.NOME_ABREVIADO = C.UNID_FISICA   -- add ALTERADO - Igor Campos 04/06/2020                                                      
    where FI.FILIAL_SIGLA is not null                                    
    AND FI.NOME_EMPRESA = 'UNECE'                                    
    AND MC.DATA_INTEGRACAO IS NULL                                   
    GROUP BY DATACONTAB, CD, CONTA, CONTA_CRED, CENTRO_DE_CUSTO, DOCUMENTO, FI.FILIAL_SIGLA, FI.EMPRESA_SIGLA, FI.NOME_FILIAL, EVENTO_NUM                                    
    ORDER BY 2, 1, 3                     
                      
 ----------------------------------------------------------------------------------------------------------------------------------------              
 -- Set Como Enviado               
 ----------------------------------------------------------------------------------------------------------------------------------------              
              
    UPDATE AY_EXPORTA_MOV_CONTAB                                    
    SET  DATA_INTEGRACAO = DBO.FN_GetDataDiaSemHora(GETDATE())                                    
    WHERE DATA_INTEGRACAO IS NULL                
               
 ----------------------------------------------------------------------------------------------------------------------------------------              
                                    
 END TRY                                      
 BEGIN CATCH                         
                                    
   SELECT                                      
    ERROR_NUMBER() AS ErrorNumber                                      
   ,ERROR_SEVERITY() AS ErrorSeverity                                      
   ,ERROR_STATE() AS ErrorState                                      
   ,ERROR_PROCEDURE() AS ErrorProcedure                                      
   ,ERROR_LINE() AS ErrorLine                                      
   ,ERROR_MESSAGE() AS ErrorMessage;                                      
                                    
                                    
  -- Da rollback (se ainda nao deu)                                      
  IF @@TRANCOUNT > 0                                    
  ROLLBACK TRANSACTION PROCESSA_EXPORTACAO                                      
                                    
  -- Se tiver erro na variavel v_errosw, manda para o log                                     
  SELECT @v_erros = '      ' + ERROR_MESSAGE()                                      
                                    
  -- Escreve os erros e sai da procedure                                    
  SELECT @v_erros = 'Movimentação de exportação interrompida! Erro: ' + ERROR_MESSAGE()                                    
  EXEC spProcIntegracaoLog @ID_PROC = @v_id_proc, @MSG = @v_erros                             
  EXEC spProcIntegracaoFinaliza @v_id_proc, @v_erros                                    
                                      
  RETURN                                    
                                      
 END CATCH                                      
                                    
 -- Da commit                                      
 IF @@TRANCOUNT > 0                                    
 COMMIT TRANSACTION PROCESSA_EXPORTACAO                                    
                                    
 -- Se inseriu algum item                                      
 IF @v_qtd_inseridos > 0                                      
 BEGIN                 
  -- Avisa quantos foram inseridos                                    
  SELECT @v_msg = '      Foram inseridos ' + CONVERT(VARCHAR, @v_qtd_inseridos) + ' registros de movimentação contábil'                                      
 END                                    
 ELSE                                    
 BEGIN                                    
  -- Avisa que nenhum item foi inserido                                    
  SELECT @v_msg = '      Nenhum registro registros de movimentação contábil foi inserido'                                      
 END                                    
                                     
 -- Grava no log se algum registro foi inserido                                    
 EXEC spProcIntegracaoLog @ID_PROC = @v_id_proc, @MSG = @v_msg                                     
                                     
 -- Grava que o processo foi finalizado                         
 SELECT @v_percentual = 1                                    
 EXEC spProcIntegracaoRefresh @v_id_proc, @v_percentual, @v_msg                                    
                                     
  -- Guarda a data depois de rodar os updates                                      
 SELECT @v_dtFim = GETDATE()                                    
                                    
  -- Escreve no log o tempo que levou                                      
 SELECT @v_msg = '      Tempo de execucao: ' + CONVERT(VARCHAR, DATEDIFF(minute, @v_dtIni, @v_dtFim)) + ' minuto(s)'                                      
    EXEC spProcIntegracaoLog @ID_PROC = @v_id_proc, @MSG = @v_msg                                       
                                    
 -- Escreve a hora final no log                                    
 SELECT @v_msg = '[' + CONVERT(VARCHAR, GETDATE(), 113) + ']-> Processo concluido'                                                    
 EXEC spProcIntegracaoLog @ID_PROC = @v_id_proc, @MSG = @v_msg                                    
                                     
 -- Registra o final do processo                                    
 EXEC spProcIntegracaoFinaliza @v_id_proc, 'Processo concluido'                                    
                   
 RETURN                                    
                                    
END                                            
-- [FIM] 