USE LYCEUM
GO

insert into parametros_relatorios (SISTEMA, GRUPO_CODIGO, RELATORIOS_NOME, NOME, TIPO, OBRIGATORIO, VALOR, SQL, COL_VALOR, COL_DESC, NOMES_COLUNAS, ORDEM)
	values ('Lyceum','AcademicoNG','DiarioEletronico','p_is_docente','5','S',NULL,'SP: Relat_P_SimNao()','CODIGO','DESCR','É Docente?, Descrição','10')