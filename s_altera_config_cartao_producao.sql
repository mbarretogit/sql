
CREATE PROCEDURE s_Altera_Config_Cartao

(

       @p_ID_PEDIDO_PGTO T_NUMERO,

       @p_id varchar(2000) output,

       @p_chave_id varchar(2000) output,

       @p_adquirente varchar(2000) output,

       @p_substitui char(1) output

)

AS

-- [INÍCIO] Customização - Não escreva código antes desta linha

     set @p_substitui = 'S'

   

     IF @p_adquirente = '2' 

         BEGIN     

          SET @p_id = '23'

          SET @p_chave_id = '67209779' 

         END 

      ELSE if @p_adquirente = '4' 

         BEGIN 

          SET @p_id = '22' 

          SET @p_chave_id = '13GTUnAR'

      END 

-- [FIM] Customização - Não escreva código após esta linha

 

