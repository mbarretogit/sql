IF OBJECT_ID('FTC_TR_MATRICULA_ESTORNA_COBRANCA_Update') IS NOT NULL
DROP TRIGGER FTC_TR_MATRICULA_ESTORNA_COBRANCA_Update
GO

-- EP PROGRAMADO  
CREATE TRIGGER FTC_TR_MATRICULA_ESTORNA_COBRANCA_Update
ON LY_MATRICULA  
AFTER UPDATE  
AS  
BEGIN  
    DECLARE 
	  @V_ANO              T_ANO 
	, @V_PERIODO          T_SEMESTRE2
	, @V_ALUNO            T_CODIGO
	, @V_CONTADOR         T_NUMERO_PEQUENO
	, @V_COBRANCA         T_NUMERO
	, @V_COBRANCA_SEP     VARCHAR(1)
	, @V_DISCIPLINA       T_CODIGO
	, @V_SIT_MATRICULA    VARCHAR(20)
	, @V_LANC_DEB         INT
	, @V_LOOP             INT
	, @V_TRANCADO_CALCULO VARCHAR(1)  
              
    SET NOCOUNT ON  
	-- ----------------------------------------------------------------------------------------------------  
	-- BUSCA OS DADOS DO CONTRATO DO FIES  
	-- ----------------------------------------------------------------------------------------------------  
	SELECT  @V_ANO          = ANO,  
			@V_PERIODO      = SEMESTRE,  
			@V_ALUNO        = ALUNO,  
			@V_COBRANCA_SEP = COBRANCA_SEP,  
			@V_DISCIPLINA   = DISCIPLINA,  
			@V_SIT_MATRICULA = SIT_MATRICULA,  
			@V_LANC_DEB = LANC_DEB  
	FROM INSERTED  
  
     -- ----------------------------------------------------------------------------------------------------  
    --CRIA UMA TABELA AUXILIAR COM AS COBRANÇAS QUE DEVEM SER ESTORNADAS  
    -- -----------------------------------------------------------------------------------------------------  
	IF @V_SIT_MATRICULA = 'Cancelado'  
	BEGIN  

		-- CALCULO E RECÁLCULO DA DÍVIDA  
		DELETE ZZCRO_ERROS WHERE SPID = @@SPID  

		CREATE TABLE #TBL_LOOP (ID INT, COBRANCA INT, ANO INT, MES INT)  
  
		INSERT INTO #TBL_LOOP  
		SELECT DISTINCT ROW_NUMBER()OVER(ORDER BY C.COBRANCA) ID, C.COBRANCA, C.ANO, C.MES  
		FROM LY_COBRANCA C   
		WHERE C.ALUNO = @V_ALUNO  
		AND C.DATA_DE_VENCIMENTO >= GETDATE()  
		AND NOT(C.ANO = DATEPART(YYYY,GETDATE()) AND C.MES = DATEPART(MM,GETDATE()))  
		AND (C.ESTORNO IS NULL OR C.ESTORNO = 'N')  
		AND C.NUM_COBRANCA = 1  
		AND NOT EXISTS ( SELECT TOP 1 1 FROM LY_ITEM_CRED IC WHERE IC.COBRANCA = C.COBRANCA )                                   -- NÃO EXISTA PAGAMENTOS  
		AND NOT EXISTS ( SELECT TOP 1 1 FROM LY_ITEM_LANC IL WHERE IL.COBRANCA = C.COBRANCA AND IL.COBRANCA_ORIG IS NOT NULL)   -- COBRANÇA NÃO PODE TER RESTITUIÇÃO  
		AND NOT EXISTS ( SELECT TOP 1 1 FROM LY_ITEM_LANC IL WHERE IL.COBRANCA = C.COBRANCA AND IL.ACORDO IS NOT NULL)          -- COBRANÇA NÃO PODE TER SIDO ACORDADA  
		AND EXISTS ( SELECT TOP 1 1 FROM LY_ITEM_LANC IL WHERE IL.COBRANCA = C.COBRANCA AND IL.LANC_DEB = @V_LANC_DEB )  
		AND NOT EXISTS ( SELECT TOP 1 1 FROM LY_ITEM_LANC IL WHERE IL.COBRANCA = C.COBRANCA AND IL.DT_ENVIO_CONTAB IS NOT NULL) 
		  
		-- ----------------------------------------------------------------------------------------------------  
		-- ESTORNA AS COBRANCAS ENCONTRADAS  
		-- ----------------------------------------------------------------------------------------------------  
		DELETE ZZCRO_ERROS WHERE SPID = @@SPID  
		SELECT @V_LOOP = MIN(ID) FROM #TBL_LOOP  
		WHILE @V_LOOP IS NOT NULL  
		BEGIN  
			SELECT @V_COBRANCA = COBRANCA FROM #TBL_LOOP WHERE ID = @V_LOOP  
			EXEC ESTORNA_COBRANCA @V_COBRANCA  
			SELECT @V_LOOP = MIN(ID) FROM #TBL_LOOP WHERE ID > @V_LOOP  
		END   
  
	END  
	SET NOCOUNT OFF  
END  
GO
