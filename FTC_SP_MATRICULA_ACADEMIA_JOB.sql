  
  
CREATE PROCEDURE FTC_SP_MATRICULA_ACADEMIA_JOB  
AS        
--## Declarar variaveis do cursor  
DECLARE @vc_aluno   VARCHAR(20),  
  @vc_ano    T_ANO,  
  @vc_mes    VARCHAR(2),  
  @vc_disciplina  VARCHAR(20),  
  @VC_SERVICO   T_CODIGO,   
  @VC_SOLICITACAO  T_NUMERO,   
  @VC_ITEM_SOLICITACAO T_NUMERO  
   
--## Inicio cursor  
DECLARE MATRICULA_ACADEMIA CURSOR STATIC READ_ONLY FOR   
  
 SELECT   
  IL.ALUNO        as ALUNO,   
  C.ANO         as ANO,  
  substring(S.VALOR,6,2)     AS MES,   -- o parametro agora é a turma  
  (CASE substring(S.VALOR,6,2) -- Nomeando os meses de acordo com a disciplina  
   WHEN '01' THEN 'ACAD_JAN'  
   WHEN '02' THEN 'ACAD_FEV'  
   WHEN '03' THEN 'ACAD_MAR'  
   WHEN '04' THEN 'ACAD_ABR'  
   WHEN '05' THEN 'ACAD_MAI'  
   WHEN '06' THEN 'ACAD_JUN'  
   WHEN '07' THEN 'ACAD_JUL'  
   WHEN '08' THEN 'ACAD_AGO'  
   WHEN '09' THEN 'ACAD_SET'  
   WHEN '10' THEN 'ACAD_OUT'  
   WHEN '11' THEN 'ACAD_NOV'  
   WHEN '12' THEN 'ACAD_DEZ' END)  as DISCIPLINA,  
  i.SERVICO        AS SERVICO,  
  i.solicitacao       as solicitacao,  
  i.ITEM_SOLICITACAO      as item_solicitacao  
 FROM LY_SOLICITACAO_SERV SS  
 JOIN LY_ITENS_SOLICIT_SERV I  
  ON SS.SOLICITACAO  = I.SOLICITACAO  
 JOIN LY_DETALHES_SOLICIT S    
  ON I.SOLICITACAO  = S.SOLICITACAO  
  and I.ITEM_SOLICITACAO = S.ITEM_SOLICITACAO  
  AND I.SERVICO   = S.SERVICO  
 JOIN LY_ITEM_LANC   IL   
  ON I.LANC_DEB   = IL.LANC_DEB  
  AND SS.ALUNO   = IL.ALUNO  
 JOIN VW_COBRANCA   C                -- VW utilizada para ver valor das cobranças  
  ON C.COBRANCA = IL.COBRANCA  
 WHERE I.SERVICO IN ('ACAD_ALU_EDFIS','ACAD_ALU_COLAB','ACAD_ALU_ALUFTC','ACAD_ALU_PUBEXT') -- verifica se estes servicos foram solicitados  
 AND C.VALOR   = 0                  -- verifica se o serviço foi pago, quando = 0 é pago  
 AND S.PARAMETRO  = 'Mês Mensalidade Academia'                    
 AND NOT EXISTS (SELECT TOP 1 1                -- Verifica se não tem a turma matriculada no ano  
     FROM LY_MATRICULA   
     WHERE ALUNO  = IL.ALUNO   
     AND TURMA  = S.VALOR  
     AND ANO   = C.ANO)   
 order by ss.aluno, ss.solicitacao              
                     
OPEN MATRICULA_ACADEMIA FETCH NEXT FROM MATRICULA_ACADEMIA INTO @VC_ALUNO, @VC_ANO, @VC_MES, @VC_DISCIPLINA, @VC_SERVICO, @VC_SOLICITACAO, @VC_ITEM_SOLICITACAO  
WHILE @@FETCH_STATUS = 0  
BEGIN  
  
--## Declarar variaveis que irão alimentar as variaveis da proc Ly_matricula_Insert  
  
DECLARE  
   @v_turma    varchar(20)  
  ,@v_semestre   numeric(2)  
  ,@v_sit_matricula  varchar(50)  
  ,@v_dt_ultalt   datetime  
  ,@v_cobranca_sep  varchar(1)  
  ,@v_dt_insercao   datetime  
  ,@v_dt_matricula  datetime  
  ,@v_stamp_atualizacao datetime  
 DECLARE @v_Errors varchar(8000)    
 DECLARE @v_ErrorsCount int = 0       
 DECLARE @aux_banco varchar (10)   
  
--Armazena dados da matricula do aluno  
  
SET @v_turma    =  'ACAD_'+ @vc_mes +'_'+ CONVERT(VARCHAR,@vc_ano)   
SET @v_semestre    = '0'   
SET @v_sit_matricula  = 'Matriculado'  
SET @v_dt_ultalt   = dbo.FN_GetDataDiaSemHora(GETDATE())  
SET @v_cobranca_sep   = 'N'  
SET @v_dt_insercao   = dbo.FN_GetDataDiaSemHora(GETDATE())  
SET @v_dt_matricula   = dbo.FN_GetDataDiaSemHora(GETDATE())  
SET @v_stamp_atualizacao = dbo.FN_GetDataDiaSemHora(GETDATE())  
  
 --## REMOVE A DISCIPLINA ACAD_LIVRE -> ELA É UTILIZADA SÓ PARA INGRESSAR O ALUNO, MAS DEVE SER RETIRADA  
  If EXISTS (SELECT TOP 1 1        
      FROM [VW_MATRICULA_E_PRE_MATRICULA] VMEPM   
      WHERE ALUNO  = @vc_aluno   
      AND DISCIPLINA = 'ACAD_LIVRE')  
  BEGIN  
   DELETE FROM LY_PRE_MATRICULA  
   WHERE ALUNO  = @vc_aluno  
   AND DISCIPLINA = 'ACAD_LIVRE'  
  
   DELETE FROM LY_MATRICULA  
   WHERE ALUNO  = @vc_aluno  
   AND DISCIPLINA = 'ACAD_LIVRE'  
  
  END  
  
 -- ROTINA DE INSERIR DISCIPLINA NA MATRICULA  
 If NOT EXISTS (SELECT TOP 1 1                -- Verifica se não tem a disciplina matriculada no ano  
     FROM LY_MATRICULA   
     WHERE ALUNO  = @vc_aluno   
     AND DISCIPLINA = @vc_disciplina  
     AND ANO   = @vc_ano  
     and TURMA  = @v_turma)  
  
  BEGIN  
  
    BEGIN TRY  
          BEGIN TRAN   
  
   -- Insere disciplina e turma na matricula do aluno  
   EXEC Ly_matricula_Insert  
          @aluno    = @vc_aluno  
         ,@disciplina  = @vc_disciplina  
         ,@turma    = @v_turma  
         ,@ano    = @vc_ano  
         ,@semestre   = @v_semestre  
         ,@sit_matricula  = @v_sit_matricula  
         ,@obs    = 'Inserido via Automação Academia'  
         ,@dt_ultalt   = @v_dt_ultalt  
         ,@cobranca_sep  = @v_cobranca_sep  
         ,@sit_detalhe  = 'Curricular'  
         ,@dt_insercao  = @v_dt_insercao  
         ,@dt_matricula  = @v_dt_matricula  
         ,@stamp_atualizacao = @v_stamp_atualizacao  
  
   -- Encerra a solicitação de serviço  
   exec LY_ANDAMENTO_INSERT    
           @servico   = @VC_SERVICO            
         , @passo   = 1              
         , @solicitacao  = @VC_SOLICITACAO          
         , @item_solicitacao = @VC_ITEM_SOLICITACAO          
         , @comentario  = 'Sua matrícula foi realizada com sucesso! Consultar disciplinas matriculadas.'         
         , @data    = @v_dt_ultalt     
         , @status   = 'Atendido'            
         , @setor   = 'AUTOMAÇÃO'            
         , @usuario   = 'Automação'   
  
  
          COMMIT TRAN  
          END TRY  
  
          BEGIN CATCH  
              -- Print error information.   
              PRINT 'Error ' + CONVERT(varchar(50), ERROR_NUMBER()) +  
                    ', Severity ' + CONVERT(varchar(5), ERROR_SEVERITY()) +  
                    ', State ' + CONVERT(varchar(5), ERROR_STATE()) +   
                    ', Procedure ' + ISNULL(ERROR_PROCEDURE(), '-') +   
                    ', Line ' + CONVERT(varchar(5), ERROR_LINE());  
              PRINT ERROR_MESSAGE();  
  
           IF XACT_STATE() <> 0  
           BEGIN  
            ROLLBACK TRANSACTION;  
           END  
  
     --## INICIO - RAUL - 09/02/2017 - Enviar e-mail para suportelyceum@ftc.edu.br sobre erro de matricula do aluno na academia  
    exec FTC_SP_SEND_MAIL_LOTE 'MatriculaAcademia', @vc_aluno, @vc_disciplina, @v_turma, null, null  
     --## FIM - RAUL - 09/02/2017 - Enviar e-mail para suportelyceum@ftc.edu.br sobre erro de matricula do aluno na academia  
  
          END CATCH  
  END  
  
FETCH NEXT FROM MATRICULA_ACADEMIA INTO @VC_ALUNO,@VC_ANO,@VC_MES,@VC_DISCIPLINA, @VC_SERVICO, @VC_SOLICITACAO, @VC_ITEM_SOLICITACAO  
END  
CLOSE MATRICULA_ACADEMIA  
DEALLOCATE MATRICULA_ACADEMIA  