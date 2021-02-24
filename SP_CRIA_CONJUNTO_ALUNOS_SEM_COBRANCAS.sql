 USE LYCEUMINTEGRACAO
 GO
-- EXEC SP_CRIA_CONJUNTO_ALUNOS_SEM_COBRANCAS  
  
ALTER PROCEDURE SP_CRIA_CONJUNTO_ALUNOS_SEM_COBRANCAS  
AS  
BEGIN  
  
-- HELP 14958 - NELSON ALBUQUERQUE ------------------------------------------------------------------------------------------------------------------------------------------------------------  
-- Descrição da Solicitação: Solicito a criação de alguns conjuntos que sejam atualizados diariamente da seguinte forma:  
-- Alunos MATRICULADOS nos Tipo_Curso GRADUAÇÃO e TECNÓLOGO no periodo 2020.2 que atendam os seguintes filtros mensais abaixo.  
  
-- MATRICULADOS_SEM_AGO - Alunos Matriculados Sem cobrança de mensalidade para o mês de Agosto.  
-- MATRICULADOS_SEM_SET - Alunos Matriculados Sem cobrança de mensalidade para o mês de Setembro.  
-- MATRICULADOS_SEM_OUT - Alunos Matriculados Sem cobrança de mensalidade para o mês de Outubro.  
-- MATRICULADOS_SEM_NOV - Alunos Matriculados Sem cobrança de mensalidade para o mês de Novembro.  
-- MATRICULADOS_SEM_DEZ - Alunos Matriculados Sem cobrança de mensalidade para o mês de Dezembro.  
  
-- exec SP_CRIA_CONJUNTO_ALUNOS_SEM_COBRANCAS  
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
declare @ano int, @semestre int, @mes int   
set @ano = year(getdate())  
set @semestre = 1
set @mes = 2
  
if month(getdate()) > 6 BEGIN  
 set @semestre = 2 
 set @mes = 8
END  
  
IF OBJECT_ID('TEMPDB.DBO.#ALUNOS_MATRICULADOS_20202', 'U') IS NOT NULL DROP TABLE #ALUNOS_MATRICULADOS_20202  
  
select distinct  
 m.ALUNO,   
 cb.MES  
INTO #ALUNOS_MATRICULADOS_PERIODO 
from LYCEUM..ly_matricula M  
inner join LYCEUM..ly_aluno a on a.ALUNO = m.aluno  
inner join LYCEUM..ly_curso c on c.curso = a.curso and c.TIPO IN ('GRADUACAO', 'TECNOLOGO')   
join LYCEUM..ly_cobranca cb on cb.ALUNO = m.aluno and cb.ANO = @ano and cb.MES >= @mes  
where   
m.ano = @ano and m.semestre = @semestre  
and exists (SELECT TOP 1 1 FROM LYCEUM..VW_COBRANCA VW WHERE VW.ALUNO = M.ALUNO AND VW.ANO = @ANO AND VW.MES = CASE WHEN @semestre = 1 THEN 1 ELSE 7 END AND VW.ESTORNO = 'N')
order by m.aluno, cb.MES  

---- DEF CONJ SEM FEV, MAR, ABR, MAI, JUN ------------------------------------------------------------------------------------------------------------------------------------------------------  
  
IF NOT EXISTS (SELECT TOP 1 1 FROM LYCEUM..LY_DEF_CONJ_ALUNO WHERE CONJ_ALUNO = 'MATRICULADOS_SEM_FEV' ) BEGIN  
 INSERT INTO LYCEUM..LY_DEF_CONJ_ALUNO ( CONJ_ALUNO, DESCRICAO ) VALUES ( 'MATRICULADOS_SEM_FEV', 'Alunos Matriculados Sem cobrança de mensalidade para o mês de Fevereiro.' )  
END  
  
IF NOT EXISTS (SELECT TOP 1 1 FROM LYCEUM..LY_DEF_CONJ_ALUNO WHERE CONJ_ALUNO = 'MATRICULADOS_SEM_MAR' ) BEGIN  
 INSERT INTO LYCEUM..LY_DEF_CONJ_ALUNO ( CONJ_ALUNO, DESCRICAO ) VALUES ( 'MATRICULADOS_SEM_MAR', 'Alunos Matriculados Sem cobrança de mensalidade para o mês de Março.' )  
END  
  
IF NOT EXISTS (SELECT TOP 1 1 FROM LYCEUM..LY_DEF_CONJ_ALUNO WHERE CONJ_ALUNO = 'MATRICULADOS_SEM_ABR' ) BEGIN  
 INSERT INTO LYCEUM..LY_DEF_CONJ_ALUNO ( CONJ_ALUNO, DESCRICAO ) VALUES ( 'MATRICULADOS_SEM_ABR', 'Alunos Matriculados Sem cobrança de mensalidade para o mês de Abril.' )  
END  
  
IF NOT EXISTS (SELECT TOP 1 1 FROM LYCEUM..LY_DEF_CONJ_ALUNO WHERE CONJ_ALUNO = 'MATRICULADOS_SEM_MAI' ) BEGIN  
 INSERT INTO LYCEUM..LY_DEF_CONJ_ALUNO ( CONJ_ALUNO, DESCRICAO ) VALUES ( 'MATRICULADOS_SEM_MAI', 'Alunos Matriculados Sem cobrança de mensalidade para o mês de Maio.' )  
END  
  
IF NOT EXISTS (SELECT TOP 1 1 FROM LYCEUM..LY_DEF_CONJ_ALUNO WHERE CONJ_ALUNO = 'MATRICULADOS_SEM_JUN' ) BEGIN  
 INSERT INTO LYCEUM..LY_DEF_CONJ_ALUNO ( CONJ_ALUNO, DESCRICAO ) VALUES ( 'MATRICULADOS_SEM_JUN', 'Alunos Matriculados Sem cobrança de mensalidade para o mês de Junho.' )  
END  
  
  
---- DEF CONJ SEM AGO, SET, OUT, NOV, DEZ ------------------------------------------------------------------------------------------------------------------------------------------------------  
  
IF NOT EXISTS (SELECT TOP 1 1 FROM LYCEUM..LY_DEF_CONJ_ALUNO WHERE CONJ_ALUNO = 'MATRICULADOS_SEM_AGO' ) BEGIN  
 INSERT INTO LYCEUM..LY_DEF_CONJ_ALUNO ( CONJ_ALUNO, DESCRICAO ) VALUES ( 'MATRICULADOS_SEM_AGO', 'Alunos Matriculados Sem cobrança de mensalidade para o mês de agosto.' )  
END  
  
IF NOT EXISTS (SELECT TOP 1 1 FROM LYCEUM..LY_DEF_CONJ_ALUNO WHERE CONJ_ALUNO = 'MATRICULADOS_SEM_SET' ) BEGIN  
 INSERT INTO LYCEUM..LY_DEF_CONJ_ALUNO ( CONJ_ALUNO, DESCRICAO ) VALUES ( 'MATRICULADOS_SEM_SET', 'Alunos Matriculados Sem cobrança de mensalidade para o mês de Setembro.' )  
END  
  
IF NOT EXISTS (SELECT TOP 1 1 FROM LYCEUM..LY_DEF_CONJ_ALUNO WHERE CONJ_ALUNO = 'MATRICULADOS_SEM_OUT' ) BEGIN  
 INSERT INTO LYCEUM..LY_DEF_CONJ_ALUNO ( CONJ_ALUNO, DESCRICAO ) VALUES ( 'MATRICULADOS_SEM_OUT', 'Alunos Matriculados Sem cobrança de mensalidade para o mês de Outubro.' )  
END  
  
IF NOT EXISTS (SELECT TOP 1 1 FROM LYCEUM..LY_DEF_CONJ_ALUNO WHERE CONJ_ALUNO = 'MATRICULADOS_SEM_NOV' ) BEGIN  
 INSERT INTO LYCEUM..LY_DEF_CONJ_ALUNO ( CONJ_ALUNO, DESCRICAO ) VALUES ( 'MATRICULADOS_SEM_NOV', 'Alunos Matriculados Sem cobrança de mensalidade para o mês de Novembro.' )  
END  
  
IF NOT EXISTS (SELECT TOP 1 1 FROM LYCEUM..LY_DEF_CONJ_ALUNO WHERE CONJ_ALUNO = 'MATRICULADOS_SEM_DEZ' ) BEGIN  
 INSERT INTO LYCEUM..LY_DEF_CONJ_ALUNO ( CONJ_ALUNO, DESCRICAO ) VALUES ( 'MATRICULADOS_SEM_DEZ', 'Alunos Matriculados Sem cobrança de mensalidade para o mês de Dezembro.' )  
END  
  
-- CONJ SEM FEV ------------------------------------------------------------------------------------------------------------------------------------------------------  
DELETE LYCEUM..LY_CONJ_ALUNO where CONJ_ALUNO = 'MATRICULADOS_SEM_FEV'  

IF @mes = 2
BEGIN

insert into LYCEUM..LY_CONJ_ALUNO (CONJ_ALUNO, ALUNO )  
select   
 distinct 'MATRICULADOS_SEM_FEV', aluno  
from LYCEUM..ly_matricula m   
where m.ano = @ano and m.semestre = @semestre  
and not exists ( SELECT top 1 1 FROM #ALUNOS_MATRICULADOS_PERIODO t where t.aluno = m.aluno and t.MES = @mes )  
and not exists ( select top 1 1 FROM LYCEUM..LY_CONJ_ALUNO ca where ca.ALUNO = m.aluno and CONJ_ALUNO = 'MATRICULADOS_SEM_FEV' )  
  
-- CONJ SEM MAR ------------------------------------------------------------------------------------------------------------------------------------------------------  
DELETE LYCEUM..LY_CONJ_ALUNO where CONJ_ALUNO = 'MATRICULADOS_SEM_MAR'  
  
insert into LYCEUM..LY_CONJ_ALUNO (CONJ_ALUNO, ALUNO )  
select   
 distinct 'MATRICULADOS_SEM_MAR', aluno  
from LYCEUM..ly_matricula m   
where m.ano = @ano and m.semestre = @semestre  
and not exists ( SELECT top 1 1 FROM #ALUNOS_MATRICULADOS_PERIODO t where t.aluno = m.aluno and t.MES = @mes+1 )  
and not exists ( select top 1 1 from LYCEUM..LY_CONJ_ALUNO ca where ca.ALUNO = m.aluno and CONJ_ALUNO = 'MATRICULADOS_SEM_MAR' )  
  
-- CONJ SEM ABR ------------------------------------------------------------------------------------------------------------------------------------------------------  
DELETE LYCEUM..LY_CONJ_ALUNO where CONJ_ALUNO = 'MATRICULADOS_SEM_ABR'  
  
insert into LYCEUM..LY_CONJ_ALUNO (CONJ_ALUNO, ALUNO )  
select   
 distinct 'MATRICULADOS_SEM_ABR', aluno  
from LYCEUM..ly_matricula m   
where m.ano = @ano and m.semestre = @semestre  
and not exists ( SELECT top 1 1 FROM #ALUNOS_MATRICULADOS_PERIODO t where t.aluno = m.aluno and t.MES = @mes+2 )  
and not exists ( select top 1 1 from LYCEUM..LY_CONJ_ALUNO ca where ca.ALUNO = m.aluno and CONJ_ALUNO = 'MATRICULADOS_SEM_ABR' )  
  
-- CONJ SEM MAI ------------------------------------------------------------------------------------------------------------------------------------------------------  
DELETE LYCEUM..LY_CONJ_ALUNO where CONJ_ALUNO = 'MATRICULADOS_SEM_MAI'  
  
insert into LYCEUM..LY_CONJ_ALUNO (CONJ_ALUNO, ALUNO )  
select   
 distinct 'MATRICULADOS_SEM_MAI', aluno  
from LYCEUM..ly_matricula m   
where m.ano = @ano and m.semestre = @semestre  
and not exists ( SELECT top 1 1 FROM #ALUNOS_MATRICULADOS_PERIODO t where t.aluno = m.aluno and t.MES = @mes+3 )  
and not exists ( select top 1 1 from LYCEUM..LY_CONJ_ALUNO ca where ca.ALUNO = m.aluno and CONJ_ALUNO = 'MATRICULADOS_SEM_MAI' )  
  
-- CONJ SEM JUN ------------------------------------------------------------------------------------------------------------------------------------------------------  
DELETE LYCEUM..LY_CONJ_ALUNO where CONJ_ALUNO = 'MATRICULADOS_SEM_JUN'  
  
insert into LYCEUM..LY_CONJ_ALUNO (CONJ_ALUNO, ALUNO )  
select   
 distinct 'MATRICULADOS_SEM_JUN', aluno  
from LYCEUM..ly_matricula m   
where m.ano = @ano and m.semestre = @semestre  
and not exists ( SELECT top 1 1 FROM #ALUNOS_MATRICULADOS_PERIODO t where t.aluno = m.aluno and t.MES = @mes+4 )  
and not exists ( select top 1 1 from LYCEUM..LY_CONJ_ALUNO ca where ca.ALUNO = m.aluno and CONJ_ALUNO = 'MATRICULADOS_SEM_JUN' )  
  
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------  
 END
 
 ELSE 

 BEGIN
-- CONJ SEM AGO ------------------------------------------------------------------------------------------------------------------------------------------------------  
DELETE LYCEUM..LY_CONJ_ALUNO where CONJ_ALUNO = 'MATRICULADOS_SEM_AGO'  
  
insert into LYCEUM..LY_CONJ_ALUNO (CONJ_ALUNO, ALUNO )  
select   
 distinct 'MATRICULADOS_SEM_AGO', aluno  
from LYCEUM..ly_matricula m   
where m.ano = @ano and m.semestre = @semestre  
and not exists ( SELECT top 1 1 FROM #ALUNOS_MATRICULADOS_PERIODO t where t.aluno = m.aluno and t.MES = @mes )  
and not exists ( select top 1 1 FROM LYCEUM..LY_CONJ_ALUNO ca where ca.ALUNO = m.aluno and CONJ_ALUNO = 'MATRICULADOS_SEM_AGO' )  
  
-- CONJ SEM AGO ------------------------------------------------------------------------------------------------------------------------------------------------------  
DELETE LYCEUM..LY_CONJ_ALUNO where CONJ_ALUNO = 'MATRICULADOS_SEM_SET'  
  
insert into LYCEUM..LY_CONJ_ALUNO (CONJ_ALUNO, ALUNO )  
select   
 distinct 'MATRICULADOS_SEM_SET', aluno  
from LYCEUM..ly_matricula m   
where m.ano = @ano and m.semestre = @semestre  
and not exists ( SELECT top 1 1 FROM #ALUNOS_MATRICULADOS_PERIODO t where t.aluno = m.aluno and t.MES = @mes+1 )  
and not exists ( select top 1 1 from LYCEUM..LY_CONJ_ALUNO ca where ca.ALUNO = m.aluno and CONJ_ALUNO = 'MATRICULADOS_SEM_SET' )  
  
-- CONJ SEM OUT ------------------------------------------------------------------------------------------------------------------------------------------------------  
DELETE LYCEUM..LY_CONJ_ALUNO where CONJ_ALUNO = 'MATRICULADOS_SEM_OUT'  
  
insert into LYCEUM..LY_CONJ_ALUNO (CONJ_ALUNO, ALUNO )  
select   
 distinct 'MATRICULADOS_SEM_OUT', aluno  
from LYCEUM..ly_matricula m   
where m.ano = @ano and m.semestre = @semestre  
and not exists ( SELECT top 1 1 FROM #ALUNOS_MATRICULADOS_PERIODO t where t.aluno = m.aluno and t.MES = @mes+2 )  
and not exists ( select top 1 1 from LYCEUM..LY_CONJ_ALUNO ca where ca.ALUNO = m.aluno and CONJ_ALUNO = 'MATRICULADOS_SEM_OUT' )  
  
-- CONJ SEM NOV ------------------------------------------------------------------------------------------------------------------------------------------------------  
DELETE LYCEUM..LY_CONJ_ALUNO where CONJ_ALUNO = 'MATRICULADOS_SEM_NOV'  
  
insert into LYCEUM..LY_CONJ_ALUNO (CONJ_ALUNO, ALUNO )  
select   
 distinct 'MATRICULADOS_SEM_NOV', aluno  
from LYCEUM..ly_matricula m   
where m.ano = @ano and m.semestre = @semestre  
and not exists ( SELECT top 1 1 FROM #ALUNOS_MATRICULADOS_PERIODO t where t.aluno = m.aluno and t.MES = @mes+3 )  
and not exists ( select top 1 1 from LYCEUM..LY_CONJ_ALUNO ca where ca.ALUNO = m.aluno and CONJ_ALUNO = 'MATRICULADOS_SEM_NOV' )  
  
-- CONJ SEM DEZ ------------------------------------------------------------------------------------------------------------------------------------------------------  
DELETE LYCEUM..LY_CONJ_ALUNO where CONJ_ALUNO = 'MATRICULADOS_SEM_DEZ'  
  
insert into LYCEUM..LY_CONJ_ALUNO (CONJ_ALUNO, ALUNO )  
select   
 distinct 'MATRICULADOS_SEM_DEZ', aluno  
from LYCEUM..ly_matricula m   
where m.ano = @ano and m.semestre = @semestre  
and not exists ( SELECT top 1 1 FROM #ALUNOS_MATRICULADOS_PERIODO t where t.aluno = m.aluno and t.MES = @mes+4 )  
and not exists ( select top 1 1 from LYCEUM..LY_CONJ_ALUNO ca where ca.ALUNO = m.aluno and CONJ_ALUNO = 'MATRICULADOS_SEM_DEZ' )  

 
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------  
  END

END  

-- select * from LYCEUM..LY_CONJ_ALUNO where CONJ_ALUNO = 'MATRICULADOS_SEM_FEV'  
-- select * from LYCEUM..LY_CONJ_ALUNO where CONJ_ALUNO = 'MATRICULADOS_SEM_MAR'  
-- select * from LYCEUM..LY_CONJ_ALUNO where CONJ_ALUNO = 'MATRICULADOS_SEM_ABR'  
-- select * from LYCEUM..LY_CONJ_ALUNO where CONJ_ALUNO = 'MATRICULADOS_SEM_MAI'  
-- select * from LYCEUM..LY_CONJ_ALUNO where CONJ_ALUNO = 'MATRICULADOS_SEM_JUN'  

-- select * from LYCEUM..LY_CONJ_ALUNO where CONJ_ALUNO = 'MATRICULADOS_SEM_AGO'  
-- select * from LYCEUM..LY_CONJ_ALUNO where CONJ_ALUNO = 'MATRICULADOS_SEM_SET'  
-- select * from LYCEUM..LY_CONJ_ALUNO where CONJ_ALUNO = 'MATRICULADOS_SEM_OUT'  
-- select * from LYCEUM..LY_CONJ_ALUNO where CONJ_ALUNO = 'MATRICULADOS_SEM_NOV'  
-- select * from LYCEUM..LY_CONJ_ALUNO where CONJ_ALUNO = 'MATRICULADOS_SEM_DEZ'  
  
--select aluno from ly_cobranca cb where cb.ALUNO in (select aluno from LY_CONJ_ALUNO where CONJ_ALUNO = 'MATRICULADOS_SEM_AGO' ) and cb.ANO = 2020 and cb.MES = 8  
--select aluno from ly_cobranca cb where cb.ALUNO in (select aluno from LY_CONJ_ALUNO where CONJ_ALUNO = 'MATRICULADOS_SEM_SET' ) and cb.ANO = 2020 and cb.MES = 9  
--select aluno from ly_cobranca cb where cb.ALUNO in (select aluno from LY_CONJ_ALUNO where CONJ_ALUNO = 'MATRICULADOS_SEM_OUT' ) and cb.ANO = 2020 and cb.MES = 10  
--select aluno from ly_cobranca cb where cb.ALUNO in (select aluno from LY_CONJ_ALUNO where CONJ_ALUNO = 'MATRICULADOS_SEM_NOV' ) and cb.ANO = 2020 and cb.MES = 11  
--select aluno from ly_cobranca cb where cb.ALUNO in (select aluno from LY_CONJ_ALUNO where CONJ_ALUNO = 'MATRICULADOS_SEM_DEZ' ) and cb.ANO = 2020 and cb.MES = 12  
  