
# get information when SQL Server service stopped and started
# 17147=SQL Server stopped
# 17162=SQL Server started
Get-WinEvent -ProviderName eventlog | Where-Object {$_.Id -eq 17147 -or $_.Id -eq 17162}

# to check on SQL Server when actually started
SELECT LastServerRestart = create_date FROM sys.databases WHERE name = 'tempdb'

# Get information when SQL Server Agent service stopped 
Get-WinEvent -ProviderName eventlog | Where-Object {$_.Id -eq 7036 }


