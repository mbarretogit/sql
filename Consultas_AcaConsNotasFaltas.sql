--Consulta que popula a ConsNotasFaltas
select ly_aluno.aluno as aluno, ly_aluno.curso as curso, m.turma as turma,  
                 m.ano as ano, m.semestre as semestre,  
                 ly_aluno.nome_compl as NomeAluno, m.disciplina as disciplina,  
                 m.Sit_Matricula as sit_matricula, 
                 m.num_chamada as NumChamada, 
                 m.conceito_fim as conceito_fim,  
                 fac.faculdade as faculdade  
                 From ly_matricula m, ly_aluno, ly_turma tur,  
                      ly_disciplina d, ly_faculdade fac 
WHERE ly_aluno.aluno  =  m.aluno AND
     d.disciplina  =  m.Disciplina AND
     m.disciplina  =  tur.Disciplina AND
     m.turma  =  tur.Turma AND
     m.ano  =  tur.ano AND
     m.semestre  =  tur.semestre AND
     tur.faculdade  =  fac.faculdade 
    AND m.sit_matricula  = 'Matriculado'
-- AND fac.faculdade  = ''
--AND tur.ano  = 
--AND tur.Disciplina  = ''
--AND tur.semestre  = 
--AND tur.turma  = ''
--AND tur.num_func  =
 order by tur.turma, tur.ano, tur.disciplina, tur.semestre, ly_aluno.aluno 
 


--consulta que popula a DadosTurma 
select m.turma as turma,  
                 m.ano as ano, m.semestre as semestre,  
                 m.disciplina as disciplina,  
                 d.nome_compl as nomedisc,  
                 fac.faculdade as faculdade,  
                 doc.num_func as docente, doc.nome_compl as docentenome  
                 From ly_matricula m, ly_turma tur,  
                      ly_disciplina d, ly_faculdade fac, ly_docente doc  

     WHERE d.disciplina  =  m.Disciplina 
     AND m.disciplina  =  tur.Disciplina 
     AND m.turma  =  tur.Turma 
     AND m.ano  =  tur.ano 
     AND m.semestre  =  tur.semestre 
     AND tur.faculdade  =  fac.faculdade 
     AND tur.num_func  =  doc.num_func 
     -- AND fac.faculdade  = ''
--AND tur.ano  = 
--AND tur.Disciplina  = ''
--AND tur.semestre  = 
--AND tur.turma  = ''
--AND tur.num_func  =
order by tur.turma, tur.ano, tur.disciplina, tur.semestre