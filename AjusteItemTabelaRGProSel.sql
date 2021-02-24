-- ---------------------------------------------------------------------------
-- ITEMTABELA - Adicionado Registro para Orgão Emissor Não Informado
-- ---------------------------------------------------------------------------  
DECLARE @v_Existe VARCHAR(1)

EXEC sp_ExisteRegistro 'ItemTabela','TAB = ''ORGAO RG'' AND item = ''OUT'' ', @v_Existe OUTPUT

IF @v_Existe = 'N'
  INSERT INTO ItemTabela (TAB, ITEM, DESCR) VALUES ('ORGAO RG','OUT', 'OUT - Outros Emissores')
GO

