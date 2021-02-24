USE LYCEUM
GO
  
ALTER PROCEDURE  [dbo].[a_TAGS_CUSTOM_CONTRATO]  
   @p_aluno T_CODIGO,  
   @p_anoMatricula T_ANO,   
   @p_periodoMatricula T_SEMESTRE2,   
   @p_curricContratoChave T_NUMERO,   
   @p_ofertaCurso T_NUMERO    
   AS   
            SELECT DISTINCT  
   iSNUll(CAST(UF.CGC AS VARCHAR(24)),'') AS UNID_FIS_CGC  
   ,isNull(UF.ENDERECO,'') AS UNID_FIS_END  
   ,isNull(UF.END_NUM,'') AS UNID_FIS_NUM  
   ,isNull(UF.END_COMPL,'')  AS UNID_FIS_END_COMP  
   ,isNull(UF.BAIRRO,'') AS UNID_FIS_BAIRRO     
   ,isNull(CONVERT(VARCHAR(24),GETDATE(),103),'') AS DT_IMPRCONT  
   ,isNUll(P.NACIONALIDADE,'')  AS ALU_NASCIONALIDADE  
   ,isNull(P.BAIRRO,'') AS ALU_BAIRRO  
   ,isNull(P.CEP,'') AS ALU_CEP  
   ,isNull(P.END_NUM,'') AS ALU_END_NUM  
   ,isNull(P.END_COMPL,'') AS ALU_ENDCOMPL  
   ,isNull(P.EST_CIVIL,'') AS ALU_ESCIVIL  
   ,CASE   
         WHEN A.UNIDADE_FISICA like 'FTC%' THEN '<img style=" float:left;" src="http://ftc.edu.br/templates/unidadeftc/images/logoftc.gif"/>'   
      WHEN A.UNIDADE_FISICA='FCS' THEN '<img style=" float:left;" src="http://www.faculdadedacidade.edu.br/templates/2013/img/logo.jpg"/>'         
      WHEN A.UNIDADE_FISICA like 'DOM%' THEN '<img style=" float:left;" src="http://www.domcolegio.com.br/lyceum/img_sistema/dom_180_x_60.png"/>'  
      WHEN A.UNIDADE_FISICA like 'THINK%' THEN '<img style=" float:left;" src="http://www.thinkidiomas.com.br/lyceum/img_sistema/think_180_60.png"/>'      
      END  AS LOGO_UNIDADE  
   ,isNull(CAST(PPP.NUM_PARCELAS AS VARCHAR(10)),'') AS NUM_PARCELAS  
   ,isNull(CAST(VWFAT.VALOR AS VARCHAR(15)),'') AS VALOR_SEMESTRA  
   ,isNull(P2.PROFISSAO,'') AS PROFISSAORESP  
   ,isNUll((SELECT TOP 1 PM.TURMA FROM VW_MATRICULA_E_PRE_MATRICULA PM WHERE PM.ALUNO=@p_aluno AND PM.ANO=@p_anoMatricula AND PM.SEMESTRE=@p_periodoMatricula),'') AS TURMAALUNO  
   ,VWFAT.ano AS ANOMATR
   ,VWFAT.periodo AS SEMMATR
   FROM LY_UNIDADE_FISICA UF  
    INNER JOIN LY_ALUNO A ON A.UNIDADE_FISICA =UF.UNIDADE_FIS  
    INNER JOIN LY_PESSOA P ON P.PESSOA =A.PESSOA  
    INNER JOIN LY_PLANO_PGTO_PERIODO PPP ON PPP.ALUNO =A.ALUNO AND PPP.ANO=@p_anoMatricula AND PPP.PERIODO=@p_periodoMatricula  
    INNER JOIN LY_RESP_FINAN RESPF ON RESPF.RESP=PPP.RESP  
    INNER JOIN LY_PESSOA P2 ON P2.PESSOA=RESPF.PESSOA  
    INNER JOIN VW_FTC_ALUNO_CURSO_VALOR_FAT VWFAT ON VWFAT.ALUNO=A.ALUNO AND VWFAT.ANO=@p_anoMatricula AND VWFAT.PERIODO=@p_periodoMatricula  
    WHERE A.ALUNO=@p_aluno  
    RETURN  