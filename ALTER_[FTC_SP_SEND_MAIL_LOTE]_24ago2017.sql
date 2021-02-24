USE LYCEUM
GO
  
ALTER PROCEDURE [dbo].[FTC_SP_SEND_MAIL_LOTE]   
(  
 @p_tipo_email varchar(100),  
 @p_chave1     varchar(100),  
 @p_chave2     varchar(100),  
 @p_chave3     varchar(100),  
 @p_chave4     varchar(100),  
 @p_chave5     varchar(100)  
    
)      
AS      
BEGIN  
  
--########################################################################################################################  
--## INICIO - Rotina comum para todos os casos  
  
--## Variaveis padrões  
DECLARE @V_DATA         T_DATA    --## data atual  
DECLARE @V_DATA_VARCHAR VARCHAR(20)         --## data atual varchar DD/MM/YYYY  
DECLARE @V_HTML         VARCHAR(MAX)  --## texto html  
declare @V_ASSUNTO      varchar(200)  --## Assunto e-mail  
declare @V_LINK   varchar(100)  --## LInk de acesso ao portal  
declare @v_email  varchar(100)  --## email do destinatario  
declare @v_nome_remetente varchar(50)  --## NOme Do remetente  
declare @v_email_remetente varchar(100)  --## E-mail Do remetente  
declare @id_gerado  int     --## Id gerado pelo identity  
declare @v_pessoa  T_NUMERO = null --## COdigo de pessoa  
Declare @V_NOME_DESTINATARIO varchar(100) --## nome do destinatario para padronizar codigo  
declare @v_concurso  varchar(20) = null --## para armazenar codigo concurso  
declare @v_resp   varchar(20) = null --## para armazenar codigo responsavel financeiro  
declare @v_nome_unidade_ensino varchar(100) = null --## para montar nome do rementente  
declare @v_email_unidade_ensino varchar(100) = null --## para montar nome do rementente  
DECLARE @v_usuario  t_codigo  
  
EXEC GetDataDiaSemHora @V_DATA OUTPUT      
SET @V_DATA_VARCHAR = CONVERT(VARCHAR,@V_DATA,103)  
  
SET @V_HTML = ''      
  
--# Variaveis -- CandidatoIngressoOnLine  
Declare @v_descricao_PS  varchar(100),  
  @v_candidato  varchar(20) = null,  
  @v_senha_candidato varchar(100)  
  
--# Variaveis -- AlunoIngresso  
Declare @v_aluno  varchar(20) = null,  
  @v_senha_aluno varchar(100),  
  @v_curso  varchar(100)  
  
--# Variaveis -- AlunoIngresso  
Declare @v_disciplina_nome varchar(100),  
        @v_turmas_vagas_horario  varchar(MAX)  
  
--## FIM - Rotina comum para todos os casos  
--########################################################################################################################  
  
--## 0001 - RAUL  
--## CandidatoIngressoOnLine  
If @p_tipo_email = 'CandidatoIngressoOnLine'  
 Begin  
  
  --# Consulta dos dados para montar html  
  Select   
    @v_nome_destinatario = cand.nome_compl,  
    @v_descricao_PS   = c.DESCRICAO,  
    @v_link     = isnull(ti.descr,'http://www.ftc.edu.br'),  
    @v_candidato   = cand.candidato,  
    @v_senha_candidato  = ISNULL(cand.SENHA_WEB,''),  
    @v_email    = cand.E_MAIL,  
    @v_pessoa    = cand.pessoa,  
    @v_concurso    = cand.concurso,  
    @v_nome_unidade_ensino = DBO.FN_RetornaRemetenteNome(cur.faculdade),   --## 17/01/2017 - alterei para função,  
    @v_email_unidade_ensino = DBO.FN_RetornaRemetenteEmail(cur.faculdade)  --## 17/01/2017 - alterei para função  
  from ly_concurso c  
  join LY_CANDIDATO cand  
   on c.CONCURSO = cand.CONCURSO  
  join LY_OPCOES_PROC_SELETIVO op  
   on op.CONCURSO  = cand.CONCURSO  
   and op.CANDIDATO = cand.CANDIDATO  
  join LY_OFERTA_CURSO oc  
   on OC.OFERTA_DE_CURSO=OP.OFERTA_DE_CURSO  
  join ly_curso cur  
   on oc.curso = cur.curso  
  left join (select item, descr from HD_TABELAITEM where TABELA = 'LinkIngressoLycFTC') ti  
   on cur.faculdade = ti.ITEM   
  where cand.concurso = @p_chave1  
  and cand.CANDIDATO = @p_chave2  
  and cand.SENHA_WEB is not null       -- tem que ter senha  
  and exists (select top 1 1 from LY_CONVOCADOS_VEST  -- tem que esta convocado  
     where CONCURSO = cand.CONCURSO  
     and CANDIDATO = cand.CANDIDATO  
     and MATRICULADO = 'N')  
  
  --# Definição dos dados do e-mail  
  set @v_nome_remetente = @v_nome_unidade_ensino  
  set @v_email_remetente = @v_email_unidade_ensino  
  set @V_ASSUNTO   = 'Processo Seletivo ' + @v_nome_unidade_ensino  
  
               
  -- MONTA HTML      
  SELECT @V_HTML = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">      
       <html>      
       <head>      
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>      
        <meta content="MSHTML 6.00.2900.2873" name="GENERATOR"/>      
       </head>      
       <body>      
        <p>Prezado(a) Candidato(a) ' + @v_nome_destinatario + '</p>  
        <p>Informamos que voc&ecirc; foi APROVADO(A) no ' + @v_descricao_PS + '</p>  
        <p>Para garantir a sua vaga, voc&ecirc; pode realizar sua pr&eacute;-matr&iacute;cula on-line acessando o endere&ccedil;o e acesso abaixo:</p>  
        <p>Endere&ccedil;o: <a href="'+ @v_link + '">'+ @v_link + '</a></p>  
        <p>Login: ' + @v_email +'</p>  
        <p>Senha: ' + @v_senha_candidato + '</p>  
        <p><br>Lembramos que a sua matr&iacute;cula s&oacute; estar&aacute; conclu&iacute;da ap&oacute;s pagamento e entrega da documenta&ccedil;&atilde;o necess&aacute;ria.</p>  
        <p>&nbsp;</p>  
        <p>Desde j&aacute;, seja bem-vindo!</p>  
        <p>Se tiver alguma d&uacute;vida, pode entrar em contato pelos telefones:<br>Salvador - 71 3254-6666<br>Demais Localidades - 0800 056 6666</p>  
        <p>E-Mail enviado em ' + @V_DATA_VARCHAR +   
       '</body>      
       </html>'       
  
 End  
  
  
--## 0002 - RAUL  
--## AlunoIngresso  
If @p_tipo_email = 'AlunoIngresso'  
 Begin  
  
  --# Consulta dos dados para montar html  
  Select   
    @v_nome_destinatario = alu.nome_compl,  
    @v_link     = DBO.FN_RetornaLinkAlunoOnLine(c.FACULDADE),  --## 17/01/2017 - alterei para função  
    @v_nome_remetente  = DBO.FN_RetornaRemetenteNome(c.FACULDADE),   --## 11/01/2017 - alterei para função  
    @v_email_remetente  = DBO.FN_RetornaRemetenteEmail(c.FACULDADE),  --## 11/01/2017 - alterei para função  
    @v_aluno    = alu.aluno,  
    @v_senha_aluno   = ISNULL(dbo.decrypt(p.senha_tac),''),  
    @v_curso    = c.NOME,  
    @v_email    = p.E_MAIL,  
    @v_pessoa    = p.pessoa  
  from ly_aluno alu  
  join LY_pessoa p  
   on alu.pessoa = p.pessoa  
  join ly_curso c  
   on alu.CURSO = c.curso  
  where alu.aluno  = @p_chave1   -- a chave é o aluno  
  and SIT_ALUNO  = 'Ativo'   -- Tem que ser aluno ativo  
  and p.SENHA_TAC  is not null   -- tem que ter senha  
  
  --# Definição dos dados do e-mail  
  set @V_ASSUNTO = 'Aluno Ingresso - ' + @v_nome_remetente  
          
  -- MONTA HTML      
  SELECT @V_HTML = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">      
       <html>      
       <head>      
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>      
        <meta content="MSHTML 6.00.2900.2873" name="GENERATOR"/>      
       </head>      
       <body>      
        <p>Prezado(a) Aluno(a) ' + @v_nome_destinatario + '</p>  
        <p>Seu ingresso foi realizado com sucesso!<br>  
        <p>Os preparativos da pr&eacute;-matr&iacute;cula est&atilde;o sendo executados!<br><br>  
        Lembramos que o pr&oacute;ximo passo para garantir a sua vaga &eacute; realizar o pagamento referente &agrave; primeira mensalidade.</p><br>  
        <p>Ele est&aacute; dispon&iacute;vel no Portal do Aluno, que voc&ecirc; pode acessar no endere&ccedil;o abaixo, com login e senha informados.</p>  
        <p>Endere&ccedil;o: <a href="'+ @v_link + '">'+ @v_link + '</a></p>  
        <p>Usu&aacute;rio: ' + @v_aluno +'</p>  
        <p>Senha: ' + @v_senha_aluno + '</p>  
        <p><br>Lembramos que a sua matr&iacute;cula s&oacute; estar&aacute; conclu&iacute;da ap&oacute;s pagamento e entrega da documenta&ccedil;&atilde;o necess&aacute;ria.</p>  
        <p>&nbsp;</p>  
        <p>Desde j&aacute;, seja bem-vindo!</p>  
        <p>Se tiver alguma d&uacute;vida, pode entrar em contato pelos telefones:<br>Salvador - 71 3254-6666<br>Demais Localidades - 0800 056 6666</p>  
        <p>E-Mail enviado em ' + @V_DATA_VARCHAR +   
       '</body>      
       </html>'      
  
   
 End  
  
--## 0003 - DOUGLAS  
--## Disciplina_Turma_Vagas_Horario  
If @p_tipo_email = 'DisciplinaTurmaVagasHorario'  
 Begin  
  
  --# Consulta dos dados para montar html  
  Select   
    @v_nome_destinatario = alu.nome_compl,  
    @v_nome_remetente  = DBO.FN_RetornaRemetenteNome(c.FACULDADE),  --## 11/01/2017 - alterei para função  
    @v_email_remetente  = DBO.FN_RetornaRemetenteEmail(c.FACULDADE), --## 11/01/2017 - alterei para função  
    @v_aluno    = alu.aluno,  
    @v_email    = p.E_MAIL,  
    @v_pessoa    = p.pessoa  
  from ly_aluno alu  
  join LY_pessoa p  
   on alu.pessoa = p.pessoa  
  join ly_curso c  
   on alu.CURSO = c.curso  
  where alu.aluno  = @p_chave1   -- a chave é o aluno  
  and SIT_ALUNO  = 'Ativo'   -- Tem que ser aluno ativo  
  and p.SENHA_TAC  is not null   -- tem que ter senha  
  
  --# Definição dos dados do e-mail  
  set @V_ASSUNTO = 'Lista de Espera - Disciplina: ' + @p_chave2 + ' Solicitação: ' + CONVERT(VARCHAR,@p_chave5)  
  
        declare   
          @v_vagas VARCHAR(20),  
          @v_turma VARCHAR(20),   
          @v_ult_turma VARCHAR(20),  
          @v_turno VARCHAR(100),   
          @v_horario VARCHAR(50)  
  
       SET @v_turmas_vagas_horario = ''  
       SET @v_ult_turma = ''  
  
        declare C_CURSOR_DISC_TURMA cursor for   
  
        select  
          CONVERT(VARCHAR,VAGAS)  
        , TURMA  
        , T.DESCRICAO  
        , '<p> ' +   
          CASE   
            WHEN DIA_SEMANA = 2 THEN 'Seg'  
            WHEN DIA_SEMANA = 3 THEN 'Ter'  
            WHEN DIA_SEMANA = 4 THEN 'Qua'  
            WHEN DIA_SEMANA = 5 THEN 'Qui'  
            WHEN DIA_SEMANA = 6 THEN 'Sex'  
            WHEN DIA_SEMANA = 7 THEN 'Sab'  
            ELSE 'Dom'  
          END  
          + ' das ' + LEFT(CONVERT(VARCHAR,HORAINI_AULA,114),5) + ' às ' + LEFT(CONVERT(VARCHAR,HORAFIM_AULA,114),5) + ' </p>'  
        from FTC_VW_TURMA_HORARIO_VAGAS A  
        JOIN LY_TURNO T ON (A.TURNO = T.TURNO)  
        WHERE VAGAS > 0  
        AND DISCIPLINA = @p_chave2  
        AND ANO = @p_chave3  
        AND SEMESTRE = @p_chave4  
        ORDER BY TURMA  
  
        open C_CURSOR_DISC_TURMA  
        fetch next from C_CURSOR_DISC_TURMA into @v_vagas, @v_turma, @v_turno, @v_horario  
        while(@@FETCH_STATUS = 0)  
        begin  
  
          IF @v_ult_turma <> @v_turma  
            SET @v_turmas_vagas_horario = @v_turmas_vagas_horario + CHAR(13) + '<p> Turma: ' + @v_turma + ' Número de Vagas: ' + @v_vagas + ' Turno: ' + @v_turno + ' </p>'  
            
          IF @v_horario IS NOT NULL  
            SET @v_turmas_vagas_horario = @v_turmas_vagas_horario + CHAR(13) + @v_horario   
  
          SET @v_ult_turma = @v_turma  
  
          fetch next from C_CURSOR_DISC_TURMA into @v_vagas, @v_turma, @v_turno, @v_horario  
  
        end  
        close C_CURSOR_DISC_TURMA  
        deallocate C_CURSOR_DISC_TURMA   
  
        SELECT @v_disciplina_nome = NOME  
        FROM LY_DISCIPLINA  
        WHERE DISCIPLINA = @p_chave2  
         
  -- MONTA HTML      
  SELECT @V_HTML = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">      
       <html>      
       <head>      
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>      
        <meta content="MSHTML 6.00.2900.2873" name="GENERATOR"/>      
       </head>      
       <body>      
        <p>Prezado(a) Aluno(a) ' + @v_nome_destinatario + '</p>  
        <p>A disciplina ' + @p_chave2 + ' - ' + @v_disciplina_nome + ' que você está em lista de espera através da solicitação ' + CONVERT(VARCHAR,@p_chave5) + ' possui vagas nas turmas abaixo relacionadas: !<br>  
        <p> ' + @v_turmas_vagas_horario + ' </p>  
        <p>O preenchimento dessas vagas ocorrerá por ordem de chegada, portanto, faça já a sua matrícula.</p>  
        <p>Se tiver alguma d&uacute;vida, pode entrar em contato pelos telefones:<br>Salvador - 71 3254-6666<br>Demais Localidades - 0800 056 6666</p>  
        <p>E-Mail enviado em ' + @V_DATA_VARCHAR +   
       '</body>      
       </html>'      
  
 End  
  
--## 0004 - EDILLAN - inicio  
--## CRIAÇÃO DE CURSO  
If @p_tipo_email = 'CursoCadastrado'  
 Begin  
  
  --# Consulta dos dados para montar html  
  Select   
    @v_nome_destinatario = 'Contabilidade',  
    @v_email_remetente  = DBO.FN_RetornaRemetenteEmail(c.FACULDADE), --## 11/01/2017 - alterei para função  
    @v_email    = 'contabilidade@ftc.edu.br'  
  FROM LY_CURSO C  
  WHERE CURSO  = @P_CHAVE1  
    
  SELECT  @v_nome_remetente  = usuario + ' - ' + NOMEUSUARIO  
  FROM USUARIO  
  WHERE USUARIO = @v_usuario  
  
  --# Definição dos dados do e-mail  
  set @V_ASSUNTO = 'Cadastro de Curso: ' + @p_chave1 + ' Nome: ' + CONVERT(VARCHAR,@p_chave2)  
  
  -- MONTA HTML      
  SELECT @V_HTML = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">      
       <html>      
       <head>      
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>      
        <meta content="MSHTML 6.00.2900.2873" name="GENERATOR"/>      
       </head>      
       <body>      
        <p>Prezado(a) ' + @v_nome_destinatario + '</p>  
        <p>Foi realizado o cadastro do curso ' + @p_chave1 + ' - ' + @p_chave2 + ' !<br>  
		<p>O tipo do curso é:  ' + @p_chave3 + ' e o código da Unidade de Ensino associado ao curso é: ' + @p_chave4 + '.<br>  
        <p>Necessário criar/associar Centro de Custo para o mesmo.</p>  
        <p></p>  
        <p>E-Mail enviado em ' + @V_DATA_VARCHAR +   
       '</body>      
       </html>'      
  
  --## Em 24/08/2017 foram acrescentadas informações de Unidade de Ensino associada e Tipo do Curso criado mediante solicitação de Grégorio (chamado 1493) ##--
  
 End  
--## 0004 - EDILLAN - fim  
  
  
--## 0005 - EDILLAN - inicio  
--## CRIAÇÃO DE CÓDIGO LANC  
If @p_tipo_email = 'CodigoLancCadastrado'  
 Begin  
    
  SELECT  @v_usuario =   usuario  
  FROM zzCRO_Vars  
  WHERE spid = @@SPID  
  
  
  --# Consulta dos dados para montar html  
  Select   
    @v_nome_destinatario = 'Contabilidade',  
    @v_nome_remetente  = usuario + ' - ' + NOMEUSUARIO,  --## 11/01/2017 - alterei para função  
    @v_email_remetente  = 'suportelyceum@ftc.edu.br', --## 11/01/2017 - alterei para função  
    @v_email    = 'contabilidade@ftc.edu.br'  
  FROM USUARIO  
  WHERE USUARIO = @v_usuario  
  
  --# Definição dos dados do e-mail  
  set @V_ASSUNTO = 'Cadastro de Código de Lançamento: ' + @p_chave1 + ' Descrição: ' + CONVERT(VARCHAR,@p_chave2)  
  
  -- MONTA HTML      
  SELECT @V_HTML = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">      
       <html>      
       <head>      
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>      
        <meta content="MSHTML 6.00.2900.2873" name="GENERATOR"/>      
       </head>      
       <body>      
        <p>Prezado(a) ' + @v_nome_destinatario + '</p>  
        <p>Foi realizado o cadastro do Código de Lançamento ' + @p_chave1 + ' - ' + @p_chave2 + ' !<br>  
        <p>Necessário verificar o cadastro e a necessidade de parametrização de roteiros/integrações.</p>  
        <p> Usuário responsável pelo cadastro: ' + @v_nome_remetente + ' </p>  
        <p>E-Mail enviado em ' + @V_DATA_VARCHAR +   
       '</body>      
       </html>'      
  
 End  
--## 0005 - EDILLAN - fim  
  
  
  
  
--## 0006 - RAUL - inicio  
--## ErroInsercaoAlunoPergamum  
If @p_tipo_email = 'ErroInsercaoAlunoPergamum'  
 Begin  
    
  --# Consulta dos dados para montar html  
  Select   
    @v_nome_destinatario = 'Suporte Lyceum FTC',  
    @v_nome_remetente  = 'Integração Pergamum - Aluno',    
    @v_email_remetente  = 'suportelyceum@ftc.edu.br',   
    @v_email    = 'suportelyceum@ftc.edu.br'  
  
  --# Definição dos dados do e-mail  
  set @V_ASSUNTO = 'Erro na inserção na integração do Pergamum - Aluno: ' + isnull(@p_chave1,'')  
  
  -- MONTA HTML      
  SELECT @V_HTML = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">      
       <html>      
       <head>      
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>      
        <meta content="MSHTML 6.00.2900.2873" name="GENERATOR"/>      
       </head>      
       <body>      
        <p>Suporte Lyceum(a), </p>  
        <p>Ocorreu um erro na inserção do aluno: ' + @p_chave1 + ' na integração do Pergamum.<br>  
        <p>Necessário verificar o cadastro e fazer a correção dos dados.</p>  
        <p>E-Mail enviado em ' + @V_DATA_VARCHAR +   
       '</body>      
       </html>'      
  
 End  
--## 0006 - RAUL- Fim  
  
  
--## 0007 - RAUL - inicio  
--## IntegracaoMultaPergamum  
If @p_tipo_email = 'IntegracaoMultaPergamum'  
 Begin  
    
  --# Consulta dos dados para montar html  
  Select   
    @v_nome_destinatario = 'Suporte Lyceum FTC',  
    @v_nome_remetente  = 'Integração Multa Pergamum - Aluno',    
    @v_email_remetente  = 'suportelyceum@ftc.edu.br',   
    @v_email    = 'suportelyceum@ftc.edu.br'  
  
  --# Definição dos dados do e-mail  
  set @V_ASSUNTO = 'Erro na geração da multa do Pergamum - Aluno: ' + isnull(@p_chave1,'')  
  
  -- MONTA HTML      
  SELECT @V_HTML = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">      
       <html>      
       <head>      
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>      
        <meta content="MSHTML 6.00.2900.2873" name="GENERATOR"/>      
       </head>      
       <body>      
        <p>Suporte Lyceum(a), </p>  
        <p>Ocorreu um erro na geração da multa do aluno: ' + @p_chave1 + ' na integração do Pergamum.<br>  
        <p>Necessário verificar o cadastro e fazer a correção dos dados.</p><br>' + @p_chave2 + '  
        <p>E-Mail enviado em ' + @V_DATA_VARCHAR +   
       '</body>      
       </html>'      
  
 End  
--## 0007 - RAUL- Fim  
  
  
  
--########################################################################################################################  
--## INICIO - Rotina de Inserir informações de emails na tabela de emails lote  
  
 --## se email for null, aborta operação  
 IF @V_EMAIL IS NULL or @V_HTML is null  
  Return  
  
 --## 09/02/2017 - Ajusta caracteres especiais do HTML  
 SET @V_HTML = DBO.FN_ConverteHTML(@V_HTML)  
  
 --# Insert na ly_email_lote   
 insert into ly_email_lote (USUARIO, ASSUNTO, MENSAGEM, DATA, NOME_REMETENTE, EMAIL_REMETENTE, EMAILS_CCO)   
 select 'Automação',@V_ASSUNTO, @v_html, getdate(), @v_nome_remetente, @v_email_remetente, null   
   
 set @id_gerado = @@identity    
   
 insert into ly_email_lote_dest (ID_EMAIL_LOTE, PESSOA, ALUNO, NUM_FUNC, SIT_EMAIL_LOTE, NUMERO_TENTATIVAS, DATA_ULTIMA_TENTATIVA, MENSAGEM_ERRO, EMAIL_DESTINATARIO,   
    NOME_DESTINATARIO, FL_FIELD_01, FL_FIELD_02, FL_FIELD_03, FL_FIELD_04, FL_FIELD_05, CONCURSO, CANDIDATO, RESP)   
 select @id_gerado, @v_pessoa, @v_aluno, null, 'Aguardando Envio',0,NULL, NULL, @V_EMAIL, @v_nome_destinatario, NULL,NULL,NULL,NULL,NULL,@v_concurso, @v_candidato,@v_resp  
  
  
--## FIM - Rotina de Inserir informações de emails na tabela de emails lote  
--########################################################################################################################                            
    
END   
GO

delete from LY_CUSTOM_CLIENTE  
where nome = 'FTC_SP_SEND_MAIL_LOTE'  
and IDENTIFICACAO_CODIGO = '0008'  

INSERT INTO LY_CUSTOM_CLIENTE
(NOME, IDENTIFICACAO_CODIGO, AUTOR, DATA_CRIACAO, OBJETIVO, SOLICITADO_POR, ATIVO, TIPOCOMPONENTE, TIPO, CLIENTE)
SELECT
  'FTC_SP_SEND_MAIL_LOTE' NOME
, '0008' IDENTIFICAO_CODIGO
, 'Miguel' AUTOR
, '2017-08-24' DATA_CRIACAO
, 'Ajustar EP - Trazer informação de Tipo de Curso e Unidade associada ao curso' OBJETIVO
, 'Gregório Cerqueira, Rosemeire Amorim' SOLICITADO_POR
, 'S' ATIVO
, 'PROCEDURE' TIPOCOMPONENTE
, 'CLIENTE' TIPO
, 'FTC' CLIENTE
GO  