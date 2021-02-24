USE LYCEUM
GO

update ly_item_lanc set encerr_processado='S' where cobranca in (4470705,4470706,4470707,4470709,4470710) and itemcobranca=14
GO
 

update ly_ITEM_LANC set encerr_processado='S' where cobranca in (4608174,4755447) and num_bolsa is not null 
GO