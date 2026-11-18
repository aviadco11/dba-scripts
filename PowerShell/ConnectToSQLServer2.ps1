
cls
function Test-SqlConnection {
    $ErrorActionPreference = 'Stop'
    Write-Host "Connection String : Server=<<servername>>;Integrated Security=true;Initial Catalog=<<database_name>>" -ForegroundColor yellow
    Write-Host "-----------------------------------------------------------------------------------------------------------" -ForegroundColor yellow
    $total_attemptes = 0
    $success_attemptes = 0
    $failed_attemptes = 0
    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $sqlConnection.ConnectionString = "Server=<<servername>>;Integrated Security=true;Initial Catalog=<<database_name>>"
    while ($true)
    {
        try {
            $total_attemptes++

            $starttime  = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
            $sqlConnection.Open() 
            $sqlcmd = $sqlConnection.CreateCommand()
            $sqlcmd.Connection = $sqlConnection
            $exectime  = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
            $query = "waitfor delay '00:01'"
            $sqlcmd.CommandText = $query
    
            Write-Host "$starttime : Execute waitfor delay '00:01 -> Connection Successfull ($exectime ACK)" -ForegroundColor Green
            $success_attemptes++
        } catch {
            $time  = Get-Date
            Write-Host "$time : An error occurred - Connection Failed !! " -ForegroundColor Red
            Write-Host $_ 
            Write-Output $_  > "c:\temp\error.txt"
            $failed_attemptes++
            break
        } finally {
        ## Close the connection when we're done
        $sqlConnection.Close()
        Start-Sleep -Seconds 62
        Write-Host "Total_Attemptes: $total_attemptes. Success_Attemptes: $success_attemptes. Failed_Attemptes: $failed_attemptes "
        }
    }

}


Test-SqlConnection

