USE LYCEUM
GO

DELETE FROM HD_GRUPO_RELATORIOS WHERE GRUPORELAT = 'AvaliacaoAcademicaNG'
GO

INSERT INTO HD_GRUPO_RELATORIOS
VALUES ('Lyceum','AvaliacaoAcademicaNG','Relat�rios da Avalia��o Docente / Institucional',NULL,NULL)
GO