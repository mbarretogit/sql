

USE [master]
GO
CREATE LOGIN [uniftc_enviorelatorio] WITH PASSWORD=N'!08w!HD01e@fs', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=ON
GO

USE [LYCEUM]
GO
CREATE USER [uniftc_enviorelatorio] FOR LOGIN [uniftc_enviorelatorio]
GO
use [LYCEUMINTEGRACAO];
GO
CREATE USER [uniftc_enviorelatorio] FOR LOGIN [uniftc_enviorelatorio]
GO

USE [LYCEUMINTEGRACAO]
GO

CREATE TABLE FTC_ALUNOS_MATRICULADOS_COMUNICADOS (ALUNO VARCHAR(20), CADASTRO DATETIME)

GRANT SELECT ON FTC_ALUNO_CONFIRMADO TO [uniftc_enviorelatorio]
GRANT ALL ON FTC_ALUNOS_MATRICULADOS_COMUNICADOS to [uniftc_enviorelatorio]
GRANT EXECUTE ON FTC_GERA_ALUNOS_MATRICULADOS_COMUNICADO  TO [uniftc_enviorelatorio]

USE LYCEUM
GO

GRANT SELECT ON LY_ALUNO TO [uniftc_enviorelatorio]
GRANT SELECT ON LY_CURSO TO [uniftc_enviorelatorio]
GRANT SELECT ON LY_UNIDADE_ENSINO TO [uniftc_enviorelatorio]
GRANT SELECT ON LY_PESSOA TO [uniftc_enviorelatorio]
GRANT SELECT ON LY_MATRICULA TO [uniftc_enviorelatorio]
