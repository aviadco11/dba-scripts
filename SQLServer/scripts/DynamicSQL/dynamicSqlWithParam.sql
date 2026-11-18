
-- dynamic sql delete with param

declare @sql nvarchar(max)
declare @param nvarchar(max)
declare @mindate date
declare @stopdate date
declare @starttime datetime
select @mindate = min([CreationDate]) from [dbo].[Votes]
select min([CreationDate]) from [dbo].[Votes]
set @sql = N'delete from [dbo].[Votes] where [CreationDate] < cast(@mindate as datetime)';
set @param = N'@mindate date';
print @sql
exec sp_executesql @sql, @param, @mindate = @mindate


