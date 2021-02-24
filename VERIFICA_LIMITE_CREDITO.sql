USE LYCEUM
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.VERIFICA_LIMITE_CREDITO'))
   exec('CREATE PROCEDURE [dbo].[VERIFICA_LIMITE_CREDITO] AS BEGIN SET NOCOUNT OFF; END')
GO 
  
ALTER procedure  VERIFICA_LIMITE_CREDITO (  
@p_SESSAO_ID as varchar(40),        
@p_aluno T_CODIGO,        
@p_disciplina T_CODIGO,        
@ver_limite_creditos  T_SIMNAO ,  --origem LY_OPCOES.PRE_MATR_SEM_LIM_CRED (valor invertido)    
@p_ANO  T_ANO ,        
@p_SEMESTRE  T_SEMESTRE2 ,        
@p_plano_estudo  T_SIMNAO ,        
@p_return varchar(100) output)           
AS          
begin        
-- ################################################################################################    
-- <DOC> Descricao:    
-- <DOC>     
-- <DOC> Verificar os limites mÝnimo e mßximo de creditos matriculados.    
-- <DOC>     
-- <DOC> Parametros:    
-- <DOC>     
-- <DOC> @p_sessao_id varchar(40) - id da conexÒo    
-- <DOC> @p_aluno T_CODIGO - c¾digo do aluno    
-- <DOC> @p_disciplina T_CODIGO - c¾digo da disciplina    
-- <DOC> @p_LimCredMin  T_SIMNAO - se verifica limite de crÚdito    
-- <DOC> @p_ANO - ano da matrÝcula    
-- <DOC> @p_SEMESTRE - perÝodo da matrÝcula    
-- <DOC> @p_plano_estudo  T_SIMNAO - se verifica plano de estudo    
-- <DOC>     
-- <DOC> Retorno:    
-- <DOC>    
-- <DOC>  @p_return varchar(100)  - mensagem de erro    
-- <DOC>     
-- <DOC> Roteiro de execuþÒo:    
-- <DOC>     
-- <DOC> Se nÒo existir validaþÒo de matrÝcula por curso 'MÝnimoDisciplina':    
-- <DOC> 1. Busca o nÀmero mÝnimo e mßximo de crÚditos do currÝculo.    
-- <DOC> 2. Calcula o nÀmero de drÚditos obrigat¾rios (TOTAL_CREDITO_OBRIG_FALTA) e de grupo (TOTAL_CREDITO_GRUPO_FALTA) que faltam para o aluno cursar.    
-- <DOC> 3. Soma a quantidade de disciplinas e os crÚditos das prÚ-matrÝculas nÒo dispensadas, das matrÝculas com situaþÒo 'Matriculado','Aprovado',    
-- <DOC>    'Rep Freq' ou 'Rep Nota' e da disciplina.    
-- <DOC> 4. Se @p_plano_estudo = 'S' e o aluno tem (VERIFICA_PLANO_ESTUDO) e @p_LimCredMin = 'S', verifica o limite de crÚditos e de displinas com os dados do plano    
-- <DOC>    senÒo com os do currÝculo (mÝnimo e mßximo).    
-- <DOC> 5. Se @p_LimCredMin = 'S' executa o entry-point a_VALIDA_PRE_MATR_CONJUNTO    
-- <DOC>     
-- ################################################################################################     
        
 declare @v_count int        
 declare @v_count_aluno int        
 declare @v_count_curriculo int        
 declare @v_credobr_falta  T_DECIMAL_MEDIO         
 declare @v_credgrp_falta  T_DECIMAL_MEDIO           
 declare @v_creditos  T_DECIMAL_MEDIO         
 declare @v_qtd_discip_plano int        
 declare @v_ver_plano_estudo  T_SIMNAO         
 declare @v_credito_plano  T_DECIMAL_MEDIO         
 declare @v_mensagem varchar(100)        
 declare @v_credito_min  T_DECIMAL_MEDIO         
 declare @v_credito_max  T_DECIMAL_MEDIO         
 declare @v_valido  T_SIMNAO         
 declare @v_msg varchar(1000)  
 declare @v_contexto varchar(100)       
           
    set @p_return = ''        
            
    set @v_count = 0        
    SELECT @v_count = isnull(COUNT(*),0)        
    From LY_VALIDACAO_MATRICULA, LY_VALID_MATR_CURSO, LY_ALUNO         
    Where LY_VALID_MATR_CURSO.VALIDACAO = LY_VALIDACAO_MATRICULA.VALIDACAO         
    AND LY_VALID_MATR_CURSO.VALIDACAO = 'MÝnimoDisciplina'         
    AND LY_VALID_MATR_CURSO.ANO = @p_ano        
    AND LY_VALID_MATR_CURSO.PERIODO = @p_semestre        
    AND LY_VALID_MATR_CURSO.CURSO = LY_ALUNO.CURSO        
    AND LY_ALUNO.ALUNO = @p_aluno        
            
    if @v_count = 0     
 begin        
   set @v_count_aluno = 0        
   select @v_count_aluno = isnull(count(*),0)        
   from ly_aluno        
   where aluno = @p_aluno        
           
   if @v_count_aluno = 0        
    set @p_return = 'Aluno não encontrado.'        
           
              
   set @v_count_curriculo = 0        
   select @v_count_curriculo = isnull(count(*),0)        
   from ly_curriculo c, ly_aluno a        
   where a.aluno = @p_aluno        
   and a.curso = c.curso        
   and a.turno = c.turno        
   and a.curriculo = c.curriculo        
           
   if @v_count_curriculo = 0        
    set @p_return = 'Currículo do aluno não encontrado.'        
   else begin        
    set @v_credito_min = 0        
    select @v_credito_min = isnull(credmin_matr,0),@v_credito_max = isnull(credmax_matr,0)        
    from ly_curriculo c, ly_aluno a        
    where a.aluno = @p_aluno        
    and a.curso = c.curso        
    and a.turno = c.turno        
    and a.curriculo = c.curriculo        
   end        
           
   if @p_return = '' begin        
    set @v_credobr_falta = 0        
    exec TOTAL_CREDITO_OBRIG_FALTA @p_sessao_id,@p_aluno,'S','N',@v_credobr_falta output        
            
    set @v_credgrp_falta = 0        
    exec TOTAL_CREDITO_GRUPO_FALTA @p_sessao_id,@p_aluno,'S','N',null, @v_credgrp_falta output        
            
    --soma diferentes disciplinas da matrÝcula, prÚ-matrÝcula e da processa que nÒo serÒo removidas     
    declare @total_cred_matriculados numeric    
    set @total_cred_matriculados = 0       
        
    SELECT @total_cred_matriculados= isnull(SUM(x.CREDITOS),0) FROM    
    (    
     SELECT DISTINCT m.DISCIPLINA, isnull(m.CREDITOS,0) CREDITOS FROM     
     (    
      SELECT d.disciplina, d.CREDITOS    
      FROM LY_DISCIPLINA d  INNER JOIN  LY_PROCESSA_MATRICULA_GRUPO p     
      on d.DISCIPLINA = p.DISCIPLINA    
      WHERE        
      p.DISPENSADA='N'         
      AND p.MATRICULANOVA='S'        
      AND p.SESSAO_ID = @p_SESSAO_ID         
      AND (p.OPCAO IS NULL OR p.OPCAO = 1)        
      AND ((@p_disciplina is not NULL AND p.DISCIPLINA <> @p_disciplina ) or @p_disciplina is null)          
      AND ((@p_ano is not NULL AND p.ANO = @p_ano ) or @p_ano is null)        
      AND ((@p_semestre is not NULL AND p.SEMESTRE = @p_semestre ) or @p_semestre is null)        
    union    
      SELECT d.disciplina, d.CREDITOS    
      FROM LY_DISCIPLINA d  INNER JOIN  LY_PRE_MATRICULA p     
      on d.DISCIPLINA = p.DISCIPLINA    
      WHERE        
      p.DISPENSADA='N'         
      AND (p.OPCAO IS NULL OR p.OPCAO = 1)        
      AND p.ALUNO = @p_aluno     
      AND ((@p_disciplina is not NULL AND p.DISCIPLINA <> @p_disciplina ) or @p_disciplina is null)          
      AND ((@p_ano is not NULL AND p.ANO = @p_ano ) or @p_ano is null)        
      AND ((@p_semestre is not NULL AND p.SEMESTRE = @p_semestre ) or @p_semestre is null)      
    union    
      SELECT d.disciplina, d.CREDITOS    
      FROM LY_DISCIPLINA d  INNER JOIN  LY_MATRICULA p     
      on d.DISCIPLINA = p.DISCIPLINA    
      WHERE         
      p.SIT_MATRICULA In ('Matriculado','Aprovado','Rep Freq','Rep Nota')        
      AND p.ALUNO = @p_aluno        
      AND ((@p_disciplina is not NULL AND p.DISCIPLINA <> @p_disciplina ) or @p_disciplina is null)          
      AND ((@p_ano is not NULL AND p.ANO = @p_ano ) or @p_ano is null)        
      AND ((@p_semestre is not NULL AND p.SEMESTRE = @p_semestre ) or @p_semestre is null)      
      ) m    
      WHERE M.DISCIPLINA NOT IN (SELECT DISCIPLINA FROM LY_REMOVE_MATRICULA_GRUPO R WHERE     
      r.SESSAO_ID = @p_SESSAO_ID) --nÒo estß para ser removida    
   ) x    
    
    declare @qtd_diciplinas numeric    
    set @qtd_diciplinas = 0       
        
    SELECT @qtd_diciplinas= isnull(count(1),0) FROM    
    (    
    --soma diferentes disciplinas da matrÝcula, prÚ-matrÝcula e da processa que nÒo serÒo removidas    
     SELECT DISTINCT m.DISCIPLINA FROM     
     (    
      SELECT d.disciplina    
      FROM LY_DISCIPLINA d  INNER JOIN  LY_PROCESSA_MATRICULA_GRUPO p     
      on d.DISCIPLINA = p.DISCIPLINA    
      WHERE        
      p.DISPENSADA='N'         
      AND p.MATRICULANOVA='S'        
      AND p.SESSAO_ID = @p_SESSAO_ID         
      AND (p.OPCAO IS NULL OR p.OPCAO = 1)        
      AND ((@p_disciplina is not NULL AND p.DISCIPLINA <> @p_disciplina ) or @p_disciplina is null)          
      AND ((@p_ano is not NULL AND p.ANO = @p_ano ) or @p_ano is null)        
      AND ((@p_semestre is not NULL AND p.SEMESTRE = @p_semestre ) or @p_semestre is null)        
    union    
      SELECT d.disciplina    
      FROM LY_DISCIPLINA d  INNER JOIN  LY_PRE_MATRICULA p     
      on d.DISCIPLINA = p.DISCIPLINA    
      WHERE        
      p.DISPENSADA='N'         
      AND (p.OPCAO IS NULL OR p.OPCAO = 1)        
      AND p.ALUNO = @p_aluno     
      AND ((@p_disciplina is not NULL AND p.DISCIPLINA <> @p_disciplina ) or @p_disciplina is null)          
      AND ((@p_ano is not NULL AND p.ANO = @p_ano ) or @p_ano is null)        
      AND ((@p_semestre is not NULL AND p.SEMESTRE = @p_semestre ) or @p_semestre is null)      
    union    
      SELECT d.disciplina    
      FROM LY_DISCIPLINA d  INNER JOIN  LY_MATRICULA p     
      on d.DISCIPLINA = p.DISCIPLINA    
      WHERE         
      p.SIT_MATRICULA In ('Matriculado','Aprovado','Rep Freq','Rep Nota')        
      AND p.ALUNO = @p_aluno        
      AND ((@p_disciplina is not NULL AND p.DISCIPLINA <> @p_disciplina ) or @p_disciplina is null)          
      AND ((@p_ano is not NULL AND p.ANO = @p_ano ) or @p_ano is null)        
      AND ((@p_semestre is not NULL AND p.SEMESTRE = @p_semestre ) or @p_semestre is null)      
      ) m    
      WHERE M.DISCIPLINA NOT IN (SELECT DISCIPLINA FROM LY_REMOVE_MATRICULA_GRUPO R WHERE     
      r.SESSAO_ID = @p_SESSAO_ID) --nÒo estß para ser removida    
   ) x    
         
    if @p_disciplina is not null begin        
  set @v_creditos = 0        
  SELECT @v_creditos= CREDITOS         
  FROM LY_DISCIPLINA  D      
  WHERE D.DISCIPLINA = @p_disciplina        
             
  set @total_cred_matriculados = @total_cred_matriculados + @v_creditos         
  set @qtd_diciplinas = @qtd_diciplinas + 1        
    end        
            
    -- Verifica se existe plano de estudo do aluno no perÝodo        
    set @v_ver_plano_estudo = 'N'        
        
    if @p_plano_estudo = 'S' begin        
  set @v_credito_plano = 0        
  set @v_mensagem = ''        
  set @v_qtd_discip_plano = 0        
  exec VERIFICA_PLANO_ESTUDO @p_aluno,@p_ano,@p_semestre,@v_qtd_discip_plano output,@v_ver_plano_estudo output,@v_credito_plano output,@v_mensagem output        
             
  if @v_mensagem <> ''         
   set @p_return = @v_mensagem        
  else begin        
   if @ver_limite_creditos = 'S' begin        
    if @v_ver_plano_estudo = 'S' begin        
     if @total_cred_matriculados < @v_credito_plano and @v_credito_plano <> 0         
   --set @p_return = 'Pré-matrícula não atinge mínimo de créditos necessários: ' + str(@v_credito_plano)        
   set @p_return = 'Prezado(a) aluno(a), a carga horária mínima para matrícula é'+ str(@v_credito_plano) +'hs. Qualquer dúvida, contate a CAA.'
                
    end        
    else begin        
     if @total_cred_matriculados < @v_credito_min and @total_cred_matriculados < @v_credobr_falta        
   --set @p_return = 'Pré-matrícula não atinge mínimo de créditos: ' + str(@v_credito_min)        
   set @p_return = 'Prezado(a) aluno(a), a carga horária mínima para matrícula é'+ str(@v_credito_min) +'hs. Qualquer dúvida, contate a CAA.'
    end        
               
    if @p_return = '' begin        
     --Verifica se a quantidade de disciplinas matriculadas ┌ maior ou        
     --igual ao do plano de estudo        
     if @v_ver_plano_estudo = 'S' begin        
   if @qtd_diciplinas < @v_qtd_discip_plano and @v_qtd_discip_plano <> 0        
    set @p_return = 'A quantidade de disciplinas é menor que a quantidade mínima de disciplinas do plano de estudos.'
     end        
    end        
   end        
  end         
    end         
   end        
       
   if @ver_limite_creditos = 'S'    
   begin    
       
   if @p_return = '' begin        
   --valida crÚditos mÝnimos    
          
    if @total_cred_matriculados < @v_credito_min        
    --set @p_return = 'Pré-matrícula não atinge mínimo de créditos necessários: ' + str(@v_credito_min)      
	set @p_return = 'Prezado(a) aluno(a), a carga horária mínima para matrícula é'+ str(@v_credito_min) +'hs. Qualquer dúvida, contate a CAA.'
   end     
        
   if @p_return = '' begin        
   --valida crÚditos mßximos    
    if @total_cred_matriculados > @v_credito_max begin        
  if @p_disciplina is not null        
   set @p_return = @p_disciplina + ' não pode ser incluída. Ultrapassou máximo de créditos permitido: ' + str(@v_credito_max)         
  else        
   --set @p_return = 'Pré-matrícula ultrapassou máximo de créditos permitido: ' + str(@v_credito_max)               
   set @p_return = 'Prezado(a) aluno(a), a carga horária máxima para matrícula é'+ str(@v_credito_max) +'hs. Qualquer dúvida, contate a CAA.'
    end        
   end     
         
   end    
        
   if @p_return = '' begin        
    if @ver_limite_creditos = 'S'     
    begin        
  DELETE FROM LY_VALIDA_MATR_CONJUNTO WHERE SESSAO_ID = @p_sessao_id        
             
  insert into LY_VALIDA_MATR_CONJUNTO (sessao_id,disciplina,turma,ano,semestre,grupo_eletiva)         
  select @p_sessao_id,disciplina,turma,ano,semestre,grupo_eletiva         
  from ly_pre_matricula         
  where aluno = @p_Aluno         
  AND (OPCAO IS NULL OR OPCAO = 1)         
  and ano = @p_Ano        
  and semestre = @p_SEMESTRE    
    
  select @v_contexto = contexto from ly_processa_matricula_grupo where sessao_id = @p_sessao_id  
    
  if @v_contexto = '' or @v_contexto is null   
 set @v_contexto = 'Contexto_Tela_Matricula'      
             
  EXEC a_VALIDA_PRE_MATR_CONJUNTO @p_sessao_id,        
           @p_aluno,         
           @p_ano,         
           @p_semestre,         
           @v_valido OUTPUT,         
           @v_msg OUTPUT,        
           @v_contexto,         
     'N','N','N','N','N','S','N','N',        
           @v_credobr_falta,        
           @v_credgrp_falta,        
     'S'        
                   
  if @v_valido = 'N'        
   set @p_return = @v_msg        
             
  DELETE FROM LY_VALIDA_MATR_CONJUNTO WHERE SESSAO_ID = @p_sessao_id         
    end        
   end        
    end             
end       
  