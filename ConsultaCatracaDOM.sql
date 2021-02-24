SELECT DISTINCT (CASE WHEN  P.CPF = '' OR P.CPF IS NULL OR P.CPF = '00000000000'
    THEN
    CASE WHEN C.TIPO = 'ENS BASICO' 
     THEN '88' + CONVERT (VARCHAR (20),P.PESSOA)     -- Coloquei 88 na frente do código de matricula para identificar quando o aluno for do ensino basico.
     ELSE '77' + CONVERT (VARCHAR (20),P.PESSOA) END -- Coloquei 77 na frente do código de matricula para identificar quando o aluno for da Faculdade FTC.
     ELSE 
    CASE WHEN C.TIPO = 'ENS BASICO' 
     THEN '88' + CONVERT (VARCHAR (20),P.CPF)   -- Coloquei 88 na frente do código de matricula para identificar quando o aluno for do ensino basico.
     ELSE '77' + CONVERT (VARCHAR (20),P.CPF)    END -- Coloquei 77 na frente do código de matricula para identificar quando o aluno for da Faculdade FTC.
   END) AS ALUNO , 
  A.NOME_COMPL, 
    '10' AS SITUACAO,  
     (CASE WHEN P.CPF = '' OR P.CPF IS NULL 
     THEN '00000000000' 
   ELSE P.CPF END) AS CPF, 
  P.RG_NUM,  
  GETDATE () AS DATAINTEGRACAO ,
  'N' AS INTEGRADO, 
  A.UNIDADE_FISICA,
  A.ALUNO
 FROM LY_ALUNO A
  INNER JOIN LY_PESSOA P ON P.PESSOA = A.PESSOA 
  INNER JOIN LY_CURSO  C ON C.CURSO  = A.CURSO 
 WHERE SIT_ALUNO = 'ATIVO' 
  AND A.UNIDADE_ENSINO IN ('50','51','52') -- Todas unidades DOM