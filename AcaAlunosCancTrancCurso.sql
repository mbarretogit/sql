USE LYCEUM
GO

DELETE from PARAMETROS_RELATORIOS where RELATORIOS_NOME ='AcaAlunosCancTrancCurso'
GO
INSERT INTO PARAMETROS_RELATORIOS(SISTEMA,GRUPO_CODIGO, RELATORIOS_NOME,NOME,TIPO,OBRIGATORIO,VALOR,SQL,COL_VALOR,COL_DESC,NOMES_COLUNAS,Ordem)
VALUES ('Lyceum', 'Academico', 'AcaAlunosCancTrancCurso', 'Unidade Física', 5, 'N', ' ', 'select faculdade,nome_comp from VW_UNIDADE_FISICA ORDER BY FACULDADE', 'faculdade', 'nome_comp', 'Código, Faculdade',01)
GO
INSERT INTO PARAMETROS_RELATORIOS(SISTEMA,GRUPO_CODIGO, RELATORIOS_NOME,NOME,TIPO,OBRIGATORIO,VALOR,SQL,COL_VALOR,COL_DESC,NOMES_COLUNAS,Ordem)
VALUES ('Lyceum', 'Academico', 'AcaAlunosCancTrancCurso', 'Ano/Período', 5, 'N', ' ','select AnoPeriodo,id_reduzida from VW_AnoPeriodo order by AnoPeriodo desc', 'AnoPeriodo', NULL, 'Ano/Período,Abreviatura',02)
GO
INSERT INTO PARAMETROS_RELATORIOS (SISTEMA,GRUPO_CODIGO,RELATORIOS_NOME,NOME, TIPO, OBRIGATORIO, VALOR, SQL, COL_VALOR, COL_DESC, NOMES_COLUNAS,ORDEM) 
VALUES ('Lyceum','Academico', 'AcaAlunosCancTrancCurso','Situação',5,'N','','Cancelado,Trancado', NULL, NULL, NULL, 3)
GO
