
USE [P2PReconciliation]
GO

exec sp_spaceused 'recon.rs2'
exec sp_spaceused 'recon.rs2_Archive'


CREATE NONCLUSTERED INDEX [IX_rs2_TransactionDate] ON recon.RS2 ([TransactionDate])
with (online=on)
GO

select max([TransactionDate]) from recon.rs2 (nolock)
-- exec Archive_RS2
--create procedure Archive_RS2 as 
--begin
DROP TABLE IF EXISTS #RowsToDelete
DROP TABLE IF EXISTS #RowsToDeleteStg

CREATE TABLE #RowsToDelete ([RS2Id] bigint NOT NULL)
CREATE TABLE #RowsToDeleteStg ([RS2Id] bigint NOT NULL)



DECLARE @stopDate Date
DECLARE @rc int
DECLARE @BatchSize INT = 20000
set @stopDate = dateadd(day,-9,getdate())


insert into #RowsToDelete ([RS2Id])
select [RS2Id] from recon.rs2 (nolock)
                where [TransactionDate] < @stopDate 

create clustered index [IX_RowsToDelete] on #RowsToDelete ([RS2Id] ) with (online=off)


while (1=1)
                
BEGIN                                 
begin try            
                begin tran

                                truncate table #RowsToDeleteStg

                                -- insert rows to #stg table
                                insert into #RowsToDeleteStg ([RS2Id])
                                select top (@BatchSize) [RS2Id] from #RowsToDelete

                                -- insert rows to archive table
                                insert into recon.RS2_Archive WITH(TABLOCK)
                                SELECT t.[TransactionDate], t.[RetrievalReference], t.[SourceId], t.[WasUsed], s.[RS2Id]
                                from recon.RS2 t 
                                inner join #RowsToDeleteStg s
                                on t.[RS2Id] = s.[RS2Id]

                                -- delete rows from real table
                                delete t
                                from recon.RS2 t
                                inner join #RowsToDeleteStg s
                                on t.[RS2Id] = s.[RS2Id]

                                -- delete rows from main temp table
                                delete p             
                                from #RowsToDelete p 
                                inner join #RowsToDeleteStg s
                                on p.[RS2Id] = s.[RS2Id]

                                select @rc = @@ROWCOUNT
                                
                commit
                
                if @rc < @BatchSize 
                                break;
                WAItFOR DELAY '00:00:02'

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

--end



--select max ([TransactionDate]), min ([TransactionDate]) from recon.RS2_Archive
--select max ([TransactionDate]), min ([TransactionDate]) from recon.RS2



