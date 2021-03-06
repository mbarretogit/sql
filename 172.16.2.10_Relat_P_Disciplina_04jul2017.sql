USE LYCEUM
GO
  
ALTER PROCEDURE [dbo].[Relat_P_Disciplina]  
(  
   @p_unidade VARCHAR(20)  
)  
  
AS  
BEGIN  
  
SELECT d.DISCIPLINA AS CODIGO, (d.DISCIPLINA + ' - ' + d.NOME) AS DESCR  
FROM VW_DISCIPLINA d   
WHERE FACULDADE = CASE WHEN @p_unidade IS NULL THEN '04' ELSE '04' END  
UNION  
SELECT NULL AS CODIGO, 'TODAS' AS DESCR    
ORDER BY d.DISCIPLINA  
  
END  
GO


delete from LY_CUSTOM_CLIENTE
where NOME = 'Relat_P_Disciplina'
and IDENTIFICACAO_CODIGO = '0001'
go

INSERT INTO LY_CUSTOM_CLIENTE
(NOME, IDENTIFICACAO_CODIGO, AUTOR, DATA_CRIACAO, OBJETIVO, SOLICITADO_POR, ATIVO, TIPOCOMPONENTE, TIPO, CLIENTE)
SELECT
  'Relat_P_Disciplina' NOME
, '0001' IDENTIFICAO_CODIGO
, 'Miguel' AUTOR
, '2017-07-04' DATA_CRIACAO
, 'Corre��o do par�mtetro, para fixar a unidade 04 como busca nas disciplinas' OBJETIVO
, 'TI - Desenvolvimento' SOLICITADO_POR
, 'S' ATIVO
, 'PROCEDURE' TIPOCOMPONENTE
, 'CLIENTE' TIPO
, 'FTC' CLIENTE
GO   

