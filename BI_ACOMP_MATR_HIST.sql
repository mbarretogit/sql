USE FTC_DATAMART
GO

--DROP TABLE BI_ACOMP_MATR_HIST

CREATE TABLE BI_ACOMP_MATR_HIST (
	[DATA_HIST] DATETIME,
	[ANO] VARCHAR(4),
	[SEMESTRE] VARCHAR(2),
	[UNIDADE_ENSINO_ALUNO]	VARCHAR(20),
	[NOME_UNIDADE_ENSINO_ALUNO] VARCHAR(100),
	[TIPO_CURSO] VARCHAR(50),
	[CURSO] VARCHAR(20),
	[NOME_CURSO] VARCHAR(100),
	[SERIE] NUMERIC(10),
	[TURNO] VARCHAR(20),
	[CONCURSO] VARCHAR(20),
	[DESC_CONCURSO] VARCHAR(100),
	[TIPO_ALUNO] VARCHAR(50),
	[TIPO_INGRESSO] VARCHAR(50),
	[TIPO_FINAN] VARCHAR(50),
	[PAGO] NUMERIC(10),
	[NAO_PAGO] NUMERIC(10),
	[BOLSISTA] VARCHAR(1),
	[DATA_PAGAMENTO] DATETIME,
	[SIT_MATRICULA] VARCHAR(20),
	[DATA_MATRICULA] DATETIME,
	[DATA_CANCELAMENTO] DATETIME,
	[ORIGEM_MATRICULA] VARCHAR(50),
	[DATA_INGRESSO] DATETIME,
	[ALUNO] VARCHAR(20),
	[CPF] VARCHAR(20),
	[NOME_ALUNO] VARCHAR(100),
	[CURRICULO] VARCHAR(20),
	[DATA_NASC] DATETIME,
	[RG] VARCHAR(20),
	[E_MAIL] VARCHAR(100),
	[ENDERECO] VARCHAR(50),
	[NUMERO] VARCHAR(20),
	[COMPLEMENTO] VARCHAR(50),
	[CEP] VARCHAR(9),
	[BAIRRO] VARCHAR(50),
	[CIDADE] VARCHAR(100),
	[ESTADO] VARCHAR(2),
	[DDD_FONE] VARCHAR(3),
	[FONE] VARCHAR(30),
	[DDD_CELULAR] VARCHAR(3),
	[CELULAR] VARCHAR(30),
	[CONTRATO_ACEITO] VARCHAR(1),

)
	
	ALTER TABLE BI_ACOMP_MATR_HIST
		--ADD [BOLSAS] VARCHAR(100)
		--ADD [DATA_MATRICULA_ORC] VARCHAR(10)
		--ADD	[TIPO_CREDITO] VARCHAR(50)
		--ADD [DATA_VENCIMENTO] DATETIME
		--ADD [DATA_VENCIMENTO_ORI] DATETIME
		ADD [TIPO_PAGAMENTO] VARCHAR(50)