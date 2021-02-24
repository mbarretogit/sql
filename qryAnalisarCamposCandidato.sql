
CREATE TABLE ##GETERRO ( --DROP TABLE #GETERRO 
	CANDIDATO VARCHAR(20),
	DATA_INTEGRACAO DATETIME,
	MSG_ERRO VARCHAR(MAX)
	)

	DECLARE @CANDIDATO VARCHAR(20)
	DECLARE @V_ERRO INT

	DECLARE CURSOR1 CURSOR FOR

	SELECT        
	IC.[cad_numeroinscricao ] 
	FROM CRMEDUCACIONAL..DY_Inscricao_Candidato IC              
	INNER JOIN CRMEDUCACIONAL..DY_Interessado I ON 1 = 1 AND IC.CAD_CLIENTEPOTENCIALID = I.CAD_CODIGO              
	INNER JOIN CRMEDUCACIONAL..DY_Concurso C ON 1 = 1 AND C.CAD_CODIGO = IC.CAD_CONCURSOID              
	INNER JOIN CRMEDUCACIONAL.DBO.DY_OFERTAS O ON 1 = 1 AND IC.CAD_OFERTAID = O.cad_codigo              
	WHERE 1 = 1               
	--AND IC.[cad_numeroinscricao ] = 'CAN-469527-FTC'              
	AND C.CAD_NOME not like '%DOM%' --- Para não enviar Alunos do Dom       
	AND IC.CREATEDON > CONVERT(DATETIME,'31/07/2019',103) --- Pegar os dados a partir da data definida              
	AND IC.CAD_SITUACAO IN('Convocado','Inscrito','Classificado') --- Pegar apenas essas situações              
	AND( IC.ftc_codcampus <> ' ' OR LEN(IC.ftc_codcampus) > 1  )              
	AND( IC.ftc_codcurriculo <> ' ' OR LEN(IC.ftc_codcurriculo) > 1  )              
	AND( IC.ftc_codcurso <> ' ' OR LEN(IC.ftc_codcurso) > 1  )              
	AND( IC.ftc_codturno <> ' ' OR LEN(IC.ftc_codturno) > 1  )              
	AND C.CAD_NUMERO not in ('212','237','258') -- Não trazer candidatos desses concursos              
	AND NOT EXISTS(              
	SELECT TOP 1 1 FROM INTEGRACAO_CRM_LYCEUM..FTC_INTEGRACAO_CRM WHERE CANDIDATO COLLATE Latin1_General_CI_AS = IC.[cad_numeroinscricao ] COLLATE Latin1_General_CI_AS              
	)              
	AND IC.cad_cpf IS NOT NULL -- Não pegar com CPF em branco               
	AND IC.cad_cpf <> '000.0000.000-00' -- nÃO PEGAR cpf ZERO            
	AND len(convert(VARCHAR,replace(replace(ftc_notafinal,'.',''),',','.'))) < 10 --**DESFEITO**alterado em 04fev2021 para que os zeros à direita não sejam considerados no LEN (Miguel Barreto, lucas Trindade e Paulo Henrique)        
	--AND LEN(convert(varchar,replace(replace(IC.ftc_notafinal,'.',''),',','.'))) < '10'             
	--AND IC.ftc_notafinal IS NOT NULL             
	--AND  RTRIM(LTRIM(IC.ftc_notafinal)) = ''            
	--AND (LEN(IC.ftc_notafinal) > '1')  -- não pegar nota final com mais de 10 caracteres, pois da erro no Lyceum              
	and IC.CAD_NUMEROINSCRICAO not in ('CAN-332136-FTC')        
	and ic.ftc_inscrioteste = '0'   

OPEN CURSOR1

-- Lendo a próxima linha
FETCH NEXT FROM CURSOR1 INTO @CANDIDATO

-- Percorrendo linhas do cursor (enquanto houverem)
WHILE @@FETCH_STATUS = 0
BEGIN 
	BEGIN TRY

INSERT INTO [FTC_INTEGRACAO_CRM_TST]
SELECT        
		IC.[cad_numeroinscricao ]              
		,CASE WHEN RTRIM(LTRIM(IC.FTC_LINGUAESTRANGEIRA)) = '' THEN 'True' WHEN RTRIM(LTRIM(IC.FTC_LINGUAESTRANGEIRA)) IS NULL THEN 'True' ELSE RTRIM(LTRIM(IC.FTC_LINGUAESTRANGEIRA)) END LINGUAESTRANGEIRA              
		,IC.CAD_TRAINEE TRAINEE              
		,FORMAT(CAST(C.CAD_DATAPROVA AS DATETIME), 'yyyy-MM-dd') DATAPROVA              
		,IC.CAD_HORAPROVA HORAPROVA              
		,IC.CAD_SALAPROVA SALAPROVA              
		,IC.CAD_UNIDADEPROVA UNIDADEPROVA              
		,REPLACE(C.CAD_NUMERO,'.','') CODCONCURSO              
		,SUBSTRING(C.CAD_NOME,1,199) NOMECONCURSO              
		,IC.cad_desejaInformacoesSobreBolsas DESEJAINFORMACOESSOBREBOLSAS              
		,I.CAD_NECESSIDADESESPECIAIS NECESSIDADESESPECIAIS              
		,SUBSTRING(IC.cad_clientepotencialnome,1,149)              
		,CASE               
			WHEN REPLACE(REPLACE(RTRIM(LTRIM(I.CAD_CPF)),'.',''),'-','') = '' THEN REPLACE(REPLACE(RTRIM(LTRIM(IC.CAD_CPF)),'.',''),'-','')              
			WHEN REPLACE(REPLACE(RTRIM(LTRIM(I.CAD_CPF)),'.',''),'-','') IS NULL THEN REPLACE(REPLACE(RTRIM(LTRIM(IC.CAD_CPF)),'.',''),'-','')              
			ELSE REPLACE(REPLACE(RTRIM(LTRIM(I.CAD_CPF)),'.',''),'-','')              
		END AS CPF              
		,SUBSTRING(I.EMAILADDRESS1,0,90)EMAILS            
		,I.MOBILEPHONE CELULAR              
		,CASE 
			WHEN isnumeric(I.ADDRESS1_POSTALCODE) = '0' THEN '48725000' 
			WHEN LEN(RTRIM(LTRIM(I.ADDRESS1_POSTALCODE))) > '9' THEN (select CEP from [PRODUCAO_CRM_LYCEUM].[LYCEUM].[dbo].[LY_UNIDADE_ENSINO] WHERE UNIDADE_ENS collate Latin1_General_CI_AI  = CASE WHEN LEN(IC.ftc_CODCAMPUS) <= 1 THEN CONCAT('0',IC.ftc_CODCAMPUS) ELSE IC.ftc_CODCAMPUS END) 
			WHEN RTRIM(LTRIM(I.ADDRESS1_POSTALCODE)) = '' THEN (select CEP from [PRODUCAO_CRM_LYCEUM].[LYCEUM].[dbo].[LY_UNIDADE_ENSINO] WHERE UNIDADE_ENS collate Latin1_General_CI_AI  = CASE WHEN LEN(IC.ftc_CODCAMPUS) <= 1 THEN CONCAT('0',IC.ftc_CODCAMPUS) ELSE IC.ftc_CODCAMPUS END) 
			WHEN I.ADDRESS1_POSTALCODE IS NULL THEN (select CEP from [PRODUCAO_CRM_LYCEUM].[LYCEUM].[dbo].[LY_UNIDADE_ENSINO] WHERE UNIDADE_ENS collate Latin1_General_CI_AI  = CASE WHEN LEN(IC.ftc_CODCAMPUS) <= 1 THEN CONCAT('0',IC.ftc_CODCAMPUS) ELSE IC.ftc_CODCAMPUS END) 
			ELSE RTRIM(LTRIM(I.ADDRESS1_POSTALCODE)) 
		END CEP              
		,CASE 
			WHEN RTRIM(LTRIM(I.ADDRESS1_LINE1)) = '' THEN (select E.ENDERECO from [PRODUCAO_CRM_LYCEUM].[LYCEUM].[dbo].[LY_UNIDADE_ENSINO] E WHERE  UNIDADE_ENS collate Latin1_General_CI_AI = CASE WHEN LEN(IC.ftc_CODCAMPUS) <= 1 THEN CONCAT('0',IC.ftc_CODCAMPUS) ELSE IC.ftc_CODCAMPUS END) 
			WHEN RTRIM(LTRIM(I.ADDRESS1_LINE1)) IS NULL THEN (select E.ENDERECO from [PRODUCAO_CRM_LYCEUM].[LYCEUM].[dbo].[LY_UNIDADE_ENSINO] E WHERE  UNIDADE_ENS collate Latin1_General_CI_AI = CASE WHEN LEN(IC.ftc_CODCAMPUS) <= 1 THEN CONCAT('0',IC.ftc_CODCAMPUS) ELSE IC.ftc_CODCAMPUS END)
			ELSE RTRIM(LTRIM(I.ADDRESS1_LINE1)) 
		END ENDERECO              
		,CASE 
			WHEN RTRIM(LTRIM(I.ADDRESS1_LINE2)) = '' THEN (select END_NUM from [PRODUCAO_CRM_LYCEUM].[LYCEUM].[dbo].[LY_UNIDADE_ENSINO] WHERE UNIDADE_ENS collate Latin1_General_CI_AI = CASE WHEN LEN(IC.ftc_CODCAMPUS) <= 1 THEN CONCAT('0',IC.ftc_CODCAMPUS) ELSE IC.ftc_CODCAMPUS END)         
			WHEN RTRIM(LTRIM(I.ADDRESS1_LINE2)) IS NULL THEN (select END_NUM from [PRODUCAO_CRM_LYCEUM].[LYCEUM].[dbo].[LY_UNIDADE_ENSINO] WHERE UNIDADE_ENS collate Latin1_General_CI_AI = CASE WHEN LEN(IC.ftc_CODCAMPUS) <= 1 THEN CONCAT('0',IC.ftc_CODCAMPUS) ELSE IC.ftc_CODCAMPUS END)         
			WHEN LEN(RTRIM(LTRIM(I.ADDRESS1_LINE1))) >= 16 THEN (select END_NUM from [PRODUCAO_CRM_LYCEUM].[LYCEUM].[dbo].[LY_UNIDADE_ENSINO] WHERE UNIDADE_ENS collate Latin1_General_CI_AI = CASE WHEN LEN(IC.ftc_CODCAMPUS) <= 1 THEN CONCAT('0',IC.ftc_CODCAMPUS) ELSE IC.ftc_CODCAMPUS END)
			ELSE RTRIM(LTRIM(I.ADDRESS1_LINE2)) 
		END NUMENDERECO                   
		,CASE 
			WHEN RTRIM(LTRIM(I.ADDRESS1_COUNTY)) = '' THEN ( select replace( E.BAIRRO,'''','') from [PRODUCAO_CRM_LYCEUM].[LYCEUM].[dbo].[LY_UNIDADE_ENSINO] E WHERE  UNIDADE_ENS collate Latin1_General_CI_AI = CASE WHEN LEN(IC.ftc_CODCAMPUS) <= 1 THEN CONCAT('0',IC.ftc_CODCAMPUS) ELSE IC.ftc_CODCAMPUS END )         
			WHEN RTRIM(LTRIM(I.ADDRESS1_COUNTY)) IS NULL THEN ( select replace(E.BAIRRO,'''','') from [PRODUCAO_CRM_LYCEUM].[LYCEUM].[dbo].[LY_UNIDADE_ENSINO] E WHERE UNIDADE_ENS collate Latin1_General_CI_AI = CASE WHEN LEN(IC.ftc_CODCAMPUS) <= 1 THEN CONCAT('0',IC.ftc_CODCAMPUS) ELSE IC.ftc_CODCAMPUS END )         
			ELSE replace(RTRIM(LTRIM(I.ADDRESS1_COUNTY)),'''','')         
		END BAIRRO             
		,CASE 
			WHEN isnumeric(I.ADDRESS1_CITY) = '0' THEN '00988' 
			WHEN RTRIM(LTRIM(I.ADDRESS1_CITY)) = '' THEN (select E.MUNICIPIO from [PRODUCAO_CRM_LYCEUM].[LYCEUM].[dbo].[LY_UNIDADE_ENSINO] E WHERE  UNIDADE_ENS collate Latin1_General_CI_AI = CASE WHEN LEN(IC.ftc_CODCAMPUS) <= 1 THEN CONCAT('0',IC.ftc_CODCAMPUS) ELSE IC.ftc_CODCAMPUS END) 
			WHEN RTRIM(LTRIM(I.ADDRESS1_CITY)) IS NULL THEN (select E.MUNICIPIO from [PRODUCAO_CRM_LYCEUM].[LYCEUM].[dbo].[LY_UNIDADE_ENSINO] E WHERE  UNIDADE_ENS collate Latin1_General_CI_AI = CASE WHEN LEN(IC.ftc_CODCAMPUS) <= 1 THEN CONCAT('0',IC.ftc_CODCAMPUS) ELSE IC.ftc_CODCAMPUS END) 
			ELSE (select E.MUNICIPIO from [PRODUCAO_CRM_LYCEUM].[LYCEUM].[dbo].[LY_UNIDADE_ENSINO] E WHERE  UNIDADE_ENS collate Latin1_General_CI_AI = CASE WHEN  LEN(IC.ftc_CODCAMPUS) <= 1 THEN CONCAT('0',IC.ftc_CODCAMPUS) ELSE IC.ftc_CODCAMPUS END) 
		END CIDADE
		,CASE 
			WHEN RTRIM(LTRIM(I.ADDRESS1_STATEORPROVINCE)) = '' THEN (select M.UF from [PRODUCAO_CRM_LYCEUM].[LYCEUM].[dbo].[LY_UNIDADE_ENSINO] E INNER JOIN [PRODUCAO_CRM_LYCEUM].[LYCEUM].[dbo].[HD_MUNICIPIO] M ON E.MUNICIPIO = M.MUNICIPIO WHERE  UNIDADE_ENS collate Latin1_General_CI_AI = CASE WHEN LEN(IC.ftc_CODCAMPUS) <= 1 THEN CONCAT('0',IC.ftc_CODCAMPUS) ELSE IC.ftc_CODCAMPUS END) 
			WHEN RTRIM(LTRIM(I.ADDRESS1_STATEORPROVINCE)) IS NULL THEN (select M.UF from [PRODUCAO_CRM_LYCEUM].[LYCEUM].[dbo].[LY_UNIDADE_ENSINO] E INNER JOIN [PRODUCAO_CRM_LYCEUM].[LYCEUM].[dbo].[HD_MUNICIPIO] M ON E.MUNICIPIO = M.MUNICIPIO WHERE  UNIDADE_ENS collate Latin1_General_CI_AI = CASE WHEN LEN(IC.ftc_CODCAMPUS) <= 1 THEN CONCAT('0',IC.ftc_CODCAMPUS) ELSE IC.ftc_CODCAMPUS END)
			ELSE RTRIM(LTRIM(I.ADDRESS1_STATEORPROVINCE))
		END UF              
		,IC.FTC_VANTAGEMAMIGA2 VANTAGEMAMIGA              
		,CASE 
			WHEN RTRIM(LTRIM(I.ADDRESS1_COMPOSITE)) = '' THEN '[Não informado]' 
			WHEN RTRIM(LTRIM(I.ADDRESS1_COMPOSITE)) IS NULL THEN '[Não informado]' 
			ELSE RTRIM(LTRIM(I.ADDRESS1_COMPOSITE)) 
		END ENDCOMPLETO              
		,c.cad_periodoletivo PERIODO_LETIVO              
		, CASE
			WHEN convert(VARCHAR,replace(replace(IC.ftc_notafinal,'.',''),',','.')) = '' then '0'             
			WHEN convert(VARCHAR,replace(replace(IC.ftc_notafinal,'.',''),',','.')) is null then '0'             
			ELSE convert(VARCHAR,replace(replace(IC.ftc_notafinal,'.',''),',','.')) 
		END ftc_notafinal              
		,IC.CAD_SITUACAO SITUACAOCONCURSO              
------------------- DADOS DO CONVOCADOS VEST ---------------------              
		,C.cad_codigo CONCURSO              
		,'1' ORDEM              
		,SUBSTRING(C.CAD_PERIODOLETIVO,1,4) ANO              
		,SUBSTRING(C.CAD_PERIODOLETIVO,6,2) SEMESTRE              
		,O.cad_nome              
		,IC.ftc_codcampus CODCAMPUS              
		,REPLACE(IC.ftc_codcurriculo,'.','') CODCURRICULO              
		,REPLACE(IC.ftc_codcurso,'.','') CODCURSO              
		,CASE IC.ftc_codturno               
			WHEN '1' THEN 'M'              
			WHEN '2' THEN 'V'              
			WHEN '3' THEN 'N'              
			WHEN '4' THEN 'I'              
			ELSE 'N'               
		END CODTURNO              
		,C.CAD_DATAFINAL DATAFINAL              
		,C.CAD_DATAINICIAL DATAINICIAL              
		,O.cad_quantidadevagas QUANTIDADEVAGAS              
		,O.cad_vagasdisponiveis VAGASDISPONIVEIS              
		,CASE O.cad_categorianome                
			WHEN 'FTC DE SALVADOR - COMERCIO' THEN '29'                
			WHEN 'FTC DE FEIRA DE SANTANA' THEN '03'              
			WHEN 'FTC DE ITABUNA' THEN '07'              
			WHEN 'FTC DE JEQUIÉ' THEN '06'                
			WHEN 'FTC DE CAMAÇARI' THEN '09'            
			WHEN 'FTC DE JUAZEIRO' THEN '21'              
			WHEN 'FTC DE SALVADOR - LAPA' THEN '29'              
			WHEN 'FTC DE SALVADOR - PARALELA' THEN '04'                          
			WHEN 'FTC DE PETROLINA' THEN '22'              
			WHEN 'FTC DE VITÓRIA DA CONQUISTA' THEN '05'              
			WHEN 'FTC DE SÃO PAULO' THEN '20'              
			WHEN 'UNESULBAHIA - EUNÁPOLIS' THEN '08'              
			ELSE 'S/N'                
		END COD_UNIDADE              
		,IC.cad_enemredacao              
		,IC.cad_enemmatematica              
		,IC.cad_enemlinguagens              
		,IC.cad_enemcienciashumanas              
		,IC.cad_enemcienciasnatureza              
-------------------------- DADOS DAS OFERTAS ----------------              
		,O.CAD_CODIGO OFERTA              
		,CASE IC.ftc_CODCAMPUS              
			WHEN '29' THEN 'FCS'              
			WHEN '3' THEN 'FTC-FSA'              
			WHEN '7' THEN 'FTC-ITA'              
			WHEN '6' THEN 'FTC-JEQ'              
			WHEN '21' THEN 'OTE-JUA'              
			WHEN '4' THEN 'FTC-SSA'              
			WHEN '22' THEN 'OTE-PET'              
			WHEN '5' THEN 'FTC-VIC'              
			WHEN '20' THEN 'OTE-SP'              
			WHEN '8' THEN 'UNECE-EUN'            
			WHEN '9' THEN 'FTC-CAM'             
			WHEN '24' THEN 'OTE-CAM'               
			ELSE ''              
		END AS UNIDADE_FISICA               
		,SUBSTRING(O.CAD_CONCURSONOME,1,150) DESCRICAO_ABREV              
		,NULL AS DT_INTEGRACAO              
		,replace(replace(ltrim(rtrim(IC.CAD_CPF)),'.',''),'-','') as SENHATAC              
		,IC.ftc_anoenem ANOENEM              
		,substring(C.ftc_tipoingressolyceum,0,90)            
		,O.FTC_SERIE                   
FROM CRMEDUCACIONAL..DY_Inscricao_Candidato IC              
INNER JOIN CRMEDUCACIONAL..DY_Interessado I ON 1 = 1 AND IC.CAD_CLIENTEPOTENCIALID = I.CAD_CODIGO              
INNER JOIN CRMEDUCACIONAL..DY_Concurso C ON 1 = 1 AND C.CAD_CODIGO = IC.CAD_CONCURSOID              
INNER JOIN CRMEDUCACIONAL.DBO.DY_OFERTAS O ON 1 = 1 AND IC.CAD_OFERTAID = O.cad_codigo              
WHERE 1 = 1               
AND IC.[cad_numeroinscricao ] = @CANDIDATO             
AND C.CAD_NOME not like '%DOM%' --- Para não enviar Alunos do Dom       
AND IC.CREATEDON > CONVERT(DATETIME,'31/07/2019',103) --- Pegar os dados a partir da data definida              
AND IC.CAD_SITUACAO IN('Convocado','Inscrito','Classificado') --- Pegar apenas essas situações              
AND( IC.ftc_codcampus <> ' ' OR LEN(IC.ftc_codcampus) > 1  ) ---Cod Campus não pode ser nulo nem branco    
AND( IC.ftc_codcurriculo <> ' ' OR LEN(IC.ftc_codcurriculo) > 1  ) ---Cod Curriculo não pode ser nulo nem em branco             
AND( IC.ftc_codcurso <> ' ' OR LEN(IC.ftc_codcurso) > 1  )  ---Cod Curso não pode ser nulo nem branco            
AND( IC.ftc_codturno <> ' ' OR LEN(IC.ftc_codturno) > 1  )  ---Cod Turno não pode ser nulo nem branco
AND C.CAD_NUMERO not in ('212','237','258') -- Não trazer candidatos desses concursos              
AND NOT EXISTS(              
SELECT TOP 1 1 FROM INTEGRACAO_CRM_LYCEUM..FTC_INTEGRACAO_CRM WHERE CANDIDATO COLLATE Latin1_General_CI_AS = IC.[cad_numeroinscricao ] COLLATE Latin1_General_CI_AS              
)      ---O candidato não pode estar integrado        
AND IC.cad_cpf IS NOT NULL -- Não pegar com CPF em branco               
AND IC.cad_cpf <> '000.0000.000-00' -- nÃO PEGAR cpf ZERO            
AND len(convert(VARCHAR,replace(replace(ftc_notafinal,'.',''),',','.'))) < 10 ---O campo de nota não pode ser nulo nem pode temais do que 9 dígitos (o valor máximo é 999999,99)          
and IC.CAD_NUMEROINSCRICAO not in ('CAN-332136-FTC')  --- Esse candidato não deve ser integrado
and ic.ftc_inscrioteste = '0' --- Não pode ser inscrição de teste
END TRY

BEGIN CATCH
	SELECT @V_ERRO = ERROR_NUMBER()
	IF @V_ERRO > 0
	BEGIN
	INSERT INTO ##GETERRO
	SELECT @CANDIDATO AS CANDIDATO, GETDATE() AS DATA_INTEGRACAO, ERROR_MESSAGE() AS MSG_ERRO
	END
END CATCH   

FETCH NEXT FROM CURSOR1 INTO @CANDIDATO

END
 -- Fechando Cursor para leitura
CLOSE CURSOR1

-- Desalocando o cursor
DEALLOCATE CURSOR1     
        