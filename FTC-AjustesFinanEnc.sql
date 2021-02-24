  DECLARE @cobranca	T_NUMERO
  DECLARE @aluno T_CODIGO

  DECLARE CEXPANSAO CURSOR FOR  
      select aluno from ly_lanc_debito d where codigo_lanc='FINAN' and ANO_REF=2017 and descricao like 'FINANCIAMENTO -%' 
      and exists (select 1 from ly_item_lanc where num_bolsa is not null and ano_ref_bolsa=2017  and encerr_processado = 'N' and aluno=d.aluno)
   
  -- Executando 
  OPEN CEXPANSAO  
    
  FETCH NEXT FROM CEXPANSAO INTO @aluno

  WHILE (@@FETCH_STATUS = 0)  
	BEGIN  
		update ly_item_lanc set encerr_processado='S' where aluno=@aluno and num_bolsa is not null and encerr_processado='N' and ano_ref_bolsa=2017 
		
		FETCH NEXT FROM CEXPANSAO INTO @aluno

	END
 
 CLOSE CEXPANSAO  
 DEALLOCATE CEXPANSAO  