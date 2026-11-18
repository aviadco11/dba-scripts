
-- LongRunningQueries over than 1 sec
CREATE EVENT SESSION [LongRunningQueries] ON SERVER 
ADD EVENT sqlserver.sql_statement_completed(
    ACTION(sqlos.task_time,sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)
    WHERE ([sqlserver].[equal_i_sql_unicode_string]([sqlserver].[database_name],NN'<<database_name>>') AND [duration]>(1000000)))
ADD TARGET package0.event_file(SET filename=N'C:\temp\LongRunningQueries',max_file_size=(50))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO

/*
However, using a query is can be a much better way to analyze the query performance and can be more helpful to resolve the query
performance issues. To do this at first, we need to find the location of the XEL files and read this file with help of the fn_xe_file_target_read_file.
*/
SELECT s.name, CAST(t.target_data AS XML).value( '(EventFileTarget/File/@name)[1]', 'VARCHAR(MAX)' ) AS fileName
FROM sys.dm_xe_sessions AS s
        INNER JOIN
        sys.dm_xe_session_targets AS t
        ON s.address = t.event_session_address
WHERE t.target_name = 'event_file'
        AND name = 'LongRunningQueries';
SELECT CAST(event_data AS XML) AS event_data
FROM sys.fn_xe_file_target_read_file( 'C:\temp\LongRunningQueries_0_133401971102040000.xel', NULL, NULL, NULL );


-- The following query returns the TOP 10 queries that generate the most I/O workload on the database.
drop table if exists #EX_FilePath
drop table if exists #AnalyzeTable
SELECT s.name, CAST(t.target_data AS XML).value( '(EventFileTarget/File/@name)[1]', 'VARCHAR(MAX)' ) AS fileName
INTO #EX_FilePath
FROM sys.dm_xe_sessions AS s
        INNER JOIN
        sys.dm_xe_session_targets AS t
        ON s.address = t.event_session_address
WHERE t.target_name = 'event_file';
DECLARE @EventFileTarget AS NVARCHAR(500);
SELECT @EventFileTarget = fileName
FROM #EX_FilePath
WHERE name = 'LongRunningQueries';
SELECT * INTO #AnalyzeTable
FROM(SELECT n.value( '(@name)[1]', 'varchar(50)' ) AS event_name, 
n.value( '(@package)[1]', 'varchar(50)' ) AS package_name, 
n.value( '(@timestamp)[1]', 'datetime2' ) AS [utc_timestamp],
n.value( '(data[@name="physical_reads"]/value)[1]', 'bigint' ) AS physical_reads, 
n.value( '(data[@name="logical_reads"]/value)[1]', 'bigint' ) AS logical_reads, 
n.value( '(data[@name="writes"]/value)[1]', 'bigint' ) AS writes, 
n.value( '(data[@name="row_count"]/value)[1]', 'bigint' ) AS row_count, 
n.value( '(action[@name="client_app_name"]/value)[1]', 'nvarchar(max)' ) AS client_app_name,
n.value( '(data[@name="cpu_time"]/value)[1]', 'bigint' ) AS cpu_time, 
n.value( '(data[@name="duration"]/value)[1]', 'bigint' ) / 1000 AS duration_ms, 
n.value( '(data[@name="statement"]/value)[1]', 'nvarchar(max)' ) AS sql_text
        FROM
        (
            SELECT CAST(event_data AS XML) AS event_data
            FROM sys.fn_xe_file_target_read_file( @EventFileTarget, NULL, NULL, NULL )
        ) AS ed
        CROSS APPLY
        ed.event_data.nodes( 'event' ) AS q(n)) AS TMP_TBL

SELECT TOP 10 sql_text AS Sql_Statment ,COUNT(*) AS NumberOfQueries,
SUM(logical_reads) AS TotalLogicalReads FROM #AnalyzeTable
GROUP BY sql_text
ORDER BY 3 DESC

