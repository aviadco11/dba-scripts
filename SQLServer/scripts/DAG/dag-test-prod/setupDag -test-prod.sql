
:SETVAR AGSource AG-AOAG_TST
:SETVAR AGDest AG-TEST-PRD02
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 AOAG_TST


-- run backup on AWS side :
:CONNECT $(ListenerDest)
use master 
go
backup database AOAG_Test to disk = 'T:\backup_no_delete\AOAG_Test_01292024.bak' with stats=10


:SETVAR AGSource AG-AOAG_TST
:SETVAR AGDest AG-TEST-PRD02
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 AOAG_TST

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

:SETVAR AGSource AG-AOAG_TST
:SETVAR AGDest AG-TEST-PRD02
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 AOAG_TST

:CONNECT $(ListenerDest)
use master
go
print ('Ensure there is no DBs in the FORWARDER')
select * from sys.databases where name in ('$(DB1)')
go

WAITFOR DELAY '00:00:10';
go

---------------------------------    join DAG on Second cluster AG    -----------------------------------

--RUN ON FORWARDER
:CONNECT $(ListenerDest)
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

------------------------------------- Backup + Restore ------------------------------------------
-- connect forwarder
:SETVAR AGSource AG-AOAG_TST
:SETVAR AGDest AG-TEST-PRD02
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 AOAG_TST

:CONNECT $(ListenerDest)
print('Run Restore on Forwarder')
use master
go

-- doing restore
-- before you run it , run transacion backup log on padbstg01
USE [master];     
RESTORE DATABASE [AOAG_Test]
FROM  URL = N'S3://<<s3_bucket>>/STG/DBStgClust01$AG-IDSVRINT-STG/DelegatedAdministration/FULL_COPY_ONLY/DBStgClust01$AG-IDSVRINT-STG_DelegatedAdministration_FULL_COPY_ONLY_20250128_224032.bak'  
WITH  CREDENTIAL = N's3://<<s3_bucket>>/Prod', 
REPLACE,NORECOVERY,  NOUNLOAD,  STATS = 5, MOVE 'DelegatedAdministration' TO 'D:\MSSQL\DATA\DelegatedAdministration.mdf' ,
MOVE 'DelegatedAdministration_log' TO 'L:\MSSQL\DATA\DelegatedAdministration_log.ldf'
GO
RESTORE LOG [AOAG_Test] 
FROM URL = N'S3://<<s3_bucket>>/STG/DBStgClust01$AG-IDSVRINT-STG/DelegatedAdministration/LOG/DBStgClust01$AG-IDSVRINT-STG_DelegatedAdministration_LOG_20250129_031052.trn' 
WITH CREDENTIAL = N's3://<<s3_bucket>>/Prod', NORECOVERY,  NOUNLOAD,  STATS = 10
GO


-- please make sure the owner for each db is <<username>>

-- run on the primary forwarder
:SETVAR AGSource AG-AOAG_TST
:SETVAR AGDest AG-TEST-PRD02
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 AOAG_TST

:CONNECT $(ListenerDest)
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
:SETVAR AGSource AG-AOAG_TST
:SETVAR AGDest AG-TEST-PRD02
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 AOAG_TST

:CONNECT $(FORWARDER_SECONDARY)

USE [master];     
RESTORE DATABASE AOAG_Test  
FROM  URL = N'S3://<<s3_bucket>>/STG/DBStgClust01$AG-IDSVRINT-STG/DelegatedAdministration/FULL_COPY_ONLY/DBStgClust01$AG-IDSVRINT-STG_DelegatedAdministration_FULL_COPY_ONLY_20250128_224032.bak'  
WITH  CREDENTIAL = N's3://<<s3_bucket>>/Prod', 
REPLACE,NORECOVERY,  NOUNLOAD,  STATS = 5, MOVE 'DelegatedAdministration' TO 'D:\MSSQL\DATA\DelegatedAdministration.mdf' ,
MOVE 'DelegatedAdministration_log' TO 'L:\MSSQL\DATA\DelegatedAdministration_log.ldf'
GO
RESTORE LOG AOAG_Test 
FROM URL = N'S3://<<s3_bucket>>/STG/DBStgClust01$AG-IDSVRINT-STG/DelegatedAdministration/LOG/DBStgClust01$AG-IDSVRINT-STG_DelegatedAdministration_LOG_20250129_031052.trn' 
WITH CREDENTIAL = N's3://<<s3_bucket>>/Prod', NORECOVERY,  NOUNLOAD,  STATS = 10
GO



:SETVAR AGSource AG-AOAG_TST
:SETVAR AGDest AG-TEST-PRD02
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 AOAG_TST

:CONNECT $(FORWARDER_SECONDARY)
use master
go
print ('Add dbs to DAG in FORWARDER_SECONDARY')
ALTER DATABASE [$(DB1)] SET HADR AVAILABILITY GROUP = [$(AGDest)];  
ALTER DATABASE [$(DB1)] SET HADR  RESUME;
GO
WAITFOR DELAY '00:00:05';
go


-- done
-- check that all sync in global, and forwarder in recovery/sync.
-- then run the failover dag on the forwarder


-------------------------------------------  FailOver DAG -------------------------------
:SETVAR AGSource AG-AOAG_TST
:SETVAR AGDest AG-TEST-PRD02
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 AOAG_TST

:CONNECT $(ListenerDest)

use master
go
print('Failvoer DAG from forwarder')
ALTER AVAILABILITY GROUP [DAG_$(ListenerSource)-$(ListenerDest)] FORCE_FAILOVER_ALLOW_DATA_LOSS; 



---------------------------------------    DROP DAG ----------------------------------
:SETVAR AGSource AG-AOAG_TST
:SETVAR AGDest AG-TEST-PRD02
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 AOAG_TST

:CONNECT $(ListenerDest)



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
:SETVAR AGSource AG-AOAG_TST
:SETVAR AGDest AG-TEST-PRD02
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 AOAG_TST

:CONNECT $(ListenerDest)
USE [master]
GO
print('Upgrade Comptability level')
ALTER DATABASE [$(DB1)] SET COMPATIBILITY_LEVEL = 160;

-- please make sure the owner for each db is <<username>>, this require failover for set the secondary


