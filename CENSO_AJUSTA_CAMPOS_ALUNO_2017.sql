               
-- PROCEDURE DE AVALIAÇÃO DOS CAMPO DO CENSO                
CREATE  PROCEDURE CENSO_AJUSTA_CAMPOS_ALUNO @P_ALUNO     T_CODIGO,                  
                                           @P_CAMPO     T_ALFALARGE,                  
                                           @P_VALOR     T_ALFALARGE,                
                                           @Resultado   T_ALFALARGE OUTPUT                
AS                  
                   
declare @SituacaoAluno  T_CODIGO                
declare @Falecido       T_CODIGO                
                  
  -- 40-1) tiporegistro1                
  if @p_campo = 'tiporegistro1'                  
    begin                  
      Select @Resultado = @P_VALOR                
    end                
                    
  -- 40-2) CodigoIes                
  if @p_campo = 'CodigoIes'                  
    begin                  
      Select @Resultado = @P_VALOR                
    end                
                    
  -- 40-3) TipoArquivo                
  if @p_campo = 'TipoArquivo'                  
    begin                  
      Select @Resultado = @P_VALOR                
    end                  
                    
   -- 41-1) TipoRegistro2                
  if @p_campo = 'TipoRegistro2'                  
    begin                  
      Select @Resultado = @P_VALOR                
    end                 
                    
  -- 41-2) IdAlunoInep                 
  if @p_campo = 'IdAlunoInep'                  
    begin                  
      Select @Resultado = @P_VALOR                
    end                     
                    
  -- 41-3) NomeAluno                
  if @p_campo = 'NomeAluno'                  
    begin                  
      Select @Resultado = @P_VALOR                
    end                      
                    
  -- 41-4) cpf                
  if @p_campo = 'cpf'                  
    begin                  
      Select @Resultado = @P_VALOR                
    end                        
                    
                
  -- 41-5) Passaporte                
  if @p_campo = 'Passaporte'                  
    begin                  
      Select @Resultado = @P_VALOR                
    end                   
                
                
  -- 41-6) DataNascimento -- Obrigatoriamente no formato <ddmmaaaa>                
  -- Aqui terá que devolver o campo no formato acima citado!!!                
  if @p_campo = 'DataNascimento'                  
    begin                  
      declare @DataAlterada t_codigo                
      select @DataAlterada = @P_VALOR                
      Select @DataAlterada = replace(@DataAlterada,'/','')                
      Select @Resultado = @DataAlterada                
    end                 
                    
   -- 41-7) Sexo                  
  if @p_campo = 'Sexo'                  
  begin                  
      select @Resultado = case upper(@p_valor)                  
           when 'M'                  
                then '0'                  
           when 'F'                  
                then '1'                  
           else ''                  
      end                  
  end                       
                
  -- 41-8) CorRaça                  
  if @p_campo = 'CorRaça'                  
  begin                  
      select @Resultado = case upper(@p_valor)                  
           when 'Branca'                  
                then '1'  -- Branca                  
           when 'Preta'                  
                then '2'  -- Preta                  
           when 'Parda'                  
                then '3'  -- Parda                  
           when 'Amarela'                  
                then '4'  -- Amarela                  
           when 'Indígena'                  
                then '5'  -- Indígena                  
           when 'NÃO DISPÕE DA INFORMAÇÃO'                  
                then '6'  -- Não dispõe da informação                  
           when 'Não declarado'                  
                then '0'  -- Não declarado                  
     when 'Nao informada'                  
                then '0'  -- Não declarado                  
     when 'Não quer declarar'                  
                then '0'  -- Não declarado                  
           else '0'                  
      end                  
  end                  
                  
                
  -- 41-9) NomeMãe                
  if @p_campo = 'NomeMãe'                  
    begin                  
      Select @Resultado = @P_VALOR                
    end                   
                    
  -- 41-10) Nacionalidade                  
  if @p_campo = 'Nacionalidade'                  
  begin                  
      select @Resultado = case upper(@p_valor)                  
           when 'BRASILEIRA'                  
                then '1'  -- Brasileira                  
           when 'BRASILEIRA - NASCIDO NO EXTERIOR OU NATURALIZADO'                  
          then '2'  -- Brasileira - Nascido no exterior ou naturalizado                  
           when 'ESTRANGEIRA'                  
                then '3'  -- Estrangeira                  
           else ''                  
      end                  
  end                       
                  
  -- 41-11) UfNascimento                
  if @p_campo = 'UfNascimento'                  
    begin                  
      Select @Resultado = Codigo                 
      from LY_CENSO_UF                
      Where nome = (  SELECT NOME Estado                
                      FROM UF                 
                      where sigla = (select uf_sigla from municipio where codigo = @P_VALOR) )                
    end                   
                    
  -- 41-12) MunicipioNascimento                
  if @p_campo = 'MunicipioNascimento'                  
    begin                  
      declare @PosIndicador int                
      declare @strAux           T_ALFALARGE                
      declare @strMunicipioNasc T_ALFALARGE                
  declare @strUFNasc        T_ALFALARGE                
      Select @strAux = @P_VALOR                
      select @PosIndicador = PATINDEX ( '%|%', @strAux)                 
      Select @strMunicipioNasc = SUBSTRING (@strAux, 1, @PosIndicador-1)                 
      Select @strUFNasc = SUBSTRING (@strAux, @PosIndicador+1, len(@strAux))                
                      
      Select @Resultado = Codigo                 
      from LY_CENSO_MUNICIPIO                
      Where codigo_uf = @strUFNasc and                 
            nome = (Select nome                 
                    from municipio                
                    where codigo = @strMunicipioNasc)                
    end                   
                    
  -- 41-13) PaisNascimento                
  if @p_campo = 'PaisNascimento'                  
    begin                  
      Select @Resultado = codigo                 
      From LY_CENSO_PAIS                
      Where nome = @P_VALOR                
    end                    
                  
                  
  -- 41-14) AlunoComDeficiência                
  if @p_campo = 'AlunoComDeficiência'                  
    begin                  
      Select @Resultado = @P_VALOR                 
    end                  
                  
                  
   -- 41-15 ao 41-27) TipoDeficiência                
  if @p_campo = 'TipoDeficiência'                  
  begin                  
      -- O Resultado do campo 'TipoDeficiência' deverá retornar um dos seguintes itens abaixo:                
      select @Resultado = case upper(@p_valor)                  
           when 'CEGUEIRA'                  
                then 'CEGUEIRA'                  
           when 'Baixa visão'                  
                then 'BAIXA VISAO'                  
           when 'SURDEZ'                  
                then 'SURDEZ'                  
           when 'AUDITIVA'                  
                then 'AUDITIVA'     
           when 'Deficiência Física'                  
                then 'FISICA'                  
           when 'SURDOCEGUEIRA'                  
                then 'SURDOCEGUEIRA'                 
           when 'Deficiência Múltipla'                  
                then 'MULTIPLA'                
           when 'INTELECTUAL'                  
                then 'INTELECTUAL'                
           when 'AUTISMO'                  
                then 'AUTISMO'                
           when 'ASPERGER'                  
                then 'ASPERGER'                
           when 'RETT'                  
                then 'RETT'                
           when 'DESINTEGRAT'                  
                then 'DESINTEGRAT'                
           when 'SUPERDOT'                  
    then 'SUPERDOT'                
           else ''                  
      end                  
  end                   
                  
   -- 42-1) Tiporegistro3                
  if @p_campo = 'Tiporegistro3'                  
    begin                  
      Select @Resultado = @P_VALOR                
    end                    
                 
   -- 42-2) SemestreRef                
  if @p_campo = 'SemestreRef'                  
    begin                  
   -- ****** O @P_VALOR : Aqui é a Data limite (Parâmetro passado pelo Processo Gera Censo)                
      Select @Resultado = ''                
    end                       
                    
   -- 42-3) IdCursoInep                
  if @p_campo = 'IdCursoInep'                  
    begin                  
      Select @Resultado = @P_VALOR                
    end                      
                    
  -- 42-4) PoloEADInep                
  if @p_campo = 'PoloEADInep'                  
    begin                  
      -- Este campo é obrigatório quando informado curso com modalidade "Curso a distância"                
      Select @Resultado =''--@P_VALOR                
    end                  
                
  -- 42-5) IdAlunoIES                
  if @p_campo = 'IdAlunoIES'                  
    begin                  
      Select @Resultado = @P_VALOR                
    end                 
                
 -- 42-6) TurnoAluno                
  if @p_campo = 'TurnoAluno'                  
  begin                  
      -- O Resultado do campo 'TurnoAluno' deverá retornar um dos seguintes itens abaixo:                
      select @Resultado = case upper(@p_valor)                  
           when 'M'                  
                then '1'                  
           when 'V'                  
                then '2'                  
           when 'N'                  
                then '3'                  
           when 'I'                  
                then '4'                 
           else ''                  
      end                  
  end                  
                
   -- 42-7) SituaçãoVínculo                  
  if @p_campo = 'SituaçãoVínculo'                  
    begin                 
                  
        -- ****** O @P_VALOR : Aqui é a Data limite (Parâmetro passado pelo Processo Gera Censo)                
        --1) Falecido                                     <7>                
        --2) Cursando                                     <2>                
        --3) Matrícula Trancada                           <3>                
        --4) Desvinculado do curso                        <4>                
        --5) Transferido para outro curso na mesma IES    <5>                
        --6) Formado                                      <6>                
        --X) Provável formador                            <1> (NÃO UTILIZADO)!!!!!                
                        
        -- Inicializando o retorno                
   Select @Resultado =''                
                      
        declare @v_ano        T_ANO                
        declare @v_periodo    T_SEMESTRE2                
        declare @Cursando     T_CODIGO     
        declare @Trancada     T_CODIGO                
        declare @Encerramento T_CODIGO                
        declare @Motivo       T_CODIGO                
        declare @dt_inicio    T_DATA                
                        
        -- BUSCANDO OS PERÍODOS LETIVOS                
        DECLARE C_PERIODOS_LETIVOS CURSOR FOR                  
       Select ANO      
    , CASE PERIODO      
        WHEN '22' THEN '2'      
     WHEN '11' THEN '1'      
     ELSE PERIODO      
      END AS PERIODO      
    ,CASE DT_INICIO      
      WHEN '2016-12-01 00:00:00.000' THEN '2016-07-01 00:00:00.000' /*DT_INICIO */        
   ELSE DT_INICIO      
    END  AS DT_INICIO             
        From LY_PERIODO_LETIVO                
        Where CONVERT(datetime,dt_inicio,103)  <= CONVERT(datetime,@P_VALOR,103) and                
              CONVERT(datetime,@P_VALOR,103) <= CONVERT(datetime,dt_fim,103)                 
        OPEN C_PERIODOS_LETIVOS                  
        FETCH NEXT FROM C_PERIODOS_LETIVOS INTO @v_ano, @v_periodo, @dt_inicio                
        -- Loop no cursor de Períodos Letivos                
        WHILE @@FETCH_STATUS = 0                   
          BEGIN                
                --1) Falecido <7>                
                Select @Falecido = '1'                
                from ly_pessoa p, ly_aluno a                
                Where a.pessoa = p.pessoa and                
                      a.aluno = @P_ALUNO and                
                      p.dt_falecimento is not null and                
                      CONVERT(datetime,p.dt_falecimento,103) >= CONVERT(datetime,@dt_inicio,103) and                 
                      CONVERT(datetime,p.dt_falecimento,103) <= CONVERT(datetime,@P_VALOR,103)                 
                If @Falecido = '1'                
                  begin                
                    Select @Resultado = '7'                
                    CLOSE C_PERIODOS_LETIVOS                  
                    DEALLOCATE C_PERIODOS_LETIVOS                 
                  GOTO Continuando                
                  end                
                else                
                  begin                
                      Select distinct @Cursando = '1'                
                      from ly_histmatricula                
                      Where aluno = @P_ALUNO and                
                            ano = @v_ano and                
                            semestre <= @v_periodo and                
                            situacao_hist not in ('Cancelado','Trancado')     
       AND NOT exists(SELECT 1 FROM ly_h_cursos_concl hcc  WHERE hcc.aluno=@P_ALUNO AND year(hcc.DT_ENCERRAMENTO)= @v_ano  )               
                      If @Cursando = '1'                
                        begin                
                      --2) Cursando <2>                
                          Select @Resultado = '2'                
                          CLOSE C_PERIODOS_LETIVOS                  
                          DEALLOCATE C_PERIODOS_LETIVOS                 
                          GOTO Continuando                
                        end                
                      else                
                        begin                
                          SELECT distinct @Trancada = '1'                
                          FROM VW_TRANC_ALUNO                 
                          WHERE ALUNO = @P_ALUNO AND                
                                ANO_TRANC = @v_ano AND                
                                SEM_TRANC  = @v_periodo AND                
                                CONVERT(datetime,DT_TRANC,103) <= CONVERT(datetime,@P_VALOR,103)                
                          If @Trancada = '1'                
                            begin                
                              --3) Matrícula Trancada <3>                
                              Select @Resultado = '3'                
                              CLOSE C_PERIODOS_LETIVOS                  
                              DEALLOCATE C_PERIODOS_LETIVOS                 
                              GOTO Continuando                
                            end                
                          else                
                            begin                 
                                Select distinct @Encerramento = '1', @Motivo = motivo                 
                                From ly_h_cursos_concl                
                                Where ALUNO = @P_ALUNO AND                 
                                      ANO_ENCERRAMENTO in( @v_ano,'2017') AND              
                                      SEM_ENCERRAMENTO <= @v_periodo AND                
                                      CONVERT(varchar(10),CASE DT_ENCERRAMENTO      
              WHEN '2017-01-04 00:00:00.000' THEN '2016-12-30 00:00:00.000'      
              ELSE DT_ENCERRAMENTO      
                      END       
           ,103) <=  CONVERT(varchar(10),@P_VALOR,103)                
                                If @Encerramento = '1'                
                                  begin                
                                      if @Motivo = 'Evasao' or @Motivo = 'Cancelamento' or @Motivo = 'ABANDONO' or @Motivo = 'MIGRACAO' or @Motivo ='OUTROS' or @Motivo ='Jubilamento'         
                                        begin                
                                             --4) Desvinculado do curso <4>                
                                        Select @Resultado = '4'                
                                            CLOSE C_PERIODOS_LETIVOS                  
                                            DEALLOCATE C_PERIODOS_LETIVOS                 
                                            GOTO Continuando                
                                        end                
                                                        
                                      if @Motivo = 'Transferencia'                
                                        begin                
                                            --5) Transferido para outro curso na mesma IES <5>                
                                            Select @Resultado = '5'                
                                            CLOSE C_PERIODOS_LETIVOS                  
                                            DEALLOCATE C_PERIODOS_LETIVOS                 
                                            GOTO Continuando                
                                        end                
                                                        
                                      if @Motivo = 'Conclusao'                
                                        begin                
                                         --6) Formado <6>                
                                            Select @Resultado = '6'                
                                            CLOSE C_PERIODOS_LETIVOS                  
                                            DEALLOCATE C_PERIODOS_LETIVOS                 
                                            GOTO Continuando                
                                        end                
                                  end -- If @Encerramento = '1'                
                            end -- If @Trancada = '1'                     
                        end -- If @Cursando = '1'                
                   end -- If @Falecido = '1'                
            FETCH NEXT FROM C_PERIODOS_LETIVOS INTO @v_ano, @v_periodo, @dt_inicio                
          END                  
        CLOSE C_PERIODOS_LETIVOS                  
        DEALLOCATE C_PERIODOS_LETIVOS                  
                
      Continuando:                
    end -- if @p_campo = 'SituaçãoVínculo'                  
                
                
   -- 42-8) CursoOrigem                
   if @p_campo = 'CursoOrigem'                  
    begin                
   Select @Resultado = ''                
 -- ****** O @P_VALOR : Aqui é a Data limite (Parâmetro passado pelo Processo Gera Censo)                     
   SELECT @Resultado = ISNULL(C.INEP_CURSO, '') FROM  LY_H_CURR_ALUNO H                
  INNER JOIN (SELECT ALUNO, MAX(DT_TRANS) DT_TRANS                 
     FROM LY_H_CURR_ALUNO                 
     WHERE DT_TRANS <= @P_VALOR                 
     GROUP BY ALUNO) HD ON HD.ALUNO = H.ALUNO AND HD.DT_TRANS =  H.DT_TRANS                
  INNER JOIN LY_CURSO C ON C.CURSO = H.CURSO              
   WHERE H.ALUNO = @P_ALUNO                
    end                             
                  
                  
     -- 42-9) SemestreConclCurso                  
  if @p_campo = 'SemestreConclCurso'                  
    begin                  
        -- ****** O @P_VALOR : Aqui é a Data limite (Parâmetro passado pelo Processo Gera Censo)                        
        -- Inicializando o retorno                
        Select @Resultado = ''                
                        
        declare @ano        T_ANO                
        declare @semestre   T_SEMESTRE2                
        declare @Concluido T_CODIGO                
        declare @dt_fim  T_DATA                
                        
        -- BUSCANDO OS PERÍODOS LETIVOS                
        DECLARE C_PERIODOS CURSOR FOR                  
        Select ANO      
    , CASE PERIODO      
        WHEN '22' THEN '2'      
     WHEN '11' THEN '1'      
     ELSE PERIODO      
      END AS PERIODO      
    ,CASE DT_FIM      
      WHEN '2017-01-30 00:00:00.000' THEN '2016-12-31 00:00:00.000' /*DT_INICIO */        
   ELSE DT_FIM      
    END  AS DT_FIM      
        From LY_PERIODO_LETIVO                
        Where CONVERT(datetime,dt_inicio,103)  <= CONVERT(datetime,@P_VALOR,103) and                
              CONVERT(datetime,@P_VALOR,103) <= CONVERT(datetime,dt_fim,103)                 
        OPEN C_PERIODOS                  
        FETCH NEXT FROM C_PERIODOS INTO @ano, @semestre, @dt_fim                
        -- Loop no cursor de Períodos Letivos                
        WHILE @@FETCH_STATUS = 0                   
          BEGIN                
            Select distinct @Concluido = '1'                 
            From ly_h_cursos_concl                
            Where ALUNO = @P_ALUNO AND                 
                  ANO_ENCERRAMENTO = @ano AND                
                  SEM_ENCERRAMENTO = @semestre AND                
                  CONVERT(datetime,DT_ENCERRAMENTO,103) <=  CONVERT(datetime,@P_VALOR,103) AND                
                  MOTIVO = 'Conclusao'                
                                  
            If @Concluido = '1'                
              begin                                    
                select @Resultado = case                 
          when month(@dt_fim) > 0 and month(@dt_fim) < 7 then '1'                
          when month(@dt_fim) > 6 and month(@dt_fim) < 13 then '2'                
          else ''                
         end                  
                CLOSE C_PERIODOS                  
                DEALLOCATE C_PERIODOS                 
                GOTO Continua                
              end -- If @Concluido = '1'                
                
            FETCH NEXT FROM C_PERIODOS INTO @ano, @semestre, @dt_fim                
          END                  
        CLOSE C_PERIODOS                  
        DEALLOCATE C_PERIODOS                
                          
  Continua:                
           
    end -- if @p_campo = 'SemestreConclCurso'                 
                    
    -- Este campo serve para verificar se o campo ALUNOPARFOR deve ser preenchido ou não.                
    -- O valor passado em @p_valor é obtido em LY_CURSO.INEP_GRAU .                
    -- O código correspondente ao Grau de Licenciatura(1) deve ser alterado para o código usado na IES,                
    -- mas o valor de retorno(2) deverá ser sempre 'LICENCIATURA'.                
    if @p_campo = 'GrauAcademico'                  
    begin                  
      select @Resultado = case upper(@p_valor)                  
           when 'LICENCIATURA' -- (1)deve ser alterado para o código usado na IES                 
                then 'LICENCIATURA' -- (2)não pode ser alterado                
           else ''                  
      end                  
    end                       
                 
   -- 42-10) AlunoPARFOR                
   -- Valores válidos: 0 - Não ou 1 - Sim                
   -- O campo AlunoPARFOR só deve ser informado quando o curso possuir grau acadêmico de Licenciatura                
   -- Caso o curso possua grau acadêmico de Licenciatura o preenchimento do campo AlunoPARFOR é obrigatório                  
   if @p_campo = 'AlunoPARFOR'                  
    begin                  
      SELECT @Resultado = CASE C.TITULO        
   WHEN 'Licenciatura' THEN '0'        
   ELSE ''        
   END        
   FROM LY_ALUNO A         
   INNER JOIN LY_CURSO C ON C.CURSO=A.CURSO        
   WHERE 1=1        
   AND C.TITULO='Licenciatura'       
   AND A.ALUNO=@P_ALUNO            
    end                            
                 
                 
 -- 42-11) SemestreIngresso -- Obrigatoriamente no formato <SSAAAA> onde S é o semestre                
  -- Aqui terá que devolver o campo no formato acima citado!!!                  
  if @p_campo = 'SemestreIngresso'                  
    begin                  
                      
   declare @SemestreIngr varchar(2)                
   declare @AnoIngr varchar(4)      
   --declare @Auxdata  varchar(24)        
         
   /*SELECT @Auxdata= CASE WHEN ((@P_VALOR) <= (C.DT_DOU)) THEN C.DT_DOU ELSE @P_VALOR   END      
   FROM  LY_ALUNO A      
   INNER JOIN LY_CURSO C ON C.CURSO =A.CURSO      
   WHERE 1=1      
   AND A.ALUNO=@P_ALUNO */        
                
   select @SemestreIngr = case when convert(numeric(2),SUBSTRING(@P_VALOR,6,2))  < 7                
           then '01'                  
          when convert(numeric(2),SUBSTRING(@P_VALOR,6,2)) > 6                   
           then '02'                  
          else ''                  
        end                 
                   
   select @AnoIngr =year(@P_VALOR)  /*Right(@P_VALOR,4) */        
                
      Select @Resultado = @SemestreIngr + @AnoIngr                
    end                           
                
-- 42-12) AluProcEscolaPublica                
  if @p_campo = 'AluProcEscolaPublica'                  
  begin                
   Select @Resultado = @P_VALOR               
  /*                
      -- O Resultado do campo 'AluProcEscolaPublica' deverá retornar um dos seguintes itens abaixo:                
      declare @ResultadoAux t_alfalarge                
                
   if @ResultadoAux = null                 
    begin                
     Select @Resultado = '2'                
    end                
   else                
    begin                
      select @Resultado = case upper(@p_valor)                  
         when '0'                  
           then '0'                  
         when '1'                  
           then '1'                  
         else '2'                  
      end                  
    end   */                
  end                  
                
  -- 42-13 ao 42-22) FormaIngresso                   
   if @p_campo = 'FormaIngresso'                  
    begin                  
      -- O Resultado do campo 'FormaIngresso' deverá retornar um dos seguintes itens abaixo:                
      select @Resultado = case upper(@P_VALOR)                  
           when 'VESTIBULAR'                  
             then 'VESTIBULAR'       
     when 'FIES'                  
                then 'VESTIBULAR'                  
           when 'OUTROS'                  
                then 'VESTIBULAR'            
           when 'REABERTURAMATRÍCULA'                  
                then 'VESTIBULAR'                     
           when 'ENEM'                  
                then 'ENEM'                  
           when 'PROUNI'                  
                then 'ENEM'               
           when 'AVALIAÇÃO SERIADA'                  
                then 'AVALIAÇÃO SERIADA'                      
           when 'SELEÇÃO SIMPLIFICADA'                  
                then 'SELEÇÃO SIMPLIFICADA'                  
           when 'EGRESSO BI/LI'                  
                then 'EGRESSO BI/LI'            
           when 'PEC-G'                  
                then 'PEC-G'                 
           when 'TRANSFERÊNCIA EX OFFICIO'                  
                then 'TRANSFERÊNCIA EX OFFICIO'                      
           when 'DECISÃO JUDICIAL'                  
                then 'DECISÃO JUDICIAL'            
    WHEN 'TRANSFERENCIAINTERNA'                 
   THEN'VAGAS REMANESCENTES'            
    WHEN 'TRANSFERENCIAEXTERNA'                 
   THEN'VAGAS REMANESCENTES'            
     WHEN 'REINGRESSO'                 
   THEN'VAGAS REMANESCENTES'            
           when 'VAGAS REMANESCENTES'                
                then 'VAGAS REMANESCENTES'       
          when 'MATRICULAESPECIAL'       
             then 'VAGAS REMANESCENTES'                     
           when 'PROGRAMAS ESPECIAIS'                  
                then 'PROGRAMAS ESPECIAIS'                 
     /*when 'VESTIBULAR-ENEM'                  
                then 'VESTIBULAR-ENEM'                 
     when 'VESTIBULAR-SIMPLIFICADA'                  
                then 'VESTIBULAR-SIMPLIFICADA'                 
     when 'ENEM-SIMPLIFICADA'                  
                then 'ENEM-SIMPLIFICADA'                 
     when 'VESTIBULAR-ENEM-SIMPLIFICADA'                  
                then 'VESTIBULAR-ENEM-SIMPLIFICADA' */                                 
           else ''                 
      end                   
    end                 
                 
  -- 42-23) MobilidadeAcademica                
   if @p_campo = 'MobilidadeAcademica'                  
    begin           
      Select @Resultado = @P_VALOR                
    end                    
                
  -- 42-24) TipoMobilAcad                
   if @p_campo = 'TipoMobilAcad'                  
    begin                   
      Select @Resultado = @P_VALOR                
    end                  
                
  -- 42-25) IESDestino                
   if @p_campo = 'IESDestino'                  
    begin                   
      Select @Resultado = @P_VALOR                
    end                  
               
  -- 42-26) TipoMobilAcadInternacional                
   if @p_campo = 'TipoMobilAcadInternacional'                  
    begin                   
      Select @Resultado = @P_VALOR                
    end                  
                
  -- 42-27) PaisDestino                
   if @p_campo = 'PaisDestino'                  
    begin                   
      Select @Resultado = @P_VALOR                
    end                   
                    
    -- 42-28) ProgrReservaVagasAfirmativas                
   if @p_campo = 'ProgrReservaVagasAfirmativas'                  
    begin                  
      Select @Resultado = '0'                
    end                 
                    
                    
   -- 42-29 ao 42-33) ProgramaReservaVagas                   
    if @p_campo = 'ProgramaReservaVagas'                  
      begin                  
        -- O Resultado do campo 'ProgrReservaVagasAfirmativas' deverá retornar um dos seguintes itens abaixo:                
        select @Resultado = case upper(@p_valor)                  
             when 'ETNICO'                  
                  then 'ETNICO'                  
             when 'PESSOAS COM DEFICIENCIA'                  
                  then 'PESSOAS COM DEFICIENCIA'                  
             when 'ESTUDANTE PROCEDENTE DE ENSINO PÚBLICO'                  
                  then 'ESTUDANTE PROCEDENTE DE ENSINO PÚBLICO'                 
             when 'SOCIAL/RENDA FAMILIAR'                  
                  then 'SOCIAL/RENDA FAMILIAR'                                    
             when 'OUTROS'                  
                  then 'OUTROS'                  
             else ''                  
        end                    
     end                   
                     
    -- Este Campo descreve a categoria administrativa da IES                  
    -- Serve para verificar se alguns campos devem ser preenchidos ou não.                
    -- Os valores possíveis são: 'Pública Federal'(1) ou 'Pública Estadual'(2), para as demais categorias administrativas não há necessidade de preenchimento.                
    if @p_campo = 'CategoriaAdmIES'                  
    begin                  
  -- O Resultado do campo 'CategoriaAdmIES' deverá retornar um dos seguintes itens abaixo:                
  declare @CategoriaAdm t_alfalarge                
  select @CategoriaAdm = ''                
  -- (1) Descomentar a linha abaixo somente se a IES estiver na categotia 'Pública Federal'                
  -- select @CategoriaAdm = 'Pública Federal'                
                  
  -- (2) Descomentar a linha abaixo somente se a IES estiver na categotia 'Pública Estadual'                
  -- select @CategoriaAdm = 'Pública Estadual'                
                
  select @Resultado = @CategoriaAdm                  
    end                 
                    
    -- Este Campo descreve a organização acadêmica da IES                  
    -- Serve para verificar se alguns campos devem ser preenchidos ou não.                
    -- Valor possível: 'Universidade'(1), para as demais organizações acadêmicas não há necessidade de preenchimento.                
    if @p_campo = 'OrganizacaoAcademicaIES'                  
    begin                  
  -- O Resultado do campo 'CategoriaAdmIES' deverá retornar um dos seguintes itens abaixo:                
  declare @OrganizAcademica t_alfalarge                
  select @OrganizAcademica = ''                
  -- (1) Descomentar a linha abaixo somente se a IES estiver na organização acadêmica 'Universidade'                
  -- select @OrganizAcademica = 'Universidade'                
                  
  select @Resultado = @OrganizAcademica                  
    end                                 
                         
   -- 42-34) FinanciamentoEstudandil                
   if @p_campo = 'FinanciamentoEstudandil'                  
    begin                  
      Select @Resultado = case @P_VALOR                  
           when @P_ALUNO THEN '1'              
     ELSE'0'              
     END              
    end                 
                    
                  
   -- 42-35 ao 42-45) TiposFinanciamentoEstudandil                   
    if @p_campo = 'TiposFinancEstReembolsavelFies'                  
    begin                  
        Select @Resultado = case @P_VALOR                  
           when @P_ALUNO THEN '1'              
     ELSE'0'              
     END                 
    end                  
 if @p_campo = 'TiposFinancEstReembolGovEstado'                  
    begin                  
       Select @Resultado = case @P_VALOR                  
           when @P_ALUNO THEN '0'              
     ELSE''         
  end               
    end                
 if @p_campo = 'TiposFinancEstReembolGovMunic'                  
    begin                  
       Select @Resultado = case @P_VALOR                  
           when @P_ALUNO THEN '0'              
     ELSE''         
  end                
    end                
 if @p_campo = 'TiposFinancEstReembolsavelIES'                  
    begin                  
       Select @Resultado = case @P_VALOR                  
           when @P_ALUNO THEN '0'              
     ELSE''         
  end                
    end                
 if @p_campo = 'TiposFinancEstReembolEntExt'                  
    begin                  
       Select @Resultado = case @P_VALOR                  
           when @P_ALUNO THEN '0'              
     ELSE''         
  end                
    end                
 if @p_campo = 'TipFinancEstNAOReembProUniInt'                  
    begin                  
      Select @Resultado = case @P_VALOR                  
           when @P_ALUNO THEN '1'              
     ELSE'0'              
     END                   
    end                
 if @p_campo = 'TipFinancEstNAOReembProUniParc'                  
    begin                  
      Select @Resultado = case @P_VALOR                  
           when @P_ALUNO THEN '1'              
     ELSE'0'              
     END                    
    end                
 if @p_campo = 'TipFinancEstNAOReembEntExt'                  
    begin                  
      Select @Resultado = case @P_VALOR                  
           when @P_ALUNO THEN '1'              
     ELSE'0'          
  end               
    end                
 if @p_campo = 'TipFinancEstNAOReembGovEstado'                  
    begin                  
      Select @Resultado = case @P_VALOR                  
           when @P_ALUNO THEN '1'              
     ELSE'0'          
  end              
    end                
 if @p_campo = 'TiposFinancEstNAOReembIES'                  
    begin                  
      Select @Resultado = case @P_VALOR                  
           when @P_ALUNO THEN '1'              
     ELSE'0'          
  end              
    end                
 if @p_campo = 'TipFinancEstNAOReembGovMunic'                  
    begin                  
      Select @Resultado = case @P_VALOR                  
           when @P_ALUNO THEN '1'              
     ELSE'0'          
  end                
    end                
                
                     
   -- 42-46) Apoio Social                
   if @p_campo = 'ApoioSocial'                  
    begin           
      Select @Resultado = '0'                
    end                  
                    
                   
   -- 42-47 ao 42-52) TiposApoioSocial                   
    if @p_campo = 'TiposApoioSocial'                  
      begin                  
        -- O Resultado do campo 'TiposApoioSocial' deverá retornar um dos seguintes itens abaixo:                
        select @Resultado = case upper(@p_valor)                  
             WHEN 'TIPOSAPOIOSOCIALALIMENTACAO'                  
                  THEN 'TIPOSAPOIOSOCIALALIMENTACAO'                  
             WHEN 'TIPOSAPOIOSOCIALMORADIA'                  
                  THEN 'TIPOSAPOIOSOCIALMORADIA'                 
             WHEN 'TIPOSAPOIOSOCIALTRANSPORTE'                  
                  THEN 'TIPOSAPOIOSOCIALTRANSPORTE'                 
             WHEN 'TIPOSAPOIOSOCIALMATERIALDIDAT'                  
                  THEN 'TIPOSAPOIOSOCIALMATERIALDIDAT'                 
             WHEN 'TIPOSAPOIOSOCIALBOLSATRABALHO'                  
                  THEN 'TIPOSAPOIOSOCIALBOLSATRABALHO'                 
             WHEN 'TIPOSAPOIOSOCBOLSAPERMANENCIA'                  
                  THEN 'TIPOSAPOIOSOCBOLSAPERMANENCIA'                
             else ''                  
        end                    
     end                  
                     
   -- 42-53) Atividade Extracurricular                
   if @p_campo = 'AtividadeExtracurricular'                  
    begin                  
      Select @Resultado = '0'                
    end                     
    -- 42-54                
 if @p_campo = 'TiposAtivExtracurricularPesquisa'                  
  begin                  
  Select @Resultado = @P_VALOR                
  end                  
  -- 42-56                
 if @p_campo = 'TiposAtivExtracurricularExtensao'                  
  begin                  
  Select @Resultado = @P_VALOR                
  end                  
  -- 42-58                
 if @p_campo = 'TiposAtivExtracurricularMonit'                  
  begin                  
  Select @Resultado = @P_VALOR            
  end                  
  -- 42-60                
 if @p_campo = 'TpAtivExtracurricularEstagNaoObrig'                  
  begin                  
  Select @Resultado = @P_VALOR                
  end                  
                  
                     
   -- 42-55) BolsaRemuneracaoPesquisa                
   if @p_campo = 'BolsaRemuneracaoPesquisa'                  
    begin                  
      Select @Resultado = @P_VALOR                
    end                   
                   
   -- 42-57) BolsaRemuneracaoExtensao                
   if @p_campo = 'BolsaRemuneracaoExtensao'                  
    begin              
      Select @Resultado = @P_VALOR                
    end                 
                    
    -- 42-59) BolsaRemuneracaoMonitoria                
   if @p_campo = 'BolsaRemuneracaoMonitoria'                  
    begin                  
      Select @Resultado = @P_VALOR                
    end                 
                    
    -- 42-61) BolsaRemuneracaoEstagNaoObrig                
   if @p_campo = 'BolsaRemuneracaoEstagNaoObrig'                  
    begin                  
      Select @Resultado = @P_VALOR                
    end                   
                
 -- 42-62) CargaHorariaTotalCurso                
   if @p_campo = 'CargaHorariaTotalCurso'                  
    begin                  
      Select @Resultado = @P_VALOR                
    end                   
                
  -- 42-63) CargaHorariaIntegralizada                
   if @p_campo = 'CargaHorariaIntegralizada'                  
    begin                  
      Select @Resultado = @P_VALOR                
    end                   
                
                
  Return 