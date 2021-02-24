  
ALTER PROCEDURE a_APrI_Ly_lanc_debito         
  @erro VARCHAR(1024) OUTPUT,          
  @lanc_deb NUMERIC(10) OUTPUT,         
  @codigo_lanc VARCHAR(20) OUTPUT,         
  @aluno VARCHAR(20) OUTPUT,           
  @ano_ref NUMERIC(4) OUTPUT,         
  @periodo_ref NUMERIC(2) OUTPUT,         
  @data DATETIME OUTPUT,           
  @valor NUMERIC(10, 2) OUTPUT,         
  @lote NUMERIC(10) OUTPUT,         
  @descricao VARCHAR(100) OUTPUT,           
  @solicitacao NUMERIC(10) OUTPUT,         
  @item_solicitacao NUMERIC(10) OUTPUT,         
  @trancado_calculo VARCHAR(1) OUTPUT,           
  @grupo VARCHAR(20) OUTPUT,      
  @matricula VARCHAR(1) OUTPUT,       
  @fl_field_01 VARCHAR(2000) OUTPUT        
AS          
-- INICIO    
--## INICIO - Raul - 09/12/2015 - 0001 - Setar grupo de dívidas na geração das dívidas      
      
 -- Verifica a Unidade Ensino e Curso do ALUNO      
 declare @unidade varchar(20)      
 declare @unidade_fisica varchar(20)      
 declare @tipo_curso varchar(20)      
 declare @curso varchar(20)      
       
 select       
  @unidade    = c.FACULDADE,      
  @tipo_curso = c.TIPO      
 from  LY_ALUNO a      
 join LY_CURSO c      
  on a.CURSO = c.CURSO      
 where ALUNO     = @aluno        
      
       
    --# Colégio      
 -- Como o colégio é uma conta para todas as cobrancas então a validação do colégio deve ser sempre a primeira      
 -- Quando ajustar os tipos de curso, podemos alterar este item para usar tipo de curso      
 -- Ajustado em 19/02/2016 para DOM     
 --- Ajustamo em 16/12/2016 para as novas unidades do curso Think -- Juliano Armentano   
    if @unidade in ('50','51','52','53','54','55','56')    --acrescetada a unidade 53 em 14/06/2017  por Miguel
        Begin         
          Set @grupo = 'GP_'+@unidade+'_DOM'      
          Return      
        End        
        
       
    --# Requerimentos / Autoatendimento / Biblioteca      
    if @codigo_lanc in ('REQ','BIB')      
        Begin         
          Set @grupo = 'GP_'+@unidade+'_REQ'      
          Return      
        End        
      
    --# Academia      
    if @codigo_lanc in ('ACADEMIA')      
        Begin         
          Set @grupo = 'GP_ACADEMIA'   --## Ajustado codigo de divida da academia para GP_ACADEMIA      
          Return      
        End        
              
      
    --# Tipo Curso Mestrado e Doutorado      
    if @tipo_curso in ('MESTRADO','DOUTORADO')      
        Begin         
          Set @grupo = 'GP_'+@unidade+'_MEST'      
          Return      
        End        
      
    --# Cursos EAD      
    if @tipo_curso in ('GRADUACAO-EAD','POS-GRADUACAO-EAD')      
        Begin         
           Set @grupo = 'GP_'+@unidade+'_EAD'      
          Return      
        End        
      
    --# Cursos Graduação      
    if @tipo_curso in ('GRADUACAO')       
        Begin         
          Set @grupo = 'GP_'+@unidade+'_GRA'      
          Return      
        End        
      
    --# Cursos Extensão      
    if @tipo_curso in ('EXTENSAO')       
        Begin         
          Set @grupo = 'GP_'+@unidade+'_GRA'      
          Return      
        End        
      
    --# Cursos Pós-Graduação      
    if @tipo_curso in ('POS-GRADUACAO')       
        Begin         
          Set @grupo = 'GP_'+@unidade+'_POS'      
          Return      
        End        
      
    --# Cursos Tecnicos      
    if @tipo_curso in ('TECNICO','PRONATEC')       
        Begin         
          Set @grupo = 'GP_'+@unidade+'_TEC'      
          Return      
        End        
      
--## FIM - Raul - 09/12/2015 - 0001 - Setar grupo de dívidas na geração das dívidas       
  
RETURN    
-- [FIM]            