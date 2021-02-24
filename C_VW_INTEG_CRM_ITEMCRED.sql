-- --------------------------------------------------
-- View: C_VW_INTEG_CRM_ITEMCRED
-- --------------------------------------------------
IF DBO.fn_ExisteView('C_VW_INTEG_CRM_ITEMCRED') = 'S'
  BEGIN
	DROP VIEW C_VW_INTEG_CRM_ITEMCRED
  END
GO

CREATE VIEW C_VW_INTEG_CRM_ITEMCRED  
AS  
	SELECT ife.ID_FILA_EVENTOS  
	     , iclv.CANDIDATO AS Inscricao  
	     , ife.DATA_INCLUSAO AS DataMatricula  
	     , iclv.CodEscola AS CodEscola  
	     , iclv.ANO AS Ano 
	     , iclv.PERIODO AS Periodo   
	     , iclv.REGIME AS Regime  
	     , iclv.CODCURSO AS Curso   
	     , iclv.CODTURNO AS CodTurno  
	     , iclv.CODCURRICULO AS Curriculo  
	     , iclv.CODCAMPUS AS CodCampus 
	     , (SELECT TOP 1 1 FROM LY_BOLSA B WHERE B.ALUNO = A.ALUNO) AS Bolsa  
	FROM LY_INTEGRACAO_FILA_EVENTOS ife  
	INNER JOIN C_INTEGRA_CRM_LYCEUM_VEST iclv ON ife.CHAVE_1 = iclv.CONCURSO 
	                                         AND ife.CHAVE_2 = iclv.CODCURSO 
	                                         AND ife.CHAVE_3 = iclv.CANDIDATO 
	LEFT OUTER JOIN LY_ALUNO a on iclv.CANDIDATO = a.CANDIDATO
	WHERE ife.SISTEMA_DESTINO = 'FTC - CRM'  
	AND   (ife.OBJETO = 'LY_ITEM_CRED' OR ife.OBJETO = 'LY_COBRANCA' )
	AND   ife.DATA_INTEGRACAO IS NULL  
	AND   ife.DATA_ERRO IS NULL  
	AND   ISNULL(ife.IGNORAR, 'N') = 'N'
GO
