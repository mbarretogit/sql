  DECLARE @cobranca	T_NUMERO

  DECLARE CEXPANSAO CURSOR FOR  
   select distinct c.cobranca from ly_item_lanc il1, ly_cobranca c where il1.cobranca=c.cobranca and encerr_processado='S' and estorno='S' and num_bolsa is not null
    and exists (select 1 from ly_item_lanc il2 where il2.cobranca=il1.cobranca and num_bolsa is not null and encerr_processado='N') order by c.cobranca
  
  -- Executando 
  OPEN CEXPANSAO  
    
  FETCH NEXT FROM CEXPANSAO INTO @cobranca

  WHILE (@@FETCH_STATUS = 0)  
	BEGIN  
		update ly_item_lanc set encerr_processado='S' where cobranca=@cobranca and num_bolsa is not null and encerr_processado='N'
		
		FETCH NEXT FROM CEXPANSAO INTO @cobranca

	END
 
 CLOSE CEXPANSAO  
 DEALLOCATE CEXPANSAO  