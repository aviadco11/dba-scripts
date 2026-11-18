

# Check read-only routing
for ($i = 1; $i -le 20; $i++) {
    $svr = Connect-DbaInstance -SqlInstance '<<servername>>' -Database '<<database_name>>' -ApplicationIntent ReadOnly -MultiSubnetFailover
    $result = $svr.Query('SELECT @@SERVERNAME AS ServerName')
    Write-Output $result
}



