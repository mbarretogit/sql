--sp_helptext FTC_Relat_Recebimentos  
--select * from ly_custom_cliente where nome like '%argy%'  
USE LYCEUM
GO
    
ALTER PROCEDURE dbo.FTC_Relat_RecebimentosPos    
(      
 @p_unid_resp VARCHAR(20),    
 @p_unid_fisica VARCHAR(20),
 @p_tipo_curso VARCHAR(20),    
 @p_curso VARCHAR(20),        
 --@p_cpfoucnpj_resp VARCHAR(19),    
 --@p_nome_resp VARCHAR(50),    
 --@p_num_cobranca NUMERIC(3,0),    
 --@p_banco NUMERIC(3,0),    
 --@p_agencia VARCHAR(15),    
 --@p_conta_banco VARCHAR(15),    
 @p_tipo_cred VARCHAR(20),    
 @p_tipo_baixa VARCHAR(40),    
 @p_tipo_recebimento VARCHAR(15),    
 --@p_estorno VARCHAR(1),    
 @p_codigo_lanc VARCHAR(MAX),    
 @p_databaixa_ini DATETIME,    
 @p_databaixa_fim DATETIME,    
 @p_dataref_ini DATETIME,    
 @p_dataref_fim DATETIME,    
 @p_tipo_emissao T_CODIGO    
)      
AS      
      
-- [INÍCIO]                
BEGIN    
    
 -- Verifica se todos os códigos de lançamento foram informados,    
 -- caso sim considera como se o parâmetro não estivesse sendo passado, para    
 -- evitar que items com o código de lançamento vazio sejam ignorados    
 DECLARE @v_todos_cod_lanc VARCHAR(1)    
    
 IF NOT EXISTS ( SELECT 1    
     FROM LY_COD_LANC    
     WHERE NOT EXISTS ( SELECT 1 FROM dbo.fnMultiValue('I', @p_codigo_lanc, ',') WHERE LY_COD_LANC.CODIGO_LANC = ValorIni ) )    
 BEGIN    
   SET @v_todos_cod_lanc = 'S'    
 END    
 ELSE    
 BEGIN    
   SET @v_todos_cod_lanc = 'N'    
 END    
     
 IF @p_tipo_emissao = 'ANALITICO'    
 BEGIN    
  SELECT rb.UNIDADE,    
    CR.TIPO AS TIPO_CURSO,     
 CR.CURSO,-- ADD POR FABIO CORREIA DE JESUS SOLICITADO POR ANDRÉ BRITTO -- em 30-05-2017  
 CR.NOME,-- ADD POR FABIO CORREIA DE JESUS SOLICITADO POR ANDRÉ BRITTO -- em 30-05-2017 
 ISNULL(tr.TURMA,'') AS TURMA, --  ADD POR MIGUEL BARRETO SOLICITADO POR ANDRÉ BRITTO -- em 07-06-2017 
 ISNULL(do.NOME_COMPL,'') AS COORDENADOR_TURMA, --  ADD POR MIGUEL BARRETO SOLICITADO POR ANDRÉ BRITTO -- em 07-06-2017               
      rb.ALUNO,    
      al.NOME_COMPL AS NOME_ALUNO,    
      ue.NOME_COMP + ' - CNPJ: ' + dbo.fn_FormataNumeroCNPJ(ue.CGC) AS NOME_UNIDADE,    
      rb.ID_BAIXA,    
      rb.COBRANCA,    
      CASE cob.NUM_COBRANCA    
     WHEN 1 THEN 'MENSALIDADE'    
     WHEN 2 THEN 'SERVICO'    
     WHEN 3 THEN 'ACORDO'    
     WHEN 4 THEN 'OUTROS'    
     WHEN 5 THEN 'CHEQUE DEVOLVIDO'    
     ELSE NULL END AS TIPO_COBRANCA,    
      rb.RESP,    
      CASE WHEN CPF_TITULAR IS NULL    
     THEN dbo.fn_FormataNumeroCNPJ(rf.CGC_TITULAR)    
     ELSE dbo.fn_FormataNumeroCPF(rf.CPF_TITULAR) END AS DOCUMENTO_TITULAR,    
      rf.TITULAR,    
      CASE WHEN rb.ERRO_MOV_ORIGEM IS NOT NULL    
     THEN (SELECT MAX(DT_REGISTRO_ITEM)    
        FROM AY_RESUMO_ATO    
        WHERE LANC_CRED = rb.ID_BAIXA    
       AND ERRO_MOV_ORIGEM = rb.ERRO_MOV_ORIGEM)    
     ELSE rb.DATACONTAB END AS DATACONTAB,    
      CASE WHEN rb.ESTORNO = 'S' THEN 'ESTORNO DE ' ELSE '' END +    
     CASE WHEN rb.ERRO_MOV_ORIGEM IS NOT NULL THEN 'DNI' ELSE rb.TIPO_BAIXA END +    
     CASE WHEN rb.ADIANTAMENTO = 'S' THEN ' ADIANTADO' ELSE '' END AS TIPO_BAIXA,    
      rb.TIPO_RECEBIMENTO,    
      RB.TIPO_CRED,    
      rb.ESTORNO,    
      rb.ADIANTAMENTO,    
      (SELECT SUM(VALOR_BRUTO) FROM AY_VW_FATURAMENTO WHERE COBRANCA = rb.COBRANCA) AS VALOR_COBRANCA,    
      -1 * rb.VALOR_RECEBIDO AS VALOR_RECEBIDO,    
      -1 * rb.VALOR_BAIXADO AS VALOR_BAIXADO,    
      -1 * rb.VALOR_DESCONTO AS VALOR_DESCONTO,    
      rb.VALOR_COB_ENCARGO,    
      -1 * rb.VALOR_BAIXADO_ENCARGO AS VALOR_BAIXADO_ENCARGO,    
      -1 * rb.VALOR_DESCONTO_ENCARGO AS VALOR_DESCONTO_ENCARGO,    
      -1 * rb.VALOR_A_MAIOR AS VALOR_A_MAIOR,    
      (SELECT MAX(DT_VENC) FROM AY_VW_FATURAMENTO WHERE COBRANCA = rb.COBRANCA) AS DATAVENCTO,    
      (SELECT MAX(DT_VENC_ORIG) FROM AY_VW_FATURAMENTO WHERE COBRANCA = rb.COBRANCA) AS DATAVENCTO_ORIG,    
      (SELECT MAX(CONVERT(DATETIME, '01/' + STR(MES_REF) + '/' + STR(ANO_REF), 103)) FROM AY_VW_FATURAMENTO WHERE COBRANCA = rb.COBRANCA) AS DATAREF    
  FROM AY_VW_RESUMO_BAIXA rb JOIN    
    LY_RESP_FINAN rf on (rb.RESP = rf.RESP) JOIN    
    LY_COBRANCA cob ON rb.COBRANCA = cob.COBRANCA JOIN    
    LY_UNIDADE_ENSINO ue ON rb.UNIDADE = ue.UNIDADE_ENS JOIN    
    LY_ALUNO al ON rb.ALUNO = al.ALUNO JOIN    
    LY_CURSO CR ON CR.CURSO = AL.CURSO LEFT JOIN
    LY_TURMA tr ON tr.TURMA = AL.TURMA_PREF LEFT JOIN
    LY_DOCENTE do ON do.NUM_FUNC = tr.NUM_FUNC  
  WHERE 1=1 AND CR.TIPO IN ('POS-GRADUACAO','EXTENSAO') AND rb.ESTORNO = 'N'
	AND ( @p_unid_resp IS NULL OR (@p_unid_resp IS NOT NULL AND rb.UNIDADE = @p_unid_resp) )    
    AND ( @p_unid_fisica IS NULL OR (@p_unid_fisica IS NOT NULL AND rb.UNIDADE_FISICA = @p_unid_fisica) )    
    AND ( @p_curso IS NULL OR (@p_curso IS NOT NULL AND rb.CURSO = @p_curso) )    
    AND ( @p_databaixa_ini IS NULL OR (@p_databaixa_ini IS NOT NULL AND rb.DATACONTAB >= @p_databaixa_ini) )    
    AND ( @p_databaixa_fim IS NULL OR (@p_databaixa_fim IS NOT NULL AND rb.DATACONTAB <= @p_databaixa_fim) )    
    AND ( @p_dataref_ini IS NULL OR (@p_dataref_ini IS NOT NULL AND (SELECT MAX(CONVERT(DATETIME, '01/' + STR(MES_REF) + '/' + STR(ANO_REF), 103)) FROM AY_VW_FATURAMENTO WHERE COBRANCA = rb.COBRANCA) >= @p_dataref_ini) )    
    AND ( @p_dataref_fim IS NULL OR (@p_dataref_fim IS NOT NULL AND (SELECT MAX(CONVERT(DATETIME, '01/' + STR(MES_REF) + '/' + STR(ANO_REF), 103)) FROM AY_VW_FATURAMENTO WHERE COBRANCA = rb.COBRANCA) <= @p_dataref_fim) )    
    --AND ( @p_num_cobranca IS NULL OR (@p_num_cobranca IS NOT NULL AND cob.NUM_COBRANCA = @p_num_cobranca) )    
    --AND ( @p_banco IS NULL OR (@p_banco IS NOT NULL AND rb.BANCO = @p_banco) )    
    --AND ( @p_agencia IS NULL OR (@p_agencia IS NOT NULL AND rb.AGENCIA = @p_agencia) )    
    --AND ( @p_conta_banco IS NULL OR (@p_conta_banco IS NOT NULL AND rb.CONTA_BANCO = @p_conta_banco) )    
    AND ( @p_tipo_cred IS NULL OR (@p_tipo_cred IS NOT NULL AND rb.TIPO_CRED = @p_tipo_cred) )    
    AND ( @p_tipo_baixa IS NULL OR (@p_tipo_baixa IS NOT NULL AND @p_tipo_baixa = CASE WHEN rb.ERRO_MOV_ORIGEM IS NOT NULL THEN 'DNI' ELSE ISNULL(rb.TIPO_BAIXA, '') END) )    
    AND ( @p_tipo_recebimento IS NULL OR (@p_tipo_recebimento IS NOT NULL AND rb.TIPO_RECEBIMENTO = @p_tipo_recebimento) )    
    --AND ( @p_estorno IS NULL OR (@p_estorno IS NOT NULL AND rb.ESTORNO = @p_estorno) )    
    --AND ( @p_cpfoucnpj_resp IS NULL OR ( @p_cpfoucnpj_resp IS NOT NULL AND ( RF.CPF_TITULAR = @p_cpfoucnpj_resp OR RF.CGC_TITULAR = @p_cpfoucnpj_resp )) )    
    --AND ( @p_nome_resp IS NULL OR (@p_nome_resp IS NOT NULL AND rf.TITULAR LIKE '%' + @p_nome_resp + '%') )    
    AND ( @p_codigo_lanc IS NULL OR @v_todos_cod_lanc = 'S' OR EXISTS ( SELECT 1    
                     FROM AY_RESUMO_ATO ra    
                     WHERE ra.COBRANCA = rb.COBRANCA    
                    AND EXISTS ( SELECT 1 FROM dbo.fnMultiValue('I', @p_codigo_lanc, ',') WHERE ValorIni = ra.CODIGO_LANC AND ra.CODIGO_LANC IN ('Acordo','MS') ) ) )    
  ORDER BY rf.TITULAR,    
     rb.COBRANCA,    
     rb.DATACONTAB    
 END    
 ELSE     
     
 IF @p_tipo_emissao = 'SINTETICO'    
 BEGIN    
  SELECT UNIDADE    
    , NOME_UNIDADE    
    , TIPO_CURSO  
 , CURSO -- ADD POR FABIO CORREIA DE JESUS SOLICITADO POR ANDRÉ BRITTO -- em 30-05-2017   
 , NOME -- ADD POR FABIO CORREIA DE JESUS SOLICITADO POR ANDRÉ BRITTO -- em 30-05-2017 
 , ISNULL(TURMA,'') AS TURMA--  ADD POR MIGUEL BARRETO SOLICITADO POR ANDRÉ BRITTO -- em 07-06-2017 
, ISNULL(NOME_COMPL,'') AS COORDENADOR_TURMA --  ADD POR MIGUEL BARRETO SOLICITADO POR ANDRÉ BRITTO -- em 07-06-2017     
    , DATACONTAB    
    , TIPO_COBRANCA    
    , TIPO_BAIXA    
    , TIPO_RECEBIMENTO    
    , TIPO_CRED    
    , ESTORNO    
    , ADIANTAMENTO    
    , SUM(VALOR_RECEBIDO) AS VALOR_RECEBIDO    
    , SUM(VALOR_BAIXADO) AS VALOR_BAIXADO    
    , SUM(VALOR_DESCONTO) AS VALOR_DESCONTO    
    , SUM(VALOR_COB_ENCARGO) AS VALOR_COB_ENCARGO    
    , SUM(VALOR_BAIXADO_ENCARGO) AS VALOR_BAIXADO_ENCARGO    
    , SUM(VALOR_DESCONTO_ENCARGO) AS VALOR_DESCONTO_ENCARGO    
    , SUM(VALOR_A_MAIOR) AS VALOR_A_MAIOR    
  FROM     
  (    
    SELECT rb.UNIDADE,  
        CR.CURSO,   
     CR.NOME,
     TR.TURMA,
     tr.NUM_FUNC,
     do.NOME_COMPL,   
        ue.NOME_COMP + ' - CNPJ: ' + dbo.fn_FormataNumeroCNPJ(ue.CGC) AS NOME_UNIDADE,    
        CR.TIPO AS TIPO_CURSO,    
        CASE cob.NUM_COBRANCA    
       WHEN 1 THEN 'MENSALIDADE'    
       WHEN 2 THEN 'SERVICO'    
       WHEN 3 THEN 'ACORDO'    
       WHEN 4 THEN 'OUTROS'    
       WHEN 5 THEN 'CHEQUE DEVOLVIDO'    
       ELSE NULL END AS TIPO_COBRANCA,    
       -- CASE WHEN rb.ERRO_MOV_ORIGEM IS NOT NULL    
       --THEN (SELECT MAX(DT_REGISTRO_ITEM)    
       --   FROM AY_RESUMO_ATO    
       --   WHERE LANC_CRED = rb.ID_BAIXA    
       --  AND ERRO_MOV_ORIGEM = rb.ERRO_MOV_ORIGEM)    
       --ELSE rb.DATACONTAB END AS DATACONTAB,    
       -- CASE WHEN rb.ESTORNO = 'S' THEN 'ESTORNO DE ' ELSE '' END +    
       --CASE WHEN rb.ERRO_MOV_ORIGEM IS NOT NULL THEN 'DNI' ELSE rb.TIPO_BAIXA END +    
       --CASE WHEN rb.ADIANTAMENTO = 'S' THEN ' ADIANTADO' ELSE '' END AS TIPO_BAIXA,    
        RB.DATACONTAB,    
        CASE WHEN rb.ESTORNO = 'S' THEN 'ESTORNO DE ' ELSE '' END +    
      CASE WHEN rb.ERRO_MOV_ORIGEM IS NOT NULL THEN 'DNI' ELSE rb.TIPO_BAIXA END +    
      CASE WHEN rb.ADIANTAMENTO = 'S' THEN ' ADIANTADO' ELSE '' END AS TIPO_BAIXA,    
        rb.TIPO_RECEBIMENTO,    
        RB.TIPO_CRED,    
        rb.ESTORNO,    
        rb.ADIANTAMENTO,    
        --(SELECT SUM(VALOR_BRUTO) FROM AY_VW_FATURAMENTO WHERE COBRANCA = rb.COBRANCA) AS VALOR_COBRANCA,    
        -1 * rb.VALOR_RECEBIDO AS VALOR_RECEBIDO,    
        -1 * rb.VALOR_BAIXADO AS VALOR_BAIXADO,    
        -1 * rb.VALOR_DESCONTO AS VALOR_DESCONTO,    
        rb.VALOR_COB_ENCARGO,    
        -1 * rb.VALOR_BAIXADO_ENCARGO AS VALOR_BAIXADO_ENCARGO,    
        -1 * rb.VALOR_DESCONTO_ENCARGO AS VALOR_DESCONTO_ENCARGO,    
        -1 * rb.VALOR_A_MAIOR AS VALOR_A_MAIOR--,    
        --(SELECT MAX(DT_VENC) FROM AY_VW_FATURAMENTO WHERE COBRANCA = rb.COBRANCA) AS DATAVENCTO,    
        --(SELECT MAX(DT_VENC_ORIG) FROM AY_VW_FATURAMENTO WHERE COBRANCA = rb.COBRANCA) AS DATAVENCTO_ORIG--,    
        --(SELECT MAX(CONVERT(DATETIME, '01/' + STR(MES_REF) + '/' + STR(ANO_REF), 103)) FROM AY_VW_FATURAMENTO WHERE COBRANCA = rb.COBRANCA) AS DATAREF    
    FROM AY_VW_RESUMO_BAIXA rb JOIN    
      LY_RESP_FINAN rf on (rb.RESP = rf.RESP) JOIN    
      LY_COBRANCA cob ON rb.COBRANCA = cob.COBRANCA JOIN    
      LY_UNIDADE_ENSINO ue ON rb.UNIDADE = ue.UNIDADE_ENS JOIN    
      LY_ALUNO al ON rb.ALUNO = al.ALUNO JOIN    
      LY_CURSO CR ON CR.CURSO = AL.CURSO LEFT JOIN
      LY_TURMA tr ON tr.TURMA = AL.TURMA_PREF LEFT JOIN
      LY_DOCENTE do ON do.NUM_FUNC = tr.NUM_FUNC   
    WHERE 1=1 AND CR.TIPO IN ('POS-GRADUACAO','EXTENSAO') AND rb.ESTORNO = 'N'
	  AND ( @p_unid_resp IS NULL OR (@p_unid_resp IS NOT NULL AND rb.UNIDADE = @p_unid_resp) )    
      AND ( @p_unid_fisica IS NULL OR (@p_unid_fisica IS NOT NULL AND rb.UNIDADE_FISICA = @p_unid_fisica) )    
      AND ( @p_curso IS NULL OR (@p_curso IS NOT NULL AND rb.CURSO = @p_curso) )    
      AND ( @p_databaixa_ini IS NULL OR (@p_databaixa_ini IS NOT NULL AND rb.DATACONTAB >= @p_databaixa_ini) )    
      AND ( @p_databaixa_fim IS NULL OR (@p_databaixa_fim IS NOT NULL AND rb.DATACONTAB <= @p_databaixa_fim) )    
      AND ( @p_dataref_ini IS NULL OR (@p_dataref_ini IS NOT NULL AND (SELECT MAX(CONVERT(DATETIME, '01/' + STR(MES_REF) + '/' + STR(ANO_REF), 103)) FROM AY_VW_FATURAMENTO WHERE COBRANCA = rb.COBRANCA) >= @p_dataref_ini) )    
      AND ( @p_dataref_fim IS NULL OR (@p_dataref_fim IS NOT NULL AND (SELECT MAX(CONVERT(DATETIME, '01/' + STR(MES_REF) + '/' + STR(ANO_REF), 103)) FROM AY_VW_FATURAMENTO WHERE COBRANCA = rb.COBRANCA) <= @p_dataref_fim) )    
      --AND ( @p_num_cobranca IS NULL OR (@p_num_cobranca IS NOT NULL AND cob.NUM_COBRANCA = @p_num_cobranca) )    
      --AND ( @p_banco IS NULL OR (@p_banco IS NOT NULL AND rb.BANCO = @p_banco) )    
      --AND ( @p_agencia IS NULL OR (@p_agencia IS NOT NULL AND rb.AGENCIA = @p_agencia) )    
      --AND ( @p_conta_banco IS NULL OR (@p_conta_banco IS NOT NULL AND rb.CONTA_BANCO = @p_conta_banco) )    
      AND ( @p_tipo_cred IS NULL OR (@p_tipo_cred IS NOT NULL AND rb.TIPO_CRED = @p_tipo_cred) )    
      AND ( @p_tipo_baixa IS NULL OR (@p_tipo_baixa IS NOT NULL AND @p_tipo_baixa = CASE WHEN rb.ERRO_MOV_ORIGEM IS NOT NULL THEN 'DNI' ELSE ISNULL(rb.TIPO_BAIXA, '') END) )    
      AND ( @p_tipo_recebimento IS NULL OR (@p_tipo_recebimento IS NOT NULL AND rb.TIPO_RECEBIMENTO = @p_tipo_recebimento) )    
      --AND ( @p_estorno IS NULL OR (@p_estorno IS NOT NULL AND rb.ESTORNO = @p_estorno) )    
      --AND ( @p_cpfoucnpj_resp IS NULL OR ( @p_cpfoucnpj_resp IS NOT NULL AND ( RF.CPF_TITULAR = @p_cpfoucnpj_resp OR RF.CGC_TITULAR = @p_cpfoucnpj_resp )) )    
      --AND ( @p_nome_resp IS NULL OR (@p_nome_resp IS NOT NULL AND rf.TITULAR LIKE '%' + @p_nome_resp + '%') )    
      AND ( @p_codigo_lanc IS NULL OR @v_todos_cod_lanc = 'S' OR EXISTS ( SELECT 1    
                       FROM AY_RESUMO_ATO ra    
                       WHERE ra.COBRANCA = rb.COBRANCA    
                      AND EXISTS ( SELECT 1 FROM dbo.fnMultiValue('I', @p_codigo_lanc, ',') WHERE ValorIni = ra.CODIGO_LANC ) AND ra.CODIGO_LANC IN ('Acordo','MS') ) )    
    ) AS TB    
  GROUP BY UNIDADE    
    , NOME_UNIDADE  
 , CURSO    
 , NOME
 , TURMA
 , NOME_COMPL  
    , TIPO_CURSO    
    , TIPO_COBRANCA    
    , TIPO_BAIXA    
    , TIPO_RECEBIMENTO    
    , TIPO_CRED    
    , ESTORNO    
    , ADIANTAMENTO    
    , DATACONTAB    
  ORDER BY UNIDADE    
    , NOME_UNIDADE    
    , TIPO_CURSO    
    , DATACONTAB    
    , TIPO_COBRANCA    
 END    
END                
-- [FIM]    
    
RETURN 

