

-- add extended property
USE [master]
GO
EXEC [StackOverflow2013].sys.sp_addextendedproperty @name=N'Email_APP_Owner', @value=N'<<email>>'
GO

-- update extended property
USE [master]
GO
EXEC [test].sys.sp_updateextendedproperty @name=N'Email_APP_Owner', @value=N'<<email>>'
GO

-- delete extended property
USE [master]
GO
EXEC [test].sys.sp_dropextendedproperty @name=N'Email_APP_Owner' 
GO

-- query extended property
use [test]
go
select *
from sys.extended_properties


-- update all extended propeties by condition :
declare @str nvarchar(2000)
declare @db_name sysname
if OBJECT_ID('tempdb..#ex_properties') is not null
drop table #ex_properties
create table #ex_properties (dbname sysname, AppContact NVARCHAR(50), [Application] NVARCHAR(50),  [IT Contact] NVARCHAR(50), [Location] NVARCHAR(50)  )

Declare DB_CURSOR CURSOR FORWARD_ONLY For
Select name from sys.databases
where name not in ('master', 'msdb','tempdb','model')
OPEN DB_Cursor FETCH NEXT FROM DB_Cursor INTO @db_name
while (@@FETCH_STATUS = 0 )
begin
set @str = 'USE ['+@db_name+']; insert into #ex_properties select db_name(), NULL, NULL, NULL, NULL'
exec sp_executesql @str
--print @str
set @str = 'USE ['+@db_name+']; update #ex_properties set [AppContact]=(select convert(nvarchar(50),value)
from sys.extended_properties where name in (''App Contact'')) where dbname=db_name()'
--print @str
exec sp_executesql @str
FETCH NEXT FROM DB_Cursor INTO @db_name
end
CLOSE DB_Cursor
DEALLOCATE DB_Cursor
select * from #ex_properties



-- list all extended propeties :
declare @str nvarchar(2000)
declare @db_name sysname
if OBJECT_ID('tempdb..#ex_properties') is not null
drop table #ex_properties
create table #ex_properties (dbname sysname, AppContact NVARCHAR(50), [Email] NVARCHAR(50))

Declare DB_CURSOR CURSOR FORWARD_ONLY For
Select name from sys.databases
where name not in ('master', 'msdb','tempdb','model','DBA_REP')
OPEN DB_Cursor FETCH NEXT FROM DB_Cursor INTO @db_name
while (@@FETCH_STATUS = 0 )
begin
set @str = 'USE ['+@db_name+']; insert into #ex_properties select db_name(), convert (nvarchar(22),name) ,convert (nvarchar(30),value) from sys.extended_properties'
exec sp_executesql @str
print @str
FETCH NEXT FROM DB_Cursor INTO @db_name
end
CLOSE DB_Cursor
DEALLOCATE DB_Cursor
select * from #ex_properties



