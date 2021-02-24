  
  
ALTER PROCEDURE a_DEFINE_TEMA_ALUNO  
 @Pessoa         as T_NUMERO_GRANDE,    
 @Tema           as T_ALFALARGE OUTPUT    
 AS    
 --[INICIO]    
 ----## INICIO - MIGUEL - 14/07/2016 - Tratamento para definir o tema do Lyceum de acordo com a Unidade de Ensino  
   
 Begin  
   --## 0001 - Consulta se aluno � da FTC.
   if exists (   
               select 1  
      from ly_curso c  
      join LY_ALUNO a  
       on a.CURSO    = c.CURSO  
      join LY_PESSOA p  
       on p.PESSOA = a.PESSOA   
      where 1 = 1   
      and isnull(c.TIPO,'')   in ('ACADEMIA','GRADUACAO','EXTENSAO','MESTRADO','POS-GRADUACAO','TECNICO')  
      --AND C.FACULDADE NOT IN ('29')  
      and p.PESSOA            = @Pessoa  
       )   
    Begin  
     --## Seta padr�o de acesso  
     SET @Tema = 'FTC'  
     RETURN  
    END  
        
   --## 0002 - Consulta se o aluno � do col�gio DOM -- ALTERADO POR MIGUEL 11/03/2016  
   if exists (   
               select 1  
      from ly_curso c  
      join LY_ALUNO a  
       on a.CURSO    = c.CURSO  
      join LY_PESSOA p  
       on p.PESSOA = a.PESSOA   
      where 1 = 1   
      and isnull(c.TIPO,'')   in ('ENS INFANTIL')  
      and p.PESSOA            = @Pessoa  
       )   
    Begin  
     --## Seta padr�o de acesso  
     SET @Tema = 'DOM'  
     RETURN  
    END  
   --## 0003 - Consulta se aluno � da Faculdade da Cidade. /***** DESATIVADO EM 06/12/2017 DEPOIS DA MUDAN�A DE NOME DA FACULDADE DA CIDADE PARA FTC COMERCIO **** /
   --if exists (   
   --            select 1  
   --   from ly_curso c  
   --   join LY_ALUNO a  
   --    on a.CURSO    = c.CURSO  
   --   join LY_PESSOA p  
   --    on p.PESSOA = a.PESSOA   
   --   where 1 = 1   
   --   and isnull(c.TIPO,'')   in ('ACADEMIA','GRADUACAO','EXTENSAO','MESTRADO','POS-GRADUACAO','TECNICO')  
   --   AND C.FACULDADE IN ('29')  
   --   and p.PESSOA            = @Pessoa  
   --    )   
   -- Begin  
   --  --## Seta padr�o de acesso  
   --  SET @Tema = 'FCS'  
   --  RETURN  
   -- END  

   ----## 0004 - Consulta se o aluno � do THINK -- ALTERADO POR MIGUEL 15/02/2017
	   if exists (   
				   select 1  
		  from ly_curso c  
		  join LY_ALUNO a  
		   on a.CURSO    = c.CURSO  
		  join LY_PESSOA p  
		   on p.PESSOA = a.PESSOA   
		  where 1 = 1   
		  and isnull(c.TIPO,'')   in ('LINGUAS')  
		  and p.PESSOA   = @Pessoa  
		   )   
		Begin  
		 --## Seta padr�o de acesso  
		 SET @Tema = 'THINK'  
		 RETURN  
		END  
	     
 END    
 --## FIM - MIGUEL - 14/07/2016 - Tratamento para definir o tema do Lyceum de acordo com a Unidade de Ensino  
     
 RETURN    
 --[FIM]  
 
delete from LY_CUSTOM_CLIENTE
where NOME = 'a_DEFINE_TEMA_ALUNO'
and IDENTIFICACAO_CODIGO = '0003'
go

INSERT INTO LY_CUSTOM_CLIENTE
(NOME, IDENTIFICACAO_CODIGO, AUTOR, DATA_CRIACAO, OBJETIVO, SOLICITADO_POR, ATIVO, TIPOCOMPONENTE, TIPO, CLIENTE)
SELECT
  'a_DEFINE_TEMA_ALUNO' NOME
, '0003' IDENTIFICAO_CODIGO
, 'Miguel' AUTOR
, '2018-06-26' DATA_CRIACAO
, 'Atualizado para Cursos do DOM - ENS INFANTIL' OBJETIVO
, 'Girlane Amorim' SOLICITADO_POR
, 'S' ATIVO
, 'PROCEDURE' TIPOCOMPONENTE
, 'CLIENTE' TIPO
, 'FTC' CLIENTE
GO