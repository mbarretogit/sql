CREATE PROCEDURE [dbo].[GRAVAR_USUARIO_SESSAO]       
  @estacao VARCHAR(100),    
  @usuario VARCHAR(100),    
  @transacao VARCHAR(100),    
  @audita VARCHAR(1),    
  @pagina VARCHAR(100)   
AS          
begin        
 declare @p_restricao T_SIMNAO   
 declare @p_restricaoUnidade T_SIMNAO   
 declare @p_restricaoCurso T_SIMNAO    
 declare @p_privilegiado T_SIMNAO   
 declare @p_restricaoUnidFis T_SIMNAO    
   
 SET @p_restricao = 'N'     
 SET @p_restricaoUnidade = 'N'     
 SET @p_restricaoCurso = 'N'     
 SET @p_privilegiado = 'N'    
 SET @p_restricaoUnidFis = 'N'  
       
 if (@usuario is null or @usuario = '')  
      set @p_privilegiado='S'  
else  
begin     
       SELECT top 1 @p_restricao = RESTRICAO_SIMNAO,       
                  @p_restricaoUnidade = RESTRICAO_UNIDADE ,      
                  @p_restricaoCurso = RESTRICAO_CURSO,       
                  @p_privilegiado = isnull(PRIVIL,'N'),       
                  @p_restricaoUnidFis = RESTRICAO_UNID_FIS      
       FROM LY_OPCOES_ACESSO   
       left join USUARIO on usuario= @usuario      
 end  
          
 --Atualiza a tabela de usuﬂrios das sessßes  
if exists (select 1 from LY_USUARIO_SESSAO  where Sessao_ID = @@spid)      
       begin      
              -- se existir altera     
              Update LY_USUARIO_SESSAO Set USUARIO = ISNULL(@usuario , ''),      
              RESTRICAO_SIMNAO = @p_restricao,      
              RESTRICAO_UNIDADE = @p_restricaoUnidade,      
              RESTRICAO_CURSO = @p_restricaoCurso,      
              RESTRICAO_UNID_FIS = @p_restricaoUnidFis,      
              PRIVIL  = @p_privilegiado      
              where Sessao_ID = @@spid     
       end      
 else      
       begin      
            --se n“o existir, insere   
            Insert into LY_USUARIO_SESSAO (USUARIO, SESSAO_ID, RESTRICAO_SIMNAO, RESTRICAO_UNIDADE ,RESTRICAO_CURSO, PRIVIL, RESTRICAO_UNID_FIS)      
            values (ISNULL(@usuario,''), @@spid, @p_restricao, @p_restricaoUnidade, @p_restricaoCurso, @p_privilegiado, @p_restricaoUnidFis)      
       end      
    
  exec zzCRO_VarsSet  @estacao,  @usuario,  @transacao,  @audita ,  @pagina       
END