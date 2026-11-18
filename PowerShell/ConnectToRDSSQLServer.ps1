
cls

function Test-SqlConnection {
    Write-Host "Connection String : Server=<<endpoint>>;Database=<<database_name>>;Integrated Security=SSPI;MultiSubnetFailover=True" -ForegroundColor yellow
    Write-Host "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor yellow
    $total_attemptes = 0
    $success_attemptes = 0
    $failed_attemptes = 0
    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $cs = "Server=<<endpoint>>;Integrated Security=true;Initial Catalog=<<database_name>>;"
    
    while ($true)
    {
        try {
            $total_attemptes++
            $starttime  = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
            Write-Host "$starttime" -ForegroundColor Green
            Write-host "Select @@ServerName" -ForegroundColor Yellow
            $rs = Invoke-Sqlcmd -ConnectionString $cs -Query "Select @@ServerName as ServerName" -ErrorAction 'Stop'
            $endtime  = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
            $DURATION = New-TimeSpan -Start $starttime -End $endtime
            Write-Host "resultSet: " $rs.ServerName 
            Write-Host "Time: " $DURATION.Milliseconds "(ms)"
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
        $sqlConnection.close()
        }
    }

}


Test-SqlConnection







