--SELECT dbo.fnGetDtContabil('Ly_Item_Lanc','4137483','11','','','')  
--SELECT * FROM LY_ITEM_LANC WHERE COBRANCA = '4137483'
--SELECT * FROM LY_CUSTOM_CLIENTE WHERE OBJETIVO LIKE '%data%'

USE LYCEUM
GO

    
ALTER FUNCTION dbo.fnGetDtContabil (@P_ENTIDADE  VARCHAR(20),    
          @P_ID1   VARCHAR(20),    
          @P_ID2   VARCHAR(20),    
          @P_ID3   VARCHAR(20),    
          @P_ID4   VARCHAR(20),    
          @P_ID5   VARCHAR(20)     
)     
RETURNS DATETIME    
AS    
BEGIN    
    
 -- Retorno da Funcao    
 DECLARE @V_DT_CONTABIL DATETIME    
    
 -- ----------------------------------------------------------------------    
 -- Se for um registro da LY_ITEM_LANC    
 -------------------------------------------------------------------------    
IF @P_ENTIDADE = 'Ly_Item_Lanc'    
 BEGIN  --## 4  
    
  DECLARE @COB_ALUNO     T_CODIGO     
  DECLARE @COB_ANO     T_ANO    
  DECLARE @COB_MES     T_MES    
  DECLARE @COB_NUM_COBRANCA   T_NUMERO_PEQUENO    
  DECLARE @COB_DATA_DE_FATURAMENTO T_DATA    
  DECLARE @ITL_DATA     T_DATA    
  DECLARE @ITL_CODIGO_LANC   T_CODIGO    
  DECLARE @ITL_DEVOLUCAO    T_NUMERO    
  DECLARE @ITL_ORIGEM     VARCHAR(40)    
  DECLARE @CUR_FACULDADE    T_CODIGO    
    
  -- PERDABOLSA    
  DECLARE @NUM_BOLSA      T_NUMERO    
  DECLARE @PERDABOLSA     T_CODIGO    
  DECLARE @DT_CREDITO     T_DATA    
  DECLARE @DT_VENCIMENTO  T_DATA    
  DECLARE @SALDO_COB  T_DECIMAL_MEDIO    
  DECLARE @V_ENC_GERADO   T_CODIGO    
    
  -- Busca os dados da cobranca para calcular a data contabil    
  SELECT   
   @COB_ALUNO     = COB.ALUNO,    
   @COB_MES     = COB.MES,     
   @COB_ANO     = COB.ANO,    
   @COB_DATA_DE_FATURAMENTO = COB.DATA_DE_FATURAMENTO,    
   @COB_NUM_COBRANCA   = COB.NUM_COBRANCA,    
   @ITL_DATA     = ITL.DATA,    
   @ITL_CODIGO_LANC   = ITL.CODIGO_LANC,    
   @ITL_DEVOLUCAO    = ITL.DEVOLUCAO,    
   @ITL_ORIGEM     = ITL.ORIGEM,    
   @CUR_FACULDADE    = CUR.FACULDADE,    
   @NUM_BOLSA     = NUM_BOLSA,    
   @DT_VENCIMENTO    = COB.DATA_DE_VENCIMENTO    
  FROM LY_ITEM_LANC ITL WITH (NOLOCK)    
  JOIN LY_COBRANCA COB WITH (NOLOCK)   
   ON (ITL.COBRANCA = COB.COBRANCA)    
  LEFT JOIN LY_CURSO CUR WITH (NOLOCK)   
   ON (ITL.CURSO = CUR.CURSO)      
  WHERE ITL.COBRANCA  = @P_ID1    
  AND ITL.ITEMCOBRANCA = @P_ID2    
    
  -- Se a cobranca estiver faturada...    
  IF @COB_DATA_DE_FATURAMENTO IS NOT NULL    
   BEGIN  --## 3  
      
    DECLARE @CALC_DATA_REFERENCIA T_DATA    
      
    -- Calculando a data de referencia    
    SELECT @CALC_DATA_REFERENCIA = CONVERT(DATETIME, '01/' + LTRIM(STR(@COB_MES, 2)) + '/' + LTRIM(STR(@COB_ANO, 4)), 103)    
       
    -- Se for um item de DEVOLUCAO...    
    IF (@ITL_CODIGO_LANC = 'Acerto' AND @ITL_ORIGEM = 'DEVOLUCAO-ALUNO' AND @ITL_DEVOLUCAO IS NOT NULL)    
     BEGIN    
      -- A data contabil sera a data prevista para a devolucao ou a data que a devolucao foi registrada (para nao ficar null)    
      SELECT @V_DT_CONTABIL = CONVERT(DATETIME, dbo.fnGreatest3(ISNULL(DATA_PREV_DEVOL, DATA) , @COB_DATA_DE_FATURAMENTO, @ITL_DATA))    
       --ISNULL(DATA_PREV_DEVOL, DATA)     
      FROM LY_DEVOLUCAO WITH (NOLOCK)     
      WHERE DEVOLUCAO = @ITL_DEVOLUCAO    
     END    
    -- Todos os outros casos...    
    ELSE    
     BEGIN --## 2   
       
      -- -- -----------------------    
      -- --  Versao padrao INICIO    
      -- -- -----------------------    
        
      -- -- A data contabil sera a maior entre a data de referencia, data de faturamento e a data do item    
      -- SELECT @V_DT_CONTABIL = CONVERT(DATETIME, dbo.fnGreatest3(@CALC_DATA_REFERENCIA, @COB_DATA_DE_FATURAMENTO, @ITL_DATA))    
    
      -- -- --------------------    
      -- --  Versao padrao FIM    
      -- -- --------------------    
      -- Se for cobranca de mensalidade (NUM_COBRANCA = 1) E TAMBÉM COBRANÇA DE SERVIÇOS SOLICITADOS (REQUERIMENTOS)    
      IF @COB_NUM_COBRANCA IN (1,2)    
       BEGIN --## 0  
        DECLARE @CALC_ANOPERIODO_DIVIDA VARCHAR(6)    
        DECLARE @CALC_ANO_DIVIDA  T_ANO    
        DECLARE @CALC_PERIODO_DIVIDA T_MES    
        DECLARE @CALC_DATA_MATRICULA T_DATA    
        DECLARE @CALC_DATA_PG_LANC_MATR T_DATA    
        DECLARE @CALC_DATA_PG_DEP_MATR T_DATA    
        DECLARE @CALC_DATA_PGTO_MATR T_DATA    
        DECLARE @CALC_DATA_BAIXA_ACORDO T_DATA    
    
        -- Buscando o maior ANOPERIODO entre as dividas dessa cobranca    
        SELECT   
         @CALC_ANOPERIODO_DIVIDA = MAX(CONVERT(VARCHAR(4),ld.ANO_REF) + SUBSTRING(CONVERT(VARCHAR(4),ld.PERIODO_REF + 100),2,2))    
        FROM LY_ITEM_LANC IL WITH (NOLOCK)    
        JOIN LY_LANC_DEBITO LD WITH (NOLOCK)   
         ON (IL.LANC_DEB = LD.LANC_DEB)    
        WHERE IL.COBRANCA = @P_ID1    
    
        -- Separando o ano e o periodo    
        SELECT @CALC_ANO_DIVIDA  = CONVERT(NUMERIC, SUBSTRING(@CALC_ANOPERIODO_DIVIDA, 1, 4))    
        SELECT @CALC_PERIODO_DIVIDA = CONVERT(NUMERIC, SUBSTRING(@CALC_ANOPERIODO_DIVIDA, 5, 2))    
         
        -- ## Data Contábil - MENSALIDADE - INÍCIO    
        -- ## Autor: Edillan Lage    
        -- ## Data: 22/11/2016    
        -- ## Objetivo: Implementação de regra de cálculo de data contábil em que só deve ser contabilizado quando uma das parcelas do período for paga ou acordada    
        BEGIN  --## 1  
         IF @COB_NUM_COBRANCA = 1    
          BEGIN    
           -- Buscar primeiro pagamento para alguma das dívidas da cobrança  
           --## SÓ TRATA PARA DIVIDAS DE MENSALIDADE GERADA NO LYCEUM -> AS MIGRADAS NÃO FUNCIONAM NA REGRA ABAIXO POIS TEM UMA COBRANCA POR DIVIDA.   
           SELECT   
            @CALC_DATA_PG_LANC_MATR = MIN(IC.DATA),    
            @CALC_DATA_PG_DEP_MATR  = MIN(ISNULL(LC.DT_DEPOSITO,LC.DT_CREDITO))    
           FROM LY_LANC_CREDITO  LC (NOLOCK)   --Verificar se existe pagamento para a cobranca  
           JOIN LY_ITEM_CRED  IC (NOLOCK)   
            ON IC.LANC_CRED  = LC.LANC_CRED    
           JOIN LY_ITEM_LANC  IL (NOLOCK)    --Verifica se para esta cobranca tem pagamento  
            ON IL.COBRANCA   = IC.COBRANCA    
           JOIN LY_LANC_DEBITO  D (NOLOCK)    --Vincula debito a cobranca  
            ON D.LANC_DEB   = IL.LANC_DEB    
           JOIN LY_COD_LANC   CL (NOLOCK)    --Verifica se o debito e de pagamento curso aula  
            ON CL.CODIGO_LANC  = D.CODIGO_LANC    
            AND CL.PGTOCURSOAULAS = 'S'    
           --## Neste join abaixo estou verificando se a cobranca esta vinculada a uma divida de mensalidade que já cobrancas vinculadas pagas  
           JOIN LY_ITEM_LANC  ILC (NOLOCK)   
            ON ILC.LANC_DEB  = D.LANC_DEB    
           WHERE ILC.COBRANCA = CAST(@P_ID1 AS int)  --Verifica se para esta cobranca já houve pagamento em alguma cobranca vinculada a sua divida  
           AND  D.ANO_REF  = @CALC_ANO_DIVIDA    
           AND  D.PERIODO_REF = @CALC_PERIODO_DIVIDA    
           -- CONSIDERA SOMENTE PAGAMENTOS, ENCARGOS E DESCONTOS PODEM EXISTIR SEM PAGAMENTO DEVIDO A ARRASTO E RESTITUIÇÕES    
           AND  IC.TIPO_ENCARGO IS NULL    
           AND  IC.TIPODESCONTO IS NULL    
          END    
         ELSE IF @COB_NUM_COBRANCA = 2    
           BEGIN    
            -- Buscar primeiro pagamento para alguma das dívidas da cobrança    
            SELECT   
             @CALC_DATA_PG_LANC_MATR = MIN(IC.DATA),    
             @CALC_DATA_PG_DEP_MATR = MIN(ISNULL(LC.DT_DEPOSITO,LC.DT_CREDITO))    
            FROM LY_LANC_CREDITO  LC (NOLOCK)    
            JOIN LY_ITEM_CRED  IC (NOLOCK)   
             ON IC.LANC_CRED  = LC.LANC_CRED    
            JOIN LY_ITEM_LANC  IL (NOLOCK)   
             ON IL.COBRANCA   = IC.COBRANCA    
            WHERE IC.COBRANCA = CAST(@P_ID1 AS int)    
            -- CONSIDERA SOMENTE PAGAMENTOS, ENCARGOS E DESCONTOS PODEM EXISTIR SEM PAGAMENTO DEVIDO A ARRASTO E RESTITUIÇÕES    
            AND  IC.TIPO_ENCARGO IS NULL    
            AND  IC.TIPODESCONTO IS NULL    
           END    
    
         -- CASO NÃO TENHA PAGAMENTO ASSOCIADO VALIDA SE COBRANÇA FOI BAIXADA DE ALGUMA FORMA (BOLSA 100%, DESCONTO, RESTITUIÇÃO, ...)    
         IF @CALC_DATA_PG_LANC_MATR IS NULL     
         AND (EXISTS (  
            SELECT TOP 1 1     
            FROM VW_COBRANCA  V    
            JOIN LY_COBRANCA  C ON C.COBRANCA  = V.COBRANCA    
            WHERE C.COBRANCA  = CAST(@P_ID1 AS INT)     
            AND  C.ESTORNO  = 'N'    
            AND  VALOR <= 0    
            )    
            
         --####################  
         --## INICIO - RAUL - INCLUIR TRATAMENTO PARA BOLSAS FIES E PROUNI 24/08/2017  
         -- Teve item de bolsa dos tipos abaixo na cobranca, contabiliza.  
         --####################  
            OR exists (  select top 1 1  
                FROM LY_ITEM_LANC IL  
              JOIN LY_BOLSA B   
               ON B.ALUNO = IL.ALUNO   
               AND B.NUM_BOLSA = IL.NUM_BOLSA  
              join ly_cobranca c  
               on il.cobranca = c.cobranca  
              WHERE IL.COBRANCA = CAST(@P_ID1 AS INT)  
              and c.ano >= 2017       --## Só considerar cobrancas com ano maior ou igual a 2017  
              AND B.TIPO_BOLSA IN ('FIES','FIES_TEMP','FIES100','FIESGERAL','FIESFNDE','FIESTA','PROUNI100','PROUNI50')  
              )   
           )  
  
         --####################  
         --## FIM - RAUL - INCLUIR TRATAMENTO PARA BOLSAS FIES E PROUNI 24/08/2017  
         --####################  
          BEGIN    
           -- DESCONTOS INSERIDOS COMO BAIXA    
           SELECT   
            @CALC_DATA_PG_LANC_MATR = MIN(IC.DATA),    
            @CALC_DATA_PG_DEP_MATR = MIN(ISNULL(LC.DT_DEPOSITO,LC.DT_CREDITO))    
           FROM LY_LANC_CREDITO  LC (NOLOCK)    
           JOIN LY_ITEM_CRED  IC (NOLOCK)   
            ON IC.LANC_CRED  = LC.LANC_CRED    
           JOIN LY_ITEM_LANC  IL (NOLOCK)   
            ON IL.COBRANCA   = IC.COBRANCA    
           WHERE IC.COBRANCA = CAST(@P_ID1 AS int)    
           -- CONSIDERA SOMENTE PAGAMENTOS FEITOS ATRAVÉS DE DESCONTOS    
           AND  IC.TIPODESCONTO IS NOT NULL   
           AND IC.TIPODESCONTO <> 'PagtoAntecipado'    
           
           IF @CALC_DATA_PG_LANC_MATR IS NULL    
            BEGIN    
             -- CASO NÃO TENHA PAGAMENTO OU DESCONTO ENTÃO BUSCA POR RESTITUIÇÃO OU ARRASTO ZERANDO O SALDO DA COBRANÇA    
             SELECT   
              @CALC_DATA_PG_LANC_MATR = MIN(IL.DATA),    
              @CALC_DATA_PG_DEP_MATR = MIN(IL.DATA)    
             FROM LY_ITEM_LANC IL    
             WHERE IL.COBRANCA = CAST(@P_ID1 AS INT)    
             AND IL.COBRANCA_ORIG IS NOT NULL    
            END    
           
           -- CASO NÃO SEJA ENCONTRADO DESCONTO OU RESTITUIÇÃO ENTÃO TEREMOS UMA BOLSA 100% QUE DEVERÁ    
           -- SER CONTABILIZADA COM A DATA DE FATURAMENTO    
           SELECT @V_DT_CONTABIL = CONVERT(DATETIME, dbo.fnGreatest4(@CALC_DATA_REFERENCIA,@COB_DATA_DE_FATURAMENTO, @CALC_DATA_PG_LANC_MATR, @CALC_DATA_PG_DEP_MATR))    
           --## 04/04/2017 - Raul - Foi solicitado por Gregorio que incluisse na validação de maior data a data de referencia  
           --SELECT @V_DT_CONTABIL = CONVERT(DATETIME, dbo.fnGreatest3(@COB_DATA_DE_FATURAMENTO, @CALC_DATA_PG_LANC_MATR, @CALC_DATA_PG_DEP_MATR))            
        
          END    
    
         -- VERIFICA SE HOUVE BAIXA DE ALGUMA PARCELA DO PERÍODO POR ACORDO. NESSE CASO ELA PASSA A SER CONSIDERADA QUITADA    
         -- VERIFICAR SE DEVE SER QUALQUER PARCELA OU SOMENTE A PRIMEIRA    
         SELECT @CALC_DATA_BAIXA_ACORDO = MIN(IAC.DATA)    
         -- ITEM LANC ASSOCIADO ÀS DÍVIDAS DA COBRANÇA SENDO CALCULADA    
         FROM LY_ITEM_LANC  IL (NOLOCK)    
         JOIN LY_LANC_DEBITO D (NOLOCK)   
          ON D.LANC_DEB   = IL.LANC_DEB    
         JOIN LY_COD_LANC  CL (NOLOCK)   
          ON CL.CODIGO_LANC  = D.CODIGO_LANC    
          AND CL.PGTOCURSOAULAS = 'S'    
         -- ITEM LANC DA COBRANÇA SENDO CALCULADA DATA    
         JOIN LY_ITEM_LANC  ILC (NOLOCK)   
          ON ILC.LANC_DEB  = D.LANC_DEB    
         -- ITEM LANC DE BAIXA DO ACORDO    
         JOIN LY_ITEM_LANC  IAC (NOLOCK)   
          ON IAC.COBRANCA  = IL.COBRANCA    
          AND IAC.CODIGO_LANC = 'Acerto'    
          AND IAC.ACORDO  IS NOT NULL    
         WHERE ILC.COBRANCA = CAST(@P_ID1 AS int)    
         AND  D.ANO_REF  = @CALC_ANO_DIVIDA    
         AND  D.PERIODO_REF = @CALC_PERIODO_DIVIDA    
    
    
         -- SE A DATA DE BAIXA DO ACORDO É INFERIOR ÀS DATAS DE DEPÓSITO E LANÇAMENTO DO PAGAMENTO    
         IF (  
          ISNULL(@CALC_DATA_BAIXA_ACORDO, @CALC_DATA_PG_LANC_MATR) < @CALC_DATA_PG_LANC_MATR    
         AND ISNULL(@CALC_DATA_BAIXA_ACORDO, @CALC_DATA_PG_DEP_MATR) < @CALC_DATA_PG_DEP_MATR  
          )    
         -- OU AINDA NÃO EXISTEM PAGAMENTOS LANÇADOS    
         OR (@CALC_DATA_PG_DEP_MATR IS NULL AND @CALC_DATA_PG_LANC_MATR IS NULL)    
         BEGIN    
          SELECT  @CALC_DATA_PG_LANC_MATR = @CALC_DATA_BAIXA_ACORDO,    
            @CALC_DATA_PG_DEP_MATR = @CALC_DATA_BAIXA_ACORDO    
         END    
    
      
         IF @CALC_DATA_PG_LANC_MATR IS NOT NULL    
         OR @CALC_DATA_PG_DEP_MATR IS NOT NULL    
           BEGIN    
             SELECT @CALC_DATA_PGTO_MATR = CONVERT(DATETIME, dbo.fnGreatest3('19000101', @CALC_DATA_PG_LANC_MATR, @CALC_DATA_PG_DEP_MATR))         
             SELECT @V_DT_CONTABIL   = CONVERT(DATETIME, dbo.fnGreatest4(@CALC_DATA_REFERENCIA, @COB_DATA_DE_FATURAMENTO, @ITL_DATA, @CALC_DATA_PGTO_MATR))    
           END     
          --## O 'ELSE' ABAIXO DEFINE COMO A DATA CONTABIL MAIOR ENTRE: 
		  --		DESCOMENTADO POR		1) DATA DE FATURAMENTO; 
		  --			MIGUEL				2) DATA DE REFERENCIA; 
		  --		EM 20/11/2017			3) DATA DO ITEM.
		  -- PARA COBRANÇAS QUE NÃO CORRESPONDAM COM AS CONDIÇÕES ACIMA ## --
           ELSE    
                BEGIN    
                    SELECT @V_DT_CONTABIL = CONVERT(DATETIME, dbo.fnGreatest3(@CALC_DATA_REFERENCIA, @COB_DATA_DE_FATURAMENTO, @ITL_DATA))    
                END    
        END --## 1 -- ## Data Contábil - PAGAMENTO    
       END --## 0  
     
       -- Se for cobranca de mensalidade/serviços (NUM_COBRANCA = 1,4) FIM    
          -- -- ----------------------------------------------------------------------------------------------------    
       -- INICIO TRATAMENTO FTC PARA COBRANÇAS DE ACORDO. UTILIZAR A DATA CONTÁBIL COMO SENDO A DATA DO ITEM DA COBRANCA    
          -- QUANDO AS COBRANÇAS JÁ ESTIVEREM FATURADAS ELA DEVEM SER CONTABILIZADAS JUNTAS E NÃO MÊS A MÊS COMO É O PADRÃO DO ARGYROS    
          -- IMPLEMENTADO POR EDILLAN LAGE EM 24/02/2016, A PEDIDO DA ROSEMEIRE DA CONTABILIDADE    
       -- COBRANÇA DE ACORDO - INICIO    
       ELSE   
        IF @COB_NUM_COBRANCA = 3    
         BEGIN    
          SELECT @V_DT_CONTABIL = ITL.DATA   
          FROM LY_ITEM_LANC ITL    
          WHERE ITL.COBRANCA  = @P_ID1   
          AND ITL.ITEMCOBRANCA = @P_ID2    
         END    
         -- FIM TRATAMENTO FTC PARA COBRANÇAS DE ACORDO.    
       -- COBRANÇA DE ACORDO - FIM    
       -- DEMAIS TIPOS DE COBRANÇA INICIO    
        ELSE    
         BEGIN    
           -- A data contabil sera a maior entre a data de referencia, data de faturamento e a data do item    
           SELECT @V_DT_CONTABIL = CONVERT(DATETIME, dbo.fnGreatest3(@CALC_DATA_REFERENCIA, @COB_DATA_DE_FATURAMENTO, @ITL_DATA))    
         END    
        -- DEMAIS TIPOS DE COBRANÇA FIM    
        -- ----------------------------------------------------------------------------------------------------    
     
    ---- VERIFICAR ITENS DE PERDABOLSA    
    ---- OS ITENS DE PERDABOLSA SERÃO CONTABILIZADOS SOMENTE SE O PAGAMENTO OCORRER ATÉ O VENCIMENTO, CASO CONTRÁRIO NÃO RECEBERÃO DATA CONTABIL    
    ---- NECESSÁRIA ROTINA PARA APÓS O VENCIMENTO REMOVER OS ITENS DA FILA OU MARCÁ-LOS COMO CONTABILIZADOS.    
        
    ---- VERIFICA SE A BOLSA DO ITEM É PERDABOLSA INICIO    
    --IF @NUM_BOLSA IS NOT NULL    
    --BEGIN    
    -- SELECT @PERDABOLSA  = TIPO_ENCARGO    
    -- FROM LY_BOLSA  B    
    -- JOIN LY_TIPO_BOLSA TB ON TB.TIPO_BOLSA = B.TIPO_BOLSA    
    -- WHERE ALUNO  = @COB_ALUNO    
    -- AND  NUM_BOLSA = @NUM_BOLSA    
    
    -- IF @PERDABOLSA IS NOT NULL    
    -- BEGIN    
    --  -- SE É PERDABOLSA, BUSCA O PAGAMENTO ANTERIOR AO VENCIMENTO    
    --  SELECT @DT_CREDITO  = MIN(LC.DT_CREDITO)    
    --  FROM LY_ITEM_CRED IC    
    --  JOIN LY_LANC_CREDITO LC ON LC.LANC_CRED = IC.LANC_CRED    
    --  WHERE COBRANCA = @P_ID1    
    --  AND  TIPO_ENCARGO IS NULL    
    --  AND  TIPODESCONTO IS NULL    
 --  AND  LC.DT_CREDITO <= @DT_VENCIMENTO    
          
    --  SELECT @SALDO_COB = VALOR    
    --  FROM VW_COBRANCA    
    --  WHERE COBRANCA = @P_ID1    
          
    --  -- BUSCA SE A COBRANÇA POSSUI O ENCARGO PERDABOLSA - CASO NÃO TENHA ELA SERÁ INCONDICIONAL    
    --  SELECT @V_ENC_GERADO = 'S'    
    --  FROM LY_ENCARGOS_COB_GERADO    
    --  WHERE COBRANCA  = CAST(@P_ID1 AS INT)    
    --  AND  TIPO_ENCARGO = 'PERDEBOLSA'    
    
    --  SET @V_ENC_GERADO = ISNULL(@V_ENC_GERADO,'N')    
          
    --  -- SE O PAGAMENTO OCORREU ANTES DO VENCIMENTO E A COBRANÇA ESTÁ TOTALMENTE PAGA, APURA AS BOLSAS    
    --  --IF @DT_CREDITO IS NOT NULL AND @SALDO_COB <= 0    
    --  --BEGIN    
    --  -- SET @V_DT_CONTABIL = @DT_CREDITO    
    --  --END    
    --  --ELSE    
    --  --/*    
    --  IF NOT(@DT_CREDITO IS NOT NULL AND @SALDO_COB <= 0) AND @V_ENC_GERADO = 'S'    
    --  BEGIN    
    --   SET @V_DT_CONTABIL = NULL    
    --  END    
    --  --*/    
    -- END    
    --END    
    ---- VERIFICA SE A BOLSA DO ITEM É PERDABOLSA FIM    
/*     
    -- --------------------------------------------------------------------------------    
    --  Versao que considera a data de matricula para cobrancas de mensalidade INICIO    
    -- --------------------------------------------------------------------------------    
       
    -- Se for cobranca de mensalidade (NUM_COBRANCA = 1)    
    IF @COB_NUM_COBRANCA = 1    
    BEGIN    
    
     DECLARE @CALC_ANOPERIODO_DIVIDA VARCHAR(6)    
     DECLARE @CALC_ANO_DIVIDA T_ANO    
     DECLARE @CALC_PERIODO_DIVIDA T_MES    
     DECLARE @CALC_DATA_MATRICULA T_DATA    
    
     -- Buscando o maior ANOPERIODO entre as dividas dessa cobranca    
     SELECT @CALC_ANOPERIODO_DIVIDA = MAX(CONVERT(VARCHAR(4),ld.ANO_REF) + SUBSTRING(CONVERT(VARCHAR(4),ld.PERIODO_REF + 100),2,2))    
     FROM LY_ITEM_LANC IL WITH (NOLOCK)    
      JOIN LY_LANC_DEBITO LD WITH (NOLOCK) ON (IL.LANC_DEB = LD.LANC_DEB)    
     WHERE IL.COBRANCA = @P_ID1    
    
     -- Separando o ano e o periodo    
     SELECT @CALC_ANO_DIVIDA = CONVERT(NUMERIC, SUBSTRING(@CALC_ANOPERIODO_DIVIDA, 1, 4))    
     SELECT @CALC_PERIODO_DIVIDA = CONVERT(NUMERIC, SUBSTRING(@CALC_ANOPERIODO_DIVIDA, 5, 2))    
         
     -- Calculando a data de matricula    
     SELECT @CALC_DATA_MATRICULA = dbo.fnGetDataMat(@COB_ALUNO, @CALC_ANO_DIVIDA, @CALC_PERIODO_DIVIDA)    
        
     -- Se achou data de matricula...    
     IF @CALC_DATA_MATRICULA IS NOT NULL    
     BEGIN    
      SELECT @V_DT_CONTABIL = CONVERT(DATETIME, dbo.fnGreatest4(@CALC_DATA_REFERENCIA, @COB_DATA_DE_FATURAMENTO, @ITL_DATA, @CALC_DATA_MATRICULA))    
     END    
         
    END    
    -- Se nao for cobranca de mensalidade (NUM_COBRANCA <> 1)    
    ELSE    
    BEGIN    
     -- A data contabil sera a maior entre a data de referencia, data de faturamento e a data do item    
     SELECT @V_DT_CONTABIL = CONVERT(DATETIME, dbo.fnGreatest3(@CALC_DATA_REFERENCIA, @COB_DATA_DE_FATURAMENTO, @ITL_DATA))    
    END    
    
    -- --------------------------------------------------------------------------------    
    --  Versao que considera a data de matricula para cobrancas de mensalidade TERMINO    
    -- --------------------------------------------------------------------------------    
*/       
    
     END  --## 2  
    
    --    
    -- Se o item nao for uma BAIXA nem DEVOLUCAO e estivermos em periodo de fechamento    
    -- devemos mudar a data contabil para o inicio do proximo mes    
    --    
    IF (    
     @ITL_CODIGO_LANC <> 'Acerto'    
     OR     
     (@ITL_CODIGO_LANC = 'Acerto'   
      AND @ITL_ORIGEM NOT IN ('ACORDO', 'CHEQUE FINANCIAMENTO', 'RESTITUICAO RECEBE', 'ARRASTO TRANSFERE', 'DEVOLUCAO-ALUNO'))    
     )    
    BEGIN    
    
     DECLARE @V_DT_CONTABIL_NOVA T_DATA    
       
     -- Busca a data contabil nova caso a atual coincida com um periodo de fechamento da unidade    
     SELECT @V_DT_CONTABIL_NOVA = DATEADD(MONTH, 1, CONVERT(DATETIME, '01' + '/' + CONVERT(VARCHAR, PF.MES) + '/' + CONVERT(VARCHAR, PF.ANO), 103))    
     FROM LY_PERIODO_FECHAMENTO PF    
     WHERE PF.UNIDADE = @CUR_FACULDADE    
     AND PF.ANO   = YEAR(@V_DT_CONTABIL)    
     AND PF.MES   = MONTH(@V_DT_CONTABIL)    
     AND PF.DATA_INI_FECHAMENTO <= @V_DT_CONTABIL    
        
     -- Utiliza a data nova se ela nao for nula    
     SELECT @V_DT_CONTABIL = ISNULL(@V_DT_CONTABIL_NOVA, @V_DT_CONTABIL)    
       
      END    
    
   END --## 3 -- se a cobranca estiver faturada    
    
 END --## 4    
     
-------------------------------------------------------------------------    
-- Se for um registro da LY_ITEM_CRED    
-------------------------------------------------------------------------    
IF @P_ENTIDADE = 'Ly_Item_Cred'    
 BEGIN  --## 6  
      
  DECLARE @ITC_DATA    T_DATA    
  DECLARE @ITC_COBRANCA   T_NUMERO    
  DECLARE @LCC_TIPO_PAGAMENTO  T_ALFASMALL    
  DECLARE @LCC_DT_CREDITO   T_DATA    
  DECLARE @LCC_DT_DEPOSITO  T_DATA    
  DECLARE @LCC_VALIDO_APOS_COMP T_SIMNAO    
  DECLARE @CHQ_DT_BAIXA   T_DATA    
  DECLARE @ITC_TIPODESCONTO  T_CODIGO    
  DECLARE @ITC_TIPO_ENCARGO  T_CODIGO    
  DECLARE @ITC_VALOR    T_DECIMAL_MEDIO    
      
  -- Busca os dados do pagamento para calcular a data contabil    
  SELECT   
   @ITC_DATA    = DATEADD(DD, 0, DATEDIFF(DD, 0, ITC.DATA)), -- retira a hora (registros inconsistentes podem ter hora)    
   @ITC_COBRANCA   = ISNULL(ITC.COBRANCA, 0),    
   @LCC_TIPO_PAGAMENTO  = LCC.TIPO_PAGAMENTO,     
   @LCC_DT_CREDITO   = LCC.DT_CREDITO,     
   @LCC_DT_DEPOSITO  = LCC.DT_DEPOSITO,    
   @LCC_VALIDO_APOS_COMP = ISNULL(LCC.VALIDO_APOS_COMP, 'N'),    
   @CHQ_DT_BAIXA   = CHQ.DT_BAIXA,    
   @ITC_TIPODESCONTO  = ITC.TIPODESCONTO,    
   @ITC_TIPO_ENCARGO  = ITC.TIPO_ENCARGO,    
   @ITC_VALOR    = ITC.VALOR    
  FROM  LY_ITEM_CRED ITC WITH (NOLOCK)    
  JOIN  LY_LANC_CREDITO LCC WITH (NOLOCK)   
   ON (ITC.LANC_CRED = LCC.LANC_CRED)    
  LEFT JOIN LY_CHEQUES  CHQ WITH (NOLOCK)   
   ON (LCC.BANCO  = CHQ.BANCO     
   AND LCC.AGENCIA  = CHQ.AGENCIA     
   AND LCC.CONTA_BANCO = CHQ.CONTA_BANCO     
   AND LCC.SERIE  = CHQ.SERIE     
   AND LCC.NUMERO  = CHQ.NUMERO)    
  WHERE ITC.LANC_CRED = @P_ID1    
  AND  ITC.ITEMCRED = @P_ID2    
      
  -- Se for pagamento via Banco...    
  IF (@LCC_TIPO_PAGAMENTO = 'Banco')    
   BEGIN --## 5    
    -- --------------------------------------------------------------------------------      
    -- Versao que FORCA a data contabil para ser SEMPRE a de deposito INICIO    
    -- Pode acabar gerando datas contabeis retroativas se o registro do deposito    
    -- tiver sido atrasado    
    -- --------------------------------------------------------------------------------    
    -- SE EXISTE TRAVA CONTABIL    
    IF (    
     -- Se nao for estorno    
     (@ITC_TIPODESCONTO IS NOT NULL AND @ITC_VALOR < 0) OR    
     (@ITC_TIPO_ENCARGO IS NOT NULL AND @ITC_VALOR > 0) OR    
     (@ITC_TIPODESCONTO IS NULL AND @ITC_TIPO_ENCARGO IS NULL AND @ITC_VALOR < 0)    
     )    
    --## RAUL - Comentado em 22/08/2017 para deixar baixas por banco e inconsistencia com mesma regra  @V_DT_CONTABIL = ISNULL(@LCC_DT_DEPOSITO,@LCC_DT_CREDITO)  
    --## Solicitado por Nelson por e-mail.  
    --AND    
    --(    
    -- -- Se nao for de origem DNI      
    -- NOT EXISTS (SELECT 1 FROM LY_ERRO_MOV_PAGAMENTO WHERE LANC_CRED = @P_ID1)      
    --)    
     BEGIN    
      -- A data contabil sera a de deposito   
      -- ALTERADO EM 22/03/2017 PARA incluir na validação A DATA DE CREDITO, pois antes só tinha deposito  
      SELECT @V_DT_CONTABIL = ISNULL(@LCC_DT_DEPOSITO,@LCC_DT_CREDITO)    
     END    
    -- Se for estorno considera a data do registro    
    ELSE    
     BEGIN    
      -- A data contabil sera a maior entre a data de geracao e a de deposito    
      SELECT @V_DT_CONTABIL = (CASE     
             WHEN (@ITC_DATA > ISNULL(@LCC_DT_DEPOSITO,@LCC_DT_CREDITO)) THEN @ITC_DATA    
             ELSE ISNULL(@LCC_DT_DEPOSITO,@LCC_DT_CREDITO)    
             END)    
     END    
    
    -- --------------------------------------------------------------------------------      
    -- Versao que FORCA a data contabil para ser SEMPRE a de deposito TERMINO    
    -- --------------------------------------------------------------------------------      
    
    
/*    
   -- -----------------------    
   --  Versao padrao INICIO    
   -- -----------------------    
    
   -- A data contabil sera a maior entre a data de geracao e a de deposito    
   SELECT @V_DT_CONTABIL = CASE     
          WHEN (@ITC_DATA > ISNULL(@LCC_DT_DEPOSITO,@LCC_DT_CREDITO)) THEN @ITC_DATA    
          ELSE ISNULL(@LCC_DT_DEPOSITO,@LCC_DT_CREDITO)    
          END    
     
   -- --------------------    
   --  Versao padrao FIM    
   -- --------------------    
*/     
  
   END --## 5    
  -- Se for pagamento de 'Arrasto-Boleto' ...    
  ELSE   
  IF (@LCC_TIPO_PAGAMENTO = 'Arrasto-Boleto')    
   BEGIN    
       
    DECLARE @QTD_PAGAMENTO NUMERIC(3)    
    DECLARE @LCC_DT_CREDITO_PG T_DATA    
       
    -- Verifica se ja existe um outro pagamento "real" para essa cobranca que teve o boleto arrastado    
    SELECT @QTD_PAGAMENTO = COUNT(*),    
     @LCC_DT_CREDITO_PG = MIN(CASE WHEN LC.TIPO_PAGAMENTO = 'Banco' THEN LC.DT_DEPOSITO ELSE LC.DT_CREDITO END)    
    FROM LY_LANC_CREDITO LC WITH (NOLOCK)    
    JOIN LY_ITEM_CRED IC WITH (NOLOCK) ON (LC.LANC_CRED = IC.LANC_CRED)    
    AND LC.TIPO_PAGAMENTO <> 'Arrasto-Boleto'  -- PAGAMENTOS QUE NAO SAO VALIDOS ENQUANTO NAO EXISTIR DE OUTRO TIPO    
    AND IC.COBRANCA = @ITC_COBRANCA    
       
    -- Se existe um pagamento "real" para essa cobranca    
    IF (@QTD_PAGAMENTO > 0)     
     BEGIN    
      -- A data contabil sera a maior entre a data de geracao e a de credito do pagamento "real"    
      SELECT @V_DT_CONTABIL = (CASE     
             WHEN (@ITC_DATA > @LCC_DT_CREDITO_PG) THEN @ITC_DATA    
             ELSE @LCC_DT_CREDITO_PG    
             END)    
     END    
    
   END    
  -- Se for pagamento via Cheque...    
  ELSE   
   IF (@LCC_TIPO_PAGAMENTO = 'Cheque')    
    BEGIN    
     -- Se foi marcado para ser valido somente depois da baixa ter sido confirmada...    
     IF @LCC_VALIDO_APOS_COMP = 'S'    
      BEGIN    
       -- A data contabil sera a maior entre a data de geracao e a data de baixa registrada (confirmada) no cheque    
       SELECT @V_DT_CONTABIL = (CASE     
              WHEN (@ITC_DATA > @CHQ_DT_BAIXA) THEN @ITC_DATA    
              ELSE @CHQ_DT_BAIXA    
              END)    
      END    
     -- Caso contrario...     
     ELSE    
      BEGIN    
       -- A data contabil sera a maior entre a data de geracao e a de deposito    
       SELECT @V_DT_CONTABIL = (CASE     
              WHEN (@ITC_DATA > ISNULL(@LCC_DT_DEPOSITO,@LCC_DT_CREDITO)) THEN @ITC_DATA    
          --           ELSE ISNULL(@LCC_DT_DEPOSITO,@LCC_DT_CREDITO)    --## Alterado em 29/03/2017 Raul - reunião com Ana Paula, Gregorio e Rose, onde pediram para alterar a data contabil apra ser considera a data de credito no lugar da data de deposito 
 
              ELSE ISNULL(@LCC_DT_CREDITO,@LCC_DT_DEPOSITO)   --## Alterado em 29/03/2017 Raul - reunião com Ana Paula, Gregorio e Rose, onde pediram para alterar a data contabil apra ser considera a data de credito no lugar da data de deposito  
              END)    
      END    
    END    
   -- Todos os outros casos...    
   ELSE    
    BEGIN    
    -- A data contabil sera a maior entre a data de geracao e a de credito    
    SELECT @V_DT_CONTABIL = CASE     
           WHEN (@ITC_DATA > @LCC_DT_CREDITO) THEN @ITC_DATA    
           ELSE @LCC_DT_CREDITO    
           END    
    END    
 END --## 6    
    
-------------------------------------------------------------------------    
-- Se for um registro da LY_CANDIDATO (PAGAMENTO)    
-------------------------------------------------------------------------    
IF @P_ENTIDADE = 'Ly_Candidato_PGTO'    
 BEGIN    
  DECLARE @CDT_BOLETO_DT_PAGAMENTO T_DATA    
      
  -- Busca dados do pagamento do candidato    
  SELECT @CDT_BOLETO_DT_PAGAMENTO = BOLETO_DT_PAGAMENTO    
  FROM LY_CANDIDATO WITH (NOLOCK)    
  WHERE CONCURSO = @P_ID1    
  AND CANDIDATO  = @P_ID2    
     
  -- A data contabil sera a data do pagamento    
  SELECT @V_DT_CONTABIL = @CDT_BOLETO_DT_PAGAMENTO    
 END    
     
-------------------------------------------------------------------------    
-- Se for um registro da LY_COBRANCA_ALT_VENC (Alteracao de vencimento)    
-------------------------------------------------------------------------    
IF @P_ENTIDADE = 'Ly_Cobranca_Alt_Venc'    
 BEGIN    
     
  DECLARE @COB_DATA_DE_GERACAO_CAV T_DATA    
  DECLARE @COB_ANO_CAV T_ANO    
  DECLARE @COB_MES_CAV T_MES    
  DECLARE @COB_DATA_DE_FATURAMENTO_CAV T_DATA    
  DECLARE @CAV_DATA_ALTERACAO DATETIME    
    
  -- Busca os dados da cobranca para calcular a data contabil    
  SELECT   
   @COB_DATA_DE_GERACAO_CAV = COB.DATA_DE_GERACAO,    
   @COB_ANO_CAV    = COB.ANO,    
   @COB_MES_CAV    = COB.MES,    
   @COB_DATA_DE_FATURAMENTO_CAV = COB.DATA_DE_FATURAMENTO,    
   @CAV_DATA_ALTERACAO   = CAV.DATA_ALTERACAO        
  FROM LY_COBRANCA_ALT_VENC CAV    
  JOIN LY_COBRANCA COB WITH (NOLOCK)   
   ON (CAV.COBRANCA = COB.COBRANCA)    
  WHERE CAV.ID = @P_ID1    
      
  DECLARE @CALC_DATA_REFERENCIA_CAV T_DATA    
      
  -- Calculando a data de referencia    
  SELECT @CALC_DATA_REFERENCIA_CAV = CONVERT(DATETIME, '01/' + LTRIM(STR(@COB_MES_CAV, 2)) + '/' + LTRIM(STR(@COB_ANO_CAV, 4)), 103)      
      
  -- A data contabil vai ser a maior entre a data de geracao, faturamento, referencia ou alteracao    
  SELECT @V_DT_CONTABIL = CONVERT(DATETIME, dbo.fnGreatest4(@CALC_DATA_REFERENCIA_CAV, @COB_DATA_DE_FATURAMENTO_CAV, @COB_DATA_DE_GERACAO_CAV, @CAV_DATA_ALTERACAO))      
     
 END    
     
 -------------------------------------------------------------------------    
 -- Retorna o valor calculado    
 -------------------------------------------------------------------------     
    
 -- Garante que a data contabil nao tem horas    
 SELECT @V_DT_CONTABIL = DATEDIFF(DAY, 0, @V_DT_CONTABIL)    
     
 -- Retorna o valor    
 RETURN @V_DT_CONTABIL    
    
END     