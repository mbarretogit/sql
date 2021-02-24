USE LYCEUM
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
ALTER PROCEDURE [dbo].[INTEGRACAO_RH_LYC]    
@p_cpf T_CODIGO    
AS    
BEGIN -- 1*    
  
---------------------------------------------------------------------------------  
  
   declare @v_ret int;     
  
   exec [checkLinkedServer] 'PRODUCAO', @v_ret output;     
       
   if @v_ret = 0     
      return;  
  
---------------------------------------------------------------------------------  
  
   -- SE NÃO PASSAR PARAMETRO COLOCO NULL 08/06/2016    
   IF @p_cpf = ''    
      SET @p_cpf = NULL    
    
   -- DECLARAR VARIAVEIS QUE SERÃO USADAS NO CURSOR    
   DECLARE @VC_PESSOA                  NUMERIC(20),    
           @VC_LOCAL                   VARCHAR(100)    
    
   -- DECLARAÇÃO DE VARIAVEIS PARA SEREM USADAS NA LY_PESSOA_UPDATE, LY_PESSOA_INSERT, LY_DOCENTE_UPDATE, LY_DOCENTE_INSERT    
   DECLARE @V_NOME_COMPL               VARCHAR(200),    
           @V_NOME_ABREV               VARCHAR(200),    
           @V_DT_NASC                  DATETIME,    
           @V_MUNICIPIO_NASC           VARCHAR(200),    
           @V_PAIS_NASC                VARCHAR(200),    
           @V_NACIONALIDADE            VARCHAR(200),    
           @V_NOME_PAI                 VARCHAR(200),    
           @V_NOME_MAE                 VARCHAR(200),    
           @V_SEXO                     VARCHAR(200),    
           @V_EST_CIVIL                VARCHAR(200),    
           @V_END_CORRETO              VARCHAR(200),    
           @V_ENDERECO                 VARCHAR(200),    
           @V_END_NUM                  VARCHAR(200),    
           @V_END_COMPL                VARCHAR(200),    
           @V_BAIRRO                   VARCHAR(200),    
           @V_END_MUNICIPIO            VARCHAR(200),    
           @V_END_PAIS                 VARCHAR(200),    
           @V_CEP                      VARCHAR(200),    
           @V_FONE                     VARCHAR(200),    
           @V_PROFISSAO                VARCHAR(200),    
           @V_NOME_EMPRESA             VARCHAR(200),    
           @V_CARGO                    VARCHAR(200),    
           @V_ENDCOM                   VARCHAR(200),    
           @V_ENDCOM_NUM               VARCHAR(200),    
           @V_ENDCOM_COMPL             VARCHAR(200),    
           @V_ENDCOM_BAIRRO            VARCHAR(200),    
           @V_ENDCOM_PAIS              VARCHAR(200),    
           @V_ENDCOM_MUNICIPIO         VARCHAR(200),    
           @V_ENDCOM_CEP               VARCHAR(200),    
           @V_FONE_COM                 VARCHAR(200),    
           @V_FAX                      VARCHAR(200),    
           @V_RG_NUM                   VARCHAR(200),    
           @V_RG_TIPO                  VARCHAR(200),    
           @V_RG_EMISSOR               VARCHAR(200),    
           @V_RG_UF                    VARCHAR(200),    
           @V_RG_DTEXP                 DATETIME,    
           @V_CPF                      VARCHAR(200),    
           @V_ALIST_NUM                VARCHAR(200),    
           @V_ALIST_SERIE              VARCHAR(200),    
           @V_ALIST_RM                 VARCHAR(200),    
           @V_ALIST_CSM                VARCHAR(200),    
           @V_ALIST_DTEXP              DATETIME,    
           @V_CR_NUM                   VARCHAR(200),    
           @V_CR_CAT                   VARCHAR(200),    
           @V_CR_SERIE                 VARCHAR(200),    
           @V_CR_RM                    VARCHAR(200),    
           @V_CR_CSM                   VARCHAR(200),    
           @V_CR_DTEXP                 DATETIME,    
           @V_TELEITOR_NUM             VARCHAR(200),    
           @V_TELEITOR_ZONA            VARCHAR(200),    
           @V_TELEITOR_SECAO           VARCHAR(200),    
           @V_TELEITOR_DTEXP           DATETIME,    
           @V_CPROF_NUM                VARCHAR(200),    
           @V_CPROF_SERIE              VARCHAR(200),    
           @V_CPROF_UF                 VARCHAR(200),    
           @V_CPROF_DTEXP              DATETIME,    
           @V_E_MAIL                   VARCHAR(200),    
           @V_MAILBOX   VARCHAR(200),    
           @V_HAB_TAC_DATA             DATETIME,    
           @V_OBS                      VARCHAR(4100),    
           @V_SENHA_TAC                VARCHAR(200),    
           @V_DT_FALECIMENTO           DATETIME,    
           @V_RESP_NOME_COMPL          VARCHAR(200),    
           @V_RESP_MUNICIPIO_NASC      VARCHAR(200),    
           @V_RESP_NACIONALIDADE       VARCHAR(200),    
           @V_RESP_SEXO                VARCHAR(200),    
           @V_RESP_EST_CIVIL           VARCHAR(200),    
           @V_RESP_ENDERECO            VARCHAR(200),    
           @V_RESP_END_NUM             VARCHAR(200),    
           @V_RESP_END_COMPL           VARCHAR(200),    
           @V_RESP_BAIRRO              VARCHAR(200),    
           @V_RESP_END_MUNICIPIO       VARCHAR(200),    
           @V_RESP_CEP                 VARCHAR(200),    
           @V_RESP_FONE                VARCHAR(200),    
           @V_RESP_RG_NUM              VARCHAR(200),    
           @V_RESP_RG_TIPO             VARCHAR(200),    
           @V_RESP_RG_EMISSOR          VARCHAR(200),    
           @V_RESP_RG_UF               VARCHAR(200),    
           @V_RESP_CPF                 VARCHAR(200),    
           @V_CELULAR                  VARCHAR(200),    
           @V_FAX_RES                  VARCHAR(200),    
           @V_E_MAIL_COM               VARCHAR(200),    
           @V_E_MAIL_INTERNO           VARCHAR(200),    
           @V_NOME_CONJUGE             VARCHAR(200),    
           @V_OBS_TEL_RES              VARCHAR(200),    
           @V_OBS_TEL_COM              VARCHAR(200),    
           @V_DIVIDA_BIBLIO            VARCHAR(200),    
           @V_NECESSIDADE_ESPECIAL     VARCHAR(200),    
           @V_NUM_FUNC                 NUMERIC(25,0),    
           @V_RESP_SENHA               VARCHAR(200),    
           @V_TELEITOR_MUN             VARCHAR(200),    
           @V_RESP_END_PAIS            VARCHAR(200),    
           @V_RENDA_MENSAL             NUMERIC(20, 10),    
           @V_COR_RACA                 VARCHAR(200),    
           @V_AREA_PROF                VARCHAR(200),    
           @V_ESPECIALIZACAO           VARCHAR(200),    
           @V_CERT_NASC_NUM            VARCHAR(200),    
           @V_CERT_NASC_FOLHA          VARCHAR(200),    
           @V_CERT_NASC_LIVRO          VARCHAR(200),    
           @V_CERT_NASC_EMISSAO        DATETIME,    
           @V_CERT_NASC_CARTORIO_UF    VARCHAR(200),    
           @V_CERT_NASC_CARTORIO_EXPED VARCHAR(200),    
           @V_FONE_RECADOS             VARCHAR(200),    
           @V_AUTORIZA_ENVIO_MAIL      VARCHAR(200),    
           @V_CONSELHO_REGIONAL        VARCHAR(200),    
           @V_PERMITEACESCADSEMSENHA   VARCHAR(200),    
           @V_PASSAPORTE               VARCHAR(200),    
           @V_PERMITE_USAR_IMAGEM      VARCHAR(200),    
           @V_FORMACAO_PAI             VARCHAR(200),    
           @V_FORMACAO_MAE             VARCHAR(200),    
           @V_DEPTO_COM                VARCHAR(200),    
           @V_WINUSUARIO               VARCHAR(200),    
           @V_RENDA_FAMILIAR           NUMERIC(20, 10),    
           @V_ID_CENSO                 VARCHAR(200),    
           @V_NR_REGUA                 VARCHAR(200),    
           @V_SENHA_ALTERADA           VARCHAR(200),    
           @V_TIPO_SANGUINEO           VARCHAR(200),    
           @V_ETNIA                    VARCHAR(200),    
           @V_CREDO                    VARCHAR(200),    
           @V_QT_FILHOS                NUMERIC(20, 10),    
           @V_PRE_NOME_SOCIAL          VARCHAR(200),    
           @V_STAMP_ATUALIZACAO        DATETIME,    
           @V_DDD_FONE                 VARCHAR(200),    
           @V_DDD_FONE_COMERCIAL       VARCHAR(200),    
           @V_DDD_FONE_CELULAR         VARCHAR(200),    
           @V_DDD_FONE_RECADO          VARCHAR(200),    
           @V_DDD_RESP_FONE            VARCHAR(200),    
           @V_HAB_TAC                  VARCHAR(200),    
           @V_OBS_FAX_RES              VARCHAR(200),    
 @V_OBS_CEL                  VARCHAR(200),    
           @V_OBS_TEL_REC              VARCHAR(200),    
           @V_RESP_FONE_OBS            VARCHAR(200),    
           @V_RESP_RG_DTEXP            VARCHAR(200),    
           @V_CERT_NASC_MATRICULA      VARCHAR(200),    
           @V_CONTRIBUI_RENDA          VARCHAR(200),    
           @V_RESP_E_MAIL              VARCHAR(200),    
           @V_DDD_FAX_RES              VARCHAR(200),    
           @V_LATITUDE                 VARCHAR(200),    
           @V_LONGITUDE                VARCHAR(200),    
           @V_FACULDADE                VARCHAR(200),    
           @V_DEPTO                    VARCHAR(200),    
           @V_ATIVO                    VARCHAR(200),    
           @V_PERC_DEDIC_MENS          NUMERIC(20,10),    
           @V_TITULACAO                VARCHAR(200),    
           @V_ATUACAO_PROFIS           VARCHAR(2100),    
           @V_SENHA_DOL                VARCHAR(200),    
           @V_FAX_COM                  VARCHAR(200),    
           @V_TIPO_PESSOA              VARCHAR(200),    
           @V_RAZAO_SOCIAL             VARCHAR(200),    
           @V_DT_HABILIT_DOL           DATETIME,    
           @V_CATEGORIA                VARCHAR(200),    
           @V_RE                       VARCHAR(200),    
           @V_DT_ADMISSAO              DATETIME,    
           @V_DT_ULT_TITULO            DATETIME,    
           @V_FECHAR_TURMA_INTERNET    VARCHAR(200),    
           @V_PAIS_RES                 VARCHAR(200),    
           @V_URL_PARTICULAR           VARCHAR(600),    
           @V_URL_PROFISSIONAL         VARCHAR(600),    
           @V_PISPASEP                 VARCHAR(200),    
           @V_CONTRATO_TRABALHO        VARCHAR(200),    
           @V_REGIME_TRABALHO          VARCHAR(200),    
           @V_OUTRA_FACULDADE          VARCHAR(200),    
           @V_SOBRENOME                VARCHAR(200),    
           @V_COD_LATTES               VARCHAR(1100),    
           @V_DT_DEMISSAO              DATETIME,    
           @V_MATRICULA                VARCHAR(200),    
           @V_SENHA_TAC_LY_PESSOA      VARCHAR(200),    
           @V_MANTENEDORA              VARCHAR(100),    
           @V_UNIDADE_ENSINO           T_CODIGO,    
           @V_CPF_ORIGINAL             VARCHAR(200),    
           @V_FL_FIELD_10              VARCHAR(2000)    
                          
   -- Javert    
   DECLARE @TSQL1                      VARCHAR(8000),    
           @TSQL2                      VARCHAR(8000),  
           @TSQL3                      NVARCHAR(4000),  
           @V_SITUACAO                 CHAR(1), -- 06/07/2020 - Javert  
           @V_STATUS                   VARCHAR(1)  
    
   --LIMPAR TABELA DE ERROS DE IMPORTAÇÃO    
   TRUNCATE TABLE ERROS_INTEGRACAO_RH    
    
   --## Inicio do cursor    
   --DECLARE CURSOR_RH_LYC CURSOR STATIC READ_ONLY FOR    
    
   --####### [CONSULTA QUE RETORNA DADOS QUE VOU UTILIZAR NO CURSOR] #######    
   SET @TSQL1 = ' DECLARE CURSOR_RH_LYC CURSOR STATIC READ_ONLY FOR    
                  SELECT a.HAB_TAC, a.NOME_COMPL, a.NOME_ABREV, a.DT_NASC, a.MUNICIPIO_NASC, a.PAIS_NASC, a.NACIONALIDADE, a.NOME_PAI,    
                    a.NOME_MAE, a.SEXO, a.EST_CIVIL, a.END_CORRETO,a.ENDERECO, a.END_NUM, a.END_COMPL, a.BAIRRO, a.END_MUNICIPIO,    
                    a.END_PAIS, a.CEP, a.FONE, a.PROFISSAO, a.NOME_EMPRESA, a.CARGO, a.ENDCOM, a.ENDCOM_NUM,a.ENDCOM_COMPL,    
                    a.ENDCOM_BAIRRO, a.ENDCOM_PAIS, a.ENDCOM_MUNICIPIO, a.ENDCOM_CEP, a.FONE_COM, a.FAX, a.RG_NUM, a.RG_TIPO,    
                    a.RG_EMISSOR, a.RG_UF, a.RG_DTEXP, a.CPF, a.ALIST_NUM, a.ALIST_SERIE, a.ALIST_RM, a.ALIST_CSM, a.ALIST_DTEXP,    
                    a.CR_NUM, a.CR_CAT, a.CR_SERIE, a.CR_RM, a.CR_CSM, a.CR_DTEXP, a.TELEITOR_NUM, a.TELEITOR_ZONA, a.TELEITOR_SECAO,    
                    a.TELEITOR_DTEXP, a.CPROF_NUM, a.CPROF_SERIE, a.CPROF_UF, a.CPROF_DTEXP, a.E_MAIL, a.MAILBOX, a.HAB_TAC_DATA,    
                    a.OBS, a.SENHA_TAC, a.DT_FALECIMENTO, a.RESP_NOME_COMPL, a.RESP_MUNICIPIO_NASC, a.RESP_NACIONALIDADE, a.RESP_SEXO,    
                    a.RESP_EST_CIVIL, a.RESP_ENDERECO, a.RESP_END_NUM, a.CELULAR, a.FAX_RES, a.E_MAIL_COM, a.E_MAIL_INTERNO,    
                    a.NOME_CONJUGE, a.OBS_TEL_RES, a.OBS_TEL_COM, a.DIVIDA_BIBLIO, a.TELEITOR_MUN, a.AREA_PROF, a.WINUSUARIO,    
                    a.STAMP_ATUALIZACAO, a.DDD_FONE, a.DDD_FONE_COMERCIAL, a.DDD_FONE_CELULAR, a.DDD_FONE_RECADO, a.DDD_RESP_FONE,    
                    a.DEPTO, a.ATIVO, a.PERC_DEDIC_MENS, a.TITULACAO, a.ATUACAO_PROFIS, a.CPF, a.DT_HABILIT_DOL, a.CATEGORIA, a.RE,    
                    a.DT_ADMISSAO, a.DT_ULT_TITULO, a.PAIS_RES, a.URL_PARTICULAR, a.URL_PROFISSIONAL, a.PISPASEP, a.CONTRATO_TRABALHO,    
                    a.COD_LATTES, a.DT_DEMISSAO, a.MATRICULA, a.MANTENEDORA,     
                    a.SITUACAO' -- 06/07/2020 - Javert    
    
   IF @p_cpf IS NOT NULL    
      SET @TSQL1 += ' FROM openquery(PRODUCAO,''select distinct * from RM.RH_LYC_DOCENTE where rownum <= 100 and IMPORTADO = ''''N'''' and CPF = ''''' + @p_cpf +    
                       ''''' order by CPF'') a'    
   ELSE    
      SET @TSQL1 += ' FROM openquery(PRODUCAO,''select distinct * from RM.RH_LYC_DOCENTE where rownum <= 100 and IMPORTADO = ''''N'''' order by CPF'') a'    
    
   EXEC(@TSQL1)    
    
   OPEN CURSOR_RH_LYC    
   FETCH NEXT FROM CURSOR_RH_LYC INTO @V_HAB_TAC, @V_NOME_COMPL, @V_NOME_ABREV, @v_DT_NASC,    
                     @V_MUNICIPIO_NASC, @V_PAIS_NASC, @V_NACIONALIDADE, @V_NOME_PAI, @V_NOME_MAE, @V_SEXO,    
                     @V_EST_CIVIL, @V_END_CORRETO, @V_ENDERECO, @V_END_NUM, @V_END_COMPL, @V_BAIRRO,    
                     @V_END_MUNICIPIO, @V_END_PAIS, @V_CEP, @V_FONE, @V_PROFISSAO, @V_NOME_EMPRESA, @V_CARGO,    
                     @V_ENDCOM, @V_ENDCOM_NUM, @V_ENDCOM_COMPL, @V_ENDCOM_BAIRRO, @V_ENDCOM_PAIS,    
                     @V_ENDCOM_MUNICIPIO, @V_ENDCOM_CEP, @V_FONE_COM, @V_FAX, @V_RG_NUM, @V_RG_TIPO, @V_RG_EMISSOR,    
                     @V_RG_UF, @V_RG_DTEXP, @V_CPF, @V_ALIST_NUM, @V_ALIST_SERIE, @V_ALIST_RM, @V_ALIST_CSM,    
                     @V_ALIST_DTEXP, @V_CR_NUM, @V_CR_CAT, @V_CR_SERIE, @V_CR_RM, @V_CR_CSM, @V_CR_DTEXP, @V_TELEITOR_NUM,    
                     @V_TELEITOR_ZONA, @V_TELEITOR_SECAO, @V_TELEITOR_DTEXP, @V_CPROF_NUM, @V_CPROF_SERIE, @V_CPROF_UF,    
                     @V_CPROF_DTEXP, @V_E_MAIL, @V_MAILBOX, @V_HAB_TAC_DATA, @V_OBS, @V_SENHA_TAC, @V_DT_FALECIMENTO,    
                     @V_RESP_NOME_COMPL, @V_RESP_MUNICIPIO_NASC, @V_RESP_NACIONALIDADE, @V_RESP_SEXO, @V_RESP_EST_CIVIL,    
                     @V_RESP_ENDERECO, @V_RESP_END_NUM, @V_CELULAR, @V_FAX_RES, @V_E_MAIL_COM, @V_E_MAIL_INTERNO,    
                     @V_NOME_CONJUGE, @V_OBS_TEL_RES, @V_OBS_TEL_COM, @V_DIVIDA_BIBLIO, @V_TELEITOR_MUN, @V_AREA_PROF,    
                     @V_WINUSUARIO, @V_STAMP_ATUALIZACAO, @V_DDD_FONE, @V_DDD_FONE_COMERCIAL, @V_DDD_FONE_CELULAR,    
                     @V_DDD_FONE_RECADO, @V_DDD_RESP_FONE, @V_DEPTO, @V_ATIVO, @V_PERC_DEDIC_MENS, @V_TITULACAO,    
                     @V_ATUACAO_PROFIS, @V_SENHA_DOL, @V_DT_HABILIT_DOL, @V_CATEGORIA, @V_RE, @V_DT_ADMISSAO, @V_DT_ULT_TITULO,    
                     @V_PAIS_RES, @V_URL_PARTICULAR, @V_URL_PROFISSIONAL, @V_PISPASEP, @V_CONTRATO_TRABALHO, @V_COD_LATTES,    
                     @V_DT_DEMISSAO, @V_MATRICULA, @V_MANTENEDORA,     
                     @V_SITUACAO -- 06/07/2020 - Javert    
    
   WHILE @@FETCH_STATUS = 0    
   BEGIN -- 2*    
      BEGIN TRY  
         -- Se a data de demissão foi informada verifica se existe outro professor ativo com o mesmo CPF  
         IF @V_DT_DEMISSAO is not null  
         BEGIN  
           SET @TSQL3 = 'select @V_STATUS = status from openquery(PRODUCAO, ''select decode(max(1),1,''''S'''',''''N'''') status 
		   from RM.PFUNC f join RM.PPESSOA p on p.codigo = f.codpessoa where rownum < 2 and f.codsituacao in (''''A'''',''''C'''',''''E'''',''''F'''') and p.cpf = '''''+@V_CPF+''''' '')'  
           EXEC sp_executesql @TSQL3, N'@V_STATUS VARCHAR(1) out', @V_STATUS out  
              
           -- Coloca NULL em @V_DT_DEMISSAO quando encontra um professor ativo com o mesmo CPF  
           IF @V_STATUS = 'S'  
              SET @V_DT_DEMISSAO = null  
         END  
    
         SET @V_MUNICIPIO_NASC        = ISNULL((SELECT TOP 1 B.CODIGO    
                                                FROM MUNICIPIO B    
                                                WHERE B.CODIGO_IBGE = @V_MUNICIPIO_NASC),'00000')    
         SET @V_PAIS_NASC             = ISNULL(@V_PAIS_NASC,'BRASIL')    
         SET @V_NACIONALIDADE         = ISNULL(@V_NACIONALIDADE,'BRASILEIRA')    
         SET @V_END_MUNICIPIO         = ISNULL((SELECT TOP 1 B.CODIGO    
                                                FROM MUNICIPIO B    
                                                WHERE B.CODIGO_IBGE = @V_END_MUNICIPIO),'00000')    
         SET @V_SENHA_DOL             = dbo.crypt(@V_CPF)    
         SET @V_SENHA_TAC             = dbo.crypt(@V_CPF)    
         SET @V_OUTRA_FACULDADE       = NULL    
         SET @V_SOBRENOME             = NULL    
         SET @V_SENHA_ALTERADA        = 'N'    
         SET @V_FACULDADE             = NULL    
         SET @V_FAX_COM               = NULL    
         SET @V_TIPO_PESSOA           = NULL    
         SET @V_RAZAO_SOCIAL          = NULL    
         SET @V_FECHAR_TURMA_INTERNET = 'N'    
         SET @V_REGIME_TRABALHO       = NULL    
    
         PRINT 'PESSOA COM CPF: ' + ISNULL(@V_CPF,'')    
    
         --## VALIDAÇÃO NA LY_PESSOA: SE O DOCENTE JA TIVER UMA PESSOA CRIADA, ATUALIZA OS DADOS DE PESSOA DELE 
  
         IF EXISTS (SELECT TOP 1 1 FROM LY_PESSOA WHERE CPF = @V_CPF)    
         BEGIN -- 3*  SE EXISTIR PESSOA DO DOCENTE-> ATUALIZA AS INFORMAAÇÕES DA LY_PESSOA COM A DA [PRODUCAO]..RM.RH_LYC_DOCENTE    
    
            -- Javert - 12/04/2019    
            -- Primeiro verifica se existe uma pessoa associada a uma turma do semestre corrente    
            select @VC_PESSOA = max(pes.pessoa)    
            from ly_docente doc    
                 join ly_turma tur    
                   on tur.num_func = doc.num_func    
                 join ly_pessoa pes    
                   on pes.pessoa = doc.pessoa    
            where tur.ano = year(getdate())    
              and (tur.semestre = 0 or tur.semestre = iif(convert(date,getdate()) >= convert(date,convert(varchar,year(getdate()))+'-08-01'),2,1))    
              and doc.cpf = @V_CPF    
    
            -- Javert - 12/04/2019    
            -- Não havendo uma pessoa associada a uma turma do semestre corrente, procura uma pessoa associada a uma turma (qualquer ano e semestre)    
            if @VC_PESSOA is null    
            begin    
               select @VC_PESSOA = max(pes.pessoa)    
               from ly_docente doc    
                    join ly_turma tur    
                      on tur.num_func = doc.num_func    
                    join ly_pessoa pes    
                      on pes.pessoa = doc.pessoa    
               where doc.cpf = @V_CPF    
            end    
    
            -- Javert - 12/04/2019    
            -- Não havendo uma pessoa associada a uma turma, pega a pessoa existente    
            if @VC_PESSOA is null    
            begin    
               select @VC_PESSOA = max(pes.pessoa)    
               from ly_pessoa pes    
               where pes.cpf = @V_CPF    
            end    
    
            -- Javert - 12/04/2019    
            -- NO UPDATE OBTEM OS DADOS EXISTENTES NA LY_PESSOA, POIS DEVEM PERMANECER OS DADOS EXISTENTES    
            select top 1    
                   @V_SENHA_TAC      = pes.SENHA_TAC    
                  ,@V_E_MAIL_COM     = pes.E_MAIL_COM    
                  ,@V_E_MAIL_INTERNO = pes.E_MAIL_INTERNO    
                  ,@V_E_MAIL         = pes.E_MAIL    
            from ly_pessoa pes    
            where pes.pessoa = @VC_PESSOA    
    
            SET @VC_LOCAL = 'LY_PESSOA'    
    
            -- Javert - 12/04/2019    
    -- SET @VC_PESSOA = (SELECT MAX(PESSOA) FROM LY_PESSOA WHERE CPF = @V_CPF)    
    
            PRINT 'EXISTE PESSOA: ATUALIZA OS DADOS: '  + ISNULL(convert(varchar(10), @VC_PESSOA),'')    
    
            -- UPDATE LY_PESSOA    
            EXEC LY_PESSOA_UPDATE @pkPessoa            = @VC_PESSOA    
                                 ,@NOME_COMPL          = @V_NOME_COMPL    
                                 ,@NOME_ABREV          = @V_NOME_ABREV    
                                 ,@DT_NASC             = @v_DT_NASC    
                                 ,@MUNICIPIO_NASC      = @V_MUNICIPIO_NASC    
                                 ,@PAIS_NASC           = @V_PAIS_NASC    
                                 ,@NACIONALIDADE       = @V_NACIONALIDADE    
                                 ,@NOME_PAI            = @V_NOME_PAI    
                                 ,@NOME_MAE            = @V_NOME_MAE    
                                 ,@SEXO                = @V_SEXO    
                                 ,@EST_CIVIL           = @V_EST_CIVIL    
                                 ,@END_CORRETO         = @V_END_CORRETO    
                                 ,@ENDERECO            = @V_ENDERECO    
                                 ,@END_NUM             = @V_END_NUM    
                                 ,@END_COMPL           = @V_END_COMPL    
                                 ,@BAIRRO              = @V_BAIRRO    
                                 ,@END_MUNICIPIO       = @V_END_MUNICIPIO    
                                 ,@END_PAIS            = @V_END_PAIS    
                                 ,@CEP                 = @V_CEP    
                                 ,@FONE                = @V_FONE    
                                 ,@PROFISSAO           = @V_PROFISSAO    
                                 ,@NOME_EMPRESA        = @V_NOME_EMPRESA    
                                 ,@CARGO               = @V_CARGO    
                                 ,@ENDCOM              = @V_ENDCOM    
                                 ,@ENDCOM_NUM          = @V_ENDCOM_NUM    
                                 ,@ENDCOM_COMPL        = @V_ENDCOM_COMPL    
                                 ,@ENDCOM_BAIRRO       = @V_ENDCOM_BAIRRO    
                                 ,@ENDCOM_PAIS         = @V_ENDCOM_PAIS    
                                 ,@ENDCOM_MUNICIPIO    = @V_ENDCOM_MUNICIPIO    
                                 ,@ENDCOM_CEP          = @V_ENDCOM_CEP    
                                 ,@FONE_COM            = @V_FONE_COM    
                                 ,@FAX                 = @V_FAX    
                                 ,@RG_NUM              = @V_RG_NUM    
                                 ,@RG_TIPO             = @V_RG_TIPO    
                                 ,@RG_EMISSOR          = @V_RG_EMISSOR    
                                 ,@RG_UF               = @V_RG_UF    
                                 ,@RG_DTEXP            = @V_RG_DTEXP    
                                 ,@CPF                 = @V_CPF    
                                 ,@ALIST_NUM           = @V_ALIST_NUM    
                                 ,@ALIST_SERIE         = @V_ALIST_SERIE    
                                 ,@ALIST_RM            = @V_ALIST_RM    
                                 ,@ALIST_CSM           = @V_ALIST_CSM    
                                 ,@ALIST_DTEXP         = @V_ALIST_DTEXP    
                                 ,@CR_NUM              = @V_CR_NUM    
                                 ,@CR_CAT              = @V_CR_CAT    
                                 ,@CR_SERIE            = @V_CR_SERIE    
                                 ,@CR_RM               = @V_CR_RM    
                                 ,@CR_CSM              = @V_CR_CSM    
                                 ,@CR_DTEXP            = @V_CR_DTEXP    
                                 ,@TELEITOR_NUM        = @V_TELEITOR_NUM    
                                 ,@TELEITOR_ZONA       = @V_TELEITOR_ZONA    
                                 ,@TELEITOR_SECAO      = @V_TELEITOR_SECAO    
                                 ,@TELEITOR_DTEXP      = @V_TELEITOR_DTEXP    
                                 ,@CPROF_NUM           = @V_CPROF_NUM    
                                 ,@CPROF_SERIE         = @V_CPROF_SERIE    
                                 ,@CPROF_UF            = @V_CPROF_UF    
                                 ,@CPROF_DTEXP         = @V_CPROF_DTEXP    
                                 ,@E_MAIL              = @V_E_MAIL    
                                 ,@MAILBOX             = @V_MAILBOX    
                                 ,@HAB_TAC_DATA        = @V_HAB_TAC_DATA    
                                 ,@OBS                 = @V_OBS    
                                 ,@SENHA_TAC           = @V_SENHA_TAC    
                                 ,@DT_FALECIMENTO      = @V_DT_FALECIMENTO    
                                 ,@RESP_NOME_COMPL     = @V_RESP_NOME_COMPL    
                                 ,@RESP_MUNICIPIO_NASC = @V_RESP_MUNICIPIO_NASC    
                                 ,@RESP_NACIONALIDADE  = @V_RESP_NACIONALIDADE    
                                 ,@RESP_SEXO           = @V_RESP_SEXO    
                                 ,@RESP_EST_CIVIL      = @V_RESP_EST_CIVIL    
                                 ,@RESP_ENDERECO       = @V_RESP_ENDERECO    
                                 ,@RESP_END_NUM        = @V_RESP_END_NUM    
                                 ,@CELULAR             = @V_CELULAR    
                                 ,@E_MAIL_INTERNO      = @V_E_MAIL_INTERNO    
                                 ,@NOME_CONJUGE        = @V_NOME_CONJUGE    
                                 ,@DIVIDA_BIBLIO       = @V_DIVIDA_BIBLIO    
                                 ,@TELEITOR_MUN        = @V_TELEITOR_MUN    
                                 ,@AREA_PROF           = @V_AREA_PROF    
                                 ,@DDD_FONE            = @V_DDD_FONE    
                                 ,@DDD_FONE_COMERCIAL  = @V_DDD_FONE_COMERCIAL    
                                 ,@DDD_FONE_CELULAR    = @V_DDD_FONE_CELULAR    
                                 ,@DDD_FONE_RECADO     = @V_DDD_FONE_RECADO    
                                 ,@DDD_RESP_FONE       = @V_DDD_RESP_FONE    
    
         END  -- 3*  --IF EXISTS ( SELECT 1 FROM LYCEUM..LY_PESSOA WHERE CPF = @CPF)    
         --#######    
          ELSE    
         --#######    
         BEGIN -- 4* -- SE NÃO EXISTIR A PESSOA PARA O DOCENTE, CADASTRA UMA PESSOA PARA O MESMO COM AS INFORMAÇÕES DA [PRODUCAO]..RM.RH_LYC_DOCENTE    
    
            PRINT 'NÃO EXISTE PESSOA, SERA INSERIDO UMA PESSOA NOVA COM OS DADOS DA [PRODUCAO]..RM.RH_LYC_DOCENTE'    
    
            SET @VC_LOCAL  = 'LY_PESSOA'    
    
            -- OBTER O NOVO CÓDIGO DA LY_PESSOA PARA FAZER O INSERT    
            SET @VC_PESSOA = (SELECT MAX(PESSOA) + 1 FROM LY_PESSOA )    
    
            -- INSERT LY_PESSOA    
            EXEC LY_PESSOA_INSERT @PESSOA              = @VC_PESSOA    
                                 ,@HAB_TAC             = @V_HAB_TAC    
                                 ,@NOME_COMPL          = @V_NOME_COMPL    
                                 ,@NOME_ABREV          = @V_NOME_ABREV    
                                 ,@DT_NASC             = @V_DT_NASC    
                                 ,@MUNICIPIO_NASC      = @V_MUNICIPIO_NASC    
                                 ,@PAIS_NASC           = @V_PAIS_NASC    
                                 ,@NACIONALIDADE       = @V_NACIONALIDADE    
                                 ,@NOME_PAI            = @V_NOME_PAI    
                                 ,@NOME_MAE            = @V_NOME_MAE    
                                 ,@SEXO                = @V_SEXO    
                                 ,@EST_CIVIL           = @V_EST_CIVIL    
                                 ,@END_CORRETO         = @V_END_CORRETO    
                                 ,@ENDERECO            = @V_ENDERECO    
                                 ,@END_NUM             = @V_END_NUM    
                                 ,@END_COMPL           = @V_END_COMPL    
                                 ,@BAIRRO              = @V_BAIRRO    
                                 ,@END_MUNICIPIO       = @V_END_MUNICIPIO    
                                 ,@END_PAIS            = @V_END_PAIS    
                                 ,@CEP                 = @V_CEP    
                                 ,@FONE                = @V_FONE    
                                 ,@PROFISSAO           = @V_PROFISSAO    
                                 ,@NOME_EMPRESA        = @V_NOME_EMPRESA    
                                 ,@CARGO               = @V_CARGO    
                                 ,@ENDCOM              = @V_ENDCOM    
                                 ,@ENDCOM_NUM          = @V_ENDCOM_NUM    
                                 ,@ENDCOM_COMPL        = @V_ENDCOM_COMPL    
                                 ,@ENDCOM_BAIRRO       = @V_ENDCOM_BAIRRO    
                                 ,@ENDCOM_PAIS         = @V_ENDCOM_PAIS    
                                 ,@ENDCOM_MUNICIPIO    = @V_ENDCOM_MUNICIPIO    
                                 ,@ENDCOM_CEP          = @V_ENDCOM_CEP    
                                 ,@FONE_COM            = @V_FONE_COM    
                                 ,@FAX                 = @V_FAX    
                                 ,@RG_NUM              = @V_RG_NUM    
                                 ,@RG_TIPO             = @V_RG_TIPO    
                                 ,@RG_EMISSOR          = @V_RG_EMISSOR    
                                 ,@RG_UF               = @V_RG_UF    
                                 ,@RG_DTEXP            = @V_RG_DTEXP    
                                 ,@CPF                 = @V_CPF    
                                 ,@ALIST_NUM           = @V_ALIST_NUM    
                                 ,@ALIST_SERIE         = @V_ALIST_SERIE    
                                 ,@ALIST_RM            = @V_ALIST_RM    
                                 ,@ALIST_CSM           = @V_ALIST_CSM    
                                 ,@ALIST_DTEXP         = @V_ALIST_DTEXP    
                                 ,@CR_NUM              = @V_CR_NUM    
                                 ,@CR_CAT              = @V_CR_CAT    
                                 ,@CR_SERIE            = @V_CR_SERIE    
                                 ,@CR_RM               = @V_CR_RM    
                                 ,@CR_CSM              = @V_CR_CSM    
                                 ,@CR_DTEXP            = @V_CR_DTEXP    
                                 ,@TELEITOR_NUM        = @V_TELEITOR_NUM    
                                 ,@TELEITOR_ZONA       = @V_TELEITOR_ZONA    
                                 ,@TELEITOR_SECAO      = @V_TELEITOR_SECAO    
                                 ,@TELEITOR_DTEXP      = @V_TELEITOR_DTEXP    
                                 ,@CPROF_NUM           = @V_CPROF_NUM    
                                 ,@CPROF_SERIE         = @V_CPROF_SERIE    
                                 ,@CPROF_UF            = @V_CPROF_UF    
                                 ,@CPROF_DTEXP         = @V_CPROF_DTEXP    
                                 ,@E_MAIL              = @V_E_MAIL    
                                 ,@MAILBOX             = @V_MAILBOX    
                                 ,@HAB_TAC_DATA        = @V_HAB_TAC_DATA    
                                 ,@OBS                 = @V_OBS    
                                 ,@SENHA_TAC           = @V_SENHA_TAC    
                                 ,@DT_FALECIMENTO      = @V_DT_FALECIMENTO    
                                 ,@RESP_NOME_COMPL     = @V_RESP_NOME_COMPL    
                                 ,@RESP_MUNICIPIO_NASC = @V_RESP_MUNICIPIO_NASC    
                                 ,@RESP_NACIONALIDADE  = @V_RESP_NACIONALIDADE    
                                 ,@RESP_SEXO           = @V_RESP_SEXO    
                                 ,@RESP_EST_CIVIL      = @V_RESP_EST_CIVIL    
                                 ,@RESP_ENDERECO       = @V_RESP_ENDERECO    
                          ,@RESP_END_NUM        = @V_RESP_END_NUM    
                                 ,@CELULAR             = @V_CELULAR    
                                 ,@E_MAIL_INTERNO      = @V_E_MAIL_INTERNO    
                                 ,@NOME_CONJUGE        = @V_NOME_CONJUGE    
                                 ,@DIVIDA_BIBLIO       = @V_DIVIDA_BIBLIO    
                                 ,@TELEITOR_MUN        = @V_TELEITOR_MUN    
                                 ,@AREA_PROF           = @V_AREA_PROF    
                                 ,@DDD_FONE            = @V_DDD_FONE    
                                 ,@DDD_FONE_COMERCIAL  = @V_DDD_FONE_COMERCIAL    
                                 ,@DDD_FONE_CELULAR    = @V_DDD_FONE_CELULAR    
                                 ,@DDD_FONE_RECADO     = @V_DDD_FONE_RECADO    
                                 ,@DDD_RESP_FONE       = @V_DDD_RESP_FONE    
                                 ,@RESP_END_COMPL      = @V_RESP_END_COMPL    
                                 ,@RESP_BAIRRO         = @V_RESP_BAIRRO    
                                 ,@RESP_END_MUNICIPIO  = @V_RESP_END_MUNICIPIO    
                                 ,@RESP_CEP            = @V_RESP_CEP    
                                 ,@RESP_FONE           = @V_RESP_FONE    
                                 ,@RESP_RG_NUM         = @V_RESP_RG_NUM    
                                 ,@RESP_RG_TIPO        = @V_RESP_RG_TIPO    
                                 ,@RESP_RG_EMISSOR     = @V_RESP_RG_EMISSOR    
                                 ,@RESP_RG_UF          = @V_RESP_RG_UF    
                                 ,@RESP_CPF            = @V_RESP_CPF    
    
         END -- 4* -- else --IF EXISTS ( SELECT 1 FROM LYCEUM..LY_PESSOA WHERE CPF = @CPF)    
    
	      -- Javert - 09/02/2021
		  -- Se a informação que vem é de um docente demitido e este já está demitido no Lyceum apenas atualiza o flag de importado na tabela RH_LYC_DOCENTE (RM)
		  IF EXISTS (SELECT TOP 1 1 FROM LY_DOCENTE WHERE ativo = 'N' and fl_field_10 = @V_CPF)    
         BEGIN 
           IF @V_DT_DEMISSAO is not null and @V_ATIVO = 'N'
            BEGIN
              --## MARCAR QUE REGISTRO FOI IMPORTADO    
              SET @TSQL2 = 'UPDATE R SET IMPORTADO = ''S'''    
                         + ' ,DT_IMPORTACAO_LYC = GETDATE() '    
                         + ' ,PESSOA = ISNULL(' + RTRIM(CONVERT(VARCHAR(10),@VC_PESSOA)) + ',(SELECT MAX(PESSOA) FROM LY_PESSOA WHERE CPF = ''' + @V_CPF + '''))'    
                         + ' FROM OPENQUERY(PRODUCAO,''select * from RM.RH_LYC_DOCENTE where IMPORTADO = ''''N'''' and CPF = ''''' + @V_CPF + ''''''') R'    
              EXEC(@TSQL2)    
    
              IF @@ROWCOUNT = 0    
              BEGIN    
               PRINT ('ERRO update rm.rh_lyc_docente - CPF: ' + ISNULL(@V_CPF,''))    
             END    
           
             CONTINUE
            END
           
         END

         IF EXISTS (SELECT TOP 1 1 FROM LY_DOCENTE D WHERE D.PESSOA = @VC_PESSOA)    
         BEGIN -- 5* -- SE EXISTIR O DOCENTE-> ATUALIZA AS INFORMAÇÕES DA LY_DOCENTE COM A DA [PRODUCAO]..RM.RH_LYC_DOCENTE    
    
            PRINT 'EXISTE DOCENTE: ATUALIZA OS DADOS'    
    
            SET @VC_LOCAL = 'LY_DOCENTE'    
    
            -- Javert - 12/04/2019    
            -- Primeiro verifica se existe um docente ativo associado a uma turma do semestre corrente    
            select @V_NUM_FUNC = max(doc.num_func)    
            from ly_docente doc    
                 join ly_turma tur    
                   on tur.num_func = doc.num_func    
            where tur.ano = year(getdate())    
              and (tur.semestre = 0 or tur.semestre = iif(convert(date,getdate()) >= convert(date,convert(varchar,year(getdate()))+'-08-01'),2,1))    
              and doc.ativo = 'S'    
              and doc.dt_demissao is null    
              and doc.pessoa = @VC_PESSOA    
    
            -- Javert - 12/04/2019    
            -- Não havendo um docente ativo associado a uma turma do semestre corrente, procura um docente associado a uma turma (qualquer ano e semestre)    
            if @V_NUM_FUNC is null    
            begin    
               select @V_NUM_FUNC = max(doc.num_func)    
               from ly_docente doc    
                    join ly_turma tur    
                      on tur.num_func = doc.num_func    
               where doc.ativo = 'S'    
                 and doc.dt_demissao is null    
                 and doc.pessoa = @VC_PESSOA    
            end    
    
            -- Javert - 12/04/2019    
            -- Não havendo um docente ativo associado a uma turma, pega o docente existente    
            if @V_NUM_FUNC is null    
            begin    
               select @V_NUM_FUNC = max(doc.num_func)    
               from ly_docente doc    
               where 1 = 1  
                 --and doc.ativo = 'S'    
                 --and doc.dt_demissao is null    
                 and doc.pessoa = @VC_PESSOA    
            end    
    
            -- OBTEM OS DADOS DA LY_DOCENTE, POIS DEVEM PERMANECER OS DADOS JÁ EXISTENTES    
            -- Javert - 24/03/2020    
            -- Se a data de demissão não for nula então: zera o CPF, guarda o CPF anterior e coloca Ativo = 'N'    
            select top 1    
                   @V_E_MAIL       = d.e_mail    
                  ,@V_E_MAIL_COM   = d.e_mail_com    
                  ,@V_CELULAR      = d.celular    
                  ,@V_CPF          = (case    
                                       when @V_DT_DEMISSAO is not null then '00000000000'    
                                       else d.cpf    
                                     end)    
                  ,@V_FL_FIELD_10  = (case    
                                       when @V_DT_DEMISSAO is not null then d.cpf    
                                       else d.fl_field_10    
                                     end)    
                  ,@V_ATIVO        = (case    
                                       when @V_DT_DEMISSAO is not null then 'N' -- Foi demitido no RM  
                                       when @V_SITUACAO = 'L'          then 'N' -- 06/07/2020 - Javert  
                                       when @V_DT_DEMISSAO is null     then 'S' -- Não foi demitido no RM - 19/08/2020 - Javert  
                                       else d.ATIVO    
                                     end)  
            from ly_docente d    
            where d.num_func = @V_NUM_FUNC    
    
            -- UPDATE LY_DOCENTE    
            EXEC LY_DOCENTE_UPDATE @pkNum_func        = @V_NUM_FUNC    
                                  ,@DEPTO             = @V_DEPTO    
                                  ,@ATIVO             = @V_ATIVO    
                                  ,@NOME_COMPL        = @V_NOME_COMPL    
                                  ,@NOME_ABREV        = @V_NOME_ABREV    
                                  ,@ENDERECO          = @V_ENDERECO    
                                  ,@END_NUM           = @V_END_NUM    
                                  ,@END_COMPL         = @V_END_COMPL    
                                  ,@BAIRRO            = @V_BAIRRO    
                                  ,@CEP               = @V_CEP    
                                  ,@FONE              = @V_FONE    
                                  ,@CPF               = @V_CPF    
                                  ,@RG_TIPO           = @V_RG_TIPO    
                                  ,@RG_NUM            = @V_RG_NUM    
                                  ,@RG_DTEXP          = @V_RG_DTEXP    
                                  ,@RG_UF             = @V_RG_UF    
                                  ,@RG_EMISSOR        = @V_RG_EMISSOR    
                                  ,@ENDCOM            = @V_ENDCOM    
                                  ,@ENDCOM_NUM        = @V_ENDCOM_NUM    
                                  ,@ENDCOM_COMPL      = @V_ENDCOM_COMPL    
                                  ,@ENDCOM_BAIRRO     = @V_ENDCOM_BAIRRO    
                                  ,@ENDCOM_PAIS       = @V_ENDCOM_PAIS    
                                  ,@ENDCOM_MUNICIPIO  = @V_ENDCOM_MUNICIPIO    
                                  ,@ENDCOM_CEP        = @V_ENDCOM_CEP    
                                  ,@FONE_COM          = @V_FONE_COM    
                                  ,@PERC_DEDIC_MENS   = @V_PERC_DEDIC_MENS    
                                  ,@E_MAIL            = @V_E_MAIL    
                                  ,@MAILBOX           = @V_MAILBOX    
                                  ,@TITULACAO         = @V_TITULACAO    
                                  ,@ATUACAO_PROFIS    = @V_ATUACAO_PROFIS    
                                  ,@OBS               = @V_OBS    
                                  ,@CPROF_NUM         = @V_CPROF_NUM    
                                  ,@CPROF_SERIE       = @V_CPROF_SERIE    
                                  ,@CPROF_UF          = @V_CPROF_UF    
                                  ,@CELULAR           = @V_CELULAR    
                                  ,@FAX_RES           = @V_FAX_RES    
                                  ,@E_MAIL_COM        = @V_E_MAIL_COM    
                                  ,@CATEGORIA         = @V_CATEGORIA    
                                  ,@RE                = @V_RE    
                                  ,@DT_ADMISSAO       = @V_DT_ADMISSAO    
                                  ,@DT_NASC           = @V_DT_NASC    
                                  ,@EST_CIVIL         = @V_EST_CIVIL    
                                  ,@DT_ULT_TITULO     = @V_DT_ULT_TITULO    
                                  ,@PAIS_RES          = @V_PAIS_RES    
                                  ,@URL_PARTICULAR    = @V_URL_PARTICULAR    
                                  ,@URL_PROFISSIONAL  = @V_URL_PROFISSIONAL    
                                  ,@PISPASEP          = @V_PISPASEP    
                                  ,@CONTRATO_TRABALHO = @V_CONTRATO_TRABALHO    
                                  ,@REGIME_TRABALHO   = @V_REGIME_TRABALHO    
                                  ,@COD_LATTES        = @V_COD_LATTES    
                                  ,@WINUSUARIO        = @V_WINUSUARIO    
                                  ,@DT_DEMISSAO       = @V_DT_DEMISSAO    
                                  ,@STAMP_ATUALIZACAO = @V_STAMP_ATUALIZACAO    
                                  ,@MATRICULA         = @V_MATRICULA    
                                  ,@FL_FIELD_10       = @V_FL_FIELD_10    
    
            IF (@V_DT_DEMISSAO IS NULL) or (@V_SITUACAO <> 'L') -- 06/07/2020 - Javert    
            BEGIN -- 7*  -- ATUALIZA O CADASTRO DE UNIDADES DO DOCENTE ATIVANDO OS ACESSOS DELE    
               SET @VC_LOCAL = 'LY_DOCENTE_UNIDADE - REATIVA'    
    
               -- ATUALIZA O CADASTRO DE UNIDADES DO DOCENTE ATIVANDO O ACESSO DELE    
               UPDATE DU SET ATIVO = 'S'    
               FROM LY_DOCENTE_UNIDADE DU    
               WHERE 1 = 1    
                 AND DU.NUM_FUNC = @V_NUM_FUNC    
            END -- 7*    
    
            IF (@V_DT_DEMISSAO IS NOT NULL) or (@V_SITUACAO = 'L') -- 06/07/2020 - Javert    
            BEGIN -- 8*  -- DOCENTES DESATIVADOS DA FTC -> INATIVAR TODAS AS UNIDADES DO DOCENTE    
               SET @VC_LOCAL = 'LY_DOCENTE_UNIDADE - DESATIVADA'    
    
               -- ATUALIZA O CADASTRO DE UNIDADES DO DOCENTE DESATIVANDO O ACESSO DELE    
               UPDATE DU SET ATIVO = 'N'    
               FROM LY_DOCENTE_UNIDADE DU    
               WHERE 1 = 1    
                 AND DU.NUM_FUNC = @V_NUM_FUNC    
            END -- 8*    
    
         END --5*    
         --#######    
         ELSE    
         --#######    
         BEGIN -- 9* --  SE NÃO EXISTIR  O DOCENTE, CADASTRAR UM DOCENTE COM AS INFORMAÇÕES DA [PRODUCAO]..RM.RH_LYC_DOCENTE    
    
            PRINT 'NÃO EXISTE DOCENTE'    
    
            SET @VC_LOCAL = 'LY_DOCENTE'    
    
            EXEC GET_NUMERO 'num_func','0', @V_NUM_FUNC OUTPUT    
    
            -- INSERT LY_DOCENTE    
            EXEC LY_DOCENTE_INSERT @NUM_FUNC               = @V_NUM_FUNC    
                                  ,@FACULDADE              = @V_FACULDADE    
                                  ,@DEPTO                  = @V_DEPTO    
                                  ,@ATIVO                  = @V_ATIVO    
                                  ,@NOME_COMPL             = @V_NOME_COMPL    
                                  ,@NOME_ABREV             = @V_NOME_ABREV    
                                  ,@ENDERECO               = @V_ENDERECO    
                                  ,@END_NUM                = @V_END_NUM    
                                  ,@END_COMPL              = @V_END_COMPL    
                                  ,@BAIRRO                 = @V_BAIRRO    
                                  ,@MUNICIPIO              = @V_MUNICIPIO_NASC    
                                  ,@CEP                    = @V_CEP    
                                  ,@FONE                   = @V_FONE    
                                  ,@CPF                    = @V_CPF    
                                  ,@RG_TIPO                = @V_RG_TIPO    
                                  ,@RG_NUM                 = @V_RG_NUM    
                                  ,@RG_DTEXP               = @V_RG_DTEXP    
                                  ,@RG_UF                  = @V_RG_UF    
                                  ,@RG_EMISSOR             = @V_RG_EMISSOR    
                                  ,@ENDCOM                 = @V_ENDCOM    
                                  ,@ENDCOM_NUM             = @V_ENDCOM_NUM    
                                  ,@ENDCOM_COMPL           = @V_ENDCOM_COMPL    
                                  ,@ENDCOM_BAIRRO          = @V_ENDCOM_BAIRRO    
                                  ,@ENDCOM_PAIS            = @V_ENDCOM_PAIS    
                                  ,@ENDCOM_MUNICIPIO       = @V_ENDCOM_MUNICIPIO    
                                  ,@ENDCOM_CEP             = @V_ENDCOM_CEP    
                                  ,@FONE_COM               = @V_FONE_COM    
                                  ,@PERC_DEDIC_MENS        = @V_PERC_DEDIC_MENS    
                                  ,@E_MAIL                 = @V_E_MAIL    
                                  ,@MAILBOX                = @V_MAILBOX    
                                  ,@TITULACAO              = @V_TITULACAO    
                                  ,@ATUACAO_PROFIS         = @V_ATUACAO_PROFIS    
                                  ,@OBS                    = @V_OBS    
                                  ,@CPROF_NUM              = @V_CPROF_NUM    
                                  ,@CPROF_SERIE            = @V_CPROF_SERIE    
                                  ,@CPROF_DATAEXP          = NULL    
                                  ,@CPROF_UF               = @V_CPROF_UF    
                                  ,@HAB_TAC                = @V_HAB_TAC    
                                  ,@SENHA_DOL              = @V_SENHA_DOL    
                                  ,@CELULAR                = @V_CELULAR    
                                  ,@FAX_RES                = @V_FAX_RES    
                                  ,@FAX_COM                = @V_FAX_COM    
                                  ,@NOME_EMPRESA           = @V_NOME_EMPRESA    
                                  ,@E_MAIL_COM             = @V_E_MAIL_COM    
                                  ,@BANCO                  = NULL    
                                  ,@AGENCIA                = NULL    
                                  ,@CONTA_BANCO            = NULL    
                                  ,@TIPO_PESSOA            = NULL    
                                  ,@RAZAO_SOCIAL           = NULL    
                                  ,@ENDEMP                 = NULL    
                                  ,@ENDEMP_NUM             = NULL    
                                  ,@ENDEMP_COMPL           = NULL    
                                  ,@ENDEMP_BAIRRO          = NULL    
                                  ,@ENDEMP_MUNICIPIO       = NULL    
                                  ,@ENDEMP_CEP             = NULL    
                                  ,@FONE_EMP               = NULL    
                                  ,@FAX_EMP                = NULL    
                                  ,@E_MAIL_EMP             = NULL    
                                  ,@CGC_EMP                = NULL    
                                  ,@DT_HABILIT_DOL         = NULL    
                                  ,@CATEGORIA              = NULL    
                                  ,@RE                     = @V_RE    
                                  ,@DT_ADMISSAO            = @V_DT_ADMISSAO    
                                  ,@DT_NASC                = @V_DT_NASC    
                                  ,@SEXO                   = @V_SEXO    
                                  ,@EST_CIVIL              = @V_EST_CIVIL    
                                  ,@DT_ULT_TITULO          = @V_DT_ULT_TITULO    
                                  ,@FECHAR_TURMA_INTERNET  = @V_FECHAR_TURMA_INTERNET    
                                  ,@PAIS_RES               = @V_PAIS_RES    
                                  ,@OBS_TEL_RES            = @V_OBS_TEL_RES    
                                  ,@OBS_TEL_COM            = @V_OBS_TEL_COM    
                                  ,@URL_PARTICULAR         = @V_URL_PARTICULAR    
                                  ,@URL_PROFISSIONAL       = @V_URL_PROFISSIONAL    
                                  ,@PISPASEP               = @V_PISPASEP    
                                  ,@PESSOA                 = @VC_PESSOA    
                                  ,@CONTRATO_TRABALHO      = @V_CONTRATO_TRABALHO    
                                  ,@REGIME_TRABALHO        = @V_REGIME_TRABALHO    
                                  ,@OUTRA_FACULDADE        = NULL    
                                  ,@PRIMEIRO_NOME          = NULL    
                                  ,@NOME_MEIO              = NULL    
                                  ,@SOBRENOME              = NULL    
                                  ,@COD_LATTES             = @V_COD_LATTES    
                                  ,@WINUSUARIO             = @V_WINUSUARIO    
                                  ,@DT_DEMISSAO            = @V_DT_DEMISSAO    
                                  ,@STAMP_ATUALIZACAO      = @V_STAMP_ATUALIZACAO    
                                  ,@MATRICULA              = @V_MATRICULA    
                                  ,@SENHA_ALTERADA         = @V_SENHA_ALTERADA    
                                  ,@ANO_INGRESSO           = NULL    
                                  ,@TIPO_INGRESSO          = NULL    
                                  ,@CONCURSO               = NULL    
                                  ,@CANDIDATO              = NULL    
                                  ,@CURSO_CONTRATO         = NULL    
                                  ,@TEMPO_EXP_PROFISSIONAL = NULL    
                                  ,@TEMPO_EXP_MAGISTERIO   = NULL    
                                  ,@TEMPO_EXP_EAD          = NULL    
                                  ,@TEMPO_EXP_GESTAO       = NULL    
                                  ,@TEMPO_EXP_EDU_BASICA   = NULL    
    
         END  -- 9*    
    
         -- INSERE DOCENTE NA LY_AUXILIAR CASO NÃO EXISTA    
         IF NOT EXISTS (SELECT TOP 1 1 FROM LY_AUXILIAR WHERE AUXILIAR = @V_NUM_FUNC)    
         BEGIN -- 11*    
            PRINT 'INSERIR DOCENTE NA LY_AUXILIAR'    
    
            SET @VC_LOCAL = 'LY_AUXILIAR'    
    
            INSERT INTO LY_AUXILIAR VALUES (convert(varchar,convert(numeric(10,0),@V_NUM_FUNC)), @VC_PESSOA)    
         END -- 11*    
    
         SET @VC_LOCAL = 'LY_DOCENTE_UNIDADE-INSERE'    
    
         IF NOT EXISTS (SELECT TOP 1 1    
                        FROM LY_OUTRAS_FACULDADES  F (nolock)    
                             JOIN LY_UNIDADE_ENSINO E (nolock)    
                               ON E.OUTRA_FACULDADE = F.OUTRA_FACULDADE    
                             JOIN LY_DEPTO D    
                               ON     D.FACULDADE = E.UNIDADE_ENS    
                                  AND D.DEPTO = 'GERAL'    
                        WHERE F.MANTENEDORA = @V_MANTENEDORA    
                          AND NOT EXISTS (SELECT TOP 1 1    
                                          FROM LY_DOCENTE_UNIDADE (nolock)    
                                          WHERE NUM_FUNC = @V_NUM_FUNC    
                                            AND FACULDADE = E.UNIDADE_ENS))    
         BEGIN -- 12*    
            SELECT @V_UNIDADE_ENSINO = E.UNIDADE_ENS    
            FROM LY_OUTRAS_FACULDADES  F (nolock)    
                 JOIN LY_UNIDADE_ENSINO E (nolock)    
                   ON E.OUTRA_FACULDADE = F.OUTRA_FACULDADE    
            WHERE F.MANTENEDORA = @V_MANTENEDORA    
              AND NOT EXISTS (SELECT TOP 1 1    
                              FROM LY_DOCENTE_UNIDADE (nolock)    
                              WHERE NUM_FUNC = @V_NUM_FUNC    
                                AND FACULDADE = E.UNIDADE_ENS)    
    
            PRINT 'ERRO - DEPARTAMENTO "GERAL" NÃO EXISTE PARA UNIDADE DE ENSINO: ' + @V_UNIDADE_ENSINO    
   END -- 12*    
    
         PRINT 'ADICIONA LOTAÇÃO DO DOCENTE - INSERÇÃO'    
    
         INSERT INTO LY_DOCENTE_UNIDADE (FACULDADE, DEPTO, NUM_FUNC, ATIVO, CLASSIFICACAO, CARGO, SINDICATO, CHEFE, FL_FIELD_01, FL_FIELD_02)    
         SELECT E.UNIDADE_ENS, 'GERAL', @V_NUM_FUNC, 'S', NULL, NULL, NULL, NULL, NULL, NULL    
         FROM LY_OUTRAS_FACULDADES  F (nolock)    
              JOIN LY_UNIDADE_ENSINO E (nolock)    
                ON E.OUTRA_FACULDADE = F.OUTRA_FACULDADE    
         WHERE F.MANTENEDORA = @V_MANTENEDORA    
           AND NOT EXISTS (SELECT TOP 1 1    
                           FROM LY_DOCENTE_UNIDADE (nolock)    
                           WHERE NUM_FUNC = @V_NUM_FUNC    
                             AND FACULDADE = E.UNIDADE_ENS)    
    
         PRINT 'MARCA COMO INTEGRADO NA TABELA RM.RH_LYC_DOCENTE - UPDATE'    
    
         --## MARCAR QUE REGISTRO FOI IMPORTADO    
         SET @TSQL2 = 'UPDATE R SET IMPORTADO = ''S'''    
                    + ' ,DT_IMPORTACAO_LYC = GETDATE() '    
                    + ' ,PESSOA = ISNULL(' + RTRIM(CONVERT(VARCHAR(10),@VC_PESSOA)) + ',(SELECT MAX(PESSOA) FROM LY_PESSOA WHERE CPF = ''' + @V_CPF + '''))'    
                    + ' FROM OPENQUERY(PRODUCAO,''select * from RM.RH_LYC_DOCENTE where IMPORTADO = ''''N'''' and CPF = ''''' + @V_CPF + ''''''') R'    
    
         EXEC(@TSQL2)    
    
         IF @@ROWCOUNT = 0    
         BEGIN    
            PRINT ('ERRO update rm.rh_lyc_docente - CPF: ' + ISNULL(@V_CPF,''))    
         END    
    
      END TRY    
      BEGIN CATCH    
         PRINT ('ERRO INTEGRACAO RH LYC - CPF: ' + ISNULL(@V_CPF,''))    
    
         -- CASO HOUVER ERRO NA ROTINA DE INTEGRAÇÃO, AS INFORMAÇÕES DO MESMO SERÃO INSERIDAS NA TABELA ERROS_INTEGRACAO_RH    
         INSERT INTO ERROS_INTEGRACAO_RH VALUES (@VC_LOCAL, @VC_PESSOA, @V_NOME_COMPL,@V_CPF, ERROR_MESSAGE(), GETDATE())    
      END CATCH    
    
      FETCH NEXT FROM CURSOR_RH_LYC INTO @V_HAB_TAC, @V_NOME_COMPL, @V_NOME_ABREV, @v_DT_NASC,    
                     @V_MUNICIPIO_NASC, @V_PAIS_NASC, @V_NACIONALIDADE, @V_NOME_PAI, @V_NOME_MAE, @V_SEXO,    
                     @V_EST_CIVIL, @V_END_CORRETO, @V_ENDERECO, @V_END_NUM, @V_END_COMPL, @V_BAIRRO,    
                     @V_END_MUNICIPIO, @V_END_PAIS, @V_CEP, @V_FONE, @V_PROFISSAO, @V_NOME_EMPRESA, @V_CARGO,    
                     @V_ENDCOM, @V_ENDCOM_NUM, @V_ENDCOM_COMPL, @V_ENDCOM_BAIRRO, @V_ENDCOM_PAIS,    
                     @V_ENDCOM_MUNICIPIO, @V_ENDCOM_CEP, @V_FONE_COM, @V_FAX, @V_RG_NUM, @V_RG_TIPO, @V_RG_EMISSOR,    
                     @V_RG_UF, @V_RG_DTEXP, @V_CPF, @V_ALIST_NUM, @V_ALIST_SERIE, @V_ALIST_RM, @V_ALIST_CSM,    
                     @V_ALIST_DTEXP, @V_CR_NUM, @V_CR_CAT, @V_CR_SERIE, @V_CR_RM, @V_CR_CSM, @V_CR_DTEXP, @V_TELEITOR_NUM,    
                     @V_TELEITOR_ZONA, @V_TELEITOR_SECAO, @V_TELEITOR_DTEXP, @V_CPROF_NUM, @V_CPROF_SERIE, @V_CPROF_UF,    
                     @V_CPROF_DTEXP, @V_E_MAIL, @V_MAILBOX, @V_HAB_TAC_DATA, @V_OBS, @V_SENHA_TAC, @V_DT_FALECIMENTO,    
                     @V_RESP_NOME_COMPL, @V_RESP_MUNICIPIO_NASC, @V_RESP_NACIONALIDADE, @V_RESP_SEXO, @V_RESP_EST_CIVIL,    
                     @V_RESP_ENDERECO, @V_RESP_END_NUM, @V_CELULAR, @V_FAX_RES, @V_E_MAIL_COM, @V_E_MAIL_INTERNO,    
                     @V_NOME_CONJUGE, @V_OBS_TEL_RES, @V_OBS_TEL_COM, @V_DIVIDA_BIBLIO, @V_TELEITOR_MUN, @V_AREA_PROF,    
                     @V_WINUSUARIO, @V_STAMP_ATUALIZACAO, @V_DDD_FONE, @V_DDD_FONE_COMERCIAL, @V_DDD_FONE_CELULAR,    
                     @V_DDD_FONE_RECADO, @V_DDD_RESP_FONE, @V_DEPTO, @V_ATIVO, @V_PERC_DEDIC_MENS, @V_TITULACAO,    
                     @V_ATUACAO_PROFIS, @V_SENHA_DOL, @V_DT_HABILIT_DOL, @V_CATEGORIA, @V_RE, @V_DT_ADMISSAO, @V_DT_ULT_TITULO,    
                     @V_PAIS_RES, @V_URL_PARTICULAR, @V_URL_PROFISSIONAL, @V_PISPASEP, @V_CONTRATO_TRABALHO, @V_COD_LATTES,    
                     @V_DT_DEMISSAO, @V_MATRICULA, @V_MANTENEDORA, @V_SITUACAO    
    
   END -- 2* (CURSOR)    
   
   CLOSE CURSOR_RH_LYC    
   DEALLOCATE CURSOR_RH_LYC    
    
   -- CASO HOUVER ERRO NA ROTINA DE INTEGRAÇÃO, SERÁ ENVIADO UM E-MAIL PARA EQUIPE DE TI DA INSTITUIÇÃO    
   IF EXISTS (SELECT 1 FROM ERROS_INTEGRACAO_RH)    
   BEGIN    
      --# PROC QUE ENVIA E-MAIL PARA OS USUARIOS CASO A INTEGRAÇÃO CAUSAR ALGUM ERRO #--    
      EXEC FTC_SP_SEND_MAIL_LOG 'INTEGRACAO_RH_LYC', 1    
   END    
    
END -- 1*    
    
GO