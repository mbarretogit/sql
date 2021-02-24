USE LYCEUM
GO

CREATE FUNCTION dbo.fn_AvalDocQtdPartic  (
 
  @p_avaliacaoq VARCHAR(30)  
 ,@p_aplicacao VARCHAR(30)  
 ,@p_unidade VARCHAR(15)  
 ,@p_curso VARCHAR(20)  
)
returns INT
as  
Begin  

 -- Retorno da Funcao      
 DECLARE @V_QTD INT 

--select dbo.fn_AvalDocQtdPartic('Avaliação Docente I', 'AVALDOCENTE1_20172', '03', NULL)  

select @V_QTD = COUNT(DISTINCT A.ALUNO) from LY_RESPOSTA_AUX RA
JOIN LY_ALUNO A ON A.ALUNO = RA.AVALIADOR
JOIN LY_CURSO C ON C.CURSO = A.CURSO
WHERE 1=1
AND RA.TIPO_QUESTIONARIO = ISNULL(@p_avaliacaoq,RA.TIPO_QUESTIONARIO) 
AND RA.aplicacao = ISNULL(@p_aplicacao,RA.aplicacao)
AND C.FACULDADE = ISNULL(@p_unidade,C.FACULDADE)
AND C.CURSO = ISNULL(@p_curso,C.CURSO)

RETURN @V_QTD

END
