  
    
USE LYCEUM      
GO    
                    
ALTER PROCEDURE dbo.AY_GERA_CAR_APROP                    
  @P_DATA_LIMITE  DATETIME = NULL,                    
  @P_CONTINUA_COM_ERRO T_SIMNAO = 'N',                    
  @P_MSG_ERRO   VARCHAR(300) OUTPUT                    
AS                    
BEGIN                    
                    
 -- Variaveis auxiliares                    
 DECLARE @S T_ALFA_HUGE                    
 DECLARE @GEROU_CAR_APROP T_SIMNAO                       
                    
 DECLARE @QTD_ATUALIZADOS INT                     
 DECLARE @QTD_NAO_ATUALIZADOS INT                      
 DECLARE @QTD_REMOVIDOS INT                      
 DECLARE @DATA_INI DATETIME                    
 DECLARE @DATA_FIM DATETIME                    
 DECLARE @CALC_VALOR_TOTAL_INSERIDO T_DECIMAL_MEDIO                    
                    
 -- Variaveis usadas para pegar um item da movimento temporal                    
 DECLARE @id_mov_temporal T_NUMERO_GRANDE                    
 DECLARE @entidade VARCHAR(50)                    
 DECLARE @id1 VARCHAR(50)                    
 DECLARE @id2 VARCHAR(50)                    
                     
 -- Cursor para pegar os itens que ainda nao foram processados                    
 DECLARE C_BUSCA_ITENS_EM_ORDEM CURSOR FAST_FORWARD FOR                    
  SELECT ID_MOVIMENTO_TEMPORAL, ENTIDADE, ID1, ID2                    
  FROM LY_MOVIMENTO_TEMPORAL                    
  WHERE DT_CAR_APROP IS NULL                    
  AND ENTIDADE IN ('Ly_Item_Lanc', 'Ly_Item_Cred')                    
  AND (@P_DATA_LIMITE IS NULL OR DATA <= @P_DATA_LIMITE)  -- LIMITADO PARA PEGAR DE 2019 A DATA AUTAL - IGOR CAMPOS             
  --AND (@P_DATA_LIMITE IS NULL OR DATA BETWEEN '2018-01-01' AND @P_DATA_LIMITE )             
            
  ORDER BY DATA, ID_MOVIMENTO_TEMPORAL                    
                    
 -- Variaveis usadas para gera LY_CAR ou LY_APROP_QUITACAO (entidades Ly_Item_Lanc)                    
 DECLARE @ITL_CODIGO_LANC T_CODIGO                    
 DECLARE @ITL_CENTRO_DE_CUSTO T_ALFAMEDIUM                    
 DECLARE @ITL_NATUREZA T_ALFAMEDIUM                    
 DECLARE @ITL_ORIGEM VARCHAR(40)                     
 DECLARE @ITL_VALOR T_DECIMAL_MEDIO                    
 DECLARE @CDL_PRIORIDADE T_NUMERO_PEQUENO                    
 DECLARE @CALC_TIPO_CAR VARCHAR(1)                    
                      
 -- Variaveis usadas para gerar LY_EAR ou LY_APROP_CRED (entidades Ly_Item_Cred)                    
 DECLARE @ITC_TIPO_ENCARGO T_CODIGO                    
 DECLARE @ITC_TIPODESCONTO T_CODIGO                    
 DECLARE @ITC_COBRANCA T_NUMERO                    
 DECLARE @ITC_VALOR T_DECIMAL_MEDIO                     
 DECLARE @TPE_PRIORIDADE T_NUMERO_PEQUENO                    
 DECLARE @CALC_ID_CAR T_NUMERO                    
 DECLARE @CALC_VALOR_APROPRIAR T_DECIMAL_MEDIO                    
 DECLARE @CALC_TIPO_ENCARGO T_CODIGO                    
 DECLARE @CALC_PAGTO_A_MAIOR VARCHAR(1)                    
                    
                    
 -- guarda a data no comeco da procedure                    
 SELECT @DATA_INI = GETDATE()                      
 SET @QTD_ATUALIZADOS = 0                    
 SET @QTD_NAO_ATUALIZADOS = 0                    
 SET @QTD_REMOVIDOS = 0                    
                     
 -- Abrindo o cursor                    
 OPEN C_BUSCA_ITENS_EM_ORDEM                    
 FETCH NEXT FROM C_BUSCA_ITENS_EM_ORDEM INTO @id_mov_temporal, @entidade, @id1, @id2                    
                    
 -- Para cada item do cursor...                    
 WHILE (@@FETCH_STATUS = 0)                        
 BEGIN                     
                    
  -- Inicia a transacao para esse item                    
  BEGIN TRANSACTION PROCESSA_ITEM_CAR_APROP                    
                      
  -- Tenta fazer a apropriacao (e captura qualquer tipo de erro)                    
  BEGIN TRY                      
                     
   -- Inicia a variavel de controle (nao gerou nada ainda)       
   SELECT @GEROU_CAR_APROP = 'N'                    
                       
   -- ------------------------------------------------------------------------------------                    
   -- Se a entidade for Ly_Item_Lanc, vai gerar LY_CAR ou LY_APROP_QUITACAO                    
   -- ------------------------------------------------------------------------------------                    
                    
   IF @entidade = 'Ly_Item_Lanc'                    
   BEGIN                    
                    
    -- Limpa as variaveis                    
    SELECT @ITL_CODIGO_LANC = NULL,                    
        @ITL_CENTRO_DE_CUSTO = NULL,                    
        @ITL_NATUREZA = NULL,                    
        @ITL_ORIGEM = NULL,                    
        @CALC_TIPO_CAR = NULL,                    
        @CDL_PRIORIDADE = NULL                    
                    
    -- Busca as informacoes necessarias para gerar o CAR ou APROP_QUITACAO para esse item                    
    SELECT @ITL_CODIGO_LANC = ITL.CODIGO_LANC,                    
        @ITL_VALOR = ITL.VALOR,                    
        @ITL_CENTRO_DE_CUSTO = ITL.CENTRO_DE_CUSTO,                    
        @ITL_NATUREZA = ITL.NATUREZA,                    
        @ITL_ORIGEM = ITL.ORIGEM,                    
        @CALC_TIPO_CAR = CASE                    
           WHEN (COB.NUM_COBRANCA = 1 AND ISS.SERVICO IS NOT NULL) THEN '2'                    
           ELSE CONVERT(VARCHAR(1), COB.NUM_COBRANCA)                    
          END,                    
        @CDL_PRIORIDADE = CDL.PRIORIDADE                    
    FROM LY_ITEM_LANC ITL WITH (NOLOCK)                    
     JOIN LY_COBRANCA COB WITH (NOLOCK) ON (ITL.COBRANCA = COB.COBRANCA)                    
     JOIN LY_COD_LANC CDL WITH (NOLOCK) ON (ITL.CODIGO_LANC = CDL.CODIGO_LANC)                    
     LEFT JOIN LY_ITENS_SOLICIT_SERV ISS WITH (NOLOCK) ON (ISS.LANC_DEB = ITL.LANC_DEB)                    
    WHERE                     
    ITL.COBRANCA = @id1                     
    AND ITL.ITEMCOBRANCA = @id2                    
                        
                    
    -- Se nao consegui buscar os dados do item                    
    IF @@ROWCOUNT = 0                    
    BEGIN                    
     -- Registra no log que o item nao existe mais no banco                    
     EXEC spProcLog @CHAVE1 = 'Ly_Item_Lanc',                     
               @CHAVE2 = @id1,                    
               @CHAVE3 = @id2,                    
               @MSG = '      [Inconsistencia] Registro da LY_ITEM_LANC que nao existe mais. Item removido da LY_MOVIMENTO_TEMPORAL'                         
                         
     -- Remove o item da movimento temporal                    
     DELETE FROM LY_MOVIMENTO_TEMPORAL WHERE ID_MOVIMENTO_TEMPORAL = @id_mov_temporal                    
                         
     -- Aumenta o contador de removidos                    
     SET @QTD_REMOVIDOS = @QTD_REMOVIDOS + 1                         
    END                    
    -- Se conseguiu buscar os dados do item                    
    ELSE                    
    BEGIN                    
                        
     -- --------------------------------------------------------------------                       
     -- Se for uma QUITACAO na LY_ITEM_LANC, vai gerar LY_APROP_QUITACAO...                    
     -- --------------------------------------------------------------------                    
     IF (@ITL_CODIGO_LANC = 'Acerto' AND @ITL_ORIGEM IN ('ACORDO', 'CHEQUE FINANCIAMENTO', 'RESTITUICAO RECEBE', 'ARRASTO TRANSFERE'))                    
     BEGIN                    
                    
      -- Cursor para ratear a quitacao                    
      DECLARE C_RATEIO_QUITACAO CURSOR FOR                    
       SELECT VALOR_APROPRIAR, ID_CAR, TIPO_ENCARGO                    
       FROM AY_RATEIA_QUITACAO (                    
            @id1,                    
            @id2,                    
        @ITL_ORIGEM,                    
            @ITL_VALOR                    
       )                    
                    
      OPEN C_RATEIO_QUITACAO                    
      FETCH NEXT FROM C_RATEIO_QUITACAO INTO @CALC_VALOR_APROPRIAR, @CALC_ID_CAR, @CALC_TIPO_ENCARGO                    
      
      -- Se nao retornou nada, nao conseguiu ratear (cenario inconsistente!!)                    
      IF (@@FETCH_STATUS <> 0)                    
      BEGIN                    
                          
       -- Se for um estorno (positivo)                    
       IF (@ITL_VALOR > 0)                        
       BEGIN             
        -- O problema e que nao encontrou o rateiro de quitacao do item original                    
        SELECT @S = '      [Inconsistencia] Registro de estorno na LY_ITEM_LANC sem item original anterior. O item foi apropriado com o valor integral (sem remocao de encargos) e como um unico evento (sem centro de custo e natureza)'                    
       END                    
       -- Se for um item normal (negativo)                    
       ELSE                    
       BEGIN                    
        -- Nao existe apropriacao dos itens anteriores (na LY_CAR)                    
        SELECT @S = '      [Inconsistencia] Registro de Acerto na LY_ITEM_LANC sem itens anteriores processados. O item foi apropriado com o valor integral (sem remocao de encargos) e como um unico evento (sem centro de custo e natureza)'                
   
   
       END                    
                    
       -- Registra no log que nao foi possivel calcular o valor correto (rateado)                    
       EXEC spProcLog @CHAVE1 = 'Ly_Item_Lanc',                     
             @CHAVE2 = @id1,                    
             @CHAVE3 = @id2,                    
             @MSG = @S                    
                           
       -- Tenta pegar "qualquer" ID_CAR da cobranca (por prioridade e menor id) para ser o centro de custo/natureza (talvez nao ache nada)                    
       SELECT @CALC_ID_CAR = MIN(C.ID_CAR)                    
       FROM LY_CAR C WITH (NOLOCK)                    
       WHERE C.COBRANCA = @id1                    
       AND C.PRIORIDADE = (SELECT MIN(C2.PRIORIDADE)                    
            FROM LY_CAR C2 WITH (NOLOCK)                     
            WHERE C2.COBRANCA = C.COBRANCA)                    
                                
       -- Chama a procedure para atualizar os valores da LY_APROP_QUITACAO                    
       EXEC dbo.AY_GERA_APROP_QUITACAO @id1, @id2, @ITL_VALOR, @CALC_ID_CAR, NULL                    
                 
      END                    
                    
      -- Para cada linha retornada do cursor de rateio...                    
      WHILE (@@FETCH_STATUS = 0)                    
      BEGIN                    
                         
       -- Chama a procedure para atualizar os valores da LY_APROP_QUITACAO                    
       EXEC dbo.AY_GERA_APROP_QUITACAO @id1, @id2, @CALC_VALOR_APROPRIAR, @CALC_ID_CAR, @CALC_TIPO_ENCARGO                    
                    
       -- Pega o proximo item do rateio                    
       FETCH NEXT FROM C_RATEIO_QUITACAO INTO @CALC_VALOR_APROPRIAR, @CALC_ID_CAR, @CALC_TIPO_ENCARGO                    
                    
      END                    
                          
      CLOSE C_RATEIO_QUITACAO                    
      DEALLOCATE C_RATEIO_QUITACAO                    
                    
      -- Obtem o valor total dos itens apropriados                    
      SELECT @CALC_VALOR_TOTAL_INSERIDO = ISNULL(SUM(VALOR),0)                     
      FROM LY_APROP_QUITACAO AQ WITH (NOLOCK)                    
      WHERE AQ.COBRANCA = @id1                     
      AND AQ.ITEMCOBRANCA = @id2                    
                          
      -- Se o valor total apropriado for igual ao valor do item original                    
      IF (@CALC_VALOR_TOTAL_INSERIDO = @ITL_VALOR)     
      BEGIN                    
       -- Anota que gerou item na LY_APROP_CRED                    
       SELECT @GEROU_CAR_APROP = 'S'                        
      END                    
      ELSE                    
      BEGIN                    
                    
       -- Limpa qualquer valor parcial que tenha sido apropriado para esse item                    
       DELETE FROM LY_APROP_QUITACAO WHERE COBRANCA = @id1 AND ITEMCOBRANCA = @id2                    
                          
       -- Registra no log que nao foi possivel calcular o valor correto (rateado)                    
       SELECT @S = '      [Inconsistencia] Registro de Acerto na LY_ITEM_LANC sem itens anteriores processados. Item nao sera apropriado'                    
       EXEC spProcLog @CHAVE1 = 'Ly_Item_Lanc',                     
             @CHAVE2 = @id1,                    
             @CHAVE3 = @id2,                    
             @MSG = @S                    
                                 
      END                    
                    
                          
     END                    
     -- ----------------------------------------------------------------------------------                       
     -- Se NAO for uma QUITACAO na LY_ITEM_LANC (eh cobranca mesmo), vai gerar LY_CAR...                    
     -- ----------------------------------------------------------------------------------                    
     ELSE                    
     BEGIN                    
                    
                         
/*                    
      --                    
      -- Versao que identifica quando uma cobranca fica zerada e transforma                     
      -- a parte do valor que sobra em um outro evento de "credito na cobranca"                    
      --                    
      -- Foi desenvolvida para uma integracao financeira baseada em eventos                     
      -- mas apresentou alguns efeitos colaterais                    
 --                    
      -- ESTA DESATIVADA!! Utilizar apenas o insert com SOBRA = 'N' a seguir                    
                    
      -- Se for uma devolucao para o aluno....                    
      IF (@ITL_CODIGO_LANC = 'Acerto' AND @ITL_ORIGEM IN ('DEVOLUCAO-ALUNO'))                    
      BEGIN                    
       -- Garante que nao sera um caso de uso de sobra                    
       INSERT INTO LY_SOBRA_CRED_COBRANCA (COBRANCA, ITEMCOBRANCA, VALOR, SOBRA)                    
       VALUES (@id1, @id2, @ITL_VALOR, 'N')                    
      END                    
      -- Todos os outros casos...                    
      ELSE                    
      BEGIN                    
       -- Chama a funcao para separar a parte de valor que pode ser geracao ou uso de credito"                    
       INSERT INTO LY_SOBRA_CRED_COBRANCA (COBRANCA, ITEMCOBRANCA, VALOR, SOBRA)                    
       SELECT @id1, @id2, VALOR, SOBRA                     
       FROM AY_SEPARA_SOBRA_CREDITO_COBRANCA(@id1, @id2, @ITL_VALOR)                     
       WHERE VALOR <> 0                    
      END                    
                          
      --                    
      -- Fim da versao que modifica o evento                    
      --                    
*/                          
                    
                    
                    
      --                    
      -- Versao que NAO MODIFICA O EVENTO mesmo que a cobranca fique negativa                    
      -- (mais coerente com o conceito original do Lyceum)                    
      --                    
                         
      -- Registra TODO o valor do item como NAO SENDO SOBRA  
	  
	   IF ( select COUNT(1) QTD from LY_SOBRA_CRED_COBRANCA where cobranca = @id1 AND ITEMCOBRANCA = @id2 ) = 0 BEGIN
		   INSERT INTO LY_SOBRA_CRED_COBRANCA (COBRANCA, ITEMCOBRANCA, VALOR, SOBRA)                    
		   VALUES (@id1, @id2, @ITL_VALOR, 'N')    
	   END         
                    
      --                    
      -- Fim da versao que nao modifica o evento                    
      --                     
                    
                          
   -- Chama a procedure para atualizar os valores da LY_CAR                    
      EXEC dbo.AY_GERA_CAR @id1, @ITL_VALOR, @ITL_CENTRO_DE_CUSTO, @ITL_NATUREZA, @CDL_PRIORIDADE, @CALC_TIPO_CAR                    
                    
      -- Guarda a informacao que gerou item na LY_CAR                    
      SELECT @GEROU_CAR_APROP = 'S'                    
     END                    
    END -- Se conseguiu buscar os dados do item                    
   END -- Se a entidade for Ly_Item_Lanc                    
                    
           
   -- ------------------------------------------------------------------------------------                    
   -- Se a entidade for Ly_Item_Cred, vai gerar LY_EAR ou LY_APROP_CRED                    
   -- ------------------------------------------------------------------------------------                    
   ELSE IF @entidade = 'Ly_Item_Cred'                    
   BEGIN                    
                    
    -- Limpa as variaveis                    
    SELECT @ITC_COBRANCA = NULL,                     
        @ITC_VALOR = NULL,                    
        @ITC_TIPO_ENCARGO = NULL,                    
        @ITC_TIPODESCONTO = NULL,                    
        @TPE_PRIORIDADE = NULL                    
                       
    -- Busca as informacoes necessarias para gerar o APROP_CRED para esse item                    
    SELECT @ITC_COBRANCA = ITC.COBRANCA,                     
        @ITC_VALOR = ITC.VALOR,                    
        @ITC_TIPO_ENCARGO = ITC.TIPO_ENCARGO,                    
        @ITC_TIPODESCONTO = ITC.TIPODESCONTO,                    
        @TPE_PRIORIDADE = ISNULL(TPE.PRIORIDADE, 0)                    
    FROM LY_ITEM_CRED ITC WITH (NOLOCK)                    
    LEFT JOIN LY_TIPO_ENCARGOS TPE WITH (NOLOCK) ON (ITC.TIPO_ENCARGO = TPE.TIPO_ENCARGO)             
    WHERE ITC.LANC_CRED = @id1                      
    AND ITC.ITEMCRED = @id2                    
                    
    -- Se nao consegui buscar os dados do item                    
    IF @@ROWCOUNT = 0                    
    BEGIN                    
     -- Registra no log que o item nao existe mais no banco                    
     EXEC spProcLog @CHAVE1 = 'Ly_Item_Cred',                     
               @CHAVE2 = @id1,                    
               @CHAVE3 = @id2,                    
               @MSG = '      [Inconsistencia] Registro da LY_ITEM_CRED que nao existe mais. Item removido da LY_MOVIMENTO_TEMPORAL'                         
                         
     -- Remove o item da movimento temporal                    
     DELETE FROM LY_MOVIMENTO_TEMPORAL WHERE ID_MOVIMENTO_TEMPORAL = @id_mov_temporal                    
                         
     -- Aumenta o contador de removidos                    
     SET @QTD_REMOVIDOS = @QTD_REMOVIDOS + 1                           
    END                    
    -- Se conseguiu buscar os dados do item                    
    ELSE                    
    BEGIN                        
                        
     -- -------------------------------------                    
     -- Se for ENCARGO, vai gerar LY_EAR...                    
     -- -------------------------------------                    
     IF (@ITC_TIPO_ENCARGO IS NOT NULL)                    
     BEGIN                    
                         
      -- Chama a procedure para atualizar os valores da LY_EAR                    
      EXEC dbo.AY_GERA_EAR @ITC_COBRANCA, @ITC_VALOR, @ITC_TIPO_ENCARGO, @TPE_PRIORIDADE                    
                    
      -- Guarda a informacao que gerou item na LY_EAR                    
      SELECT @GEROU_CAR_APROP = 'S'                        
                          
     END                    
     -- --------------------------------------------------------------------------                    
     -- Se nao for ENCARGO (eh DESCONTO ou PAGAMENTO), vai gerar LY_APROP_CRED...                    
     -- --------------------------------------------------------------------------                    
     ELSE                    
     BEGIN                    
                         
      -- Cursor para ratear o pagamento                    
      DECLARE C_RATEIO_PAGAMENTO CURSOR FOR                    
       SELECT VALOR_APROPRIAR, ID_CAR, TIPO_ENCARGO, PGTO_A_MAIOR                    
       FROM AY_RATEIA_PAGAMENTO (                    
            @id1,                    
            @id2,                    
            @ITC_VALOR,                    
            @ITC_COBRANCA,                    
            @ITC_TIPODESCONTO                    
       )                    
                    
      OPEN C_RATEIO_PAGAMENTO               
      FETCH NEXT FROM C_RATEIO_PAGAMENTO INTO @CALC_VALOR_APROPRIAR, @CALC_ID_CAR, @CALC_TIPO_ENCARGO, @CALC_PAGTO_A_MAIOR                    
                    
      -- Se nao retornou nada, nao conseguiu ratear (cenario inconsistente!!)                    
      IF (@@FETCH_STATUS <> 0)                    
      BEGIN                    
                          
       -- Se for um estorno (positivo)                    
       IF (@ITC_VALOR > 0)                        
       BEGIN                    
        -- O problema e que nao encontrou o rateiro de pagamento do item original                   
        SELECT @S = '      [Inconsistencia] Registro de estorno na LY_ITEM_CRED sem item original anterior. O item foi apropriado com o valor integral (sem remocao de encargos) e como um unico evento (sem centro de custo e natureza)'                    
       END                    
       -- Se for um item normal (negativo)                    
       ELSE                    
       BEGIN                    
        -- Nao existe apropriacao dos itens da cobranca (na LY_CAR)                    
        SELECT @S = '      [Inconsistencia] Registro de pagamento na LY_ITEM_CRED sem itens da cobranca processados. O item foi apropriado com o valor integral (sem remocao de encargos) e como um unico evento (sem centro de custo e natureza)'            
  
    
      
        
       END                    
                          
       -- Registra no log que nao foi possivel ratear o estorno                    
       EXEC spProcLog @CHAVE1 = 'Ly_Item_Cred',                     
             @CHAVE2 = @id1,                    
             @CHAVE3 = @id2,                    
             @MSG = @S                    
                    
       -- Tenta pegar "qualquer" ID_CAR da cobranca (por prioridade e menor id) para ser o centro de custo/natureza (talvez nao ache nada)                    
       SELECT @CALC_ID_CAR = MIN(C.ID_CAR)                    
       FROM LY_CAR C WITH (NOLOCK)                    
       WHERE C.COBRANCA = @ITC_COBRANCA                    
       AND C.PRIORIDADE = (SELECT MIN(C2.PRIORIDADE)                    
            FROM LY_CAR C2 WITH (NOLOCK)                     
            WHERE C2.COBRANCA = C.COBRANCA)                    
                                 
       -- Chama a procedure para atualizar os valores da LY_APROP_CRED                    
       EXEC dbo.AY_GERA_APROP_CRED @id1, @id2, @ITC_VALOR, @CALC_ID_CAR, NULL, 'N'                    
                  END                    
                          
      -- Para cada linha retornada do cursor de rateio...                    
      WHILE (@@FETCH_STATUS = 0)                    
      BEGIN                    
                          
       -- Chama a procedure para atualizar os valores da LY_APROP_CRED                    
       EXEC dbo.AY_GERA_APROP_CRED @id1, @id2, @CALC_VALOR_APROPRIAR, @CALC_ID_CAR, @CALC_TIPO_ENCARGO, @CALC_PAGTO_A_MAIOR                    
                    
       -- Pega o proximo item do rateio                    
       FETCH NEXT FROM C_RATEIO_PAGAMENTO INTO @CALC_VALOR_APROPRIAR, @CALC_ID_CAR, @CALC_TIPO_ENCARGO, @CALC_PAGTO_A_MAIOR                    
                    
      END                    
                
      CLOSE C_RATEIO_PAGAMENTO                    
      DEALLOCATE C_RATEIO_PAGAMENTO                    
                    
      -- Obtem o valor total dos itens apropriados                    
      SELECT @CALC_VALOR_TOTAL_INSERIDO = ISNULL(SUM(VALOR),0)                     
      FROM LY_APROP_CRED AC WITH (NOLOCK)                    
      WHERE AC.LANC_CRED = @id1                     
      AND AC.ITEMCRED = @id2                    
                          
      -- Se o valor total apropriado for igual ao valor do item original                    
      IF (@CALC_VALOR_TOTAL_INSERIDO = @ITC_VALOR)                    
      BEGIN                    
       -- Anota que gerou item na LY_APROP_CRED                    
       SELECT @GEROU_CAR_APROP = 'S'                        
      END                    
      ELSE                    
    BEGIN                    
       -- Limpa qualquer valor parcial que tenha sido apropriado para esse item                    
       DELETE FROM LY_APROP_CRED WHERE LANC_CRED = @id1 AND ITEMCRED = @id2                    
                           
       -- Registra no log que nao foi possivel calcular o valor correto (rateado)                    
       SELECT @S = '      [Inconsistencia] Registro de pagamento na LY_ITEM_CRED sem itens de cobranca processados. Item nao sera apropriado'                    
       EXEC spProcLog @CHAVE1 = 'Ly_Item_Cred',                     
   @CHAVE2 = @id1,                    
             @CHAVE3 = @id2,                    
             @MSG = @S                    
      END                    
                    
                          
     END -- Se NAO for ENCARGO                    
    END -- Se conseguiu buscar os dados do item                    
   END -- Se a entidade for Ly_Item_Cred                    
                      
   -- ------------------------------------------------------------------------------------                    
   -- Se a entidade for invalida...                    
   -- ------------------------------------------------------------------------------------                    
   ELSE                    
   BEGIN                    
    -- Escreve no log                    
    SELECT @S = '      Entidade invalida para na LY_MOVIMENTO_TEMPORAL'                    
    EXEC spProcLog @CHAVE1 = @entidade,                     
          @CHAVE2 = @id1,                    
          @CHAVE3 = @id2,                    
          @MSG = @S                     
   END                    
                  
                       
   -- Se foi FOI APROPRIADO...                    
   IF (@GEROU_CAR_APROP = 'S')                    
   BEGIN                    
    -- Anota a data da apropriacao no item                    
    UPDATE LY_MOVIMENTO_TEMPORAL                     
    SET DT_CAR_APROP = GETDATE()                     
    WHERE ID_MOVIMENTO_TEMPORAL = @id_mov_temporal                    
                    
    -- Aumenta o contador de atualizados                    
    SET @QTD_ATUALIZADOS = @QTD_ATUALIZADOS + 1                        
   END                    
   ELSE                    
   BEGIN                    
    -- Aumenta o contador de NAO atualizados                    
    SET @QTD_NAO_ATUALIZADOS = @QTD_NAO_ATUALIZADOS + 1                    
   END                    
                       
  END TRY                    
  -- Se pegou algum erro durante a execucao                    
  BEGIN CATCH                    
   -- Da rollback (se ainda nao deu)                    
   WHILE @@TRANCOUNT > 0                    
    ROLLBACK TRANSACTION PROCESSA_ITEM_CAR_APROP                    
                    
   -- Manda o erro para o log                    
   SELECT @S = '      ' + ERROR_MESSAGE()                    
   EXEC spProcLog @CHAVE1 = @entidade,                     
         @CHAVE2 = @id1,                    
         @CHAVE3 = @id2,                    
         @MSG = @S                    
                  -- Se nao deve continuar com erros, aborta a execucao                    
   IF @P_CONTINUA_COM_ERRO = 'N'                     
   BEGIN                    
    -- Registra no retorno de erro que esta parando                    
    SELECT @P_MSG_ERRO = 'Apropriacao interrompida!'                    
    -- Vai para o final do processo                    
    GOTO FIM_PROC                    
   END                    
  END CATCH                    
                       
  -- Da commit na transacao                    
  COMMIT TRANSACTION PROCESSA_ITEM_CAR_APROP                    
                     
  -- Pega o proximo item do cursor                    
  FETCH NEXT FROM C_BUSCA_ITENS_EM_ORDEM INTO @id_mov_temporal, @entidade, @id1, @id2                    
                    
 END -- para cada item do cursor                    
                    
 -- guarda a data no final da procedure                    
 SELECT @DATA_FIM = GETDATE()                    
                    
 -- Escreve no log o que aconteceu                    
 IF @QTD_ATUALIZADOS = 0 AND @QTD_NAO_ATUALIZADOS = 0 AND @QTD_REMOVIDOS = 0                      
 BEGIN                    
  SELECT @S = '      Nenhum item precisava ser apropriado'                    
  EXEC spProcLog @MSG = @S                     
 END   ELSE                    
 BEGIN                    
  IF @QTD_ATUALIZADOS > 0                    
  BEGIN                    
   SELECT @S = '      Foram apropriados ' + CONVERT(VARCHAR, @QTD_ATUALIZADOS) + ' itens.'                    
   EXEC spProcLog @MSG = @S                     
  END                    
  IF @QTD_NAO_ATUALIZADOS > 0                    
  BEGIN                    
   SELECT @S = '      Nao foi possivel apropriar ' + CONVERT(VARCHAR, @QTD_NAO_ATUALIZADOS) + ' itens.'                    
   EXEC spProcLog @MSG = @S                     
  END                    
  IF @QTD_REMOVIDOS > 0                    
  BEGIN                    
   SELECT @S = '      Foram removidos ' + CONVERT(VARCHAR, @QTD_REMOVIDOS) + ' itens.'                    
   EXEC spProcLog @MSG = @S                     
  END                      
 END                     
                     
 -- Escreve no log o tempo que levou                    
 SELECT @S = '      Tempo de execucao: ' + CONVERT(VARCHAR, DATEDIFF(minute, @DATA_INI, @DATA_FIM)) + ' minutos.'                    
    EXEC spProcLog @MSG = @S                     
                     
                    
FIM_PROC:                    
 -- Fecha e libera o cursor                    
 CLOSE C_BUSCA_ITENS_EM_ORDEM                    
 DEALLOCATE C_BUSCA_ITENS_EM_ORDEM                    
 RETURN                    
                     
END       