/****** Object: Job [INTEGRACAO_CENTRO_CUSTO_PROTHEUS]   Script Date: 14/01/2021 20:54:51 ******/
USE [master];
GO
DECLARE @JobID BINARY(16)

EXECUTE msdb.dbo.sp_add_job @job_id = @JobID OUTPUT, @job_name = N'INTEGRACAO_CENTRO_CUSTO_PROTHEUS',
   @enabled = 0,
   @owner_login_name = N'sa',
   @description = N'ESTE JOB TEM A FINALIDDE DE INTEGRAR OS CENTROS DE CUSTO DO PROTHEUS',
   @category_name = N'[Uncategorized (Local)]',
   @notify_level_eventlog = 0,
   @notify_level_email = 0,
   @notify_level_netsend = 0,
   @notify_level_page = 0,
   @delete_level = 0;

EXECUTE msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 1, @step_name = N'INTEGRACAO_CENTRO_CUSTO_PROTHEUS',
   @command = N'exec INTEGRACAO_CENTRO_CUSTO_PROTHEUS',
   @database_name = N'LYCEUM',
   @subsystem = N'TSQL',
   @flags = 0,
   @retry_attempts = 0,
   @retry_interval = 0,
   @on_success_step_id = 0,
   @on_success_action = 1,
   @on_fail_step_id = 0,
   @on_fail_action = 2;
EXECUTE msdb.dbo.sp_update_job @job_id = @JobID, @start_step_id = 1;
EXECUTE msdb.dbo.sp_add_jobserver @job_id = @JobID, @server_name = N'(LOCAL)';
EXECUTE msdb.dbo.sp_add_jobschedule @job_id = @JobID,
        @name = N'INTEGRACAO_CENTRO_CUSTO_PROTHEUS',
        @enabled = 1,
        @freq_type = 8,
        @active_start_date = 20210114,
        @active_end_date = 99991231,
        @freq_interval = 127,
        @freq_subday_type = 4,
        @freq_subday_interval = 5,
        @freq_relative_interval = 1,
        @freq_recurrence_factor = 1,
        @active_start_time = 50000,
        @active_end_time = 235959;
GO

