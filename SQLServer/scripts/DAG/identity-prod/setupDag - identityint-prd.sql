
:SETVAR AGSource <<ag_name>>
:SETVAR AGDest <<ag_name>>
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 DelegatedAdministration
:SETVAR DB2 Crb.IdentityServer
:SETVAR DB3 Crb.IdentityServerSelfService
:SETVAR DB4 Crb.IdentityServerUsers


----------------------------------- Create DAG on global_primary  ----------------------------------------
--RUN ON GLOBAL PRIMARY
:CONNECT $(ListenerSource)
print ('Create DAG on global_primary')
use master
go

ALTER AVAILABILITY GROUP [$(AGSource)] GRANT CREATE ANY DATABASE ;
CREATE AVAILABILITY GROUP [DAG_$(ListenerSource)-$(ListenerDest)]  
   WITH (DISTRIBUTED)   
   AVAILABILITY GROUP ON  
   '$(AGSource)' WITH    
      (   
         LISTENER_URL = 'tcp://$(ListenerSource).<<company_domain>>:5022',   
         AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT,   
         FAILOVER_MODE = MANUAL,   
         SEEDING_MODE = MANUAL--AUTOMATIC   
      ),    
      '$(AGDest)' WITH    
      (   
         LISTENER_URL = 'tcp://$(ListenerDest).<<company_domain>>:5022',    
         AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT,   
         FAILOVER_MODE = MANUAL,   
         SEEDING_MODE = MANUAL--AUTOMATIC   
      );   
GO


------------------ Ensure there is no DB's in the FORWARDER ----------------

:SETVAR AGSource <<ag_name>>
:SETVAR AGDest <<ag_name>>
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 DelegatedAdministration
:SETVAR DB2 Crb.IdentityServer
:SETVAR DB3 Crb.IdentityServerSelfService
:SETVAR DB4 Crb.IdentityServerUsers

/*
use master
go
print ('Ensure there is no DBs in the FORWARDER')
select * from sys.databases where name in ('$(DB1)','$(DB2)','$(DB3)','$(DB4)')
go
*/


---------------------------------    join DAG on Second cluster AG    -----------------------------------

--RUN ON FORWARDER
:CONNECT <<servername>>
use master
go
print ('join DAG on Second cluster AG')
ALTER AVAILABILITY GROUP [DAG_$(ListenerSource)-$(ListenerDest)]   
   JOIN   
   AVAILABILITY GROUP ON  
      '$(AGSource)' WITH    
      (   
         LISTENER_URL = 'tcp://$(ListenerSource).<<company_domain>>:5022',    
         AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT,   
         FAILOVER_MODE = MANUAL,   
         SEEDING_MODE = MANUAL   
      ),   
      '$(AGDest)' WITH    
      (   
         LISTENER_URL = 'tcp://$(ListenerDest).<<company_domain>>:5022',   
         AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT,   
         FAILOVER_MODE = MANUAL,   
         SEEDING_MODE = MANUAL  
      );    
GO  

WAITFOR DELAY '00:00:10';
go
-- DONE
------------------------------------- Backup + Restore ------------------------------------------
-- connect forwarder, restore with <<username>>
:SETVAR AGSource <<ag_name>>
:SETVAR AGDest <<ag_name>>
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 DelegatedAdministration
:SETVAR DB2 Crb.IdentityServer
:SETVAR DB3 Crb.IdentityServerSelfService
:SETVAR DB4 Crb.IdentityServerUsers

:CONNECT <<servername>> -U <<username>> -P <<password>>
print('Run Restore on Forwarder')
use master
go

-- doing restore, restore with <<username>>
-- before you run it , run transacion backup log on padbstg01
USE [master]
GO
RESTORE DATABASE [DelegatedAdministration]  
FROM  URL = N'S3://<<s3_bucket>>/Prod/DBProdClust01$AG-IDSERVER/DelegatedAdministration/FULL_COPY_ONLY/DBProdClust01$AG-IDSERVER_DelegatedAdministration_FULL_COPY_ONLY_20250210_093405.bak'  
WITH  CREDENTIAL = N's3://<<s3_bucket>>/prod', 
REPLACE,NORECOVERY,  NOUNLOAD,  STATS = 5, 
MOVE 'DelegatedAdministration' TO 'D:\MSSQL\DATA\DelegatedAdministration.mdf' ,
MOVE 'DelegatedAdministration_log' TO 'L:\MSSQL\DATA\DelegatedAdministration_log.ldf'
GO

RESTORE LOG [DelegatedAdministration] 
FROM URL = N'S3://<<s3_bucket>>/Prod/DBProdClust01$AG-IDSERVER/DelegatedAdministration/LOG/DBProdClust01$AG-IDSERVER_DelegatedAdministration_LOG_20250210_093500.trn' 
WITH CREDENTIAL = N's3://<<s3_bucket>>/prod', NORECOVERY,  NOUNLOAD,  STATS = 10
GO


--------------------------------
RESTORE DATABASE [Crb.IdentityServer] 
FROM  URL = N'S3://<<s3_bucket>>/Prod/DBProdClust01$AG-IDSERVER/Crb.IdentityServer/FULL_COPY_ONLY/DBProdClust01$AG-IDSERVER_Crb.IdentityServer_FULL_COPY_ONLY_20250210_093211.bak'  
WITH  CREDENTIAL = N's3://<<s3_bucket>>/prod', 
REPLACE,NORECOVERY,  NOUNLOAD,  STATS = 5, 
MOVE 'Crb.IdentityServer' TO 'D:\MSSQL\DATA\Crb.IdentityServer.mdf' ,
MOVE 'Crb.IdentityServer_log' TO 'L:\MSSQL\DATA\Crb.IdentityServer_log.ldf'
GO

RESTORE LOG [Crb.IdentityServer] 
FROM URL = N'S3://<<s3_bucket>>/Prod/DBProdClust01$AG-IDSERVER/Crb.IdentityServer/LOG/DBProdClust01$AG-IDSERVER_Crb.IdentityServer_LOG_20250210_093449.trn' 
WITH CREDENTIAL = N's3://<<s3_bucket>>/prod', NORECOVERY,  NOUNLOAD,  STATS = 10
GO



----------------------------

RESTORE DATABASE [Crb.IdentityServerSelfService] 
FROM  URL = N'S3://<<s3_bucket>>/Prod/DBProdClust01$AG-IDSERVER/Crb.IdentityServerSelfService/FULL_COPY_ONLY/DBProdClust01$AG-IDSERVER_Crb.IdentityServerSelfService_FULL_COPY_ONLY_20250210_093402.bak'  
WITH  CREDENTIAL = N's3://<<s3_bucket>>/prod', 
REPLACE,NORECOVERY,  NOUNLOAD,  STATS = 5, 
MOVE 'Crb.IdentityServerSelfService' TO 'D:\MSSQL\DATA\Crb.IdentityServerSelfService.mdf' ,
MOVE 'Crb.IdentityServerSelfService_log' TO 'L:\MSSQL\DATA\Crb.IdentityServerSelfService_log.ldf'
GO

RESTORE LOG [Crb.IdentityServerSelfService] 
FROM URL = N'S3://<<s3_bucket>>/Prod/DBProdClust01$AG-IDSERVER/Crb.IdentityServerSelfService/LOG/DBProdClust01$AG-IDSERVER_Crb.IdentityServerSelfService_LOG_20250210_093453.trn' 
WITH CREDENTIAL = N's3://<<s3_bucket>>/prod', NORECOVERY,  NOUNLOAD,  STATS = 10
GO


RESTORE DATABASE [Crb.IdentityServerUsers] 
FROM  URL = N'S3://<<s3_bucket>>/Prod/DBProdClust01$AG-IDSERVER/Crb.IdentityServerUsers/FULL_COPY_ONLY/DBProdClust01$AG-IDSERVER_Crb.IdentityServerUsers_FULL_COPY_ONLY_20250210_093403.bak'  
WITH  CREDENTIAL = N's3://<<s3_bucket>>/prod', 
REPLACE,NORECOVERY,  NOUNLOAD,  STATS = 5, 
MOVE 'Crb.IdentityServerUsers' TO 'D:\MSSQL\DATA\Crb.IdentityServerUsers.mdf' ,
MOVE 'Crb.IdentityServerUsers_log' TO 'L:\MSSQL\DATA\Crb.IdentityServerUsers_log.ldf'
GO

RESTORE LOG [Crb.IdentityServerUsers]
FROM URL = N'S3://<<s3_bucket>>/Prod/DBProdClust01$AG-IDSERVER/Crb.IdentityServerUsers/LOG/DBProdClust01$AG-IDSERVER_Crb.IdentityServerUsers_LOG_20250210_093456.trn' 
WITH CREDENTIAL = N's3://<<s3_bucket>>/prod', NORECOVERY,  NOUNLOAD,  STATS = 10
GO

-- please make sure the owner for each db is <<username>>

-- run on the primary forwarder
:SETVAR AGSource <<ag_name>>
:SETVAR AGDest <<ag_name>>
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 DelegatedAdministration
:SETVAR DB2 Crb.IdentityServer
:SETVAR DB3 Crb.IdentityServerSelfService
:SETVAR DB4 Crb.IdentityServerUsers

:CONNECT <<servername>>
use master
go
print ('Add dbs to DAG in forwarder')
ALTER DATABASE [$(DB1)] SET HADR AVAILABILITY GROUP = [DAG_$(ListenerSource)-$(ListenerDest)];
ALTER DATABASE [$(DB2)] SET HADR AVAILABILITY GROUP = [DAG_$(ListenerSource)-$(ListenerDest)];
ALTER DATABASE [$(DB3)] SET HADR AVAILABILITY GROUP = [DAG_$(ListenerSource)-$(ListenerDest)];
ALTER DATABASE [$(DB4)] SET HADR AVAILABILITY GROUP = [DAG_$(ListenerSource)-$(ListenerDest)];
go
WAITFOR DELAY '00:00:05';
go



------------------ Join the database on the secondary of the forwarder  ---------------------------------
-- run on the secondary of the forwarder

-------------- Doing Backup and restore on secondary of the forwarder  ----------
:SETVAR AGSource <<ag_name>>
:SETVAR AGDest <<ag_name>>
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 DelegatedAdministration
:SETVAR DB2 Crb.IdentityServer
:SETVAR DB3 Crb.IdentityServerSelfService
:SETVAR DB4 Crb.IdentityServerUsers

:CONNECT $(FORWARDER_SECONDARY) -U <<username>> -P <<password>>

USE [master]     
GO
RESTORE DATABASE [DelegatedAdministration]  
FROM  URL = N'S3://<<s3_bucket>>/Prod/DBProdClust01$AG-IDSERVER/DelegatedAdministration/FULL_COPY_ONLY/DBProdClust01$AG-IDSERVER_DelegatedAdministration_FULL_COPY_ONLY_20250210_093405.bak'  
WITH  CREDENTIAL = N's3://<<s3_bucket>>/prod', 
REPLACE,NORECOVERY,  NOUNLOAD,  STATS = 5, 
MOVE 'DelegatedAdministration' TO 'D:\MSSQL\DATA\DelegatedAdministration.mdf' ,
MOVE 'DelegatedAdministration_log' TO 'L:\MSSQL\DATA\DelegatedAdministration_log.ldf'
GO

RESTORE LOG [DelegatedAdministration] 
FROM URL = N'S3://<<s3_bucket>>/Prod/DBProdClust01$AG-IDSERVER/DelegatedAdministration/LOG/DBProdClust01$AG-IDSERVER_DelegatedAdministration_LOG_20250210_093500.trn' 
WITH CREDENTIAL = N's3://<<s3_bucket>>/prod', NORECOVERY,  NOUNLOAD,  STATS = 10
GO


--------------------------------
RESTORE DATABASE [Crb.IdentityServer] 
FROM  URL = N'S3://<<s3_bucket>>/Prod/DBProdClust01$AG-IDSERVER/Crb.IdentityServer/FULL_COPY_ONLY/DBProdClust01$AG-IDSERVER_Crb.IdentityServer_FULL_COPY_ONLY_20250210_093211.bak'  
WITH  CREDENTIAL = N's3://<<s3_bucket>>/prod', 
REPLACE,NORECOVERY,  NOUNLOAD,  STATS = 5, 
MOVE 'Crb.IdentityServer' TO 'D:\MSSQL\DATA\Crb.IdentityServer.mdf' ,
MOVE 'Crb.IdentityServer_log' TO 'L:\MSSQL\DATA\Crb.IdentityServer_log.ldf'
GO

RESTORE LOG [Crb.IdentityServer] 
FROM URL = N'S3://<<s3_bucket>>/Prod/DBProdClust01$AG-IDSERVER/Crb.IdentityServer/LOG/DBProdClust01$AG-IDSERVER_Crb.IdentityServer_LOG_20250210_093449.trn' 
WITH CREDENTIAL = N's3://<<s3_bucket>>/prod', NORECOVERY,  NOUNLOAD,  STATS = 10
GO



----------------------------

RESTORE DATABASE [Crb.IdentityServerSelfService] 
FROM  URL = N'S3://<<s3_bucket>>/Prod/DBProdClust01$AG-IDSERVER/Crb.IdentityServerSelfService/FULL_COPY_ONLY/DBProdClust01$AG-IDSERVER_Crb.IdentityServerSelfService_FULL_COPY_ONLY_20250210_093402.bak'  
WITH  CREDENTIAL = N's3://<<s3_bucket>>/prod', 
REPLACE,NORECOVERY,  NOUNLOAD,  STATS = 5, 
MOVE 'Crb.IdentityServerSelfService' TO 'D:\MSSQL\DATA\Crb.IdentityServerSelfService.mdf' ,
MOVE 'Crb.IdentityServerSelfService_log' TO 'L:\MSSQL\DATA\Crb.IdentityServerSelfService_log.ldf'
GO

RESTORE LOG [Crb.IdentityServerSelfService] 
FROM URL = N'S3://<<s3_bucket>>/Prod/DBProdClust01$AG-IDSERVER/Crb.IdentityServerSelfService/LOG/DBProdClust01$AG-IDSERVER_Crb.IdentityServerSelfService_LOG_20250210_093453.trn' 
WITH CREDENTIAL = N's3://<<s3_bucket>>/prod', NORECOVERY,  NOUNLOAD,  STATS = 10
GO


RESTORE DATABASE [Crb.IdentityServerUsers] 
FROM  URL = N'S3://<<s3_bucket>>/Prod/DBProdClust01$AG-IDSERVER/Crb.IdentityServerUsers/FULL_COPY_ONLY/DBProdClust01$AG-IDSERVER_Crb.IdentityServerUsers_FULL_COPY_ONLY_20250210_093403.bak'  
WITH  CREDENTIAL = N's3://<<s3_bucket>>/prod', 
REPLACE,NORECOVERY,  NOUNLOAD,  STATS = 5, 
MOVE 'Crb.IdentityServerUsers' TO 'D:\MSSQL\DATA\Crb.IdentityServerUsers.mdf' ,
MOVE 'Crb.IdentityServerUsers_log' TO 'L:\MSSQL\DATA\Crb.IdentityServerUsers_log.ldf'
GO

RESTORE LOG [Crb.IdentityServerUsers]
FROM URL = N'S3://<<s3_bucket>>/Prod/DBProdClust01$AG-IDSERVER/Crb.IdentityServerUsers/LOG/DBProdClust01$AG-IDSERVER_Crb.IdentityServerUsers_LOG_20250210_093456.trn' 
WITH CREDENTIAL = N's3://<<s3_bucket>>/prod', NORECOVERY,  NOUNLOAD,  STATS = 10
GO

WAITFOR DELAY '00:00:05';
go



:SETVAR AGSource <<ag_name>>
:SETVAR AGDest <<ag_name>>
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 DelegatedAdministration
:SETVAR DB2 Crb.IdentityServer
:SETVAR DB3 Crb.IdentityServerSelfService
:SETVAR DB4 Crb.IdentityServerUsers

:CONNECT $(FORWARDER_SECONDARY)
use master
go
print ('Add dbs to DAG in FORWARDER_SECONDARY')
ALTER DATABASE [$(DB1)] SET HADR AVAILABILITY GROUP = [$(AGDest)];  
ALTER DATABASE [$(DB1)] SET HADR  RESUME;
ALTER DATABASE [$(DB2)] SET HADR AVAILABILITY GROUP = [$(AGDest)];  
ALTER DATABASE [$(DB2)] SET HADR  RESUME;
ALTER DATABASE [$(DB3)] SET HADR AVAILABILITY GROUP = [$(AGDest)];  
ALTER DATABASE [$(DB3)] SET HADR  RESUME;
ALTER DATABASE [$(DB4)] SET HADR AVAILABILITY GROUP = [$(AGDest)];  
ALTER DATABASE [$(DB4)] SET HADR  RESUME;
GO
WAITFOR DELAY '00:00:05';
go


-- done
-- check that all sync in global, and forwarder in recovery/sync.
-- then run the failover dag on the forwarder


-------------------------------------------  FailOver DAG -------------------------------
:SETVAR AGSource <<ag_name>>
:SETVAR AGDest <<ag_name>>
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 DelegatedAdministration
:SETVAR DB2 Crb.IdentityServer
:SETVAR DB3 Crb.IdentityServerSelfService
:SETVAR DB4 Crb.IdentityServerUsers

:CONNECT <<servername>>

use master
go
print('Failvoer DAG from forwarder')
ALTER AVAILABILITY GROUP [DAG_$(ListenerSource)-$(ListenerDest)] FORCE_FAILOVER_ALLOW_DATA_LOSS; 



---------------------------------------    DROP DAG ----------------------------------
:SETVAR AGSource <<ag_name>>
:SETVAR AGDest <<ag_name>>
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 DelegatedAdministration
:SETVAR DB2 Crb.IdentityServer
:SETVAR DB3 Crb.IdentityServerSelfService
:SETVAR DB4 Crb.IdentityServerUsers

:CONNECT <<servername>>

-- done

print('DROP DAG on new global')
USE [master]
GO

DROP AVAILABILITY GROUP [DAG_$(ListenerSource)-$(ListenerDest)];
GO

:CONNECT $(ListenerSource)
USE [master]
GO
print('Drop Dag on new Forwarder')
DROP AVAILABILITY GROUP [DAG_STG-LS-IDSVRINT-AWS-LS-IDSRVINT-STG];
GO



------------------------     Upgrade Comptability level     ---------------------- 

:SETVAR AGSource <<ag_name>>
:SETVAR AGDest <<ag_name>>
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 DelegatedAdministration
:SETVAR DB2 Crb.IdentityServer
:SETVAR DB3 Crb.IdentityServerSelfService
:SETVAR DB4 Crb.IdentityServerUsers

:CONNECT <<servername>>
USE [master]
GO
print('Upgrade Comptability level')
ALTER DATABASE [$(DB1)] SET COMPATIBILITY_LEVEL = 160;
ALTER DATABASE [$(DB2)] SET COMPATIBILITY_LEVEL = 160;
ALTER DATABASE [$(DB3)] SET COMPATIBILITY_LEVEL = 160;
ALTER DATABASE [$(DB4)] SET COMPATIBILITY_LEVEL = 160;

-- please make sure the owner for each db is <<username>>, this require failover for set the secondary


