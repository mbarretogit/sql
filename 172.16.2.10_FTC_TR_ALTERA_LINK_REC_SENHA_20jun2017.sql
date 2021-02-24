USE LYCEUM
GO

  
ALTER TRIGGER FTC_TR_ALTERA_LINK_REC_SENHA   
ON LY_EMAIL_LOTE_DEST  
FOR INSERT  
AS  
BEGIN  
 --## Declaração variaveis globais  
 DECLARE @V_ID_EMAIL_LOTE   INT  
 DECLARE @V_PESSOA     INT  
 DECLARE @V_USUARIO    VARCHAR(255)  
 DECLARE @V_EMAIL_REMETENTE_ORIG VARCHAR(100)  
 --## Declaração de variaveis recuperação senha  
 DECLARE @v_email_remetente VARCHAR(100)  
 DECLARE @v_nome_remetente VARCHAR(50)  
 DECLARE @v_link_faculdade VARCHAR(200)  
  
  -- Consulta pessoa e ID do lote  
  SELECT   
     @V_ID_EMAIL_LOTE = ID_EMAIL_LOTE  
   , @V_PESSOA   = PESSOA  
  FROM inserted  
  
  -- Consulta os dados do email: usuario e email remetente  
  SELECT TOP 1  
     @V_USUARIO     = USUARIO    -- usado para saber qual usuario e como filtro nos tratamentos de recuperação de senha  
  ,  @V_EMAIL_REMETENTE_ORIG = EMAIL_REMETENTE  -- usando para saber se o email é de recuperação senha docente   
  FROM LY_EMAIL_LOTE  
  WHERE ID_EMAIL_LOTE = @V_ID_EMAIL_LOTE  
  
  
  -- Verificar se o email é de reset de senha docente   
 IF @V_USUARIO = 'ServicoRecSenha'         --## Verifica se a origem do email é o reset de senha que esta definido como usuario: ServicoRecSenha  
 and @V_EMAIL_REMETENTE_ORIG = 'naoresponda-docente@ftc.edu.br'  --## Pelo email FAKE naoresponda-docente@ftc.edu.br sei que é alteração de docente  
  Begin  
   
   --## Verificar de qual unidade o docente faz parte  
   -- Estou ordenando pelo campo unidade fisica para definir a prioridade do top 1  
   -- Pego as unidades vinculadas ao docente, com a unidade vou nas unidades associadas, com esta pego a unidade fisica e vou na unidade fisica e la tem o flex05   
   select  top 1   
    @v_nome_remetente = uf.FL_FIELD_02,  
    @v_email_remetente = uf.FL_FIELD_03,  
    @v_link_faculdade = uf.FL_FIELD_05  
   from ly_docente d  
   join LY_DOCENTE_UNIDADE du  
    on d.NUM_FUNC = du.NUM_FUNC  
   join LY_UNIDADES_ASSOCIADAS ua  
    on ua.UNIDADE_ENS = du.FACULDADE  
   join LY_UNIDADE_FISICA uf  
    on ua.UNIDADE_FIS = uf.UNIDADE_FIS  
   where d.PESSOA  = @V_PESSOA  
   and du.ATIVO  = 'S'      -- Só verifica as unidades ativas do docente  
   order by du.FACULDADE  
  
   --## Atualiza dados na tabela  
   UPDATE EL   
   SET   MENSAGEM   = REPLACE(MENSAGEM,'docente.ftc.edu.br',('http://'+@v_link_faculdade))   
    , EMAIL_REMETENTE = @v_email_remetente  
    , NOME_REMETENTE = @v_nome_remetente  
   from LY_EMAIL_LOTE EL  
   WHERE ID_EMAIL_LOTE = @V_ID_EMAIL_LOTE  
   AND MENSAGEM LIKE '%docente.ftc.edu.br%'  
  
  End  
 else   
  -- Verificar se o emails é de reset de senha  
  IF @V_USUARIO = 'ServicoRecSenha'          --## Verifica se a origem do email é o reset de senha que esta definido como usuario: ServicoRecSenha  
  AND EXISTS(SELECT TOP 1 1 FROM LY_ALUNO WHERE PESSOA = @V_PESSOA)  --## Verifica se existe alguma aluno com a pessoa vinculada  
   BEGIN  
  
    --## Verificar de qual unidade o aluno faz parte  
    -- Estou ordenando pelo campo unidade fisica para definir a prioridade do top 1  
    -- Ex: se o aluno for da faculdade e do curso de ingles vai apresentar o link da faculdade.  
    select  top 1   
    @v_nome_remetente = uf.FL_FIELD_02,  
    @v_email_remetente = uf.FL_FIELD_03,  
    @v_link_faculdade = uf.FL_FIELD_04  
    from ly_aluno a  
    join LY_UNIDADE_FISICA uf  
    on a.UNIDADE_FISICA = uf.UNIDADE_FIS  
    where a.PESSOA  = @V_PESSOA  
    and a.sit_aluno  = 'Ativo'  
    order by a.UNIDADE_FISICA  
  
    --## Atualiza dados na tabela  
    UPDATE EL   
    SET   MENSAGEM   = REPLACE(MENSAGEM,'aluno.ftc.edu.br',('http://'+@v_link_faculdade))   
    , EMAIL_REMETENTE = @v_email_remetente  
    , NOME_REMETENTE = @v_nome_remetente  
    from LY_EMAIL_LOTE EL  
    WHERE ID_EMAIL_LOTE = @V_ID_EMAIL_LOTE  
    AND MENSAGEM LIKE '%aluno.ftc.edu.br%'  
  
   END  
END  