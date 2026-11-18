
USE [ArixLendingHooks]
GO

-- AuditEntries = 564,6645 rows
-- Events = 59,203,010 rows           
exec sp_spaceused 'hooks.AuditEntries'
exec sp_spaceused 'hooks.Events'

-- 56765244 rows
--select count(1) from [hooks].[Events] where Created < dateadd(day, -60, getdate())


--CREATE NONCLUSTERED INDEX [IX_hooks_Created] ON [hooks].[Events] ([Created]) with (online=on)
--GO

DROP TABLE IF EXISTS #RowsToDelete
DROP TABLE IF EXISTS #RowsToDeleteStg

-- generate temp tables
CREATE TABLE #RowsToDelete ([Id] uniqueidentifier NOT NULL)
CREATE TABLE #RowsToDeleteStg ([Id] uniqueidentifier NOT NULL)


DECLARE @stopDate Date
DECLARE @rc int
DECLARE @retention INT = -60
DECLARE @BatchSize INT = 20000
set @stopDate = dateadd(day, @retention, getdate())


insert into #RowsToDelete ([Id])
select [Id] from [hooks].[Events] (nolock)
                where [Created] < @stopDate 

PRINT CONCAT('Total id rows: ', @@ROWCOUNT)


create clustered index [IX_RowsToDelete] on #RowsToDelete ([Id] ) with (online=off)

while (1=1)
                
BEGIN                                 
begin try            
                begin tran

                                truncate table #RowsToDeleteStg

                                -- insert rows to #stg table
                                insert into #RowsToDeleteStg ([Id])
                                select top (@BatchSize) [Id] from #RowsToDelete

                                -- delete rows from child table
                                delete d
                                from hooks.AuditEntries d 
                                inner join #RowsToDeleteStg s
                                on d.[EventId] = s.[Id]

                                -- delete rows from parent table
                                delete d
                                from [hooks].[Events] d
                                inner join #RowsToDeleteStg s
                                on d.[Id] = s.[Id]

                                -- delete rows from main temp table
                                delete p             
                                from #RowsToDelete p 
                                inner join #RowsToDeleteStg s
                                on p.[Id] = s.[Id]

                                select @rc = @@ROWCOUNT
                                
                                PRINT CONCAT('delete ',@rc,' rows')

                commit
                
                if @rc < @BatchSize 
                                break;
                WAItFOR DELAY '00:00:01'

end try
begin catch
if @@TRANCOUNT > 0 
                rollback;
                
                DECLARE @ErrorMessage NVARCHAR(4000);
                DECLARE @ErrorSeverity INT;
                DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();
    RAISERROR (@ErrorMessage, -- Message text.
               @ErrorSeverity, -- Severity.
               @ErrorState -- State.
               );
                                
                break;
                
end catch
end

DROP TABLE #RowsToDelete
DROP TABLE #RowsToDeleteStg




