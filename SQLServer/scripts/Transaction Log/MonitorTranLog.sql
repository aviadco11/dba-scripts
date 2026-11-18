
-- invistigate Table CommandLog
SELECT TOP (1000) [ID]
      ,[DatabaseName]
      ,[Command]
      ,[CommandType]
      ,[StartTime]
      ,[EndTime]
      ,[ErrorNumber]
      ,[ErrorMessage]
                  , DateDiff(MINUTE, [StartTime],[EndTime])
  FROM [DBAUtilities].[dbo].[CommandLog]
  where [DatabaseName] = 'DBAUtilities' and CommandType like '%BACKUP%'
  order by [StartTime] desc



/*
Database Name - Name of the database for the log statistics displayed.
Log Size (MB) - Actual amount of space available for the log.
Log Space Used (%) - Percentage of the log file currently occupied with transaction log information.
Status - Status of the log file. Always 0.
*/
-- whis command will show you what going on with all log of DB's

if OBJECT_ID(N'tempdb..#Temp_LogSpace') IS NOT NULL
begin
drop table #Temp_LogSpace
end
go
create table #Temp_LogSpace
(
[DATABASE_NAME] nvarchar(100),
[LOGSIZE_MB] numeric(10,1),
[LOGSPACE_USED] numeric(10,1),
[LOGSTATUS] bit
)

insert #Temp_LogSpace([DATABASE_NAME], [LOGSIZE_MB], [LOGSPACE_USED], [LOGSTATUS]) 
EXEC('DBCC SQLPERF(LOGSPACE);')

select [DATABASE_NAME], [LOGSIZE_MB], [LOGSPACE_USED], [LOGSTATUS],[LOGSIZE_MB]-[LOGSPACE_USED] as [FreeMB] 
from #Temp_LogSpace 
where [DATABASE_NAME] not in ('master','msdb','tempdb','model')
order by [FreeMB]  desc






-- check on what the Translog wait 
select name, log_reuse_wait_desc
from sys.databases
where name like 'CosWebhooks'


/*
log_space_in_bytes_since_last_backup - The amount of space used since the last log backup
*/
USE CosWebhooks;
SELECT db_name() as DBName,total_log_size_in_bytes/1024/1024 [Total Log Size in MB],
used_log_space_in_bytes/1024/1024 AS [Used Log Size in MB],
convert(decimal(4,2),used_log_space_in_percent) [Used Log Space in %],
(total_log_size_in_bytes - used_log_space_in_bytes)/1024/1024 AS [Free log space in MB],
log_space_in_bytes_since_last_backup/1024/1024 [Log Since Last Log Backup MB]
FROM sys.dm_db_log_space_usage;

