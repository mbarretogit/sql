USE [FTC_DATAMART]
GO
/****** Object:  Table [dbo].[BI_ACOMP_MATR]    Script Date: 08/05/2019 09:21:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BI_ACOMP_MATR](
	[ANO] [varchar](4) NULL,
	[SEMESTRE] [varchar](2) NULL,
	[UNIDADE_ENSINO_ALUNO] [varchar](20) NULL,
	[NOME_UNIDADE_ENSINO_ALUNO] [varchar](100) NULL,
	[TIPO_CURSO] [varchar](50) NULL,
	[CURSO] [varchar](20) NULL,
	[NOME_CURSO] [varchar](100) NULL,
	[SERIE] [numeric](10, 0) NULL,
	[TURNO] [varchar](20) NULL,
	[CONCURSO] [varchar](20) NULL,
	[DESC_CONCURSO] [varchar](100) NULL,
	[TIPO_ALUNO] [varchar](50) NULL,
	[TIPO_INGRESSO] [varchar](50) NULL,
	[TIPO_FINAN] [varchar](50) NULL,
	[PAGO] [numeric](10, 0) NULL,
	[NAO_PAGO] [numeric](10, 0) NULL,
	[BOLSISTA] [varchar](1) NULL,
	[DATA_PAGAMENTO] [datetime] NULL,
	[SIT_MATRICULA] [varchar](20) NULL,
	[DATA_MATRICULA] [datetime] NULL,
	[DATA_CANCELAMENTO] [datetime] NULL,
	[ORIGEM_MATRICULA] [varchar](50) NULL,
	[DATA_INGRESSO] [datetime] NULL,
	[ALUNO] [varchar](20) NULL,
	[CPF] [varchar](20) NULL,
	[NOME_ALUNO] [varchar](100) NULL,
	[CURRICULO] [varchar](20) NULL,
	[DATA_NASC] [datetime] NULL,
	[RG] [varchar](20) NULL,
	[E_MAIL] [varchar](100) NULL,
	[ENDERECO] [varchar](50) NULL,
	[NUMERO] [varchar](20) NULL,
	[COMPLEMENTO] [varchar](50) NULL,
	[CEP] [varchar](9) NULL,
	[BAIRRO] [varchar](50) NULL,
	[CIDADE] [varchar](100) NULL,
	[ESTADO] [varchar](2) NULL,
	[DDD_FONE] [varchar](3) NULL,
	[FONE] [varchar](30) NULL,
	[DDD_CELULAR] [varchar](3) NULL,
	[CELULAR] [varchar](30) NULL,
	[CONTRATO_ACEITO] [varchar](1) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BI_ACOMP_MATR_HIST]    Script Date: 08/05/2019 09:21:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BI_ACOMP_MATR_HIST](
	[DATA_HIST] [datetime] NULL,
	[ANO] [varchar](4) NULL,
	[SEMESTRE] [varchar](2) NULL,
	[UNIDADE_ENSINO_ALUNO] [varchar](20) NULL,
	[NOME_UNIDADE_ENSINO_ALUNO] [varchar](100) NULL,
	[TIPO_CURSO] [varchar](50) NULL,
	[CURSO] [varchar](20) NULL,
	[NOME_CURSO] [varchar](100) NULL,
	[SERIE] [numeric](10, 0) NULL,
	[TURNO] [varchar](20) NULL,
	[CONCURSO] [varchar](20) NULL,
	[DESC_CONCURSO] [varchar](100) NULL,
	[TIPO_ALUNO] [varchar](50) NULL,
	[TIPO_INGRESSO] [varchar](50) NULL,
	[TIPO_FINAN] [varchar](50) NULL,
	[PAGO] [numeric](10, 0) NULL,
	[NAO_PAGO] [numeric](10, 0) NULL,
	[BOLSISTA] [varchar](1) NULL,
	[DATA_PAGAMENTO] [datetime] NULL,
	[SIT_MATRICULA] [varchar](20) NULL,
	[DATA_MATRICULA] [datetime] NULL,
	[DATA_CANCELAMENTO] [datetime] NULL,
	[ORIGEM_MATRICULA] [varchar](50) NULL,
	[DATA_INGRESSO] [datetime] NULL,
	[ALUNO] [varchar](20) NULL,
	[CPF] [varchar](20) NULL,
	[NOME_ALUNO] [varchar](100) NULL,
	[CURRICULO] [varchar](20) NULL,
	[DATA_NASC] [datetime] NULL,
	[RG] [varchar](20) NULL,
	[E_MAIL] [varchar](100) NULL,
	[ENDERECO] [varchar](50) NULL,
	[NUMERO] [varchar](20) NULL,
	[COMPLEMENTO] [varchar](50) NULL,
	[CEP] [varchar](9) NULL,
	[BAIRRO] [varchar](50) NULL,
	[CIDADE] [varchar](100) NULL,
	[ESTADO] [varchar](2) NULL,
	[DDD_FONE] [varchar](3) NULL,
	[FONE] [varchar](30) NULL,
	[DDD_CELULAR] [varchar](3) NULL,
	[CELULAR] [varchar](30) NULL,
	[CONTRATO_ACEITO] [varchar](1) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BI_ACOMP_MATR_POS]    Script Date: 08/05/2019 09:21:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BI_ACOMP_MATR_POS](
	[UNIDADE_ENSINO_ALUNO] [varchar](20) NULL,
	[NOME_UNIDADE_ENSINO_ALUNO] [varchar](100) NULL,
	[TIPO_CURSO] [varchar](50) NULL,
	[CURSO] [varchar](20) NULL,
	[NOME_CURSO] [varchar](100) NULL,
	[TURMA_PREFERENCIAL] [varchar](20) NULL,
	[TURNO] [varchar](20) NULL,
	[PERIODO_INGRESSO] [varchar](10) NULL,
	[TIPO_ALUNO] [varchar](50) NULL,
	[PAGO] [numeric](10, 0) NULL,
	[NAO_PAGO] [numeric](10, 0) NULL,
	[ALUNO] [varchar](20) NULL,
	[CPF] [varchar](20) NULL,
	[NOME_ALUNO] [varchar](100) NULL,
	[CURRICULO] [varchar](20) NULL,
	[SIT_ALUNO] [varchar](30) NULL,
	[DT_INGRESSO] [datetime] NULL,
	[DT_INSERCAO] [datetime] NULL,
	[SIT_MATRICULA] [varchar](20) NULL,
	[RG] [varchar](20) NULL,
	[E_MAIL] [varchar](100) NULL,
	[ENDERECO] [varchar](50) NULL,
	[NUMERO] [varchar](20) NULL,
	[COMPLEMENTO] [varchar](50) NULL,
	[CEP] [varchar](9) NULL,
	[BAIRRO] [varchar](50) NULL,
	[CIDADE] [varchar](100) NULL,
	[ESTADO] [varchar](2) NULL,
	[DDD_FONE] [varchar](3) NULL,
	[FONE] [varchar](30) NULL,
	[DDD_CELULAR] [varchar](3) NULL,
	[CELULAR] [varchar](30) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BI_ACOMP_MATR_POS_HIST]    Script Date: 08/05/2019 09:21:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BI_ACOMP_MATR_POS_HIST](
	[DATA_HIST] [datetime] NULL,
	[UNIDADE_ENSINO_ALUNO] [varchar](20) NULL,
	[NOME_UNIDADE_ENSINO_ALUNO] [varchar](100) NULL,
	[TIPO_CURSO] [varchar](50) NULL,
	[CURSO] [varchar](20) NULL,
	[NOME_CURSO] [varchar](100) NULL,
	[TURMA_PREFERENCIAL] [varchar](20) NULL,
	[TURNO] [varchar](20) NULL,
	[PERIODO_INGRESSO] [varchar](10) NULL,
	[TIPO_ALUNO] [varchar](50) NULL,
	[PAGO] [numeric](10, 0) NULL,
	[NAO_PAGO] [numeric](10, 0) NULL,
	[ALUNO] [varchar](20) NULL,
	[CPF] [varchar](20) NULL,
	[NOME_ALUNO] [varchar](100) NULL,
	[CURRICULO] [varchar](20) NULL,
	[SIT_ALUNO] [varchar](30) NULL,
	[DT_INGRESSO] [datetime] NULL,
	[DT_INSERCAO] [datetime] NULL,
	[SIT_MATRICULA] [varchar](20) NULL,
	[RG] [varchar](20) NULL,
	[E_MAIL] [varchar](100) NULL,
	[ENDERECO] [varchar](50) NULL,
	[NUMERO] [varchar](20) NULL,
	[COMPLEMENTO] [varchar](50) NULL,
	[CEP] [varchar](9) NULL,
	[BAIRRO] [varchar](50) NULL,
	[CIDADE] [varchar](100) NULL,
	[ESTADO] [varchar](2) NULL,
	[DDD_FONE] [varchar](3) NULL,
	[FONE] [varchar](30) NULL,
	[DDD_CELULAR] [varchar](3) NULL,
	[CELULAR] [varchar](30) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BI_ALUNOS_UNIDADE]    Script Date: 08/05/2019 09:21:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BI_ALUNOS_UNIDADE](
	[PERIODO_LETIVO] [varchar](7) NULL,
	[UNIDADE_ENSINO_ALUNO] [varchar](50) NULL,
	[TIPO_CURSO] [varchar](50) NULL,
	[CENTRO_DE_CUSTO] [varchar](20) NULL,
	[DESCR_CENTRO_CUSTO] [varchar](200) NULL,
	[CURSO] [varchar](20) NULL,
	[NOME_CURSO] [varchar](200) NULL,
	[ALUNO] [varchar](20) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BI_CH_DOCENTE]    Script Date: 08/05/2019 09:21:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BI_CH_DOCENTE](
	[ANO] [varchar](4) NULL,
	[SEMESTRE] [varchar](2) NULL,
	[UNIDADE_FISICA] [varchar](20) NULL,
	[NOME_UNIDADE_FISICA] [varchar](100) NULL,
	[CPF] [varchar](20) NULL,
	[NOME_DOCENTE] [varchar](100) NULL,
	[CH_SEMESTRE] [numeric](18, 0) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BI_CURSOS_META]    Script Date: 08/05/2019 09:21:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BI_CURSOS_META](
	[NOME_CURSO] [varchar](100) NULL,
	[META] [int] NULL,
	[TIPO_CURSO] [varchar](30) NULL,
	[TIPO_ALUNO] [varchar](30) NULL,
	[TURNO] [varchar](1) NULL,
	[ANO] [varchar](4) NULL,
	[SEMESTRE] [varchar](2) NULL,
	[PERIODO_LETIVO] [varchar](10) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BI_EVASAO]    Script Date: 08/05/2019 09:21:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BI_EVASAO](
	[COD_UNIDADE_FISICA] [varchar](20) NULL,
	[NOME_UNIDADE_FISICA] [varchar](200) NULL,
	[TIPO_CURSO] [varchar](20) NULL,
	[COD_CURSO] [varchar](20) NULL,
	[NOME_CURSO] [varchar](200) NULL,
	[CURRICULO] [varchar](20) NULL,
	[TURNO] [varchar](20) NULL,
	[TIPO_INGRESSO] [varchar](20) NULL,
	[ANO_INGRESSO] [varchar](4) NULL,
	[SEM_INGRESSO] [varchar](2) NULL,
	[SITUACAO_ALUNO] [varchar](30) NULL,
	[ALUNO] [varchar](20) NULL,
	[NOME_ALUNO] [varchar](200) NULL,
	[DT_ENCERRAMENTO] [datetime] NULL,
	[ANO_ENCERRAMENTO] [varchar](4) NULL,
	[SEM_ENCERRAMENTO] [varchar](2) NULL,
	[MOTIVO_ENCERRAMENTO] [varchar](30) NULL,
	[CAUSA_ENCERRAMENTO] [varchar](20) NULL,
	[PERIODO_ENCERRAMENTO] [varchar](7) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BI_FINANCEIRO]    Script Date: 08/05/2019 09:21:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BI_FINANCEIRO](
	[LANC_CRED] [numeric](18, 0) NULL,
	[TIPO_COBRANCA] [varchar](50) NULL,
	[COBRANCA] [numeric](18, 0) NULL,
	[COBRANCA_ESTORNADA] [varchar](1) NULL,
	[DATA_ESTORNO] [datetime] NULL,
	[TIPO_PAGAMENTO] [varchar](30) NULL,
	[TIPO_CREDITO] [varchar](20) NULL,
	[COD_UNIDADE] [varchar](20) NULL,
	[TIPO_CURSO] [varchar](30) NULL,
	[COD_CURSO] [varchar](20) NULL,
	[NOME_CURSO] [varchar](200) NULL,
	[ALUNO] [varchar](20) NULL,
	[RESPONSAVEL] [varchar](20) NULL,
	[DATA_FATURAMENTO] [datetime] NULL,
	[DATA_REF] [datetime] NULL,
	[DATA_VENCIMENTO] [datetime] NULL,
	[DATA_PAGAMENTO] [datetime] NULL,
	[DATA_RECEBIMENTO] [datetime] NULL,
	[TIPO_BOLSA] [varchar](100) NULL,
	[VALOR_BRUTO] [decimal](10, 2) NULL,
	[VALOR_LIQUIDO] [decimal](10, 2) NULL,
	[BOLSA] [decimal](10, 2) NULL,
	[MULTA] [decimal](10, 2) NULL,
	[PERDEBOLSA] [decimal](10, 2) NULL,
	[JUROS] [decimal](10, 2) NULL,
	[DESCONTOS] [decimal](10, 2) NULL,
	[VALOR_ESTORNO] [decimal](10, 2) NULL,
	[VALOR_PAGO] [decimal](10, 2) NULL,
	[SALDO] [decimal](10, 2) NULL,
	[PAGO] [varchar](1) NULL,
	[VENCIDA] [varchar](1) NULL,
	[PERIODO_LETIVO] [varchar](7) NULL,
	[AGING] [varchar](30) NULL,
	[TIPO_FINAN] [varchar](30) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BI_GESTAO_PESSOAS]    Script Date: 08/05/2019 09:21:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BI_GESTAO_PESSOAS](
	[CODEMPRESA] [numeric](5, 0) NULL,
	[EMPRESA] [varchar](255) NULL,
	[FILIAL] [varchar](60) NULL,
	[CODSECAO] [varchar](35) NULL,
	[SECAO] [varchar](60) NULL,
	[MES_COMPETENCIA] [numeric](5, 0) NULL,
	[ANO_COMPETENCIA] [numeric](5, 0) NULL,
	[PERIODO_FOLHA] [numeric](5, 0) NULL,
	[MATRICULA] [varchar](20) NULL,
	[FUNCIONARIO] [varchar](120) NULL,
	[SEXO] [varchar](1) NULL,
	[TIPO_RECEBIMENTO] [varchar](10) NULL,
	[TIPO_FUNCIONARIO] [varchar](50) NULL,
	[PCD] [varchar](3) NULL,
	[SITUACAO_ATUAL] [varchar](50) NULL,
	[SITUACAO_HISTORICA] [varchar](50) NULL,
	[MOTIVO_DEMISSAO] [varchar](50) NULL,
	[DATA_SITUACAO_HISTORICA] [varchar](10) NULL,
	[DATA_INICIO_FERIAS] [varchar](10) NULL,
	[DATA_FIM_FERIAS] [varchar](10) NULL,
	[TIPO_AFASTAMENTO] [varchar](50) NULL,
	[MOTIVO_AFASTAMENTO] [varchar](50) NULL,
	[INICIO_AFASTAMENTO] [varchar](10) NULL,
	[FIM_AFASTAMENTO] [varchar](10) NULL,
	[CPF] [varchar](11) NULL,
	[DATA_NASCIMENTO] [varchar](10) NULL,
	[DATA_ADMISSAO] [varchar](10) NULL,
	[DATA_DEMISSAO] [varchar](10) NULL,
	[FUNCAO] [varchar](100) NULL,
	[GRAU_INSTRUCAO] [varchar](255) NULL,
	[NIVEL_SALARIAL] [varchar](10) NULL,
	[CODHORARIO] [varchar](10) NULL,
	[HORARIO_TRABALHO] [varchar](100) NULL,
	[SUBGRUPO] [varchar](30) NULL,
	[CODCUSTO] [varchar](25) NULL,
	[CCUSTO] [varchar](60) NULL,
	[CCUSTO_PERCENT] [numeric](15, 2) NULL,
	[CODEVENTO] [varchar](4) NULL,
	[EVENTO] [varchar](80) NULL,
	[TIPO_EVENTO] [varchar](8) NULL,
	[EVENTO_REF] [numeric](15, 2) NULL,
	[VALOR_EVENTO] [numeric](18, 0) NULL,
	[SALARIO_CADASTRO] [numeric](18, 0) NULL,
	[SALARIO_HISTORICO] [numeric](15, 2) NULL,
	[LIQUIDO_FOLHA_EVENTO_MES] [numeric](15, 2) NULL,
	[LIQUIDO_TOTAL_MES] [numeric](18, 0) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BI_METAS]    Script Date: 08/05/2019 09:21:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BI_METAS](
	[ANO] [varchar](4) NULL,
	[SEMESTRE] [varchar](2) NULL,
	[TIPO_CURSO] [varchar](30) NULL,
	[COD_UNIDADE] [varchar](20) NULL,
	[NOME_UNIDADE] [varchar](100) NULL,
	[NOME_CURSO] [varchar](100) NULL,
	[TURNO] [varchar](1) NULL,
	[METAS] [int] NULL,
	[TIPO_ALUNO] [varchar](20) NULL,
	[PERIODO_LETIVO] [varchar](10) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BI_REMATRICULA]    Script Date: 08/05/2019 09:21:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BI_REMATRICULA](
	[ANO] [varchar](4) NULL,
	[SEMESTRE] [varchar](2) NULL,
	[STATUS_FTC] [varchar](50) NULL,
	[UNIDADE_ENSINO_ALUNO] [varchar](20) NULL,
	[NOME_UNIDADE_ENSINO_ALUNO] [varchar](100) NULL,
	[UNIDADE_FISICA_ALUNO] [varchar](30) NULL,
	[TIPO_CURSO] [varchar](50) NULL,
	[CURSO] [varchar](20) NULL,
	[NOME_CURSO] [varchar](100) NULL,
	[CURRICULO] [varchar](20) NULL,
	[TURNO] [varchar](20) NULL,
	[SERIE] [smallint] NULL,
	[SERIE_CALCULADA] [smallint] NULL,
	[TIPO_ALUNO] [varchar](50) NULL,
	[TIPO_INGRESSO] [varchar](50) NULL,
	[ANO_INGRESSO] [varchar](4) NULL,
	[SEM_INGRESSO] [varchar](2) NULL,
	[ALUNO] [varchar](20) NULL,
	[CPF] [varchar](20) NULL,
	[NOME_ALUNO] [varchar](100) NULL,
	[E_MAIL] [varchar](100) NULL,
	[DDD] [varchar](10) NULL,
	[FONE] [varchar](30) NULL,
	[CELULAR] [varchar](30) NULL,
	[CEP] [varchar](10) NULL,
	[MUNICIPIO] [varchar](20) NULL,
	[SIT_MATRICULA] [varchar](50) NULL,
	[PAGO] [smallint] NULL,
	[NAO_PAGO] [smallint] NULL,
	[TIPO_FINAN] [varchar](50) NULL,
	[FINAN] [varchar](10) NULL,
	[DATA_PERIODO] [varchar](10) NULL,
	[INDICE_REPROVACAO] [decimal](10, 2) NULL,
	[QTD_INADIMP] [int] NULL,
	[PERC_FALTAS] [decimal](10, 2) NULL,
	[DATA_MATRICULA] [varchar](10) NULL,
	[ANTECIP_FINAN] [varchar](1) NULL,
	[DT_ANTECIP] [varchar](10) NULL,
	[TIPO_ANTECIP] [varchar](20) NULL,
	[VALOR_ATENCIP] [decimal](10, 2) NULL,
	[PERFIL_EVASAO] [varchar](30) NULL,
	[ULTIMA_MATRICULA] [varchar](6) NULL,
	[SOLICITOU_PLANO] [varchar](1) NULL,
	[SOLICITOU_HIST] [varchar](1) NULL,
	[TIPO_TRANSF] [varchar](50) NULL,
	[VALOR_MENSALIDADE] [decimal](10, 2) NULL,
	[VALOR_SEMESTRALIDADE] [decimal](10, 2) NULL,
	[DT_ENCERRAMENTO] [varchar](10) NULL,
	[BOLSISTA] [varchar](1) NULL,
	[MEDIA_PERC_BOLSA] [decimal](10, 2) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BI_REMATRICULA_HIST]    Script Date: 08/05/2019 09:21:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BI_REMATRICULA_HIST](
	[DATA_HIST] [datetime] NULL,
	[ANO] [varchar](4) NULL,
	[SEMESTRE] [varchar](2) NULL,
	[STATUS_FTC] [varchar](50) NULL,
	[UNIDADE_ENSINO_ALUNO] [varchar](20) NULL,
	[NOME_UNIDADE_ENSINO_ALUNO] [varchar](100) NULL,
	[UNIDADE_FISICA_ALUNO] [varchar](30) NULL,
	[TIPO_CURSO] [varchar](50) NULL,
	[CURSO] [varchar](20) NULL,
	[NOME_CURSO] [varchar](100) NULL,
	[CURRICULO] [varchar](20) NULL,
	[TURNO] [varchar](20) NULL,
	[SERIE] [smallint] NULL,
	[SERIE_CALCULADA] [smallint] NULL,
	[TIPO_ALUNO] [varchar](50) NULL,
	[TIPO_INGRESSO] [varchar](50) NULL,
	[ANO_INGRESSO] [varchar](4) NULL,
	[SEM_INGRESSO] [varchar](2) NULL,
	[ALUNO] [varchar](20) NULL,
	[CPF] [varchar](20) NULL,
	[NOME_ALUNO] [varchar](100) NULL,
	[E_MAIL] [varchar](100) NULL,
	[DDD] [varchar](10) NULL,
	[FONE] [varchar](30) NULL,
	[CELULAR] [varchar](30) NULL,
	[CEP] [varchar](10) NULL,
	[MUNICIPIO] [varchar](20) NULL,
	[SIT_MATRICULA] [varchar](50) NULL,
	[PAGO] [smallint] NULL,
	[NAO_PAGO] [smallint] NULL,
	[TIPO_FINAN] [varchar](50) NULL,
	[FINAN] [varchar](10) NULL,
	[DATA_PERIODO] [varchar](10) NULL,
	[INDICE_REPROVACAO] [decimal](10, 2) NULL,
	[QTD_INADIMP] [int] NULL,
	[PERC_FALTAS] [decimal](10, 2) NULL,
	[DATA_MATRICULA] [varchar](10) NULL,
	[ANTECIP_FINAN] [varchar](1) NULL,
	[DT_ANTECIP] [varchar](10) NULL,
	[TIPO_ANTECIP] [varchar](20) NULL,
	[VALOR_ATENCIP] [numeric](20, 2) NULL,
	[PERFIL_EVASAO] [varchar](30) NULL,
	[ULTIMA_MATRICULA] [varchar](6) NULL,
	[SOLICITOU_PLANO] [varchar](1) NULL,
	[SOLICITOU_HIST] [varchar](1) NULL,
	[TIPO_TRANSF] [varchar](50) NULL,
	[VALOR_MENSALIDADE] [decimal](10, 2) NULL,
	[VALOR_SEMESTRALIDADE] [decimal](10, 2) NULL,
	[DT_ENCERRAMENTO] [varchar](10) NULL,
	[BOLSISTA] [varchar](1) NULL,
	[MEDIA_PERC_BOLSA] [decimal](10, 2) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BI_VALOR_MENSALIDADE]    Script Date: 08/05/2019 09:21:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BI_VALOR_MENSALIDADE](
	[CURSO] [varchar](20) NULL,
	[TURNO] [varchar](1) NULL,
	[CURRICULO] [varchar](20) NULL,
	[SERIE] [smallint] NULL,
	[ANO] [varchar](4) NULL,
	[SEMESTRE] [varchar](2) NULL,
	[VALOR_MENSALIDADE] [decimal](10, 2) NULL
) ON [PRIMARY]
GO
