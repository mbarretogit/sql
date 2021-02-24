USE LYCEUM
GO

-----------------------------------------------------------------------
-- TRANSACAO TLOV041D - POPUP - Responsáveis Financeiros e planos de pagamento por periodo
-----------------------------------------------------------------------
DECLARE @v_Existe VARCHAR(1)
EXEC sp_ExisteRegistro 'HD_TRANSACAO', 'SIS = ''Secretaria'' AND TRANS = ''TLOV041D'' ', @v_Existe OUTPUT

IF @v_Existe = 'N'
BEGIN
     INSERT INTO HD_TRANSACAO (SIS, TRANS, NOME, PUBLICA, ACESSOANONIMO, PAGINAWEB, FORM, ITEMMENU, AUDITAR, MODULO)
     VALUES ('Secretaria', 'TLOV041D', 'POPUP - Responsáveis Financeiros e planos de pagamento por periodo', 'N', 'N', NULL, NULL, NULL, 'N', NULL)

     INSERT INTO HD_PADTRANS (PADACES, SIS, TRANS, PODEALT, PODECAD, PODEREM)
     VALUES ('LY_ADM', 'Secretaria', 'TLOV041D', 'S', NULL, NULL)
END
GO
