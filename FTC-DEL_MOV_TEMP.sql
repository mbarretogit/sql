DECLARE @erro_mov T_NUMERO

DECLARE C_DEL_MOV_TEMP CURSOR FOR  
  SELECT erro_mov   
  FROM Ly_Erro_Movimento 
  WHERE Valor_Pago = 0 

  
OPEN C_DEL_MOV_TEMP  
FETCH NEXT FROM C_DEL_MOV_TEMP INTO @erro_mov 
   
WHILE (@@FETCH_STATUS = 0)        
 BEGIN
	DELETE FROM Ly_Movimento_Temporal WHERE entidade='Ly_Erro_Movimento' and id1=convert(varchar,@erro_mov)
	FETCH NEXT FROM C_DEL_MOV_TEMP INTO @erro_mov 
 END	
 
CLOSE C_DEL_MOV_TEMP        
DEALLOCATE C_DEL_MOV_TEMP     