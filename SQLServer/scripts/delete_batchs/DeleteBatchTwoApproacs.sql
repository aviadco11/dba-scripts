
-- this approach using the non-clusterd index
-- test on stackoverflow DB, table of 50 Milion rows, able to delete 30 Milion rows in 07:20 min
exec sp_spaceused 'dbo.Votes'
SET NOCOUNT OFF
declare @sql nvarchar(max)
declare @param nvarchar(max)
declare @mindate date
declare @stopdate date
declare @starttime datetime
select @mindate = min([CreationDate]) from [dbo].[Votes]
select min([CreationDate]) from [dbo].[Votes]
set @stopdate = '2012-12-31 00:00:00.000'

while @mindate < @stopdate
begin
begin try            
                begin tran
                                print @mindate
                                set @starttime = getdate()
                                set @sql = N'delete from [dbo].[Votes] where [CreationDate] < cast(@mindate as datetime)';
                                set @param = N'@mindate date';
                                print @sql
                                exec sp_executesql @sql, @param, @mindate = @mindate
                                
                                commit
                                print(datediff(ms, @starttime, getdate()))
                                set @mindate = dateadd(WEEK,1,@mindate)
end try

begin catch
if @@TRANCOUNT > 0 
                rollback tran
end catch
end

GO

exec sp_spaceused 'dbo.Votes'


-- this approach using the clusterd index
-- test on stackoverflow DB, table of 50 Milion rows, able to delete 30 Milion rows in 05:50 min
exec sp_spaceused 'dbo.Votes'

SET NOCOUNT OFF

declare @mindate date
declare @stopdate date
declare @sql nvarchar(max)
declare @param nvarchar(max)
declare @starttime datetime

select @mindate = min([CreationDate]) from [dbo].[Votes]
select min([CreationDate]) from [dbo].[Votes]
set @stopdate = '2012-12-31 00:00:00.000'

create table dbo.temp_work_table
(
[Id] [int],
CONSTRAINT [PK_temp_work_table_Id] PRIMARY KEY CLUSTERED 
(
                [Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]


while @mindate < @stopdate
begin
begin try            
                begin tran
                                print @mindate
                                set @starttime = getdate()
                                truncate table dbo.temp_work_table
                                set @sql = N'insert into dbo.temp_work_table(Id) select Id from [dbo].[Votes] where [CreationDate] < cast(@mindate as datetime) ';
                                set @param = N'@mindate date';
                                print @sql
                                exec sp_executesql @sql, @param, @mindate = @mindate

                                print 'delete v from  [dbo].[Votes] v inner join dbo.temp_work_table t on v.Id = t.Id'
                                delete v
                                from  [dbo].[Votes] v
                                inner join dbo.temp_work_table t
                                on v.Id = t.Id

                commit
                print(datediff(ms, @starttime, getdate()))
                set @mindate = dateadd(WEEK,1,@mindate)
end try

begin catch
if @@TRANCOUNT > 0 
                rollback tran
end catch
end

GO
exec sp_spaceused 'dbo.Votes'

