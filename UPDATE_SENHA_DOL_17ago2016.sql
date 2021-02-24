use lyceum
go

UPDATE ly_docente SET SENHA_DOL = dbo.Crypt(CPF), SENHA_ALTERADA = 'N'
WHERE NUM_FUNC IN ('1581','865')
GO