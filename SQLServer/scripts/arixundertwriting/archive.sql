
--exec sp_spaceused 'FailedComplianceLoans'
--exec sp_spaceused 'FailedComplianceLoanReasons'

use [ArixUnderwriting]
GO
SET XACT_ABORT ON;
-- start with minimun, until reach to -366.
SET NOCOUNT OFF
--declare @dayy INT = -560 (week = -200 (initial), day = -200*7=-1400)
declare @MSG VARCHAR(300)
declare @calcdate datetime
declare @dayy INT
select @dayy = datediff(DAY,getdate(),(Min([CreateDate]))) from [dbo].[FailedComplianceLoans] where ActionTypeId is null

while @dayy < -400  -- dest: week = -48, day = -401= 13 months year
BEGIN                                 
begin try            
                begin tran
                                select @calcdate = DATEADD(dd, @dayy, DATEDIFF(dd, 0,getdate()))
                                SET @MSG = 'Iteration for day ' + CAST(@dayy AS VARCHAR) + ': [CreateDate] < ' + convert(varchar,@calcdate,25) + ' and ActionTypeId is null'
                                print @MSG
                                print ('')
                                
                                print concat('Start ->  Insert to table [FailedComplianceLoansArchive] < ', convert(varchar,@calcdate,25),' and ActionTypeId is null')
                                insert into [FailedComplianceLoansArchive] WITH(TABLOCK)
                                select * from [dbo].[FailedComplianceLoans] where [CreateDate] < @calcdate and ActionTypeId is null
                                print concat('Done ->  Insert to table [FailedComplianceLoansArchive] < ', convert(varchar,@calcdate,25), ' and ActionTypeId is null')
                                print ('')
                                                                
                                print concat('Start ->  Create Temporary table #temp_FailedComplianceLoans < ',convert(varchar,@calcdate,25), ' and ActionTypeId is null')

                                IF OBJECT_ID('tempdb..#temp_FailedComplianceLoans') IS NOT NULL
                                                DROP TABLE tempdb..#temp_FailedComplianceLoans

                                select [FailedComplianceLoanID] 
                                into #temp_FailedComplianceLoans
                                from [dbo].[FailedComplianceLoans] 
                                where [CreateDate] < @calcdate and ActionTypeId is null
                                
                                create index ix_CreateDate on #temp_FailedComplianceLoans(FailedComplianceLoanID)
                                
                                print concat('Done ->  Create Temporary table #temp_FailedComplianceLoans < ',convert(varchar,@calcdate,25), ' and ActionTypeId is null')
                                print concat('Start ->  Insert to table [FailedComplianceLoanReasonsArchive] < ',convert(varchar,@calcdate,25), ' and ActionTypeId is null')
                                
                                insert into [FailedComplianceLoanReasonsArchive] WITH(TABLOCK)
                                select a.* from [dbo].[FailedComplianceLoanReasons] a 
                                join #temp_FailedComplianceLoans b on a.FailedComplianceID = b.[FailedComplianceLoanID]
                                
                                print concat('Done ->  Insert to table [FailedComplianceLoanReasonsArchive] < ', convert(varchar,@calcdate,25), ' and ActionTypeId is null') 
                                print ('')

                                print concat('Start ->  Delete from  table [FailedComplianceLoanReasons] < ', convert(varchar,@calcdate,25), ' and ActionTypeId is null')
                                                
                                delete a from [dbo].[FailedComplianceLoanReasons] a
                                                join #temp_FailedComplianceLoans b on a.FailedComplianceID = b.[FailedComplianceLoanID]
                                
                                print concat('DONE ->  Delete from  table [FailedComplianceLoanReasons] < ', convert(varchar,@calcdate,25), ' and ActionTypeId is null')
                                print ('')

                                print concat('Start ->  Delete from  table [FailedComplianceLoans] ', convert(varchar,@calcdate,25), ' and ActionTypeId is null')
                                delete from [dbo].[FailedComplianceLoans] where [CreateDate] < @calcdate and ActionTypeId is null
                                
                                print concat('DONE ->  Delete from table [FailedComplianceLoans] < ',convert(varchar,@calcdate,25), ' and ActionTypeId is null')
                                print ('')
                                
                commit
                
                print concat('Finish : < ', convert(varchar,@calcdate,25))
                print ('************************************************************************************************************')
                WAITFOR DELAY '00:00:01'
                set @dayy += 1
end try
begin catch
if @@TRANCOUNT > 0 
                rollback tran
end catch
end
                --exec sp_spaceused 'FailedComplianceLoansArchive'
                --exec sp_spaceused 'FailedComplianceLoanReasonsArchive'


