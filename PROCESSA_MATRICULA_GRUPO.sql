USE LYCEUM
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.PROCESSA_MATRICULA_GRUPO'))
   exec('CREATE PROCEDURE [dbo].[PROCESSA_MATRICULA_GRUPO] AS BEGIN SET NOCOUNT OFF; END')
GO 
  
ALTER procedure PROCESSA_MATRICULA_GRUPO(  
 @p_sessao_id varchar(40),  
 @p_aluno T_CODIGO,   
 @p_ano T_ANO,  
 @p_semestre T_SEMESTRE2,  
 @p_contexto varchar(100) = null,  
 @p_pre_matricula varchar(1) = 'N',  
 @p_troca_turma varchar(1) = 'N',  
 @p_plano_estudo varchar(1) = 'S',  
 @p_valida_duplicidade_prior varchar(1) = 'S',  
 @p_disciplina_origem T_CODIGO = NULL)  
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
-- <DOC> @p_contexto varchar(100) = null - de onde foi chamado, podendo ser:  
-- <DOC>   1. Tela de Matricula - quando executado a partir das telas de prÚ-matrÝcula e matrÝcula                 
-- <DOC>   2. Matricula pela Internet            
-- <DOC>   3. Proc EnturmaþÒo/PriorizaþÒo  
-- <DOC>   4. Processo prÚ-matrÝcula             
-- <DOC>   5. Processo ajuste da prÚ-matrÝcula  
-- <DOC>   6. Tela de MatriculaN - quando executado a partir da tela de prÚ-matricula e matrÝcula privilegiada e nÒo for para executar o entry-point de validaþÒo  
-- <DOC> @p_pre_matricula varchar(1) - se Ú prÚ-matricula  
-- <DOC> @p_troca_turma varchar(1) - se Ú transferÛncia de turma - utilizado somente para prÚ-matricula  
-- <DOC> @p_plano_estudo varchar(1) - se verifica plano de estudo - utilizado somente nas telas de prÚ-matrÝcula e matrÝcula privilegiada, senÒo Ú False  
-- <DOC> @p_valida_duplicidade_prior varchar(1) - somente para prÚ-matricula - nÒo Ú mais utilizado  
-- <DOC> @p_disciplina_origem T_CODIGO = NULL - quando troca disciplina Ú enviada a disciplina origem - utilizado somente para matricula  
-- <DOC>   
-- <DOC> Retorno:  
-- <DOC>  
-- <DOC> Nenhum (procedure)  
-- <DOC>   
-- <DOC> Roteiro de execuþÒo:  
-- <DOC>  
-- <DOC> 1. Validar o conjunto de disciplinas matriculadas (VALIDA_MATRICULA_GRUPO).  
-- <DOC> 2. Buscar o parÔmetro de duplicaþÒo de disciplina na matrÝcula (PERMITIR_MATR_DUPL - LY_OPCOES) para passar como parÔmetro ao executar MATRICULA_VALID.  
-- <DOC> 3. Se matrÝcula nova, fazer a validaþÒo por disciplina (VALIDA_MATRICULA).  
-- <DOC> 4. Inserir ou alterar a prÚ-matrÝcula ou matrÝcula (INSERE_MATRICULA_GRUPO ou INSERE_PRE_MATRICULA_GRUPO).  
-- <DOC> 5. No final remove os registros do id da conexÒo da tabela LY_PROCESSA_MATRICULA_GRUPO.  
-- <DOC>  
-- <DOC> Antes de executar essa procedure Ú necessßrio popular a tabela LY_PROCESSA_MATRICULA_GRUPO com as prÚ-matriculas e matricula que devem ser validadas e inseridas ou alteradas.  
-- ################################################################################################  
   
 declare @v_UID NUMERIC(18)  
 declare @v_SESSAO_ID [varchar](40)  
 declare @v_DISCIPLINA [T_CODIGO]  
 declare @v_TIPO [T_ALFAMEDIUM]  
 declare @v_TURMA [T_CODIGO]  
 declare @v_ANO [T_ANO]  
 declare @v_SEMESTRE [T_SEMESTRE2]  
 declare @v_SUBTURMA1 [T_CODIGO]  
 declare @v_SUBTURMA2 [T_CODIGO]  
 declare @v_SIT_MATRICULA [varchar](100)  
 declare @v_SIT_DETALHE [T_ALFAMEDIUM]  
 declare @v_OBS [T_ALFAEXTRALARGE]  
 declare @v_MATRICULANOVA [T_SIMNAO]  
 declare @v_SERIE_IDEAL [T_NUMERO_PEQUENO]  
 declare @v_SERIE_CALCULO [T_NUMERO_PEQUENO]  
 declare @v_COBRANCA_SEP [T_ALFAMEDIUM]  
 declare @v_DT_CONFIRMACAO [T_DATA]  
 declare @v_DT_INSERCAO [T_DATA]  
 declare @v_DT_MATRICULA [T_DATA]  
 declare @v_GRUPO_ELETIVA [T_CODIGO]  
 declare @v_CONFIRMACAO_LIDER [T_ALFAMEDIUM]  
 declare @v_ALOCADO [T_ALFAMEDIUM]  
 declare @v_OPCAO [T_ALFAMEDIUM]  
 declare @v_DISCIPLINA_SUBST [T_CODIGO]  
 declare @v_TURMA_SUBST [T_CODIGO]  
 declare @v_CONTEXTO [T_ALFAMEDIUM]  
 declare @v_VERMAXREPROVACAO [T_SIMNAO]  
 declare @v_VERVAGA [T_SIMNAO]  
 declare @v_VERGRADE [T_SIMNAO]  
 declare @v_VERHORARIO [T_SIMNAO]  
 declare @v_VERPREREQ [T_SIMNAO]  
 declare @v_VERLIMITESCREDITOS [T_SIMNAO]  
 declare @v_VERDISCIPADAP [T_SIMNAO]  
 declare @v_VERPLANOESTUDO [T_SIMNAO]  
 declare @v_VERCARGAHORARIA [T_SIMNAO]  
 declare @v_ACEITE_ONLINE [T_SIMNAO]  
  
 declare @v_curriculo [T_CODIGO]  
 DECLARE @v_ErrorsCount int    
 declare @v_permitir_matr_dupl T_SIMNAO  
 declare @v_erro_validacao T_SIMNAO  
 declare @v_opcao_aluno numeric(6)   
 declare @v_matricula_nova T_SIMNAO  
  
    DECLARE @aux_banco varchar (10)  
    DECLARE @v_Errors varchar(8000)  
    declare @tipoMatricula [T_CODIGO]  
      
    DECLARE @v_return T_SIMNAO  
 DECLARE @v_mensagem varchar(2000)   
 declare @v_campo varchar(50)  
 declare @v_sucesso [T_SIMNAO]  
   
    EXEC tipobanco @aux_banco OUTPUT  
      
    EXEC RemErros  
      
 -- INICIA A TRANSAÃ├O  
       
    --exec SET_ERRO 'teste de erro'  
    --insert into zzCRO_Erros(spid,mensagem,campo)  
    --values(@@spid,'erroerro',null)  
    --return  
  
 -- Armazena valores padrÒo dos parÔmetros de entrada  
 if @p_pre_matricula is null  
  SET @p_pre_matricula = 'N'  
 if @p_troca_turma is null  
  SET @p_troca_turma = 'N'  
 if @p_plano_estudo is null  
  SET @p_plano_estudo = 'S'  
 if @p_valida_duplicidade_prior is null  
  SET @p_valida_duplicidade_prior = 'S'  
  
   
 if @p_pre_matricula = 'S'  
  SET @tipoMatricula = 'Pré-matrícula'  
 else  
  SET @tipoMatricula = 'Matrícula'   
    
 -- Inicializa varißveis  
 SET @v_erro_validacao = 'N'  
 SET @v_matricula_nova = 'N'  
   
 -- Valida o conjunto de turmas matriculadas  
 exec VALIDA_MATRICULA_GRUPO @p_sessao_id,@p_aluno, @p_ano, @p_semestre, @p_pre_matricula, @p_plano_estudo  
    EXEC GetErrorsCount @v_ErrorsCount OUTPUT  
    IF @v_ErrorsCount <> 0 BEGIN  
        exec DELETE_LY_PROCESSA_MATRICULA_GRUPO @p_sessao_id  
          
        SELECT @v_Errors = ''--'Erro ao validar a ' + @tipoMatricula + ':'  --Removido mediante solicitação da Secretaria Geral em 06/11/2017
        EXEC setErro @v_Errors, ''  
        --EXEC GetErros @v_Errors OUTPUT  
        --ROLLBACK TRAN TR_MATRICULA_CONJUNTO  
        --IF @aux_banco = 'SQL'   
        --  COMMIT TRANSACTION -- pois o rollback atÚ um save point nÒo decrementa a variavel @@trancount    
        --EXEC SetErro @v_Errors                
        RETURN      
    END  
  
 -- checa se permite duplicaþÒo de turma na matrÝcula  
 exec @v_opcao_aluno=FN_BUSCAR_OPCAO_ALUNO @p_aluno  
 SELECT @v_permitir_matr_dupl=max(PERMITIR_MATR_DUPL) FROM LY_OPCOES WHERE CHAVE = @v_opcao_aluno  
 if @v_permitir_matr_dupl is null  
  set @v_permitir_matr_dupl='N'  
   
  
 -- Valida as turmas matriculadas  
 -- declara  cursor para o grupo de turmas a serem matriculadas  
 declare C_MATRICULA_CONJUNTO cursor STATIC for  
 select [ID],[SESSAO_ID],[DISCIPLINA],[TIPO],[TURMA],[ANO],[SEMESTRE],[SUBTURMA1],[SUBTURMA2],  
   [SIT_MATRICULA],[SIT_DETALHE],[OBS],[MATRICULANOVA],[SERIE_IDEAL],[SERIE_CALCULO],  
   [COBRANCA_SEP],[DT_CONFIRMACAO],[DT_INSERCAO],[DT_MATRICULA],[GRUPO_ELETIVA],  
   [CONFIRMACAO_LIDER],[ALOCADO],[OPCAO],[DISCIPLINA_SUBST],[TURMA_SUBST],[CONTEXTO],  
   [VERMAXREPROVACAO],[VERVAGA],[VERGRADE],[VERHORARIO],[VERPREREQ],[VERLIMITESCREDITOS],  
   [VERDISCIPADAP],[VERPLANOESTUDO],[VERCARGAHORARIA],[ACEITE_ONLINE]  
 from LY_PROCESSA_MATRICULA_GRUPO  
 where SESSAO_ID=@p_sessao_id  
   
 open C_MATRICULA_CONJUNTO  
 fetch next from C_MATRICULA_CONJUNTO  
 into @v_UID,@v_SESSAO_ID,@v_DISCIPLINA,@v_TIPO,@v_TURMA,@v_ANO,@v_SEMESTRE,@v_SUBTURMA1,@v_SUBTURMA2,  
  @v_SIT_MATRICULA,@v_SIT_DETALHE,@v_OBS,@v_MATRICULANOVA,@v_SERIE_IDEAL,@v_SERIE_CALCULO,  
  @v_COBRANCA_SEP,@v_DT_CONFIRMACAO,@v_DT_INSERCAO,@v_DT_MATRICULA,@v_GRUPO_ELETIVA,  
  @v_CONFIRMACAO_LIDER,@v_ALOCADO,@v_OPCAO,@v_DISCIPLINA_SUBST,@v_TURMA_SUBST,@v_CONTEXTO,  
  @v_VERMAXREPROVACAO,@v_VERVAGA,@v_VERGRADE,@v_VERHORARIO,@v_VERPREREQ,@v_VERLIMITESCREDITOS,  
  @v_VERDISCIPADAP,@v_VERPLANOESTUDO,@v_VERCARGAHORARIA,@v_ACEITE_ONLINE  
 set @v_ErrorsCount=0  
   
   
 while (@@fetch_status = 0 and @v_ErrorsCount =0)          
  BEGIN    
      if @p_pre_matricula = 'S'  
    begin  
     IF @v_MATRICULANOVA = 'S'  
      BEGIN  
       exec VALIDA_MATRICULA @p_SESSAO_ID,@p_aluno,@p_pre_matricula,@p_disciplina_origem,  
              @v_UID,@v_DISCIPLINA,@v_TIPO,@v_TURMA,@v_ANO,@v_SEMESTRE,@v_SUBTURMA1,@v_SUBTURMA2,  
              @v_SIT_MATRICULA,@v_SIT_DETALHE,@v_OBS,@v_MATRICULANOVA,@v_SERIE_IDEAL,@v_SERIE_CALCULO,  
              @v_COBRANCA_SEP,@v_DT_CONFIRMACAO,@v_DT_INSERCAO,@v_DT_MATRICULA,@v_GRUPO_ELETIVA,  
              @v_CONFIRMACAO_LIDER,@v_ALOCADO,@v_OPCAO,@v_DISCIPLINA_SUBST,@v_TURMA_SUBST,@v_CONTEXTO,  
              @v_VERMAXREPROVACAO,@v_VERVAGA,@v_VERGRADE,@v_VERHORARIO,@v_VERPREREQ,@v_VERLIMITESCREDITOS,  
              @v_VERDISCIPADAP,@v_VERPLANOESTUDO,@v_VERCARGAHORARIA,@v_ACEITE_ONLINE   
       EXEC GetErrorsCount @v_ErrorsCount OUTPUT  
       IF @v_ErrorsCount <> 0   
        BEGIN  
         delete LY_HORARIO_AUX  
         where SESSAO_ID=@p_sessao_id  
         exec DELETE_LY_PROCESSA_MATRICULA_GRUPO @p_sessao_id  
           
         SELECT @v_Errors = ''--'Erro ao validar a ' + @tipoMatricula + ':'  --Removido mediante solicitação da Secretaria Geral em 06/11/2017
         EXEC setErro @v_Errors, ''  
         --EXEC GetErros @v_Errors OUTPUT  
         --ROLLBACK TRAN TR_MATRICULA_CONJUNTO  
         --IF @aux_banco = 'SQL'   
         -- COMMIT TRANSACTION -- pois o rollback atÚ um save point nÒo decrementa a variavel @@trancount    
         --EXEC SetErro @v_Errors                
         CLOSE C_MATRICULA_CONJUNTO          
         DEALLOCATE C_MATRICULA_CONJUNTO   
         RETURN      
        END  
      END  
    end  
   else  
    begin  
     exec MATRICULA_VALID @p_aluno, @v_DISCIPLINA, @v_turma, @v_ANO, @v_SEMESTRE, @v_return output, @v_mensagem output, @v_permitir_matr_dupl, 'N'  
     EXEC GetErrorsCount @v_ErrorsCount OUTPUT  
     IF @v_ErrorsCount <> 0 BEGIN  
      delete LY_HORARIO_AUX  
      where SESSAO_ID=@p_sessao_id  
      exec DELETE_LY_PROCESSA_MATRICULA_GRUPO @p_sessao_id  
        
      SELECT @v_Errors = ''--'Erro ao validar a ' + @tipoMatricula + ':'  --Removido mediante solicitação da Secretaria Geral em 06/11/2017
      EXEC setErro @v_Errors, ''  
      --EXEC GetErros @v_Errors OUTPUT  
      --ROLLBACK TRAN TR_MATRICULA_CONJUNTO  
      --IF @aux_banco = 'SQL'   
      -- COMMIT TRANSACTION -- pois o rollback atÚ um save point nÒo decrementa a variavel @@trancount    
      --EXEC SetErro @v_Errors                
      CLOSE C_MATRICULA_CONJUNTO          
      DEALLOCATE C_MATRICULA_CONJUNTO   
      RETURN      
     END  
       
     IF @v_return = 'N'       
      BEGIN  
       exec VALIDA_MATRICULA @p_SESSAO_ID,@p_aluno,@p_pre_matricula,@p_disciplina_origem,  
              @v_UID,@v_DISCIPLINA,@v_TIPO,@v_TURMA,@v_ANO,@v_SEMESTRE,@v_SUBTURMA1,@v_SUBTURMA2,  
              @v_SIT_MATRICULA,@v_SIT_DETALHE,@v_OBS,@v_MATRICULANOVA,@v_SERIE_IDEAL,@v_SERIE_CALCULO,  
              @v_COBRANCA_SEP,@v_DT_CONFIRMACAO,@v_DT_INSERCAO,@v_DT_MATRICULA,@v_GRUPO_ELETIVA,  
              @v_CONFIRMACAO_LIDER,@v_ALOCADO,@v_OPCAO,@v_DISCIPLINA_SUBST,@v_TURMA_SUBST,@v_CONTEXTO,  
              @v_VERMAXREPROVACAO,@v_VERVAGA,@v_VERGRADE,@v_VERHORARIO,@v_VERPREREQ,@v_VERLIMITESCREDITOS,  
              @v_VERDISCIPADAP,@v_VERPLANOESTUDO,@v_VERCARGAHORARIA,@v_ACEITE_ONLINE   
         
       EXEC GetErrorsCount @v_ErrorsCount output    
       IF @v_ErrorsCount <> 0   
        BEGIN  
         delete LY_HORARIO_AUX  
         where SESSAO_ID=@p_sessao_id  
         exec DELETE_LY_PROCESSA_MATRICULA_GRUPO @p_sessao_id  
           
         SELECT @v_Errors = ''--'Erro ao validar a ' + @tipoMatricula + ':'  --Removido mediante solicitação da Secretaria Geral em 06/11/2017
         EXEC setErro @v_Errors, ''  
         --EXEC GetErros @v_Errors OUTPUT  
         --ROLLBACK TRAN TR_MATRICULA_CONJUNTO  
         --IF @aux_banco = 'SQL'   
         -- COMMIT TRANSACTION -- pois o rollback atÚ um save point nÒo decrementa a variavel @@trancount    
         --EXEC SetErro @v_Errors                
         CLOSE C_MATRICULA_CONJUNTO          
         DEALLOCATE C_MATRICULA_CONJUNTO   
         RETURN      
        END   
       ELSE  
        SET @v_matricula_nova='S'               
      END   
     ELSE  
      SET @v_matricula_nova='N'   
        
        
     UPDATE LY_PROCESSA_MATRICULA_GRUPO   
     SET MATRICULANOVA = @v_matricula_nova  
     WHERE SESSAO_ID = @p_sessao_id  
     AND ID = @v_UID  
    end  
     
   fetch next from C_MATRICULA_CONJUNTO  
   into @v_UID,@v_SESSAO_ID,@v_DISCIPLINA,@v_TIPO,@v_TURMA,@v_ANO,@v_SEMESTRE,@v_SUBTURMA1,@v_SUBTURMA2,  
    @v_SIT_MATRICULA,@v_SIT_DETALHE,@v_OBS,@v_MATRICULANOVA,@v_SERIE_IDEAL,@v_SERIE_CALCULO,  
    @v_COBRANCA_SEP,@v_DT_CONFIRMACAO,@v_DT_INSERCAO,@v_DT_MATRICULA,@v_GRUPO_ELETIVA,  
    @v_CONFIRMACAO_LIDER,@v_ALOCADO,@v_OPCAO,@v_DISCIPLINA_SUBST,@v_TURMA_SUBST,@v_CONTEXTO,  
    @v_VERMAXREPROVACAO,@v_VERVAGA,@v_VERGRADE,@v_VERHORARIO,@v_VERPREREQ,@v_VERLIMITESCREDITOS,  
    @v_VERDISCIPADAP,@v_VERPLANOESTUDO,@v_VERCARGAHORARIA,@v_ACEITE_ONLINE  
  END  
 CLOSE C_MATRICULA_CONJUNTO          
 DEALLOCATE C_MATRICULA_CONJUNTO   
   
     
 EXEC GetErrorsCount @v_ErrorsCount OUTPUT  
    IF @v_ErrorsCount <> 0 BEGIN  
        delete LY_HORARIO_AUX  
  where SESSAO_ID=@p_sessao_id  
        exec DELETE_LY_PROCESSA_MATRICULA_GRUPO @p_sessao_id  
          
        SELECT @v_Errors = ''--'Erro ao validar a ' + @tipoMatricula + ':'  --Removido mediante solicitação da Secretaria Geral em 06/11/2017
        EXEC setErro @v_Errors, ''  
        --EXEC GetErros @v_Errors OUTPUT  
        --ROLLBACK TRAN TR_MATRICULA_CONJUNTO  
        --IF @aux_banco = 'SQL'   
        --  COMMIT TRANSACTION -- pois o rollback atÚ um save point nÒo decrementa a variavel @@trancount    
        --EXEC SetErro @v_Errors                
        RETURN      
    END  
             
 -- Se chegou atÚ aqui, Ú porque passou nas validaþ§es  
 -- E somente insere/atualiza se as matriculas estiverem como matricula_nova.   
 if @p_pre_matricula='N' begin  
  exec INSERE_MATRICULA_GRUPO @p_sessao_id,@p_aluno,@p_ano,@p_semestre,@v_curriculo  
 end   
 else begin  
  exec INSERE_PRE_MATRICULA_GRUPO @p_sessao_id,@p_aluno,@p_ano,@p_semestre,@v_curriculo,@p_troca_turma, @p_valida_duplicidade_prior  
 end  
    
 EXEC GetErrorsCount @v_ErrorsCount OUTPUT  
    IF @v_ErrorsCount <> 0 BEGIN  
        delete LY_HORARIO_AUX  
  where SESSAO_ID=@p_sessao_id  
        exec DELETE_LY_PROCESSA_MATRICULA_GRUPO @p_sessao_id  
          
        SELECT @v_Errors = ''--'Erro ao validar a ' + @tipoMatricula + ':'  --Removido mediante solicitação da Secretaria Geral em 06/11/2017
        EXEC setErro @v_Errors, ''  
        --EXEC GetErros @v_Errors OUTPUT  
        --ROLLBACK TRAN TR_MATRICULA_CONJUNTO  
        --IF @aux_banco = 'SQL'   
        --  COMMIT TRANSACTION -- pois o rollback atÚ um save point nÒo decrementa a variavel @@trancount    
        --EXEC SetErro @v_Errors                
        RETURN      
    END  
 delete LY_HORARIO_AUX  
 where SESSAO_ID=@p_sessao_id  
 exec DELETE_LY_PROCESSA_MATRICULA_GRUPO @p_sessao_id  
    --COMMIT TRANSACTION  
  
 RETURN  