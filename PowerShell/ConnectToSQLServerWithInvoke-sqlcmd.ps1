
cls
function Test-SqlConnection {
    Write-Host "Connection String : Server=<<servername>>;Integrated Security=true;Initial Catalog=<<database_name>>" -ForegroundColor yellow
    Write-Host "-----------------------------------------------------------------------------------------------------------" -ForegroundColor yellow
    $total_attemptes = 0
    $success_attemptes = 0
    $failed_attemptes = 0
    while ($true)
    {
        try {
            $total_attemptes++

            $starttime  = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
            Write-Host "$starttime : Start : Execute select from AggregatedReconTransactions -> Completed.  Connection Successfull" -ForegroundColor Green
            $rs = Invoke-Sqlcmd -ServerInstance <<servername>> -Database <<database_name>> -Query "SELECT 1 as cnt FROM [<<database_name>>].[dbo].[AggregatedReconTransactions] (nolock) where [Id] = '<<record_id>>'" -ErrorAction 'Stop'
            $endtime  = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
            Write-Host "$endtime : Finish: Get Result select from AggregatedReconTransactions -> Completed." -ForegroundColor Green
            if ($rs.cnt = 1) { $success_attemptes++ }
            $DURATION = New-TimeSpan -Start $starttime -End $endtime
            Write-Host "Time diffreence is :" $DURATION.Seconds " (Sec)"
            if ($DURATION.Seconds>0) {
                Write-Output $DURATION.Seconds  >> "c:\temp\duraion.txt"
            }
        } catch {
            $time  = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
            Write-Host "$time : An error occurred - Connection Failed !! " -ForegroundColor Red
            Write-Host $_ 
            Write-Output $_  >> "c:\temp\error.txt"
            $failed_attemptes++
            break;
        } finally {
        Start-Sleep -Seconds 1
        Write-Host "Total Attemptes: $total_attemptes" 
        Write-Host "Total Successes: $success_attemptes" 
        Write-Host "Total Faileds:   $failed_attemptes "
        Write-Host ""
        Write-Host "==========================================================================================================================================="
        Write-Host ""
        }
    }

}


Test-SqlConnection







