USE LYCEUM
GO  

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.Relat_P_A_UnidadeEnsino'))
   exec('CREATE PROCEDURE [dbo].[Relat_P_A_UnidadeEnsino] AS BEGIN SET NOCOUNT OFF; END')
GO 

ALTER PROCEDURE [dbo].[Relat_P_A_UnidadeEnsino]    
AS    

BEGIN    
   SELECT DISTINCT VW.FACULDADE AS CODIGO, (VW.FACULDADE + ' - ' + VW.NOME_COMP + (CASE WHEN VW.CGC IS NULL THEN '' ELSE ' - CNPJ: ' + dbo.fn_FormataNumeroCNPJ(VW.CGC) END)) AS DESCR    
   FROM VW_FACULDADE VW    
   JOIN LY_CURSO C ON C.FACULDADE = VW.FACULDADE  
   WHERE VW.ENSINO = 'S'  AND C.TIPO IN ('GRADUACAO','MESTRADO','TECNOLOGO')
      UNION  
   SELECT NULL AS CODIGO, 'TODAS' AS DESCR  
END