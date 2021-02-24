
SELECT A.UNIDADE_FISICA,C.CURSO,C.NOME AS NOME_CURSO, A.ALUNO, A.NOME_COMPL, A.SIT_ALUNO,ISNULL(VW.SIT_MATRICULA,'Sem-Matricula') AS SIT_MATRICULA, HCC.DT_ENCERRAMENTO, HCC.MOTIVO
FROM LYCEUM..LY_ALUNO A
JOIN LYCEUM..LY_CURSO C ON C.CURSO = A.CURSO
LEFT JOIN LYCEUM..LY_H_CURSOS_CONCL HCC ON HCC.ALUNO = A.ALUNO
LEFT JOIN LYCEUM..VW_MATRICULA_E_PRE_MATRICULA VW ON VW.ALUNO = A.ALUNO
WHERE A.ALUNO IN ('192042091','201030001','201220002','201040123','201040156','201040160','192210236','201210005','201040164','201030009','201210014','201030014','201060014','201220015','201070041','201050059','201040196','201040201','201030033','201040206','201290018','201050067','201050077','201040213','201050079','201070058','201210051','201050102','201030062','201080037','192050824','201050151','201290069','201060120','201030088','201040348','201030093','201040378','201070124','201220114','201040468','201210117','201050292','201220162','201060208','201050346','201030194','201050351','201050362','201040601','201290180','201050391')
