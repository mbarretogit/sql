USE LYCEUM
GO

--exec FTC_Relat_Inadimplentes '03',NULL,NULL,'2017-01-01','2017-07-20',NULL,NULL

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.FTC_Relat_Inadimplentes'))
   exec('CREATE PROCEDURE [dbo].[FTC_Relat_Inadimplentes] AS BEGIN SET NOCOUNT OFF; END')
GO 

   
ALTER PROCEDURE [dbo].[FTC_Relat_Inadimplentes]      
(      
  @p_unidade AS T_CODIGO,      
  @p_unidade_fisica AS T_CODIGO,      
  @p_codigo_lanc AS VARCHAR(MAX),      
  @p_datavenc_ini AS DATETIME,      
  @p_datavenc_fim AS DATETIME,    
  @p_aluno VARCHAR(MAX),   
  @p_resp VARCHAR(MAX)   
)      
      
AS      
BEGIN 

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
  

  /*
  DECLARE @p_unidade AS T_CODIGO      
  DECLARE @p_unidade_fisica AS T_CODIGO      
  DECLARE @p_codigo_lanc AS T_CODIGO
  DECLARE @p_datavenc_ini AS DATETIME      
  DECLARE @p_datavenc_fim AS DATETIME    
  DECLARE @p_aluno VARCHAR(MAX)   
  DECLARE @p_resp VARCHAR(MAX)   
  DECLARE @p_tipo VARCHAR(10)    

  SET @p_unidade = '03'
  SET @p_unidade_fisica = NULL
  SET @p_codigo_lanc = NULL
  SET @p_datavenc_ini = '2017-01-01'
  SET @p_datavenc_fim = '2017-07-20'
  SET @p_aluno = NULL
  SET @p_resp = NULL
  SET @p_tipo = 'MS'
  */

     
CREATE TABLE #FBRUTO                
(                
  RESPONSAVEL VARCHAR(20) COLLATE Latin1_General_CI_AI,              
  COBRANCA NUMERIC(10),              
  NOME_RESPONSAVEL VARCHAR(200) COLLATE Latin1_General_CI_AI,                
  UNIDADE_FISICA VARCHAR(100) COLLATE Latin1_General_CI_AI,                
  ALUNO VARCHAR(20) COLLATE Latin1_General_CI_AI,                
  NOME_ALUNO VARCHAR(200) COLLATE Latin1_General_CI_AI,                
  CURSO VARCHAR(20) COLLATE Latin1_General_CI_AI,                
  NOME_CURSO VARCHAR(200) COLLATE Latin1_General_CI_AI,                 
  TELEFONES VARCHAR(200) COLLATE Latin1_General_CI_AI,                
  DATA_VENCTO DATETIME,                
  DATA_VENCTO_ATUAL DATETIME,                
  ANO NUMERIC(4,0),                
  MES NUMERIC(2,0),                
  CODIGOS_LANCAMENTO VARCHAR(400) COLLATE Latin1_General_CI_AI,                
  VALOR_BASE NUMERIC(12,2),                
  VALOR_DESCONTOS NUMERIC(12,2),                
  VALOR_LIQUIDO NUMERIC(12,2),                
  VALOR_PAGO NUMERIC(12,2),                
  PERDA_BOLSA NUMERIC(12,2),                  
  VALOR_JUROS NUMERIC(12,2),                
  VALOR_MULTA NUMERIC(12,2),                
  VALOR_PAGAR NUMERIC(12,2),      
  TOTAL_ENCARGOS NUMERIC (12,2),                 
  TOTAL_DESCONTOS NUMERIC (12,2)      
)                
 CREATE INDEX IX_COBRANCA ON #FBRUTO(COBRANCA)    
 CREATE INDEX IX_NOME_RESP ON #FBRUTO(NOME_RESPONSAVEL)     
 CREATE INDEX IX_NOME_ALUNO ON #FBRUTO(NOME_ALUNO)     
    
/*    
 RESUMO:    
 POPULA TABELA TEMPORARIA COM AS COBRANÇAS EM ABERTO PARA DEPOIS PERCORRER ESTA TABELA E     
 CALCULAR OS VALORES DE ENCARGOS.    
*/    
              
             
BEGIN                
INSERT INTO #FBRUTO                
SELECT fb.RESP as RESPONSAVEL,              
       fb.COBRANCA,              
       rf.TITULAR as NOME_RESPONSAVEL,                
       f.NOME_COMP AS UNIDADE_FISICA,                
       fb.ALUNO,                
       a.NOME_COMPL AS NOME_ALUNO,                
       fb.CURSO,                
       c.NOME AS NOME_CURSO,                
       dbo.fnRelatConcatenaTelefones(a.PESSOA) AS TELEFONES,                
       fb.DATA_DE_VENCIMENTO AS DATA_VENCTO,                
	   fb.DATA_DE_VENCIMENTO AS DATA_VENCTO_ATUAL,                     
       fb.ANOREF as ANO,                
       fb.MESREF AS MES,                
       dbo.fnRelatConcatenaLancamentos(fb.COBRANCA) AS CODIGOS_LANCAMENTO,                
       ISNULL(SUM(fb.VALOR),0) AS VALOR_BASE,                
       (ISNULL(SUM(fb.VALOR),0) - dbo.fn_VW_Faturamento_Liquido(fb.COBRANCA,NULL,NULL)) AS VALOR_DESCONTOS,                
       dbo.fn_VW_Faturamento_Liquido(fb.COBRANCA,NULL,NULL) AS VALOR_LIQUIDO,                
       dbo.fn_VW_Receita_Liquida(fb.COBRANCA,NULL,NULL) +              
       dbo.fn_VW_Restituicao_Aplicada(fb.COBRANCA,NULL,NULL) AS VALOR_PAGO,                
       PERDA_BOLSA = NULL,                
       VALOR_JUROS = NULL,                
       VALOR_MULTA = NULL,                
       VALOR_PAGAR = NULL,   --Calculado diretamente no relatório para ganho de performance.  
       TOTAL_ENCARGOS = ISNULL((select sum(valor) as total_encargos from ly_item_Cred where tipo_encargo is not null and  cobranca = fb.COBRANCA),0),          
	   TOTAL_DESCONTOS = ISNULL((select sum(valor)*(-1) as total_encargos from ly_item_Cred where tipodesconto is not null and  cobranca = fb.COBRANCA),0)         
FROM VW_Faturamento_Bruto fb INNER JOIN                
     LY_CURSO c ON fb.CURSO = c.CURSO INNER JOIN    
     LY_ALUNO a ON fb.ALUNO = a.ALUNO INNER JOIN
	 LY_PESSOA p on a.PESSOA = p.pessoa INNER JOIN                
     LY_RESP_FINAN rf ON fb.RESP = rf.RESP LEFT OUTER JOIN                
     LY_FACULDADE f ON a.UNIDADE_FISICA = f.FACULDADE              
WHERE (@p_aluno IS NULL OR (@p_aluno IS NOT NULL AND @p_aluno = a.aluno)) AND        
	  (@p_resp is NULL OR (@p_resp IS NOT NULL AND @p_resp = rf.RESP)) AND             
      fb.UNIDADE_FISICA = ISNULL(@p_unidade_fisica, fb.UNIDADE_FISICA) AND                
      fb.DATA_DE_VENCIMENTO >= ISNULL(@p_datavenc_ini, fb.DATA_DE_VENCIMENTO) AND              
      fb.DATA_DE_VENCIMENTO <= ISNULL(@p_datavenc_fim, fb.DATA_DE_VENCIMENTO) 
	  AND ( @p_codigo_lanc IS NULL OR @v_todos_cod_lanc = 'S' OR EXISTS (	SELECT 1  
																			FROM LY_COBRANCA co
																			WHERE co.COBRANCA = fb.COBRANCA  
																			AND EXISTS ( SELECT 1 FROM dbo.fnMultiValue('I', @p_codigo_lanc, ',') WHERE ValorIni = fb.CODIGO_LANC ) ) )  
 and exists(  
 select 1   
 from ly_aluno a inner join ly_curso c on a.curso = c.curso   
 where a.aluno = fb.ALUNO   
 and faculdade= @p_unidade   
 )       
GROUP BY fb.RESP, fb.COBRANCA, rf.TITULAR, f.NOME_COMP, fb.ALUNO, a.PESSOA, a.NOME_COMPL, fb.CURSO, c.NOME, fb.DATA_DE_VENCIMENTO,fb.DATA_DE_VENCIMENTO, fb.ANOREF, fb.MESREF               
HAVING dbo.fn_VW_Pagaberto_ouPagmaior(fb.COBRANCA, NULL) > 0           
ORDER BY rf.TITULAR, a.NOME_COMPL, fb.ANOREF, fb.MESREF              
END              
    
    
----------------------------------------------------------                
--REALIZA CALCULO DOS ENCARGOS DAS COBRANÇAS EM ABERTO                
----------------------------------------------------------                
    
DECLARE @COBRANCA T_NUMERO    
DECLARE @SESSION_ID AS VARCHAR(40)    
    
    
SET @SESSION_ID = CAST(@@SPID AS VARCHAR(10)) + '_RELATORIO_INADIMPLENTES'    
    
    
DECLARE @VALOR_MULTA AS NUMERIC(12,2)    
DECLARE @VALOR_JUROS AS NUMERIC(12,2)    
DECLARE @VALOR_PERDA_BOLSA AS NUMERIC(12,2)    
DECLARE @DATA_PAGAMENTO AS T_DATA    
    
SET @DATA_PAGAMENTO = GETDATE()    
    
--CURSOR PARA COM QUE PEGA AS COBRANÇAS LISTADAS PARA QUE SEJA CALCULADO O ENCARGO    
DECLARE C_COBRANCAS CURSOR FOR     
 SELECT DISTINCT COBRANCA FROM #FBRUTO ORDER BY COBRANCA             
    
OPEN C_COBRANCAS     
FETCH NEXT FROM C_COBRANCAS INTO @COBRANCA    
    
WHILE @@FETCH_STATUS = 0    
BEGIN    
 --PARA CADA COBRANÇA FAÇA...    
 EXEC Calcula_Encargos @SESSION_ID, @COBRANCA, @DATA_PAGAMENTO    
 --OBTEM VALOR DE MULTA CALCULADO    
 SELECT @VALOR_MULTA = ISNULL(SUM(VALOR),0)     
  FROM LY_AUX_ITEM_CRED_OUT C INNER JOIN LY_TIPO_ENCARGOS E ON (C.TIPO_ENCARGO = E.TIPO_ENCARGO)    
    WHERE  SESSAO_ID = @SESSION_ID    
       AND COBRANCA = @COBRANCA    
       AND E.CATEGORIA = 'Multa'      
    
 --OBTEM VALOR DE JUROS CALCULADO    
 SELECT @VALOR_JUROS = ISNULL(SUM(VALOR),0)     
  FROM LY_AUX_ITEM_CRED_OUT C INNER JOIN LY_TIPO_ENCARGOS E ON (C.TIPO_ENCARGO = E.TIPO_ENCARGO)    
    WHERE  SESSAO_ID = @SESSION_ID    
       AND COBRANCA = @COBRANCA    
       AND E.CATEGORIA = 'Juros'      
    
 --OBTEM VALOR DE PERDA BOLSA CALCULADO    
 SELECT @VALOR_PERDA_BOLSA = ISNULL(SUM(VALOR),0)     
  FROM LY_AUX_ITEM_CRED_OUT C INNER JOIN LY_TIPO_ENCARGOS E ON (C.TIPO_ENCARGO = E.TIPO_ENCARGO)    
    WHERE  SESSAO_ID = @SESSION_ID    
       AND COBRANCA = @COBRANCA    
       AND E.CATEGORIA = 'PerdaBolsa'      
     
 --ATUALIZA ESSES CAMPOS NA TABELA    
 UPDATE #FBRUTO SET     
   VALOR_MULTA = @VALOR_MULTA    
   ,VALOR_JUROS = @VALOR_JUROS    
   ,PERDA_BOLSA = @VALOR_PERDA_BOLSA    
 WHERE COBRANCA = @COBRANCA    
    
 FETCH NEXT FROM C_COBRANCAS INTO @COBRANCA    
    
END    
    
    
    
CLOSE C_COBRANCAS    
DEALLOCATE C_COBRANCAS    
/*    
DECLARE @DATA_PAGAMENTO AS T_DATA    
SET @DATA_PAGAMENTO = GETDATE()    
EXEC Calcula_Encargos 'TESTE_12', '28416', @DATA_PAGAMENTO    
*/      
    
--DELETE DA TABELA TEMPORARIA UTILIZADA PELA procedure Calcula_Encargos    
DELETE FROM LY_AUX_ITEM_CRED_OUT WHERE SESSAO_ID = @SESSION_ID    
    
SELECT * FROM #FBRUTO ORDER BY NOME_RESPONSAVEL, NOME_ALUNO, ANO, MES              
    
      
        
END
GO      
    
delete from LY_CUSTOM_CLIENTE
where NOME = 'FTC_Relat_Inadimplentes'
and IDENTIFICACAO_CODIGO = '0002'
go

INSERT INTO LY_CUSTOM_CLIENTE
(NOME, IDENTIFICACAO_CODIGO, AUTOR, DATA_CRIACAO, OBJETIVO, SOLICITADO_POR, ATIVO, TIPOCOMPONENTE, TIPO, CLIENTE)
SELECT
  'FTC_Relat_Inadimplentes' NOME
, '0001' IDENTIFICAO_CODIGO
, 'Miguel' AUTOR
, '2018-08-15' DATA_CRIACAO
, 'Relatório de Inadimplentes' OBJETIVO
, 'Ana Paula Gomes' SOLICITADO_POR
, 'S' ATIVO
, 'PROCEDURE' TIPOCOMPONENTE
, 'CLIENTE' TIPO
, 'FTC' CLIENTE
GO  