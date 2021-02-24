
  DECLARE @V_CODCURSO VARCHAR(20)  
  DECLARE @V_TURMADTFIM VARCHAR(20)  
  DECLARE @V_DOCENTE  VARCHAR(200)  
  DECLARE @V_COORDENADOR  VARCHAR(200)  
  DECLARE @V_COD_COORD NUMERIC(15)  
  DECLARE @V_NUMFUNC_AUX NUMERIC(15)  
  DECLARE @V_DOL_INFORMAR_DIARIO_AULA_DIA VARCHAR(1)   
  DECLARE @V_DOL_REL_DT_TURMA VARCHAR(1)  
  DECLARE @V_DTINI DATETIME  
  DECLARE @V_DTFIM DATETIME 
  DECLARE @p_disciplina VARCHAR(20)
  DECLARE @p_turma VARCHAR(20)
  DECLARE @p_ano VARCHAR(4)
  DECLARE @p_semestre VARCHAR(2)
  DECLARE @p_numfunc  VARCHAR(20)
  DECLARE @p_subper VARCHAR(20)
  DECLARE @p_nome_compl VARCHAR(100)
  DECLARE @p_is_docente  VARCHAR(1) 
  
  
  --SET @p_disciplina = '148415'
  --SET @p_turma = '04_NUT6AM'
  --SET @p_ano = '2017'
  --SET @p_semestre = '1'
  --SET @p_numfunc = '1687'
  --SET @p_subper = null
  --SET @p_nome_compl = null
  --SET @p_is_docente = 'S'
  
    SET @p_disciplina = '150983'
  SET @p_turma = '05_SIS7AN'
  SET @p_ano = '2017'
  SET @p_semestre = '1'
  SET @p_numfunc = '1555'
  SET @p_subper = null
  SET @p_nome_compl = null
  SET @p_is_docente = 'S'
      
 -- PREENCHE TABELA TEMPORÁRIA                                
 CREATE TABLE #DIARIOE (  
  DTFIMTURMA  VARCHAR(20) COLLATE LATIN1_GENERAL_CI_AI,  
  DOCENTE   VARCHAR(200) COLLATE LATIN1_GENERAL_CI_AI,  
  COORDENADOR VARCHAR(200) COLLATE LATIN1_GENERAL_CI_AI,  
  DATA    DATE ,  
  AULA    NUMERIC(3,0),  
  HORARIO   DATETIME,                               
  ITENS    VARCHAR(20) COLLATE LATIN1_GENERAL_CI_AI ,  
  ASSUNTO   VARCHAR(2000) COLLATE LATIN1_GENERAL_CI_AI ,  
  CONTEUDO  VARCHAR(2000) COLLATE LATIN1_GENERAL_CI_AI   
 )      
   
 SET @V_DOL_INFORMAR_DIARIO_AULA_DIA = 'N'  
 SET @V_DOL_REL_DT_TURMA = 'N'  
   
 SELECT @V_DOL_INFORMAR_DIARIO_AULA_DIA = ISNULL(DOL_INFORMAR_DIARIO_AULA_DIA,'N'),  
     @V_DOL_REL_DT_TURMA = ISNULL(DOL_REL_DT_TURMA,'N')  
 FROM LY_OPCOES_ONLINE  
    
 SELECT  @V_CODCURSO = a.CURSO, @V_TURMADTFIM = CONVERT(VARCHAR,a.dt_fim,103)  
 FROM ly_turma a   
 WHERE a.turma = @p_turma  
  AND a.disciplina = @p_disciplina  
  AND a.ano = @p_ano   
  AND a.semestre =  @p_semestre   
   
    
 IF @V_DOL_REL_DT_TURMA = 'N'  
   SET @V_TURMADTFIM = CONVERT(VARCHAR,GETDATE(),103)  
     
 SET @V_DOCENTE = ''  
 SET @V_COORDENADOR = ''  
 SET @V_COD_COORD = 0  
 IF @p_is_docente = 'S'   
  BEGIN  
   SET @V_DOCENTE = @p_nome_compl  
   -- Obtem Coordenador  
   IF @V_CODCURSO <> ''   
       -- Busca, primeiramente, o coordenador da turma selecionada  
     SELECT @V_COD_COORD = ct.num_func  
     FROM ly_grade_turma gt   
      JOIN ly_coord_turma ct   
       ON gt.grade_id = ct.grade_id   
     WHERE ct.utiliza_diario = 'S'   
         AND gt.disciplina = @p_disciplina  
         AND gt.turma = @p_turma  
         AND gt.ano = @p_ano  
         AND gt.semestre = @p_semestre  
       
     -- Não achou o coordenador da turma      
     IF @V_COD_COORD = 0  
      BEGIN  
      -- Busca, primeiramente, o coordenador da turma selecionada  
       SELECT @V_COD_COORD = c.num_func  
       FROM ly_coordenacao c,    
          ly_curriculo_unidade_fisica u    
       WHERE u.curso = c.curso    
       AND u.turno = c.turno    
       AND u.curriculo = c.curriculo    
       AND c.curso = @V_CODCURSO    
       AND turma_associada = @p_turma   
      END  
  
     IF @V_COD_COORD = 0  
      BEGIN  
      -- Não encontrou o coordenador de turma  
      -- Busca o coordenador de turma graduação  
       SELECT @V_COD_COORD = num_func   
       FROM ly_coord_turma_graduacao   
       WHERE periodo = @p_semestre  
           AND disciplina = @p_disciplina  
          AND turma = @p_turma  
          AND ano = @p_ano  
           AND utiliza_diario = 'S'    
          AND ISNULL(DT_INI, convert(datetime, CONVERT(varchar(10), GETDATE(), 112) )) <= convert(datetime, CONVERT(varchar(10), GETDATE(), 112) )  
          AND ISNULL(DT_FIM, convert(datetime, CONVERT(varchar(10), GETDATE(), 112) )) >= convert(datetime, CONVERT(varchar(10), GETDATE(), 112) )  
      END  
             
     IF @V_COD_COORD = 0  
      BEGIN  
       -- Não encontrou o coordenador de turma graduação  
       -- Busca o coordenador do curso da turma selecionada  
       SELECT @V_COD_COORD = NUM_FUNC  
       FROM ly_coordenacao   
       WHERE curso = @V_CODCURSO  
             AND curriculo is null   
             AND turno is null   
             AND ( unid_fisica in (  
              SELECT faculdade FROM ly_turma   
              WHERE disciplina = @p_disciplina   
               AND turma = @p_turma   
               AND ano = @p_ano   
               AND semestre = @p_semestre   
              ) )    
            AND ISNULL(DT_INI,convert(datetime, CONVERT(varchar(10), GETDATE(), 112) ))<=convert(datetime, CONVERT(varchar(10), GETDATE(), 112) )  
            AND ISNULL(DT_FIM,convert(datetime, CONVERT(varchar(10), GETDATE(), 112) ))>=convert(datetime, CONVERT(varchar(10), GETDATE(), 112) )  
      END  
          
     IF @V_COD_COORD = 0  
      BEGIN  
       SELECT @V_COD_COORD = c.NUM_FUNC  
        FROM   ly_coordenacao c, ly_turma t   
        WHERE c.curso = t.curso   
        AND t.disciplina =  @p_disciplina    
        AND t.turma =  @p_turma    
        AND t.ano =  @p_ano    
        AND t.semestre =  @p_semestre    
        AND c.unid_fisica IS NULL    
        AND c.curriculo = t.curriculo   
        AND c.turno = t.turno   
             AND  ISNULL(c.DT_INI,convert(datetime, CONVERT(varchar(10), GETDATE(), 112) ))<=convert(datetime, CONVERT(varchar(10), GETDATE(), 112) )  
        AND  ISNULL(c.DT_FIM,convert(datetime, CONVERT(varchar(10), GETDATE(), 112) ))>=convert(datetime, CONVERT(varchar(10), GETDATE(), 112) )  
      END  
        
     IF @V_COD_COORD = 0  
      BEGIN        
         SELECT @V_COD_COORD =  NUM_FUNC  
         FROM ly_coordenacao   
       WHERE curso = @V_CODCURSO   
          AND curriculo IS NULL   
          AND turno IS NULL    
          AND unid_fisica IS NULL     
          AND ISNULL(DT_INI,convert(datetime, CONVERT(varchar(10), GETDATE(), 112) ))<=convert(datetime, CONVERT(varchar(10), GETDATE(), 112) )  
         AND ISNULL(DT_FIM,convert(datetime, CONVERT(varchar(10), GETDATE(), 112) ))>=convert(datetime, CONVERT(varchar(10), GETDATE(), 112) )  
      END                           
          
    -- Busca o nome do coordenador  
    IF @V_COD_COORD = 0  
     SET @V_COORDENADOR = ''   
    ELSE  
     SELECT @V_COORDENADOR = nome_compl   
     FROM ly_docente   
     WHERE num_func = @V_COD_COORD    
   -------------------------------------------------------------------------------------  
   END  
 ELSE  
  BEGIN  
   SET @V_COORDENADOR = @p_nome_compl  
   SELECT @V_DOCENTE = NOME_COMPL FROM LY_DOCENTE WHERE NUM_FUNC = @p_numfunc  
  END  
   
    
 IF NOT @p_subper IS NULL  
  BEGIN  
   SELECT @V_DTINI = DT_INICIO, @V_DTFIM = DT_FIM  
   FROM LY_SUBPERIODO_LETIVO  
   WHERE ANO = @p_ano AND PERIODO = @p_semestre AND SUBPERIODO = @p_subper  
  END  
   
 SET @V_NUMFUNC_AUX = @p_numfunc  
 -- Se for coordenador não deve filtrar pelo numfunc  
 IF @p_is_docente = 'N'  
  SET @V_NUMFUNC_AUX = NULL  
   
  IF @V_DOL_INFORMAR_DIARIO_AULA_DIA = 'S'   
    BEGIN  
   INSERT INTO #DIARIOE  
   SELECT @V_TURMADTFIM,  
     @V_DOCENTE,  
     @V_COORDENADOR,  
     ag.DATA AS data,   
     ag.AULA AS aula,  
     ag.HORA_INICIO AS hora_inicio,  
     pdp.AULA AS item,  
     pdp.ASSUNTO_ATIVIDADES as ASSUNTO_ATIVIDADES ,    
     de.COMENTARIOS AS comentarios   
   FROM (SELECT DATA, COUNT(AULA) AS AULA, MIN(AGENDA) AS AGENDA, HORA_INICIO  
      FROM LY_AGENDA  
      WHERE DISCIPLINA = @p_disciplina  
       AND TURMA = @p_turma  
       AND ANO = @p_ano  
       AND SEMESTRE = @p_semestre  
       AND (@V_NUMFUNC_AUX IS NULL OR NUM_FUNC = @V_NUMFUNC_AUX)  
       AND (@p_subper IS NULL OR (DATA >= @V_DTINI AND DATA<= @V_DTFIM))  
       AND CANCELADA = 'N'  
      GROUP BY DATA, HORA_INICIO) ag  
    LEFT OUTER JOIN LY_DIARIO_ELETRONICO de   
     ON ag.AGENDA = de.AGENDA   
    LEFT OUTER JOIN LY_PLAN_DIDAT_PEDAG_T pdp   
     ON de.DISCIPLINA = pdp.DISCIPLINA   
      AND de.TURMA = pdp.TURMA   
      AND de.ANO = pdp.ANO   
      AND de.SEMESTRE = pdp.SEMESTRE   
      AND de.AULA = pdp.AULA   
      ORDER BY ag.DATA, ag.AULA  
    END  
  ELSE  
   BEGIN  
   INSERT INTO #DIARIOE  
   SELECT @V_TURMADTFIM,  
     @V_DOCENTE,  
     @V_COORDENADOR,  
     ag.DATA AS data,   
     ag.AULA AS aula,  
     ag.HORA_INICIO AS hora_inicio,  
     pdp.AULA AS item,   
     pdp.ASSUNTO_ATIVIDADES as ASSUNTO_ATIVIDADES ,    
     de.COMENTARIOS AS comentarios   
   FROM LY_AGENDA ag   
    LEFT OUTER JOIN LY_DIARIO_ELETRONICO de   
     ON ag.AGENDA = de.AGENDA   
    LEFT OUTER JOIN LY_PLAN_DIDAT_PEDAG_T pdp   
     ON de.DISCIPLINA = pdp.DISCIPLINA   
      AND de.TURMA = pdp.TURMA   
      AND de.ANO = pdp.ANO   
      AND de.SEMESTRE = pdp.SEMESTRE   
      AND de.AULA = pdp.AULA   
   WHERE ag.DISCIPLINA = @p_disciplina   
     AND ag.TURMA = @p_turma   
     AND ag.ANO = @p_ano   
     AND ag.SEMESTRE = @p_semestre   
     AND ag.CANCELADA = 'N'   
     AND (@V_NUMFUNC_AUX IS NULL OR ag.NUM_FUNC = @V_NUMFUNC_AUX)  
     AND (@p_subper IS NULL OR (ag.DATA >= @V_DTINI AND ag.DATA<= @V_DTFIM))  
      ORDER BY ag.DATA, ag.AULA  
    END  
    
 -- EXIBE O RESULTADO DO SELECT   
    SELECT * FROM #DIARIOE   
          
    -- APAGA A TABELA TEMPORÁRIA  
    DROP TABLE #DIARIOE  
   
END;       