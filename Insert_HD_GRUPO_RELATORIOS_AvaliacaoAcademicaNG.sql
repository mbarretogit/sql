USE LYCEUM
GO

DELETE FROM HD_GRUPO_RELATORIOS WHERE GRUPORELAT = 'AvaliacaoAcademicaNG'
GO

INSERT INTO HD_GRUPO_RELATORIOS
VALUES ('Lyceum','AvaliacaoAcademicaNG','Relatórios da Avaliação Docente / Institucional',NULL,NULL)
GO