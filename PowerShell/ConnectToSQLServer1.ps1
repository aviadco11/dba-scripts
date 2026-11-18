
# check connections
cls
while ($true)
{
    try {
            $time  = Get-Date
            $svr = Connect-DbaInstance -SqlInstance <<servername>> -Database <<database_name>>
            $msg = $svr.Query('Select @@ServerName as ServerName')
            Write-Host "$time : " $msg.ServerName " Connection Successfull" -ForegroundColor Green
        }
    catch {
            $time  = Get-Date
            Write-Host "$time : An error occurred - Connection Failes !! " -ForegroundColor Red
            Write-Host $_
            break
        }
    Finally {
            $svr | Disconnect-DbaInstance
            Start-Sleep -Seconds 1
        }
}

