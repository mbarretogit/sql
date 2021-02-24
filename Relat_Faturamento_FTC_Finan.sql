--Relat_Faturamento_FTC_Finan  '05','FTC-VIC',NULL,'399',NULL,NULL,NULL,'S',NULL,NULL,NULL,NULL,'2018-01-01','2018-03-31'

USE LYCEUM
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.Relat_Faturamento_FTC_Finan'))
   exec('CREATE PROCEDURE [dbo].[Relat_Faturamento_FTC_Finan] AS BEGIN SET NOCOUNT OFF; END')
GO

ALTER PROCEDURE dbo.Relat_Faturamento_FTC_Finan    
(      
 @p_unidade VARCHAR(20),    
 @p_unid_fisica VARCHAR(20),
 @p_tipo VARCHAR(20),    
 @p_curso VARCHAR(20),    
 @p_cpfoucnpj_resp VARCHAR(19),    
 @p_codigo_lanc VARCHAR(MAX),    
 @p_num_cobranca NUMERIC(3,0),    
 @p_exibe_estornadas VARCHAR(1),    
 @p_datageracao_ini DATETIME,    
 @p_datageracao_fim DATETIME,
 @p_datavenc_ini DATETIME,    
 @p_datavenc_fim DATETIME,    
 @p_dataref_ini DATETIME,    
 @p_dataref_fim DATETIME  
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
  
/*DECLARE  
 @p_datacontab_ini DATETIME,  
 @p_datacontab_fim DATETIME,  
 @p_codigo_lanc VARCHAR(MAX)
  
 set @p_datacontab_ini ='2017-08-23'  
 set @p_datacontab_fim ='2017-08-23'*/  
     
 SELECT DISTINCT    
     cob.RESP,    
     cob.ALUNO,    
     cob.COBRANCA,    
     cur.FACULDADE AS UNIDADE,   
	 cur.CURSO,  
	 (SELECT TOP 1 ISNULL(CCUSTO.CENTRO_DE_CUSTO,'')  FROM  LY_CENTRO_DE_CUSTO CCUSTO WHERE CCUSTO.CURSO=COB.CURSO) CENTRO_DE_CUSTO,  
	 CUR.NOME AS NOME_CURSO,  
	 CUR.TIPO AS TIPO_CURSO,  
  	(SELECT ISNULL(SUM(VALOR),0) FROM LY_ITEM_LANC IL WHERE IL.COBRANCA = COB.COBRANCA AND IL.NUM_BOLSA IS NULL AND IL.ITEM_ESTORNADO IS NULL) AS [VALOR_BRUTO_TITULO]
	, (SELECT ISNULL(SUM(VALOR),0) FROM LY_ITEM_LANC IL WHERE IL.COBRANCA = COB.COBRANCA AND IL.ITEM_ESTORNADO IS NOT NULL)						AS [VALOR_ESTORNOS]
	, (SELECT ISNULL(SUM(VALOR),0) FROM LY_ITEM_LANC IL WHERE IL.COBRANCA = COB.COBRANCA AND IL.NUM_BOLSA IS NOT NULL AND IL.ITEM_ESTORNADO IS NULL)	AS [VALOR_BOLSAS]
	, (SELECT ISNULL(SUM(VALOR),0) FROM LY_ITEM_LANC IL WHERE IL.COBRANCA = COB.COBRANCA)														AS [VALOR_FATURADO]
	, (SELECT ISNULL(SUM(VALOR),0) FROM LY_ITEM_CRED IC1 WHERE IC1.COBRANCA = COB.COBRANCA AND IC1.TIPO_ENCARGO = 'MULTA')						AS [MULTA]
	, (SELECT ISNULL(SUM(VALOR),0) FROM LY_ITEM_CRED IC4 WHERE IC4.COBRANCA = COB.COBRANCA AND IC4.TIPO_ENCARGO = 'PERDEBOLSA')					AS [PERDEBOLSA]
	, (SELECT ISNULL(SUM(VALOR),0) FROM LY_ITEM_CRED IC2 WHERE IC2.COBRANCA = COB.COBRANCA AND IC2.TIPO_ENCARGO = 'JUROS')						AS [JUROS]
	, (SELECT ISNULL(SUM(VALOR),0) FROM LY_ITEM_CRED IC3 WHERE IC3.COBRANCA = COB.COBRANCA AND IC3.TIPODESCONTO IN ('Acréscimo','Concedido','DescBanco','PagtoAntecipado'))	AS [DESCONTO]
	, (SELECT ISNULL(SUM(VALOR),0) FROM LY_ITEM_CRED IC3 WHERE IC3.COBRANCA = COB.COBRANCA AND IC3.TIPODESCONTO IS NULL AND IC3.TIPO_ENCARGO IS NULL)*-1						AS [VALOR_PAGO] 
	,(SELECT TOP 1 VWC.VALOR FROM  VW_COBRANCA VWC WHERE VWC.COBRANCA=cob.COBRANCA AND VWC.ALUNO=cob.ALUNO AND VWC.RESP=cob.RESP ) AS SALDO,  
	(SELECT  TOP 1  CODIGO_LANC FROM  LY_ITEM_LANC  IC WHERE IC.COBRANCA=cob.COBRANCA) AS CODIGO_LANC,    
        ue.NOME_COMP + ' - CNPJ: ' + dbo.fn_FormataNumeroCNPJ(ue.CGC) AS NOME_UNIDADE,    
        rf.TITULAR,    
        ISNULL(dbo.fn_FormataNumeroCNPJ(rf.CGC_TITULAR), dbo.fn_FormataNumeroCPF(rf.CPF_TITULAR)) AS DOCUMENTO_TITULAR,    
     al.NOME_COMPL AS NOME_ALUNO,    
     CASE cob.NUM_COBRANCA    
             WHEN 1 THEN 'MENSALIDADE'    
             WHEN 2 THEN 'SERVICO'    
             WHEN 3 THEN 'ACORDO'    
             WHEN 4 THEN 'OUTROS'    
             WHEN 5 THEN 'CHEQUE DEVOLVIDO'    
             ELSE NULL END AS TIPO_COBRANCA,    
     MAX(cob.ESTORNO) COB_ESTORNADA,     
     ISNULL(MAX(cnfe.NUMERO_NFE),0) AS NUMERO_NFE,    
     MAX(cob.DATA_DE_GERACAO) DT_GERACAO_COB,    
     MAX(cob.DATA_DE_VENCIMENTO_ORIG) DT_VENC_ORIG,    
     MAX(CONVERT(DATETIME, '01/' + STR(cob.MES) + '/' + STR(cob.ANO), 103)) AS DATAREF,  
     MAX(cob.DATA_DE_VENCIMENTO) DT_VENC,   
  cob.data_de_faturamento DT_FATURAMENTO_COB 
 FROM LY_COBRANCA cob
 JOIN LY_CURSO CUR ON CUR.CURSO=cob.CURSO  
 JOIN LY_RESP_FINAN RF ON cob.RESP = RF.RESP    
 JOIN LY_UNIDADE_ENSINO ue ON cur.FACULDADE = ue.UNIDADE_ENS    
 JOIN LY_ALUNO al ON cob.ALUNO = al.ALUNO    
 LEFT JOIN LY_COBRANCA_NOTA_FISCAL cnfe ON cob.COBRANCA = cnfe.COBRANCA AND cnfe.LINK_RPS IS NOT NULL    
 WHERE 1=1      
    AND ( @p_unidade IS NULL OR (@p_unidade IS NOT NULL AND cur.FACULDADE = @p_unidade) )      
   AND ( @p_unid_fisica IS NULL OR (@p_unid_fisica IS NOT NULL AND cob.UNID_FISICA = @p_unid_fisica) )    
   AND ( @p_tipo IS NULL OR (@p_tipo IS NOT NULL AND cur.TIPO = @p_tipo) )    
   AND ( @p_curso IS NULL OR (@p_curso IS NOT NULL AND cob.CURSO = @p_curso) )    
   AND ((@p_num_cobranca IS NOT NULL AND cob.NUM_COBRANCA = @p_num_cobranca) OR @p_num_cobranca is null)   
   AND ( @p_datageracao_ini IS NULL OR (@p_datageracao_ini IS NOT NULL AND cob.DATA_DE_GERACAO >= @p_datageracao_ini) )    
   AND ( @p_datageracao_fim IS NULL OR (@p_datageracao_fim IS NOT NULL AND cob.DATA_DE_GERACAO <= @p_datageracao_fim) )    
   AND ( @p_datavenc_ini IS NULL OR (@p_datavenc_ini IS NOT NULL AND cob.DATA_DE_VENCIMENTO_ORIG >= @p_datavenc_ini) )    
   AND ( @p_datavenc_fim IS NULL OR (@p_datavenc_fim IS NOT NULL AND cob.DATA_DE_VENCIMENTO_ORIG <= @p_datavenc_fim) ) 
   --AND ( @p_dataref_ini IS NULL OR (@p_dataref_ini IS NOT NULL AND CONVERT(DATETIME, '01/' + STR(cob.MES) + '/' + STR(cob.ANO), 103) >= @p_dataref_ini) )    
   --AND ( @p_dataref_fim IS NULL OR (@p_dataref_fim IS NOT NULL AND CONVERT(DATETIME, '01/' + STR(cob.MES) + '/' + STR(cob.ANO), 103) <= @p_dataref_fim) )     
   AND (COB.ANO BETWEEN YEAR(@p_dataref_ini) AND YEAR(@p_dataref_fim))
AND (COB.MES BETWEEN MONTH(@p_dataref_ini) AND MONTH(@p_dataref_fim))
   AND ( @p_cpfoucnpj_resp IS NULL OR ( @p_cpfoucnpj_resp IS NOT NULL AND ( RF.CPF_TITULAR = @p_cpfoucnpj_resp OR    
                                                                            RF.CGC_TITULAR = @p_cpfoucnpj_resp )) )    
   AND ( @p_codigo_lanc IS NULL OR @v_todos_cod_lanc = 'S' OR EXISTS ( SELECT 1    
                   FROM LY_ITEM_LANC IL    
                   WHERE 1=1  
                   AND IL.COBRANCA = cob.COBRANCA                       
                   AND EXISTS ( SELECT 1 FROM dbo.fnMultiValue('I', @p_codigo_lanc, ',') WHERE ValorIni = IL.CODIGO_LANC )   
                  )   
       )  
     GROUP BY   
     cob.RESP,    
     cob.ALUNO,    
     cob.COBRANCA,    
     cur.FACULDADE,    
	 cob.CURSO,
	 CUR.CURSO,  
	 cob.ESTORNO,  
	 CUR.NOME,  
	 cur.TIPO,  
	 ue.NOME_COMP,    
	 ue.CGC,    
	 rf.TITULAR,    
	 ISNULL(dbo.fn_FormataNumeroCNPJ(rf.CGC_TITULAR), dbo.fn_FormataNumeroCPF(rf.CPF_TITULAR)),    
	 al.NOME_COMPL,    
	 cob.NUM_COBRANCA,  
	 cob.DATA_DE_FATURAMENTO

END                
-- [FIM]