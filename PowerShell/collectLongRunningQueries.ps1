
#where to store the results
$OutputSQLInstance="<<instance_name>>"
$OutputSQLDatabase="<<database_name>>"


#region Functions
#### This region contains the functions and declarations
<###########################################################################################################################################################################>
#regoin GetLongRunningQueriesByReads
# This region get computer name as parameter

Function GetLongRunningQueriesByReads {
  param ([string]$comp)
      
$select_query = "exec GetMostIntensiveQueries @SortBy = 'Reads'"
$rs = Invoke-Sqlcmd -query $select_query -ServerInstance $comp -database DBAUtilities -OutputAs DataTables
foreach ($row in $rs)
{
    $servername = $row.servername
    $duration = $row.Duration
    $session_id = $row.session_id
    $login_name = $row.login_name
    $host_name = $row.host_name
    $database_name = $row.database_name
    $collection_time = $row.collection_time
    $start_time = $row.start_time
    $program_name = $row.program_name
    $sql_text = $row.sql_text.replace("'","''")
    $CPU = $row.CPU
    $reads = $row.reads
    $writes = $row.writes
    $physical_reads = $row.physical_reads
    Write-Output "start"
    Write-Output $sql_text
    Write-Output "end"
    $Recoveryinsertquery="INSERT INTO [LongRunningQuery].[LongRunningQueryInfo] ([ServerName],[dd hh:mm:ss.mss],[session_id],[login_name],[host_name],[database_name],[collection_time],[start_time],[program_name],[sql_text],[CPU],[reads],[writes],[physical_reads]) values ('$servername','$Duration','$session_id','$login_name','$host_name','$database_name','$collection_time','$start_time','$program_name','$sql_text','$CPU','$reads','$writes','$physical_reads')" 
    Write-Output $Recoveryinsertquery
    Invoke-sqlcmd -ServerInstance $OutputSQLInstance -Query $Recoveryinsertquery -Database $OutputSQLDatabase
}
}
#endregion

<###########################################################################################################################################################################>

#regoin GetLongRunningQueriesByDuration
# This region get computer name as parameter

Function GetLongRunningQueriesByDuration {
  param ([string]$comp)

$select_query = "exec GetMostIntensiveQueries @SortBy = 'Duration'"

$rs = Invoke-Sqlcmd -query $select_query -ServerInstance $comp -database DBAUtilities -OutputAs DataTables
foreach ($row in $rs)
{
    $servername = $row.servername
    $duration = $row.Duration
    $session_id = $row.session_id
    $login_name = $row.login_name
    $host_name = $row.host_name
    $database_name = $row.database_name
    $collection_time = $row.collection_time
    $start_time = $row.start_time
    $program_name = $row.program_name
    $sql_text = $row.sql_text
    $CPU = $row.CPU
    $reads = $row.reads
    $writes = $row.writes
    $physical_reads = $row.physical_reads
     
    $Recoveryinsertquery="INSERT INTO [LongRunningQuery].[LongRunningQueryInfo] ([ServerName],[dd hh:mm:ss.mss],[session_id],[login_name],[host_name],[database_name],[collection_time],[start_time],[program_name],[sql_text],[CPU],[reads],[writes],[physical_reads]) values ('$servername','$Duration','$session_id','$login_name','$host_name','$database_name','$collection_time','$start_time','$program_name','$sql_text','$CPU','$reads','$writes','$physical_reads')" 

    Invoke-sqlcmd -ServerInstance $OutputSQLInstance -Query $Recoveryinsertquery -Database $OutputSQLDatabase
}
}
#endregion

<###########################################################################################################################################################################>



$ConnectionList = Get-DbaRegServer -SqlInstance $OutputSQLInstance -Group "Accessible\BackupMonitored"

$truncate_query = "truncate table [LongRunningQuery].[LongRunningQueryInfo]"
Invoke-Sqlcmd -query $truncate_query -ServerInstance $OutputSQLInstance -database $OutputSQLDatabase

#Loop through ConnectionList array
foreach ($item in $ConnectionList)
{
    $comp=$item.ServerName 
    try {
        Write-Host '' -ForegroundColor White;
        '#########################  Now   GetLongRunningQueriesByReads for '+$comp+' ...  #########################';
        GetLongRunningQueriesByReads $comp;
        }
  catch {
        Write-Host '';
        Write-Host '=======================================================================' -ForegroundColor DarkCyan;
        Write-Host '*** Failed getting GetLongRunningQueriesByReads for'$comp' ***' -ForegroundColor Red;
        Write-Host 'Manual Review Required.' -ForegroundColor Yellow;
        Write-Host '=======================================================================' -ForegroundColor DarkCyan;
       }
       <#
  try {
        #Write-Host '' -ForegroundColor White;
        #'#########################  Now   GetLongRunningQueriesByDuration for '+$comp+' ...  #########################';
        #GetLongRunningQueriesByDuration $comp;
        }
  catch {
        Write-Host '';
        Write-Host '=======================================================================' -ForegroundColor DarkCyan;
        Write-Host '*** Failed getting GetLongRunningQueriesByDuration for'$comp' ***' -ForegroundColor Red;
        Write-Host 'Manual Review Required.' -ForegroundColor Yellow;
        Write-Host '=======================================================================' -ForegroundColor DarkCyan;
       }#>
}
<#
$sendmail_query = "exec [LongRunningQuery].[SendMAilLongQuery]"
try {
  Write-Host '' -ForegroundColor White;
  '#########################  Now   SendMAilLongQuery on '+$OutputSQLInstance+' ...  #########################';
  Invoke-Sqlcmd -query $sendmail_query -ServerInstance $OutputSQLInstance -database $OutputSQLDatabase
  }
  catch {
    Write-Host '';
    Write-Host '=======================================================================' -ForegroundColor DarkCyan;
    Write-Host '*** Failed running SendMAilLongQuery on '$OutputSQLInstance' ***' -ForegroundColor Red;
    Write-Host 'Manual Review Required.' -ForegroundColor Yellow;
    Write-Host '=======================================================================' -ForegroundColor DarkCyan;
   }
#>

#endregoin

