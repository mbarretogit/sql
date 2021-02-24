C_PR_INTEGRA_CRM_OFERTA

select top 20 * from LY_INTEGRACAO_LOG order by TIME_INI desc
select * from LY_INTEGRACAO_ANDAMENTO_LOG where ID_INTEGRACAO_LOG = '8691' AND ERRO = 'S' AND OBJETO = 'Oferta' and parametros_execucao like '%Curso:729%'
select * from LY_INTEGRACAO_ANDAMENTO_LOG where ID_INTEGRACAO_LOG = '8691' AND PARAMETROS_EXECUCAO LIKE '%CAN-238846-FTC%' --AND ERRO = 'S'
select * from LY_INTEGRACAO_ANDAMENTO_LOG where ID_INTEGRACAO_LOG = '9549' AND MSG LIKE '%C_PR_INTEGRA_CRM_CONVOCADOS_VEST%' AND ERRO = 'N'
--C_PR_INTEGRA_CRM_CONVOCADOS_VEST
select distinct OBJETO from LY_INTEGRACAO_ANDAMENTO_LOG where ID_INTEGRACAO_LOG = '9549' and ERRO = 'S' and OBJETO = 'Candidato' AND PARAMETROS_EXECUCAO LIKE '%Curso:729%'

select * from LY_UNIDADE_FISICA
select * from C_INTEGRA_CRM_LYCEUM_VEST where concurso = '135'
select * from C_INTEGRA_CRM_LYCEUM_VEST where concurso = '160'

select * from LY_INTEGRACAO_ANDAMENTO_LOG where OBJETO = 'Oferta' and MSG LIKE '%3244%'

select * from LY_UNIDADE_FISICA 
--update LY_UNIDADE_FISICA set FL_FIELD_01 = CONVERT(NUMERIC,FL_FIELD_01)

select PESSOA,* from LY_CANDIDATO WHERE CONCURSO = '162'
select * from LY_CONCURSO WHERE CONCURSO= '165'
select * from LY_OFERTA_CURSO where CONCURSO = '135' and CURSO = '3244'
--DELETE from LY_OFERTA_CURSO where CONCURSO = '160' and CURSO = '3244'
select * from LY_OFERTA_CURSO where ANO_INGRESSO = '2018' 
select COUNT(candidato), CANDIDATO 
from LY_CONVOCADOS_VEST 
GROUP BY CANDIDATO
HAVING COUNT(candidato) > 1

select * from LY_CANDIDATO WHERE CANDIDATO = 'CAN-242309-FTC'--166
select * from LY_CANDIDATO WHERE CANDIDATO = 'CAN-238846-FTC'--165
select * from LY_CONVOCADOS_VEST WHERE CANDIDATO = 'CAN-238846-FTC'
select * from LY_CONVOCADOS_VEST WHERE CANDIDATO = 'CAN-236674-FTC'
select * from LY_CONVOCADOS_VEST WHERE CONCURSO = '166'

select * from LY_PESSOA where pessoa = '42749'

--Inscricao: CAN-212813-FTC - SituacaoConcurso: - Concurso:160 - Ordem:1 - Ano: - CategoriaNome:FTC DE VITÓRIA DA CONQUISTA - CodCampus:5 - CodCurriculo:201801 - CodCurso:3244 - 
--CodEscola: - CodFormaIngr: - CodSubFormaIngr: - CodTurno:3 - CurrEquiv: - DataFinal: - DataInicial: - IdOferta:43d35ba7-f901-e811-8115-e0071b6eacf1 - MinimoDeVagasPreenchidas: - 
--Nome:Engenharia Ambiental  - NomeConcurso: - Periodo: - QuantidadeVagas: - Regime: - VagasDisponiveis:24 - VagasDisponiveisSGA: - Classificacao:
exec C_PR_INTEGRA_CRM_CONVOCADOS_VEST 'CAN-212813-FTC',NULL,'160',1,'2018','1','FTC DE VITÓRIA DA CONQUISTA','5','201801','3244',NULL,NULL,NULL,3,NULL,NULL,NULL,'43d35ba7-f901-e811-8115-e0071b6eacf1',NULL,'Engenharia Ambiental',NULL,NULL,NULL,24,NULL,1

LY_OFERTA_CURSO
--DELETE from LY_OPCOES_PROC_SELETIVO where CONCURSO = '160' and CANDIDATO = 'CAN-212813-FTC'

