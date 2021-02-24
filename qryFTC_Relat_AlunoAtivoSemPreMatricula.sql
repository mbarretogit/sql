USE LYCEUM
GO

DELETE FROM HD_RELATORIO WHERE RELATORIO = 'FTC_Relat_AlunoAtivoSemPreMatricula' AND GRUPORELAT = 'AcademicoNG'
INSERT INTO HD_RELATORIO
VALUES('Lyceum','AcademicoNG','FTC_Relat_AlunoAtivoSemPreMatricula','Alunos Ativos Sem Pré-matrícula','/Lyceum/Academico/FTC_Relat_AlunoAtivoSemPreMatricula','N',NULL,'sqlserver')
GO

--select * from HD_PARAMETRO_RELATORIO where GRUPORELAT = 'AcademicoNG'
DELETE FROM HD_PARAMETRO_RELATORIO WHERE RELATORIO = 'FTC_Relat_AlunoAtivoSemPreMatricula'
INSERT INTO HD_PARAMETRO_RELATORIO
VALUES
 ('Lyceum','AcademicoNG','FTC_Relat_AlunoAtivoSemPreMatricula','p_unidade','1','5','Unidade Ensino:','N',NULL,'SP: Relat_P_A_UnidadeEnsino()','CODIGO','DESCR','Código, Descrição','N')
, ('Lyceum','AcademicoNG','FTC_Relat_AlunoAtivoSemPreMatricula','p_tipo','2','5','Tipo de Curso:','N',NULL,'SP: Relat_P_TipoCurso()','CODIGO','DESCR','Tipo, Descrição','N')
GO

delete from LY_CUSTOM_CLIENTE
where NOME = 'FTC_Relat_AlunoAtivoSemPreMatricula'
and IDENTIFICACAO_CODIGO = '0001'
GO

INSERT INTO LY_CUSTOM_CLIENTE
(NOME, IDENTIFICACAO_CODIGO, AUTOR, DATA_CRIACAO, OBJETIVO, SOLICITADO_POR, ATIVO, TIPOCOMPONENTE, TIPO, CLIENTE)
SELECT
  'FTC_Relat_AlunoAtivoSemPreMatricula' NOME
, '0001' IDENTIFICAO_CODIGO
, 'Miguel' AUTOR
, '2017-12-27' DATA_CRIACAO
, 'Validação de Alunos Ativos Sem Pré-matrícula' OBJETIVO
, 'Greice Kelly/Jessica' SOLICITADO_POR
, 'S' ATIVO
, 'RELATORIO' TIPOCOMPONENTE
, 'CLIENTE' TIPO
, 'FTC' CLIENTE
GO   