USE LYCEUM
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.FTC_SP_csvIntegraCRM'))
   exec('CREATE PROCEDURE [dbo].[FTC_SP_csvIntegraCRM] AS BEGIN SET NOCOUNT OFF; END')
GO 

ALTER PROCEDURE dbo.FTC_SP_csvIntegraCRM     
(      
  @p_faculdade VARCHAR(20)  
, @p_curso  VARCHAR(20)  
, @p_turno  VARCHAR(20)  
, @p_curriculo VARCHAR(20)  
)      
AS      
-- [INÍCIO]              
BEGIN      
  
SET NOCOUNT ON  
  
  
select   
  ''             as [Categoria]   
 ,''             as [Concurso]   
 , ltrim(rtrim(c.nome)) + ' (' + t.DESCRICAO + ')' as [Nome]   
 ,''             as [Quantidade de Vagas]   
 ,''             as [Vagas disponiveis]   
 ,''             as [Area do Curso]   
 ,''             as [Nome Original Oferta]   
 ,''             as [Data Inicial]   
 ,''             as [Data Final]   
 ,''             as [Formula Nota Final]   
 ,''             as [Ano]  
 ,''             as [Vagas Disponiveis SGA]  
 ,c.FACULDADE    as [Codcampus]  
 ,cur.curriculo  as [Codcurriculo]   
 ,c.curso        as [Codcurso]   
 ,''             as [Codescola]   
 ,''             as [CodFormaingresso]   
 ,''             as [Codsubformaingresso]   
 ,cur.turno      as [Codturno]   
 ,''             as [Curriculo Equivalente]   
 ,''             as [Periodo]   
 ,''             as [Regime]  
 ,''             as [Oferta de Pos-Graduacao]   
 ,''             as [Período Pos-Graduacao]   
 ,''             as [Situação da Oferta na PosGraduação]  
from ly_curso c  
join ly_curriculo cur  
 on c.curso = cur.curso  
join ly_turno t  
 on cur.turno = t.TURNO  
where c.ativo  = 'S' -- Só cursos ativos  
and concat(cur.ANO_INI,cur.SEM_INI) = (select MAX(concat(ano_ini,sem_ini)) from ly_curriculo where CURSO = cur.CURSO and DT_EXTINCAO is null) -- ajuste para trazer o curriculo com vigência mais recente
and cur.DT_EXTINCAO is null and c.TIPO in ('GRADUACAO','TECNOLOGO') -- só curriculos ativos   
and ((@p_curso IS NOT NULL AND c.curso = @p_curso) OR @p_curso IS NULL)   
and ((@p_curriculo IS NOT NULL AND cur.curriculo = @p_curriculo) OR @p_curriculo IS NULL)   
and ((@p_turno IS NOT NULL AND cur.turno = @p_turno) OR @p_turno IS NULL)   
and ((@p_faculdade IS NOT NULL AND c.faculdade = @p_faculdade) OR @p_faculdade IS NULL)   
  
  
SET NOCOUNT OFF  
  
END              
-- [FIM]      