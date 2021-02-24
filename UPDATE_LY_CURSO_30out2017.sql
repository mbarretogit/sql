use lyceum
go

update ly_curso set ativo = 'N'
where faculdade = '02' and ativo = 'S'
go

--select * from ly_curso where faculdade = '02' and ativo = 'S'