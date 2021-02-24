--## 6.2.1-hf14  
    
ALTER PROCEDURE S_VALIDA_AOL_SOLICITACAO_SERVICO       
     @p_Aluno  T_CODIGO,    
     @p_Servico  T_CODIGO,       
     @p_PessoaLogada T_CODIGO,    
     @p_ESenhaMestre T_SIMNAO,    
     @p_Msg   VARCHAR(500) OUTPUT      
     AS
  
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------           
-- ENTRY-POINT UTILIZADO PARA VALIDAR O SERVIÇO QUE ESTÁ TENTANDO SER SOLICITADO PELO AOL NG.          
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------           
-- @p_Msg  - Caso haja mensagem de retorno o fluxo não continuará, consequentemente o aluno não conseguirá realizar a solicitação daquele serviço.          
-- -- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------          
-- NOTA: OS PARÂMETROS DE RETORNO SOMENTE SERÃO LEVADOS EM CONSIDERAÇÃO CASO FOR DIFERENTE DE VAZIO (@P_Msg <> '')          
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------          
  
--## INICIO - RAUL - 14/12/2015 - 0001 - Valida os serviços de academia para cada grupo de aluno  
  
    If @p_Servico IN ('ACAD_ALU_EDFIS','ACAD_ALU_ALUFTC','ACAD_ALU_COLAB','ACAD_ALU_PUBEXT')   
        Begin  
            --# Alunos Educ. Física  
            If @p_Servico = 'ACAD_ALU_EDFIS'  
            and not exists (select 1 from LY_ALUNO  
                            where ALUNO = @p_Aluno  
                            and GRUPO = 'GPA01')  
                Begin  
                    SET @p_Msg = 'FTC - Este serviço é exclusivo para Alunos Educ. Física'              
                    RETURN     
                End  
  
            --# Alunos FTC - Exceto Curso Educ. Física  
            If @p_Servico = 'ACAD_ALU_ALUFTC'  
            and not exists (select 1 from LY_ALUNO  
                            where ALUNO = @p_Aluno  
                            and GRUPO = 'GPA02')  
                Begin  
                    SET @p_Msg = 'FTC - Este serviço é exclusivo para Alunos FTC - Exceto Curso Educ. Física'              
                    RETURN     
                End  
  
            --# Colaboradores FTC  
            If @p_Servico = 'ACAD_ALU_COLAB'  
            and not exists (select 1 from LY_ALUNO  
                            where ALUNO = @p_Aluno  
                            and GRUPO = 'GPA03')  
                Begin  
                    SET @p_Msg = 'FTC - Este serviço é exclusivo para Colaboradores FTC'              
                    RETURN     
                End  
  
  
            --# Não Alunos e Não Colaboradores  
            If @p_Servico = 'ACAD_ALU_PUBEXT'  
            and not exists (select 1 from LY_ALUNO  
                            where ALUNO = @p_Aluno  
                            and GRUPO = 'GPA04')  
                Begin  
                    SET @p_Msg = 'FTC - Este serviço é exclusivo para Não Alunos e Não Colaboradores'              
                    RETURN     
                End  

        End  
      
--## FIM - RAUL - 14/12/2015 - 0001 - Valida os serviços de academia para cada grupo de aluno  

--## INICIO - MIGUEL - 27/09/2016 - 0002 - Valida os serviços que filtram alunos Cancelados/Evadidos  
 
 If @p_Servico IN ('AOL_CANCM','AOL_CANCONV','AOL_CANFOR')
 and exists (select 1 from LY_ALUNO  
                 where ALUNO = @p_Aluno  
                 and SIT_ALUNO in ('Cancelado','Evadido')) 
        Begin  

   --# Alunos Cancelados/Evadidos não podem acessar esse serviço  
   SET @p_Msg = 'FTC - Aluno cancelado ou evadido não pode solicitar este serviço.'              
   RETURN     
   End  
      
--## FIM - MIGUEL - 27/09/2016 - 0002 - Valida os serviços que filtram alunos Cancelados/Evadidos  
-- 
--## Resultado padrão do EP          
SET @p_Msg = ''              
RETURN          