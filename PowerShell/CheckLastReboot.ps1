
# 6006 Event ID is what tells us when the server has gone down
# 6005 Event ID is what tells us when the server has gone up


Get-WinEvent -ProviderName eventlog | Where-Object {$_.Id -eq 6005 -or $_.Id -eq 6006}

