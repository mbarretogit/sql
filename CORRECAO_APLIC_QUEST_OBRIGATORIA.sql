use LYCEUM
go

update LY_APLIC_QUESTIONARIO 
set EXIBE_PAG_RESUMO = 'S', MSG_FINAL = 'Obrigada pela sua participa��o.'
where APLICACAO LIKE '%_20181%'
GO