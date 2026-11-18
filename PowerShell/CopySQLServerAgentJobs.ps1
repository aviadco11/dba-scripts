
#NOSQLPS
####################################################
#HERE IS THE BS TO GET DBATOOLS TO WORK WHAT A MESS#
####################################################
<# https://stackoverflow.com/questions/76250523/powershell-the-certificate-chain-was-issued-by-an-authority-that-is-not-truste #>

Set-DbatoolsConfig -Name Import.EncryptionMessageCheck -Value $false -PassThru | Register-DbatoolsConfig
Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $true -Register
Set-DbatoolsConfig -FullName sql.connection.encrypt -Value $false -Register

<# 
.SYNOPSIS
    Powershell Script to Copy SQL Server Agent Jobs to secondary Servers .

.DESCRIPTION 
    Script Connects to a SQL Server instance copy SQL Server Agent Jobs to secondary Servers.

.NOTES 
    This script will handle copying SQL Server Agent jobs to secondary servers

.COMPONENT 
    This needs the following components
                    1.) SQL SERVER Module
                                2.) DBA Tools Chrissy LeMaire

.LINK 
    Useful Link to ressources or others.

.Parameter ParameterName 
    Description for a parameter in param definition section. Each parameter requires a separate description. The name in the description and the parameter section must match. 
                Currently no Parameters defined for this script

.CREATED BY
                Paul Asaro 

.CREATED DATE 
                10/05/2023

.MODIFIED DATE
    10/18/2023
                
.VERSION
                Version 1.0 Initial Version
                Version 1.1 Fix to make DBATools work correctly because its complete garbage added to ignore certificate.
    Version 1.2 Cleanup code a little bit to better organize it.
    Version 1.3 Added sync date information to better track whether the sync process is actually working.  I update the Description of the Agent Job with the Sync Date.
    Version 1.4 removed Write-Host just using transcript to make it easier for Noa and Esther to create patterns for loading into Elastic Search.
#>

##########################################
#CREATE LOGGING FOLDER IF IT DOESN'T EXIST
##########################################
$path = "C:\CRB\Logs"
If(!(test-path -PathType container $path))
{
      New-Item -ItemType Directory -Path $path
}

########################
#Set File Cleanup Limit#
########################
$limit = (Get-Date).AddHours(-72) ### 3 Days

#$limit = (Get-Date).AddDays(-15)

######################################
# Delete files older than the $limit.#
######################################
#Get-ChildItem -Path $path -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force


#########################################
#CREATING LOGGING FILE FOr AUDIT PURPOSES
#########################################
$LogDate = Get-Date -Format "yyyyMMddhhmm"
$LogFilePath = "$path\CopySQLServerAgentJobs_$LogDate.txt" 

##################
#Start Transcript#
##################
Start-Transcript -Append $LogFilePath


Import-Module -Name SqlServer
Import-Module -Name DBATools


$MachineName = [Environment]::MachineName
#$MachineName = "sqlrsisstg01"
$Source_Instance = Get-SqlInstance -ServerInstance "$MachineName" -Confirm:$false | ForEach-Object {$_.name}




################################
# Get Secondary Replica Servers#
################################
function Get-SecondaryReplicas {
    param(
        [parameter(mandatory=$true)]
        [validatenotnullorempty()]
        [string]$SQLInstance
    )
    $PrimaryReplicasQuery = "SELECT r.replica_server_name as SecondaryReplica    
FROM sys.dm_hadr_availability_group_states States
INNER JOIN master.sys.availability_groups Groups ON States.group_id = Groups.group_id
INNER JOIN master.sys.availability_replicas r ON r.group_id = Groups.group_id
WHERE groups.name = 'AG-RSIS'
AND States.primary_replica = '$SQLInstance'
AND r.replica_server_name != '$SQLInstance';"

    try{
        $SecondaryReplicas = (invoke-sqlcmd -ServerInstance $SQLInstance -Database master -TrustServerCertificate -Query $PrimaryReplicasQuery).SecondaryReplica
        return $SecondaryReplicas
        
    } catch {
        return $_.Exception
        break
    }
}

$replicas = Get-SecondaryReplicas $Source_Instance
$TotalRecords = ($replicas | Measure-Object).Count

if ($TotalRecords -gt 0) {

    foreach($Replica in $Replicas) {

        $UpdateDate = Get-Date
        $Description = "Job auto updated on Primary Server $MachineName at $UpdateDate by SQL Server Job Sync process to Secondary Server $Replica."
   
        $Message = "Update  Primary Server $MachineName Sync information  for sync to Secondary Replica $Replica."
        #Write-Host $Message
        
        Get-DbaAgentJob -SqlInstance $Source_Instance | Where-Object Category -eq "DataTeam" | Set-DbaAgentJob  -Job $_.Name -Description $Description -Force

        $Message = "Syncing Secondary Replica $Replica Jobs from Primary Node $Source_Instance"
        #Write-Host $Message

        Get-DbaAgentJob -SqlInstance $Source_Instance | Where-Object Category -eq "DataTeam" | Copy-DbaAgentJob -Destination $Replica -Force

}
    }
else {

    $Message = "there are $TotalRecords Secondary Servers in array $MachineName is not the primary node for SSIS Catalog no action taken..." 
    Write-Host $Message
}

#################
#Stop transcript#
#################
Stop-Transcript



