USE LYCEUM
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.INSERE_PRE_MATRICULA_GRUPO'))
   exec('CREATE PROCEDURE [dbo].[INSERE_PRE_MATRICULA_GRUPO] AS BEGIN SET NOCOUNT OFF; END')
GO 
  
ALTER PROCEDURE INSERE_PRE_MATRICULA_GRUPO  (  
  @p_SESSAO_ID as varchar(40),    
  @p_aluno T_CODIGO,    
  @p_ANO T_ANO,  
  @p_SEMESTRE T_SEMESTRE2,  
  @p_CURRICULO T_CODIGO,  
  @p_troca_turma varchar(1) = 'N',  
  @p_validaduplprior varchar(1) = 'S')  
as  
begin  
-- ################################################################################################  
-- <DOC> Descricao:  
-- <DOC>  
-- <DOC> Insere ou altera as prÚ-matriculas do aluno (TRATA_PRE_MATRICULA).  
-- <DOC>  
-- <DOC> Parametros:  
-- <DOC>   
-- <DOC> @p_sessao_id varchar(40) - id da conexÒo  
-- <DOC> @p_aluno T_CODIGO - c¾digo do aluno  
-- <DOC> @p_ano T_ANO - ano da matrÝcula  
-- <DOC> @p_semestre T_SEMESTRE2 - perÝodo da matrÝcula  
-- <DOC> @p_curriculo T_CODIGO - c¾digo do currÝculo  
-- <DOC> @p_troca_turma varchar(1) - se Ú transferÛncia de turma - utilizado somente para prÚ-matricula  
-- <DOC> @p_valida_duplicidade_prior varchar(1) - somente para prÚ-matricula - nÒo Ú mais utilizado  
-- <DOC>   
-- <DOC> Retorno:  
-- <DOC>  
-- <DOC> Nenhum (procedure);  
-- <DOC>   
-- <DOC> Roteiro de execuþÒo:  
-- <DOC>  
-- <DOC> 1. Busca as matriculas.  
-- <DOC> 2. Para cada uma executa a atualizaþÒo (TRATA_PRE_MATRICULA).  
-- <DOC>  
-- ################################################################################################  
  
 declare @v_DISCIPLINA T_CODIGO  
 Declare @v_TURMA T_CODIGO  
 declare @v_ANO T_ANO  
 declare @v_SEMESTRE T_SEMESTRE2  
 declare @v_MATRICULANOVA T_SIMNAO  
 declare @v_campo varchar(50)  
 declare @v_mensagem varchar(2000)  
 declare @v_sucesso T_SIMNAO  
    
 DECLARE @v_ErrorsCount int    
 DECLARE @aux_banco varchar (10)  
    DECLARE @v_Errors varchar(8000)   
    
    EXEC tipobanco @aux_banco OUTPUT  
      
 -- INICIA A TRANSAÃ├O  
 --BEGIN TRANSACTION TR_INSERE_MATRICULA_CONJUNTO  
 --SAVE TRANSACTION TR_INSERE_MATRICULA_CONJUNTO  
   
 -- Valida as turmas matriculadas  
 -- declara  cursor para o grupo de turmas a serem matriculadas  
 declare C_VALIDA_MATR_CONJUNTO cursor STATIC for  
 select DISCIPLINA,TURMA,ANO,SEMESTRE,MATRICULANOVA   
 from LY_PROCESSA_MATRICULA_GRUPO  
 where SESSAO_ID=@p_sessao_id  
   
 open C_VALIDA_MATR_CONJUNTO  
 fetch next from C_VALIDA_MATR_CONJUNTO  
 into @v_DISCIPLINA,@v_TURMA,@v_ANO,@v_SEMESTRE,@v_MATRICULANOVA  
  
 set @v_ErrorsCount=0  
 while (@@fetch_status = 0 and @v_ErrorsCount =0)          
  BEGIN    
   set @v_campo = ''  
   set @v_mensagem = ''  
   set @v_sucesso = 'N'  
     
   -- E somente insere/atualiza se as matriculas estiverem como matricula_nova.   
   if @v_MATRICULANOVA = 'S' begin  
    exec TRATA_PRE_MATRICULA @p_sessao_id,@p_aluno,@v_DISCIPLINA,@v_TURMA,@v_ANO,  
          @v_SEMESTRE,@v_campo output,@v_mensagem output,@v_sucesso output,@p_troca_turma,@p_validaduplprior  
      
    if @v_sucesso = 'N' begin  
     if ISNULL(@v_mensagem,'') = ''  
      set @v_Errors = 'Erro ao inserir Pré-matrícula'
     else  
      set @v_Errors = @v_mensagem   
       
     exec SetErro @v_errors,''  
    end  
   end  
     
   fetch next from C_VALIDA_MATR_CONJUNTO  
   into @v_DISCIPLINA,@v_TURMA,@v_ANO,@v_SEMESTRE,@v_MATRICULANOVA  
  END  
 CLOSE C_VALIDA_MATR_CONJUNTO          
 DEALLOCATE C_VALIDA_MATR_CONJUNTO   
   
 EXEC GetErrorsCount @v_ErrorsCount OUTPUT  
    IF @v_ErrorsCount <> 0 BEGIN  
        SELECT @v_Errors = ''  --Mensagem removida mediante solicitação da Secretaria Geral em 06/11/2017 por Girlane
        EXEC setErro @v_Errors, ''  
        EXEC GetErros @v_Errors OUTPUT  
        --ROLLBACK TRAN TR_INSERE_MATRICULA_CONJUNTO  
        IF @aux_banco = 'SQL'   
          --COMMIT TRANSACTION -- pois o rollback atÚ um save point nÒo decrementa a variavel @@trancount    
        EXEC SetErro @v_Errors                
        RETURN      
    END  
 --COMMIT TRANSACTION  
end  