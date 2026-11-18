
<# 
.SYNOPSIS
    Powershell Script to Failover Any AG on the server for Post Patching Failback .

.DESCRIPTION 
    Script Connects to a SQL Server instance and gets a list of AG's currently primary 
    on this instance and retrieves the first Sync Secondary available and fails over
    the AG to that instance

.NOTES 
    Information about the environment, things to need to be consider and other information.
                This Script is currently designed for DEVELOPMENT

.COMPONENT 
    This needs the following components
                    1.) SQL SERVER SMO
                                2.) SQL Server PS Module

.LINK 
    Useful Link to ressources or others.

.Parameter ParameterName 
    Description for a parameter in param definition section. Each parameter requires a separate description. The name in the description and the parameter section must match. 
                Currently no Parameters defined for this script

.CREATED BY
                Paul Asaro 

.CREATED DATE 
                03/16/2023

.MODIFIED DATE
    09/07/2023
                
.VERSION
                Version 1.0 Initial Version
    Version 1.1 fixed logic in code to properly failover only AG's that exist on running server and do not belong there.
                Also added some better logging 
                Made logging directory dynamic.
                Version 1.2 adjust message on logging to show post patching not patching and write to post patching log on same date
                            when multiple reboots happen on same date.
                Version 1.3 Fixed metadata server to point to production listener. Adding error handling to connection to meta server
                Version 1.4 Modified code to force ASYNCHRONOUS_COMMIT AG to failback if patching .  This currently only applies for AG_MPL also logging down to minute
                Version 1.5 Moving MetaServer to point to a CNAME in preparation for the move of <<database_name>> to RDS instance
                Version 1.6 Modified code to check for up to 10 minutes but check in 30 second intervals instead of 1 minute intervals
                Version 1.7 Modified code to handle default instance path variable and to resume HADR on the NEW Secondary Server of an ASYNC AG
                Version 1.8 Modifed code to add NOC Patching Alert notifications.
    Version 1.9 Modifed code to change AG Mode and failover mode for ASYNC Availability Groups to prevent data loss.Modification to support Multisubnet connection issues with RDS
#>

#UNCOMMENT OUT WHEN THIS RUNS ON THE ACTUAL SERVER
$MachineName = [Environment]::MachineName


##########################################
#CREATE LOGGING FOLDER IF IT DOESN'T EXIST
##########################################
$path = "C:\CRB\Logs"
If(!(test-path -PathType container $path))
{
      New-Item -ItemType Directory -Path $path
}

#########################################
#CREATING LOGGING FILE FOr AUDIT PURPOSES
#########################################
$LogDate = Get-Date -Format "yyyyMMddhhmm"
#$LogDate = Get-Date -Format "yyyyMMddTHHmmssffff"
$LogFilePath = "$path\PostPatching_Groupfailback_$LogDate.log" 

#if (Test-Path $LogFilePath) {
#  Write-Host "Deleting LogFile $LogfilePath"
# Remove-Item $LogFilePath
#}
# Version 1.2 remove delete of file for same day and add to existing day log.

Function Write-LogEntry  {
                param (
                [parameter(Mandatory = $true, HelpMessage = "Value added to the log file.")]
                                [ValidateNotNullOrEmpty()]
                                [string]$Value,
                                [parameter(Mandatory = $False, HelpMessage = "Severity for the log entry. 1 for Informational, 2 for Warning and 3 for Error. Default is 1")]
                                #[ValidateNotNullOrEmpty()]
                                [ValidateSet("1", "2", "3")]
                                [string]$Severity = "1"
                                #[parameter(Mandatory = $false, HelpMessage = "Name of the log file that the entry will written to.")]
                                #[ValidateNotNullOrEmpty()]
                                #[System.IO.FileInfo]$FileName = $LogFilePath
                )
                # Determine log file location
                                #$LogFilePath = Join-Path -Path $LogsDirectory -ChildPath $($Action +"_Users_$DateTimeStamp.log")
                                # Construct time stamp for log entry
                                if (-not(Test-Path -Path 'variable:global:TimezoneBias')) {
                                                [string]$global:TimezoneBias = [System.TimeZoneInfo]::Local.GetUtcOffset((Get-Date)).TotalMinutes
                                if ($TimezoneBias -match "^-") {
                                                $TimezoneBias = $TimezoneBias.Replace('-', '+')
                                }
                                else {
                                                $TimezoneBias = '-' + $TimezoneBias
                                }
                                }
                                $Time = -join @((Get-Date -Format "HH:mm:ss.fff"), $TimezoneBias)
                                # Construct date for log entry
                                $Date = (Get-Date -Format "MM-dd-yyyy")
                                # Construct context for log entry
                                $Context = $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)
                                # Construct final log entry
                                $LogText = "<![LOG[$($Value)]LOG]!><time=""$($Time)"" date=""$($Date)"" context=""$($Context)"" type=""$($Severity)"" thread=""$($PID)"" file=""$InputFile"">"
        #Write-Host $LogText
                # Add value to log file
                try {
                Out-File -InputObject $LogText -Append -NoClobber -Encoding Default -FilePath $LogFilePath -ErrorAction Stop
                }
                catch [System.Exception] {
Write-Warning -Message "Unable to append log entry to $LogFilePath file. Error message at line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)" -Severity 3
                }
} # End Function Write-LogEntry -Severity 2 

####################################
##META SERVER CONNECTION INFORMATION
[string] $MetaServer= "<<servername>>"
[string] $MetaDatabase = "<<database_name>>"
####################################

function ExecuteSqlQuery ($SQLQuery) {
    $Datatable = New-Object System.Data.DataTable

    $Connection = New-Object System.Data.SQLClient.SQLConnection
    $Connection.ConnectionString = "server=$MetaServer;database=$MetaDatabase;trusted_connection=true;MultiSubnetFailover=True"
    $Connection.Open()
    $Command = New-Object System.Data.SQLClient.SQLCommand
    $Command.Connection = $Connection
    $Command.CommandText = $SQLQuery
    $Reader = $Command.ExecuteReader();
    $Datatable.Load($Reader);
    $Connection.Close()
    #$Datatable

    return $Datatable
    
}


################
#Credential Info
################
#$cred =Get-Credential crbcloud\adminPaul


#$source_instance  = 'PADBQUA02\SQLQUA02'
$dbname = "master"


##########################
#IMPORT SQL SERVER MODULE#
##########################
Import-Module SQLServer 

######################
#SET THE INSTANCE NAME
###################### 
$Source_Instance = Get-SqlInstance -ServerInstance "$MachineName" -Confirm:$false | ForEach-Object {$_.name}

Write-LogEntry "Connecting to SQL Server Instance:$Source_instance"

######################## 
#INCLUDE SQL SERVER SMO#
########################
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null

###############
##Email Server#
###############
$mailserver = "<<servername>>"
$EmailFrom = -Join($MachineName, "@<<company_domain>>")
$EmailToArray = @('<<email>>','<<email>>','<<email>>')
#$EmailToArray = @('<<email>>','<<email>>')
$EmailTo = "<<email>>;<<email>>"
$SubjectStart = -Join("(CRB_DBA Patching) Starting Post-Patching process on Server ", $MachineName)

$SubjectEnd = -Join("(CRB_DBA Patching) Completed Post-Patching process on Server ", $MachineName)

$BodyStart = -Join("NOC,", "<br /> <br />", "The Post-Patching process has started on Server ",$MachineName, ".  Please be on the lookout for a successful completion Email. This process can take 30 minutes or more to complete.  Please notify <<email>> if you have not seen a successful post-patching complete email within two hours.<br /> <br />  Thanks, <br />  <br /> CRB_DBA Team")

$BodyEnd = -Join("NOC,","<br /> <br />","The Post-Patching process has completed on Server. Please review the attached logfile to validate process had no errors. If there are any errors you should also reach out to <<email>> and notify him that there may be an issue. ",$MachineName, ". <br /> <br /> Thanks, <br />  CRB_DBA Team")

$subect = "Error Failing Over Availability Groups for SQL Server Post-Patching process"
$body = $null

##########################################
#DEFINE A NEW CONNECTION TO Source_Server#
##########################################
$source_server = new-object ('Microsoft.SqlServer.Management.Smo.Server') -Args $source_instance 



Write-LogEntry -Severity 2  "Executing Post_Patch_Failback.ps1 Machine: $CurrentServer"

#####################################
#ALERT NOC POST-PATCHING HAS STARTED#
#####################################
Send-MailMessage -From $EmailFrom -Subject $SubjectStart -To $EmailToArray -Body $BodyStart -Port 25 -SmtpServer $mailserver -BodyAsHtml -Priority High


#########################################################
#This sets the connection to Windows-mode authentication#
#########################################################
$source_server.ConnectionContext.LoginSecure=$true;
Write-LogEntry -Severity 2  "Connecting to: $source_server"
#Set Database 
$db = $source_server.Databases[$dbname]
Write-LogEntry -Severity 2  "Using Database: $dbname"

$Message = "Retrieving list of Primary Availiability Groups on Server: $Source_Server that will be moved to secodary server"
Write-LogEntry -Severity 2  $Message
#################################################################################
$ds = $db.ExecuteWithResults(";WITH CTE_PRIMARY AS
(
                SELECT
                   AGC.name -- Availability Group
                , CASE WHEN CHARINDEX('\',RCS.replica_server_name,1) > 0 THEN RCS.replica_server_name ELSE CONCAT(RCS.replica_server_name,'\default') END AS replica_server_name -- SQL cluster node name
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
),CTE_SECONDARY AS
(
                SELECT
                   AGC.name -- Availability Group
                , CASE WHEN CHARINDEX('\',RCS.replica_server_name,1) > 0 THEN RCS.replica_server_name ELSE CONCAT(RCS.replica_server_name,'\default') END AS replica_server_name -- SQL cluster node name
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
      ,R.Primary_Server
                  ,R.Secondary_Server
                  ,R.availability_mode_desc
FROM CTE_RANK R
WHERE R.rownum = 1
AND R.AG_NAME NOT LIKE 'DAG%'
--AND R.AG_NAME = 'AG_TEST'

")



$dt = $ds.Tables[0]

$RecordCount = $dt.Rows.Count
if ([string]::IsNullOrEmpty($RecordCount)) 
{
    $RecordCount = 0
    
}

Write-LogEntry -Severity 2  "Found $RecordCount active Primary Availability Groups on Server:  $Source_instance that need to be moved to secondary server during post patching rebalance of Availability Groups..."

################################
#Load data table with Resultset#
################################
$dt = $ds.Tables[0]

######################################################
#Code to FAIL OVER THE LOCAL INSTANCE TO A SECONDARY #
######################################################

foreach ($Row in $dt) {

                        $AGName = $Row[0]                     
                        $PrimaryServer =  $Row[1]
                        $SecondaryServer = $Row[2]
                                                                                                $AGMode = $Row[3]
                                                                                

                        $Path = "SQLSERVER:\Sql\$SecondaryServer\AvailabilityGroups\$AGName"
                        $PrimaryPath = "SQLSERVER:\Sql\$PrimaryServer\AvailabilityGroups\$AGName"
                        $SecondaryPath = "SQLSERVER:\Sql\$SecondaryServer\AvailabilityGroups"
                        $AGStatePath = "SQLSERVER:\Sql\$PrimaryServer\AvailabilityGroups\$AGName\DatabaseReplicaStates"
                        $AGDBs = "SQLSERVER:\Sql\$PrimaryServer\AvailabilityGroups\$AGName\AvailabilityDatabases"
                        
                        $PrimaryReplicaType = $PrimaryServer.Replace('\', '%5C')

                        If ($PrimaryServer.Contains("default")) {
                            $PrimaryReplicaType = $PrimaryServer.Replace("\default","") }
                        
                        $SecondaryReplicaType = $SecondaryServer.Replace('\', '%5C')

                        If ($SecondaryServer.Contains("default")) {
                            $SecondaryReplicaType = $SecondaryServer.Replace("\default", "") }
                                                      
                        $AGReplicaPrimary = "SQLSERVER:\Sql\$PrimaryServer\AvailabilityGroups\$AGName\AvailabilityReplicas\$PrimaryReplicaType"
                                                                                                $AGReplicaSecondary = "SQLSERVER:\Sql\$PrimaryServer\AvailabilityGroups\$AGName\AvailabilityReplicas\$SecondaryReplicaType"

                        $AGReplicaPrimaryNew = "SQLSERVER:\Sql\$SecondaryServer\AvailabilityGroups\$AGName\AvailabilityReplicas\$PrimaryReplicaType"
                        $AGReplicaSecondaryNew = "SQLSERVER:\Sql\$SecondaryServer\AvailabilityGroups\$AGName\AvailabilityReplicas\$SecondaryReplicaType"

                        #Write-Host $AGName
                                                                                                [string] $SQLQuery= $(";WITH cte_Env
                                                                                                                                                                                                AS (
                                                                                                                                                                                                                                SELECT DISTINCT Environment
                                                                                                                                                                                                                                FROM core.AG_Metadata
                                                                                                                                                                                                                                WHERE MachineName = '$MachineName'
                                                                                                                                                                                                )
                                                                                                                                                                                                SELECT m.name
                                                                                                                                                                                                FROM  cte_Env cte
                                                                                                                                                                                                JOIN core.AG_Metadata m
                                                                                                                                                                                                                ON cte.Environment = m.Environment
                                                                                                                                                                                                WHERE m.MachineName <> '$MachineName'
                                                AND m.IsDefault = 1
                                                                                                                                                                                                AND name = '$AGName'")
                        #Write-Host $SQLQuery
                        $AGDatatable = New-Object System.Data.DataTable
                        Try{
                                                                                                                $ConnectionError = $null
                            $ConnectionWarning = $null
                            $ErrMsg = $null

                            $MetaConnection = (Test-NetConnection $MetaServer -Port 1433 -WarningAction SilentlyContinue -EA Stop -WarningVariable ConnectionWarning -ErrorVariable ConnectionError).TcpTestSucceeded 

                                                                                                                If($MetaConnection -eq "True"){
                                                                                                                                $ErrMsg = "TCP connect to MetaServer $MetaServer  from $MachineName was Successful"
                                                                                                                                Write-LogEntry -Severity 2 $  
                                                                                                                                $AGDatatable = ExecuteSqlQuery $SqlQuery 

                                                                                                                }
                            else
                            {
                                $ErrMsg = $( ($ConnectionError | Select Exception).Exception.message) # "TCP connect to MetaServer $MetaServer from $MachineName Failed"
                                
                                Write-Host "Error Msg:" $ErrMsg
                                Write-Host "Connection Error:" $ConnectionError
                                If($ConnectionError -or $ErrMsg)
                                {
                                   
                                    Write-LogEntry -Severity 1 $ErrMsg
                                }
                            }
                                                                                                                                                                                
                        }
                                                                                                Catch {
                                  
                                Write-LogEntry -Severity 1 $( ($ConnectionError | Select Exception).Exception.message)
                                Send-MailMessage -From $EmailFrom -Subject $subect -To $EmailToArray -Body $( ($ConnectionError | Select Exception).Exception.message) -Port 25 -SmtpServer $mailserver -BodyAsHtml -Priority High -Attachments $LogFilePath
                                Throw $_ 
                                                                                                }
                        
                        foreach ($Row in $AGDatatable) {
                            
                            $AG_Result = $Row[0]                              
                        }
                        
                       #Write-Host "Result is $AG_Result Current Row is $AGName"
                                                                                                
                        #Test-SqlAvailabilityGroup -Path $Path -Confirm 
                            #Write-LogEntry -Severity 2  $PrimaryPath
                            Try{
                                                                                                                                                If ($AG_Result -eq $AGName) {                                                                                                                                          
                                                                                                                                                                Write-LogEntry -Severity 2  "Moving Availability Group: [$AGName] from Instance: $PrimaryServer to its default Instance: $SecondaryServer during AG failback script."
                                                                                                                                                                
                                        If ($AgMode -eq "ASYNCHRONOUS_COMMIT") {

                                            ###########################################
                                            #CHANGE AVAILABLITY MODE AND FAILOVER MODE#
                                            ###########################################
                                            
                                                                                                                                                                                $ErrMsg = "Changing Availabiity Mode from ASYNCHRONOUS_COMMIT to SYNCHRONOUS_COMMIT and failover Mode to Automatic for $AGName on Server $PrimaryServer" 
                                            Write-LogEntry -Severity 2 $ErrMsg
                                            Set-SqlAvailabilityReplica -AvailabilityMode SynchronousCommit -FailoverMode Automatic -Path $AGReplicaPrimary -Confirm:$false

                                            

                                            $ErrMsg = "Changing Availabiity Mode from ASYNCHRONOUS_COMMIT to SYNCHRONOUS_COMMIT and failover mode to Automatic for $AGName on Server $SecondaryServer" 
                                            Write-LogEntry -Severity 2 $ErrMsg
                                            Set-SqlAvailabilityReplica -AvailabilityMode SynchronousCommit -FailoverMode Automatic -Path $AGReplicaSecondary -Confirm:$false 
                                            
                                            

                                            #Sleep for 30 seconds just wait for the Availability and FailoverMode to complete
                                            sleep 30
                                            
                                            ###########################
                                            #SWITCH AVAILABILITY GROUP#
                                            ###########################
                                            $ErrMsg = "Error Occurred while moving over Availability Group: [$AGName] from Instance: $PrimaryServer to its default Instance: $SecondaryServer during AG failback script."
                                            Switch-SqlAvailabilityGroup -Path "$Path" -Confirm:$false

                                            ###########################################
                                            #CHANGE AVAILABLITY MODE AND FAILOVER MODE#
                                            ###########################################
                                            
                                            $ErrMsg = "Changing Availabiity Mode from SYNCHRONOUS_COMMIT to ASYNCHRONOUS_COMMIT and failover Mode to Manual for $AGName on Server $PrimaryServer" 
                                            Write-LogEntry -Severity 2 $ErrMsg
                                            Set-SqlAvailabilityReplica -AvailabilityMode AsynchronousCommit -FailoverMode Manual -Path $AGReplicaPrimaryNew -Confirm:$false
                                            

                                            $ErrMsg = "Changing Availabiity Mode from SYNCHRONOUS_COMMIT to ASYNCHRONOUS_COMMIT and failover Mode to Manual for $AGName on Server $SecondaryServer" 
                                            Write-LogEntry -Severity 2 $ErrMsg
                                            Set-SqlAvailabilityReplica -AvailabilityMode AsynchronousCommit -FailoverMode Manual -Path $AGReplicaSecondaryNew -Confirm:$false
                                            
                                                                                                                                                                }
                                                                                                                                                                else {
                                                                                                                                                                                Switch-SqlAvailabilityGroup -Path "$Path" -Confirm:$false
                                                                                                                                                                }
                                                                                                                                                }
                                                                                                                                                else {
                                                                                                                                                                Write-LogEntry -Severity 2 "Availability Group [$AGName] will remain on Instance: $PrimaryServer and not be moved to Instance: $SecondaryServer during AG failback script."
                                                                                                                                                                
                                                                                                                                                }              
                                                                                                                                                
                                                                                                                                
                            }
                            Catch {
                                $body = $ErrMsg
                                Send-MailMessage -From $EmailFrom -Subject $subect -To $EmailToArray -Body $body -Port 25 -SmtpServer $mailserver -BodyAsHtml -Priority High -Attachments $LogFilePath
                                Throw $_
                                Return $False;
                            } #End Try AG FAILOVER


                            #Check the healthstate of the AG on the Secondary Server where we failed it over to 
                       
                            $AGHealth = Get-ChildItem -Path "$SecondaryPath" | Where-Object {$_.Name -eq "$AGName" } | Test-SqlAvailabilityGroup | Select-Object "HealthState" | ForEach-Object {$_.HealthState} 
                        
                            ############################################################
                            #CHECK AG HEALTH STATE TO MAKE SURE IT COMES UP ON SECONDARY
                            ############################################################ 
                            $loopcount = 1
                                                                                                                
                          try {
                                                                                                                                If ($AG_Result -eq $AGName) {
                                                                                                                                                while ($AgHealth -ne "Healthy" -and $loopcount -lt 21) {
                                                                                                                                                                                $AGHealth = Get-ChildItem -Path "$SecondaryPath" | Where-Object {$_.Name -eq "$AGName" } | Test-SqlAvailabilityGroup | Select-Object "HealthState" | ForEach-Object {$_.HealthState} 
                                                                                                                                                                                Write-LogEntry -Severity 2  "Availability Group $AGName  is in a $AGHealth state on Server $SecondaryServer"
                                                                                                                                                                                #Write-LogEntry -Severity 2  "Sleeping for 5 seconds"
                                                                                                                                                                                Write-LogEntry -Severity 2  "Checked Availability Group $AGname State $loopcount times..."
                                                                                                                                                                                sleep 30

                                                                                                                                                                                $loopcount++
                                                                                                                                                   }  
                                                                                                                   
                                                                                                                                                If ($AGHealth -ne "Healthy") {
                                                                                                                                                                $ErrMsg =  "Unable to confirm successful move of $AGname from $PrimaryServer to $SecondaryServer the current state is $AGHealth"
                                        Write-LogEntry -Severity 3  $ErrMsg
                                                                                                                                                                #Throw $ErrMsg
                                                                                                                                                                Throw "AG Heath Error occurred..."
                                                                                                                                                }
                                                                                                                                                else {
                                        $ErrMsg = "AG: $AGName has successfully moved over from $PrimaryServer to $SecondaryServer and is in $AGHealth State currently" 
                                                                                                                                                                Write-LogEntry -Severity 2  $ErrMsg
                                                                                                                                                }
                                                                                                                                }
                        } #End Try AG HEALTH STATUS CHECK
                        Catch {
                            #$error[0].Exception
                            $body = $ErrMsg 
                            Send-MailMessage -From $EmailFrom -Subject $subect -To $EmailToArray -Body $body -Port 25 -SmtpServer $mailserver -BodyAsHtml -Priority High -Attachments $LogFilePath
                            Throw $_
                            Return $False;

                        }

                      }

#######################################
#ALERT NOC POST-PATCHING HAS COMPLETED#
#######################################
Send-MailMessage -From $EmailFrom -Subject $SubjectEnd -To $EmailToArray -Body $BodyEnd -Port 25 -SmtpServer $mailserver -BodyAsHtml -Priority High -Attachments $LogFilePath


###################################################
#Cleanup objects in memory because PS leaks memory#
###################################################
$Source_Server = $null
$ds = $null
$dt = $null

