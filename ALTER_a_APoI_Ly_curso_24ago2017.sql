USE LYCEUM
GO

ALTER PROCEDURE a_APoI_Ly_curso    
  @erro VARCHAR(1024) OUTPUT,    
  @curso VARCHAR(20), @num_func NUMERIC(15), @faculdade VARCHAR(20), @mnemonico VARCHAR(6),     
  @nome VARCHAR(300), @habilitacao VARCHAR(255), @titulo VARCHAR(50), @decreto VARCHAR(255),     
  @ativo CHAR(1), @formatura CHAR(1), @kit VARCHAR(20), @tipo VARCHAR(20), @dt_dou DATETIME,     
  @cobran_disc CHAR(1), @vagas NUMERIC(10), @valor_cred_assoc_disc CHAR(1), @depto VARCHAR(20),     
  @usa_serie_ideal CHAR(1), @modalidade VARCHAR(20), @inep_dtinicio DATETIME, @inep_area_de_conhecimento VARCHAR(50),     
  @inep_curso VARCHAR(50), @inep_grau VARCHAR(50), @inep_nivel VARCHAR(50), @inep_presencial VARCHAR(1),     
  @inep_tipocursoextensao VARCHAR(50), @inep_tipocursopos VARCHAR(50), @inep_turno VARCHAR(50),     
  @inep_ext_alunosconcluintes NUMERIC(10), @inep_ext_alunosexecutivos NUMERIC(10),     
  @inep_ext_alunosgraduacao NUMERIC(10), @inep_ext_alunosmatriculados NUMERIC(10),     
  @inep_ext_alunosoutrasies NUMERIC(10), @inep_ext_alunosposgraduacao NUMERIC(10),     
  @inep_ext_alunosprofedbasica NUMERIC(10), @inep_ext_alunosprofliberais NUMERIC(10),     
  @inep_ext_carga_horaria NUMERIC(18), @inep_ext_docentesies NUMERIC(10), @inep_ext_docentesoutrasies NUMERIC(10),     
  @inep_ext_pessoascomunidade NUMERIC(10), @inep_ext_pessoasoutrasies NUMERIC(10),     
  @inep_ext_servidoresies NUMERIC(10), @inep_tipodoc_criacao VARCHAR(50), @inep_numdespacho_criacao VARCHAR(50),     
  @inep_dtdespacho_criacao DATETIME, @inep_tipodoc_rec VARCHAR(50), @inep_numdoc_rec VARCHAR(50),     
  @inep_dtpubl_rec DATETIME, @inep_validade_rec VARCHAR(50), @inep_numdespacho_rec VARCHAR(50),     
  @inep_dtdespacho_rec DATETIME, @inep_diploma_rec CHAR(1), @inep_dtfinal_rec DATETIME,     
  @inep_tipodoc_renov VARCHAR(50), @inep_numdoc_renov VARCHAR(50), @inep_dtpubl_renov DATETIME,     
  @inep_validade_renov VARCHAR(50), @inep_numdespacho_renov VARCHAR(50), @inep_dtdespacho_renov DATETIME,     
  @inep_q01 VARCHAR(100), @inep_q02 VARCHAR(100), @inep_q03 VARCHAR(100), @inep_ocde VARCHAR(50),     
  @inep_diplomas VARCHAR(500), @inep_turnooferta VARCHAR(50), @inep_regime VARCHAR(50),     
  @grupo_curso VARCHAR(20), @curso_associado VARCHAR(20), @faculdade_associada VARCHAR(20),     
  @nome_secretaria VARCHAR(100), @rg_num_secretaria VARCHAR(15), @portaria_secretaria VARCHAR(255),     
  @nome_diretor VARCHAR(100), @rg_num_diretor VARCHAR(15), @portaria_diretor VARCHAR(255),   
  @stamp_atualizacao DATETIME, @tem_reclassificacao CHAR(1), @duracao_aula NUMERIC(10, 2),   
  @fl_field_01 VARCHAR(2000), @fl_field_02 VARCHAR(2000), @fl_field_03 VARCHAR(2000),   
  @fl_field_04 VARCHAR(2000), @fl_field_05 VARCHAR(2000), @fl_field_06 VARCHAR(2000),   
  @fl_field_07 VARCHAR(2000), @fl_field_08 VARCHAR(2000), @fl_field_09 VARCHAR(2000),   
  @fl_field_10 VARCHAR(2000), @evento CHAR(1)    
AS    
  -- [INÍCIO] Customização - Não escreva código antes desta linha    
    
 --## INICIO - RAUL - 05/08/2016 - Pergamum - Código de integração do Pergamum   
 --## 13/01/2017 - tratamento para não incluir informações dos cursos do tipo linguas  
 --## 09/02/2017 - TRATAMENTO PARA NÃO CONSIDERAR ACADEMIA E ENSINO BASICO  
   
 If isnull(@tipo,'') not in ('LINGUAS','ENS BASICO','ACADEMIA')  
   exec insert_curso_pergamum @curso, @faculdade, @nome, @mnemonico, null --@nome_diretor  
--## FIM - RAUL - 05/08/2016 - Pergamum - Código de integração do Pergamum   
   
 --## INICIO - EDILLAN - 07/02/2017 - envio de email para contabilidade na criação de cursos  
 EXEC [FTC_SP_SEND_MAIL_LOTE]  
        @p_tipo_email = 'CursoCadastrado',  
        @p_chave1 = @curso,  
        @p_chave2 = @nome,  
        @p_chave3 = @tipo,  --Inserido mediante solicitação de Gregório (chamado 1493) em 06/06/17  por Miguel Barreto
        @p_chave4 = @faculdade,  --Inserido mediante solicitação de Gregório (chamado 1493) em 06/06/17 por Miguel Barreto
        @p_chave5 = ''  
--## fim - EDILLAN - 07/02/2017 - envio de email para contabilidade na criação de cursos  
  
  SET @erro = NULL  
  -- [FIM] Customização - Não escreva código após esta linha    
  
GO
    
delete from LY_CUSTOM_CLIENTE  
where nome = 'a_APoI_Ly_curso'  
and IDENTIFICACAO_CODIGO = '0002'  

INSERT INTO LY_CUSTOM_CLIENTE
(NOME, IDENTIFICACAO_CODIGO, AUTOR, DATA_CRIACAO, OBJETIVO, SOLICITADO_POR, ATIVO, TIPOCOMPONENTE, TIPO, CLIENTE)
SELECT
  'a_APoI_Ly_curso' NOME
, '0002' IDENTIFICAO_CODIGO
, 'Miguel' AUTOR
, '2017-08-24' DATA_CRIACAO
, 'Ajustar EP - Trazer informação de Tipo de Curso e Unidade associada ao curso' OBJETIVO
, 'Gregório Cerqueira, Rosemeire Amorim' SOLICITADO_POR
, 'S' ATIVO
, 'PROCEDURE' TIPOCOMPONENTE
, 'CLIENTE' TIPO
, 'FTC' CLIENTE
GO  