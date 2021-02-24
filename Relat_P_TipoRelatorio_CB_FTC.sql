USE LYCEUM
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.Relat_P_TipoRelatorio_CB_FTC'))
   exec('CREATE PROCEDURE [dbo].[Relat_P_TipoRelatorio_CB_FTC] AS BEGIN SET NOCOUNT OFF; END')
GO 

ALTER PROCEDURE dbo.Relat_P_TipoRelatorio_CB_FTC    
  
AS    
   
-- [IN�CIO]            
BEGIN  
 SELECT 'MENSALIDADE' AS TIPO, 1 AS COD  
 UNION  
 SELECT 'SERVI�OS' AS TIPO, 2 AS COD  
 UNION  
 SELECT 'CHEQUES DEVOLVIDOS' AS TIPO, 3 AS COD  
 UNION  
 SELECT 'ACORDO' AS TIPO, 4 AS COD  
 UNION  
 SELECT 'FIES' AS TIPO, 5 AS COD  
 UNION  
 SELECT 'FINANCIAMENTO' AS TIPO, 6 AS COD  
 UNION  
 SELECT 'MULTA' AS TIPO, 7 AS COD  
 UNION  
 SELECT 'TODOS' AS TIPO, 8 AS COD  
 ORDER BY COD  
END  