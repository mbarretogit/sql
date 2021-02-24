Select 

   --top 1          --<<<<<<<<<<<<<<<<<< retirar quando aplicar em produção <<<<<<<<<<<<<<<<<<<< 

   COD_EMPRESA 

  ,DATA_MULTA 

  ,COD_PESSOA 

  ,VALOR_MULTA 

  ,VALOR_DESCONTO 

  ,OBSERVACAO 

  ,NUM_TITULO 

  ,DATA_EMPRESTIMO 

  ,FLAG_TRANSPORTE 

  ,COD_BIBLIOTECA 

  ,COD_PESSOA_MOV 

  ,ltrim(rtrim(CONVERT(VARCHAR,titulo_livro))) as titulo_livro  --## AJUSTE PARA REMOVER OS ESPAÇOS ANTES E DEPOIS DO TITULO 

  ,ALUNO 

 From FTC_VW_EXPORTA_MULTA  

 Where 1 = 1  

 AND observacao  is not null   

 AND data_emprestimo is not null 

 and data_multa  is not null 

 Order by num_titulo, data_multa 