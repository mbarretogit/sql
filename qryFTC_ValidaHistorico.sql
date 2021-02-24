USE LYCEUM
GO

DELETE FROM HD_RELATORIO WHERE RELATORIO = 'FTC_ValidaHistorico' AND GRUPORELAT = 'AcademicoNG'
INSERT INTO HD_RELATORIO
VALUES('Lyceum','AcademicoNG','FTC_ValidaHistorico','Valida��o de Lan�amento de Notas no Hist�rico','/Lyceum/Academico/FTC_ValidaHistorico','N',NULL,'sqlserver')
GO

--select * from HD_PARAMETRO_RELATORIO where GRUPORELAT = 'AcademicoNG'
DELETE FROM HD_PARAMETRO_RELATORIO WHERE RELATORIO = 'FTC_ValidaHistorico'
INSERT INTO HD_PARAMETRO_RELATORIO
VALUES
('Lyceum','AcademicoNG','FTC_ValidaHistorico','p_ano','1','5','Ano:','N',NULL,NULL,NULL,NULL,'Ano, Descri��o','N')
,('Lyceum','AcademicoNG','FTC_ValidaHistorico','p_semestre','2','5','Semestre:','N',NULL,NULL,NULL,NULL,'Semestre, Descri��o','N')
, ('Lyceum','AcademicoNG','FTC_ValidaHistorico','p_unidade','3','5','Unidade Ensino:','S',NULL,'SP: Relat_P_A_UnidadeEnsino()','CODIGO','DESCR','C�digo, Descri��o','N')
, ('Lyceum','AcademicoNG','FTC_ValidaHistorico','p_tipo','4','5','Tipo de Curso:','S',NULL,'SP: Relat_P_TipoCurso()','CODIGO','DESCR','Tipo, Descri��o','N')
,('Lyceum','AcademicoNG','FTC_ValidaHistorico','p_curso','5','5','Curso:','N',NULL,'SP: Relat_P_A_Curso(@p_tipo@, @p_unidade@)','CODIGO','DESCR','Curso, Nome','N')
,('Lyceum','AcademicoNG','FTC_ValidaHistorico','p_turno','6','5','Turno:','N',NULL,'SP: Relat_P_Turno()','CODIGO','DESCR','Turno, Nome','N')
,('Lyceum','AcademicoNG','FTC_ValidaHistorico','p_curriculo','7','5','Curr�culo:','N',NULL,'SP: Relat_P_Curriculo(@p_curso@, @p_turno@)','CODIGO','DESCR','C�digo, Descri��o','N')
GO

delete from LY_CUSTOM_CLIENTE
where NOME = 'FTC_ValidaHistorico'
and IDENTIFICACAO_CODIGO = '0001'
GO

INSERT INTO LY_CUSTOM_CLIENTE
(NOME, IDENTIFICACAO_CODIGO, AUTOR, DATA_CRIACAO, OBJETIVO, SOLICITADO_POR, ATIVO, TIPOCOMPONENTE, TIPO, CLIENTE)
SELECT
  'FTC_ValidaHistorico' NOME
, '0001' IDENTIFICAO_CODIGO
, 'Miguel' AUTOR
, '2017-05-11' DATA_CRIACAO
, 'Valida��o de Lan�amento de Notas no Hist�rico' OBJETIVO
, 'Josane Oliveira' SOLICITADO_POR
, 'S' ATIVO
, 'RELATORIO' TIPOCOMPONENTE
, 'CLIENTE' TIPO
, 'FTC' CLIENTE
GO   