  
select   DISTINCT --acrescentado por Miguel pois plano de pagamento é por periodo letivo. 19/10/2016
  
 CONVERT(VARCHAR,CHE.BANCO)                           as[BANCO],  
 CONVERT(VARCHAR,CHE.AGENCIA)                         as[AGENCIA],  
 CONVERT(VARCHAR,CHE.CONTA_BANCO)                     as[CONTA_BANCO],  
 CONVERT(VARCHAR,CHE.SERIE)                           as[SERIE],  
 CONVERT(VARCHAR,CHE.NUMERO)                          as[NUMERO],  
 CONVERT(VARCHAR,CHE.VALOR)                           as[VALOR],  
 CONVERT(VARCHAR,CHE.VALOR_DESC)                      as[VALOR_DESC],  
   CONVERT(VARCHAR,CHE.DT_RECEB,103)                  as[DATA_RECEB],  
 CONVERT(VARCHAR,CHE.DT_PREV_DEP,103)                 as[DATA_PREV_DEPOSITO],     
 ISNULL(CONVERT(VARCHAR,CHE.DT_DEPOSITO,103),'')      as[DATA_DEPOSITO],  
 ISNULL(CONVERT(VARCHAR,CHE.DT_DEVOLUCAO1,103),'')    as[DATA_DEVOLUCAO_1],  
 ISNULL(CONVERT(VARCHAR,CHE.DT_DEVOLUCAO2,103),'')    as[DATA_DEVOLUCAO_2],  
 ISNULL(CONVERT(VARCHAR,CHE.DT_REAPRES,103),'')       as[DATA_REPRESENTACAO],  
 ISNULL(CONVERT(VARCHAR,CHE.DT_BAIXA,103),'')         as[DATA_BAIXA],  
 ISNULL(CONVERT(VARCHAR,CHE.DT_CANC,103),'')          as[DATA_CANCELAMENTO],  
 ISNULL(CONVERT(VARCHAR,CHE.DATA_CUSTODIA,103),'')    as[DATA_CUSTODIA],  
 CONVERT(VARCHAR,CHE.ANO)                             as[ANO],  
 CONVERT(VARCHAR,CHE.MES)							  as[MES],  
 CONVERT(VARCHAR,ALU.ALUNO)                           as[ALUNO],  
 CONVERT(VARCHAR,ALU.NOME_COMPL)                      as[NOME_COMPLETO],  
 CONVERT(VARCHAR,CHE.TITULAR)                         as[TITULAR],  
 CONVERT(VARCHAR,RESP.RESP)                           as[RESP_FINANCEIRO],  
 CONVERT(VARCHAR,CHE.CPF_TITULAR)                     as[CPF_TITULAR],  
 CONVERT(VARCHAR,CHE.CGC_TITULAR)                     as[CNPJ_TITULAR],  
 CONVERT(VARCHAR,ALU.UNIDADE_FISICA)                  as[UNIDADE_FISICA],  
 CONVERT(VARCHAR,CUR.FACULDADE)                       as[UNIDADE_ENSINO]  
   
 --tabela de cadastro de cheques  
  from LY_CHEQUES CHE  
  
      --tabela de responsavel financeiro  
   JOIN LY_RESP_FINAN RESP  
   ON RESP.RESP = CHE.RESP  
  
   --tabela de Plano_Pagamento_Periodo  
      JOIN LY_PLANO_PGTO_PERIODO PPP  
      ON PPP.RESP = CHE.RESP  
     
   --tabela de aluno  
      JOIN LY_ALUNO ALU  
      ON ALU.ALUNO = PPP.ALUNO  
  
   --tabela de curso  
   JOIN LY_CURSO CUR  
   ON ALU.CURSO = CUR.CURSO
  
where      
       CUR.FACULDADE = '04' -- unidade de ensino  --alterado para CUR.FACULDADE do curso pois alguns alunos nao possuem cadastro de unidade no cadastro do aluno (ly_aluno)
       and CHE.DT_RECEB >= '2016-10-18' -- data de recebimento inicial  
    and CHE.DT_RECEB <= '2016-10-18' -- data de recebimento final  
  