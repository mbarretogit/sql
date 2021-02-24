  
CREATE PROCEDURE s_calcula_valor_disciplina  
  @p_aluno T_CODIGO,   
  @p_ano T_ANO,  
  @p_periodo T_SEMESTRE2,  
  @p_curso T_CODIGO,   
  @p_turno T_CODIGO,    
  @p_curriculo T_CODIGO,   
  @p_serie T_NUMERO_PEQUENO,   
  @p_disciplina T_CODIGO,   
  @p_valor_disciplina DECIMAL(14,2) output,   
  @p_codigo_lanc T_CODIGO output,   
  @p_descricao T_ALFALARGE OUTPUT,  
  @p_substitui varchar(1) OUTPUT,  
  @p_calc_serie_incompl T_SIMNAO  
AS  
  SET @p_substitui = 'S'  
--  RETURN  
  
  -- ------------------------------------------------------------------  
  -- Obtem da tabela de matricula ou pré-matricula se foi informado a série para cálculo  
  select @v_serie_calculo = null  
    
  SELECT @v_serie_calculo = SERIE_CALCULO   
  FROM LY_PRE_MATRICULA  
  WHERE ALUNO = @p_aluno AND  
        DISCIPLINA = @p_disciplina AND  
        ANO = @p_ano AND  
        SEMESTRE = @p_periodo  
    
  IF @@ROWCOUNT <> 1  
    BEGIN  
      SELECT @v_serie_calculo = SERIE_CALCULO   
      FROM LY_MATRICULA  
      WHERE ALUNO = @p_aluno AND  
            DISCIPLINA = @p_disciplina AND  
            ANO = @p_ano AND  
            SEMESTRE = @p_periodo  
    END  
  
  
  -- Obtem a parametrização do curso  
  SELECT @v_valor_cred_assoc_disc = VALOR_CRED_ASSOC_DISC,   
    @v_usa_serie_ideal = USA_SERIE_IDEAL,  
         @v_cobran_disc =COBRAN_DISC  
  FROM LY_CURSO  
  WHERE CURSO = @p_curso  
  
  IF @@ROWCOUNT <> 1  
    BEGIN  
      SELECT @v_Errors = 'Curso não encontrado: ' + @p_curso  
      EXEC SetErro @v_Errors, 'CURSO'  
      GOTO FIM_ERRO  
    END  
  
  
  -- Se CRÉDITO NÃO ASSOCIADO A DISCIPLINA          
  IF @v_valor_cred_assoc_disc = 'N'   
    BEGIN  -- Obtém serviço ref. a série ideal da disciplina   
      IF @v_cobran_disc='S' and @v_usa_serie_ideal = 'N' -- o serviço está na série do aluno  
        BEGIN  
            
      
    SELECT @v_servico = SERVICO_CRED  
          FROM LY_SERIE S  
          WHERE S.CURSO = @p_curso AND  
                S.TURNO = @p_turno AND  
                S.CURRICULO = @p_curriculo AND          
                S.SERIE = isnull(@v_serie_calculo,@p_serie) --Obs: se @serie_calculo informada, usa-lá obrigatoriamente  
          IF @@ROWCOUNT <> 1  
            BEGIN  
              SET @v_straux = convert(varchar(2),@p_serie)  
              SELECT @v_Errors = 'Serie não encontrada: ' + @p_curso + ' - ' + @p_turno + ' - ' + @p_curriculo + ' - ' + @v_straux  
              EXEC SetErro @v_Errors, 'SERIE'  
              GOTO FIM_ERRO  
            END  
        END  -- Obtém serviço ref. série do aluno  
      ELSE -- Busca a série ideal da disciplina e joga em '@serie_ideal_disciplina'   
        BEGIN    
          -- Busca série ideal na grade   
          SELECT @v_serie_ideal_disciplina = null  
          SELECT @v_serie_ideal_disciplina = isnull(@v_serie_calculo,SERIE_IDEAL) --Obs: se @serie_calculo informada, usa-lá obrigatoriamente  
          FROM LY_GRADE G  
          WHERE G.CURSO = @p_curso AND  
                G.TURNO = @p_turno AND  
                G.CURRICULO = @p_curriculo AND          
                G.DISCIPLINA = @p_disciplina  
         -- SE NÃO Encontrou série ideal na grade -> verifica na grade de eletivas   
          IF @@ROWCOUNT <> 1  
            BEGIN               
              SELECT @v_serie_ideal_disciplina = isnull(@v_serie_calculo,SERIE_IDEAL) --Obs: se @serie_calculo informada, usa-lá obrigatoriamente  
              FROM LY_GRADE_ELETIVAS G  
              WHERE G.CURSO = @p_curso AND  
                    G.TURNO = @p_turno AND  
                    G.CURRICULO = @p_curriculo AND   
                    G.DISCIPLINA = @p_disciplina  
             -- SE NÃO encontrou série ideal   
             IF @@ROWCOUNT <> 1  
              BEGIN  
                SELECT @v_serie_ideal_disciplina = SERIE_CALCULO   
                FROM LY_PRE_MATRICULA M  
                WHERE M.ALUNO = @p_aluno AND  
                      M.DISCIPLINA = @p_disciplina                  
                  -- Se NÃO encontrou série ideal   
                  IF @@ROWCOUNT <> 1  
                  BEGIN  
                    SELECT @v_serie_ideal_disciplina = SERIE_CALCULO   
                    FROM LY_MATRICULA M  
                    WHERE M.ALUNO = @p_aluno AND  
                     M.DISCIPLINA = @p_disciplina  
  
                        -- Se NÃO encontrou série ideal, jogar série do aluno.  
                      IF @@ROWCOUNT <> 1  
                      BEGIN  
                        SELECT @v_serie_ideal_disciplina = @p_serie  
                      END  
                  END  
                END    
            END  
          -- Verifica se a série ideal foi obtida  
          IF @v_serie_ideal_disciplina is null  
            BEGIN  
              SELECT @v_Errors = 'Serie ideal para cálculo não encontrada na grade, grade de eletivas, matrícula e pré-matricula: ' + @p_curso + ' - ' + @p_turno + ' - ' + @p_curriculo + ' - ' + @p_disciplina  
              EXEC SetErro @v_Errors, 'SERIE'   
              GOTO FIM_ERRO  
            END  
          ELSE    
            BEGIN  -- Obtém serviço em '@servico'  
              SELECT @v_servico = SERVICO_CRED  
              FROM LY_SERIE S  
              WHERE S.CURSO = @p_curso AND  
                    S.TURNO = @p_turno AND  
                    S.CURRICULO = @p_curriculo AND          
                    S.SERIE = @v_serie_ideal_disciplina  
   
              IF @@ROWCOUNT <> 1  
                BEGIN  
                  SET @v_straux = convert(varchar(2),@v_serie_ideal_disciplina)  
                  SELECT @v_Errors = 'Serie não encontrada: ' + @p_curso + ' - ' + @p_turno + ' - ' + @p_curriculo + ' - ' + @v_straux  
                  EXEC SetErro @v_Errors, 'SERIE'   
                  GOTO FIM_ERRO  
                END  
            END     
      END  -- Fim da busca série ideal e joga em '@serie_ideal_disciplina'   
    END        
  ELSE        -- Se CRÉDITO ASSOCIADO A DISCIPLINA          
    BEGIN        -- Obtém serviço associado à disciplina do aluno  
      SELECT @v_servico = SERVICO  
      FROM LY_DISCIPLINA  
      WHERE DISCIPLINA = @p_disciplina  
  
      IF @@ROWCOUNT <> 1  
        BEGIN  
          SELECT @v_Errors = 'Disciplina não encontrada: ' + @p_disciplina  
          EXEC SetErro @v_Errors, 'DISCIPLINA'  
          GOTO FIM_ERRO  
        END  
    END -- Obtém serviço ref. série do aluno  
  
  EXEC calcula_valor_servico @v_servico, @p_aluno, @p_ano, @p_periodo, @v_valor_unitario OUTPUT, @p_codigo_lanc OUTPUT, @p_descricao OUTPUT  
  
  -- Verifica se ocorreram erros durante a execução da função  
  EXEC GetErrorsCount @v_ErrorsCount output  
 IF @v_ErrorsCount <> 0  
    GOTO FIM_ERRO  
  
  SELECT @p_valor_disciplina = @v_valor_unitario * CREDITOS  
  FROM LY_DISCIPLINA  
  WHERE DISCIPLINA = @p_disciplina  
  
  IF @@ROWCOUNT <> 1  
    BEGIN  
      SELECT @v_Errors = 'Disciplina não encontrada: ' + @p_disciplina  
      EXEC SetErro @v_Errors  
      GOTO FIM_ERRO  
    END  
  
  -- ------------------------------------------------------------------  
   
  EXEC a_calcula_valor_disciplina @p_aluno, @p_ano, @p_periodo, @p_curso, @p_turno, @p_curriculo, @p_serie,   
   @p_disciplina, @p_valor_disciplina OUTPUT , @p_codigo_lanc OUTPUT , @p_descricao OUTPUT, @p_calc_serie_incompl   
  
  EXEC GetErrorsCount @v_ErrorsCount output  
 IF @v_ErrorsCount <> 0  
    GOTO FIM_ERRO  
  
  -- ------------------------------------------------------------------  
  
FIM_FUNCAO:  
  RETURN  
  
FIM_ERRO:  
  RETURN
