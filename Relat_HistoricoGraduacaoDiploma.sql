Relat_HistoricoGraduacaoDiploma

/*              
CRIADO POR:  TECHNE              
CRIADO EM:  -              
ATUALIZADO POR: YURI GUIMARÃES              
ATUALIZADO EM: 16/09/2020  
USO:   EXEC Relat_HistoricoGraduacaoDiploma <UNIDADE_ENSINO,UNIDADE_FISICA,CURSO,TURNO,CURRICULO,SERIE,SIT_MATRICULA,DATA_CONCLUSAO_INICIO,DATA_CONCLUSAO_TERMINO,              
              ASSINATURA_PRIMEIRA,ASSINATURA_SEGUNDA,ANO_INGRESSO,PER_INGRESSO,ANO_CONCL,PER_CONCL,ALUNO,EXIBE_REPROVADAS>              
EXEMPLO:  EXEC Relat_HistoricoGraduacaoDiploma null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,'172040998','S','S'                
RETORNO:  DADOS DO HISTÓRICO DO ALUNO PARA EMITIR O DIPLOMA            
*/                
                  
                 
CREATE PROCEDURE dbo.Relat_HistoricoGraduacaoDiploma (                               
    @P_UNIDADE_ENSINO                   AS T_CODIGO         = null                              
  , @P_UNIDADE_FISICA                   AS T_CODIGO         = null                              
  , @P_CURSO                            AS T_CODIGO         = null                              
  , @P_TURNO                            AS T_CODIGO         = null                              
  , @P_CURRICULO                        AS T_CODIGO         = null                              
  , @P_SERIE                            AS T_NUMERO_PEQUENO = null                              
  , @P_SIT_MATRICULA                    AS VARCHAR(50)      = null                              
  , @P_DATA_CONCLUSAO_INICIO            AS DATETIME         = null                              
  , @P_DATA_CONCLUSAO_TERMINO           AS DATETIME         = null                              
  , @P_ASSINATURA_PRIMEIRA              AS VARCHAR(50)      = null                              
  , @P_ASSINATURA_SEGUNDA               AS VARCHAR(50)      = null                              
  , @P_ANO_INGRESSO                     AS T_ANO            = null                              
  , @P_PER_INGRESSO                     AS T_SEMESTRE2      = null                              
  , @P_ANO_CONCL                        AS T_ANO            = null                              
  , @P_PER_CONCL                        AS T_SIT_ALUNO      = null  
  , @P_ALUNO                            AS VARCHAR(MAX)     = null                         
  , @P_EXIBE_REPROVADAS                 AS VARCHAR(1)       = 'S'                              
  , @P_EXIBE_PENDENTES                  AS VARCHAR(1)       = 'S'                              
)                              
AS                              
BEGIN                               
                    
SET @P_EXIBE_REPROVADAS = 'S'                    
SET @P_EXIBE_PENDENTES = 'S'                    
                              
SET NOCOUNT ON                                  
-- -------------------------------------------------------------------                                                  
-- 1) DECLARAÇÃO DE VARIÁVEIS INTERNAS                                                  
-- -------------------------------------------------------------------                                                  
DECLARE @v_ID_LOOP    INT                                                  
DECLARE @v_CURSO      T_CODIGO                                                  
DECLARE @v_TURNO      T_CODIGO                                                   
DECLARE @v_CURRICULO  T_CODIGO                                                  
DECLARE @v_DISCIPLINA T_CODIGO                                                  
DECLARE @v_ALUNO      T_CODIGO                                                  
DECLARE @v_ID         INT                                                  
DECLARE @v_QTD        INT                                                  
DECLARE @v_QTD_AUX    INT                                                  
DECLARE @v_VERIFICA   INT                             
                        
                          
SET @P_EXIBE_REPROVADAS = 'S'                    
SET @P_EXIBE_PENDENTES = 'S'                        
    -- -------------------------------------------------------------------                                                  
    -- 2) CRIA UMA TABELA AUXILIAR PARA GUARDAR OS DADOS                                                  
    -- -------------------------------------------------------------------                                                  
 DECLARE @TBL_HIST TABLE (                                                  
        UNID_RESP             VARCHAR(20) COLLATE Latin1_General_CI_AI                                               
      , UNID_FIS              VARCHAR(20) COLLATE Latin1_General_CI_AI                              
      , TIPO                  VARCHAR(20) COLLATE Latin1_General_CI_AI                                                   
      , MODALIDADE            VARCHAR(20) COLLATE Latin1_General_CI_AI                                                   
      , CURSO                 VARCHAR(20) COLLATE Latin1_General_CI_AI                                                   
      , TURNO                 VARCHAR(20) COLLATE Latin1_General_CI_AI                                                   
      , CURRICULO             VARCHAR(20) COLLATE Latin1_General_CI_AI                                                   
      , PESSOA                NUMERIC(10,0)            
      , ALUNO                 VARCHAR(20) COLLATE Latin1_General_CI_AI                              
      , ORIGEM                VARCHAR(50) COLLATE Latin1_General_CI_AI                                                   
      , ANO                   NUMERIC(4,0)            
      , PERIODO               NUMERIC(2,0)            
      , SERIE_ALUNO           NUMERIC(3,0)                                                  
      , SERIE_IDEAL           NUMERIC(3,0)                                                  
      , SERIE                 NUMERIC(3,0)                                                  
      , DISCIPLINA            VARCHAR(20)    COLLATE Latin1_General_CI_AI                              
      , NOTA_FINAL            VARCHAR(200)   COLLATE Latin1_General_CI_AI                                                
      , PERC_PRESENCA         DECIMAL(5,4)                              
      , SITUACAO              VARCHAR(20)    COLLATE Latin1_General_CI_AI                              
      , CRED_DISC             DECIMAL(10,2)                                                   
      , HORAS_AULA_DISC       DECIMAL(10,2)                                
      , ESTAGIO               VARCHAR(1)     COLLATE Latin1_General_CI_AI                              
      , CRED_HIST             DECIMAL(10,2)                                                  
      , HORAS_AULA_HIST       DECIMAL(10,2)                                                   
      , GRUPO_ELETIVA         VARCHAR(20)    COLLATE Latin1_General_CI_AI                              
      , SIT_DETALHE           VARCHAR(50)    COLLATE Latin1_General_CI_AI                                                   
      , DISC_DA_GRADE         VARCHAR(1)     COLLATE Latin1_General_CI_AI                                                   
      , CURSOU_EQUIV          VARCHAR(1)     COLLATE Latin1_General_CI_AI                                                   
      , PENDENTE              VARCHAR(1)     COLLATE Latin1_General_CI_AI                                                   
      , FORMULA_EQUIV         VARCHAR(2000)  COLLATE Latin1_General_CI_AI                                                   
      , ID_EQUIV              INT                                              
    )                                             
                                 
 -- -------------------------------------------------------------------                                                  
    -- 3) CRIA UMA TABELA AUXILIAR COM AS DISCIPLINAS QUE SOBRARAM (NÃO ESTÃO NA GRADE DE OBRIGATÓRIAS)                                                  
    -- -------------------------------------------------------------------                                                  
    DECLARE @TBL_IDENTIFICAR TABLE (                                         
  CURSO               VARCHAR(20)    COLLATE Latin1_General_CI_AI                                                   
      , TURNO               VARCHAR(20)    COLLATE Latin1_General_CI_AI                                                   
      , CURRICULO           VARCHAR(20)    COLLATE Latin1_General_CI_AI                                                   
      , ALUNO               VARCHAR(20)    COLLATE Latin1_General_CI_AI                                                   
      , ANO                 NUMERIC(4,0)                                                   
      , PERIODO             NUMERIC(2,0)                                                   
      , DISCIPLINA          VARCHAR(20)    COLLATE Latin1_General_CI_AI                                                   
      , NOTA_FINAL          VARCHAR(200)   COLLATE Latin1_General_CI_AI                                                   
      , SITUACAO            VARCHAR(20)    COLLATE Latin1_General_CI_AI                                                   
      , PERC_PRESENCA       DECIMAL(5,4)                                                   
      , HORAS_AULA_HIST     DECIMAL(10,2)                                                   
      , CRED_HIST           DECIMAL(10,2)                                                   
      , SERIE               NUMERIC(3,0)                                                  
      , GRUPO_ELETIVA       VARCHAR(20)    COLLATE Latin1_General_CI_AI                                                   
      , SIT_DETALHE         VARCHAR(50)    COLLATE Latin1_General_CI_AI                                                   
      , ORIGEM              VARCHAR(50)    COLLATE Latin1_General_CI_AI                                                   
      , FORMULA_EQUIV       VARCHAR(2000)  COLLATE Latin1_General_CI_AI                                                   
    )                                                  
                                                  
    -- -------------------------------------------------------------------                                                  
    -- 4) TABELA UTILIZADA PARA AGILIZAR O LOOP QUE CHAMA A PROCEDURE PARA DESMEMBRAR A FÓRMULA DE EQUIVALÊNCIA                                                  
    -- -------------------------------------------------------------------                                    
    DECLARE @TBL_LOOP_EQUIV TABLE (                                                  
        ID        INT         IDENTITY(1,1)                                                  
      , CURSO     VARCHAR(20) COLLATE Latin1_General_CI_AI                                          
      , TURNO     VARCHAR(20) COLLATE Latin1_General_CI_AI                                                   
      , CURRICULO VARCHAR(20) COLLATE Latin1_General_CI_AI                                                   
    )                                           
                                                  
    -- -------------------------------------------------------------------                                                  
    -- 5) TABELA QUE TERÁ A FÓRMULA DE EQUIVALÊNCIA DESMEMBRADA                                                 
    -- -------------------------------------------------------------------                                                  
    Create table #TBL_EQUIVALENCIAS (                                                   
        CURSO               VARCHAR(20)   COLLATE Latin1_General_CI_AI                                                 
      , TURNO               VARCHAR(20)   COLLATE Latin1_General_CI_AI                                                  
      , CURRICULO           VARCHAR(20)   COLLATE Latin1_General_CI_AI                                               
      , ID                  INT                                       
      , GRUPO_ELETIVA       VARCHAR(20)   COLLATE Latin1_General_CI_AI                                                  
      , DISCIPLINA          VARCHAR(20)   COLLATE Latin1_General_CI_AI                                                  
      , SERIE_IDEAL         NUMERIC(3,0)                                                  
      , FORMULA_EQUIV       VARCHAR(2000) COLLATE Latin1_General_CI_AI                                                  
      , DISC_EQUIVALENTE    VARCHAR(20)   COLLATE Latin1_General_CI_AI                                                  
      , CONTROLE            VARCHAR(30)   COLLATE Latin1_General_CI_AI                                                   
      , ORDEM               INT                         
    )                                                     
                                                  
    -- -------------------------------------------------------------------                                                  
    -- 6) TABELA FINAL PARA GUARDAR AS EQUIVALÊNCIAS CURSADAS                                                  
    -- -------------------------------------------------------------------                                                  
    DECLARE @TBL_HIST_EQUIV TABLE (                                                  
        CURSO               VARCHAR(20)   COLLATE Latin1_General_CI_AI                                                   
      , TURNO               VARCHAR(20)   COLLATE Latin1_General_CI_AI                                                   
      , CURRICULO           VARCHAR(20)   COLLATE Latin1_General_CI_AI                                                   
      , ALUNO               VARCHAR(20)   COLLATE Latin1_General_CI_AI                                                   
      , ORIGEM              VARCHAR(50)   COLLATE Latin1_General_CI_AI                                                   
      , ANO                 NUMERIC(4,0)                                                   
      , PERIODO             NUMERIC(2,0)                                                   
      , SERIE               NUMERIC(3,0)                                                  
      , DISC_ORIGINAL       VARCHAR(20)   COLLATE Latin1_General_CI_AI                              
      , DISCIPLINA_EQUIV    VARCHAR(20)   COLLATE Latin1_General_CI_AI                                                   
      , NOTA_FINAL          VARCHAR(200)  COLLATE Latin1_General_CI_AI                                                   
      , PERC_PRESENCA       DECIMAL(5,4)                                                   
      , SITUACAO            VARCHAR(20)   COLLATE Latin1_General_CI_AI                              
      , CRED_DISC           DECIMAL(10,2)                                                   
      , CRED_HIST           DECIMAL(10,2)                                                   
      , HORAS_AULA_DISC     DECIMAL(10,2)                                                   
      , HORAS_AULA_HIST     DECIMAL(10,2)                                                   
      , ESTAGIO      VARCHAR(1)    COLLATE Latin1_General_CI_AI                                                   
      , GRUPO_ELETIVA       VARCHAR(20)   COLLATE Latin1_General_CI_AI                                   
      , SIT_DETALHE         VARCHAR(50)   COLLATE Latin1_General_CI_AI                                                   
      , SERIE_IDEAL         NUMERIC(3,0)                                                  
      , PENDENTE            VARCHAR(1)    COLLATE Latin1_General_CI_AI                                                   
      , ID_EQUIV            INT                               
    )                                                  
                                                  
    -- -------------------------------------------------------------------                                                  
    -- 7) TABELA FINAL PARA GERAR O RELATÓRIO                                                   
    --      UTILIZADA PARA PEGAR OS DEMAIS CAMPOS NECESSÁRIOS PARA MONTAR O RELATÓRIO                                                  
    -- -------------------------------------------------------------------                   
    DECLARE @TBL_HIST_SAIDA TABLE                               
 (                                                  
 SIT_ALUNO       VARCHAR(255) COLLATE Latin1_General_CI_AI                                                   
 , ALUNO        VARCHAR(255) COLLATE Latin1_General_CI_AI                               
 , TURNO        VARCHAR(255) COLLATE Latin1_General_CI_AI                                                   
 , CURRICULO       VARCHAR(255) COLLATE Latin1_General_CI_AI                                                   
 , OBSERVACAO_HIST     VARCHAR(4000) COLLATE Latin1_General_CI_AI                                                   
 , NOME_ALUNO      VARCHAR(255) COLLATE Latin1_General_CI_AI                                
 , SEXO        VARCHAR(1)  COLLATE Latin1_General_CI_AI                               
 , DT_NASC       DATETIME                               
 , MUNICIPIO_NASC     VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , UF_NASC       VARCHAR(2)  COLLATE Latin1_General_CI_AI                                                  
 , NACIONALIDADE      VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , TELEITOR_NUM      VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , TELEITOR_ZONA      VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , TELEITOR_SECAO     VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , TELEITOR_DTEXP     DATETIME                                               
 , CR_NUM       VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , CR_CAT       VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , CR_SERIE       VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , CR_RM        VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , CR_CSM       VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , CR_DTEXP       DATETIME                                               
 , RG_TIPO       VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , RG_NUM       VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , RG_EMISSOR      VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , RG_UF        VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , RG_DTEXP       DATETIME                                                    
 , CPF        VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , NOME_PAI       VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , NOME_MAE       VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , CURSO_ANT       VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , ESCOLA_CURSO_ANT     VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , ANO_CONCL_CURSO_ANT    NUMERIC(4,0)                                                  
 , UNIDADE_FISICA     VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , NOME_UNID_FIS      VARCHAR(255) COLLATE Latin1_General_CI_AI                   
 , RECONHECIMENTO     VARCHAR(300) COLLATE Latin1_General_CI_AI        ----- RECONHECIMENTO FL_FIEL06                        
 , FACULDADE       VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , NOME_UNID_ENSINO     VARCHAR(255) COLLATE Latin1_General_CI_AI                                        
 , CURSO        VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , HABILITACAO      VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , NOME_CURSO      varchar(300) COLLATE Latin1_General_CI_AI                                                  
 , DECRETO       VARCHAR(2255) COLLATE Latin1_General_CI_AI                                                  
 , CONCURSO       VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , DT_INGRESSO      DATETIME                                                    
 , TIPO_INGRESSO      VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , ANO_INGRESSO      NUMERIC(4,0)                                             
 , SEM_INGRESSO      NUMERIC(2,0)                              
 , DT_ENCERRAMENTO     DATETIME                                         
 , DT_COLACAO      DATETIME                                         
 , DT_DIPLOMA      DATETIME                                         
 , DTVEST       DATETIME                
 , CLASSIFICACAO      NUMERIC(10,0)                                                     
 , DISC_DA_GRADE      VARCHAR(255) COLLATE Latin1_General_CI_AI                                                   
 , ORIGEM       VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , TIPO_DISC       VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , GRUPO_ELETIVA      VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , ANO        NUMERIC(4,0)                                                  
 , PERIODO       NUMERIC(2,0)                                                  
 , DISCIPLINA      VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , NOME_DISC       VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , NUM_FUNC       NUMERIC(15,0)                                                   
 , NOME_DOCENTE      VARCHAR(500) COLLATE Latin1_General_CI_AI                   
 , DOCENTE_TITULACAO     VARCHAR(500) COLLATE Latin1_General_CI_AI       --- ALTERAÇÂO FEITA POR LAERTE LAGO   06/2019                  
 , TITULACAO       VARCHAR(500) COLLATE Latin1_General_CI_AI       --- ALTERAÇÂO FEITA POR LAERTE LAGO   06/2019                  
 , ESTAGIO       VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , CRED_DISC       DECIMAL(10,2)                                                   
 , HORAS_AULA_DISC     DECIMAL(10,2)                                                    
 , HORAS_LAB_DISC     DECIMAL(10,2)                                                    
 , HORAS_ATIV_DISC     DECIMAL(10,2)                                                       
 , HORAS_AULA_GRADE     DECIMAL(10,2)                                                 
 , CRED_HIST       DECIMAL(10,2)                                                   
 , HORAS_AULA_HIST     DECIMAL(10,2)                                                   
 , PERC_PRESENCA      VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , NOTA_FINAL      VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , SITUACAO       VARCHAR(255) COLLATE Latin1_General_CI_AI                                                    
 , SITUACAO_HISTORICO    VARCHAR(255) COLLATE Latin1_General_CI_AI                                                     
 , SITUACAO_SIGLA_HISTORICO   VARCHAR(20)  COLLATE Latin1_General_CI_AI                            
 , PENDENTE       VARCHAR(255) COLLATE Latin1_General_CI_AI                                         
 , ID_EQUIV       INT                                      
 , HORAS_AULA_EXIGIDA    DECIMAL(10,2)                                            
 , ATIV_COMPL_CH      DECIMAL(10,2)                                            
 , ATIV_COMPL_CH_TIPO    DECIMAL(10,2)                                            
 , TOT_HORAS_AULA_CUR    DECIMAL(10,2)                                            
 , HORAS_AULA_ATC_CUR    DECIMAL(10,2)                                            
 , CR_PERIODO      DECIMAL(10,2)                                            
 , CR_CURSO       DECIMAL(10,2)                 
 , UNID_ENDERECO      VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , UNID_END_NUM      VARCHAR(255) COLLATE Latin1_General_CI_AI                               
 , UNID_END_COMPL     VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , UNID_BAIRRO      VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , UNID_MUNICIPIO     VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , UNID_UF_SIGLA_MUNI    CHAR(2)   COLLATE Latin1_General_CI_AI                                                  
 , UNID_CEP       VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , UNID_FONE       VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , UNID_FAX       VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
 , UNID_WEB_SITE      VARCHAR(255) COLLATE Latin1_General_CI_AI                                                 
 , ASSINATURA_PRIMEIRA    VARCHAR(100) COLLATE Latin1_General_CI_AI                                
 , ASSINATURA_PRIMEIRA_RESPONSAVEL VARCHAR(100) COLLATE Latin1_General_CI_AI                                
 , ASSINATURA_PRIMEIRA_DOCUMENTO  VARCHAR(15)  COLLATE Latin1_General_CI_AI                                
 , ASSINATURA_SEGUNDA    VARCHAR(100) COLLATE Latin1_General_CI_AI                                 
 , ASSINATURA_SEGUNDA_RESPONSAVEL VARCHAR(100) COLLATE Latin1_General_CI_AI                                
 , ASSINATURA_SEGUNDA_DOCUMENTO  VARCHAR(15)  COLLATE Latin1_General_CI_AI                                
 , SERIE        NUMERIC(5,0)                             
 , ENADE_INGRESSANTE     VARCHAR(180) COLLATE Latin1_General_CI_AI                                
 , ENADE_CONCLUINTE     VARCHAR(180) COLLATE Latin1_General_CI_AI                                   
    )                                                
                                                  
    -- -------------------------------------------------------------------                                                  
    -- 8) TABELA FINAL PARA ARMAZENAR AS DISCIPLINAS CURSADAS                                         
    -- -------------------------------------------------------------------                                                  
    DECLARE @TBL_DISC_CURSADAS TABLE                                
 (                                                  
        ALUNO               VARCHAR(20)     COLLATE Latin1_General_CI_AI                                                 
      , ANO                 NUMERIC(4,0)                                                   
      , SEMESTRE            NUMERIC(2,0)                  
      , DISCIPLINA          VARCHAR(20)     COLLATE Latin1_General_CI_AI                                                
      , TURMA    VARCHAR(20)     COLLATE Latin1_General_CI_AI                                                
      , NOTA_FINAL          VARCHAR(200)    COLLATE Latin1_General_CI_AI                                                
      , SITUACAO            VARCHAR(20)     COLLATE Latin1_General_CI_AI                                                
      , PERC_PRESENCA       VARCHAR(50)     COLLATE Latin1_General_CI_AI                                        
      , HORAS_AULA     DECIMAL(10, 2)                                                   
      , CREDITOS            DECIMAL(10, 2)                                                   
      , NOME_DISC_ORIG      VARCHAR(150)    COLLATE Latin1_General_CI_AI                                                 
      , SERIE               NUMERIC(3,0)                                                   
      , GRUPO_ELETIVA       VARCHAR(20)     COLLATE Latin1_General_CI_AI                                      
      , SIT_DETALHE         VARCHAR(50)     COLLATE Latin1_General_CI_AI                     
      , ORIGEM              VARCHAR(50)     COLLATE Latin1_General_CI_AI                                                 
    )                                                    
                                                  
    -- -------------------------------------------------------------------                                                  
    -- 8) TABELA FINAL PARA ARMAZENAR AS DISCIPLINAS CURSADAS                                         
    -- -------------------------------------------------------------------                              
    DECLARE @TBL_DISCIPLINA_EM_CURSO TABLE                               
 (                                                  
        ALUNO               VARCHAR(20)     COLLATE Latin1_General_CI_AI                                                 
      , ANO                 NUMERIC(4,0)                                                   
      , SEMESTRE            NUMERIC(2,0)                             
      , DISCIPLINA          VARCHAR(20)     COLLATE Latin1_General_CI_AI                                                
      , TURMA               VARCHAR(20)     COLLATE Latin1_General_CI_AI                                               
      , SITUACAO            VARCHAR(20)     COLLATE Latin1_General_CI_AI                                                
      , SERIE               NUMERIC(3,0)                                                   
      , GRUPO_ELETIVA       VARCHAR(20)     COLLATE Latin1_General_CI_AI                                                
      , SIT_DETALHE         VARCHAR(50)     COLLATE Latin1_General_CI_AI                                                
      , ORIGEM              VARCHAR(50)     COLLATE Latin1_General_CI_AI                                                 
    )                                     
                              
    -- -------------------------------------------------------------------                                                  
    -- 9) INSERE NA TABELA AUXILIAR TODAS AS DISCIPLINAS DA GRADE                                                   
    ----------------------------------------------------------------------                              
             
 IF @P_ALUNO IS NULL --SEM PARÂMETRO DE ALUNO            
 BEGIN            
  INSERT INTO @TBL_HIST (UNID_RESP, UNID_FIS, TIPO, MODALIDADE, CURSO, TURNO, CURRICULO, PESSOA, ALUNO, ORIGEM, ANO,                                       
       PERIODO, SERIE_ALUNO, SERIE_IDEAL, SERIE, DISCIPLINA, NOTA_FINAL, PERC_PRESENCA, SITUACAO,                                        
       CRED_DISC, HORAS_AULA_DISC, ESTAGIO, CRED_HIST, HORAS_AULA_HIST, GRUPO_ELETIVA, SIT_DETALHE,                                                   
       DISC_DA_GRADE, CURSOU_EQUIV, PENDENTE, FORMULA_EQUIV, ID_EQUIV)                                                  
  SELECT             
  C.FACULDADE AS UNID_RESP                              
    , A.UNIDADE_FISICA AS UNID_FIS                              
    , C.TIPO                              
    , C.MODALIDADE                     
    , A.CURSO                              
    , A.TURNO                              
    , A.CURRICULO                              
    , A.PESSOA                              
    , A.ALUNO                              
    , 'Grade' AS ORIGEM                              
    , NULL AS ANO                   
    , NULL AS PERIODO                              
    , A.SERIE AS SERIE_ALUNO                              
    , G.SERIE_IDEAL                              
    , NULL AS SERIE                              
    , G.DISCIPLINA                              
    , NULL AS NOTA_FINAL                              
    , NULL AS PERC_PRESENCA                              
    , 'A Cursar' AS SITUACAO                              
    , D.CREDITOS AS CRED_DISC                           
    , D.HORAS_AULA AS HORAS_AULA_DISC                              
    , D.ESTAGIO                              
    , NULL AS CRED_HIST                              
    , NULL AS HORAS_AULA_HIST                              
    , NULL AS GRUPO_ELETIVA                              
    , 'Curricular' AS SIT_DETALHE                              
    , 'S' AS DISC_DA_GRADE                              
    , 'N' AS CURSOU_EQUIV                              
    , 'S' AS PENDENTE                              
    , ISNULL(CASE WHEN LEN(RTRIM(LTRIM(G.FORMULA_EQUIV))) < 1                               
      THEN NULL                               
   ELSE G.FORMULA_EQUIV                               
    END, D.FORMULA_EQUIV) AS FORMULA_EQUIV                              
    , NULL ID_EQUIV                                             
  FROM LY_ALUNO a WITH(NOLOCK)                                                  
  INNER JOIN LY_GRADE g WITH(NOLOCK) ON a.CURSO = g.CURSO AND a.TURNO = g.TURNO AND a.CURRICULO = g.CURRICULO                                                  
  INNER JOIN LY_DISCIPLINA d WITH(NOLOCK) ON g.DISCIPLINA = d.DISCIPLINA                                                  
  INNER JOIN LY_CURSO c WITH(NOLOCK) ON a.CURSO = c.CURSO                                   
  LEFT OUTER JOIN LY_H_CURSOS_CONCL hcc WITH(NOLOCK) on a.ALUNO = hcc.ALUNO                                                          
  WHERE C.FACULDADE = ISNULL(@P_UNIDADE_ENSINO, C.FACULDADE)                                                   
  AND (A.UNIDADE_FISICA = ISNULL(@P_UNIDADE_FISICA, A.UNIDADE_FISICA) OR A.UNIDADE_FISICA IS NULL)                                                   
  AND C.CURSO = ISNULL(@P_CURSO, C.CURSO)                                                   
  AND A.TURNO = ISNULL(@P_TURNO, A.TURNO)                                                  
  AND A.CURRICULO = ISNULL(@P_CURRICULO, A.CURRICULO)                                                   
  AND A.SERIE = ISNULL(@P_SERIE, A.SERIE)                                                          
  AND A.ANO_INGRESSO = ISNULL(@P_ANO_INGRESSO, A.ANO_INGRESSO)                                                   
  AND A.SEM_INGRESSO = ISNULL(@P_PER_INGRESSO, A.SEM_INGRESSO)            
 END            
 ELSE --COM ALUNO                                                   
    BEGIN            
 INSERT INTO @TBL_HIST (UNID_RESP, UNID_FIS, TIPO, MODALIDADE, CURSO, TURNO, CURRICULO, PESSOA, ALUNO, ORIGEM, ANO,                                                   
       PERIODO, SERIE_ALUNO, SERIE_IDEAL, SERIE, DISCIPLINA, NOTA_FINAL, PERC_PRESENCA, SITUACAO,                                        
       CRED_DISC, HORAS_AULA_DISC, ESTAGIO, CRED_HIST, HORAS_AULA_HIST, GRUPO_ELETIVA, SIT_DETALHE,                                                   
       DISC_DA_GRADE, CURSOU_EQUIV, PENDENTE, FORMULA_EQUIV, ID_EQUIV)                                                  
  SELECT             
  C.FACULDADE AS UNID_RESP                              
    , A.UNIDADE_FISICA AS UNID_FIS                              
    , C.TIPO                              
    , C.MODALIDADE                              
    , A.CURSO                              
    , A.TURNO                              
    , A.CURRICULO                              
    , A.PESSOA                              
    , A.ALUNO                              
    , 'Grade' AS ORIGEM                              
    , NULL AS ANO                              
    , NULL AS PERIODO                              
    , A.SERIE AS SERIE_ALUNO                            
    , G.SERIE_IDEAL                              
    , NULL AS SERIE                              
    , G.DISCIPLINA                              
    , NULL AS NOTA_FINAL                              
    , NULL AS PERC_PRESENCA                              
    , 'A Cursar' AS SITUACAO                              
    , D.CREDITOS AS CRED_DISC                              
    , D.HORAS_AULA AS HORAS_AULA_DISC                              
    , D.ESTAGIO                              
    , NULL AS CRED_HIST                              
    , NULL AS HORAS_AULA_HIST                              
    , NULL AS GRUPO_ELETIVA              
    , 'Curricular' AS SIT_DETALHE                              
    , 'S' AS DISC_DA_GRADE                              
    , 'N' AS CURSOU_EQUIV                              
    , 'S' AS PENDENTE                              
    , ISNULL(CASE WHEN LEN(RTRIM(LTRIM(G.FORMULA_EQUIV))) < 1                               
      THEN NULL                               
   ELSE G.FORMULA_EQUIV                               
    END, D.FORMULA_EQUIV) AS FORMULA_EQUIV                              
    , NULL ID_EQUIV                                             
  FROM LY_ALUNO a WITH(NOLOCK)                                                  
  INNER JOIN LY_GRADE g WITH(NOLOCK) ON a.CURSO = g.CURSO AND a.TURNO = g.TURNO AND a.CURRICULO = g.CURRICULO                                                  
  INNER JOIN LY_DISCIPLINA d WITH(NOLOCK) ON g.DISCIPLINA = d.DISCIPLINA                                                  
  INNER JOIN LY_CURSO c WITH(NOLOCK) ON a.CURSO = c.CURSO                                   
  INNER JOIN dbo.SPLIT(@P_ALUNO, ',') S ON S.S = A.ALUNO            
  LEFT OUTER JOIN LY_H_CURSOS_CONCL hcc WITH(NOLOCK) on a.ALUNO = hcc.ALUNO            
  WHERE C.FACULDADE = ISNULL(@P_UNIDADE_ENSINO, C.FACULDADE)                                                   
  AND (A.UNIDADE_FISICA = ISNULL(@P_UNIDADE_FISICA, A.UNIDADE_FISICA) OR A.UNIDADE_FISICA IS NULL)                                                   
  AND C.CURSO = ISNULL(@P_CURSO, C.CURSO)                                                   
  AND A.TURNO = ISNULL(@P_TURNO, A.TURNO)                                                  
  AND A.CURRICULO = ISNULL(@P_CURRICULO, A.CURRICULO)                                                   
  AND A.SERIE = ISNULL(@P_SERIE, A.SERIE)                                                          
  AND A.ANO_INGRESSO = ISNULL(@P_ANO_INGRESSO, A.ANO_INGRESSO)                                                   
  AND A.SEM_INGRESSO = ISNULL(@P_PER_INGRESSO, A.SEM_INGRESSO)            
 END                                                      
    -- -------------------------------------------------------------------                                                  
    -- 10) ATUALIZA AS DISCIPLINAS QUE CURSOU TENDO APROVAÇÃO OU ESTÁ CURSANDO (SOMENTE DISCIPLINAS DA GRADE)                                                   
    -- -------------------------------------------------------------------                                                  
    INSERT INTO @TBL_DISC_CURSADAS(ALUNO, ANO, SEMESTRE, DISCIPLINA, TURMA, NOTA_FINAL, SITUACAO, PERC_PRESENCA,                                                   
                                   HORAS_AULA, CREDITOS, NOME_DISC_ORIG, SERIE, GRUPO_ELETIVA, SIT_DETALHE, ORIGEM)                                                
    SELECT ALUNO                              
      , ANO                              
   , SEMESTRE                              
   , DISCIPLINA                              
   , TURMA                              
   , NOTA_FINAL                              
   , SITUACAO_HIST AS SITUACAO                              
   , PERC_PRESENCA                              
   , HORAS_AULA                              
   , CREDITOS                              
   , LTRIM(RTRIM(NOME_DISC_ORIG)) AS NOME_DISC_ORIG                              
   , SERIE                              
   , GRUPO_ELETIVA                              
   , SIT_DETALHE                              
   , 'Histórico' AS ORIGEM                                                  
    FROM LY_HISTMATRICULA H                                             
    WHERE SITUACAO_HIST IN ('Aprovado','Dispensado')                                            
    AND EXISTS (SELECT TOP 1 1                               
             FROM @TBL_HIST TMP                                                  
                WHERE TMP.ALUNO = H.ALUNO --COLLATE Latin1_General_CI_AI                               
    AND   TMP.DISCIPLINA = H.DISCIPLINA )--COLLATE Latin1_General_CI_AI)                                                     
                                    
    UPDATE TMP                                                   
    SET ORIGEM          = H.ORIGEM                              
   , ANO             = H.ANO                              
   , PERIODO         = H.SEMESTRE                              
   , SERIE           = H.SERIE                              
   , NOTA_FINAL      = H.NOTA_FINAL                              
   , PERC_PRESENCA   = H.PERC_PRESENCA                              
   , SITUACAO        = H.SITUACAO                          
   , CRED_HIST       = H.CREDITOS           
   , HORAS_AULA_HIST = H.HORAS_AULA                              
   , GRUPO_ELETIVA   = H.GRUPO_ELETIVA                       
   , SIT_DETALHE     = H.SIT_DETALHE                              
   , PENDENTE        = CASE WHEN H.SITUACAO IN ('Aprovado','Dispensado') THEN 'N' ELSE 'S' END                                                  
    FROM @TBL_HIST TMP                                                  
    INNER JOIN @TBL_DISC_CURSADAS H ON TMP.ALUNO = H.ALUNO COLLATE Latin1_General_CI_AI                               
                                AND TMP.DISCIPLINA = H.DISCIPLINA COLLATE Latin1_General_CI_AI                                                  
                                                  
    -- -------------------------------------------------------------------                                                  
    -- 10b) ATUALIZA AS DISCIPLINAS QUE ESTÃO EM CURSO (SOMENTE DISCIPLINAS DA GRADE)                      
    -- -------------------------------------------------------------------                                                  
    INSERT INTO @TBL_DISCIPLINA_EM_CURSO(ALUNO, ANO, SEMESTRE, DISCIPLINA, TURMA, SITUACAO, SERIE, GRUPO_ELETIVA, SIT_DETALHE, ORIGEM)                                                  
    SELECT M.ALUNO                              
      , M.ANO                              
   , M.SEMESTRE                              
   , G.DISCIPLINA                              
   , M.TURMA                              
   , CASE WHEN M.SIT_MATRICULA = 'Cancelado' THEN 'A Cursar' ELSE M.SIT_MATRICULA END AS SITUACAO --INCLUÍDO POR YURI GUIMARÃES A PEDIDO DO CHAMADO 128757    
   , T.SERIE                               
   , M.GRUPO_ELETIVA                              
   , M.SIT_DETALHE                              
   , 'Matrícula' AS ORIGEM                                                  
    FROM LY_MATRICULA M                              
   INNER JOIN LY_TURMA T ON M.DISCIPLINA = T.DISCIPLINA AND M.TURMA = T.TURMA AND M.ANO = T.ANO AND M.SEMESTRE = T.SEMESTRE                    
   INNER JOIN LY_ALUNO A ON A.ALUNO = M.ALUNO                    
   INNER JOIN LY_GRADE G ON G.CURSO = A.CURSO AND G.TURNO = A.TURNO AND G.CURRICULO = A.CURRICULO AND (M.DISCIPLINA = G.DISCIPLINA OR G.FORMULA_EQUIV LIKE '%'+M.DISCIPLINA+'%')                    
    WHERE 1=1                    
 AND EXISTS (SELECT TOP 1 1        
    FROM @TBL_HIST TMP                                                  
    WHERE TMP.ALUNO = M.ALUNO COLLATE Latin1_General_CI_AI)                              
     --AND TMP.DISCIPLINA = M.DISCIPLINA COLLATE Latin1_General_CI_AI) --Exibir disciplinas equivalentes cursadas no histórico chamado 116650 -- Jéssica Ciqueira      
                   
                                                      
    UPDATE TMP                                                   
    SET ORIGEM          = H.ORIGEM                              
   , ANO             = H.ANO                              
   , PERIODO         = H.SEMESTRE                              
   , SERIE           = H.SERIE                              
   , SITUACAO        = H.SITUACAO                              
   , GRUPO_ELETIVA   = H.GRUPO_ELETIVA                              
   , SIT_DETALHE     = H.SIT_DETALHE                              
   , PENDENTE        = 'S'                              
    FROM @TBL_HIST TMP                                                  
    INNER JOIN @TBL_DISCIPLINA_EM_CURSO H ON TMP.ALUNO = H.ALUNO COLLATE Latin1_General_CI_AI                     
                                      AND TMP.DISCIPLINA = H.DISCIPLINA COLLATE Latin1_General_CI_AI                                  
                               
 -- -------------------------------------------------------------------                                                  
    -- 11) INSERE AS DISCIPLINAS QUE CURSOU TENDO REPROVAÇÃO (SOMENTE DISCIPLINAS DA GRADE)                                                   
    -- -------------------------------------------------------------------                                                  
    INSERT INTO @TBL_HIST (UNID_RESP, UNID_FIS, TIPO, MODALIDADE, CURSO, TURNO, CURRICULO, PESSOA, ALUNO, ORIGEM, ANO,                                                   
                           PERIODO, SERIE_ALUNO, SERIE_IDEAL, SERIE, DISCIPLINA, NOTA_FINAL, PERC_PRESENCA, SITUACAO,                                                   
                           CRED_DISC, HORAS_AULA_DISC, ESTAGIO, CRED_HIST, HORAS_AULA_HIST, GRUPO_ELETIVA, SIT_DETALHE,                                             
                           DISC_DA_GRADE, CURSOU_EQUIV, PENDENTE, FORMULA_EQUIV, ID_EQUIV)                                                  
    SELECT T.UNID_RESP                              
      , T.UNID_FIS                              
   , T.TIPO                              
   , T.MODALIDADE                              
   , T.CURSO                              
   , T.TURNO                              
   , T.CURRICULO                              
   , T.PESSOA                              
   , T.ALUNO                              
   , H.ORIGEM                              
   , H.ANO                              
   , H.SEMESTRE AS PERIODO                              
   , T.SERIE_ALUNO                              
   , T.SERIE_IDEAL                              
   , H.SERIE                              
   , T.DISCIPLINA                              
   , H.NOTA_FINAL                              
   , H.PERC_PRESENCA                              
   , H.SITUACAO                              
   , T.CRED_DISC                              
   , T.HORAS_AULA_DISC                          
   , T.ESTAGIO                  
   , H.CREDITOS AS CRED_HIST                              
   , H.HORAS_AULA AS HORAS_AULA_HIST                              
   , H.GRUPO_ELETIVA                              
   , H.SIT_DETALHE                              
   , T.DISC_DA_GRADE                              
   , T.CURSOU_EQUIV                              
   , T.PENDENTE                              
   , FORMULA_EQUIV                              
   , NULL AS ID_EQUIV                                                  
    FROM @TBL_HIST T                                                  
    INNER JOIN (SELECT ALUNO, ANO, SEMESTRE, DISCIPLINA, TURMA, NOTA_FINAL, SITUACAO_HIST AS SITUACAO, PERC_PRESENCA, HORAS_AULA,                                                   
                       CREDITOS, LTRIM(RTRIM(NOME_DISC_ORIG)) AS NOME_DISC_ORIG, SERIE, GRUPO_ELETIVA, SIT_DETALHE, 'Histórico' AS ORIGEM                
                FROM LY_HISTMATRICULA                                                   
                WHERE SITUACAO_HIST IN ('Rep Freq','Rep Nota')) H ON T.ALUNO = H.ALUNO COLLATE Latin1_General_CI_AI                               
                      AND T.DISCIPLINA = H.DISCIPLINA COLLATE Latin1_General_CI_AI                                                  
                                                  
    -- -------------------------------------------------------------------                                                  
    -- 12) ELIMINA DUPLICIDADE PARA A DISCIPLINA QUE SÓ TENHA REPROVAÇÃO (SOMENTE DISCIPLINAS DA GRADE)                                                   
    -- -------------------------------------------------------------------                                                  
    DELETE T                                                  
    FROM @TBL_HIST T                                                  
    WHERE ANO IS NULL AND EXISTS (SELECT TOP 1 1                               
                               FROM @TBL_HIST T2                                                   
                                  WHERE T2.ANO IS NOT NULL                                                   
                                  AND   T2.ALUNO = T.ALUNO AND T2.DISCIPLINA = T.DISCIPLINA)                                                  
 --   -- -------------------------------------------------------------------                                                  
 --   -- 12.1) ELIMINA REGISTROS PARA MANTER APENAS O ULTIMO STATUS DA DISCIPLINA                                              
 --   -- -------------------------------------------------------------------                                                  
 --DELETE T                                                  
 --   FROM @TBL_HIST T                                                  
 --   WHERE EXISTS (SELECT MAX(CONCAT(T2.ANO,T2.PERIODO)), T2.DISCIPLINA                    
 --                              FROM @TBL_HIST T2                                                   
 --                                 WHERE T2.ANO IS NOT NULL                                                   
 --                                 AND   T2.ALUNO = T.ALUNO AND T2.DISCIPLINA = T.DISCIPLINA                    
 --         GROUP BY T2.DISCIPLINA)                       
                                             
-- -------------------------------------------------------------------                                                  
    -- 13) CRIA UMA TABELA AUXILIAR COM AS DISCIPLINAS QUE SOBRARAM (CURSADAS QUE NÃO ESTÃO NA GRADE DE OBRIGATÓRIAS)                                 
 --     DISCIPLINA FORA DA GRADE                                                                
    -- -------------------------------------------------------------------                                        
    INSERT INTO @TBL_IDENTIFICAR(CURSO, TURNO, CURRICULO, ALUNO, ANO, PERIODO, DISCIPLINA, NOTA_FINAL, SITUACAO                              
                            , PERC_PRESENCA, HORAS_AULA_HIST, CRED_HIST, SERIE, GRUPO_ELETIVA, SIT_DETALHE, ORIGEM)                                                  
    SELECT CURSO                              
      , TURNO                              
   , CURRICULO                              
   , ALUNO                              
   , ANO                              
   , SEMESTRE AS PERIODO                              
   , DISCIPLINA                              
   , NOTA_FINAL                              
   , SITUACAO                              
   , PERC_PRESENCA                              
   , HORAS_AULA AS HORAS_AULA_HIST                              
   , CREDITOS AS CRED_HIST                              
   , SERIE                             
   , GRUPO_ELETIVA                              
   , SIT_DETALHE                              
   , ORIGEM                                                  
    FROM (SELECT A1.CURSO, A1.TURNO, A1.CURRICULO, M1.ALUNO, M1.ANO, M1.SEMESTRE, M1.DISCIPLINA, M1.TURMA, M1.NOTA_FINAL                              
            , M1.SITUACAO_HIST AS SITUACAO, M1.PERC_PRESENCA, M1.HORAS_AULA, M1.CREDITOS, LTRIM(RTRIM(M1.NOME_DISC_ORIG)) AS NOME_DISC_ORIG, M1.SERIE                              
      , M1.GRUPO_ELETIVA, M1.SIT_DETALHE, 'Histórico' AS ORIGEM                                                  
          FROM LY_HISTMATRICULA M1                                                  
          INNER JOIN LY_ALUNO A1 ON M1.ALUNO = A1.ALUNO                                                  
          WHERE EXISTS (SELECT TOP 1 1                               
                  FROM @TBL_HIST T                               
      WHERE T.ALUNO = M1.ALUNO COLLATE Latin1_General_CI_AI)                                                  
          AND   NOT EXISTS (SELECT TOP 1 1                               
                      FROM @TBL_HIST T                               
       WHERE T.DISCIPLINA = M1.DISCIPLINA COLLATE Latin1_General_CI_AI                          
                  AND   T.ALUNO = M1.ALUNO COLLATE Latin1_General_CI_AI)) H                                      
                                                  
                                                       
    -- -------------------------------------------------------------------                                                  
    -- 14) INSERE AS DISCIPLINAS DA GRADE ELETIVA QUE ESTAM APROVADAS                                       
    -- -------------------------------------------------------------------                                                  
    INSERT INTO @TBL_HIST (UNID_RESP, UNID_FIS, TIPO, MODALIDADE, CURSO, TURNO, CURRICULO, PESSOA, ALUNO, ORIGEM, ANO,                                                   
                           PERIODO, SERIE_ALUNO, SERIE_IDEAL, SERIE, DISCIPLINA, NOTA_FINAL, PERC_PRESENCA, SITUACAO,                                                   
                           CRED_DISC, HORAS_AULA_DISC, ESTAGIO, CRED_HIST, HORAS_AULA_HIST, GRUPO_ELETIVA, SIT_DETALHE,                                                   
                           DISC_DA_GRADE, CURSOU_EQUIV, PENDENTE, FORMULA_EQUIV, ID_EQUIV)                                           
    SELECT T.UNID_RESP                              
      , T.UNID_FIS                              
   , T.TIPO                              
   , T.MODALIDADE                              
   , T.CURSO                              
   , T.TURNO                              
   , T.CURRICULO                              
   , T.PESSOA                              
   , T.ALUNO                              
   , I.ORIGEM                              
   , I.ANO                              
   , I.PERIODO                   
   , T.SERIE_ALUNO                              
   , GE.SERIE_IDEAL                              
   , I.SERIE                              
   , I.DISCIPLINA                              
   , I.NOTA_FINAL                              
   , I.PERC_PRESENCA                              
   , I.SITUACAO                              
   , NULL AS CRED_DISC                              
   , NULL AS HORAS_AULA_DISC                              
   , NULL AS ESTAGIO                              
   , I.CRED_HIST                              
   , I.HORAS_AULA_HIST                              
   , GE.GRUPO_DISC AS GRUPO_ELETIVA                              
   , I.SIT_DETALHE                              
   , 'S' AS DISC_DA_GRADE                              
   , 'N' AS CURSOU_EQUIV                              
   , 'N' AS PENDENTE                              
   , NULL AS FORMULA_EQUIV                              
   , NULL AS ID_EQUIV                                                  
    FROM @TBL_IDENTIFICAR I                                                  
    INNER JOIN LY_GRADE_ELETIVAS GE ON I.CURSO = GE.CURSO COLLATE Latin1_General_CI_AI                               
                             AND I.TURNO = GE.TURNO COLLATE Latin1_General_CI_AI                                                   
                                   AND I.CURRICULO = GE.CURRICULO COLLATE Latin1_General_CI_AI                               
           AND I.DISCIPLINA = GE.DISCIPLINA COLLATE Latin1_General_CI_AI                                                   
   INNER JOIN (SELECT DISTINCT UNID_RESP, UNID_FIS, TIPO, MODALIDADE, CURSO, TURNO, CURRICULO, PESSOA, ALUNO, SERIE_ALUNO                                                  
                FROM @TBL_HIST) T ON I.ALUNO = T.ALUNO                                                   
    WHERE I.SITUACAO NOT LIKE 'Rep%'                                                  
                                                
    -- -------------------------------------------------------------------                                                  
    -- 15) INSERE AS DISCIPLINAS DA GRADE ELETIVA QUE CURSOU TENDO REPROVAÇÃO                                                  
    -- -------------------------------------------------------------------                                                  
    INSERT INTO @TBL_HIST (UNID_RESP, UNID_FIS, TIPO, MODALIDADE, CURSO, TURNO, CURRICULO, PESSOA, ALUNO, ORIGEM, ANO,                                                   
                           PERIODO, SERIE_ALUNO, SERIE_IDEAL, SERIE, DISCIPLINA, NOTA_FINAL, PERC_PRESENCA, SITUACAO,                                                   
                           CRED_DISC, HORAS_AULA_DISC, ESTAGIO, CRED_HIST, HORAS_AULA_HIST, GRUPO_ELETIVA, SIT_DETALHE,                                                   
                           DISC_DA_GRADE, CURSOU_EQUIV, PENDENTE, FORMULA_EQUIV, ID_EQUIV)                                
    SELECT T.UNID_RESP                              
      , T.UNID_FIS                              
   , T.TIPO                              
   , T.MODALIDADE                              
   , T.CURSO                              
   , T.TURNO                              
   , T.CURRICULO                              
   , T.PESSOA                              
   , T.ALUNO                              
   , I.ORIGEM                         
   , I.ANO                              
   , I.PERIODO                              
   , T.SERIE_ALUNO                              
   , GE.SERIE_IDEAL                         
   , I.SERIE                              
   , I.DISCIPLINA                              
   , I.NOTA_FINAL                              
   , I.PERC_PRESENCA                              
   , I.SITUACAO                              
   , NULL AS CRED_DISC                              
   , NULL AS HORAS_AULA_DISC                              
   , NULL AS ESTAGIO                              
   , I.CRED_HIST                              
   , I.HORAS_AULA_HIST                              
   , GE.GRUPO_DISC AS GRUPO_ELETIVA                              
   , I.SIT_DETALHE                              
   , 'S' AS DISC_DA_GRADE                              
   , 'N' AS CURSOU_EQUIV                              
   , T.PENDENTE                              
   , NULL AS FORMULA_EQUIV                              
   , NULL AS ID_EQUIV                                                  
    FROM @TBL_IDENTIFICAR I                                                  
    INNER JOIN LY_GRADE_ELETIVAS GE ON I.CURSO = GE.CURSO COLLATE Latin1_General_CI_AI                               
                                AND I.TURNO = GE.TURNO COLLATE Latin1_General_CI_AI                                                   
                                   AND I.CURRICULO = GE.CURRICULO COLLATE Latin1_General_CI_AI                               
           AND I.DISCIPLINA = GE.DISCIPLINA COLLATE Latin1_General_CI_AI                                                  
    INNER JOIN (SELECT DISTINCT UNID_RESP, UNID_FIS, TIPO, MODALIDADE, CURSO, TURNO, CURRICULO, PESSOA, ALUNO        
                          , SERIE_ALUNO, DISCIPLINA, PENDENTE                                                  
                FROM @TBL_HIST) T ON I.ALUNO = T.ALUNO AND I.DISCIPLINA = T.DISCIPLINA                                                  
    WHERE I.SITUACAO LIKE 'Rep%'                                                  
                                                  
    -- -------------------------------------------------------------------                                                  
    -- 16) ELIMINA AS QUE JÁ FORAM IDENTIFICADAS E INSERIDAS NA @TBL_HIST                                           
    -- -------------------------------------------------------------------                           
    DELETE I                                                  
    FROM @TBL_IDENTIFICAR I                                                  
    WHERE EXISTS (SELECT TOP 1 1                               
               FROM @TBL_HIST T                                                   
                  WHERE T.ALUNO = I.ALUNO                               
      AND   T.DISCIPLINA = I.DISCIPLINA                               
      AND   T.ANO = I.ANO                           
      AND   T.PERIODO = I.PERIODO)                                       
           
    -- -------------------------------------------------------------------                                                  
    -- 16) ELIMINA AS QUE JÁ FORAM IDENTIFICADAS E INSERIDAS NA @TBL_HIST                                                  
    -- -------------------------------------------------------------------                                                  
    --DELETE I                                                  
    --FROM @TBL_IDENTIFICAR I                                                  
    --WHERE EXISTS (SELECT TOP 1 1                               
    --           FROM @TBL_HIST T                                                   
    --              WHERE T.ALUNO = I.ALUNO                               
    --  AND   T.DISCIPLINA = I.DISCIPLINA                               
    --  AND   T.ANO = I.ANO                               
    --  AND   T.PERIODO = I.PERIODO)                                                  
                                              
    -- -------------------------------------------------------------------                                                  
    -- AS QUE SOBRARAM OU SÃO AS EQUIVALENTES CURSADAS OU SÃO FORA DA GRADE                                                  
    -- -------------------------------------------------------------------                                                  
    -- 17) PREENCHE A TABELA #TBL_EQUIVALENCIAS (FÓRMULA DE EQUIVALÊNCIA DESMEMBRADA)                                                  
    -- -------------------------------------------------------------------                                                  
    INSERT INTO @TBL_LOOP_EQUIV(CURSO, TURNO, CURRICULO )                                                  
    SELECT DISTINCT CURSO                              
               , TURNO                              
      , CURRICULO                                    
    FROM @TBL_IDENTIFICAR T                                                  
                                                  
    SET @v_ID_LOOP = NULL                               
                                                  
    SELECT @v_ID_LOOP = MIN(ID)                               
 FROM @TBL_LOOP_EQUIV                                
                                                  
    WHILE @v_ID_LOOP IS NOT NULL                                                   
    BEGIN                                   
        SELECT @v_CURSO = CURSO                              
       , @v_TURNO = TURNO                              
    , @v_CURRICULO = CURRICULO                               
  FROM @TBL_LOOP_EQUIV                               
  WHERE ID = @v_ID_LOOP                                 
                                               
        EXEC SP_Desmembra_Formula_Equiv @v_CURSO, @v_TURNO, @v_CURRICULO                                   
                                             
        SELECT @v_ID_LOOP = MIN(ID)                               
  FROM @TBL_LOOP_EQUIV                               
  WHERE ID > @v_ID_LOOP                                                  
    END                                                  
                                                  
    -- -------------------------------------------------------------------                                                  
    -- 18) INSERE NA TABELA @TBL_HIST_EQUIV, TODAS AS DISCIPLINAS, CURSADAS, QUE ENCONTROU NA FÓRMULA DE EQUIVALÊNCIAS (TABELA #TBL_EQUIVALENCIAS)                                        
    --     EQUIVALENCIAS COM E SEM FORMULA "E"                                    
    -- -------------------------------------------------------------------                                                  
    DECLARE @TBL_LOOP_IDENTIFICA_EQUIV AS TABLE (                                  
               ID_IDENTITY     INT         IDENTITY(1,1)                                                  
              , CURSO           VARCHAR(20) COLLATE Latin1_General_CI_AI                                                   
              , TURNO           VARCHAR(20) COLLATE Latin1_General_CI_AI                                                   
              , CURRICULO       VARCHAR(20) COLLATE Latin1_General_CI_AI                                                   
              , DISCIPLINA      VARCHAR(20) COLLATE Latin1_General_CI_AI                                                   
              , ALUNO           VARCHAR(20) COLLATE Latin1_General_CI_AI                  
              , ID              INT                                                  
              , QTD             INT                                                  
            )                                       
                                            
    INSERT INTO @TBL_LOOP_IDENTIFICA_EQUIV                                                  
    SELECT DISTINCT T2.CURSO                              
               , T2.TURNO                              
      , T2.CURRICULO                              
      , T2.DISCIPLINA                              
      , T.ALUNO                              
      , T2.ID                  
      , COUNT(*) AS QTD                                                  
    FROM #TBL_EQUIVALENCIAS T2                                                  
    INNER JOIN (SELECT DISTINCT T1.CURSO, T1.TURNO, T1.CURRICULO, T1.ALUNO                              
             FROM @TBL_IDENTIFICAR T1) T ON T2.CURSO = T.CURSO                                                    
         AND T2.TURNO = T.TURNO                                                   
                                           AND T2.CURRICULO = T.CURRICULO                                                  
 GROUP BY  T2.CURSO, T2.TURNO, T2.CURRICULO, T2.DISCIPLINA, T.ALUNO, T2.ID                                     
                                                  
    SET @v_ID_LOOP = NULL                                  
                                               
    SELECT @v_ID_LOOP = MIN(ID_IDENTITY)                               
 FROM @TBL_LOOP_IDENTIFICA_EQUIV                                
                                                  
    WHILE @v_ID_LOOP IS NOT NULL                                                   
    BEGIN                                                  
        SELECT @v_CURSO = CURSO                              
       , @v_TURNO = TURNO                              
    , @v_CURRICULO = CURRICULO                              
    , @v_DISCIPLINA = DISCIPLINA                              
    , @v_ALUNO = ALUNO                              
    , @v_ID = ID                              
    , @v_QTD = QTD        
        FROM @TBL_LOOP_IDENTIFICA_EQUIV                                                   
        WHERE ID_IDENTITY = @v_ID_LOOP                                                  
                                                  
        SET @v_QTD_AUX = 0                                  
                                                
        IF @v_QTD > 0                                                  
            SET @v_VERIFICA = 0                                                  
        ELSE                              
            SET @v_VERIFICA = 1                                                  
                                                          
        WHILE @v_QTD_AUX < @v_QTD --AND @v_VERIFICA < 1                                                  
        BEGIN                                                  
            SET @v_VERIFICA = 0                                                  
            SELECT @v_VERIFICA = ISNULL(COUNT(*), 0)                                   
            FROM @TBL_IDENTIFICAR I                                                  
            WHERE EXISTS (SELECT TOP 1 1                               
                 FROM #TBL_EQUIVALENCIAS T                                                  
                          WHERE T.ID = @v_ID                               
        AND   T.ORDEM = @v_QTD_AUX+1                                                  
                          AND   T.CURSO = I.CURSO          
        AND   T.TURNO = I.TURNO                               
        AND   T.CURRICULO = I.CURRICULO                               
        AND   T.DISC_EQUIVALENTE = I.DISCIPLINA)                                   
            AND I.ALUNO = @v_ALUNO                                                  
                            
       SET @v_QTD_AUX = @v_QTD_AUX+1                                                  
            IF @v_VERIFICA < 1                                                  
               BREAK                                                  
        END                                                  
                                                  
        IF @v_VERIFICA > 0                                                  
        BEGIN                                                  
            --INSERIR NA TABELA DE EQUIVALENCIA                              
            INSERT INTO @TBL_HIST_EQUIV (CURSO, TURNO, CURRICULO, ALUNO, ORIGEM, ANO, PERIODO, SERIE, DISC_ORIGINAL, DISCIPLINA_EQUIV, NOTA_FINAL, PERC_PRESENCA,                                                   
                                        SITUACAO, CRED_DISC, CRED_HIST, HORAS_AULA_DISC, HORAS_AULA_HIST, ESTAGIO, GRUPO_ELETIVA, SIT_DETALHE,                                                   
                                        SERIE_IDEAL, PENDENTE, ID_EQUIV)                                                  
            SELECT T.CURSO                              
     , T.TURNO                              
     , T.CURRICULO                              
     , T.ALUNO                              
     , X.ORIGEM                              
     , X.ANO                              
     , X.PERIODO                              
     , X.SERIE                              
     , X.DISC_ORIGINAL                              
     , UPPER(X.DISC_EQUIVALENTE) AS DISCIPLINA_EQUIV           --ATUALZIADO POR MIGUEL EM 26/02/2018 DEVIDO À ERRO DE CADASTRO NA GRADE                    
     , X.NOTA_FINAL                              
     , X.PERC_PRESENCA                              
     , X.SITUACAO                              
     , NULL AS CRED_DISC                              
     , X.CRED_HIST                              
     , NULL AS HORAS_AULA_DISC                              
     , X.HORAS_AULA_HIST                              
     , NULL AS ESTAGIO                              
     , X.GRUPO_ELETIVA                              
     , X.SIT_DETALHE                              
     , X.SERIE_IDEAL                              
     , CASE WHEN X.SITUACAO = 'Aprovado' OR X.SITUACAO = 'Dispensado' THEN 'N' ELSE 'S' END AS PENDENTE                              
     , X.ID_EQUIV                                                  
            FROM @TBL_HIST T                                    
            INNER JOIN (SELECT I.CURSO, I.TURNO, I.CURRICULO, I.ALUNO, I.ANO, I.PERIODO, I.DISCIPLINA, I.NOTA_FINAL, I.SITUACAO                                                   
                      , I.PERC_PRESENCA, I.HORAS_AULA_HIST, I.CRED_HIST, I.SERIE, E.GRUPO_ELETIVA                              
        , I.GRUPO_ELETIVA AS GRUPO_ELETIVA_HIST, I.SIT_DETALHE, I.ORIGEM, I.FORMULA_EQUIV                              
        , E.DISCIPLINA AS DISC_ORIGINAL, E.DISC_EQUIVALENTE, E.SERIE_IDEAL, E.ID                            
                             , ISNULL((SELECT MAX(ID_EQUIV) FROM @TBL_HIST_EQUIV),0) + RANK() OVER(PARTITION BY I.ALUNO ORDER BY E.CURSO, E.TURNO, E.CURRICULO, E.DISCIPLINA, E.ID) AS ID_EQUIV                                                  
                        FROM @TBL_IDENTIFICAR I           
                        INNER JOIN (SELECT * FROM #TBL_EQUIVALENCIAS T1 WHERE T1.ID = @v_ID) E ON I.CURSO = E.CURSO                               
                                                                            AND I.TURNO = E.TURNO                               
                         AND I.CURRICULO = E.CURRICULO                               
                         AND I.DISCIPLINA = E.DISC_EQUIVALENTE                                     
                        INNER JOIN @TBL_HIST T1 ON I.ALUNO = T1.ALUNO                               
                             AND E.DISCIPLINA = T1.DISCIPLINA) X ON T.CURSO = X.CURSO                               
                                                 AND T.TURNO = X.TURNO                               
                      AND T.CURRICULO = X.CURRICULO                                                   
                                                                                  AND T.ALUNO = X.ALUNO                               
                      AND T.DISCIPLINA = X.DISC_ORIGINAL                     
                             
        END --IF @v_VERIFICA > 0                                                          
        SELECT @v_ID_LOOP = MIN(ID_IDENTITY)                               
  FROM @TBL_LOOP_IDENTIFICA_EQUIV                               
  WHERE ID_IDENTITY > @v_ID_LOOP                                                  
 END                                                  
                                              
    -- -------------------------------------------------------------------                                                  
    -- 19) ELIMINA AS QUE JÁ FORAM IDENTIFICADAS NA EQUIVALENCIA E INSERIDAS NA @TBL_HIST_EQUIV                                                  
    -- CASO QUEIRA QUE A DISCIPLINA CURSADA SEJA UTILIZADA APENAS UMA VEZ PARA COMPENSAR OUTRA DA GRADE, COLOQUE DENTRO DO "IF @v_VERIFICA > 0" ACIMA                                                   
    -- -------------------------------------------------------------------                                                  
    DELETE I                                                  
    FROM @TBL_IDENTIFICAR I                                                  
    WHERE EXISTS (SELECT TOP 1 1                               
      FROM @TBL_HIST_EQUIV T                                                   
                  WHERE T.ALUNO = I.ALUNO AND T.DISCIPLINA_EQUIV = I.DISCIPLINA                                                   
                 )                                                  
                                                  
    -- -------------------------------------------------------------------                                                  
    -- 20) ATUALIZA O CAMPO PENDENTE DA TABELA PRINCIPAL DAS DISCIPLINAS QUE O ALUNO CURSOU A EQUIVALENCIA                                                  
    -- -------------------------------------------------------------------                                                  
    UPDATE T                               
 SET PENDENTE = 'N'                                                  
    FROM @TBL_HIST T                                                  
    INNER JOIN @TBL_HIST_EQUIV TA ON T.ALUNO = TA.ALUNO                               
 AND T.DISCIPLINA = TA.DISC_ORIGINAL                                                  
                                 AND T.CURSO = TA.CURSO                               
         AND T.TURNO = TA.TURNO                               
         AND T.CURRICULO = TA.CURRICULO                                                   
    WHERE TA.SITUACAO NOT LIKE 'Rep%'                                                  
    AND   NOT EXISTS (SELECT TOP 1 1                               
                   FROM @TBL_HIST_EQUIV TR                                                  
                      WHERE TR.SITUACAO LIKE 'Rep%'                               
       AND   TR.ALUNO = TA.ALUNO                               
       AND   TR.DISC_ORIGINAL = TA.DISC_ORIGINAL                                                  
                      AND   TR.CURSO = TA.CURSO                               
       AND   TR.TURNO = TA.TURNO                               
       AND   TR.CURRICULO = TA.CURRICULO)                                                  
                                                  
    -- -------------------------------------------------------------------                            
    -- 21) ATUALIZA O ID DA EQUIV NA TABELA PRINCIPAL A @TBL_HIST                                                  
    -- -------------------------------------------------------------------                                                  
    UPDATE T                               
 SET ID_EQUIV = E.ID_EQUIV                              
   , CURSOU_EQUIV = 'S'                                                  
    FROM @TBL_HIST T                                                  
    INNER JOIN @TBL_HIST_EQUIV E ON T.CURSO = E.CURSO                               
                             AND T.TURNO = E.TURNO                               
        AND T.CURRICULO = E.CURRICULO                               
        AND T.ALUNO = E.ALUNO                               
        AND T.DISCIPLINA = E.DISC_ORIGINAL                                                  
                              
    -- -------------------------------------------------------------------                                                  
    -- 22) CASO AINDA SOBRE DISCIPLINAS NA TABELA @TBL_IDENTIFICAR, SIGNIFICA QUE SÃO FORA DA GRADE.                               
 --     ENTÃO INSERE NA TABELA @TBL_HIST_DISCIPLINA_FORA_GRADE                                                   
    --     NÃO É DA GRADE DE OBRIGATÓRIAS                              
 --     NÃO É DA GRADE DE ELETIVAS                              
 --     NÃO ESTÁ NAS FÓRMULAS DE EQUIV NEM DA GRADE NEM DAS ELETIVAS                                                  
    -- -------------------------------------------------------------------                                                 
    INSERT INTO @TBL_HIST (UNID_RESP, UNID_FIS, TIPO, MODALIDADE, CURSO, TURNO, CURRICULO, PESSOA, ALUNO, ORIGEM, ANO,                      
                           PERIODO, SERIE_ALUNO, SERIE_IDEAL, SERIE, DISCIPLINA, NOTA_FINAL, PERC_PRESENCA, SITUACAO,                                                   
                           CRED_DISC, HORAS_AULA_DISC, ESTAGIO, CRED_HIST, HORAS_AULA_HIST, GRUPO_ELETIVA, SIT_DETALHE,                                                   
                           DISC_DA_GRADE, CURSOU_EQUIV, PENDENTE, FORMULA_EQUIV, ID_EQUIV)                                                  
    SELECT DISTINCT T.UNID_RESP                              
 , T.UNID_FIS                  
      , T.TIPO                              
      , T.MODALIDADE                              
      , T.CURSO                              
      , T.TURNO                              
      , T.CURRICULO                              
      , T.PESSOA                              
      , T.ALUNO                              
      , I.ORIGEM                              
      , I.ANO                              
      , I.PERIODO                              
      , T.SERIE_ALUNO                              
      , NULL AS SERIE_IDEAL                              
      , I.SERIE                              
      , I.DISCIPLINA                           
      , I.NOTA_FINAL                              
      , I.PERC_PRESENCA                              
      , I.SITUACAO                              
      , NULL AS CRED_DISC                              
      , NULL AS HORAS_AULA_DISC                              
      , NULL AS ESTAGIO                              
      , I.CRED_HIST                              
      , I.HORAS_AULA_HIST                              
      , I.GRUPO_ELETIVA                              
      , I.SIT_DETALHE                              
      , 'N' AS DISC_DA_GRADE                              
      , 'N' AS CURSOU_EQUIV                              
      , 'N' AS PENDENTE                              
      , NULL AS FORMULA_EQUIV                              
      , NULL AS ID_EQUIV              
    FROM (SELECT DISTINCT UNID_RESP, UNID_FIS, TIPO, MODALIDADE, CURSO, TURNO, CURRICULO, PESSOA, ALUNO, SERIE_ALUNO FROM @TBL_HIST) T                                                  
    INNER JOIN @TBL_IDENTIFICAR I ON T.CURSO = I.CURSO              
                              AND T.TURNO = I.TURNO                               
         AND T.CURRICULO = I.CURRICULO                               
         AND T.ALUNO = I.ALUNO                                                 
    WHERE NOT EXISTS (SELECT TOP 1 1                               
                   FROM @TBL_HIST T1                               
       WHERE T1.ALUNO = I.ALUNO                               
       AND   T1.DISCIPLINA = I.DISCIPLINA)                                                 
                              
    -- -------------------------------------------------------------------                              
    -- 23) PEGAR OS DEMAIS CAMPOS NECESSÁRIOS PARA MONTAR O RELATÓRIO                              
    -- -------------------------------------------------------------------                              
    DECLARE @TBL_HIST_DOCENTE TABLE (                                                  
        ALUNO           VARCHAR(20) COLLATE Latin1_General_CI_AI,                                                   
        ANO             NUMERIC(4,0),                                                   
        PERIODO         NUMERIC(2,0),                                                   
        DISCIPLINA      VARCHAR(20) COLLATE Latin1_General_CI_AI,                                                   
        NUM_FUNC        NUMERIC(15, 0),                                                   
        NOME_DOCENTE    VARCHAR(100) COLLATE Latin1_General_CI_AI,                  
  TITULACAO  VARCHAR(100) COLLATE Latin1_General_CI_AI                                                   
    )                                                  
                                                  
    DECLARE @TBL_HIST_DOCENTE_EQUIV TABLE (               
        ALUNO               VARCHAR(20) COLLATE Latin1_General_CI_AI,                                                   
        ANO                 NUMERIC(4,0),                                                   
        PERIODO             NUMERIC(2,0),                                                   
        DISCIPLINA          VARCHAR(20) COLLATE Latin1_General_CI_AI,                                                   
        NUM_FUNC            NUMERIC(15, 0),                                
        NOME_DOCENTE_EQUIV  VARCHAR(100) COLLATE Latin1_General_CI_AI,                    
  TITULACAO   VARCHAR(100) COLLATE Latin1_General_CI_AI                                             
    )                                                  
                                                  
    DECLARE @TBL_ALUNO TABLE (                                                  
        SIT_ALUNO       VARCHAR(15) COLLATE Latin1_General_CI_AI,                                                   
        CURSO           VARCHAR(20) COLLATE Latin1_General_CI_AI,                                                   
        ALUNO           VARCHAR(20) COLLATE Latin1_General_CI_AI,                                                   
        PESSOA          NUMERIC(10,0),                                                   
        TURNO           VARCHAR(20) COLLATE Latin1_General_CI_AI,                                                   
        CURRICULO       VARCHAR(20) COLLATE Latin1_General_CI_AI,                                                   
        NOME_COMPL      VARCHAR(100) COLLATE Latin1_General_CI_AI,                                                   
        CURSO_ANT       VARCHAR(100) COLLATE Latin1_General_CI_AI,                                                   
        OUTRA_FACULDADE VARCHAR(100) COLLATE Latin1_General_CI_AI,                                                   
        ANOCONCL_2G     NUMERIC(4,0),                                                   
        UNIDADE_FISICA  VARCHAR(20) COLLATE Latin1_General_CI_AI,                  
  RECONHECIMENTO  VARCHAR(300) COLLATE Latin1_General_CI_AI,                                                   
        CONCURSO        VARCHAR(20) COLLATE Latin1_General_CI_AI,                          
        DT_INGRESSO     DATETIME,                                                   
        TIPO_INGRESSO   VARCHAR(20) COLLATE Latin1_General_CI_AI,                                                   
       ANO_INGRESSO    NUMERIC(4,0),                                                   
        SEM_INGRESSO    NUMERIC(2,0)                                                   
    )                                                                
                                                  
    -- -------------------------------------------------------------------                                                  
    -- 24) TABELA PARA ARMAZENAR OS DOCENTES DAS DISCIPLINAS                                     
    -- -------------------------------------------------------------------                               
    INSERT INTO @TBL_HIST_DOCENTE(ALUNO, ANO, PERIODO, DISCIPLINA, NUM_FUNC, NOME_DOCENTE, TITULACAO)                                                  
    SELECT HD.ALUNO                              
      , HD.ANO                              
   , HD.PERIODO                              
   , HD.DISCIPLINA                            
   , HD.NUM_FUNC                              
   , PROF.NOME_COMPL AS NOME_DOCENTE                    
   , PROF.TITULACAO                                                
    FROM LY_HISTORICO_DOCENTE HD                                                   
    INNER JOIN LY_DOCENTE PROF ON HD.NUM_FUNC = PROF.NUM_FUNC                                                   
    WHERE EXISTS (SELECT TOP 1 1                               
      FROM @TBL_HIST T1                                                  
                  WHERE T1.ALUNO = HD.ALUNO COLLATE Latin1_General_CI_AI                                                  
                  AND   T1.ANO = HD.ANO                               
      AND   T1.PERIODO = HD.PERIODO                               
      AND   T1.DISCIPLINA = HD.DISCIPLINA COLLATE Latin1_General_CI_AI)                                                  
   AND EXISTS (SELECT TOP 1 1                     
    FROM LY_TURMA TX                    
    WHERE TX.ANO = HD.ANO                     
    AND TX.SEMESTRE = HD.PERIODO  /*AJUSTE REALIZADO POR MIGUEL PARA*/                    
    AND TX.DISCIPLINA = HD.DISCIPLINA /*REMOVER DUPLICAÇÕES NO HISTÓRICO*/                    
    AND TX.NUM_FUNC = HD.NUM_FUNC  /*EM 21/08/2018*/                    
    AND TX.TURMA = (SELECT TOP 1 HM1.TURMA                     
        FROM LY_HISTMATRICULA HM1                     
        WHERE HM1.ALUNO = HD.ALUNO                     
        AND HM1.DISCIPLINA = HD.DISCIPLINA                    
        AND HM1.ANO = HD.ANO                    
        AND HM1.SEMESTRE = HD.PERIODO)                    
   )                    
                                                      
    -- -------------------------------------------------------------------                                                  
    -- 25) TABELA PARA ARMAZENAR OS DADOS DO ALUNO                                       
    -- -------------------------------------------------------------------                               
    INSERT INTO @TBL_ALUNO(SIT_ALUNO, CURSO, ALUNO, PESSOA, TURNO, CURRICULO, NOME_COMPL, CURSO_ANT, OUTRA_FACULDADE, ANOCONCL_2G,                                                   
                           UNIDADE_FISICA, RECONHECIMENTO, CONCURSO,  DT_INGRESSO, TIPO_INGRESSO, ANO_INGRESSO, SEM_INGRESSO)                           
    SELECT DISTINCT A.SIT_ALUNO                              
               , A.CURSO                              
      , A.ALUNO                              
      , A.PESSOA                              
      , A.TURNO                              
      , A.CURRICULO                          
      , A.NOME_COMPL                              
      , A.CURSO_ANT                              
      , A.OUTRA_FACULDADE                              
      , A.ANOCONCL_2G                              
      , A.UNIDADE_FISICA              
   , UF.FL_FIELD_06 as RECONHECIMENTO           -- reconhecimento                  
      , A.CONCURSO                              
      , A.DT_INGRESSO                              
      , A.TIPO_INGRESSO                              
      , A.ANO_INGRESSO                              
      , A.SEM_INGRESSO                                                
    FROM LY_ALUNO A                   
 inner join LY_UNIDADE_FISICA UF on UF.UNIDADE_FIS=A.UNIDADE_FISICA       ---- ALTERAÇÃO PARA INCLUSÂO DO RECONHECIMENTO DA UNIDADE      LAERTE LAGO                              
    WHERE EXISTS (SELECT TOP 1 1                               
               FROM @TBL_HIST T                                                  
                  WHERE T.ALUNO = A.ALUNO COLLATE Latin1_General_CI_AI)                                                  
                                                 
    -- ------------------------------------------------------------------------------------                                                 
    -- 26) TABELA PARA ARMAZENAR O HISTÓRICO DO DOCENTE NAS DICIPLINAS EQUIVALENTES                                         
    -- ------------------------------------------------------------------------------------                                       
    INSERT INTO @TBL_HIST_DOCENTE_EQUIV(ALUNO, ANO, PERIODO, DISCIPLINA, NUM_FUNC, NOME_DOCENTE_EQUIV, TITULACAO)                                                  
    SELECT HD.ALUNO                              
      , HD.ANO                              
   , HD.PERIODO                              
   , HD.DISCIPLINA                              
   , HD.NUM_FUNC                              
   , PROF.NOME_COMPL AS NOME_DOCENTE                                                  
   , PROF.TITULACAO                  
    FROM LY_HISTORICO_DOCENTE HD                                                   
    INNER JOIN LY_DOCENTE PROF ON HD.NUM_FUNC = PROF.NUM_FUNC                                                   
    WHERE EXISTS (SELECT TOP 1 1                              
               FROM @TBL_HIST_EQUIV E                                                  
                  WHERE E.ALUNO = HD.ALUNO COLLATE Latin1_General_CI_AI                                                  
  AND   E.ANO = HD.ANO                               
      AND   E.PERIODO = HD.PERIODO                               
      AND   E.DISCIPLINA_EQUIV = HD.DISCIPLINA COLLATE Latin1_General_CI_AI)                           
                              
    -- ------------------------------------------------------------------------------------                                                 
    -- 27) TABELA PARA ARMAZENAR DADOS DA CONCLUSÃO DO ALUNO NO CURSO                                         
    -- ------------------------------------------------------------------------------------                                                  
   /*            
    SELECT ALUNO                              
      , DT_ENCERRAMENTO                              
   , DT_COLACAO, DT_DIPLOMA                              
   , REGISTRO, DT_REGISTRO                              
   , NOME_DIPLOMA                              
   , PROCESSO                              
   , LIVRO                              
   , FOLHAS                                
 INTO #LY_H_CURSOS_CONCL_AUX                                                 
    FROM LY_H_CURSOS_CONCL                                                   
    WHERE DT_REABERTURA IS NULL AND MOTIVO = 'Conclusao'                                      
 --Se o motivo for conclusão, a Data de Colação estará preenchida                              
 --AND   DT_COLACAO >= @P_DATA_CONCLUSAO_INICIO                                
   -- AND   DT_COLACAO <= @P_DATA_CONCLUSAO_TERMINO            
               
   select * from #LY_H_CURSOS_CONCL_AUX                              
      */                         
    -- ------------------------------------------------------------------------------------                                                 
    -- 28) TABELA PARA ARMAZENAR DADOS DO INGRESSO DO ALUNO NO CURSO (PROCESSO SELETIVO)              
    -- ------------------------------------------------------------------------------------                               
 SELECT TOP 1 DV.ALUNO                              
      , DV.ANO                              
   , DV.SEMESTRE                              
   , DV.OUTRA_FACULDADE AS LOCAL_CONCURSO_VEST                              
   , DV.TIPO_VESTIBULAR                              
   , DV.PONTOS AS PONTOS_VEST                              
   , DV.CLASSIFICACAO                              
   , DV.CLASSIF_CURSO                    
   , DV.CLASSIF_CONCURSO                              
   , DV.DTVEST                              
   , DNV.PROVAVEST                              
   , PV.DESCRICAO AS DESCR_PROVA_VEST                              
   , DNV.NOTA_PADRONIZADA                                
    INTO #VESTIBULAR_AUX                               
 FROM LY_DADOS_NOTA_VEST DNV                                                   
    LEFT OUTER JOIN LY_PROVA_VEST PV ON DNV.PROVAVEST = PV.PROVAVEST                              
    RIGHT OUTER JOIN LY_DADOS_VESTIBULAR DV ON DNV.ALUNO = DV.ALUNO AND DNV.ANO = DV.ANO AND DNV.SEMESTRE = DV.SEMESTRE                              
    AND EXISTS (SELECT TOP 1 1                               
                FROM @TBL_HIST TMP                              
                WHERE TMP.ALUNO = DNV.ALUNO COLLATE LATIN1_GENERAL_CI_AI)                              
                              
                                 
    -- ------------------------------------------------------------------------------------                                                 
    -- 29) TABELA DE RETORNO DO RELATÓRIO                              
    -- ------------------------------------------------------------------------------------                                                       
    INSERT INTO @TBL_HIST_SAIDA                                                  
    SELECT * FROM (                                                  
    SELECT DISTINCT A.SIT_ALUNO                              
      , A.ALUNO                              
      , A.TURNO                              
      , A.CURRICULO                              
      , DH.INFORMACAO AS OBSERVACAO_HIST                              
      , A.NOME_COMPL AS NOME_ALUNO                              
      , SEXO                              
      , P.DT_NASC                              
      , dbo.MOSTRA_MUNICIPIO_NOME(P.MUNICIPIO_NASC,P.Pais_Nasc) AS MUNICIPIO_NASC                                
      , dbo.MOSTRA_MUNICIPIO_UF(P.MUNICIPIO_NASC,P.Pais_Nasc) AS UF_NASC                              
      , P.NACIONALIDADE                              
      , P.TELEITOR_NUM                              
      , P.TELEITOR_ZONA                      , P.TELEITOR_SECAO                              
      , P.TELEITOR_DTEXP                              
      , P.CR_NUM                   
      , P.CR_CAT                              
      , P.CR_SERIE                              
      , P.CR_RM                              
      , P.CR_CSM                              
      , P.CR_DTEXP                              
      , P.RG_TIPO                              
      , P.RG_NUM                              
      , P.RG_EMISSOR                              
      , P.RG_UF                              
      , P.RG_DTEXP                              
      , P.CPF                              
      , P.NOME_PAI                              
      , P.NOME_MAE                              
      , A.CURSO_ANT                              
      , A.OUTRA_FACULDADE AS ESCOLA_CURSO_ANT                              
      , A.ANOCONCL_2G AS ANO_CONCL_CURSO_ANT                              
      , A.UNIDADE_FISICA                              
      , UF.NOME_COMP AS NOME_UNID_FIS                   
   , UF.FL_FIELD_06 AS RECONHECIMENTO          ---- RECONHECIMENTO                   
      , C.FACULDADE                              
      , UE.NOME_COMP AS NOME_UNID_ENSINO                              
      , C.CURSO                              
      , C.HABILITACAO                
      , C.NOME AS NOME_CURSO                              
      , C.DECRETO                              
      , A.CONCURSO                              
      , A.DT_INGRESSO                           
      , A.TIPO_INGRESSO                              
      , A.ANO_INGRESSO                            
      , A.SEM_INGRESSO                              
      , HCC.DT_ENCERRAMENTO                              
      , HCC.DT_COLACAO                              
      , HCC.DT_DIPLOMA                              
      , prv.DTVEST                  
      , PRV.CLASSIFICACAO                              
      , T.DISC_DA_GRADE                              
      , T.ORIGEM                              
      , CASE WHEN T.DISC_DA_GRADE = 'S' AND LEN(RTRIM(LTRIM(ISNULL(T.GRUPO_ELETIVA, ''))))<1 THEN 'O' /*OBRIGATÓRIA*/         
    ELSE CASE WHEN T.DISC_DA_GRADE = 'S' AND LEN(RTRIM(LTRIM(ISNULL(T.GRUPO_ELETIVA, ''))))>0 THEN 'E' /*ELETIVA*/         
     ELSE T.DISC_DA_GRADE  /*'N' FORA DA GRADE*/         
     END          
  END AS TIPO_DISC                              
      , T.GRUPO_ELETIVA                              
      , T.ANO                              
      , T.PERIODO                              
      , T.DISCIPLINA                              
      , LTRIM(RTRIM(ISNULL(D.NOME_COMPL,HM.NOME_DISC_ORIG))) AS NOME_DISC                              
      , DOC.NUM_FUNC                              
      , ISNULL(DOC.NOME_DOCENTE,HM.FL_FIELD_01) AS NOME_DOCENTE              
   , CASE WHEN DOC.NOME_DOCENTE IS NULL THEN HM.FL_FIELD_01              
    ELSE LTRIM(RTRIM(isnull(CAST(DOC.NOME_DOCENTE AS varchar(500)),''))) + LTRIM(RTRIM(isnull(' - ' + DOC.TITULACAO,'')))               
  END as DOCENTE_TITULACAO                  
      , DOC.TITULACAO                           
      , D.ESTAGIO                              
      , D.CREDITOS AS CRED_DISC                
      , D.HORAS_AULA AS HORAS_AULA_DISC                              
      , D.HORAS_LAB AS HORAS_LAB_DISC                              
      , D.HORAS_ATIV AS HORA_ATIV_DISC                              
      , (ISNULL(D.HORAS_AULA, 0) + ISNULL(D.HORAS_LAB, 0) + ISNULL(D.HORAS_ATIV, 0)) AS HORAS_AULA_GRADE                              
      , T.CRED_HIST                              
      , T.HORAS_AULA_HIST                              
      , CASE WHEN D.TEM_FREQ = 'N' OR T.SITUACAO = 'Dispensado' OR T.PERC_PRESENCA IS NULL THEN '-'         
    ELSE CAST(CAST(T.PERC_PRESENCA*100 AS DECIMAL(5,2)) AS VARCHAR)         
  END AS PERC_PRESENCA                              
      , CASE WHEN T.SITUACAO = 'Dispensado' THEN '-' ELSE T.NOTA_FINAL END AS NOTA_FINAL        
      , T.SITUACAO                                                   
      , T.SITUACAO AS SITUACAO_HISTORICO                                                         
      , T.SITUACAO AS SITUACAO_SIGLA_HISTORICO                              
      , T.PENDENTE                              
      , T.ID_EQUIV                              
      , NULL AS HORAS_AULA_EXIGIDA                              
      , NULL AS ATIV_COMPL_CH                              
      , NULL AS ATIV_COMPL_CH_TIPO                              
      , NULL AS TOT_HORAS_AULA_CUR                              
      , NULL AS HORAS_AULA_ATC_CUR                              
      , NULL AS CR_PERIODO                  
      , NULL AS CR_CURSO                              
      , NULL AS UNID_ENDERECO                              
      , NULL AS UNID_END_NUM                              
      , NULL AS UNID_END_COMPL                              
      , NULL AS UNID_BAIRRO                              
      , NULL AS UNID_MUNICIPIO                              
      , NULL AS UNID_UF_SIGLA_MUNI                              
      , NULL AS UNID_CEP                              
      , NULL AS UNID_FONE                              
      , NULL AS UNID_FAX                              
      , NULL AS UNID_WEB_SITE                              
      , NULL AS ASSINATURA_PRIMEIRA                               
      , NULL AS ASSINATURA_PRIMEIRA_RESPONSAVEL                               
      , NULL AS ASSINATURA_PRIMEIRA_DOCUMENTO                               
      , NULL AS ASSINATURA_SEGUNDA                              
      , NULL AS ASSINATURA_SEGUNDA_RESPONSAVEL                              
      , NULL AS ASSINATURA_SEGUNDA_DOCUMENTO            
      , ISNULL(ISNULL(T.SERIE_IDEAL, T.SERIE_ALUNO), T.SERIE) AS SERIE                                 
      , NULL AS ENADE_INGRESSANTE                                      
      , NULL AS ENADE_CONCLUINTE                                
    FROM @TBL_HIST T                                                  
    INNER JOIN @TBL_ALUNO A ON T.ALUNO = A.ALUNO                                                   
    LEFT OUTER JOIN LY_DADOS_HIST DH ON A.ALUNO = DH.ALUNO COLLATE Latin1_General_CI_AI                                                  
    LEFT OUTER JOIN LY_H_CURSOS_CONCL HCC WITH(NOLOCK) ON A.ALUNO = HCC.ALUNO COLLATE Latin1_General_CI_AI AND DT_REABERTURA IS NULL AND MOTIVO = 'Conclusao'             
    INNER JOIN LY_CURSO C ON A.CURSO = C.CURSO COLLATE Latin1_General_CI_AI                                                  
    INNER JOIN LY_PESSOA P ON A.PESSOA = P.PESSOA                                                   
    LEFT OUTER JOIN MUNICIPIO MN ON P.MUNICIPIO_NASC = MN.CODIGO                                                  
    INNER JOIN LY_DISCIPLINA D ON T.DISCIPLINA = D.DISCIPLINA COLLATE Latin1_General_CI_AI                                                
    LEFT OUTER JOIN #VESTIBULAR_AUX PRV ON A.ALUNO = PRV.ALUNO COLLATE Latin1_General_CI_AI                                                      
    LEFT OUTER JOIN @TBL_HIST_DOCENTE DOC ON T.ALUNO = DOC.ALUNO AND T.ANO = DOC.ANO AND T.PERIODO = DOC.PERIODO AND T.DISCIPLINA = DOC.DISCIPLINA                                                   
    INNER JOIN LY_UNIDADE_ENSINO UE ON C.FACULDADE = UE.UNIDADE_ENS                                                  
    LEFT OUTER JOIN LY_UNIDADE_FISICA UF ON A.UNIDADE_FISICA = UF.UNIDADE_FIS COLLATE Latin1_General_CI_AI                                          
    LEFT OUTER JOIN ly_histmatricula HM on HM.disciplina = D.DISCIPLINA and hm.ANO =t.ANO and hm.SEMESTRE = t.PERIODO and HM.aluno = A.ALUNO COLLATE Latin1_General_CI_AI        
 UNION                                                  
    SELECT DISTINCT         
  A.SIT_ALUNO                              
      , A.ALUNO                              
      , A.TURNO                              
      , A.CURRICULO                              
      , DH.INFORMACAO AS OBSERVACAO_HIST                              
      , A.NOME_COMPL AS NOME_ALUNO                              
      , p.SEXO                              
      , P.DT_NASC                                                           
      , dbo.MOSTRA_MUNICIPIO_NOME(P.MUNICIPIO_NASC,P.Pais_Nasc) AS MUNICIPIO_NASC                              
      , dbo.MOSTRA_MUNICIPIO_UF(P.MUNICIPIO_NASC,P.Pais_Nasc) AS UF_NASC                              
      , P.NACIONALIDADE                              
      , P.TELEITOR_NUM                              
      , P.TELEITOR_ZONA                              
      , P.TELEITOR_SECAO                              
      , P.TELEITOR_DTEXP                              
      , P.CR_NUM                              
      , P.CR_CAT                              
      , P.CR_SERIE                              
      , P.CR_RM                              
      , P.CR_CSM                              
      , P.CR_DTEXP                              
      , P.RG_TIPO                              
      , P.RG_NUM                              
      , P.RG_EMISSOR                        
      , P.RG_UF                              
      , P.RG_DTEXP                              
      , P.CPF                              
      , P.NOME_PAI                              
      , P.NOME_MAE                              
      , A.CURSO_ANT                              
      , A.OUTRA_FACULDADE AS ESCOLA_CURSO_ANT                              
      , A.ANOCONCL_2G AS ANO_CONCL_CURSO_ANT                            
      , A.UNIDADE_FISICA                              
      , UF.NOME_COMP AS NOME_UNID_FIS                              
   , UF.FL_FIELD_06 AS RECONHECIMENTO   -----  RECONHECIMENTO                   
      , C.FACULDADE                              
      , UE.NOME_COMP AS NOME_UNID_ENSINO                              
      , C.CURSO                              
      , C.HABILITACAO                    
      , C.NOME AS NOME_CURSO                              
      , C.DECRETO                              
      , A.CONCURSO                              
      , A.DT_INGRESSO                  
   , A.TIPO_INGRESSO                              
      , A.ANO_INGRESSO                              
      , A.SEM_INGRESSO                              
      , HCC.DT_ENCERRAMENTO                              
      , HCC.DT_COLACAO                              
      , HCC.DT_DIPLOMA                     
      , PRV.DTVEST  ---ALTERADO POR LAERTE                  
      , PRV.CLASSIFICACAO                              
      , 'E' AS DISC_DA_GRADE                              
      , E.ORIGEM AS ORIGEM_EQUIV                              
      , CASE WHEN LEN(RTRIM(LTRIM(ISNULL(E.GRUPO_ELETIVA, ''))))>1 THEN 'E' ELSE 'O' END AS TIPO_DISC_EQUIV                              
      , E.GRUPO_ELETIVA                              
      , E.ANO AS ANO_EQUIV                              
      , E.PERIODO AS PER_EQUIV                              
      , E.DISCIPLINA_EQUIV                              
      , LTRIM(RTRIM(DE.NOME_COMPL)) AS NOME_DISC_EQUIV                              
      , DOC_E.NUM_FUNC AS NUM_FUNC_EQUIV            
   , ISNULL(DOC_E.NOME_DOCENTE_EQUIV,HM.FL_FIELD_01) AS NOME_DOCENTE              
      , CASE WHEN DOC_E.NOME_DOCENTE_EQUIV IS NULL THEN HM.FL_FIELD_01              
   ELSE LTRIM(RTRIM(isnull(CAST(DOC_E.NOME_DOCENTE_EQUIV AS varchar(500)),''))) + LTRIM(RTRIM(isnull(' - ' + DOC_E.TITULACAO,'')))               
  END as DOCENTE_TITULACAO                                     
   , DOC_E.TITULACAO                  
     --ALTERADO 25/10/19 PARA PEGAR OS DADOS DA DISCIPLINA DA GRADE DO ALUNO PEDIDO POR JOSANE/JÉSSICA. --INICIO          
   , D.ESTAGIO          
   , D.CREDITOS AS CRED_DISC_EQUIV           
      , D.HORAS_AULA AS HORAS_AULA_DISC_EQUIV                              
      , D.HORAS_LAB AS HORAS_LAB_DISC                              
      , D.HORAS_ATIV AS HORA_ATIV_DISC                              
      , (ISNULL(D.HORAS_AULA, 0) + ISNULL(D.HORAS_LAB, 0) + ISNULL(D.HORAS_ATIV, 0)) AS HORAS_AULA_GRADE                              
      , T.CRED_HIST AS CRED_HIST_EQUIV                              
      , T.HORAS_AULA_HIST AS HORAS_AULA_HIST_EQUIV                  
     --ALTERADO 25/10/19 PARA PEGAR OS DADOS DA DISCIPLINA DA GRADE DO ALUNO PEDIDO POR JOSANE/JÉSSICA. --FIM          
      , CASE WHEN DE.TEM_FREQ = 'N' OR E.SITUACAO = 'Dispensado' OR E.PERC_PRESENCA IS NULL THEN '-' ELSE CAST(CAST(E.PERC_PRESENCA*100 AS DECIMAL(5,2)) AS VARCHAR) END AS PERC_PRESENCA_EQUIV                              
      , CASE WHEN E.SITUACAO = 'Dispensado' THEN '-' ELSE E.NOTA_FINAL END AS NOTA_FINAL                    
      , E.SITUACAO AS SITUACAO_EQUIV           
      , E.SITUACAO AS SITUACAO_HISTORICO                              
      , E.SITUACAO AS SITUACAO_SIGLA_HISTORICO                              
      , E.PENDENTE AS PENDENTE_EQUIV                              
      , E.ID_EQUIV                              
      , NULL AS HORAS_AULA_EXIGIDA                              
      , NULL AS ATIV_COMPL_CH                              
      , NULL AS ATIV_COMPL_CH_TIPO                              
      , NULL AS TOT_HORAS_AULA_CUR                              
      , NULL AS HORAS_AULA_ATC_CUR                              
      , NULL AS CR_PERIODO                              
      , NULL AS CR_CURSO                              
      , NULL AS UNID_ENDERECO                              
      , NULL AS UNID_END_NUM                              
      , NULL AS UNID_END_COMPL                              
      , NULL AS UNID_BAIRRO                              
      , NULL AS UNID_MUNICIPIO                              
      , NULL AS UNID_UF_SIGLA_MUNI                              
      , NULL AS UNID_CEP                              
      , NULL AS UNID_FONE                              
      , NULL AS UNID_FAX                              
      , NULL AS UNID_WEB_SITE                              
      , NULL AS ASSINATURA_PRIMEIRA                               
      , NULL AS ASSINATURA_PRIMEIRA_RESPONSAVEL                               
      , NULL AS ASSINATURA_PRIMEIRA_DOCUMENTO                               
      , NULL AS ASSINATURA_SEGUNDA                              
      , NULL AS ASSINATURA_SEGUNDA_RESPONSAVEL                              
      , NULL AS ASSINATURA_SEGUNDA_DOCUMENTO                              
      , ISNULL(ISNULL(T.SERIE_IDEAL, T.SERIE_ALUNO), T.SERIE) AS SERIE                                  
      , NULL AS ENADE_INGRESSANTE                                      
      , NULL AS ENADE_CONCLUINTE                                                
    FROM @TBL_HIST T                                                  
    LEFT OUTER JOIN @TBL_HIST_EQUIV E ON T.ALUNO = E.ALUNO AND T.ID_EQUIV = E.ID_EQUIV AND T.CURSO = E.CURSO AND T.TURNO = E.TURNO AND T.CURRICULO = E.CURRICULO                                                  
    INNER JOIN @TBL_ALUNO A ON T.ALUNO = A.ALUNO                                                   
    LEFT OUTER JOIN LY_DADOS_HIST DH ON A.ALUNO = DH.ALUNO COLLATE Latin1_General_CI_AI                                        
    LEFT OUTER JOIN LY_H_CURSOS_CONCL HCC WITH(NOLOCK) ON A.ALUNO = HCC.ALUNO COLLATE Latin1_General_CI_AI AND DT_REABERTURA IS NULL AND MOTIVO = 'Conclusao'                                                
    INNER JOIN LY_CURSO C ON A.CURSO = C.CURSO COLLATE Latin1_General_CI_AI                                                  
    INNER JOIN LY_PESSOA P ON A.PESSOA = P.PESSOA                                                   
    LEFT OUTER JOIN MUNICIPIO MN ON P.MUNICIPIO_NASC = MN.CODIGO                                                  
    LEFT OUTER JOIN LY_DISCIPLINA DE ON E.DISCIPLINA_EQUIV = DE.DISCIPLINA COLLATE Latin1_General_CI_AI -- NOME DISCIPLINA EQUIVALENTE                                                 
    LEFT OUTER JOIN LY_DISCIPLINA D ON T.DISCIPLINA = D.DISCIPLINA COLLATE Latin1_General_CI_AI -- NOME DISCIPLINA EQUIVALENTE                                                 
 LEFT OUTER JOIN #VESTIBULAR_AUX PRV ON A.ALUNO = PRV.ALUNO COLLATE Latin1_General_CI_AI                              
    LEFT OUTER JOIN @TBL_HIST_DOCENTE_EQUIV DOC_E ON E.ALUNO = DOC_E.ALUNO AND E.ANO = DOC_E.ANO AND E.PERIODO = DOC_E.PERIODO AND E.DISCIPLINA_EQUIV = DOC_E.DISCIPLINA COLLATE Latin1_General_CI_AI                                                  
    INNER JOIN LY_UNIDADE_ENSINO UE ON C.FACULDADE = UE.UNIDADE_ENS                                                  
    LEFT OUTER JOIN LY_UNIDADE_FISICA UF ON A.UNIDADE_FISICA = UF.UNIDADE_FIS COLLATE Latin1_General_CI_AI            
 LEFT OUTER JOIN ly_histmatricula HM on HM.disciplina = E.DISCIPLINA_EQUIV and HM.aluno = A.ALUNO COLLATE Latin1_General_CI_AI and hm.ANO = e.ANO and hm.SEMESTRE = e.PERIODO        
 ) X                                                  
                               
 -- -------------------------------------------------------------------                                                  
    -- 31) Formatação das notas                                           
    -- -------------------------------------------------------------------                               
 UPDATE @TBL_HIST_SAIDA                              
 SET NOTA_FINAL = '-'                              
 WHERE (NOTA_FINAL IS NULL OR NOTA_FINAL = '')                              
                              
    UPDATE @TBL_HIST_SAIDA                              
 SET NOTA_FINAL = REPLACE(CAST(CAST(REPLACE(NOTA_FINAL, ',', '.') AS DECIMAL(10,2)) AS VARCHAR), '.', ',')                              
 WHERE ISNUMERIC(NOTA_FINAL) = 1                              
 AND   NOTA_FINAL <> '-'                                 
                            -- -------------------------------------------------------------------                                                  
    -- 32) Elimina as disciplinas trancadas                                                  
    -- -------------------------------------------------------------------                                                  
    DELETE T                                                  
    FROM @TBL_HIST_SAIDA T                                                  
    WHERE T.SITUACAO = 'Trancado'                                                  
                                                  
    -- -------------------------------------------------------------------                                                  
    -- 33) TABELA COM AS INFORMAÇÕES DAS ATIVIDADES COMPLEMENTARES                                                  
    -- -------------------------------------------------------------------                                                  
    CREATE TABLE #TBL_ATIV_COMPL(                                                  
        ALUNO                   VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
      , CURSO                   VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
      , TURNO                   VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
      , CURRICULO               VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
      , TIPO_DISC               VARCHAR(255) COLLATE Latin1_General_CI_AI                                                  
      , ANO                     NUMERIC(4, 0)                                                  
      , PERIODO                 NUMERIC(2, 0)                                                  
      , DISCIPLINA        VARCHAR(255) COLLATE Latin1_General_CI_AI                                                   
      , NOME_DISC               VARCHAR(255) COLLATE Latin1_General_CI_AI                                                   
      , HORAS_AULA_HIST         DECIMAL(10, 2)                                                   
      , ATIV_COMPL_CH_TIPO      DECIMAL(10, 2)                                                  
    )                                            
                              
                                       
    INSERT INTO #TBL_ATIV_COMPL (ALUNO, CURSO, TURNO, CURRICULO, TIPO_DISC, ANO, PERIODO, DISCIPLINA, NOME_DISC, HORAS_AULA_HIST, ATIV_COMPL_CH_TIPO)                                                  
    SELECT AC.ALUNO                              
      , CC.CURSO                              
   , CC.TURNO                              
   , CC.CURRICULO                              
   , A.TIPO_ATIV_COMPL AS TIPO_DISC                              
   , AC.ANO AS ANO                              
   , AC.PERIODO AS PERIODO                              
   , A.TIPO_ATIV_COMPL AS DISCIPLINA                              
   , LTRIM(RTRIM(A.DESCRICAO)) AS NOME_DISC                              
   , AC.CH AS HORAS_AULA_HIST                              
   , CC.CH AS ATIV_COMPL_CH_TIPO                                                  
    FROM LY_ATIVIDADES_COMPLEMENTARES AC                                                   
    INNER JOIN LY_ATIVIDADES A ON AC.ATIVIDADE = A.ATIVIDADE COLLATE Latin1_General_CI_AI                                                   
    INNER JOIN LY_ATIV_COMPL_CARGA_HOR  CC ON A.TIPO_ATIV_COMPL = CC.TIPO_ATIV_COMPL                                                   
    WHERE EXISTS (SELECT TOP 1 1                               
               FROM @TBL_HIST_SAIDA T                                          
                  WHERE T.ALUNO = AC.ALUNO COLLATE Latin1_General_CI_AI                                                   
                  AND   T.CURSO = CC.CURSO COLLATE Latin1_General_CI_AI                                 
                  AND   T.TURNO = CC.TURNO COLLATE Latin1_General_CI_AI                                                   
                  AND   T.CURRICULO = CC.CURRICULO COLLATE Latin1_General_CI_AI)                                 
                                                    
    -- ------------------------------------------------------------------------------------                                                 
    -- 34) TABELA DE RETORNO DO RELATÓRIO                              
    -- ------------------------------------------------------------------------------------                                  
    INSERT INTO @TBL_HIST_SAIDA                           
    SELECT DISTINCT T.SIT_ALUNO                              
      , T.ALUNO                              
      , T.TURNO                              
      , T.CURRICULO                              
      , T.OBSERVACAO_HIST                              
      , T.NOME_ALUNO                              
      , T.SEXO                              
      , T.DT_NASC                              
      , T.MUNICIPIO_NASC                              
      , T.UF_NASC                              
      , T.NACIONALIDADE                              
      , T.TELEITOR_NUM                              
      , T.TELEITOR_ZONA                              
      , T.TELEITOR_SECAO                           
      , T.TELEITOR_DTEXP                              
      , T.CR_NUM                              
      , T.CR_CAT                              
      , T.CR_SERIE                              
      , T.CR_RM                              
      , T.CR_CSM                              
      , T.CR_DTEXP                              
      , T.RG_TIPO                              
      , T.RG_NUM                              
      , T.RG_EMISSOR                              
      , T.RG_UF                              
      , T.RG_DTEXP                              
      , T.CPF                              
      , T.NOME_PAI                              
      , T.NOME_MAE                              
      , T.CURSO_ANT                              
      , T.ESCOLA_CURSO_ANT                              
      , T.ANO_CONCL_CURSO_ANT                              
      , T.UNIDADE_FISICA                              
      , T.NOME_UNID_FIS                    
      , T.RECONHECIMENTO          ----------   RECONHECIMENTO                  
      , T.FACULDADE                              
      , T.NOME_UNID_ENSINO                              
      , T.CURSO                              
      , T.HABILITACAO                              
      , T.NOME_CURSO                              
      , T.DECRETO                              
      , T.CONCURSO                              
      , T.DT_INGRESSO                              
      , T.TIPO_INGRESSO                              
      , T.ANO_INGRESSO                              
      , T.SEM_INGRESSO                              
      , T.DT_ENCERRAMENTO                              
      , T.DT_COLACAO                              
      , T.DT_DIPLOMA                              
      , T.DTVEST ---ALTAERADO POR LAERTE                           
      , T.CLASSIFICACAO                              
      , 'N' AS DISC_DA_GRADE                              
      , 'ATVC' AS ORIGEM                              
      , AT.TIPO_DISC                              
      , NULL AS GRUPO_ELETIVA                              
      , AT.ANO                              
      , AT.PERIODO                              
      , AT.DISCIPLINA                              
      , LTRIM(RTRIM(AT.NOME_DISC)) AS NOME_DISC                              
      , LTRIM(RTRIM(isnull(CAST(T.NOME_DOCENTE AS varchar(500)),''))) + LTRIM(RTRIM(isnull(' - ' + T.TITULACAO,''))) as DOCENTE_TITULACAO                  
      , NULL AS NUM_FUNC                 
      , NULL AS NOME_DOCENTE                    
      , null AS TITULACAO                            
      , NULL AS ESTAGIO                              
      , NULL AS CRED_DISC                              
     , NULL AS HORAS_AULA_DISC                              
      , NULL AS HORAS_LAB_DISC                              
      , NULL AS HORAS_ATIV_DISC                              
      , NULL AS HORAS_AULA_GRADE                              
      , NULL AS CRED_HIST                              
      , AT.HORAS_AULA_HIST                              
      , NULL AS PERC_PRESENCA                              
      , NULL AS NOTA_FINAL                              
      , NULL AS SITUACAO                              
      , NULL AS SITUACAO_HISTORICO                              
      , NULL AS SITUACAO_SIGLA_HISTORICO                              
      , 'N' AS PENDENTE                              
      , NULL AS ID_EQUIV                              
      , NULL AS HORAS_AULA_EXIGIDA                              
      , NULL AS ATIV_COMPL_CH                           
      , AT.ATIV_COMPL_CH_TIPO                              
      , NULL AS TOT_HORAS_AULA_CUR                              
      , NULL AS HORAS_AULA_ATC_CUR                              
      , NULL AS CR_PERIODO                              
      , NULL AS CR_CURSO                              
      , NULL AS UNID_ENDERECO                              
      , NULL AS UNID_END_NUM                              
      , NULL AS UNID_END_COMPL                              
      , NULL AS UNID_BAIRRO                              
      , NULL AS UNID_MUNICIPIO                              
      , NULL AS UNID_UF_SIGLA_MUNI                              
      , NULL AS UNID_CEP                              
      , NULL AS UNID_FONE                              
      , NULL AS UNID_FAX                              
      , NULL AS UNID_WEB_SITE                              
      , NULL AS ASSINATURA_PRIMEIRA                               
      , NULL AS ASSINATURA_PRIMEIRA_RESPONSAVEL                               
      , NULL AS ASSINATURA_PRIMEIRA_DOCUMENTO                               
      , NULL AS ASSINATURA_SEGUNDA                              
      , NULL AS ASSINATURA_SEGUNDA_RESPONSAVEL                              
      , NULL AS ASSINATURA_SEGUNDA_DOCUMENTO                                 
      , T.SERIE                                      
      , T.ENADE_INGRESSANTE                              
      , T.ENADE_CONCLUINTE                              
    FROM @TBL_HIST_SAIDA T                                                   
    INNER JOIN #TBL_ATIV_COMPL AT ON T.ALUNO = AT.ALUNO                                                   
                                 AND T.CURSO = AT.CURSO                                                  
                                 AND T.TURNO = AT.TURNO                                                  
                               AND T.CURRICULO = AT.CURRICULO                                                   
                                                  
                                  
 -- ------------------------------- --                              
 -- 35A) ATUALIZAR SITUAÇÃO DA MATRÍCULA --                              
 -- ------------------------------- --                              
 UPDATE THS                              
 SET DECRETO = CD.DECRETO                              
 FROM @TBL_HIST_SAIDA THS                                                  
    INNER JOIN LY_CURSO_DECRETO CD ON THS.CURSO = CD.CURSO COLLATE LATIN1_GENERAL_CI_AI                                 
                               
 -- -------------------------------------------------------------------                                                  
    -- 35) ATUALIZA OS CAMPOS DE HORAS PREVISTAS NO CURRICULO (HORAS DO CURSO E ATIVIDADES COMPLEMENTARES)                                                  
    -- -------------------------------------------------------------------                                                  
    UPDATE T                               
 SET HORAS_AULA_EXIGIDA = C.AULAS_PREVISTAS                              
   , ATIV_COMPL_CH = C.ATIV_COMPL_CH                                    
    FROM @TBL_HIST_SAIDA T                              
    INNER JOIN LY_CURRICULO C ON T.CURSO = C.CURSO COLLATE LATIN1_GENERAL_CI_AI                                                   
                             AND T.TURNO = C.TURNO COLLATE LATIN1_GENERAL_CI_AI                                                   
                             AND T.CURRICULO = C.CURRICULO COLLATE LATIN1_GENERAL_CI_AI                                                  
                                                  
    -- -------------------------------------------------------------------                                                  
    -- 36) ATUALIZA O TOTAL DE AULAS CURSADAS                                                  
    -- -------------------------------------------------------------------                                                
           
 /*          
   UPDATE T                               
   SET TOT_HORAS_AULA_CUR = TOT_CUR.TOTAL_CURSADO                 
   FROM @TBL_HIST_SAIDA T                                                  
   INNER JOIN (SELECT X.ALUNO                              
                    , SUM(X.HORAS_AULA_HIST) TOTAL_CURSADO              
               FROM (SELECT DISTINCT T1.ALUNO                              
                          , T1.DISCIPLINA                              
           , T1.HORAS_AULA_HIST                                                  
                     FROM @TBL_HIST_SAIDA T1                                                  
                     WHERE T1.SITUACAO IN ('APROVADO','DISPENSADO')) X                                                  
               GROUP BY X.ALUNO) TOT_CUR ON T.ALUNO = TOT_CUR.ALUNO                                                  
--lixo--          
SELECT X.ALUNO                              
                    , SUM(X.HORAS_AULA_HIST) TOTAL_CURSADO                       
               FROM (SELECT DISTINCT T1.ALUNO                              
                          , T1.DISCIPLINA                              
           , T1.HORAS_AULA_HIST                                                  
                     FROM @TBL_HIST_SAIDA T1                                                  
                     WHERE T1.SITUACAO IN ('APROVADO','DISPENSADO')) X                                                  
               GROUP BY X.ALUNO          
--lixo--            
          
*/                            
    -- -------------------------------------------------------------------                                                  
    -- 37) ATUALIZA O TOTAL DE AULAS DE ATIVIDADES COMPLEMENTARES CURSADAS                                       
    -- -------------------------------------------------------------------                                               
    /*UPDATE T                               
 SET HORAS_AULA_ATC_CUR = TOT_CUR.TOTAL_CURSADO                                                  
    FROM @TBL_HIST_SAIDA T                                                  
    INNER JOIN (SELECT X.ALUNO                              
                  , SUM(X.HORAS_AULA_HIST) TOTAL_CURSADO                                                  
                FROM (SELECT T1.ALUNO                              
               , T1.ORIGEM                              
         , T1.HORAS_AULA_HIST                                                  
                      FROM @TBL_HIST_SAIDA T1                                                  
                      WHERE T1.ORIGEM = 'ATVC') X                                                  
                GROUP BY X.ALUNO) TOT_CUR ON T.ALUNO = TOT_CUR.ALUNO */                            
                            
    UPDATE T                               
     SET HORAS_AULA_ATC_CUR = (SELECT SUM(CH) FROM  LY_ATIVIDADES_COMPLEMENTARES  WHERE ALUNO=@P_ALUNO)                                                  
     FROM @TBL_HIST_SAIDA T                            
                                                     
                                                  
    -- -------------------------------------------------------------------                                             
    -- 38) ATUALIZA OS CAMPOS DO ENDEREÇO DA UNIDADE DE ENSINO                                                  
    -- -------------------------------------------------------------------                                                 
    UPDATE T                               
 SET UNID_ENDERECO = UE.ENDERECO                              
   , UNID_END_NUM = UE.END_NUM                              
   , UNID_END_COMPL = UE.END_COMPL                              
   , UNID_BAIRRO = UE.BAIRRO                              
   , UNID_MUNICIPIO = DBO.FNPROPRIEDADECAIXAALTA(M.NOME, 1)                              
   , UNID_UF_SIGLA_MUNI = M.UF_SIGLA                              
, UNID_CEP = UE.CEP                              
   , UNID_FONE = UE.FONE                              
   , UNID_FAX = UE.FAX                              
   , UNID_WEB_SITE = UE.WEB_SITE                                                  
    FROM @TBL_HIST_SAIDA T                                                   
    INNER JOIN LY_UNIDADE_ENSINO UE ON T.FACULDADE = UE.UNIDADE_ENS COLLATE LATIN1_GENERAL_CI_AI                                                   
    INNER JOIN MUNICIPIO M ON UE.MUNICIPIO = CODIGO                                        
    ---- ------------------------------------------------------                                                       
                                                  
    -- ----------------------- --                                                   
    -- 39) ATUALIZA ASSINATURA --                                                   
    -- ----------------------- --                                                   
    UPDATE T                         
 SET ASSINATURA_PRIMEIRA             = RD.FUNCAO                              
   , ASSINATURA_PRIMEIRA_RESPONSAVEL = RD.NOME                                 
   , ASSINATURA_PRIMEIRA_DOCUMENTO   = RD.RG_NUM                                              
    FROM @TBL_HIST_SAIDA T                                                   
    INNER JOIN (SELECT RC.NOME                              
                     , RC.FUNCAO                              
                  , RC.RG_NUM                              
                  , RC.CURSO                              
      , RC.DATA_INICIAL                              
      , RC.DATA_FINAL                              
                FROM LY_RESPONSAVEL_CURSO RC                              
                INNER JOIN (SELECT MAX(RC.ID_RESP_CURSO) AS ID_RESP_CURSO                              
                                 , RC.CURSO                                                   
                            FROM LY_RESPONSAVEL_CURSO RC                                                   
                            WHERE RC.FUNCAO = @P_ASSINATURA_PRIMEIRA                              
       AND   ((RC.DATA_INICIAL <= GETDATE() AND RC.DATA_FINAL >= GETDATE()) OR (RC.DATA_FINAL IS NULL))                               
                          GROUP BY RC.CURSO) RC_ID ON RC.ID_RESP_CURSO = RC_ID.ID_RESP_CURSO) RD ON T.CURSO = RD.CURSO COLLATE LATIN1_GENERAL_CI_AI                                                   
                                                  
    UPDATE T                                
 SET ASSINATURA_SEGUNDA             = RD.FUNCAO                              
   , ASSINATURA_SEGUNDA_RESPONSAVEL = RD.NOME                                 
   , ASSINATURA_SEGUNDA_DOCUMENTO   = RD.RG_NUM                                              
    FROM @TBL_HIST_SAIDA T                                                   
    INNER JOIN (SELECT RC.NOME                              
                     , RC.FUNCAO                              
                  , RC.RG_NUM                              
                  , RC.CURSO                              
      , RC.DATA_INICIAL                              
      , RC.DATA_FINAL                              
                FROM LY_RESPONSAVEL_CURSO RC                              
                INNER JOIN (SELECT MAX(RC.ID_RESP_CURSO) AS ID_RESP_CURSO                              
                                 , RC.CURSO                                                   
                            FROM LY_RESPONSAVEL_CURSO RC                                                   
          WHERE RC.FUNCAO = @P_ASSINATURA_SEGUNDA                              
       AND   ((RC.DATA_INICIAL <= GETDATE() AND RC.DATA_FINAL >= GETDATE()) OR (RC.DATA_FINAL IS NULL))                               
                       GROUP BY RC.CURSO) RC_ID ON RC.ID_RESP_CURSO = RC_ID.ID_RESP_CURSO) RD ON T.CURSO = RD.CURSO COLLATE LATIN1_GENERAL_CI_AI                                                   
                                                          
    -- ----------------------------------------------------------------------                                                  
    -- 40) ATUALIZA OS COEFICIENTES DE RENDIMENTOS CRES DO PERÍODO E DO CURSO                    
    -- ----------------------------------------------------------------------                                                  
    --COEFICIENTE DE RENDIMENTO SEMESTRAL                     
 UPDATE T                               
 SET CR_PERIODO  = IA.VALOR                              
    FROM @TBL_HIST_SAIDA T                               
    INNER JOIN LY_INDICE_ALUNO IA ON T.ALUNO = IA.ALUNO                               
      AND T.ANO = IA.ANO                              
            AND T.PERIODO = IA.PERIODO                              
 WHERE IA.INDICE <> 'GLOBAL'                              
                              
 --COEFICIENTE DE RENDIMENTO GLOBAL                              
    UPDATE T                               
 SET CR_CURSO  = IA.VALOR                              
    FROM @TBL_HIST_SAIDA T                               
    INNER JOIN LY_INDICE_ALUNO IA ON T.ALUNO = IA.ALUNO                               
    WHERE IA.INDICE = 'GLOBAL'                                
                          
 -- ------------------------------- --                              
 -- 41) ATUALIZAR SITUAÇÃO DA MATRÍCULA --                              
 -- ------------------------------- --                              
 UPDATE THS                              
 SET SITUACAO_HISTORICO       = DBO.FNSITUACAO_LEGENDA_HISTORICOGRADUCAO(THS.SITUACAO, 0, THS.ALUNO, THS.DISCIPLINA, THS.ANO, THS.PERIODO)                              
   , SITUACAO_SIGLA_HISTORICO = DBO.FNSITUACAO_LEGENDA_HISTORICOGRADUCAO(THS.SITUACAO, 1, THS.ALUNO, THS.DISCIPLINA, THS.ANO, THS.PERIODO)                               
 FROM @TBL_HIST_SAIDA THS                               
                              
    -- -------------------------------------------------------------------                           
    -- 42) ELIMINA AS PENDENTES CONFORME O PARÂMETRO                                                  
    -- -------------------------------------------------------------------                                                  
    IF @P_EXIBE_PENDENTES = 'N'                                                  
    BEGIN                                                  
        DELETE T                                                  
        FROM @TBL_HIST_SAIDA T                                                  
        WHERE EXISTS (SELECT TOP 1 1                  
                FROM @TBL_HIST_SAIDA T2                                                  
                      WHERE T2.ALUNO = T.ALUNO                               
       AND   T2.DISCIPLINA = T.DISCIPLINA                               
       AND   T2.PENDENTE = 'S')                                                  
    END                                        
                                
                                
 -- -------------------------------------------------------------------                              
    -- 43) ELIMINA AS PENDENTES CONFORME O PARÂMETRO                                
    --     SE (PENDENTE = N E SITUACAO = A CURSAR)                              
 --        SIGNIFICA QUE FOI CURSADA UMA EQUIVALÊNCIA                          
    -- -------------------------------------------------------------------                                 
   DELETE T                                                  
   FROM @TBL_HIST_SAIDA T                                                  
   WHERE EXISTS (SELECT TOP 1 1                               
                 FROM @TBL_HIST_SAIDA T2                                                  
                 WHERE T2.ALUNO = T.ALUNO                               
     AND   T2.DISCIPLINA = T.DISCIPLINA                               
     AND   T2.PENDENTE = 'N'                               
     AND   SITUACAO = 'A CURSAR')                               
                              
  -- -------------------------------------------------------------------                              
    -- 44) ENADE                
    -- -------------------------------------------------------------------                                 
 --INGRESSANTE                                
 UPDATE S                             
 SET ENADE_INGRESSANTE = ISNULL(TI.DESCR, ISNULL(MP.SITUACAO_ENADE, 'NÃO INFORMADO'))                              
 FROM             
   @TBL_HIST_SAIDA S INNER JOIN LY_MATRICULA_PROVAO MP ON S.ALUNO = MP.ALUNO AND S.CURSO = MP.CURSO            
   LEFT OUTER JOIN HD_TABELAITEM TI ON MP.SITUACAO_ENADE = TI.ITEM                              
 WHERE UPPER(MP.TIPO) = 'INGRESSANTE'                                         
                              
 --CONCLUINTE                               
 UPDATE S                                    
 SET ENADE_CONCLUINTE = ISNULL(TI.DESCR, ISNULL(MP.SITUACAO_ENADE, 'NÃO INFORMADO'))                              
 FROM @TBL_HIST_SAIDA S INNER JOIN LY_MATRICULA_PROVAO MP ON S.ALUNO = MP.ALUNO AND S.CURSO = MP.CURSO            
 LEFT OUTER JOIN HD_TABELAITEM TI ON MP.SITUACAO_ENADE = TI.ITEM                              
 WHERE UPPER(MP.TIPO) = 'CONCLUINTE'                               
                               
 -- -------------------------------------------------------------------                              
    -- 45) ELIMINA DISCIPLINAS NULAS                                            
    -- -------------------------------------------------------------------                                 
   DELETE T                                                    
   FROM @TBL_HIST_SAIDA T                                                    
   WHERE DISCIPLINA IS NULL                                
                    
   -- -------------------------------------------------------------------                              
    -- 46) ALTERA AS DISCIPLINAS EQUIVALENTES CURSADAS PELAS DISCIPLINAS DA GRADE DO ALUNO                    
 --  ADICIONADO POR MIGUEL EM 26/02/2018 A PEDIDO DA SECRETARIA GERAL.                    
    -- -------------------------------------------------------------------                                 
                       
   UPDATE T                                                  
   SET T.DISCIPLINA = D.DISCIPLINA,                    
  T.NOME_DISC = D.NOME,                    
  T.HORAS_AULA_HIST = D.CREDITOS                    
  --T.HORAS_AULA_DISC = D.CREDITOS                    
   FROM @TBL_HIST_SAIDA T                    
   JOIN @TBL_HIST_EQUIV T2 ON T2.DISCIPLINA_EQUIV = UPPER(T.DISCIPLINA)                    
   JOIN LY_DISCIPLINA D ON D.DISCIPLINA = T2.DISC_ORIGINAL                    
                    
               
    -- -------------------------------------------------------------------                                                  
    -- 51) REMOVE REGISTROS ADICIONAIS DE DISCIPLINAS, MANTENDO APENAS O MAIOR PERIODO LETIVO                    
 --  ADICIONADO POR MIGUEL EM 04/09/2018 A PEDIDO DA SECRETARIA GERAL.                                               
    -- -------------------------------------------------------------------                       
                    
                        
 DELETE T1 FROM @TBL_HIST_SAIDA T1                    
 WHERE EXISTS (                    
  SELECT * FROM @TBL_HIST_SAIDA T2                    
  WHERE T2.DISCIPLINA = T1.DISCIPLINA                    
  AND CONCAT(T2.ANO,T2.PERIODO) > CONCAT(T1.ANO,T1.PERIODO)                    
 )                        
                            
 -- -------------------------------------------------------------------                                                  
    -- 50) ATUALIZA A CH CURSADA NO HISTORICO PARA DISCIPLINAS EQUIVALENTES                    
 --  ADICIONADO POR MIGUEL EM 03/09/2018 A PEDIDO DA SECRETARIA GERAL.                                               
    -- -------------------------------------------------------------------                       
                    
   UPDATE T                               
   SET HORAS_AULA_HIST = HORAS_AULA_GRADE                    
 FROM @TBL_HIST_SAIDA T                                                  
   INNER JOIN (SELECT X.ALUNO                              
                    , SUM(X.HORAS_AULA_HIST) TOTAL_CURSADO           
               FROM (SELECT DISTINCT T1.ALUNO                              
                          , T1.DISCIPLINA                              
           , T1.HORAS_AULA_HIST                                                  
                     FROM @TBL_HIST_SAIDA T1                                                  
                     WHERE T1.SITUACAO IN ('APROVADO','DISPENSADO')) X                                                  
     GROUP BY X.ALUNO) TOT_CUR ON T.ALUNO = TOT_CUR.ALUNO              
                    
    -- -------------------------------------------------------------------                                                  
    -- 53) ATUALIZA O NOME E A CARGA HORA DA DISCIPLINA EQUIVALENTE PARA A DISCIPLINA DA GRADE DO ALUNO                    
 --    ADICIONADO POR MIGUEL EM 04/09/2018 A PEDIDO DA SECRETARIA GERAL.                                               
    -- -------------------------------------------------------------------                       
                       
 UPDATE T                               
   SET T.NOME_DISC = D.NOME, T.HORAS_AULA_HIST = D.CH_TOTAL, T.HORAS_AULA_GRADE = D.CH_TOTAL                    
   FROM @TBL_HIST_SAIDA T                    
   JOIN (SELECT DISTINCT DISCIPLINA, CURSO, TURNO, CURRICULO, FORMULA_EQUIV FROM LY_GRADE) X ON X.CURSO = T.CURSO AND X.CURRICULO = T.CURRICULO AND X.TURNO = T.TURNO AND X.DISCIPLINA = T.DISCIPLINA                    
   JOIN (SELECT DISTINCT SUM(HORAS_AULA+HORAS_LAB+HORAS_ATIV+HORAS_ESTAGIO) AS CH_TOTAL, DISCIPLINA, NOME FROM LY_DISCIPLINA GROUP BY DISCIPLINA,NOME) D ON D.DISCIPLINA = X.DISCIPLINA                                                  
   WHERE 1=1--T.DISC_DA_GRADE = 'E'           
          
    -- -------------------------------------------------------------------                                                  
    -- 52) ATUALIZA CH DO HISTORICO PARA ZERO EM DISCIPLINAS REPROVADAS.                    
 --  DESSA FORMA, O RELATÓRIO CONTABILIZARÁ APENAS AS APROVADAS/DISPENSADAS                    
 --  ADICIONADO POR MIGUEL EM 04/09/2018 A PEDIDO DA SECRETARIA GERAL.                                               
    -- -------------------------------------------------------------------                       
                       
   UPDATE T                               
   SET T.HORAS_AULA_HIST = 0.00                    
   FROM @TBL_HIST_SAIDA T                                                  
   WHERE T.SITUACAO NOT IN ('APROVADO','DISPENSADO')               
             
   -- -------------------------------------------------------------------                                                  
    -- 48) ATUALIZA O TOTAL DE AULAS CURSADAS NOVAMENTE                      
 --  ADICIONADO POR MIGUEL EM 26/02/2018 A PEDIDO DA SECRETARIA GERAL.                                               
    -- -------------------------------------------------------------------                                                
   UPDATE T                               
   SET TOT_HORAS_AULA_CUR = TOT_CUR.TOTAL_CURSADO                                                  
   FROM @TBL_HIST_SAIDA T              
   INNER JOIN (SELECT X.ALUNO                              
                    , SUM(X.HORAS_AULA_HIST) TOTAL_CURSADO                       
               FROM (SELECT DISTINCT T1.ALUNO                              
                          , T1.DISCIPLINA                              
           , T1.HORAS_AULA_HIST                                                  
                     FROM @TBL_HIST_SAIDA T1                                                  
                     WHERE T1.SITUACAO IN ('APROVADO','DISPENSADO')) X                                                  
               GROUP BY X.ALUNO) TOT_CUR ON T.ALUNO = TOT_CUR.ALUNO                                    
                      
              
 -- -------------------------------------------------------------------                                                  
    -- 49) ATUALIZA O TOTAL DE AULAS CURSADAS PARA O TOTAL EXIGIDO CASO ESTE SEJA MAIOR.                      
 --  ADICIONADO POR MIGUEL EM 22/08/2018 A PEDIDO DA SECRETARIA GERAL.                                               
    -- -------------------------------------------------------------------                                                
   UPDATE T                               
   SET TOT_HORAS_AULA_CUR = HORAS_AULA_EXIGIDA                                                
   FROM @TBL_HIST_SAIDA T                                                  
   WHERE TOT_HORAS_AULA_CUR > HORAS_AULA_EXIGIDA               
      -- -------------------------------------------------------------------                                                  
    -- 53) REMOVE DO REGISTRO DISCIPLINAS IGUAIS COM DOCENTES DIFERENTES DEVIDO A MUDANÇA DE DOCENTE (DOCENTE A DEFINIR)                    
 --    ADICIONADO POR MIGUEL EM 11/09/2018 A PEDIDO DA SECRETARIA GERAL.                                               
    -- -------------------------------------------------------------------                       
 --DELETE FROM @TBL_HIST_SAIDA WHERE NUM_FUNC IN ('825','1','388')                               
                                 
 -- -------------------------------------------------------------------                                                  
    -- 47) SELECT FINAL PARA O RELATÓRIO                                                   
    -- -------------------------------------------------------------------                                         
 IF @P_EXIBE_REPROVADAS = 'S'                              
 BEGIN                                                  
select DISTINCT   
 SIT_ALUNO  
 , ALUNO  
 , TURNO  
 , CURRICULO  
 , OBSERVACAO_HIST  
 , NOME_ALUNO  
 , SEXO  
 , DT_NASC  
 , MUNICIPIO_NASC  
 , UF_NASC  
 , NACIONALIDADE  
 , TELEITOR_NUM  
 , TELEITOR_ZONA  
 , TELEITOR_SECAO  
 , TELEITOR_DTEXP  
 , CR_NUM  
 , CR_CAT  
 , CR_SERIE  
 , CR_RM  
 , CR_CSM  
 , CR_DTEXP  
 , RG_TIPO  
 , RG_NUM  
 , RG_EMISSOR  
 , RG_UF  
 , RG_DTEXP  
 , CPF  
 , NOME_PAI  
 , NOME_MAE  
 , CURSO_ANT  
 , ESCOLA_CURSO_ANT  
 , ANO_CONCL_CURSO_ANT  
 , UNIDADE_FISICA  
 , NOME_UNID_FIS  
 , RECONHECIMENTO  
 , FACULDADE  
 , NOME_UNID_ENSINO  
 , CURSO  
 , HABILITACAO  
 , NOME_CURSO  
 , DECRETO  
 , CONCURSO  
 , DT_INGRESSO  
 , TIPO_INGRESSO  
 , ANO_INGRESSO  
 , SEM_INGRESSO  
 , DT_ENCERRAMENTO  
 , DT_COLACAO  
 , DT_DIPLOMA  
 , DTVEST  
 , CLASSIFICACAO  
 , DISC_DA_GRADE  
 , ORIGEM  
 , TIPO_DISC  
 , GRUPO_ELETIVA  
 , ANO  
 , PERIODO  
 , DISC.DISCIPLINA  
 , NOME_DISC  
 , DISC.NUM_FUNC  
 , DISC.NOME_DOCENTE  
 , DISC.DOCENTE_TITULACAO  
 , DISC.TITULACAO  
 , ESTAGIO  
 , CRED_DISC  
 , HORAS_AULA_DISC  
 , HORAS_LAB_DISC  
 , HORAS_ATIV_DISC  
 , HORAS_AULA_GRADE  
 , CRED_HIST  
 , HORAS_AULA_HIST  
 , DISC.PERC_PRESENCA  
 , DISC.NOTA_FINAL  
 , SITUACAO  
 , SITUACAO_HISTORICO  
 , SITUACAO_SIGLA_HISTORICO  
 , PENDENTE  
 , ID_EQUIV  
 , HORAS_AULA_EXIGIDA  
 , ATIV_COMPL_CH  
 , ATIV_COMPL_CH_TIPO  
 , TOT_HORAS_AULA_CUR  
 , HORAS_AULA_ATC_CUR  
 , CR_PERIODO  
 , CR_CURSO  
 , UNID_ENDERECO  
 , UNID_END_NUM  
 , UNID_END_COMPL  
 , UNID_BAIRRO  
 , UNID_MUNICIPIO  
 , UNID_UF_SIGLA_MUNI  
 , UNID_CEP  
 , UNID_FONE  
 , UNID_FAX  
 , UNID_WEB_SITE  
 , ASSINATURA_PRIMEIRA  
 , ASSINATURA_PRIMEIRA_RESPONSAVEL  
 , ASSINATURA_PRIMEIRA_DOCUMENTO  
 , ASSINATURA_SEGUNDA  
 , ASSINATURA_SEGUNDA_RESPONSAVEL  
 , ASSINATURA_SEGUNDA_DOCUMENTO  
 , SERIE  
 , ENADE_INGRESSANTE  
 , ENADE_CONCLUINTE   
  FROM @TBL_HIST_SAIDA T    
  --PEDIDO POR MEDICINA PARA AGRUPAR DISCIPLINA COM MAIOR NOTA  
   OUTER APPLY(  
  SELECT TOP 1 DISCIPLINA, NOTA_FINAL,NUM_FUNC, NOME_DOCENTE,DOCENTE_TITULACAO, TITULACAO, PERC_PRESENCA  
  FROM   
   @TBL_HIST_SAIDA T2  
  WHERE  
   T.ALUNO = T2.ALUNO  
   AND T.ANO = T2.ANO  
   AND T.PERIODO = T2.PERIODO  
   AND T.DISCIPLINA = T2.DISCIPLINA  
  ORDER BY NOTA_FINAL DESC  
   ) DISC  
  
  WHERE (DISC_DA_GRADE IN ('S', 'E') OR (DISC_DA_GRADE = 'N' AND ORIGEM = 'ATVC'))                              
  ORDER BY T.ORIGEM DESC   
    
 END                                       
    ELSE                                    
 BEGIN                                             
    SELECT  DISTINCT  
 SIT_ALUNO  
 , ALUNO  
 , TURNO  
 , CURRICULO  
 , OBSERVACAO_HIST  
 , NOME_ALUNO  
 , SEXO  
 , DT_NASC  
 , MUNICIPIO_NASC  
 , UF_NASC  
 , NACIONALIDADE  
 , TELEITOR_NUM  
 , TELEITOR_ZONA  
 , TELEITOR_SECAO  
 , TELEITOR_DTEXP  
 , CR_NUM  
 , CR_CAT  
 , CR_SERIE  
 , CR_RM  
 , CR_CSM  
 , CR_DTEXP  
 , RG_TIPO  
 , RG_NUM  
 , RG_EMISSOR  
 , RG_UF  
 , RG_DTEXP  
 , CPF  
 , NOME_PAI  
 , NOME_MAE  
 , CURSO_ANT  
 , ESCOLA_CURSO_ANT  
 , ANO_CONCL_CURSO_ANT  
 , UNIDADE_FISICA  
 , NOME_UNID_FIS  
 , RECONHECIMENTO  
 , FACULDADE  
 , NOME_UNID_ENSINO  
 , CURSO  
 , HABILITACAO  
 , NOME_CURSO  
 , DECRETO  
 , CONCURSO  
 , DT_INGRESSO  
 , TIPO_INGRESSO  
 , ANO_INGRESSO  
 , SEM_INGRESSO  
 , DT_ENCERRAMENTO  
 , DT_COLACAO  
 , DT_DIPLOMA  
 , DTVEST  
 , CLASSIFICACAO  
 , DISC_DA_GRADE  
 , ORIGEM  
 , TIPO_DISC  
 , GRUPO_ELETIVA  
 , ANO  
 , PERIODO  
 , DISC.DISCIPLINA  
 , NOME_DISC  
 , DISC.NUM_FUNC  
 , DISC.NOME_DOCENTE  
 , DISC.DOCENTE_TITULACAO  
 , DISC.TITULACAO  
 , ESTAGIO  
 , CRED_DISC  
 , HORAS_AULA_DISC  
 , HORAS_LAB_DISC  
 , HORAS_ATIV_DISC  
 , HORAS_AULA_GRADE  
 , CRED_HIST  
 , HORAS_AULA_HIST  
 , DISC.PERC_PRESENCA  
 , DISC.NOTA_FINAL  
 , SITUACAO  
 , SITUACAO_HISTORICO  
 , SITUACAO_SIGLA_HISTORICO  
 , PENDENTE  
 , ID_EQUIV  
 , HORAS_AULA_EXIGIDA  
 , ATIV_COMPL_CH  
 , ATIV_COMPL_CH_TIPO  
 , TOT_HORAS_AULA_CUR  
 , HORAS_AULA_ATC_CUR  
 , CR_PERIODO  
 , CR_CURSO  
 , UNID_ENDERECO  
 , UNID_END_NUM  
 , UNID_END_COMPL  
 , UNID_BAIRRO  
 , UNID_MUNICIPIO  
 , UNID_UF_SIGLA_MUNI  
 , UNID_CEP  
 , UNID_FONE  
 , UNID_FAX  
 , UNID_WEB_SITE  
 , ASSINATURA_PRIMEIRA  
 , ASSINATURA_PRIMEIRA_RESPONSAVEL  
 , ASSINATURA_PRIMEIRA_DOCUMENTO  
 , ASSINATURA_SEGUNDA  
 , ASSINATURA_SEGUNDA_RESPONSAVEL  
 , ASSINATURA_SEGUNDA_DOCUMENTO  
 , SERIE  
 , ENADE_INGRESSANTE  
 , ENADE_CONCLUINTE   
 FROM @TBL_HIST_SAIDA T  
  --PEDIDO POR MEDICINA PARA AGRUPAR DISCIPLINA COM MAIOR NOTA  
  OUTER APPLY(  
  SELECT TOP 1 DISCIPLINA, NOTA_FINAL,NUM_FUNC, NOME_DOCENTE,DOCENTE_TITULACAO, TITULACAO, PERC_PRESENCA  
  FROM   
   @TBL_HIST_SAIDA T2  
  WHERE  
   T.ALUNO = T2.ALUNO  
   AND T.ANO = T2.ANO  
   AND T.PERIODO = T2.PERIODO  
   AND T.DISCIPLINA = T2.DISCIPLINA  
  ORDER BY NOTA_FINAL DESC  
   ) DISC  
 WHERE (SITUACAO NOT LIKE 'REP%' OR SITUACAO IS NULL)                                      
 AND   (DISC_DA_GRADE IN ('S', 'E') OR (DISC_DA_GRADE = 'N' AND ORIGEM = 'ATVC'))                                                       
 END                                         
END 