
Param (
    [Parameter(Mandatory=$False)]
    [String]$AvailabilityGroupName,
    [Parameter(Mandatory=$true)]
    [ValidateSet("Jobs", "Logins")]
    [String]$SyncType
    )


#Process {
#Write-host "Sync Type is " $SyncType

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
    10/26/2023
                
.VERSION
                Version 1.0 Initial Version
                Version 1.1 Fix to make DBATools work correctly because its complete garbage added to ignore certificate.
    Version 1.2 Cleanup code a little bit to better organize it.
    Version 1.3 Added sync date information to better track whether the sync process is actually working.  I update the Description of the Agent Job with the Sync Date.
    Version 1.4 removed Write-Host just using transcript to make it easier for Noa and Esther to create patterns for loading into Elastic Search.
    Version 1.5 Added code to sync logins nd parameterize it so the same script
    Version 1.6 Added the code to handle job and Login syncs and multiple AG's using categories based on AG Names
    Version 1.7 Added logic to only copy jobs that have actually changed in the last 30 minutes so Mauro doesn't bitch that the job history is lost.
    Version 1.8 Changed logic to sync jobs to secondary server first and then update description on the Secondary Server only not on the primary server.
#>

if ([string]::IsNullOrEmpty($AvailabilityGroupName)) 
{
    $AvailabilityGroupName = 'EMPTY'
    Write-Host "This will be run for all Availability Groups"
    
}
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
$message = "The sync type we are performing is $SyncType"
#Write-Host $message
$starttime = (Get-Date).ToString("yyyy-MM-dd hh:mm:ss")
$LogDate = Get-Date -Format "yyyyMMddhhmm"
$LogFilePath = -Join($path, '\SyncSQLServer_',$SyncType,'_',$LogDate, '.txt') 
#$LogFilePath = '$path\SyncSQLServer_$SyncType_$LogDate.txt'


###########################
#IMPORT POWERSHELL MODULES#
###########################
Import-Module -Name SqlServer
Import-Module -Name DBATools

################################### 
#INCLUDE SQL SERVER SMO#powershell#
###################################
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null


function Get-SQLSrvAgentJobs {
    param(
        [parameter(mandatory=$true)]
        [validatenotnullorempty()]
        [string]$SQLInstance
    )

                $Date = Get-Date
                $yesterday=  $date.AddHours(-24)

    $JobQuery = ";WITH CTE_Jobs AS 
(
                SELECT j.name
          ,ROW_NUMBER() OVER (ORDER BY j.date_modified DESC)  AS rownum     
                FROM dbo.sysjobs j
                WHERE j.date_modified > '$yesterday'
)
SELECT j.name AS JobList
FROM CTE_Jobs j;"

#Write-Host $JobQuery
    try{
        $JobList = (invoke-sqlcmd -ServerInstance $SQLInstance -Database msdb -TrustServerCertificate -Query $JobQuery) | Select-Object -ExpandProperty JobList
               
        
        return $JobList
    } catch {
        return $_.Exception
        break
    }
}

##################
#Start Transcript#
##################
Start-Transcript -Append $LogFilePath 

#################################################################################################
#Message used to identify the job start info that matches sql server job output requested by Noa#
#################################################################################################
$message = -Join ('Job (SysDBA) Sync SQLServerAgent','_',$SyncType, ' : Step 1, Sync ', $SyncType, ' : Began Executing ', $starttime)
Write-Host $message

###############################
#DEFINE SOME WORKING VARIABLES#
###############################
$MachineName = [Environment]::MachineName
#$MachineName = "sqlrsisstg01"
$Source_Instance = Get-SqlInstance -ServerInstance "$MachineName" -Confirm:$false | ForEach-Object {$_.name}

#Get-SQLSrvAgentJobs $Source_Instance
##########################################
#DEFINE A NEW CONNECTION TO Source_Server#
##########################################
$source_server = new-object ('Microsoft.SqlServer.Management.Smo.Server') -Args $source_instance 

#########################
#DEFINE DEFAULT DATABASE#
#########################
$dbname = "master"

#########################################################
#This sets the connection to Windows-mode authentication#
#########################################################
$source_server.ConnectionContext.LoginSecure=$true;
#Write-Host "Connecting to: $source_server"
#Set Database 
$db = $source_server.Databases[$dbname]
#Write-Host "Using Database: $dbname"

$Message = "Retrieving list of Primary Availiability Groups on Server: $Source_Server and their secondary replica servers..."
#Write-Host $Message

#################################################################################
$ds = $db.ExecuteWithResults(";WITH CTE_PRIMARY AS
(
                SELECT
                   AGC.name -- Availability Group
                , CASE WHEN CHARINDEX('\',RCS.replica_server_name,1) > 0 THEN RCS.replica_server_name ELSE RCS.replica_server_name END AS replica_server_name -- SQL cluster node name
                , ARS.role_desc  -- Replica Role
                , AGL.dns_name  -- Listener Name
                , AR.availability_mode_desc
                FROM
                sys.availability_groups_cluster AS AGC
                  INNER JOIN sys.dm_hadr_availability_replica_cluster_states AS RCS
                   ON
                                RCS.group_id = AGC.group_id
                  INNER JOIN sys.dm_hadr_availability_replica_states AS ARS
                   ON
                                ARS.replica_id = RCS.replica_id
                  LEFT JOIN sys.availability_group_listeners AS AGL
                   ON
                                AGL.group_id = ARS.group_id
                                INNER JOIN Sys.availability_replicas ar
                                                ON ar.replica_id = ARS.replica_id
                WHERE
                ARS.role_desc = 'PRIMARY'
                AND AGC.Name = ISNULL(CAST(NULLIF('$AvailabilityGroupName','EMPTY') as sysname), AGC.Name)
),CTE_SECONDARY AS
(
                SELECT
                   AGC.name -- Availability Group
                , CASE WHEN CHARINDEX('\',RCS.replica_server_name,1) > 0 THEN RCS.replica_server_name ELSE RCS.replica_server_name END AS replica_server_name -- SQL cluster node name
                , ARS.role_desc  -- Replica Role
                , AGL.dns_name  -- Listener Name
                , AR.availability_mode_desc
                FROM
                sys.availability_groups_cluster AS AGC
                  INNER JOIN sys.dm_hadr_availability_replica_cluster_states AS RCS
                   ON
                                RCS.group_id = AGC.group_id
                  INNER JOIN sys.dm_hadr_availability_replica_states AS ARS
                   ON
                                ARS.replica_id = RCS.replica_id
                  LEFT JOIN sys.availability_group_listeners AS AGL
                   ON
                                AGL.group_id = ARS.group_id
                                INNER JOIN Sys.availability_replicas ar
                                                ON ar.replica_id = ARS.replica_id
                WHERE
                ARS.role_desc = 'SECONDARY'
                AND AGC.Name = ISNULL(CAST(NULLIF('$AvailabilityGroupName','EMPTY') as sysname), AGC.Name)
),CTE_RANK AS
(
                SELECT P.name AS AG_NAME
                      ,P.replica_server_name AS Primary_Server
                                  ,S.replica_server_name AS Secondary_Server
                                  ,P.availability_mode_desc
                                  ,ROW_NUMBER() OVER (PARTITION BY p.name ORDER BY CASE WHEN S.availability_mode_desc = 'SYNCHRONOUS_COMMIT' THEN 1 ELSE 2 END ASC) AS rownum
                FROM CTE_PRIMARY P
                JOIN CTE_SECONDARY S
                                ON S.name = P.name

)

SELECT R.AG_NAME
      --,R.Primary_Server
                  ,R.Secondary_Server
                  --,R.availability_mode_desc
FROM CTE_RANK R
WHERE R.rownum = 1
AND R.availability_mode_desc = 'SYNCHRONOUS_COMMIT'
AND R.Primary_Server = @@SERVERNAME
UNION 
SELECT R.AG_NAME
      --,R.Primary_Server
                  ,R.Secondary_Server
                  --,R.availability_mode_desc
FROM CTE_RANK R
WHERE R.rownum = 1
AND R.availability_mode_desc = 'ASYNCHRONOUS_COMMIT'

")

$dt = $ds.Tables[0]

$RecordCount = $dt.Rows.Count
if ([string]::IsNullOrEmpty($RecordCount)) 
{
    $RecordCount = 0
    
}

$message = "Found $RecordCount active Primary Availability Groups on Server:  $Source_instance that we need to syncronize SQL Server objects for..."
#Write-Host $message


#########################################################################
#GET A LIST OF ONLY SQL Server Agent Jobs Changed in the last 30 minutes#
#########################################################################
$Jobs = Get-SQLSrvAgentJobs $Source_Instance

$rowcount = $Jobs.Count

if ($SyncType -eq "Jobs" -and $rowcount -eq 0){

    $message = "There were $Rowcount jobs changed on primary node no need to sync any records"
    Write-Host $message

}


#Write-Host $Jobs
#Write-Host $TotalRecords
################################
#Load data table with Resultset#
################################
$dt = $ds.Tables[0]
Try{
    foreach ($Row in $dt) {
        $AvailabilityGroup = $Row[0]
        $SecondaryServer = $Row[1]

        #################
        #SYNC AGENT JOBS#
        #################
        if ($SyncType -eq "Jobs" -and $rowcount -gt 0) {

                        
                                                $Message = "Syncing Secondary Replica $SecondaryServer Jobs from Primary Node $Source_Instance"
                                                #Write-Host $Message
                                                
            #############################################################################
            #UPDATE JOB ON SECONDARY SERVER FOR ANY JOB THAT WAS CHANGED ON PRIMARY NODE#
            #############################################################################
            Get-DbaAgentJob -SqlInstance $Source_Instance -Job $Jobs | Where-Object {$_.Category -eq $AvailabilityGroup} | Copy-DbaAgentJob -Destination $SecondaryServer -Force 

                                                $message = "AvailabilityGroup: $AvailabilityGroup Secondary Server: $SecondaryServer"
                                                #Write-Host $message

            
                                                $message = -Join('This is the list of jobs that have changed ', $Jobs)
            #Write-Host $message

                                                $UpdateDate = Get-Date
                                                $Description = "Job auto updated on Primary Server $Source_Instance due a change in the job that occurred in the last 24 hours Updated on $UpdateDate by SQL Server Agent Job Sync process to Secondary Server $SecondaryServer."
                
                                                $Message = "Update  Primary Server $Source_Instance Sync information  for sync to Secondary Replica $SecondaryServer."
                                                #Write-Host $Message
                                                
            #########################################################################################
            #UPDATE JOB DESCRIPTION ON SECONDARY SERVER THAT A CHANGE WAS MADE ON THE PRIMARY SERVER#
            #########################################################################################
                                                Get-DbaAgentJob -SqlInstance $SecondaryServer  -Job $Jobs | Where-Object {$_.Category -eq $AvailabilityGroup} | Set-DbaAgentJob  -Job $_.Name -Description $Description -Force
                                
    
        }
        
        #############
        #SYNC LOGINS#
        #############
        If($SyncType -eq "Logins") {

            $Message = "Syncing Secondary Replica $Replica Logins from Primary Node $Source_Instance"
            #Write-Host $Message

            Get-DbaLogin -SqlInstance $Source_Instance |Where-Object {$_.name -ne <<username>> -and $_.name -ne "sa"} | Copy-DbaLogin -Destination $SecondaryServer 
           
        }
    

    }
} #End Try
Catch {
    Write-Host "An error has occurred on SQL Server Sync Process"
    Throw $_
} #End Catch

#################
#Stop transcript#
#################
Stop-Transcript

#} #End Process


