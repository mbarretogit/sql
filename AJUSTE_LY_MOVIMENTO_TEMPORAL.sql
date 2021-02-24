USE LYCEUMA
GO

--SANEAMENTO NECESSÁRIO EM BASE TESTE PARA CORRIGIR O INSERT 
--DELETE MT FROM LY_MOVIMENTO_TEMPORAL MT
--JOIN LY_ITEM_LANC IL ON IL.COBRANCA = MT.ID1 AND IL.ITEMCOBRANCA = MT.ID2
--WHERE DT_CAR_APROP > '2018-11-12'
--AND IL.CODIGO_LANC = 'SSI' AND IL.DT_ENVIO_CONTAB IS NULL


--CRIACAO DA TABELA TEMPORARIA
CREATE TABLE #TEMP_MOV (
	DATA DATETIME,
	ENTIDADE VARCHAR(20),
	ID1 VARCHAR(20),
	ID2 VARCHAR(20),
	ID3 VARCHAR(20),
	ID4 VARCHAR(20),
	ID5 VARCHAR(20),
	DT_ENVIO_CONTAB DATETIME,
	LOTE_CONTABIL BIGINT,
	DT_CAR_APROP DATETIME,
	DT_CONTABIL DATETIME

)


--DETERMINANDO POSSIVEIS LANÇAMENTOS SSI QUE IRÃO PARA A LY_MOVIMENTO_TEMPORAL
INSERT INTO #TEMP_MOV
SELECT	IL.DATA AS data
		,'Ly_Item_Lanc' AS entidade
		,IL.COBRANCA AS id1
		,IL.ITEMCOBRANCA AS id2
		,NULL AS id3
		,NULL AS id4
		,NULL AS id5
		,NULL AS dt_envio_contab
		,NULL AS lote_contabil
		,GETDATE() AS dt_car_aprop
		,dbo.fnGetDtContabil('Ly_Item_Lanc',IL.COBRANCA,IL.ITEMCOBRANCA,NULL,NULL,NULL) as dt_contabil
FROM LY_ITEM_LANC IL 
WHERE IL.CODIGO_LANC = 'SSI' AND IL.DT_ENVIO_CONTAB IS NULL


--REMOVER LANÇAMENTOS QUE TENHAM DT_CONTABIL NULL
DELETE FROM #TEMP_MOV WHERE DT_CONTABIL IS NULL

--INSERIR NA LY_MOVIMENTO__TEMPORAL
 -- DECLARE	@p_data DATETIME, @p_entidade VARCHAR(20), @p_id1 VARCHAR(20), @p_id2 VARCHAR(20), @p_id3 VARCHAR(20)
	--	,	@p_ID4 VARCHAR(20), @p_id5 VARCHAR(20), @p_dt_envio_contab DATETIME, @p_lote_contabil BIGINT, @p_dt_car_aprop DATETIME, @p_dt_contabil DATETIME	
 -- DECLARE cursor1 CURSOR FOR  
 -- SELECT DATA, ENTIDADE, ID1, ID2, ID3, ID4, ID5, DT_ENVIO_CONTAB, LOTE_CONTABIL, DT_CAR_APROP, DT_CONTABIL  FROM #TEMP_MOV  
  
 -- OPEN cursor1  
  
	--FETCH NEXT FROM cursor1 INTO @p_data, @p_entidade, @p_id1, @p_id2, @p_id3, @p_id4, @p_id5, @p_dt_envio_contab, @p_lote_contabil, @p_dt_car_aprop, @p_dt_contabil
  
	--WHILE @@FETCH_STATUS = 0  
	--BEGIN  
  
	--	INSERT INTO ly_movimento_temporal([data], [entidade], [id1], [id2], [id3], [id4],[id5], [dt_envio_contab], [lote_contabil], [dt_car_aprop], [dt_contabil])  
	--	VALUES(@p_data, @p_entidade, @p_id1, @p_id2, @p_id3, @p_id4, @p_id5, @p_dt_envio_contab, @p_lote_contabil, @p_dt_car_aprop, @p_dt_contabil)
   
  
	--	FETCH NEXT FROM cursor1 INTO @p_data, @p_entidade, @p_id1, @p_id2, @p_id3, @p_id4, @p_id5, @p_dt_envio_contab, @p_lote_contabil, @p_dt_car_aprop, @p_dt_contabil 
	--END  
 -- CLOSE cursor1  
  
 -- DEALLOCATE cursor1  

 --INSERIR NA LY_MOVIMENTO__TEMPORAL
INSERT INTO ly_movimento_temporal([data], [entidade], [id1], [id2], [id3], [id4],[id5], [dt_envio_contab], [lote_contabil], [dt_car_aprop], [dt_contabil])  
SELECT DATA, ENTIDADE, ID1, ID2, ID3, ID4, ID5, DT_ENVIO_CONTAB, LOTE_CONTABIL, DT_CAR_APROP, DT_CONTABIL  
FROM #TEMP_MOV T WHERE NOT EXISTS (SELECT TOP 1 1 FROM LY_MOVIMENTO_TEMPORAL WHERE ENTIDADE = T.ENTIDADE AND ID1 = T.ID1 AND ID2 = T.ID2)   


--EXECUTAR ARGYROS
EXEC FTC_EXECUTA_ARGYROS