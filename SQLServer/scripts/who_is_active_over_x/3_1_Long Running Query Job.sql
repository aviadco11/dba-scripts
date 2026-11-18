
USE [DBAUtilities]
GO

/****** Object:  StoredProcedure [dbo].[AlertOnLongQuery]    Script Date: 9/5/2022 9:41:41 AM ******/
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
                            Cross River Bank
==========================================================================================
Proc Name   : [dbo].[[AlertOnLongQuery]]
Author      : <<username>>, <<username>>, <<username>>
Create Date : 2022-05-31
==========================================================================================
Description : [dbo].[AlertOnLongQuery] procedure collect Query that runs too long (over 5 minutes)
***Requires reference table to filter logins on DBAUtilities.Monitoring.OmittedLogins
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


GO




