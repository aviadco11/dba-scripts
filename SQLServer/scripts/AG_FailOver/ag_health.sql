USE [db repo]
GO

/****** Object:  Table [Monitoring].[AGSyncInfo]    Script Date: 11/17/2026 5:04:16 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Monitoring].[AGSyncInfo](
                [collection_time] [datetime] NULL,
                [pri_replica_server_name] [nvarchar](256) NULL,
                [sec_replica_server_name] [nvarchar](256) NULL,
                [ag_name] [sysname] NULL,
                [database_name] [sysname] NULL,
                [is_local] [bit] NULL,
                [is_primary_replica] [bit] NULL,
                [availability_mode_desc] [nvarchar](60) NULL,
                [synchronization_state_desc] [nvarchar](60) NULL,
                [is_commit_participant] [bit] NULL,
                [synchronization_health_desc] [nvarchar](60) NULL,
                [Sec_Behind] [int] NULL,
                [LSN_Behind] [numeric](26, 0) NULL,
                [recovery_lsn] [numeric](25, 0) NULL,
                [truncation_lsn] [numeric](25, 0) NULL,
                [last_sent_lsn] [numeric](25, 0) NULL,
                [last_sent_time] [datetime] NULL,
                [last_received_lsn] [numeric](25, 0) NULL,
                [last_received_time] [datetime] NULL,
                [last_hardened_lsn] [numeric](25, 0) NULL,
                [last_hardened_time] [datetime] NULL,
                [last_redone_lsn] [numeric](25, 0) NULL,
                [last_redone_time] [datetime] NULL,
                [log_send_queue_size] [bigint] NULL,
                [log_send_rate] [bigint] NULL,
                [redo_rate] [bigint] NULL,
                [redo_queue_size] [bigint] NULL,
                [filestream_send_rate] [bigint] NULL,
                [end_of_log_lsn] [numeric](25, 0) NULL,
                [last_commit_lsn] [numeric](25, 0) NULL,
                [last_commit_time] [datetime] NULL
) ON [PRIMARY]
GO





USE [DBAUtilities]
GO
/****** Object:  StoredProcedure [dbo].[AlertOnAGHealth]    Script Date: 11/17/2026 5:04:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec [dbo].[AlertOnAGHealth] @pEmail='xxx@gmail.com'


ALTER    procedure [dbo].[AlertOnAGHealth](@pMailProfile varchar(64) = 'xxx EXCH',
                                                                                                                                                                                                  @pEmail varchar(1000) = NULL
)
as

/*========================================================================================
                           xxx
==========================================================================================
Proc Name   : [dbo].[AlertOnAGHealth]
Author      : xxx
Create Date : 2022-05-31
=================================================================================================
Description : [dbo].[AlertOnAGHealth] procedure collect AG Statistics and alert on AG unhealthy
==================================================================================================
Returns     : Email
==================================================================================================
Revisions   :
Author          Date                                           Description
=================================================================================================
*/

begin


SET NOCOUNT ON

declare @vInstance varchar(64), @pointintime varchar(18), @HealthyStats bit;

print concat('*** ',RIGHT(CONVERT(VARCHAR(26), GETDATE(), 109),14), ': Start Check AG Health.')

set @vInstance = @@SERVERNAME;
set @pointintime = convert(varchar, getdate(), 111) + ' -' + CONVERT(varchar(5),getdate(),108) 
DECLARE @AGs varchar(300) = '';


----------------------------
--DECLARE VARIABLES FOR HTML
----------------------------
DECLARE @Style NVARCHAR(MAX)= '';
declare @tableHTML NVARCHAR(MAX)= '';

----------------------------------
--Collect the data to notify with 
----------------------------------

                DECLARE @s nVARCHAR(MAX)
                DECLARE @r INT = 1;
                
                

                If OBJECT_ID('tempdb..#AGStats') IS NOT NULL
                                DROP TABLE #AGStats
                                
                CREATE TABLE #AGStats
                (
                [collection_time] [datetime] NULL,
                [pri_replica_server_name] [nvarchar](256) NULL,
                [sec_replica_server_name] [nvarchar](256) NULL,
                [ag_name] [sysname] NULL,
                [database_name] [sysname] NULL,
                [is_local] [bit] NULL,
                [is_primary_replica] [bit] NULL,
                [availability_mode_desc] [nvarchar](60) NULL,
                [synchronization_state_desc] [nvarchar](60) NULL,
                [is_commit_participant] [bit] NULL,
                [synchronization_health_desc] [nvarchar](60) NULL,
                [Sec_Behind] [int] NULL,
                [LSN_Behind] [numeric](26, 0) NULL,
                [recovery_lsn] [numeric](25, 0) NULL,
                [truncation_lsn] [numeric](25, 0) NULL,
                [last_sent_lsn] [numeric](25, 0) NULL,
                [last_sent_time] [datetime] NULL,
                [last_received_lsn] [numeric](25, 0) NULL,
                [last_received_time] [datetime] NULL,
                [last_hardened_lsn] [numeric](25, 0) NULL,
                [last_hardened_time] [datetime] NULL,
                [last_redone_lsn] [numeric](25, 0) NULL,
                [last_redone_time] [datetime] NULL,
                [log_send_queue_size] [bigint] NULL,
                [log_send_rate] [bigint] NULL,
                [redo_rate] [bigint] NULL,
                [redo_queue_size] [bigint] NULL,
                [filestream_send_rate] [bigint] NULL,
                [end_of_log_lsn] [numeric](25, 0) NULL,
                [last_commit_lsn] [numeric](25, 0) NULL,
                [last_commit_time] [datetime] NULL
                )

                insert into #AGStats
                exec DBAUtilities.dbo.GetAGSyncInfo
                

                insert into DBAUtilities.Monitoring.AGSyncInfo
                select 
       [collection_time]
                  ,[pri_replica_server_name]
      ,[sec_replica_server_name]
      ,[ag_name]
      ,[database_name]
      ,[is_local]
      ,[is_primary_replica]
      ,[availability_mode_desc]
      ,[synchronization_state_desc]
      ,[is_commit_participant]
      ,[synchronization_health_desc]
      ,[Sec_Behind]
      ,[LSN_Behind]
      ,[recovery_lsn]
      ,[truncation_lsn]
      ,[last_sent_lsn]
      ,[last_sent_time]
      ,[last_received_lsn]
      ,[last_received_time]
      ,[last_hardened_lsn]
      ,[last_hardened_time]
      ,[last_redone_lsn]
      ,[last_redone_time]
      ,[log_send_queue_size]
      ,[log_send_rate]
      ,[redo_rate]
      ,[redo_queue_size]
      ,[filestream_send_rate]
      ,[end_of_log_lsn]
      ,[last_commit_lsn]
      ,[last_commit_time]
                from #AGStats

   WHILE @r > 0
   BEGIN

   BEGIN TRANSACTION;

                                DELETE TOP (10000) 
                                from DBAUtilities.Monitoring.AGSyncInfo 
                                where [collection_time] < dateadd(MONTH,-2,getdate())
                                SET @r = @@ROWCOUNT;

    COMMIT TRANSACTION;
                end

------------
--DEFINE CSS
------------
set @Style += +N'<style type="text/css">' + N'.tg  {border-collapse:collapse;border-spacing:0;border-color:#aaa;}'
    + N'.tg td{font-family:Arial, sans-serif;font-size:12px;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;border-color:#aaa;color:#333;background-color:#ffffff;}'
    + N'.tg th{font-family:Arial, sans-serif;font-size:13px;font-weight:normal;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;border-color:#aaa;color:#fff;background-color:#03A0EF;}'
    + N'.tg .tg-9ajh{white-space: nowrap;font-weight:bold;background-color:#F1F1F2}' + N'.tg .tg-hgcj{font-weight:bold;text-align:center}'
                + N'.tg .tg-8ajh{white-space: nowrap;font-weight:bold;background-color:#FF0000}' + N'.tg .tg-hgcj{font-weight:bold;text-align:center}'
    + N'</style>';

                set @tableHTML = concat(@Style,' ',@tableHTML,'<H4>','@NOC Team,</H4>')
                set @tableHTML = concat(@Style,' ',@tableHTML,'<H4>','please contact the CRB_DBA On. call DBA !!!</H4>')

                + N'<table class="tg">' --DEFINE TABLE
---set @tableHTML += @Style + @tableHTML
                + N'<H4>List of Availability Groups in an Unhealthy state on Instance: '+@vInstance + '</H4>' 
                + N'<table class="tg">' --DEFINE TABLE
/*
Define Column Headers and Column Span for each Header Column
*/
                + N'<tr>' 
    + N'<th class="tg-hgcj" colspan="8">AG Details</th>' 
                --+ N'<th class="tg-hgcj" colspan="3">Service Details</th>'
                + N'</tr>' 
/*
Define Column Sub-Headers
*/
                + N'<tr>'
                + N'<td class="tg-9ajh">Collection Time</td>'
    + N'<td class="tg-9ajh">AG Name</td>'
                + N'<td class="tg-9ajh">Primary</td>'
                + N'<td class="tg-9ajh">Secondary</td>'
                + N'<td class="tg-8ajh">DB</td>'
                + N'<td class="tg-9ajh">AVAILABILITY MODE</td>'
                + N'<td class="tg-8ajh">SYNC HEALTH</td>'
                + N'<td class="tg-8ajh">SYNC STATE</td></tr>'
                                                                                                                
                                                                
/*
Define data for table and cast to xml
*/
    + cast(( select td = isnull(cast(convert(datetime, Collection_Time) as varchar(30)),cast(convert(datetime,sysdatetimeoffset()) as varchar(30))),
                                                                                '',
                    td = isnull(ag_name,'Unknown') ,
                                                                                '',
                                                                                td = isnull(pri_replica_server_name,'Unknown') ,
                                                                                '',
                                                                                td = isnull(sec_replica_server_name,'Unknown') ,
                                                                                '',
                                                                                td = isnull([database_name],'Unknown') ,
                                                                                '',
                                                                                td = isnull(availability_mode_desc,'Unknown') ,
                                                                                '',
                                                                                td = isnull(synchronization_health_desc,'Unknown') ,
                                                                                '',
                                                                                td = isnull(synchronization_state_desc,'Unknown') ,
                                                                                ''                                                              
           from  #AGStats  
                                                  where [is_primary_replica] = 1 and synchronization_health_desc not like 'HEALTHY' and [ag_name] not like '%test%'
                                                  or synchronization_state_desc not in ('SYNCHRONIZED','SYNCHRONIZING') and [ag_name] not like '%test%'                                  
                                                  or [is_commit_participant] = 0 and synchronization_health_desc like 'PARTIALLY_HEALTHY' and [ag_name] not like '%test%'
           for
                                                xml path('tr') ,
                 type
           ) as nvarchar(max)) + N'</table>';

-----------------------------------------------------------------------------------------
-- Send an html formatted e-mail to notify of restart if there are any offending Queries
-----------------------------------------------------------------------------------------



declare @OffenderCnt int
select @OffenderCnt = count(0) from #AGStats                                    
                                                                                                                                where [ag_name] not like '%test%' and
                                                                                                                                synchronization_health_desc not like 'HEALTHY' 
                                                                                                                                or synchronization_state_desc not in ('SYNCHRONIZED','SYNCHRONIZING') and [ag_name] not like '%test%'
                                                                                                                                
select @OffenderCnt as Offender_Record_Count
print concat('*** Found ', @OffenderCnt, ' Databases in Availblity Group in an UNHEALTHY/PARTIALLY_HEALTHY state. ')

if (NOT EXISTS(select 1 from [DBAUtilities].[dbo].[AGHealthyStats] where issue = 'Healthy'))
begin
                insert into  [DBAUtilities].[dbo].[AGHealthyStats] 
                SELECT 0,'Healthy', name AS [AG]
                FROM sys.availability_groups
end

if @OffenderCnt >0 and @pEmail is not null
                begin   
                                
                                UPDATE aa
                                SET aa.HealthyStats = 1, aa.AG = bb.ag_name
                                FROM [DBAUtilities].[dbo].[AGHealthyStats] aa
                                JOIN (
                                                SELECT distinct ag_name 
                                                FROM #AGStats
                                                WHERE 
                                                --role_desc = 'PRIMARY' 
                                                (synchronization_health_desc NOT LIKE 'HEALTHY' and [ag_name] not like '%test%'
                                                OR synchronization_state_desc NOT IN ('SYNCHRONIZED', 'SYNCHRONIZING') and [ag_name] not like '%test%'
                                                or [is_commit_participant] = 0 and synchronization_health_desc like 'PARTIALLY_HEALTHY' and [ag_name] not like '%test%')
                                ) bb ON aa.AG = bb.ag_name
                                WHERE aa.issue = 'Healthy';

                                SELECT @AGs = STRING_AGG(AG, ',')
                                FROM [DBAUtilities].[dbo].[AGHealthyStats]
                                WHERE HealthyStats = 1 AND issue = 'Healthy';

                                declare @vSubject varchar(100) = 'List of Availability Groups in an UNHEALTHY/PARTIALLY_HEALTHY state:  '+@vInstance + ' _ ' +@AGs+' __ ' + @pointintime;

                                exec msdb.dbo.sp_send_dbmail
                                @profile_name = @pMailProfile,
                                @recipients = @pEmail,
                                @subject = @vSubject,
                                @body = @tableHTML,
                                @body_format = 'HTML',
                                @importance = 'HIGH';
                                print concat('*** ','Mail was sent !')
                                RAISERROR('*** Error: Found Databases in Availblity Group in an UNHEALTHY/PARTIALLY_HEALTHY state', 16, 1);
                end
                else 
                begin

                                SET @HealthyStats = (SELECT TOP 1 HealthyStats 
                     FROM [DBAUtilities].[dbo].[AGHealthyStats] 
                     WHERE issue = 'Healthy' 
                     ORDER BY HealthyStats DESC);

                                
                                SELECT @AGs = STRING_AGG(AG, ',')
                                FROM [DBAUtilities].[dbo].[AGHealthyStats]
                                WHERE HealthyStats = 1 AND issue = 'Healthy';
                                
                                set @vSubject = 'Availability Groups have returned to a healthy state on Instance: '+@vInstance + ' __ ' +@AGs + ' !!!'
                                if (@HealthyStats = 1)
                                begin
                                                update [DBAUtilities].[dbo].[AGHealthyStats] set HealthyStats=0 where issue = 'Healthy'
                                                exec msdb.dbo.sp_send_dbmail
                                                                @profile_name = @pMailProfile,
                                                                @recipients = @pEmail,
                                                                @subject = @vSubject,
                                                                @body = NULL,
                                                                @body_format = 'HTML',
                                                                @importance = 'HIGH';
                                                print concat('*** ','Availability Groups have returned to a healthy state !')
                                                print concat('*** ','Mail was sent !')
                                end
                end
set nocount off
end;




USE [DBAUtilities]
GO
/****** Object:  StoredProcedure [dbo].[AlertOnAGLatency]    Script Date: 11/17/2026 5:04:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--exec [dbo].[AlertOnAGLatency] @pEmail='aviadcohen@crossriver.com',@ThresholdLatencyAGSec=40
-- exec [DBAUtilities].[dbo].[AlertOnAGLatency] @pEmail='xxxx@fff.com;noc@fff.com', @ThresholdLatencyAGSyncSec=300, @ThresholdLatencyAGASyncSec=600

ALTER      procedure [dbo].[AlertOnAGLatency](@pMailProfile varchar(64) = 'xxx EXCH',
                                                                                                                                                                                                  @ThresholdLatencyAGSyncSec int = 300,
                                                                                                                                                                                                  @ThresholdLatencyAGASyncSec int = 600,
                                                                                                                                                                                                  @pEmail varchar(1000) = NULL
)
as

/*========================================================================================
                         xxx
==========================================================================================
Proc Name   : [dbo].[AlertOnAGLatency]
Author      : xxx
Create Date : 2023-02-22
=================================================================================================
Description : [dbo].[AlertOnAGLatency] procedure collect AG Statistics and alert on AG unhealthy
==================================================================================================
Returns     : Email
==================================================================================================
Revisions   :
Author          Date                                           Description
=================================================================================================
*/

begin


SET NOCOUNT ON


declare @vInstance varchar(64), @pointintime varchar(18), @HealthyStats bit;;

set @vInstance = @@SERVERNAME;
set @pointintime = convert(varchar, getdate(), 111) + ' -' + CONVERT(varchar(5),getdate(),108) 

declare @vSubject varchar(100) = 'List of Availability Groups with High Latency in the Last Hour:  '+@vInstance + ' _ ' + @pointintime;

----------------------------
--DECLARE VARIABLES FOR HTML
----------------------------
DECLARE @Style NVARCHAR(MAX)= '';
declare @tableHTML NVARCHAR(MAX)= '';

----------------------------------
--Collect the data to notify with 
----------------------------------

                DECLARE @s nVARCHAR(MAX)
                DECLARE @r INT;
                
                

                If OBJECT_ID('tempdb..#AGStats') IS NOT NULL
                                DROP TABLE #AGLatencyStats
                                
                CREATE TABLE #AGLatencyStats
                (
                                ag_name varchar(50),
                                pri_replica_server_name varchar(50),
                                sec_replica_server_name varchar(50),
                                [database_name] varchar(50),
                                availability_mode_desc varchar(50),
                                synchronization_health varchar(50),
                                synchronization_state varchar(50),
                                lag_in_sec int,
                                log_send_queue_size_mb int
                )

                insert into #AGLatencyStats
                select 
                                ag_name,
                                pri_replica_server_name,
                                sec_replica_server_name,
                                [database_name],
                                availability_mode_desc,
                                [synchronization_health_desc],
                                synchronization_state_desc,
                                AVG([Sec_Behind]) as avg_latency_sec,
                                AVG(log_send_queue_size) as avg_queue_size_mb
                from [DBAUtilities].[Monitoring].[AGSyncInfo]
                where collection_time > DATEADD(HOUR,-1,getdate()) and ISNULL([Sec_Behind],0)>0 and ISNULL(log_send_queue_size,0)>0
                group by ag_name,pri_replica_server_name,sec_replica_server_name,[database_name],availability_mode_desc,
                                synchronization_health_desc,           synchronization_state_desc
                having AVG([Sec_Behind]) > @ThresholdLatencyAGSyncSec and availability_mode_desc = 'SYNCHRONOUS_COMMIT' 
                                or AVG([Sec_Behind]) > @ThresholdLatencyAGASyncSec and availability_mode_desc = 'ASYNCHRONOUS_COMMIT'
------------
--DEFINE CSS
------------
set @Style += +N'<style type="text/css">' + N'.tg  {border-collapse:collapse;border-spacing:0;border-color:#aaa;}'
    + N'.tg td{font-family:Arial, sans-serif;font-size:12px;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;border-color:#aaa;color:#333;background-color:#ffffff;}'
    + N'.tg th{font-family:Arial, sans-serif;font-size:13px;font-weight:normal;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;border-color:#aaa;color:#fff;background-color:#03A0EF;}'
    + N'.tg .tg-9ajh{white-space: nowrap;font-weight:bold;background-color:#F1F1F2}' + N'.tg .tg-hgcj{font-weight:bold;text-align:center}'
                + N'.tg .tg-8ajh{white-space: nowrap;font-weight:bold;background-color:#FF0000}' + N'.tg .tg-hgcj{font-weight:bold;text-align:center}'
    + N'</style>';

                set @tableHTML = concat(@Style,' ',@tableHTML,'<H4>','@NOC Team,</H4>')
                set @tableHTML = concat(@Style,' ',@tableHTML,'<H4>','The next latency check for AG will take place in one hour. Please continue to follow !!!</H4>')

                + N'<table class="tg">' --DEFINE TABLE
---set @tableHTML += @Style + @tableHTML
                + N'<H4>List of DataBases in Availblity Group With High Latency in the Last Hour: '+@vInstance + '</H4>' 
                + N'<table class="tg">' --DEFINE TABLE
/*
Define Column Headers and Column Span for each Header Column
*/
                + N'<tr>' 
    + N'<th class="tg-hgcj" colspan="9">AG Details</th>' 
                --+ N'<th class="tg-hgcj" colspan="3">Service Details</th>'
                + N'</tr>' 
/*
Define Column Sub-Headers
*/
                + N'<tr>'
    + N'<td class="tg-9ajh">AG Name</td>'
                + N'<td class="tg-9ajh">Primary</td>'
                + N'<td class="tg-9ajh">Secondary</td>'
                + N'<td class="tg-8ajh">DB</td>'
                + N'<td class="tg-9ajh">AVAILABILITY MODE</td>'
                + N'<td class="tg-8ajh">SYNC HEALTH</td>'
                + N'<td class="tg-9ajh">SYNC STATE</td>'
                + N'<td class="tg-9ajh">QUEUE SIZE MB</td>'
                + N'<td class="tg-8ajh">SEC BEHIND</td></tr>'
                                                                                                
                                                                                
/*
Define data for table and cast to xml
*/
    + cast(( select td = isnull(ag_name,'Unknown') ,
                                                                                '',
                                                                                td = isnull(pri_replica_server_name,'Unknown') ,
                                                                                '',
                                                                                td = isnull(sec_replica_server_name,'Unknown') ,
                                                                                '',
                                                                                td = isnull([database_name],'Unknown') ,
                                                                                '',
                                                                                td = isnull(availability_mode_desc,'Unknown') ,
                                                                                '',
                                                                                td = isnull(synchronization_health,'Unknown') ,
                                                                                '',
                                                                                td = isnull(synchronization_state,'Unknown') ,
                                                                                '',
                                                                                td = log_send_queue_size_mb,
                                                                                '',
                                                                                td = lag_in_sec,
                                                                                ''
           from  #AGLatencyStats  
           for
                                                xml path('tr') ,
                 type
           ) as nvarchar(max)) + N'</table>';

-----------------------------------------------------------------------------------------
-- Send an html formatted e-mail to notify of restart if there are any offending Queries
-----------------------------------------------------------------------------------------

declare @OffenderCnt int
select @OffenderCnt = count(0) from #AGLatencyStats                                  

select @OffenderCnt as Offender_Record_Count
print concat('*** Found ', @OffenderCnt, ' Databases in Availblity Group With High Average Latency in the Last Hour. ')

if (NOT EXISTS(select 1 from [DBAUtilities].[dbo].[AGHealthyStats] where issue = 'Latency'))
begin
                insert into [DBAUtilities].[dbo].[AGHealthyStats] ([issue], [HealthyStats]) values ('Latency', 0)
end

if @OffenderCnt >0 and @pEmail is not null
                begin
                                update [DBAUtilities].[dbo].[AGHealthyStats] set HealthyStats=1 where issue = 'Latency'
                
                                exec msdb.dbo.sp_send_dbmail
                                                @profile_name = @pMailProfile,
                                                @recipients = @pEmail,
                                                @subject = @vSubject,
                                                @body = @tableHTML,
                                                @body_format = 'HTML',
                                                @importance = 'HIGH';
                                                print concat('*** ','Mail was sent !')
                                                print concat('*** ',@tableHTML )
                                                RAISERROR('*** Error: High Latency Found in one or more Databases in Availblity Group', 16, 1);
                end
                else begin
                                                select @HealthyStats = HealthyStats from [DBAUtilities].[dbo].[AGHealthyStats] where issue = 'Latency'
                                                set @vSubject = 'The Availblity Groups have returned to be in sync without latency'
                                                if (@HealthyStats = 1)
                                                begin
                                                                update [DBAUtilities].[dbo].[AGHealthyStats] set HealthyStats=0 where issue = 'Latency' 
                                                                exec msdb.dbo.sp_send_dbmail
                                                                @profile_name = @pMailProfile,
                                                                @recipients = @pEmail,
                                                                @subject = @vSubject,
                                                                @body = @tableHTML,
                                                                @body_format = 'HTML',
                                                                @importance = 'HIGH';
                                                                print concat('*** ','No Latency Found in Availblity Group !')
                                                                print concat('*** ','Availblity Group have returned to be sync without latency')
                                                                print concat('*** ','Mail was sent !')
                                                end
                                end

set nocount off
end;






USE [DBAUtilities]
GO
/****** Object:  StoredProcedure [dbo].[AlertOnLongQuery]    Script Date: 11/17/2026 5:05:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







--exec AlertOnLongQuery

ALTER    procedure [dbo].[AlertOnLongQuery](@pMailProfile varchar(64) = 'CRB EXCH'
                                                                                                                                                                                                ,@pEmail varchar(1000) = NULL
)
as

/*========================================================================================
                            xx
==========================================================================================
Proc Name   : [dbo].[[AlertOnLongQuery]]
Author      : crb\xxxx
Create Date : 2022-05-31
==========================================================================================
Description : [dbo].[AlertOnLongQuery] procedure collect Query that runs too long (over 5 minutes)
***Requires reference table to filter logins on dbrewpo.Monitoring.OmittedLogins
==========================================================================================
Returns     : Email
==========================================================================================
Revisions   :
Author          Date                                           Description
========================================================================================
*/

begin


SET NOCOUNT ON

declare @vInstance varchar(64), @pointintime varchar(18);

set @vInstance = @@SERVERNAME;
set @pointintime = convert(varchar, getdate(), 111) + ' -' + CONVERT(varchar(5),getdate(),108) 

declare @vSubject varchar(100) = 'Long Running Queries on:  '+@vInstance + ' _ ' + @pointintime;

----------------------------
--DECLARE VARIABLES FOR HTML
----------------------------
DECLARE @Style NVARCHAR(MAX)= '';
declare @tableHTML NVARCHAR(MAX)= '';

----------------------------------
--Collect the data to notify with 
----------------------------------

                DECLARE @s nVARCHAR(MAX)
                DECLARE @r INT;
    SET @r = 1;
                
                EXEC sp_WhoIsActive  @output_column_list = '[dd hh:mm:ss.mss],[session_id],[login_name],[host_name],[database_name],[collection_time],[start_time],[sql_text],[blocking_session_id],[program_name],[wait_info],[CPU],[reads],[writes],[physical_reads]',
                @return_schema = 1,
                @schema = @s OUTPUT;
                
                SET @s = REPLACE(@s, '<table_name>', 'tempdb.dbo.WHO_IS_Over5')
                IF OBJECT_ID('tempdb.dbo.WHO_IS_Over5', 'U') IS NOT NULL
                begin
                   print 'tempdb.dbo.WHO_IS_Over5 will be Re-Created.';
                   drop table tempdb.dbo.WHO_IS_Over5; 
                end;
                else print 'tempdb.dbo.WHO_IS_Over5 will be created.';

                EXEC(@s);

                exec DBAUtilities.dbo.sp_WhoIsActive  @output_column_list = '[dd hh:mm:ss.mss],[session_id],[login_name],[host_name],[database_name],[collection_time],[start_time],[sql_text],[blocking_session_id],[program_name],[wait_info],[CPU],[reads],[writes],[physical_reads]',
                @destination_table = 'tempdb.dbo.WHO_IS_Over5';

                ---select @s
                
                delete from tempdb.dbo.WHO_IS_Over5 where login_name in (select Login_Name from DBAUtilities.[Monitoring].[OmittedLogins]); 

                --- update fix below as [dd hh:mm:ss.mss] sometimes outputs 16 chars instead of 15, as 15 is the standard( can't figure out why yet  ( padbprod01) )
                update tempdb.dbo.WHO_IS_Over5 set [dd hh:mm:ss.mss] = right([dd hh:mm:ss.mss] ,15)  
                                where len([dd hh:mm:ss.mss]) > 15;
                
                insert into DBAUtilities.Monitoring.WhoIsActiveOver5
                select 
                [dd hh:mm:ss.mss],
                [session_id] ,
                [login_name],
                [host_name],
                [database_name] ,
                [collection_time] ,
                [start_time],
                [sql_text] ,
                [blocking_session_id],
                [program_name],
                [wait_info],
                TRIM([CPU]),
                TRIM([reads]),
                TRIM([writes]),
                TRIM([physical_reads])
                from tempdb.dbo.WHO_IS_Over5  where [dd hh:mm:ss.mss] > '00 00:05:00.000' 

-- delete history rows old more than 6 Months from table
   WHILE @r > 0
   BEGIN

   BEGIN TRANSACTION;

                                DELETE TOP (10000) 
                                from DBAUtilities.Monitoring.WhoIsActiveOver5 
                                where [collection_time] < dateadd(MONTH,-3,getdate())
                                SET @r = @@ROWCOUNT;

    COMMIT TRANSACTION;
                end

------------
--DEFINE CSS
------------
set @Style += +N'<style type="text/css">' + N'.tg  {border-collapse:collapse;border-spacing:0;border-color:#aaa;}'
    + N'.tg td{font-family:Arial, sans-serif;font-size:12px;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;border-color:#aaa;color:#333;background-color:#ffffff;}'
    + N'.tg th{font-family:Arial, sans-serif;font-size:13px;font-weight:normal;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;border-color:#aaa;color:#fff;background-color:#03A0EF;}'
    + N'.tg .tg-9ajh{white-space: nowrap;font-weight:bold;background-color:#F1F1F2}' + N'.tg .tg-hgcj{font-weight:bold;text-align:center}'
                + N'.tg .tg-8ajh{white-space: nowrap;font-weight:bold;background-color:#FFFF00}' + N'.tg .tg-hgcj{font-weight:bold;text-align:center}'
    + N'</style>';

                set @tableHTML = concat(@Style,' ',@tableHTML,'<H4>','@NOC Team,</H4>')
                                set @tableHTML = concat(@Style,' ',@tableHTML,'<H4>','Please see below long running queries by highlighted columns (DD HH:MM:SS.MSS , Login Name). 
                                These are queries running on '+@vInstance + ' that exceed the allotted runtime threshold of 15 minutes. 
                                Please reachout to the offending user to stop their query, and include the CRB_DBA Oncall DBA to kill it if there is no response from the end user after 30 minutes.</H4>')

                + N'<table class="tg">' --DEFINE TABLE
---set @tableHTML += @Style + @tableHTML
                + N'<H4>Long Running Queries that need to be addressed on: '+@vInstance + '</H4>' 
                + N'<table class="tg">' --DEFINE TABLE
/*
Define Column Headers and Column Span for each Header Column
*/
                + N'<tr>' 
    + N'<th class="tg-hgcj" colspan="7">Query Details</th>' 
                --+ N'<th class="tg-hgcj" colspan="3">Service Details</th>'
                + N'</tr>' 
/*
Define Column Sub-Headers
*/
                + N'<tr>'
                + N'<td class="tg-8ajh">DD HH:MM:SS.MSS</td>'
    + N'<td class="tg-9ajh">SPID</td>'
                + N'<td class="tg-8ajh">Login Name</td>'
                + N'<td class="tg-9ajh">Host Name</td>'
                + N'<td class="tg-9ajh">DB Name</td>'
                + N'<td class="tg-9ajh">Collection Time</td>'
                + N'<td class="tg-9ajh">SQL Text (*First 400 Chars)</td></tr>'
/*
Define data for table and cast to xml
*/
    + cast(( select td = isnull([dd hh:mm:ss.mss],'Unknown') ,
                                                                                '',
                    td = isnull(Session_id,'Unknown') ,
                                                                                '',
                    td = isnull(Login_Name,'Unknown') ,
                                                                                '',
                                                                                td = case when host_name = '' then 'Unknown' else  isnull(Host_Name,'Unknown') end,
                                                                                '',
                                                                                td = isnull(database_name,'Unknown'),
                                                                                '',
                                                                                td = isnull(cast(convert(datetime, Collection_Time) as varchar(30)),cast(convert(datetime,sysdatetimeoffset()) as varchar(30))),
                                                                                '',
                                                                                td = left(isnull(cast([sql_text] as nvarchar(max)),'Unknown'),400),
                                                                                ''
           from  tempdb.dbo.WHO_IS_Over5  
                                                 where [dd hh:mm:ss.mss] > '00 00:15:00.000' 
                                                 order by [dd hh:mm:ss.mss] desc
           for
                                                xml path('tr') ,
                 type
           ) as nvarchar(max)) + N'</table>';

-----------------------------------------------------------------------------------------
-- Send an html formatted e-mail to notify of restart if there are any offending Queries
-----------------------------------------------------------------------------------------

declare @OffenderCnt int
select @OffenderCnt = count(0) from tempdb.dbo.WHO_IS_Over5  where  [dd hh:mm:ss.mss] > '00 00:15:00.000' 

select @OffenderCnt as Offender_Record_Count

if @OffenderCnt >0 and @pEmail is not null
                begin
                exec msdb.dbo.sp_send_dbmail
       @profile_name = @pMailProfile,
       @recipients = @pEmail,
       @subject = @vSubject,
       @body = @tableHTML,
       @body_format = 'HTML',
                   @importance = 'HIGH';
                end

set nocount off
end;





USE [DBAUtilities]
GO
/****** Object:  StoredProcedure [dbo].[AlertOnLargeVersionStore]    Script Date: 11/17/2026 5:05:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




--exec [dbo].[AlertOnLargeVersionStore] @pEmail='xxxx@crossriver.com',@ThresholdVersionStoreSizeMB=10, @ThresholdDurationVersionStoreSizeMin=-60

-- exec [DBAUtilities].[dbo].[AlertOnLargeVersionStore] @pEmail='crb_dba@crossriver.com;noc@crossriver.com', @ThresholdLatencyAGSyncSec=300, @ThresholdLatencyAGASyncSec=600

ALTER    procedure [dbo].[AlertOnLargeVersionStore](@pMailProfile varchar(64) = 'xxx EXCH',
                                                                                                                                                                                                  @ThresholdVersionStoreSizeMB int = 300000,
                                                                                                                                                                                                  @ThresholdDurationVersionStoreSizeMin int = -60,
                                                                                                                                                                                                  @pEmail varchar(1000) = NULL
)
as

/*========================================================================================
                            
==========================================================================================
Proc Name   : [dbo].[AlertOnLargeVersionStore]
Author      : xxx
Create Date : 2024-12-03
=================================================================================================
Description : [dbo].[AlertOnLargeVersionStore] procedure alert on large version store size
==================================================================================================
Returns     : Email
==================================================================================================
Revisions   :
Author          Date                                           Description
=================================================================================================
*/

begin


SET NOCOUNT ON


declare @vInstance varchar(64), @pointintime varchar(18), @HealthyStats bit;

set @vInstance = @@SERVERNAME;
set @pointintime = convert(varchar, getdate(), 111) + ' -' + CONVERT(varchar(5),getdate(),108) 

declare @vSubject varchar(100) = 'Alert: Large Tempdb Version Store Size in the Last Hour:  '+@vInstance + ' _ ' + @pointintime;

----------------------------
--DECLARE VARIABLES FOR HTML
----------------------------
declare @tableHTML NVARCHAR(MAX)= '';

----------------------------------
--Collect the data to notify with 
----------------------------------

                DECLARE @s nVARCHAR(MAX)
                DECLARE @r INT;
                
                
                set @tableHTML = concat('<H3>','Alert : Large Version Store Size Found ( >above ',@ThresholdVersionStoreSizeMB, 'MB) on tempdb !! Please Follow Up</H3>')
                
                                                                                


-----------------------------------------------------------------------------------------
-- Send an html formatted e-mail to notify of restart if there are any offending Queries
-----------------------------------------------------------------------------------------

declare @OffenderCnt int
select @OffenderCnt = count(1) FROM [DBAUtilities].[HealthCheck].[TempDBSizeUsed]  where [Version_Store_MB] > @ThresholdVersionStoreSizeMB and [collection_time] > dateadd(MINUTE,@ThresholdDurationVersionStoreSizeMin,getdate())                                 

select @OffenderCnt as Offender_Record_Count
print concat('*** Found ', @OffenderCnt, ' rows in [DBAUtilities].[HealthCheck].[TempDBSizeUsed > 300000 in the last hour . ')


if @OffenderCnt >11 and @pEmail is not null
                begin
                                
                                exec msdb.dbo.sp_send_dbmail
                                                @profile_name = @pMailProfile,
                                                @recipients = @pEmail,
                                                @subject = @vSubject,
                                                @body = @tableHTML,
                                                @body_format = 'HTML',
                                                @importance = 'HIGH';
                                                print concat('*** ','Mail was sent !')
                                                print concat('*** ',@tableHTML )
                                                RAISERROR('*** Error: Large Version Store Size Found on tempdb', 16, 1);
                end

set nocount off
end;




USE [dbrepo]
GO
/****** Object:  StoredProcedure [dbo].[GetAGSyncInfo]    Script Date: 11/17/2026 5:05:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec [dbo].[GetAGSyncInfo]

ALTER PROCEDURE [dbo].[GetAGSyncInfo]
    @pAgName     VARCHAR(64) = NULL,
    @pDbName     VARCHAR(64) = NULL,
    @pServerName VARCHAR(64) = NULL,
    @pHealth     VARCHAR(64) = NULL
AS 
BEGIN
    -- Drop temp table if it already exists
    IF OBJECT_ID('tempdb..#LocalReplicas') IS NOT NULL
        DROP TABLE #LocalReplicas;

    -- Create temp table
    CREATE TABLE #LocalReplicas (
        group_id UNIQUEIDENTIFIER,
        group_database_id UNIQUEIDENTIFIER,
        database_id INT,
        last_commit_time DATETIME,
        last_commit_lsn NUMERIC(25,0)
    );

    -- Insert local replicas
    INSERT INTO #LocalReplicas (group_id, group_database_id, database_id, last_commit_time, last_commit_lsn)
    SELECT group_id, group_database_id, database_id, last_commit_time, last_commit_lsn
    FROM sys.dm_hadr_database_replica_states
    WHERE is_local = 1;

    -- Main query
    SELECT getdate() as [CollectionTime],
                                @@SERVERNAME as pri_replica_server_name,
        ar.replica_server_name as sec_replica_server_name, 
        ag.name AS ag_name, 
        adc.database_name, 
        drs.is_local, 
        drs.is_primary_replica, 
                                ar.availability_mode_desc,
        drs.synchronization_state_desc, 
        drs.is_commit_participant, 
        drs.synchronization_health_desc, 
                    IIF(DATEDIFF(SECOND, L.last_commit_time, drs.last_commit_time)<0,0,DATEDIFF(SECOND, L.last_commit_time, drs.last_commit_time)) AS [Sec_Behind],
        ISNULL(TRY_CAST(L.last_commit_lsn AS BIGINT) - TRY_CAST(drs.last_commit_lsn AS BIGINT),0) AS [LSN_Behind],
        drs.recovery_lsn, 
        drs.truncation_lsn, 
        drs.last_sent_lsn, 
        drs.last_sent_time, 
        drs.last_received_lsn, 
        drs.last_received_time, 
        drs.last_hardened_lsn, 
        drs.last_hardened_time, 
        drs.last_redone_lsn, 
        drs.last_redone_time, 
        drs.log_send_queue_size, 
        drs.log_send_rate, 
        drs.redo_rate, 
        drs.redo_queue_size, 
        drs.filestream_send_rate, 
        drs.end_of_log_lsn, 
        drs.last_commit_lsn, 
        drs.last_commit_time
    FROM sys.dm_hadr_database_replica_states AS drs
        INNER JOIN sys.availability_databases_cluster AS adc 
            ON drs.group_id = adc.group_id AND drs.group_database_id = adc.group_database_id
        INNER JOIN sys.availability_groups AS ag
            ON ag.group_id = drs.group_id
        INNER JOIN sys.availability_replicas AS ar 
            ON drs.group_id = ar.group_id AND drs.replica_id = ar.replica_id
        INNER JOIN #LocalReplicas L  
            ON drs.group_id = L.group_id AND drs.group_database_id = L.group_database_id AND drs.database_id = L.database_id
    WHERE (ag.name LIKE ('%' + @pAgName + '%') OR @pAgName IS NULL)
      AND (adc.database_name LIKE ('%' + @pDbName + '%') OR @pDbName IS NULL)
      AND (ar.replica_server_name LIKE ('%' + @pServerName + '%') OR @pServerName IS NULL)
      AND (drs.synchronization_health_desc LIKE ('%' + @pHealth + '%') OR @pHealth IS NULL)
                  AND ar.replica_server_name != @@SERVERNAME
    ORDER BY ag.name, adc.database_name, ar.replica_server_name;

    -- Clean up
    DROP TABLE #LocalReplicas;
END;


USE [DBrepo]
GO

/****** Object:  Table [Monitoring].[WhoIsActiveOver5]    Script Date: 11/17/2026 5:10:54 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Monitoring].[WhoIsActiveOver5](
                [WhoIsActiveOver5_ID] [int] IDENTITY(1,1) NOT NULL,
                [dd hh:mm:ss.mss] [varchar](16) NULL,
                [session_id] [smallint] NOT NULL,
                [login_name] [nvarchar](128) NOT NULL,
                [host_name] [nvarchar](128) NULL,
                [database_name] [nvarchar](128) NULL,
                [collection_time] [datetime] NOT NULL,
                [start_time] [datetime] NOT NULL,
                [sql_text] [xml] NULL,
                [collection_date]  AS (CONVERT([date],[collection_time])) PERSISTED,
                [collection_hour]  AS (datepart(hour,[collection_time])) PERSISTED,
                [blocking_session_id] [int] NULL,
                [program_name] [nvarchar](256) NULL,
                [wait_info] [nvarchar](256) NULL,
                [CPU] [nvarchar](25) NULL,
                [reads] [nvarchar](25) NULL,
                [writes] [nvarchar](25) NULL,
                [physical_reads] [nvarchar](25) NULL,
CONSTRAINT [pk_WhoIsActiveOver5_WhoIsActiveOver5_ID] PRIMARY KEY CLUSTERED 
(
                [WhoIsActiveOver5_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO





USE [dbrepo]
GO

/****** Object:  Table [Monitoring].[OmittedLogins]    Script Date: 11/17/2026 5:11:14 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Monitoring].[OmittedLogins](
                [Login_Name] [varchar](75) NOT NULL,
CONSTRAINT [PK_OLogins] PRIMARY KEY CLUSTERED 
(
                [Login_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO




