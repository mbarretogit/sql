USE LYCEUM
GO 

ALTER PROCEDURE s_Altera_Config_Cartao

(

       @p_ID_PEDIDO_PGTO T_NUMERO,

       @p_id varchar(2000) output,

       @p_chave_id varchar(2000) output,

       @p_adquirente varchar(2000) output,

       @p_substitui char(1) output

)

AS

-- [IN�CIO] Customiza��o - N�o escreva c�digo antes desta linha

     set @p_substitui = 'S'

   

     IF @p_adquirente = 'Rede' 

         BEGIN     

          SET @p_id = '19'

          SET @p_chave_id = '67209779' 

         END 

      ELSE if @p_adquirente = 'Cielo' 

         BEGIN 

          SET @p_id = '15' 

          SET @p_chave_id = '13GTUnAR'

      END 

-- [FIM] Customiza��o - N�o escreva c�digo ap�s esta linha

 

 