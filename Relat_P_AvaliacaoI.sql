USE LYCEUM
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.Relat_P_AvaliacaoI'))
   exec('CREATE PROCEDURE [dbo].[Relat_P_AvaliacaoI] AS BEGIN SET NOCOUNT OFF; END')
GO
  
ALTER PROCEDURE [dbo].[Relat_P_AvaliacaoI]   

AS    
BEGIN    
    
SELECT	TIPO_QUESTIONARIO AS CODIGO
		,DESCRICAO AS DESCR 
FROM LY_TIPO_QUESTIONARIO
WHERE TIPO_QUESTIONARIO IN ('Av Institucional I','Av Institucional II','Av Institucional III')

ORDER BY 1    
    
END; 

