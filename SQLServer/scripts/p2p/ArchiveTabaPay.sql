
USE [P2PReconciliation]
GO
--exec sp_spaceused 'recon.TabaPay_TxnDetail'
--exec sp_spaceused 'recon.TabaPay_TxnDetail_Archive'


--CREATE NONCLUSTERED INDEX [IX_TabaPay_TxnDetail_DateTimeCreated] ON [recon].[TabaPay_TxnDetail] ([DateTimeCreated])
--with (online=on)
GO

--select max([DateTimeCreated]) from [recon].[TabaPay_TxnDetail] (nolock)
-- exec Archive_TabaPay_TxnDetail
create procedure Archive_TabaPay_TxnDetail as 
begin
DROP TABLE IF EXISTS #RowsToDelete
DROP TABLE IF EXISTS #RowsToDeleteStg

CREATE TABLE #RowsToDelete (TabaPay_TxnDetailID BIGINT NOT NULL)
CREATE TABLE #RowsToDeleteStg (TabaPay_TxnDetailID BIGINT NOT NULL)



DECLARE @stopDate Date
DECLARE @rc int
DECLARE @BatchSize INT = 20000
set @stopDate = dateadd(day,-9,getdate())


insert into #RowsToDelete (TabaPay_TxnDetailID)
select TabaPay_TxnDetailID from [recon].[TabaPay_TxnDetail] (nolock)
                where [DateTimeCreated] < @stopDate or [DateTimeCreated] is null

create clustered index [IX_RowsToDelete] on #RowsToDelete (TabaPay_TxnDetailID ) with (online=off)


while (1=1)
                
BEGIN                                 
begin try            
                begin tran

                                truncate table #RowsToDeleteStg

                                -- insert rows to #stg table
                                insert into #RowsToDeleteStg (TabaPay_TxnDetailID)
                                select top (@BatchSize) TabaPay_TxnDetailID from #RowsToDelete

                                -- insert rows to archive table
                                insert into [recon].[TabaPay_TxnDetail_Archive] WITH(TABLOCK)
                                select t.[ReferenceID],t.[DateTimeCreated],t.[SourceId],t.[WasUsed],s.[TabaPay_TxnDetailID]
                                from [recon].[TabaPay_TxnDetail] t 
                                inner join #RowsToDeleteStg s
                                on t.TabaPay_TxnDetailID = s.TabaPay_TxnDetailID


                                -- delete rows from real table
                                delete t
                                from [recon].[TabaPay_TxnDetail] t
                                inner join #RowsToDeleteStg s
                                on t.TabaPay_TxnDetailID = s.TabaPay_TxnDetailID

                                -- delete rows from main temp table
                                delete p             
                                from #RowsToDelete p 
                                inner join #RowsToDeleteStg s
                                on p.TabaPay_TxnDetailID = s.TabaPay_TxnDetailID

                                select @rc = @@ROWCOUNT
                                
                commit
                
                if @rc < @BatchSize 
                                break;
                WAItFOR DELAY '00:00:02'

end try
begin catch
if @@TRANCOUNT > 0 
                rollback tran
                Throw;
end catch
end

end
--exec sp_spaceused 'recon.TabaPay_TxnDetail'
--exec sp_spaceused 'recon.TabaPay_TxnDetail_Archive'


--select max ([DateTimeCreated]), min ([DateTimeCreated]) from recon.TabaPay_TxnDetail 
--select max ([DateTimeCreated]), min ([DateTimeCreated]) from recon.TabaPay_TxnDetail_Archive 



