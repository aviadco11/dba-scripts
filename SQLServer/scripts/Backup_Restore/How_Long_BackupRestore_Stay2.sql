
SELECT command,
            s.text,
            start_time,
            percent_complete, 
            CAST(((DATEDIFF(s,start_time,GETDATE()))/3600) AS VARCHAR) + ' hour(s), '
                  + CAST((DATEDIFF(s,start_time,GETDATE())%3600)/60 AS VARCHAR) + 'min, '
                  + CAST((DATEDIFF(s,start_time,GETDATE())%60) AS VARCHAR) + ' sec' AS running_time,
            CAST((estimated_completion_time/3600000) AS VARCHAR) + ' hour(s), '
                  + CAST((estimated_completion_time %3600000)/60000 AS VARCHAR) + 'min, '
                  + CAST((estimated_completion_time %60000)/1000 AS VARCHAR) + ' sec' AS est_time_to_go,
            DATEADD(SECOND,estimated_completion_time/1000, GETDATE()) AS est_completion_time 
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) s
WHERE r.command IN ('RESTORE DATABASE', 'BACKUP DATABASE', 'RESTORE LOG', 'BACKUP LOG')
UNION ALL

 
SELECT
r.command, NULL, NULL, 
  r.percent_complete,
      CAST(((DATEDIFF(s,start_time,GETDATE()))/3600) AS VARCHAR) + ' hour(s), '
                  + CAST((DATEDIFF(s,start_time,GETDATE())%3600)/60 AS VARCHAR) + 'min, '
                  + CAST((DATEDIFF(s,start_time,GETDATE())%60) AS VARCHAR) + ' sec' AS running_time,
CAST((estimated_completion_time/3600000) AS VARCHAR) + ' hour(s), '
                  + CAST((estimated_completion_time %3600000)/60000 AS VARCHAR) + 'min, '
                  + CAST((estimated_completion_time %60000)/1000 AS VARCHAR) + ' sec' AS est_time_to_go,
            DATEADD(SECOND,estimated_completion_time/1000, GETDATE()) AS est_completion_time 
FROM sys.dm_exec_requests r JOIN sys.dm_exec_sessions s
ON r.session_id = s.session_id
WHERE r.session_id <> @@SPID
AND s.is_user_process = 0
AND r.command LIKE 'VDI%'
AND wait_type ='ASYNC_IO_COMPLETION'

