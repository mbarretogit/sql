use LYCEUM
go

CREATE FUNCTION dbo.INS_fnENCARGOS(
    @p_COBRANCA         T_NUMERO,
    @p_TIPO_ENCARGO     T_CODIGO, 
    @p_CATEGORIA        T_ALFASMALL, 
    @p_DATA_VENC        T_DATA,
    @p_DATA_PAGAMENTO   T_DATA,
    @p_VALOR_BASE       decimal(14,6),
    @p_VALOR_COBRANCA   decimal(14,6),
    @p_VALOR_A_APLICAR  decimal(14,6),
    @p_TIPO_BOLSA       T_CODIGO,
    @p_TIPO_CALCULO     T_TIPO_TAXA
)
RETURNS NUMERIC(10,2)

AS
BEGIN

    DECLARE @v_DIAS_ATRASADOS INT
    DECLARE @v_VALOR_ENCARGO DECIMAL(10,6)
    DECLARE @v_TIPO_CALCULO VARCHAR(15)

    DECLARE @v_TIPO_ENCARGO T_CODIGO
    DECLARE @v_CODIGO_LANC T_CODIGO
    DECLARE @v_TIPO_BOLSA T_CODIGO
    DECLARE @v_VALOR_BOLSA DECIMAL(10,6)

    DECLARE @v_CURSO T_CODIGO
    DECLARE @v_FACULDADE T_CODIGO
    DECLARE @v_OPCAO T_NUMERO 
    DECLARE @v_ANO_CONTRATO T_ANO   
    DECLARE @v_PERIODO_CONTRATO T_SEMESTRE2       
    DECLARE @v_PERDE_BOLSA_PARCATUAL T_SIMNAO
    DECLARE @v_LANC_DEB T_NUMERO
    DECLARE @v_PARCELA T_NUMERO
    DECLARE @v_VALOR_BOLSA_AUX decimal (14,6)
    DECLARE @v_VALOR_BOLSA_AUX2 decimal (14,6)

      DECLARE @v_dias T_NUMERO
      DECLARE @v_ValorMes decimal (14,6)
      DECLARE @v_ValorAcumulado decimal (14,8)
      DECLARE @v_substitui  VARCHAR(1)
      DECLARE @v_valor_nao_pago decimal(14,6)
      DECLARE @v_valor_cobranca T_NUMERO
      DECLARE @v_pre_calculado varchar(1)
      DECLARE @v_valor_pre_calculado decimal(14,2)
  
      DECLARE @v_VALOR_CALCULADO decimal(14,6)

    SET @v_VALOR_CALCULADO = 0

    ----- INÍCIO FUNÇÃO DE DIA ÚTIL -----
    SET @p_DATA_VENC = dbo.fn_Dia_Util(@p_COBRANCA,@p_DATA_VENC)    
    ------- FIM FUNÇÃO DE DIA ÚTIL -------
	
    SELECT @V_DIAS_ATRASADOS = DATEDIFF(day, @p_DATA_VENC, @p_DATA_PAGAMENTO)

    IF @v_DIAS_ATRASADOS > 0
    BEGIN  

	    IF 	@p_CATEGORIA = 'Multa'
	    BEGIN
		    IF @p_TIPO_CALCULO = 'VALOR'
		      SELECT @v_VALOR_CALCULADO = @p_VALOR_A_APLICAR
		    ELSE
		      SELECT @v_VALOR_CALCULADO = @p_VALOR_BASE * @p_VALOR_A_APLICAR
        END
    
	    IF 	@p_CATEGORIA = 'Juros'
        BEGIN
          SELECT @v_dias = DATEDIFF(day, @p_data_venc, @p_data_pagamento) 

          SELECT @v_pre_calculado = PRE_CALCULADO
          FROM LY_TIPO_ENCARGOS
          WHERE TIPO_ENCARGO = @p_tipo_encargo 
           

          SET @v_pre_calculado = isnull( @v_pre_calculado , 'N')

    
          IF @p_tipo_calculo = 'Valor'
            IF @v_pre_calculado = 'N'
              SELECT @v_VALOR_CALCULADO = @p_valor_a_aplicar * @v_dias
            ELSE
              BEGIN
                SET @v_valor_pre_calculado = @p_valor_a_aplicar 
                SET @v_VALOR_CALCULADO = @v_valor_pre_calculado * @v_dias
              END
          ELSE
            BEGIN
              IF @v_pre_calculado = 'N'
                SELECT @v_VALOR_CALCULADO = @p_valor_base * @p_valor_a_aplicar  * @v_dias
              ELSE 
                BEGIN
                  SET @v_valor_pre_calculado = @p_valor_base * @p_valor_a_aplicar 
                  SET @v_VALOR_CALCULADO = @v_valor_pre_calculado * @v_dias
                END
            END
        END
	
	    IF 	@p_CATEGORIA = 'PerdeBolsa'
        BEGIN
          --Encontra o debito e parcela para a bolsa para verificar a parametrização do perda bolsa na última parcela
          DECLARE C_DEBITO2 CURSOR STATIC READ_ONLY FOR        
          SELECT distinct i.LANC_DEB
          FROM LY_ITEM_LANC i, LY_BOLSA b, LY_COBRANCA c
          WHERE i.COBRANCA = c.COBRANCA AND
                c.COBRANCA = @p_cobranca AND
                c.ALUNO = b.ALUNO AND
                i.NUM_BOLSA = b.NUM_BOLSA AND
                b.TIPO_BOLSA = @p_tipo_bolsa AND
                i.LANC_DEB IS NOT NULL
          GROUP BY i.LANC_DEB
       
          OPEN C_DEBITO2        
          FETCH NEXT FROM C_DEBITO2 INTO  @v_lanc_deb

          select @v_valor_bolsa = 0
             
          WHILE @@FETCH_STATUS = 0        
            BEGIN        
              SELECT @v_valor_bolsa_aux = 0

              SELECT @v_parcela = MAX(PARCELA)
              FROM LY_ITEM_LANC i, LY_BOLSA b, LY_COBRANCA c
              WHERE i.COBRANCA = c.COBRANCA AND
                    c.COBRANCA = @p_cobranca AND
                    c.ALUNO = b.ALUNO AND
                    i.NUM_BOLSA = b.NUM_BOLSA AND
                    b.TIPO_BOLSA = @p_tipo_bolsa AND
                    i.LANC_DEB = @v_lanc_deb
          	
              SELECT @v_Perde_Bolsa_ParcAtual = 'N'        
           
              IF @v_lanc_deb IS NOT NULL
                BEGIN
                  SELECT @v_ano_contrato = D.ANO_REF, @v_periodo_contrato = D.PERIODO_REF, @v_curso = A.CURSO
                  FROM  LY_LANC_DEBITO D, LY_ALUNO A
                  WHERE D.ALUNO  = A.ALUNO
                        AND D.LANC_DEB = @v_lanc_deb
                 
                  -- encontrar a chave da tabela de opções financeiras que deverá ser utilizada        
                  SELECT @v_faculdade = FACULDADE FROM LY_CURSO WHERE CURSO = @v_curso        
              
                  select @v_opcao = null        
                  SELECT @v_opcao = max(f.opcao)         
                  FROM LY_OPCOES_FINAN f, LY_OPCOES_FINAN_CURSO fc        
                  WHERE f.OPCAO = fc.OPCAO AND        
                        ANO = @v_ano_contrato AND        
                        PERIODO = @v_periodo_contrato AND        
                        FACULDADE = @v_faculdade AND        
                        CURSO = @v_curso         
               
                  IF @v_opcao is null        
                    SELECT @v_opcao = max(f.opcao)         
                    FROM LY_OPCOES_FINAN f , LY_OPCOES_FINAN_UNID fc        
                    WHERE f.OPCAO = fc.OPCAO AND        
                        ANO = @v_ano_contrato AND        
                        PERIODO = @v_periodo_contrato AND        
                        FACULDADE = @v_faculdade AND        
                        not exists ( SELECT 1 FROM  LY_OPCOES_FINAN_CURSO where OPCAO = fc.OPCAO AND        
                                                                      FACULDADE = fc.FACULDADE )        
                      
                  IF @v_opcao is null        
                    SELECT @v_opcao = max(opcao)         
                    FROM LY_OPCOES_FINAN o        
                    WHERE ANO = @v_ano_contrato AND        
                          PERIODO = @v_periodo_contrato AND        
                          not exists ( SELECT 1 FROM LY_OPCOES_FINAN_UNID where OPCAO = o.OPCAO )        
                
                  IF @v_opcao is null SET @v_opcao = 0        
                  
                  SELECT @v_Perde_Bolsa_ParcAtual = ISNULL(PERDE_BOLSA_PARCATUAL, 'N')
                  FROM LY_OPCOES_FINAN        
                  WHERE OPCAO = @v_opcao        
                END
              ELSE
                SELECT @v_Perde_Bolsa_ParcAtual = 'N'        
          
              IF @v_Perde_Bolsa_ParcAtual <> 'S'
                SELECT @v_valor_bolsa_aux = isnull( sum(i.valor), 0)
                FROM LY_ITEM_LANC i, LY_BOLSA b, LY_COBRANCA c
                WHERE i.COBRANCA = c.COBRANCA AND
                      c.COBRANCA = @p_cobranca AND
                      c.ALUNO = b.ALUNO AND
                      i.NUM_BOLSA = b.NUM_BOLSA AND
                      b.TIPO_BOLSA = @p_tipo_bolsa AND 
                      i.LANC_DEB =  @v_lanc_deb AND       	  
                      i.valor <> 0
              ELSE
                SELECT @v_valor_bolsa_aux = isnull( sum(i.valor), 0)
                FROM LY_ITEM_LANC i, LY_BOLSA b, LY_COBRANCA c
                WHERE i.COBRANCA = c.COBRANCA AND
                      c.COBRANCA = @p_cobranca AND
                      c.ALUNO = b.ALUNO AND
                      i.NUM_BOLSA = b.NUM_BOLSA AND
                      b.TIPO_BOLSA = @p_tipo_bolsa AND
                      i.PARCELA = @v_parcela AND
                      i.LANC_DEB = @v_lanc_deb AND
               	      i.valor <> 0
             
              select @v_valor_bolsa = @v_valor_bolsa + @v_valor_bolsa_aux

              FETCH NEXT FROM C_DEBITO2 INTO  @v_lanc_deb
            END
          CLOSE C_DEBITO2        
          DEALLOCATE C_DEBITO2 
 
          select @v_valor_bolsa_aux2 = 0
 
          SELECT @v_valor_bolsa_aux2 = isnull( sum(i.valor), 0)
          FROM LY_ITEM_LANC i, LY_BOLSA b, LY_COBRANCA c
          WHERE i.COBRANCA = c.COBRANCA AND
                c.COBRANCA = @p_cobranca AND
                c.ALUNO = b.ALUNO AND
                i.NUM_BOLSA = b.NUM_BOLSA AND
                b.TIPO_BOLSA = @p_tipo_bolsa AND          	  
                i.lanc_deb is null AND
                i.valor <> 0

          IF @v_valor_bolsa_aux2 <> 0
            select @v_valor_bolsa = @v_valor_bolsa + @v_valor_bolsa_aux2

          IF @v_valor_bolsa > 0
            select @v_valor_bolsa = 0
          ELSE 
            IF @v_valor_bolsa < 0 
              SET @v_valor_bolsa = @v_valor_bolsa * (-1)
            

          SELECT @v_VALOR_CALCULADO =  @v_valor_bolsa
      
        END
    
	    IF @p_Categoria = 'Correcao'
        BEGIN
          SELECT @v_ValorMes = 0
          SELECT @v_ValorAcumulado = 0
         
          DECLARE C_CORRECAO CURSOR READ_ONLY FOR 
          SELECT VALOR FROM LY_CORRECAO
          WHERE (ANO > DATEPART (year, @p_data_venc) OR
                (ANO = DATEPART (year, @p_data_venc) AND MES > DATEPART(month, @p_data_venc)))
            AND (ANO < DATEPART (year, @p_data_pagamento) OR
                (ANO = DATEPART (year, @p_data_pagamento) AND MES <= DATEPART(month, @p_data_pagamento)))


          OPEN C_CORRECAO
          FETCH NEXT FROM C_CORRECAO INTO @v_ValorMes
          WHILE (@@fetch_status = 0)
          BEGIN
            SELECT @v_ValorAcumulado = Round(Round((@v_ValorMes * @v_ValorAcumulado), 8) + @v_ValorAcumulado + @v_ValorMes, 6)      
            FETCH NEXT FROM C_CORRECAO INTO @v_ValorMes
          END
          CLOSE C_CORRECAO
          DEALLOCATE C_CORRECAO
          SELECT  @v_VALOR_CALCULADO = @p_valor_base * @v_ValorAcumulado
        END
    END
    RETURN @v_VALOR_CALCULADO
END
go



delete from LY_CUSTOM_CLIENTE
where NOME = 'INS_fnENCARGOS'
and IDENTIFICACAO_CODIGO = '0000'
go

INSERT INTO LY_CUSTOM_CLIENTE
(NOME, IDENTIFICACAO_CODIGO, AUTOR, DATA_CRIACAO, OBJETIVO, SOLICITADO_POR, ATIVO, TIPOCOMPONENTE, TIPO, CLIENTE)
SELECT
  'INS_fnENCARGOS' NOME
, '0000' IDENTIFICAO_CODIGO
, 'Renato' AUTOR
, '2016-03-03' DATA_CRIACAO
, 'FNC - Calculo de encargos' OBJETIVO
, '' SOLICITADO_POR
, 'S' ATIVO
, 'FUNCTION' TIPOCOMPONENTE
, 'CLIENTE' TIPO
, 'FTC' CLIENTE
go 
