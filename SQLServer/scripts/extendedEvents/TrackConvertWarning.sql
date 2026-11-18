
-- Track ConvertWarning

CREATE EVENT SESSION [ConvertWarning] ON SERVER 
ADD EVENT sqlserver.plan_affecting_convert(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.nt_username,sqlserver.plan_handle,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)
    WHERE ([sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[database_name],N'master')))
ADD TARGET package0.event_file(SET filename=N'c:\temp\ConvertWarning')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=ON)
GO


use CrReporting
select query_plan from sys.dm_exec_query_plan (0x05001900D52A424B10E760D9D202000001000000000000000000000000000000000000000000000000000000)



