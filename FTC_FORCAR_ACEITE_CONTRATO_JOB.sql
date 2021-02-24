/*                    
CRIADO POR:  -                    
CRIADO EM:  -                    
ATUALIZADO POR: YURI GUIMARÃES                    
ATUALIZADO EM: 20/04/2020        
ATUALIZADO POR: IGOR CAMPOS        
ATUALIZADO EM: 23/07/2020       
ATUALIZADO POR: YURI GUIMARÃES                    
ATUALIZADO EM: 12/08/2020        
OBS.: ERRO NA EXECUÇÃO        
Executed as user: NT SERVICE\SQLSERVERAGENT. The DELETE statement conflicted with the REFERENCE constraint "FK_LY_CONTR_ALU_IMG_LY_CONTR".         
The conflict occurred in database "LYCEUM", table "dbo.LY_CONTRATO_ALUNO_IMG", column 'ID_CONTRATO_ALUNO'. [SQLSTATE 23000] (Error 547)          
The statement has been terminated. [SQLSTATE 01000] (Error 3621).  The step failed.        
        
USO:   EXEC LYCEUMINTEGRACAO..FTC_FORCAR_ACEITE_CONTRATO_JOB            
EXEMPLO:  EXEC LYCEUMINTEGRACAO..FTC_FORCAR_ACEITE_CONTRATO_JOB             
RETORNO:  SEM RETORNO - COLOCA COMO CONTRATO REMOVIDO PARA TODOS OS ALUNOS SEM CONTRATO ACEITO            
*/                
            
-- exec FTC_FORCAR_ACEITE_CONTRATO_JOB    
    
ALTER PROCEDURE FTC_FORCAR_ACEITE_CONTRATO_JOB            
AS            
BEGIN            
 DECLARE             
  @ANO INT = YEAR(GETDATE()),            
  @SEMESTRE INT = CASE WHEN MONTH(GETDATE()) < 7 THEN 1 ELSE 2 END            
 ---------------------------------------------            
 --REMOVE ALUNOS QUE NÃO ACEITARAM CONTRATOS--            
 ---------------------------------------------            
         
INSERT INTO LOG_FTC.dbo.LY_CONTRATO_ALUNO_IMG (ID_CONTRATO_ALUNO,IMAGEM,CODIGO_HASH,EXTENSAO_BIN,IMAGEM_BIN)        
SELECT ID_CONTRATO_ALUNO,IMAGEM,CODIGO_HASH,EXTENSAO_BIN,IMAGEM_BIN FROM lyceum.dbo.LY_CONTRATO_ALUNO_IMG l        
WHERE EXISTS ( SELECT TOP 1 1 FROM LYCEUM..LY_CONTRATO_ALUNO lca WHERE lca.ANO = @ANO            
AND lca.PERIODO = @SEMESTRE and lca.CONTRATO_ACEITO = 'N' and l.ID_CONTRATO_ALUNO = lca.ID_CONTRATO_ALUNO )        
         
delete l FROM lyceum.dbo.LY_CONTRATO_ALUNO_IMG l        
WHERE EXISTS ( SELECT TOP 1 1 FROM LYCEUM..LY_CONTRATO_ALUNO lca WHERE lca.ANO = @ANO            
AND lca.PERIODO = @SEMESTRE and lca.CONTRATO_ACEITO = 'N' and l.ID_CONTRATO_ALUNO = lca.ID_CONTRATO_ALUNO )        
        
----------------------------------------------------------------------------------------------------------        
       
delete lca            
FROM            
LYCEUM..LY_CONTRATO_ALUNO lca            
WHERE             
lca.ANO = @ANO            
AND lca.PERIODO = @SEMESTRE            
and lca.CONTRATO_ACEITO = 'N'            
        
 --------------------            
 ----MATRICULADOS----            
 --------------------                 
 INSERT INTO LYCEUM..LY_CONTRATO_REMOVIDO (ALUNO, ANO, PERIODO, CHAVE, CONTRATO_ACEITO, DATA_ACEITE, OFERTA_DE_CURSO)            
 SELECT DISTINCT LA.ALUNO,@ANO,@SEMESTRE, (SELECT MAX(CHAVE)+1 FROM LYCEUM..LY_CONTRATO_REMOVIDO),'S',GETDATE(),NULL            
 FROM            
  LYCEUM..LY_ALUNO la INNER JOIN LYCEUM..LY_MATRICULA lm ON la.ALUNO = lm.ALUNO            
  INNER JOIN LYCEUM..LY_CURSO LC ON LC.CURSO = LA.CURSO            
  INNER JOIN LYCEUM..LY_UNIDADE_ENSINO lue ON LC.FACULDADE = lue.UNIDADE_ENS            
 WHERE            
  lm.ANO = @ANO            
  AND lm.SEMESTRE = @SEMESTRE            
  AND (lue.NOME_ABREV LIKE 'OTE%' OR lue.NOME_ABREV LIKE 'FTC%' OR lue.NOME_ABREV LIKE 'UNESUL%' OR lue.NOME_ABREV LIKE 'IDEA%')            
  AND NOT EXISTS (            
   SELECT *            
   FROM            
    LYCEUM..LY_CONTRATO_ALUNO lca            
   WHERE lca.ALUNO = la.ALUNO            
    AND lca.ANO = lm.ANO            
    AND lca.PERIODO = lm.SEMESTRE            
  )            
  AND NOT EXISTS (            
   SELECT TOP 1 1            
   FROM            
    LYCEUM..LY_CONTRATO_REMOVIDO lcr             
   WHERE lcr.ALUNO = la.ALUNO            
    AND lcr.ANO = lm.ANO            
    AND lcr.PERIODO = lm.SEMESTRE            
  )    
  -- adicionado ára não forcar o aceite do aluno ate a implementaão do banco money plus techne    
   AND EXISTS (    
  select top 1 1     
  from lyceum..LY_ITEM_LANC l
  INNER JOIN LYCEUM..LY_LANC_DEBITO LD ON LD.LANC_DEB = L.LANC_DEB
  INNER JOIN LYCEUM..LY_COBRANCA C ON C.COBRANCA = L.COBRANCA
  where 1 = 1 
  and l.boleto in ( select BOLETO from lyceum..ly_boleto WHERE BANCO <> '274' )
  AND C.NUM_COBRANCA = 1
  and l.ALUNO = la.ALUNO        
  AND LD.ANO_REF = @ANO
  AND LD.PERIODO_REF = @SEMESTRE
  AND EXISTS (
	  select top 1 1     
	  from lyceum..LY_ITEM_LANC l
	  INNER JOIN LYCEUM..LY_LANC_DEBITO LD ON LD.LANC_DEB = L.LANC_DEB
	  INNER JOIN LYCEUM..LY_COBRANCA C ON C.COBRANCA = L.COBRANCA
	  where l.boleto in ( select BOLETO from lyceum..ly_boleto WHERE BANCO = '274' )
	  AND C.NUM_COBRANCA = 1
	  and l.ALUNO = la.ALUNO 
	  AND LD.ANO_REF = @ANO
	  AND LD.PERIODO_REF = @SEMESTRE
	)
 )    
            
 ------------------------            
 ----PRE-MATRICULADOS----            
 ------------------------            
 INSERT INTO LYCEUM..LY_CONTRATO_REMOVIDO (ALUNO, ANO, PERIODO, CHAVE, CONTRATO_ACEITO, DATA_ACEITE, OFERTA_DE_CURSO)            
 SELECT DISTINCT LA.ALUNO,@ANO,@SEMESTRE, (SELECT MAX(CHAVE)+1 FROM LYCEUM..LY_CONTRATO_REMOVIDO),'S',GETDATE(),NULL            
 FROM            
  LYCEUM..LY_ALUNO la             
  INNER JOIN LYCEUM..LY_PRE_MATRICULA PM ON la.ALUNO = PM.ALUNO            
  INNER JOIN LYCEUM..LY_CURSO LC ON LC.CURSO = LA.CURSO            
  INNER JOIN LYCEUM..LY_UNIDADE_ENSINO lue ON LC.FACULDADE = lue.UNIDADE_ENS           
  --VERIFICA ALUNO DE SUGESTÃO      
  /*OUTER APPLY(      
  SELECT TOP 1 1 AS SUGESTAO       
  FROM LYCEUMINTEGRACAO..FTC_SUGESTAO_PRE_MAT SP      
  WHERE      
   SP.ALUNO = PM.ALUNO      
   AND SP.ANO = PM.ANO      
   AND SP.SEMESTRE = PM.SEMESTRE      
   AND SP.ENVIADO IS NOT NULL      
    ) S*/      
 --VERIFICA SE O COORDENADOR JÁ DEU O OK      
 OUTER APPLY(      
  SELECT TOP 1 1 AS CONFIRMADO       
  FROM LYCEUMINTEGRACAO..REMATRICULA SP --MODIFICADA PARA A NOVA TABELA DE CONTROLE DE DE REMATÓCULA EM 28/01/2021  
  WHERE      
   SP.ALUNO = PM.ALUNO      
   AND SP.ANO = PM.ANO      
   AND SP.SEMESTRE = PM.SEMESTRE      
    ) V      
 WHERE  1=1          
 -- AND PM.ALUNO = @ALUNO
  AND PM.ANO = @ANO            
  AND PM.SEMESTRE = @SEMESTRE  AND (lue.NOME_ABREV LIKE 'OTE%' OR lue.NOME_ABREV LIKE 'FTC%' OR lue.NOME_ABREV LIKE 'UNESUL%' OR lue.NOME_ABREV LIKE 'IDEA%')            
  AND NOT EXISTS (            
   SELECT *            
   FROM            
    LYCEUM..LY_CONTRATO_ALUNO lca            
   WHERE lca.ALUNO = la.ALUNO            
    AND lca.ANO = PM.ANO            
    AND lca.PERIODO = PM.SEMESTRE            
  )            
  AND NOT EXISTS (            
   SELECT *            
   FROM            
    LYCEUM..LY_CONTRATO_REMOVIDO lcr             
   WHERE lcr.ALUNO = la.ALUNO            
    AND lcr.ANO = PM.ANO            
    AND lcr.PERIODO = PM.SEMESTRE            
  )          
  --VERIFICA PAGAMENTO REGRA DO FINANCEIRO          
  AND ISNULL(LYCEUMINTEGRACAO.DBO.FN_FTC_ALUNO_PAGO(PM.ALUNO,PM.LANC_DEB),0) = 1           
      
  --OU É CALOURO OU É VETERANO CONFIRMADO PELO COORDENADOR      
  AND ((LA.ANO_INGRESSO = PM.ANO AND LA.SEM_INGRESSO = PM.SEMESTRE) OR (V.CONFIRMADO IS NOT NULL) OR (LC.CURSO IN ('722','507')))      
      
  --REMOVE ALUNOS DE SUGESTÃO      
  --AND ((S.SUGESTAO IS NULL) OR (S.SUGESTAO IS NOT NULL AND V.SUGESTAO IS NOT NULL))    
      
  -- adicionado ára não forcar o aceite do aluno ate a implementaão do banco money plus techne    
   AND EXISTS (    
  select top 1 1     
  from lyceum..LY_ITEM_LANC l
  INNER JOIN LYCEUM..LY_LANC_DEBITO LD ON LD.LANC_DEB = L.LANC_DEB
  INNER JOIN LYCEUM..LY_COBRANCA C ON C.COBRANCA = L.COBRANCA
  where 1 = 1 
  and l.boleto in ( select BOLETO from lyceum..ly_boleto WHERE BANCO <> '274' )
  AND C.NUM_COBRANCA = 1
  and l.ALUNO = la.ALUNO        
  AND LD.ANO_REF = PM.ANO 
  AND LD.PERIODO_REF = PM.SEMESTRE
  AND EXISTS (
	  select top 1 1     
	  from lyceum..LY_ITEM_LANC l
	  INNER JOIN LYCEUM..LY_LANC_DEBITO LD ON LD.LANC_DEB = L.LANC_DEB
	  INNER JOIN LYCEUM..LY_COBRANCA C ON C.COBRANCA = L.COBRANCA
	  where l.boleto in ( select BOLETO from lyceum..ly_boleto WHERE BANCO = '274' )
	  AND C.NUM_COBRANCA = 1
	  and l.ALUNO = la.ALUNO 
	  AND LD.ANO_REF = PM.ANO 
	  AND LD.PERIODO_REF = PM.SEMESTRE
	)
 )      
            
END