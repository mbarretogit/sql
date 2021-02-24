USE LYCEUM
GO

                  
CREATE VIEW VW_ALUNOS_CENSO                   
                  
AS                   
                  
                  
--SELECT * FROM VW_ALUNOS_CENSO_1                  
                  
Select             
                  
        p.pessoa      Pessoa,                   
                  
        a.aluno       Aluno,                    
                  
        --a.dt_ingresso     dt_ingresso,  -- 30-03-2017,                  
                  
        --dbo.fn_getdatadiasemhora(ISNULL(a.dt_ingresso,convert(varchar,a.ano_ingresso) + '-' + (case a.sem_ingresso when 1 then '01' else '07' end) + '-' + '01')) as dt_ingresso,                   
         dbo.fn_getdatadiasemhora(convert(varchar,a.ano_ingresso) + '-' + (case a.sem_ingresso when 1 then '01' else '07' end) + '-' + '01') as dt_ingresso,         
        a.curso       Curso,                    
                  
        c.inep_presencial    Modalidade,                   
                  
        '40'       TipoRegistro1,                    
                  
        ue.inep_faculdade    CodigoIes,                    
                  
        '4'        TipoArquivo,                   
                  
        '41'       TipoRegistro2,                   
                  
        p.id_censo      IdAlunoInep,                   
                  
        p.pessoa      IdAlunoIES,                   
                  
       dbo.fn_removeacentos(upper(p.nome_compl))    NomeAluno,                   
       --upper(p.nome_compl_ NomeAluno,                  
        p.cpf       cpf,                   
                  
        upper(p.passaporte)    Passaporte,                   
                  
        convert(varchar,p.dt_nasc,103) DataNascimento,                   
                  
        p.sexo       Sexo,                   
                  
        p.cor_raca      CorRaça,                   
                  
        ''/*upper(p.nome_mae)*/    NomeMãe,                   
                  
        p.nacionalidade     Nacionalidade,                   
                  
        p.municipio_nasc    UfNascimento,                   
                  
        p.municipio_nasc    MunicipioNascimento,                   
                  
        p.pais_nasc      PaisNascimento,                   
                  
        case isnull(p.necessidade_especial, '@*@*@*@')                   
                  
            when '@*@*@*@'                   
                  
                 then 0                   
                  
       when ''                   
                  
                 then 0                   
                  
            else 1                   
                  
        end        AlunoComDeficiência,                   
                  
        p.necessidade_especial   TipoDeficiência,                   
                  
        CONVERT(varchar(1), '')   TipoDeficienciaCegueira,                   
                  
        CONVERT(varchar(1), '')   TipoDeficienciaBaixaVisao,                     
                  
        CONVERT(varchar(1), '')   TipoDeficienciaSurdez,                     
                  
        CONVERT(varchar(1), '')   TipoDeficienciaAuditiva,                     
                  
        '0'/*CONVERT(varchar(1), '')*/   TipoDeficienciaFisica,                     
                  
        CONVERT(varchar(1), '')   TipoDeficienciaSurdocegueira,                     
                  
        CONVERT(varchar(1), '')   TipoDeficienciaMultipla,                     
                  
        CONVERT(varchar(1), '')   TipoDeficienciaIntelectual,                     
                  
        CONVERT(varchar(1), '')   TipoDeficienciaAutismo,                     
                  
        CONVERT(varchar(1), '')   TipoDeficienciaAsperger,                     
                  
        CONVERT(varchar(1), '')   TipoDeficienciaRett,                     
                  
        CONVERT(varchar(1), '')   TipoDeficienciaDesintegrat,                                       
        CONVERT(varchar(1), '')   TipoDeficienciaSuperdot,                     
                  
        '42'       TipoRegistro3,                   
                  
        CONVERT(varchar(1), '')   SemestreRef,                     
                  
        c.inep_curso     IdCursoInep,                     
                  
        ''/*a.unidade_fisica*/    PoloEadInep,                   
          
  a.turno       TurnoAluno,                       
                  
        CONVERT(varchar(100), '')  SituaçãoVínculo,                    
                  
  CONVERT(varchar(12), '')  CursoOrigem,                   
                  
        CONVERT(varchar(1), '')   SemestreConclCurso,                   
                  
        c.inep_grau      GrauAcademico,                   
                  
  c.INEP_NIVEL     NivelAcademico,                   
                  
        CONVERT(varchar(1), '')   AlunoPARFOR,                              
                  
 --convert(varchar,a.dt_ingresso,103) DataIngresso,                 
  dbo.fn_getdatadiasemhora(ISNULL(a.dt_ingresso,convert(varchar,a.ano_ingresso) + '-' + (case a.sem_ingresso when 1 then '01' else '07' end) + '-' + '01'))   DataIngresso,                
                  
  --convert(varchar,a.dt_ingresso,103) SemestreIngresso,                 
   CONVERT(VARCHAR(19),dbo.fn_getdatadiasemhora(ISNULL(a.dt_ingresso,convert(varchar,a.ano_ingresso) + '-' + (case a.sem_ingresso when 1 then '01' else '07' end) + '-' + '01')),121)   SemestreIngresso,                  
                   
                  
  '0'/*inst.tipo_origem*/    AluProcEscolaPublica,                     
                  
        a.tipo_ingresso     FormaIngresso,                    
                  
        CONVERT(varchar(1), '')   FormaIngressoVestibular,                     
                  
        CONVERT(varchar(1), '')   FormaIngressoEnem,                   
                  
        CONVERT(varchar(1), '')   FormaIngressoAvalSeriada,                     
                  
        CONVERT(varchar(1), '')   FormaIngrSelecaoSimplificada,                     
                  
  CONVERT(varchar(1), '')   FormaIngrEgressoBILI,                     
                  
        CONVERT(varchar(1), '')   FormaIngressoPECG,                   
                  
        CONVERT(varchar(1), '')   FormaIngressoTransfExOficio,                   
                  
        CONVERT(varchar(1), '')   FormaIngressoDecisaoJudicial,                   
                  
  CONVERT(varchar(1), '')   FormaIngrVagasRemanescentes,                   
                  
  CONVERT(varchar(1), '')   FormaIngrProgEspeciais,                     
                  
       '0'/*CONVERT(varchar(1), '')*/   MobilidadeAcademica,                   
                  
        CONVERT(varchar(1), '')   TipoMobilAcad,                   
                  
        CONVERT(varchar(12), '')  IESDestino,                   
                  
        CONVERT(varchar(1), '')   TipoMobilAcadInternacional,                   
                  
   CONVERT(varchar(3), '')   PaisDestino,                     
                  
        CONVERT(varchar(1), '')   ProgrReservaVagasAfirmativas,                     
                  
        CONVERT(varchar(100), '')  ProgramaReserva,                     
                  
        CONVERT(varchar(1), '')   ProgramaReservaVagasEtnico,                     
                  
        CONVERT(varchar(1), '')   ProgrResVagasPesComDeficiencia,                     
                  
        CONVERT(varchar(1), '')   ProgrResVagasEsteEnsinoPublico,                     
                  
        CONVERT(varchar(1), '')   ProgrResVagasSocRendaFamiliar,                    
                  
        CONVERT(varchar(1), '')   ProgramaReservaVagasOutros,                    
                  
        CONVERT(varchar(100), '')  CategoriaAdmIES,                   
                  
        CONVERT(varchar(100), '')  OrganizacaoAcademicaIES,                        
                  
        (SELECT  TOP 1 B.ALUNO FROM  LY_BOLSA B WHERE 1=1 AND  B.TIPO_BOLSA LIKE'%FIES%' AND  B.ANOINI=2016 AND B.ANOFIM=2016 AND B.ALUNO=A.ALUNO)   FinanciamentoEstudandil,   --CONVERT(varchar(100), '')                 
                  
        CONVERT(varchar(100), '')  TiposFinanciamentoEstudandil,                     
                  
        (SELECT  TOP 1 B.ALUNO FROM  LY_BOLSA B WHERE 1=1 AND  B.TIPO_BOLSA LIKE'%FIES%' AND  B.ANOINI=2016 AND B.ANOFIM=2016 AND B.ALUNO=A.ALUNO)  TiposFinancEstReembolsavelFies, --CONVERT(varchar(1), '')                    
                  
        (SELECT  TOP 1 B.ALUNO FROM  LY_BOLSA B WHERE 1=1 AND  B.TIPO_BOLSA LIKE'%FIES%' AND  B.ANOINI=2016 AND B.ANOFIM=2016 AND B.ALUNO=A.ALUNO)   TiposFinancEstReembolGovEstado, --CONVERT(varchar(1), '')                     
                  
        (SELECT  TOP 1 B.ALUNO FROM  LY_BOLSA B WHERE 1=1 AND  B.TIPO_BOLSA LIKE'%FIES%' AND  B.ANOINI=2016 AND B.ANOFIM=2016 AND B.ALUNO=A.ALUNO)   TiposFinancEstReembolGovMunic,    --CONVERT(varchar(1), '')                 
                  
         (SELECT  TOP 1 B.ALUNO FROM  LY_BOLSA B WHERE 1=1 AND  B.TIPO_BOLSA LIKE'%FIES%' AND  B.ANOINI=2016 AND B.ANOFIM=2016 AND B.ALUNO=A.ALUNO)  TiposFinancEstReembolsavelIES,  --CONVERT(varchar(1), '')                   
                  
        (SELECT  TOP 1 B.ALUNO FROM  LY_BOLSA B WHERE 1=1 AND  B.TIPO_BOLSA LIKE'%FIES%' AND  B.ANOINI=2016 AND B.ANOFIM=2016 AND B.ALUNO=A.ALUNO)  TiposFinancEstReembolEntExt,                     
                  
        (SELECT  TOP 1 B.ALUNO FROM  LY_BOLSA B WHERE 1=1 AND  B.TIPO_BOLSA IN ('PROUNI100','PROUNI_100') AND  B.ANOINI=2016 AND B.ANOFIM=2016 AND B.ALUNO=A.ALUNO)   TipFinancEstNAOReembProUniInt,  --CONVERT(varchar(1), '')                   
                  
        (SELECT  TOP 1 B.ALUNO FROM  LY_BOLSA B WHERE 1=1 AND  B.TIPO_BOLSA IN ('PROUNI_50','PROUNI50') AND  B.ANOINI=2016 AND B.ANOFIM=2016 AND B.ALUNO=A.ALUNO)    TipFinancEstNAOReembProUniParc, --CONVERT(varchar(1), '')                  
                  
        (SELECT  TOP 1 B.ALUNO FROM  LY_BOLSA B WHERE 1=1 AND  B.TIPO_BOLSA LIKE'%FIES%' AND  B.ANOINI=2016 AND B.ANOFIM=2016 AND B.ALUNO=A.ALUNO)   TipFinancEstNAOReembEntExt,                     
                  
        (SELECT  TOP 1 B.ALUNO FROM  LY_BOLSA B WHERE 1=1 AND  B.TIPO_BOLSA LIKE'%FIES%' AND  B.ANOINI=2016 AND B.ANOFIM=2016 AND B.ALUNO=A.ALUNO)  TipFinancEstNAOReembGovEstado,                     
                  
        (SELECT  TOP 1 B.ALUNO FROM  LY_BOLSA B WHERE 1=1 AND  B.TIPO_BOLSA LIKE'%FIES%' AND  B.ANOINI=2016 AND B.ANOFIM=2016 AND B.ALUNO=A.ALUNO)    TiposFinancEstNAOReembIES,                    
                  
        (SELECT  TOP 1 B.ALUNO FROM  LY_BOLSA B WHERE 1=1 AND  B.TIPO_BOLSA LIKE'%FIES%' AND  B.ANOINI=2016 AND B.ANOFIM=2016 AND B.ALUNO=A.ALUNO)    TipFinancEstNAOReembGovMunic,                     
                  
        CONVERT(varchar(100), '')  ApoioSocial,                     
                  
        CONVERT(varchar(100), '')  TiposApoioSocial,                      
                  
        CONVERT(varchar(1), '')   TiposApoioSocialAlimentacao,                     
                  
        CONVERT(varchar(1), '')   TiposApoioSocialMoradia,                     
                  
        CONVERT(varchar(1), '')   TiposApoioSocialTransporte,                     
                  
        CONVERT(varchar(1), '')   TiposApoioSocialMaterialDidat,                     
                  
        CONVERT(varchar(1), '')   TiposApoioSocialBolsaTrabalho,                     
                  
        CONVERT(varchar(1), '')   TiposApoioSocBolsaPermanencia,                     
                  
        CONVERT(varchar(100), '')  AtividadeExtracurricular,                     
                  
        CONVERT(varchar(100), '')  TiposAtividadeExtracurricular,                     
                  
        CONVERT(varchar(1), '')   TiposAtivExtracurricularPesquisa,                     
                  
        CONVERT(varchar(1), '')   BolsaRemuneracaoPesquisa,                   
                  
        CONVERT(varchar(1), '')   TiposAtivExtracurricularExtensao,                     
                  
        CONVERT(varchar(1), '')   BolsaRemuneracaoExtensao,                     
                  
        CONVERT(varchar(1), '')   TiposAtivExtracurricularMonit,                     
                  
        CONVERT(varchar(1), '')   BolsaRemuneracaoMonitoria,                     
                  
        CONVERT(varchar(1), '')   TpAtivExtracurricularEstagNaoObrig,                     
                  
        CONVERT(varchar(1), '')   BolsaRemuneracaoEstagNaoObrig,                   
                  
  CONVERT(varchar,isnull(cur.AULAS_PREVISTAS,0))         CargaHorariaTotalCurso,                   
                  
                    
                  
  (select  CONVERT(varchar,isnull(sum(h.horas_aula),0))       
                  
  from LY_HISTMATRICULA h where h.ALUNO = a.ALUNO                    
                  
  and h.SITUACAO_HIST <> 'Cancelado' and h.SITUACAO_HIST <> 'Trancado'                    
                  
  and h.SITUACAO_HIST <> 'Rep Nota' and h.SITUACAO_HIST <> 'Rep Freq')                     
                  
                CargaHorariaIntegralizada                         
                  
From ly_aluno a join ly_pessoa p                   
                  
                     on a.pessoa = p.pessoa                   
                  
                join ly_curso c                   
                  
                     on a.curso = c.curso                   
                  
    join LY_CURRICULO cur                    
                  
      on cur.CURSO = a.CURSO and cur.TURNO = a.TURNO and cur.CURRICULO = a.CURRICULO                   
                  
                join ly_unidade_ensino ue                   
                  
                     on c.faculdade = ue.unidade_ens                   
                  
                join ly_unidade_fisica uf                   
                  
                     on a.unidade_fisica = uf.unidade_fis                   
                  
    left join ly_instituicao inst                   
                  
      on a.instituicao = inst.outra_faculdade               
   INNER JOIN LY_CURSO Curso ON A.CURSO=Curso.CURSO                
                  
Where  1=1                     
 AND Curso.TIPO IN ('GRADUACAO')    
 AND (                   
                  
   exists (                   
                  
      SELECT 1                     
                  
      FROM   LY_ALUNO AE INNER JOIN LY_PESSOA PE                    
                  
                ON                    
                  
                 AE.PESSOA = PE.PESSOA                    
                  
           INNER JOIN LY_HISTMATRICULA HE                    
                  
                ON                    
                  
                 HE.ALUNO = AE.ALUNO                     
                  
           INNER JOIN LY_CURSO CE                    
                  
                ON                    
                  
                 AE.CURSO = CE.CURSO                    
                            
                  
      WHERE 1 = 1                   
                  
        and (HE.ANO = 2016)                   
                  
        and AE.PESSOA = A.PESSOA                    
                  
        AND CE.CURSO = A.CURSO                   
                  
        AND HE.ALUNO = A.ALUNO                   
                     
      UNION                   
                  
      SELECT 1                     
                  
      FROM LY_H_CURSOS_CONCL HCC INNER JOIN LY_ALUNO AE2                    
                  
                ON                    
                  
                 HCC.ALUNO = AE2.ALUNO                    
                  
              INNER JOIN LY_CURSO CE2                    
         
                ON                    
                  
                 AE2.CURSO = CE2.CURSO                     
                  
      WHERE 1 =1                    
                  
        and (HCC.ANO_ENCERRAMENTO = 2016 )                    
                  
        and  (HCC.MOTIVO = 'Evasao')                    
                  
        AND HCC.ALUNO = A.ALUNO                   
                  
        AND HCC.CURSO = A.CURSO                   
                  
        AND AE2.PESSOA = A.PESSOA                                
                  
     )                           
    or  a.ano_ingresso = 2016                     
  )                               
  and a.UNIDADE_FISICA in ('FCS') --('FTC-JEQ','FTC-SSA','FTC-FSA','FTC-ITA','FTC-VIC','FCS')          
  AND a.sit_aluno not in ('Cancelado')      
  --AND a.curso NOT IN ('617')/*FTC-JEQ*/          
  AND A.CURSO NOT IN ('591','589','373','2673','2572','2451','2573','3247','3246','2087','31','617','291','2428','66','583','457','456','2560','8','10','69','67','1','3','4','458','461','495','464')/* FTC-FSA*/          
  --AND NOT EXISTS( SELECT 1 FROM  dbo.LY_HISTMATRICULA lh WHERE LH.ALUNO=A.ALUNO AND ANO=2016)            
            
  --AND a.tipo_ingresso NOT IN ('Outros','TransferenciaInterna','MatriculaEspecial','FIES','Reingresso','TransferenciaExterna','PROUNI','ReaberturaMatrícula')           
  AND (select  CONVERT(varchar,isnull(sum(h.horas_aula),0))                    
                  
  from LY_HISTMATRICULA h where h.ALUNO = a.ALUNO                    
                  
  and h.SITUACAO_HIST <> 'Cancelado' and h.SITUACAO_HIST <> 'Trancado'                    
                  
  and h.SITUACAO_HIST <> 'Rep Nota' and h.SITUACAO_HIST <> 'Rep Freq')  > '0.00'    
  and a.aluno  not in ('162290028') /*FTC-SSA*/          
 and a.aluno  not in ('162070022') /*FTC-ITA*/      
 -- AND EXISTS (SELECT 1 FROM  LY_FL_ALUNO LA where 1=1 AND LA.ALUNO=A.ALUNO fl_field_02='978870')      
 --AND p.cpf IN  (SELECT CPF FROM LYCEUMTEMP..FTC_ALUNO_CENSO_2017)    