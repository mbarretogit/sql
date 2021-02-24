USE LYCEUM
GO

UPDATE LY_CONSULTA_DINAMICA_PARAMETROS
SET DESCRICAO = 'Unidade Física', SQL_TEXTO = 'Select unidade_fis as codigo, nome_comp as descricao from ly_unidade_fisica order by unidade_fis'
WHERE ID = '310'
GO