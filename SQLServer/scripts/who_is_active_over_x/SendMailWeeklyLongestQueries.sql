
USE [DBAUtilities]
GO

/****** Object:  StoredProcedure [dbo].[SendMailWeeklyLongestQueries]    Script Date: 8/14/2022 3:26:50 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





 --exec [dbo].[SendMailWeeklyLongestQueries] @LastDaysAnalyze=2
CREATE procedure [dbo].[SendMailWeeklyLongestQueries] (@SortBy varchar(50) = 'Reads',                   -- Read / CPU / Writes / Physical_Reads / Duration
                                                                                                                                                                                                  @DBName varchar(200) = NULL,                -- 'test,stackoverflow' / NULL = ALL_DB
                                                                                                                                                                                                  @AGName varchar(50) = NULL,                 -- 'AGARIX'  / NULL = ALL_DB
                                                                                                                                                                                                  @LoginName varchar(50) = NULL,                         -- '<<username>>' / NULL = ALL_DB
                                                                                                                                                                                                  @LastDaysAnalyze int = 7,                                                                     --  Default=7 Days,Last Days to analyze     
                                                                                                                                                                                                  @pMailProfile varchar(64) = 'CRB EXCH'
                                                                                                                                                                                                ,@pEmail varchar(1000) = '<<email>>'
)
as
begin
SET NOCOUNT ON;
declare @DBList varchar(max)
set @DBList = ''''

if OBJECT_ID(N'tempdb..#TopFiveQueries') IS NOT NULL
BEGIN
                DROP TABLE #TopFiveQueries
END

if (@DBName is NULL and @AGName is NULL)
begin
                select @DBList = COALESCE(@DBList + ',' + [name], [name]) from sys.databases;
                set @DBList = @DBList + ''''
end
else if (@DBName is NULL  and @AGName is NOT NULL)
begin
                select @DBList = COALESCE(@DBList + ',' + dbcs.[database_name], dbcs.[database_name]) 
                                                                                FROM master.sys.availability_groups AS AG
                                                                                INNER JOIN master.sys.availability_replicas AS AR
                                                                                ON AG.group_id = AR.group_id
                                                                                INNER JOIN master.sys.dm_hadr_availability_replica_states AS arstates
                                                                                ON AR.replica_id = arstates.replica_id AND arstates.is_local = 1
                                                                                INNER JOIN master.sys.dm_hadr_database_replica_cluster_states AS dbcs
                                                                                ON arstates.replica_id = dbcs.replica_id
                                                                                where AG.name = @AGName;
                                                                                set @DBList = @DBList + ''''
end
else if (@DBName is NOT NULL  and @AGName is NULL) set @DBList = @DBName;

with cte (rownum, [WhoIsActiveOver5_ID],[dd hh:mm:ss.mss],[session_id] ,[login_name],[host_name],[database_name],[collection_time],[start_time],[program_name],[sql_text],[collection_date]
                                  ,[collection_hour],[CPU],[reads],[writes],[physical_reads]) as (select ROW_NUMBER() OVER (partition by session_id, start_time order by [dd hh:mm:ss.mss] desc) as rownum,[WhoIsActiveOver5_ID],
                                  [dd hh:mm:ss.mss],[session_id] ,[login_name],[host_name],[database_name],[collection_time],[start_time],[program_name],[sql_text],[collection_date]
                                  ,[collection_hour],[CPU],[reads],[writes],[physical_reads] from [Monitoring].[WhoIsActiveOver5]
                                  where [start_time] > dateadd(day,(@LastDaysAnalyze*-1),getdate()) and [database_name] in (select * from STRING_SPLIT(@DBList, ',')) and [login_name] like ISNULL(@LoginName,'%'))
select top 5 [dd hh:mm:ss.mss], [session_id] ,[login_name],[host_name],[database_name],[collection_time],[start_time],[program_name],[sql_text],
                                                [CPU],[reads],[writes],[physical_reads] into #TopFiveQueries from cte 
where rownum = 1 
order by 
                CASE WHEN UPPER(@SortBy) = 'READS' THEN cast(replace([reads],',','') as bigint)
                END desc,
                CASE WHEN UPPER(@SortBy) = 'CPU' THEN cast(replace([CPU],',','') as bigint)
                END desc,
                CASE WHEN UPPER(@SortBy) = 'WRITES' THEN cast(replace([writes],',','') as bigint)
                END desc,
                CASE WHEN UPPER(@SortBy) = 'PHYSICAL_READS' THEN cast(replace([physical_reads],',','') as bigint)
                END desc,
                CASE WHEN UPPER(@SortBy) = 'DURATION' THEN [dd hh:mm:ss.mss]
                END desc



declare @vInstance varchar(64), @pointintime varchar(18);

set @vInstance = @@SERVERNAME;
set @pointintime = convert(varchar, getdate(), 111) + ' -' + CONVERT(varchar(5),getdate(),108) 

declare @vSubject varchar(100) = 'Top 5 Intensive Queries By '+@SortBy+' On '+@vInstance + ' _ ' + @pointintime;

----------------------------
--DECLARE VARIABLES FOR HTML
----------------------------
DECLARE @Style NVARCHAR(MAX)= '';
declare @tableHTML NVARCHAR(MAX)= '';
------------
--DEFINE CSS
------------
set @Style += +N'<style type="text/css">' + N'.tg  {border-collapse:collapse;border-spacing:0;border-color:#aaa;}'
    + N'.tg td{font-family:Arial, sans-serif;font-size:12px;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;border-color:#aaa;color:#333;background-color:#ffffff;}'
    + N'.tg th{font-family:Arial, sans-serif;font-size:13px;font-weight:normal;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;border-color:#aaa;color:#fff;background-color:#0E9E2C;}'
    + N'.tg .tg-9ajh{white-space: nowrap;font-weight:bold;background-color:#F1F1F2}' + N'.tg .tg-hgcj{font-weight:bold;text-align:center}'
                + N'.tg .tg-8ajh{white-space: nowrap;font-weight:bold;background-color:#FFFF00}' + N'.tg .tg-hgcj{font-weight:bold;text-align:center}'
    + N'</style>';


set @tableHTML = concat(@Style,' ',@tableHTML,'<H4>','Below are the top 5 intensive queries sort by '+@SortBy+'   
                                                                                running on '+@vInstance + ' in the last '+cast(CONVERT(int,@LastDaysAnalyze) as varchar(10))+' days. The following queires need to be improved, For help please feel free to contact the CRB_DBA Team to tune and improve them.  </H4>')

                + N'<table class="tg">' --DEFINE TABLE
---set @tableHTML += @Style + @tableHTML
                + N'<table class="tg">' --DEFINE TABLE
/*
Define Column Headers and Column Span for each Header Column
*/
                + N'<tr>' 
    + N'<th class="tg-hgcj" colspan="13">Query Details</th>' 
                --+ N'<th class="tg-hgcj" colspan="13">Service Details</th>'
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
                + N'<td class="tg-9ajh">Start Time</td>'
                + N'<td class="tg-9ajh">Program Name</td>'
                + N'<td class="tg-9ajh">SQL Text (*First 400 Chars)</td>'
                + N'<td class="tg-9ajh">CPU</td>'
                + N'<td class="tg-9ajh">reads</td>'
                + N'<td class="tg-9ajh">writes</td>'
                + N'<td class="tg-9ajh">physical_reads</td></tr>'
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
                                                                                td = isnull(start_time,'Unknown') ,
                                                                                '',
                                                                                td = isnull([Program_Name],'Unknown') ,
                                                                                '',
                                                                                td = left(isnull(cast([sql_text] as nvarchar(max)),'Unknown'),400),
                                                                                '',
                                                                                td = isnull([CPU],'Unknown') ,
                                                                                '',
                                                                                td = isnull(reads,'Unknown') ,
                                                                                '',
                                                                                td = isnull(writes,'Unknown') ,
                                                                                '',
                                                                                td = isnull([physical_reads],'Unknown') ,
                                                                                ''
           from  #TopFiveQueries
           for
                                                xml path('tr') ,
                 type
           ) as nvarchar(max)) + N'</table>';

-----------------------------------------------------------------------------------------
-- Send an html formatted e-mail to notify of restart if there are any offending Queries
-----------------------------------------------------------------------------------------

declare @OffenderCnt int
select @OffenderCnt = count(0) from #TopFiveQueries 

select @OffenderCnt as Offender_Record_Count

if @OffenderCnt >0 
                begin
                exec msdb.dbo.sp_send_dbmail
       @profile_name = @pMailProfile ,
       @recipients = @pEmail,
       @subject = @vSubject,
       @body = @tableHTML,
       @body_format = 'HTML'
                end

set nocount off
end;
GO

