
-- create extended events to monitor queries with warnings

CREATE EVENT SESSION [MonitorWarnings] ON SERVER 
ADD EVENT sqlserver.missing_column_statistics(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.plan_handle,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)
    WHERE ([sqlserver].[database_name]=N'AdventureWorks2012')),
ADD EVENT sqlserver.missing_join_predicate(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.plan_handle,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)
    WHERE ([sqlserver].[database_name]=N'AdventureWorks2012')),
ADD EVENT sqlserver.optimizer_timeout(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.plan_handle,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)
    WHERE ([sqlserver].[database_name]=N'AdventureWorks2012')),
ADD EVENT sqlserver.plan_affecting_convert(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.plan_handle,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)
    WHERE ([sqlserver].[database_name]=N'AdventureWorks2012')),
ADD EVENT sqlserver.unmatched_filtered_indexes(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.plan_handle,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)
    WHERE ([sqlserver].[database_name]=N'AdventureWorks2012'))
ADD TARGET package0.event_file(SET filename=N'c:\temp\MonitorWarnings')
WITH (STARTUP_STATE=ON)
GO

-- to see the execution plan paste here the plan handle from output
select query_plan from sys.dm_exec_query_plan (0x06005A004C00BD22401E0CDD7A02000001000000000000000000000000000000000000000000000000000000)

