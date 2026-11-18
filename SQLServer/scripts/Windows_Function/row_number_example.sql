
/****** This take care only the DB Belongs to AG  ******/
IF OBJECT_ID(N'tempdb..#DBNameInAginfo') IS NOT NULL
begin
drop table #DBNameInAginfo
END
GO
with cte1 as(
select *,ROW_NUMBER() over (partition by AGName,DatabaseName order by inserteddate desc) as rownum from [BackupMonitoring].[DBAndAgInfo])
select AGName,DatabaseName into #DBNameInAginfo from cte1 where rownum=1

/*
insert into [LongRunningQuery].[MetaDBAGInfo] (AGName, DatabaseName, StakeHolderMail)
select a.AGName, a.DatabaseName, b.StakeHolderMail
from #DBNameInAginfo a
join [LongRunningQuery].[StakeholdersInfo] b
on a.AGName = b.AGName
order by a.DatabaseName
*/

with cte1 as(
select *,ROW_NUMBER() over (partition by DatabaseName order by inserteddate desc) as rownum from [LongRunningQuery].[MetaDBAGInfo])
delete from cte1 where rownum>1
select AGName,DatabaseName into #DBNameInAginfo from cte1 where rownum=1
select * from [LongRunningQuery].[MetaDBAGInfo]


