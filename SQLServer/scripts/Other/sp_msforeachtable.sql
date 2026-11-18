

exec sp_msforeachtable 'if ''?'' like ''%ComplianceSaga%''
begin
IF OBJECT_ID(''tempdb..#tt1'') IS NOT NULL
begin
drop table #tt1
end
create table #tt1 (indexname varchar(200), descr varchar(max), keys varchar(200))
insert into #tt1 exec sp_helpindex ''?''
if not exists (select * from #tt1 where keys like ''%Correlation_LoanId%'' )
print ''?''
end
'


-- the same query with nested query                                                              
select b.[name]
from sys.tables b
where not EXISTS (select 1 from sys.indexes i 
                                                                where i.[object_id]= b.[object_id] and i.[name] like '%LoanId%'
                                                                ) and b.[name] like '%ComplianceSaga%'


