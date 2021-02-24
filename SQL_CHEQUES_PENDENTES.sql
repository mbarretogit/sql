select  
    CA_Aluno.IDAluno as 'COD_ALUNO_VIRTUAL' ,
    CA_Aluno.Nome as 'NOME',
    CA_Curso.IDCurso as 'CODIGO CURSO',
    CA_Turma.Turno as 'TURNO',
    RE_AlunoXCurso.IDGradeCurricular as 'CODIGO CURRICULO',
    CA_Cheque.IDCheque as 'ID CHEQUE',
    CA_Cheque.Valor as 'Valor',
    RE_MensalidadeXAluno2.Parcela as Parcela,
    CA_Cheque.CPF as 'CPF TITULAR',
    CA_Cheque.Titular as 'NOME TITULAR',
	CA_Cheque.Numero as 'NUMERO CHEQUE'
from 
		RE_MensalidadeXAluno2 inner join RE_NegociacaoXAluno2 on RE_MensalidadeXAluno2.IDNegociacaoAluno = RE_NegociacaoXAluno2.IDNegociacaoAluno 
																 and RE_MensalidadeXAluno2.IDAluno = RE_NegociacaoXAluno2.IDAluno 		
                                                                 and RE_MensalidadeXAluno2.Removido=0 and RE_MensalidadeXAluno2.Tipo not in ('S','E')  and RE_NegociacaoXAluno2.Ativa<>0         
		inner join CA_Turma on CA_Turma.IDTurma=RE_NegociacaoXAluno2.IDTurma 
        inner join CA_Curso on CA_Curso.IDCurso=CA_Turma.IDCurso      
        -- inner join CA_GrupoCurso on CA_GrupoCurso.IDGrupoCurso=CA_Curso.IDGrupoCurso
        inner join CA_Unidade on CA_Curso.IDUnidade=CA_Unidade.IDUnidade 
        inner join CA_Empresa on CA_Empresa.IDEmpresa=CA_Unidade.IDEmpresa
        -- inner join CA_Instituto on CA_Curso.IDInstituto=CA_Instituto.IDInstituto 
        inner join CA_Periodo on RE_NegociacaoXAluno2.IDPeriodo=CA_Periodo.IDPeriodo  
        -- inner join CA_GrupoPeriodo on CA_GrupoPeriodo.IDGrupoPeriodo=CA_Periodo.IDGrupoPeriodo         
        inner join CA_Aluno on CA_Aluno.IDAluno=RE_MensalidadeXAluno2.IDAluno and CA_Aluno.IDAluno=RE_NegociacaoXAluno2.IDAluno
        inner join RE_MensalidadeAlunoXCheque on RE_MensalidadeAlunoXCheque.IDAluno=RE_MensalidadeXAluno2.IDAluno and RE_MensalidadeAlunoXCheque.IDMensalidadeAluno=RE_MensalidadeXAluno2.IDMensalidadeAluno
        inner join CA_Cheque on CA_Cheque.IDCheque=RE_MensalidadeAlunoXCheque.IDCheque 
        inner join RE_AlunoXCurso on RE_AlunoXCurso.IDAluno=CA_Aluno.IDAluno and CA_Curso.IDCurso=RE_AlunoXCurso.IDCurso  
where CA_Cheque.Situacao not in ('CP','NE') and Pago=0 
group by CA_Cheque.IDCheque