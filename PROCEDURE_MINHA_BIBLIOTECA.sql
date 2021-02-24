USE LYCEUM
GO  
  
ALTER PROCEDURE dbo.C_FTC_INTEGRA_MINHA_BIBLIOTECA  
(  
 @P_ALUNO AS T_CODIGO,   
 @P_FIRSTNAME AS T_CODIGO OUTPUT,   
 @P_LASTNAME AS T_ALFALARGE OUTPUT,   
 @P_EMAIL AS VARCHAR(100) OUTPUT,  
 @P_APIKEY AS T_ALFAMEDIUM OUTPUT,   
 @P_MSGERRO AS T_ALFAMEDIUM OUTPUT,  
 @P_URL AS T_ALFALARGE OUTPUT  
)  
AS  
BEGIN  
    DECLARE @v_key AS T_ALFAMEDIUM  
    DECLARE @v_unidade_fisica AS T_CODIGO  
    DECLARE @v_nome_compl AS T_ALFALARGE  
    DECLARE @v_primeiro_nome AS T_ALFAMEDIUM  
    DECLARE @v_ultimo_nome AS T_ALFALARGE  
    DECLARE @v_posicao_primeiro_espaco AS NUMERIC(3)  
    DECLARE @v_email AS VARCHAR(100)  
   
    SET @v_key = ''  
    SET @v_nome_compl = ''  
    SET @v_primeiro_nome = ''  
    SET @v_ultimo_nome = ''  
    SET @v_email = ''  
    SET @P_MSGERRO = ''  
  
    -- Tenta localizar o aluno informado  
 --## RAUL - 16/02/2017 - alterado a chave email para aluno.  
    --SELECT @v_nome_compl = NOME_COMPL, @v_email = ISNULL(E_MAIL_INTERNO, ''), @v_unidade_fisica = UNIDADE_FISICA FROM LY_ALUNO WHERE ALUNO = @P_ALUNO  
 SELECT @v_nome_compl = NOME_COMPL, @v_email = ALUNO, @v_unidade_fisica = UNIDADE_FISICA FROM LY_ALUNO WHERE ALUNO = @P_ALUNO  
  
    -- código do aluno informado não foi localizado   
    IF @v_nome_compl = ''  
    BEGIN  
            SET @P_MSGERRO = 'Aluno informado não foi localizado no cadastro de alunos.'  
            RETURN  
    END  
    -- obteve o nome completo do aluno informado  
    ELSE  
    BEGIN  
            -- configuração da API-KEY  
            SET @v_key = '6fdbba77-a7ab-4b90-8743-0545bd7e9b75'  
            --IF @v_unidade_fisica = '001' SET @v_key = 'YYY-YYYYY-YYYYY-YYYY-YYYYY'  
            --IF @v_unidade_fisica = '003' SET @v_key = 'ZZZ-ZZZZZ-ZZZZZ-ZZZZ-ZZZZZ'  
  
            -- Obtem o primero e o último nome a partir do nome completo do aluno  
            SET @v_posicao_primeiro_espaco = PATINDEX ( '% %' , @v_nome_compl )  
            SET @v_primeiro_nome = RTRIM(LTRIM(SUBSTRING(@v_nome_compl, 1, @v_posicao_primeiro_espaco - 1)))  
            SET @v_ultimo_nome = RTRIM(LTRIM(SUBSTRING(@v_nome_compl, @v_posicao_primeiro_espaco + 1, LEN(@v_nome_compl))))  
    END  
  
    -- Verifica se foi possível obter os 4 parâmetros de output e caso contrário configura mensagem de erro  
    IF LEN(@v_primeiro_nome) = 0 OR LEN(@v_ultimo_nome) = 0 OR LEN(@v_key) = 0  --OR LEN(@v_email) = 0  
    BEGIN  
  
            IF LEN(@v_primeiro_nome) = 0 SET @P_MSGERRO = 'Não foi possível obter o primeiro nome do aluno.'  
  
            IF LEN(@v_ultimo_nome) = 0 SET @P_MSGERRO = @P_MSGERRO + ' Não foi possível obter o último nome do aluno.'  
  
   --## 16/02/2017 - alteramos para aluno o campo e-mail, por isso nao precisa desta validação  
            --IF LEN(@v_email) = 0 SET @P_MSGERRO = @P_MSGERRO + ' Não foi possível obter o e-mail do aluno.'  
  
            IF LEN(@v_key) = 0 SET @P_MSGERRO = @P_MSGERRO + ' Não foi possível obter a chave de acesso à Minha Biblioteca.'  
  
    END  
  
    SET @P_FIRSTNAME = @v_primeiro_nome  
    SET @P_LASTNAME = @v_ultimo_nome  
    SET @P_EMAIL = @v_email    -- esta enviando agora como chave o aluno no lugar do e-mail  
    SET @P_APIKEY = @v_key  
 SET @P_URL = 'https://digitallibrary-staging.zbra.com.br/DigitalLibraryIntegrationService/AuthenticatedUrl'  
  
END  