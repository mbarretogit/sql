USE LYCEUM
GO

DELETE FROM HD_RELATORIO WHERE RELATORIO = 'FTC_RelatAvalInstPartic' AND GRUPORELAT = 'AvaliacaoAcademicaNG'
INSERT INTO HD_RELATORIO
VALUES('Lyceum','AvaliacaoAcademicaNG','FTC_RelatAvalInstPartic','Acompanhamento Avalia��o Docente','/Lyceum/AvaliacaoAcademicaNG/FTC_RelatAvalInstPartic','N',NULL,'sqlserver')
GO

--select * from HD_PARAMETRO_RELATORIO where RELATORIO = 'AlunosIngressantes'
DELETE FROM HD_PARAMETRO_RELATORIO WHERE RELATORIO = 'FTC_RelatAvalInstPartic'
INSERT INTO HD_PARAMETRO_RELATORIO
VALUES
('Lyceum','AvaliacaoAcademicaNG','FTC_RelatAvalInstPartic','p_avaliacaoq','1','5','Avalia��o:','S',NULL,'SP: Relat_P_Avaliacao()','CODIGO','DESCR','Avalia��o, Descri��o','N')
,('Lyceum','AvaliacaoAcademicaNG','FTC_RelatAvalInstPartic','p_aplicacao','2','5','Aplica��o','S',NULL,'SP: Relat_P_AplicacaoDNOVO(@p_avaliacaoq@)','CODIGO','DESCR','C�digo, Descri��o','N')
,('Lyceum','AvaliacaoAcademicaNG','FTC_RelatAvalInstPartic','p_unidade','3','5','Unidade F�sica','N',NULL,'SP: Relat_P_A_UnidadeEnsino()','CODIGO','DESCR','C�digo, Descri��o','N')
,('Lyceum','AvaliacaoAcademicaNG','FTC_RelatAvalInstPartic','p_curso','4','5','Curso','N',NULL,'SP: Relat_P_A_Curso(@p_tipo@, @p_unidade@)','CODIGO','DESCR','Curso, Nome','N')
,('Lyceum','AvaliacaoAcademicaNG','FTC_RelatAvalInstPartic','p_tiporelatorio','5','5','Tipo de Relat�rio','S',NULL,'SELECT ''0'' AS CODIGO, ''Sint�tico'' AS DESCR UNION SELECT ''1'' AS CODIGO, ''An�litico'' AS DESCR ','CODIGO','DESCR','C�digo, Descri��o','N')
GO

delete from LY_CUSTOM_CLIENTE
where NOME = 'FTC_Relat_AvalInstAcompanhamento'
and IDENTIFICACAO_CODIGO = '0002'
go

INSERT INTO LY_CUSTOM_CLIENTE
(NOME, IDENTIFICACAO_CODIGO, AUTOR, DATA_CRIACAO, OBJETIVO, SOLICITADO_POR, ATIVO, TIPOCOMPONENTE, TIPO, CLIENTE)
SELECT
  'FTC_Relat_AvalInstAcompanhamento' NOME
, '0002' IDENTIFICAO_CODIGO
, 'Miguel' AUTOR
, '2018-08-02' DATA_CRIACAO
, 'Relat�rio Acompanhamento Avalia��o Docente' OBJETIVO
, 'Liane Soares' SOLICITADO_POR
, 'S' ATIVO
, 'RELATORIO' TIPOCOMPONENTE
, 'CLIENTE' TIPO
, 'FTC' CLIENTE
GO   