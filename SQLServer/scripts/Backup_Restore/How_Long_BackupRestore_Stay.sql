
SELECT 
   session_id as SPID, command, a.text AS Query, start_time, percent_complete,
   dateadd(second,estimated_completion_time/1000, getdate()) as estimated_completion_time, datediff(HOUR,start_time,getdate()) as DurationHours
FROM sys.dm_exec_requests r 
   CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) a 
--WHERE r.command in ('BACKUP DATABASE','RESTORE DATABASE', 'DBCC', 'DbccFilesCompact','CREATE INDEX')


