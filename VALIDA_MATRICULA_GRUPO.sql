USE LYCEUM
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.VALIDA_MATRICULA_GRUPO'))
   exec('CREATE PROCEDURE [dbo].[VALIDA_MATRICULA_GRUPO] AS BEGIN SET NOCOUNT OFF; END')
GO 
  
ALTER procedure VALIDA_MATRICULA_GRUPO   
(  
@p_SESSAO_ID varchar(40),  
@p_aluno T_CODIGO,   
@p_ano T_ANO,  
@p_semestre T_SEMESTRE2,  
@p_pre_matricula T_SIMNAO = 'N',  
@p_plano_estudo T_SIMNAO = 'S',  
@p_ChamaMatrGrupoSoPorExcl T_SIMNAO = 'N')  
as  
-- ################################################################################################  
-- <DOC> Descricao:  
-- <DOC>  
-- <DOC> Inserir as prÚ-matrÝculas ou matrÝculas em conjunto.  
-- <DOC>   
-- <DOC> Parametros:  
-- <DOC>   
-- <DOC> @p_sessao_id varchar(40) - id da conexÒo  
-- <DOC> @p_aluno T_CODIGO - c¾digo do aluno  
-- <DOC> @p_ano T_ANO - ano da matrÝcula  
-- <DOC> @p_semestre T_SEMESTRE2 - perÝodo da matrÝcula  
-- <DOC> @p_pre_matricula varchar(1) - se Ú prÚ-matricula  
-- <DOC> @p_plano_estudo varchar(1) - se verifica plano de estudo - utilizado somente nas telas de prÚ-matrÝcula e matrÝcula privilegiada, senÒo Ú False  
-- <DOC> @p_ChamaMatrGrupoSoPorExcl T_SIMNAO - se verificar n·mero de disciplinas de grupo por sÚrie - somente na remoþÒo de disciplinas pelo on line  
-- <DOC>   
-- <DOC> Retorno:  
-- <DOC>  
-- <DOC> Nenhum (procedure)  
-- <DOC>   
-- <DOC> Roteiro de execuþÒo:  
-- <DOC>  
-- <DOC> 1. Se @p_plano_estudo = 'S', busca a opþÒo (FN_BUSCAR_OPCAO_ALUNO) e se VERIFICA_PLANO_ESTUDO = 'S'   
-- <DOC>    (tabela LY_OPCOES) verifica se existe o plano de estudo do aluno e busca os crÚditos e quantidade de disciplinas cadastrados.  
-- <DOC> 2. Busca na tabela LY_PROCESSA_MATRICULA_GRUPO o VERLIMITESCREDITOS, se existe for 'S', verifica:  
-- <DOC>    - soma a quantidade de disciplinas e de crÚditos matriculados  
-- <DOC>    - se VERIFICA_PLANO_ESTUDO = 'S' verifica mÝnimo e mßximo de crÚditos da matrÝcula com os crÚditos   
-- <DOC>       do plano de estudo senÒo com os do currÝculo.  
-- <DOC>    - se VERIFICA_PLANO_ESTUDO = 'S' verifica a quantidade de disciplinas da matrÝcula com a do plano de estudo     
-- <DOC> 3. Se contexto diferente de 'Tela de MatriculaN' insere os registros de matrÝcula na tabela LY_VALIDA_MATR_CONJUNTO,  
-- <DOC>    calcula o total de crÚditos que falta cursar da grade (TOTAL_CREDITO_OBRIG_FALTA) e do grupo (TOTAL_CREDITO_GRUPO_FALTA)  
-- <DOC>    e executa o entry-point a_VALIDA_PRE_MATR_CONJUNTO ou a_VALIDA_MATR_CONJUNTO.  
-- <DOC> 4. Se @p_ChamaMatrGrupoSoPorExcl = 'N' e nÒo ocorreu erro no entry-point e o contexto for 'Matricula pela Internet' verifica se o aluno estß cursando o n·mero de disciplinas   
-- <DOC>    de grupo obrigat¾rias na sua sÚrie.  
-- <DOC>  
-- ################################################################################################  
   
  declare @v_erro      varchar(2000)  
 declare @v_tem_erro     T_SIMNAO  
 declare @v_sit_aluno    varchar(15)  
 declare @v_disciplina    T_CODIGO  
 declare @v_curso     T_CODIGO  
 declare @v_turno     T_CODIGO  
 declare @v_curriculo    T_CODIGO  
 declare @v_serie     T_NUMERO_PEQUENO  
 declare @v_ver_plano_estudo   T_SIMNAO  
 declare @v_cont      numeric(18)  
 declare @v_opcao_aluno    numeric(6)   
 declare @v_tot_creditos_plano  T_DECIMAL_MEDIO  
 declare @v_QTDE_DISCIP    T_NUMERO_PEQUENO  
 declare @v_curr_credmin_matr  T_DECIMAL_MEDIO  
 declare @v_curr_credmax_matr  T_DECIMAL_MEDIO  
 declare @v_dt_confirmacao   varchar(25)  
 declare @v_dt_insercao    varchar(25)  
 declare @v_dt_matricula    varchar(25)  
 declare @v_cred_grp_falta   T_DECIMAL_MEDIO  
 declare @v_cred_obrg_falta   T_DECIMAL_MEDIO  
 declare @v_mga_contexto    varchar(100)  
 declare @v_mga_ver_plan_est   T_SIMNAO  
 declare @v_mga_ver_lim_cred   T_SIMNAO  
 declare @v_mga_ver_max_reprov  T_SIMNAO  
 declare @v_mga_ver_vaga    T_SIMNAO  
 declare @v_mga_ver_grade   T_SIMNAO  
 declare @v_mga_ver_horario   T_SIMNAO  
 declare @v_mga_ver_pre_req   T_SIMNAO  
 declare @v_mga_ver_disci_adap  T_SIMNAO  
 declare @v_retorno_sp    T_SIMNAO      
 declare @v_valido     T_SIMNAO      
   
 begin  
  
  -- Armazena valores padrÒo dos parÔmetros de entrada  
  if @p_pre_matricula is null  
   SET @p_pre_matricula = 'N'  
  if @p_plano_estudo is null  
   SET @p_plano_estudo = 'N'  
  if @p_ChamaMatrGrupoSoPorExcl is null  
   SET @p_ChamaMatrGrupoSoPorExcl = 'N'  
     
  -- Inicializa varißveis  
  SET @v_tem_erro = 'N'  
  SET @v_mga_contexto = null  
  SET @v_ver_plano_estudo = 'N'  
  SET @v_mga_ver_plan_est = 'N'  
  SET @v_mga_ver_lim_cred = 'S'  
  SET @v_mga_ver_max_reprov = 'S'  
  SET @v_mga_ver_vaga = 'S'  
  SET @v_mga_ver_grade = 'S'  
  SET @v_mga_ver_horario = 'S'  
  SET @v_mga_ver_pre_req = 'S'  
  SET @v_mga_ver_disci_adap = 'S'  
  
  -- Valida parÔmetros  
  if @p_aluno is null  
   begin  
    set @v_tem_erro= 'S'    
    EXEC SetErro 'Erro na validação do grupo de matrícula. O aluno não foi informado.'    
   end  
  else  
   begin  
    select @v_cont=COUNT(aluno)  
    from LY_ALUNO where ALUNO=@p_aluno  
    if @v_cont=0  
     begin  
      set @v_tem_erro= 'S'    
      EXEC SetErro 'Erro na validação do grupo de matrícula. O aluno informado não existe.',''    
     end  
    else  
     begin  
      select @v_curriculo=a.CURRICULO,@v_sit_aluno=a.SIT_ALUNO,@v_curr_credmin_matr=c.CREDMIN_MATR,  
        @v_curr_credmax_matr=c.CREDMAX_MATR,@v_curso=a.CURSO,@v_turno=a.TURNO,@v_serie=a.SERIE  
      from LY_ALUNO a   
      left join LY_CURRICULO c on a.CURRICULO=c.CURRICULO and a.TURNO=c.TURNO and a.CURSO=c.CURSO   
      where ALUNO=@p_aluno  
      if @v_sit_aluno <> 'Ativo'  
       begin  
        set @v_tem_erro= 'S'    
        EXEC SetErro 'Erro na validação do grupo de matrícula. O aluno informado não está ativo.',''    
       end   
      if @v_curriculo is null  
       begin  
        set @v_tem_erro= 'S'    
        EXEC SetErro 'Erro na validação do grupo de matrícula. O currículo do aluno não foi informado.',''    
       end   
     end  
   end   
  if @p_ano is null  
   begin  
    set @v_tem_erro= 'S'    
    EXEC SetErro 'Erro na validação do grupo de matrícula. O ano não foi informado.',''    
   end  
  if @p_semestre is null  
   begin  
    set @v_tem_erro= 'S'    
    EXEC SetErro 'Erro na validação do grupo de matrícula. O período não foi informado.',''    
   end  
    
    
  if @v_tem_erro='S'  
   return  
  
 -- obtÚm o campo que define se existem ou nÒo limites de crÚditos para a matrÝcula  
 select @v_mga_ver_lim_cred=isnull(max(mga.VERLIMITESCREDITOS), 'N')  
 from LY_PROCESSA_MATRICULA_GRUPO mga   
 where SESSAO_ID = @p_SESSAO_ID   
        
   if @p_pre_matricula = 'S'  and @v_mga_ver_lim_cred = 'S'  
   begin  
    --soma diferentes disciplinas da matrÝcula, prÚ matrÝcula e da processa que nÒo serÒo removidas   
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
       AND ((@p_ano is not NULL AND p.ANO = @p_ano ) or @p_ano is null)      
       AND ((@p_semestre is not NULL AND p.SEMESTRE = @p_semestre ) or @p_semestre is null)    
     union  
       SELECT d.disciplina, d.CREDITOS  
       FROM LY_DISCIPLINA d  INNER JOIN  LY_MATRICULA p   
       on d.DISCIPLINA = p.DISCIPLINA  
       WHERE       
       p.SIT_MATRICULA In ('Matriculado','Aprovado','Rep Freq','Rep Nota')      
       AND p.ALUNO = @p_aluno      
       AND ((@p_ano is not NULL AND p.ANO = @p_ano ) or @p_ano is null)      
       AND ((@p_semestre is not NULL AND p.SEMESTRE = @p_semestre ) or @p_semestre is null)    
       ) m  
       WHERE M.DISCIPLINA NOT IN (SELECT DISCIPLINA FROM LY_REMOVE_MATRICULA_GRUPO R WHERE   
       r.SESSAO_ID = @p_SESSAO_ID) --nÒo estß para ser removida  
    ) x  
       
     --valida creditos mÝnimos  
    if @total_cred_matriculados < @v_curr_credmin_matr      
    begin  
     --set @v_erro = 'Pré-matrícula não atinge mínimo de créditos necessários: ' + str(@v_curr_credmin_matr)      
	 set @v_erro = 'Prezado(a) aluno(a), a carga horária mínima para matrícula é'+ str(@v_curr_credmin_matr) +'hs. Qualquer dúvida, contate a CAA.'
     EXEC SetErro @v_erro,''    
    end  
  end  
  -- Verifica se as disciplinas matriculadas sÒo compatÝveis com o plano de estudo do aluno  
  -- Obs: somente quando nÒo Ú prÚ-matrÝcula  
  if @p_pre_matricula <> 'S'   
   begin  
    --checa se todas as disciplinas sÒo vßlidas  
    select @v_disciplina=MAX(disciplina)   
    from LY_PROCESSA_MATRICULA_GRUPO mga  
    where SESSAO_ID = @p_SESSAO_ID   
    and NOT exists(select d.DISCIPLINA from LY_DISCIPLINA d where d.DISCIPLINA=mga.DISCIPLINA)  
      
    if @v_disciplina is not null  
     begin  
      set @v_erro='Erro na validação do grupo de matrícula. A disciplina informada ''' + @v_disciplina + ''' não existe.'  
      EXEC SetErro @v_erro,''    
      return  
     end  
       
     -- Calcula totais de crÚditos e quantidade de disciplinas  
     declare @v_tot_creditos numeric(18)  
     declare @v_qtde_disci_mat numeric(18)  
       
     select @v_qtde_disci_mat=COUNT(mga.disciplina),@v_tot_creditos=SUM(d.CREDITOS)  
     from LY_PROCESSA_MATRICULA_GRUPO mga  
     left join LY_DISCIPLINA d on mga.DISCIPLINA=d.DISCIPLINA  
     where SESSAO_ID = @p_SESSAO_ID and SIT_MATRICULA  in('Matriculado','Aprovado','Espera','Rep Freq','Rep Nota')  
  
    -- Verifica plano de estudo  
    if @p_plano_estudo = 'S'  
     begin  
      set @v_opcao_aluno = dbo.FN_BUSCAR_OPCAO_ALUNO(@p_aluno)  
      SELECT @v_ver_plano_estudo=isnull(max(VERIFICA_PLANO_ESTUDO),'N') FROM LY_OPCOES WHERE CHAVE = @v_opcao_aluno  
        
      select @v_tot_creditos_plano=ISNULL(max(CREDITOS),0), @v_QTDE_DISCIP=ISNULL(max(QTDE_DISCIP),0),@V_cont=COUNT(*)  
      FROM LY_PLANO_ESTUDO   
      WHERE ALUNO = @p_aluno and ANO=@p_ano and PERIODO=@p_semestre   
        
      if @v_cont = 0  
       set @v_ver_plano_estudo='N'  
     end  
          
    if @v_mga_ver_lim_cred = 'S'  
     begin  
      -- Verifica mÝnimo de crÚditos por matrÝcula  
      if @v_ver_plano_estudo = 'S'  
       begin  
        if @v_tot_creditos < @v_tot_creditos_plano and @v_tot_creditos_plano <> 0  
         begin  
          set @v_erro='Erro na validação do grupo de matrícula. A matrícula não atinge o número mínimo de ' + str(@v_tot_creditos_plano) + ' créditos.'  
          EXEC SetErro @v_erro,''    
          return  
         end  
       end  
      else  
       begin  
        if @v_tot_creditos < @v_curr_credmin_matr  
         begin  
          set @v_erro='Erro na validação do grupo de matrícula. A matrícula não atinge o número mínimo de ' + str(@v_curr_credmin_matr) + ' créditos.'  
          EXEC SetErro @v_erro,''    
          return  
         end  
       end  
        
      -- Verifica mßximo de crÚditos por matrÝcula  
      if @v_tot_creditos > @v_curr_credmax_matr  
       begin  
        set @v_erro='Erro na validação do grupo de matrícula. A matrícula ultrapassa o número máximo de ' + str(@v_curr_credmax_matr) + ' créditos.'
        EXEC SetErro @v_erro,''    
        return  
       end  
         
      --  Verifica se a quantidade de disciplinas matriculadas Ú maior ou igual ao do plano de estudo  
      if @v_ver_plano_estudo = 'S'  
       begin  
        --Verifica a quantidade de disciplinas do plano do aluno  
        if @v_qtde_disci_mat < @v_QTDE_DISCIP and @v_QTDE_DISCIP <> 0  
         begin  
          set @v_erro='Erro na validação do grupo de matrícula. A quantidade de disciplinas é menor que a quantidade mínima de disciplinas do plano de estudos.'  
          EXEC SetErro @v_erro,''    
          return  
         end  
          
       end       
     end  
   end  
  
  -- obtÚm o contexto da matrÝcula  
  select @v_mga_contexto=max(mga.CONTEXTO)  
  from LY_PROCESSA_MATRICULA_GRUPO mga   
  where SESSAO_ID = @p_SESSAO_ID   
    
    
    
  if ISNULL(@v_mga_contexto,'') <> 'Tela de MatriculaN'  
   begin  
    exec TOTAL_CREDITO_OBRIG_FALTA @p_SESSAO_ID, @p_aluno, 'S', 'N', @v_cred_obrg_falta output  
    exec TOTAL_CREDITO_GRUPO_FALTA @p_SESSAO_ID, @p_aluno, 'S', 'N','', @v_cred_grp_falta output  
      
    exec BUSCA_DISCIPLINAS_PENDENTES @p_SESSAO_ID, @p_aluno, null, null, null, null, null, null, null, null, null,  
    @v_retorno_sp output, @v_erro output  
      
    if @v_retorno_sp = 'N'  
     begin  
      return  
     end  
       
    DELETE FROM LY_VALIDA_MATR_CONJUNTO WHERE SESSAO_ID = @p_SESSAO_ID  
      
    INSERT INTO LY_VALIDA_MATR_CONJUNTO  
    SELECT SESSAO_ID, DISCIPLINA, TIPO, TURMA, ANO, SEMESTRE, SUBTURMA1, SUBTURMA2,  
     SIT_MATRICULA, SIT_DETALHE, OBS, MATRICULANOVA, SERIE_IDEAL, SERIE_CALCULO,  
     COBRANCA_SEP, DT_CONFIRMACAO, DT_INSERCAO, DT_MATRICULA, GRUPO_ELETIVA,   
     CONFIRMACAO_LIDER, ALOCADO, OPCAO, DISCIPLINA_SUBST, TURMA_SUBST, CONTEXTO,  
     VERMAXREPROVACAO, VERVAGA, VERGRADE, VERHORARIO, VERPREREQ, VERLIMITESCREDITOS,  
     VERDISCIPADAP, VERPLANOESTUDO, VERGRUPO  
    FROM LY_PROCESSA_MATRICULA_GRUPO   
    WHERE SESSAO_ID = @p_SESSAO_ID  
      
  
    declare @v_qte_mga numeric(18)  
    select @v_qte_mga=count(1) from LY_PROCESSA_MATRICULA_GRUPO where SESSAO_ID = @p_SESSAO_ID   
    if @v_qte_mga = 0  
     begin  
      set @v_mga_ver_max_reprov = 'S'  
      set @v_mga_ver_vaga = 'S'   
      set @v_mga_ver_grade = 'S'    
      set @v_mga_ver_horario = 'S'     
      set @v_mga_ver_pre_req = 'S'     
      set @v_mga_ver_lim_cred = 'N'    
      set @v_mga_ver_disci_adap = 'S'     
      set @v_mga_ver_plan_est = 'S'    
     end  
    else  
     begin  
      -- obtÚm as flags utilizadas na validaþÒo  
      select @v_mga_ver_max_reprov=isnull(max(mga.VERMAXREPROVACAO), 'N'),  
       @v_mga_ver_vaga=isnull(max(mga.VERVAGA), 'N'),  
       @v_mga_ver_grade=isnull(max(mga.VERGRADE), 'N'),  
       @v_mga_ver_horario=isnull(max(mga.VERHORARIO), 'N'),  
       @v_mga_ver_pre_req=isnull(max(mga.VERPREREQ), 'N'),  
       @v_mga_ver_lim_cred=isnull(max(mga.VERLIMITESCREDITOS), 'N'),  
       @v_mga_ver_disci_adap=isnull(max(mga.VERPLANOESTUDO), 'N'),  
       @v_mga_ver_plan_est=isnull(max(mga.VERPLANOESTUDO), 'N')  
      from LY_PROCESSA_MATRICULA_GRUPO mga   
      where SESSAO_ID = @p_SESSAO_ID   
     end  
      
    if @p_pre_matricula = 'N'  
     begin  
      exec a_VALIDA_MATR_CONJUNTO @p_sessao_id,    
           @p_aluno,     
           @p_ano,     
           @p_semestre,     
           @v_valido OUTPUT,     
           @v_erro OUTPUT,    
           @v_mga_contexto,     
           @v_mga_ver_max_reprov,     
           @v_mga_ver_vaga,     
           @v_mga_ver_grade,     
           @v_mga_ver_horario,     
           @v_mga_ver_pre_req,     
           @v_mga_ver_lim_cred,     
           @v_mga_ver_disci_adap,     
           @v_mga_ver_plan_est,    
           @v_cred_obrg_falta,    
           @v_cred_grp_falta                            
     end  
    else  
     begin  
      exec a_VALIDA_PRE_MATR_CONJUNTO @p_sessao_id,    
           @p_aluno,     
           @p_ano,     
           @p_semestre,     
           @v_valido OUTPUT,     
           @v_erro OUTPUT,    
           @v_mga_contexto,     
           @v_mga_ver_max_reprov,     
           @v_mga_ver_vaga,     
           @v_mga_ver_grade,     
           @v_mga_ver_horario,     
           @v_mga_ver_pre_req,     
           @v_mga_ver_lim_cred,     
           @v_mga_ver_disci_adap,     
           @v_mga_ver_plan_est,    
           @v_cred_obrg_falta,    
           @v_cred_grp_falta,  
           'S'  
     end  
      
    if @p_ChamaMatrGrupoSoPorExcl = 'N'  
     begin   
      if @v_valido = 'S' and @v_mga_contexto = 'Matricula pela Internet'    
        
       begin  
        --------------------------------------------------------------------------------------------------------------------------------  
        -- INICIO  
        --------------------------------------------------------------------------------------------------------------------------------  
        --Verificar:  
        --Implementar um novo campo na aba de sÚries por grupo de disciplina, tela de currÝculos, para indicar o n·mero de  
        --disciplinas eletivas que o aluno deverß cursar daquele grupo naquela sÚrie. O nome do campo Ú "N·mero Disciplinas MatrÝcula".  
        --------------------------------------------------------------------------------------------------------------------------------  
        
        declare @v_grp_eletiva   varchar(2000)  
        declare @v_grp_eletiva_aux  varchar(2000)  
        declare @v_deletar    T_SIMNAO  
        declare @v_num_disci_matr  numeric(18)  
        declare @v_qdt_disci_matr_pre numeric(18)  
  
        SET @v_deletar = 'N'  
  
        declare C_SERIE_GRP_ELETIVAS cursor static for  
        select distinct GRUPO_DISC  
        from LY_SERIE_GRP_ELETIVAS  
        where CURSO = @v_curso and CURRICULO = @v_curriculo and TURNO = @v_turno and SERIE = @v_serie  
            
        open C_SERIE_GRP_ELETIVAS  
        fetch next from C_SERIE_GRP_ELETIVAS  
        into @v_grp_eletiva_aux  
          
        while (@@fetch_status = 0 and @v_deletar = 'N')          
         begin  
          set @v_num_disci_matr = 0  
          set @v_qdt_disci_matr_pre = 0  
            
          -- ObtÚm a quantidade de sÚries eletivas  
          select @v_num_disci_matr=isnull(num_disciplinas_matricula, 0)      
          from LY_SERIE_GRP_ELETIVAS  
          where CURSO = @v_curso and CURRICULO = @v_curriculo and TURNO = @v_turno and SERIE = @v_serie and GRUPO_DISC = @v_grp_eletiva_aux  
            
          -- ObtÚm a quantidade de matrÝculas ou prÚ-matrÝculas eletivas existentes  
          if @v_num_disci_matr > 0  
           begin  
            select @v_qdt_disci_matr_pre=isnull(count(p.disciplina),0)  
            from LY_PROCESSA_MATRICULA_GRUPO p  
            where p.SESSAO_ID = @p_SESSAO_ID   
             and exists   
             (  
              select 1   
              from LY_GRADE_ELETIVAS ge  
              where ge.CURSO = @v_curso  
               and ge.CURRICULO = @v_curriculo  
               and ge.TURNO = @v_turno  
               and ge.grupo_disc = @v_grp_eletiva_aux  
               and ge.grupo_disc = p.grupo_eletiva   
               and ge.disciplina = p.disciplina  
             )  
              
            if ((@v_num_disci_matr <> @v_qdt_disci_matr_pre) and @v_qdt_disci_matr_pre <> 0)  
             begin  
              set @v_grp_eletiva = @v_grp_eletiva_aux  
              set @v_deletar = 'S'  
             end  
           end  
       
          fetch next from C_SERIE_GRP_ELETIVAS  
          into @v_grp_eletiva_aux  
         end  
        CLOSE C_SERIE_GRP_ELETIVAS          
        DEALLOCATE C_SERIE_GRP_ELETIVAS    
        
        if @v_deletar = 'S'  
         begin  
          if @p_pre_matricula = 'S'  
            set @v_erro = 'Não foram pré-matriculadas a quantidade obrigatória de ''' + str(@v_num_disci_matr) + ''' disciplina(s) do grupo de eletivas ''' + @v_grp_eletiva + '''.'  
          else  
            set @v_erro = 'Não foram matriculadas a quantidade obrigatória de ''' + str(@v_num_disci_matr) + ''' disciplina(s) do grupo de eletivas ''' + @v_grp_eletiva + '''.'  
          EXEC SetErro @v_erro,''  
          return  
         end  
          
        ----------------------------------------------------------------------------------------------------------------------------------  
        -- FIM  
        ----------------------------------------------------------------------------------------------------------------------------------  
        -- Verificar:  
        -- Implementar um novo campo na aba de sÚries por grupo de disciplina, tela de currÝculos, para indicar o n·mero de  
        -- disciplinas eletivas que o aluno deverß cursar daquele grupo naquela sÚrie. O nome do campo Ú "N·mero Disciplinas MatrÝcula".  
        ----------------------------------------------------------------------------------------------------------------------------------   
          
       end  
     end    
   end  
     
  DELETE FROM LY_VALIDA_MATR_CONJUNTO WHERE SESSAO_ID = @p_SESSAO_ID  
  if @v_valido = 'N'  
   EXEC SetErro @v_erro,''  
 end -- Fim da SP  
     