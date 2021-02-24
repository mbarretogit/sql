use TOPDESK_PROD

Select   
mudanca.briefdescription as Breve_descricao,
mudanca.number as numero_mudanca,
pessoa.telefoon as Matricula,
al.sit_aluno as situcao_aluno,
pessoa.achternaam as Nome_solicitante,
c.curso,
c.nome Nome_curso,
mudanca.ref_caller_branch_name as unidade_solictante,
tipo_status.naam as Status,
mudanca.plannedfinaldate as Data_planejada_para_o_Final,
mudanca.plannedstartdate as Data_planejada_para_o_Incio,
isnull((Select top 1 'Sim'  from lyceum..ly_plano_pgto_periodo where resp like '%fies%' and ano='2021' and periodo ='1' AND ALUNO =AL.ALUNO),'')AS Fies,
isnull((Select top 1 'Sim'  from lyceum..ly_plano_pgto_periodo where resp ='03738654000105' and ano='2021' and periodo ='1' AND ALUNO =AL.ALUNO),'') AS Prouni
--mudanca.starteddate as data_inicio

--atividade.number as numero_atividade,
--atividade.briefdescription,
--usu.naam as criado_ficha,
--usu2.naam alterado_ficha,
--operador.achternaam as opeardor,
--grupo_operador.naam as grupo_operador
from change  mudanca
left join persoon pessoa on pessoa.unid = mudanca.persoonid
left join lyceum..ly_aluno al  on al.aluno COLLATE Latin1_General_CI_AI = mudanca.aanmeldertelefoon
left join lyceum..ly_curso c on c.curso = al.curso
left join wijzigingstatus tipo_status on tipo_status.unid = mudanca.statusid
/*left join changeactivity atividade  on atividade.unid = Atlog.kaartid
left join actiedoor  operador on  operador.unid = atividade.operatorid
left join actiedoor  grupo_operador on  grupo_operador.unid = atividade.operatorgroupid*/
where mudanca.briefdescription in('Solicitação Trancamento de Matrícula','Solicitação de Transferência - Saída','Solicitação Cancelamento de Matrícula')
--and mudanca.number='M2007-9729'
order by 10