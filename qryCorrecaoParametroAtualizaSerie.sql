USE LYCEUM
GO

begin tran

delete from parametros_processos where processo = 'AtualizaSerie' and ordem >= 14

go

insert into parametros_processos values ('Lyceum', 'AtualizaSerie', 'Reprovações per.ant?', 14, 'S', 5, 'S,N', NULL, NULL, NULL, 'S')

go

insert into parametros_processos values ('Lyceum', 'AtualizaSerie', 'Caminho do Log', 15, NULL, 17, NULL, NULL, NULL, NULL, 'N')

go

insert into parametros_processos values ('Lyceum', 'AtualizaSerie', 'Turma Preferencial', 16, NULL, 5, 'SELECT DISTINCT TURMA_PREF FROM LY_ALUNO ORDER BY 1', 'TURMA_PREF', NULL, 'Turma Preferencial', 'N')

go

insert into parametros_processos values ('Lyceum', 'AtualizaSerie', 'Múltipla Progressão', 17, 'N', 5, 'S,N', NULL, NULL, NULL, 'N')

go

commit tran