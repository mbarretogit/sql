USE LYCEUM
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.s_SituacaoFinanOK'))
   exec('CREATE PROCEDURE [dbo].[s_SituacaoFinanOK] AS BEGIN SET NOCOUNT OFF; END')
GO 
  
ALTER PROCEDURE s_SituacaoFinanOK  
  @p_aluno T_CODIGO,   
  @pVerificaSoPrimParcPreMatr T_SIMNAO = 'N',  
  @p_ano T_ANO = NULL,  
  @p_periodo T_SEMESTRE2 = NULL,  
  @p_SitFinanOk T_SIMNAO OUTPUT,  
  @p_Msg_Erro VARCHAR(4000) OUTPUT,  
  @p_TipoDivida VARCHAR(20) = NULL,  
  @p_AnoRef T_ANO = NULL,  
  @p_MesRef T_MES = NULL,  
  @p_data_limite T_DATA=NULL,  
  @v_substitui varchar(1) OUTPUT  
AS  
  SET @v_substitui = 'S'  

  DECLARE @v_cobranca T_NUMERO  
  DECLARE @v_resp T_CODIGO  
  DECLARE @v_dtvenc T_DATA  
  DECLARE @v_titular  VARCHAR(500)  
  DECLARE @v_banco T_NUMERO_PEQUENO  
  DECLARE @v_agencia T_ALFASMALL  
  DECLARE @v_conta_banco T_ALFASMALL  
  DECLARE @v_serie varchar(10)   
  DECLARE @v_numero varchar(10)  
  DECLARE @v_soma numeric(30,15)   
  DECLARE @v_data_dia_sem_hora T_DATA  
  DECLARE @v_count int  
  DECLARE @v_mens_erro as VARCHAR(8000)  
  DECLARE @v_straux1 VARCHAR(100)  
  DECLARE @v_straux2 VARCHAR(100)  
  DECLARE @v_straux3 VARCHAR(100)  
  DECLARE @v_straux4 VARCHAR(100)  
  DECLARE @v_straux5 VARCHAR(100)  
  DECLARE @v_chave T_NUMERO  
  DECLARE @v_inadimpl_acordo T_SIMNAO  
  DECLARE @v_faculdade T_CODIGO  
  DECLARE @v_curso T_CODIGO  
  

   if @p_data_limite is null   
   EXEC GetDataDiaSemHora @v_data_dia_sem_hora OUTPUT  
  else   
      select @v_data_dia_sem_hora = @p_data_limite  
  
  SELECT @p_SitFinanOk = 'S'  
    
  -- ---------------------------------------------------  
  --   Verifica  se há algum cheque sem baixa  
  -- ---------------------------------------------------  
  SELECT @v_cobranca =  il.COBRANCA, @v_dtvenc=c.data_de_vencimento,  
         @v_banco = ch.banco, @v_agencia = ch.agencia,   
         @v_conta_banco = ch.conta_banco, @v_serie = ch.serie, @v_numero = ch.numero  
  FROM LY_ITEM_LANC il, ly_cobranca c,  
       LY_ITEM_CRED ic, LY_CHEQUES ch, LY_LANC_CREDITO cr   
  WHERE il.cobranca = ic.cobranca  
       and il.cobranca = c.cobranca  
       and ic.LANC_CRED = cr.LANC_CRED   
       and ch.BANCO = cr.BANCO   
       and ch.AGENCIA = cr.AGENCIA  
       and ch.CONTA_BANCO = cr.CONTA_BANCO  
       and ch.SERIE = cr.SERIE   
       and ch.NUMERO = cr.NUMERO   
       and VALIDO_APOS_COMP = 'S'    
       and DT_BAIXA is null  
       and DT_CANC is null  
       and c.DATA_DE_FATURAMENTO is not null  
       and (c.data_de_vencimento < @v_data_dia_sem_hora or @pVerificaSoPrimParcPreMatr = 'S')  
       and SEM_FUNDOS = 'N'  
       and il.aluno = @p_aluno  
       and (  (@pVerificaSoPrimParcPreMatr = 'N') or   
              (  
                @pVerificaSoPrimParcPreMatr = 'S' and  
                c.cobranca in   
                (  
                  select distinct cobranca from ly_item_lanc   
                  where lanc_deb in   
                  (  
                    select distinct lanc_deb from ly_pre_matricula   
                    where aluno = @p_aluno and  
                        ((@p_ano is null) or (@p_ano is not null and ano = @p_ano)) and  
                        ((@p_periodo is null) or (@p_periodo is not null and semestre = @p_periodo))  
                  ) and parcela = 1  
                )  
              ) or  
              (  
                @pVerificaSoPrimParcPreMatr = 'C' and  
                @p_TipoDivida = 'Mensalidade' and  
                c.ano = @p_AnoRef and  
                c.mes = @p_MesRef and  
                c.num_cobranca = 1  
              ) or  
              (  
                @pVerificaSoPrimParcPreMatr = 'C' and  
                @p_TipoDivida = 'Qualquer Dívida' and  
                c.ano = @p_AnoRef and  
                c.mes = @p_MesRef  
              )  
           )  
  
  IF @@ROWCOUNT <> 0   
      BEGIN  
         SELECT @p_SitFinanOk = 'N'  
         SET @v_straux1 = convert(varchar(50),@v_cobranca)  
         SET @v_straux2 = convert(varchar(50),@v_dtvenc)  
         SET @v_straux3 = convert(varchar(50),@v_numero)  
         SET @v_straux4 = convert(varchar(50),@v_banco)  
         SET @v_straux5 = convert(varchar(50),@v_serie)  
         SET @p_Msg_Erro = 'Há cheque sem data de baixa para esse aluno. Verifique a Cobrança ' + @v_straux1 + ' com vencimento em ' + @v_straux2  + '. Dados do Cheque :  número ' + @v_straux3 + ', banco ' + @v_straux4 + ', agência' + @v_agencia + ', cont
  
a_banco ' + @v_conta_banco + ', série ' + @v_straux5  
         RETURN  
      END  
  
  -- ---------------------------------------------------   
  -- Verifica  se há algum cheque sem fundo  
  -- ---------------------------------------------------   
  IF @p_SitFinanOk = 'S'  
    BEGIN  
      SELECT @v_cobranca = il.COBRANCA, @v_dtvenc=c.data_de_vencimento,  
             @v_banco = ch.banco, @v_agencia = ch.agencia,   
             @v_conta_banco = ch. conta_banco, @v_serie = ch.serie, @v_numero = ch.numero  
      FROM LY_ITEM_LANC il, ly_cobranca c,  
           LY_ITEM_CRED ic, LY_CHEQUES ch, LY_LANC_CREDITO cr   
      WHERE il.cobranca = ic.cobranca  
             and il.cobranca = c.cobranca  
             and ic.LANC_CRED = cr.LANC_CRED   
             and ch.BANCO = cr.BANCO   
             and ch.AGENCIA = cr.AGENCIA  
             and ch.CONTA_BANCO = cr.CONTA_BANCO  
             and ch.SERIE = cr.SERIE   
             and ch.NUMERO = cr.NUMERO   
             and VALIDO_APOS_COMP = 'S'    
             and DT_BAIXA is null  
             and DT_CANC is null  
             and c.DATA_DE_FATURAMENTO is not null  
             and (c.data_de_vencimento < @v_data_dia_sem_hora or @pVerificaSoPrimParcPreMatr = 'S')            
             and SEM_FUNDOS = 'S'  
             and il.aluno = @p_aluno  
             and (  (@pVerificaSoPrimParcPreMatr = 'N') or   
                    (  
                      @pVerificaSoPrimParcPreMatr = 'S' and  
                      c.cobranca in   
                      (  
                        select distinct cobranca from ly_item_lanc   
                        where lanc_deb in   
                        (  
                          select distinct lanc_deb from ly_pre_matricula   
                          where aluno = @p_aluno and  
                              ((@p_ano is null) or (@p_ano is not null and ano = @p_ano)) and  
                              ((@p_periodo is null) or (@p_periodo is not null and semestre = @p_periodo))  
                        ) and parcela = 1  
                      )  
                    ) or  
                    (  
                 @pVerificaSoPrimParcPreMatr = 'C' and  
                 @p_TipoDivida = 'Mensalidade' and  
                 c.ano = @p_AnoRef and  
                 c.mes = @p_MesRef and  
                 c.num_cobranca = 1  
                    ) or  
                    (  
                 @pVerificaSoPrimParcPreMatr = 'C' and  
                 @p_TipoDivida = 'Qualquer Dívida' and  
                 c.ano = @p_AnoRef and  
                 c.mes = @p_MesRef  
                    )  
                 )  
      
      IF @@ROWCOUNT <> 0   
        BEGIN   
          SELECT @p_SitFinanOk = 'N'  
          SET @v_straux1 = convert(varchar(50),@v_cobranca)  
          SET @v_straux2 = convert(varchar(50),@v_dtvenc)  
          SET @v_straux3 = convert(varchar(50),@v_numero)  
          SET @v_straux4 = convert(varchar(50),@v_banco)  
          SET @v_straux5 = convert(varchar(50),@v_serie)  
          SELECT @p_Msg_Erro ='Há cheque sem fundo para esse aluno. Verifique a Cobrança nº ' + @v_straux1 + ' com vencimento em ' + @v_straux2  + '. Dados do Cheque :  número ' + @v_straux3 + ', banco ' + @v_straux4 + ', agência' + @v_agencia + ', conta_
  
banco ' + @v_conta_banco + ', série ' + @v_straux5  
          RETURN  
        END  
   
    END  
  
  -- --------------------------------------------------------------------------------------   
  --  Verifica se há alguma cobrança ainda pendente.   
  --  Somemente serão levadas em conta as cobranças que tenham pelo menos um item de    
  --  lançamento cujo código de lançamento é utilizado para verificação de inadimplência  
  -- --------------------------------------------------------------------------------------   
  -- Somente serão verificados os responsáveis onde o campo Ver Inadimplência? igual a S.  
  -- --------------------------------------------------------------------------------------  
  IF @p_SitFinanOk = 'S'  
    BEGIN  
      SELECT @v_cobranca = v.cobranca, @v_resp = c.resp,  
             @v_dtvenc = c.data_de_vencimento, @v_titular = r.titular,  
             @v_soma = SUM(isnull(v.valor,0))     
      FROM vw_lancamento_pagto_vercheque v, ly_cobranca c, ly_resp_finan r  
      WHERE v.cobranca = c.cobranca  
            and c.aluno = @p_aluno  
            and (c.data_de_vencimento < @v_data_dia_sem_hora or @pVerificaSoPrimParcPreMatr = 'S')  
            and c.resp = r.resp  
      and c.DATA_DE_FATURAMENTO is not null  
      and r.VER_INADIMPLENCIA = 'S'  
            and (SELECT COUNT(CL.VER_INADIMPLENCIA) FROM LY_ITEM_LANC IL, LY_COD_LANC CL  
                 WHERE IL.CODIGO_LANC = CL.CODIGO_LANC AND IL.COBRANCA = v.cobranca AND CL.VER_INADIMPLENCIA = 'S') > 0  
            and (  (@pVerificaSoPrimParcPreMatr = 'N') or   
                   (  
                     @pVerificaSoPrimParcPreMatr = 'S' and  
                     c.cobranca in   
                     (  
                       select distinct cobranca from ly_item_lanc   
                       where lanc_deb in   
                       (  
                         select distinct lanc_deb from ly_pre_matricula   
                         where aluno = @p_aluno and  
                             ((@p_ano is null) or (@p_ano is not null and ano = @p_ano)) and  
                             ((@p_periodo is null) or (@p_periodo is not null and semestre = @p_periodo))  
                       ) and parcela = 1  
                     )  
                   ) or  
                   (  
                @pVerificaSoPrimParcPreMatr = 'C' and  
                @p_TipoDivida = 'Mensalidade' and  
                c.ano = @p_AnoRef and  
                c.mes = @p_MesRef and  
                c.num_cobranca = 1  
                   ) or  
                   (  
                @pVerificaSoPrimParcPreMatr = 'C' and  
                @p_TipoDivida = 'Qualquer Dívida' and  
                c.ano = @p_AnoRef and  
                c.mes = @p_MesRef  
                   )  
                )  
      GROUP BY v.cobranca, c.resp, c.data_de_vencimento, r.titular   
      HAVING SUM(v.valor) > 50  --ALTERADO PARA R$50,00 MEDIANTE SOLICITAÇÂO DA SECRETARIA GERAL (ANDRÉ BRITTO/JOSANE)
        
      IF @@ROWCOUNT <> 0   
        BEGIN             
          SELECT @p_SitFinanOk = 'N'  
          SET @v_straux1 = convert(varchar(50),@v_cobranca)  
          SET @v_straux2 = convert(varchar(50),@v_dtvenc,103)  
          SELECT @p_Msg_Erro = 'Débito pendente para a Cobrança nº ' + @v_straux1 +   
           '  referente ao responsável ' + @v_titular  + ' (' + @v_resp +')' + ' com vencimento em ' + @v_straux2 + '.'  
          RETURN  
        END  
    END  
  
  IF @p_SitFinanOk = 'S'  
      BEGIN  
  
   SELECT @v_curso = LY_ALUNO.CURSO, @v_faculdade = FACULDADE  
   FROM LY_ALUNO , LY_CURSO  
   WHERE LY_ALUNO.CURSO = LY_CURSO.CURSO  
   AND   ALUNO = @p_Aluno   
   
   select @v_chave = null  
   SELECT @v_chave = max(f.chave)   
   FROM LY_OPCOES f , LY_OPCOES_CURSO fc  
   WHERE f.chave = fc.chave AND  
         FACULDADE = @v_faculdade AND  
         CURSO = @v_curso   
   
   if @v_chave is null  
     SELECT @v_chave = max(f.chave)   
     FROM LY_OPCOES f , LY_OPCOES_UNID fc  
     WHERE f.chave = fc.chave AND  
         FACULDADE = @v_faculdade AND  
         not exists ( SELECT 1 from LY_OPCOES_CURSO where chave = fc.chave AND  
                                                         FACULDADE = fc.FACULDADE )  
           
   if @v_chave is null  
     SELECT @v_chave = max(chave)   
     FROM LY_OPCOES o  
     WHERE  not exists ( SELECT 1 from LY_OPCOES_UNID where chave = o.chave )  
   
   if @v_chave is null  
     SELECT @v_chave = max(chave)   
     FROM LY_OPCOES  
   
   
   SET @v_inadimpl_acordo = 'N'  
   SELECT @v_inadimpl_acordo = INADIMPL_ACORDO  
   FROM LY_OPCOES  
   WHERE chave = @v_chave  
  
   IF @v_inadimpl_acordo = 'S'  
      BEGIN  
  SELECT  @v_cobranca = c.cobranca,   
   @v_resp = c.resp,  
        @v_dtvenc = c.data_de_vencimento,   
   @v_titular = r.titular,  
        @v_soma = SUM(isnull(i.valor,0))     
  FROM    ly_item_lanc i, ly_cobranca c, ly_resp_finan r, ly_acordo a  
  WHERE  i.cobranca = c.cobranca  
  and i.motivo_desconto is null  
  and i.num_bolsa is null  
  and i.lanc_deb = a.lanc_deb  
  and a.cancelado <> 'S'  
  and i.parcela = 1  
  and c.aluno = @p_aluno  
  and c.resp = r.resp  
  and c.data_de_faturamento is not null  
  and r.VER_INADIMPLENCIA = 'S'      
  and exists  
  (  
   select 1  
   from ly_item_lanc ii  
   where ii.cobranca = c.cobranca  
   group by ii.cobranca  
   having sum(ii.valor) > 50  --ALTERADO PARA R$50,00 MEDIANTE SOLICITAÇÂO DA SECRETARIA GERAL (ANDRÉ BRITTO/JOSANE)
  )  
  and not exists  
  (  
   select 1  
   from ly_lanc_credito lc  
   inner join ly_item_cred ic  
    on lc.lanc_cred = ic.lanc_cred  
   where c.cobranca = ic.cobranca  
   group by ic.cobranca  
  )  
  group by c.cobranca, c.resp, c.data_de_vencimento, r.titular   
  having sum(i.valor) > 50  --ALTERADO PARA R$50,00 MEDIANTE SOLICITAÇÂO DA SECRETARIA GERAL (ANDRÉ BRITTO/JOSANE)
   
  IF @@ROWCOUNT <> 0   
           BEGIN             
      SELECT @p_SitFinanOk = 'N'  
      SET @v_straux1 = convert(varchar(50),@v_cobranca)  
      SET @v_straux2 = convert(varchar(50),@v_dtvenc,103)  
      SELECT @p_Msg_Erro = 'Débito pendente para 1ª parcela de Negociação. Cobrança nº ' + @v_straux1 +   
    '  referente ao responsável ' + @v_titular  + ' (' + @v_resp +')' + ' com vencimento em ' + @v_straux2 + '.'  
      RETURN  
           END  
      END   
      END  
  
  
  RETURN  

go

use lyceum
go
  
INSERT INTO LY_CUSTOM_CLIENTE
(NOME, IDENTIFICACAO_CODIGO, AUTOR, DATA_CRIACAO, OBJETIVO, SOLICITADO_POR, ATIVO, TIPOCOMPONENTE, TIPO, CLIENTE)
SELECT
  's_SituacaoFinanOK' NOME
, '0001' IDENTIFICAO_CODIGO
, 'Miguel Barreto' AUTOR
, '2018-01-19' DATA_CRIACAO
, 'Mudança da regra de trava financeira' OBJETIVO
, 'Josane Oliveira, André Britto' SOLICITADO_POR
, 'S' ATIVO
, 'PROCEDURE' TIPOCOMPONENTE
, 'CLIENTE' TIPO
, 'FTC' CLIENTE

GO 