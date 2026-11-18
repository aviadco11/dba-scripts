

:SETVAR AGSource AG-Test-STG
:SETVAR AGDest AG-TEST
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest  <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 AOAG_TEST
:SETVAR DB2 AOAG_TEST2
:SETVAR DB3 AOAG_TEST3

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

:SETVAR AGSource AG-Test-STG
:SETVAR AGDest AG-TEST
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest  <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 AOAG_TEST
:SETVAR DB2 AOAG_TEST2
:SETVAR DB3 AOAG_TEST3
:CONNECT $(ListenerDest)
use master
go
print ('Ensure there is no DBs in the FORWARDER')
select * from sys.databases where name in ('$(DB1)','$(DB2)','$(DB3)')
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
:SETVAR AGSource AG-Test-STG
:SETVAR AGDest AG-TEST
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest  <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 AOAG_TEST
:SETVAR DB2 AOAG_TEST2
:SETVAR DB3 AOAG_TEST3

:CONNECT $(ListenerDest)
print('Run Restore on Forwarder')
use master
go

-- doing restore
USE [master];     
RESTORE DATABASE [AOAG_TEST]  FROM  URL = N'S3://<<s3_bucket>>/STG/DBStgClust01$AG-Test-STG/AOAG_Test/FULL_COPY_ONLY/DBStgClust01$AG-Test-STG_AOAG_TEST_FULL_COPY_ONLY_20250126_074252.bak'  
WITH  CREDENTIAL = N's3://<<s3_bucket>>/Prod', 
REPLACE,NORECOVERY,  NOUNLOAD,  STATS = 5, 
MOVE 'AOAG_TEST' TO 'D:\MSSQL\DATA\AOAG_TEST.mdf' ,
MOVE  'AOAG_TEST_log' TO 'L:\MSSQL\DATA\AOAG_TEST_log.ldf'
GO
RESTORE LOG [AOAG_TEST] FROM URL = N's3://<<s3_bucket>>/STG/DBStgClust01$AG-Test-STG/AOAG_Test/LOG/DBStgClust01$AG-Test-STG_AOAG_TEST_Log_20250126_075052.trn' 
WITH CREDENTIAL = N's3://<<s3_bucket>>/Prod', 
NORECOVERY,  NOUNLOAD,  STATS = 10
GO


USE [master];     
RESTORE DATABASE [AOAG_TEST2]  FROM  URL = N's3://<<s3_bucket>>/STG/DBStgClust01$AG-Test-STG/AOAG_TEST2/FULL_COPY_ONLY/DBStgClust01$AG-Test-STG_AOAG_TEST2_FULL_COPY_ONLY_20250126_074257.bak'  
WITH  CREDENTIAL = N's3://<<s3_bucket>>/Prod', 
REPLACE,NORECOVERY,  NOUNLOAD,  STATS = 5, 
MOVE 'AOAG_TEST2' TO 'D:\MSSQL\DATA\AOAG_TEST2.mdf' ,
MOVE  'AOAG_TEST2_log' TO 'L:\MSSQL\DATA\AOAG_TEST2_log.ldf'
GO
RESTORE LOG [AOAG_TEST2] FROM URL = N's3://<<s3_bucket>>/STG/DBStgClust01$AG-Test-STG/AOAG_TEST2/Log/DBStgClust01$AG-Test-STG_AOAG_TEST2_Log_20250126_075200.trn' 
WITH CREDENTIAL = N's3://<<s3_bucket>>/Prod', 
NORECOVERY,  NOUNLOAD,  STATS = 10
GO


USE [master];     
RESTORE DATABASE [AOAG_TEST3]  FROM  URL = N's3://<<s3_bucket>>/STG/DBStgClust01$AG-Test-STG/AOAG_TEST3/FULL_COPY_ONLY/DBStgClust01$AG-Test-STG_AOAG_TEST3_FULL_COPY_ONLY_20250126_074303.bak'  
WITH  CREDENTIAL = N's3://<<s3_bucket>>/Prod', REPLACE,NORECOVERY,  NOUNLOAD,  STATS = 5, MOVE 'AOAG_TEST3' TO 'D:\MSSQL\DATA\AOAG_TEST3.mdf',
  MOVE  'AOAG_TEST3_log' TO 'L:\MSSQL\DATA\AOAG_TEST3_log.ldf'
GO
RESTORE LOG [AOAG_TEST3] FROM URL = N's3://<<s3_bucket>>/STG/DBStgClust01$AG-Test-STG/AOAG_TEST3/Log/DBStgClust01$AG-Test-STG_AOAG_TEST3_Log_20250126_075202.trn' 
WITH CREDENTIAL = N's3://<<s3_bucket>>/Prod', 
NORECOVERY,  NOUNLOAD,  STATS = 10
GO

-- run on the primary forwarder
:SETVAR AGSource AG-Test-STG
:SETVAR AGDest AG-TEST
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest  <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 AOAG_TEST
:SETVAR DB2 AOAG_TEST2
:SETVAR DB3 AOAG_TEST3

:CONNECT $(ListenerDest)
use master
go
print ('Add dbs to DAG in forwarder')
ALTER DATABASE [$(DB1)] SET HADR AVAILABILITY GROUP = [DAG_$(ListenerSource)-$(ListenerDest)];
ALTER DATABASE [$(DB2)] SET HADR AVAILABILITY GROUP = [DAG_$(ListenerSource)-$(ListenerDest)];
ALTER DATABASE [$(DB3)] SET HADR AVAILABILITY GROUP = [DAG_$(ListenerSource)-$(ListenerDest)];
go
WAITFOR DELAY '00:00:05';
go



------------------ Join the database on the secondary of the forwarder  ---------------------------------
-- run on the secondary of the forwarder

-------------- Doing Backup and restore on secondary of the forwarder  ----------
:SETVAR AGSource AG-Test-STG
:SETVAR AGDest AG-TEST
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest  <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 AOAG_TEST
:SETVAR DB2 AOAG_TEST2
:SETVAR DB3 AOAG_TEST3

:CONNECT $(FORWARDER_SECONDARY)
use master 
go
print('run restore on FORWARDER_SECONDARY')
-- doing restore
RESTORE DATABASE [AOAG_TEST]  FROM  URL = N'S3://<<s3_bucket>>/STG/DBStgClust01$AG-Test-STG/AOAG_Test/FULL_COPY_ONLY/DBStgClust01$AG-Test-STG_AOAG_TEST_FULL_COPY_ONLY_20250126_074252.bak'  
WITH  CREDENTIAL = N's3://<<s3_bucket>>/Prod', 
REPLACE,NORECOVERY,  NOUNLOAD,  STATS = 5, 
MOVE 'AOAG_TEST' TO 'D:\MSSQL\DATA\AOAG_TEST.mdf' ,
MOVE  'AOAG_TEST_log' TO 'L:\MSSQL\DATA\AOAG_TEST_log.ldf'
GO
RESTORE LOG [AOAG_TEST] FROM URL = N's3://<<s3_bucket>>/STG/DBStgClust01$AG-Test-STG/AOAG_Test/LOG/DBStgClust01$AG-Test-STG_AOAG_TEST_Log_20250126_075052.trn' 
WITH CREDENTIAL = N's3://<<s3_bucket>>/Prod', 
NORECOVERY,  NOUNLOAD,  STATS = 10
GO


USE [master];     
RESTORE DATABASE [AOAG_TEST2]  FROM  URL = N's3://<<s3_bucket>>/STG/DBStgClust01$AG-Test-STG/AOAG_TEST2/FULL_COPY_ONLY/DBStgClust01$AG-Test-STG_AOAG_TEST2_FULL_COPY_ONLY_20250126_074257.bak'  
WITH  CREDENTIAL = N's3://<<s3_bucket>>/Prod', 
REPLACE,NORECOVERY,  NOUNLOAD,  STATS = 5, 
MOVE 'AOAG_TEST2' TO 'D:\MSSQL\DATA\AOAG_TEST2.mdf' ,
MOVE  'AOAG_TEST2_log' TO 'L:\MSSQL\DATA\AOAG_TEST2_log.ldf'
GO
RESTORE LOG [AOAG_TEST2] FROM URL = N's3://<<s3_bucket>>/STG/DBStgClust01$AG-Test-STG/AOAG_TEST2/Log/DBStgClust01$AG-Test-STG_AOAG_TEST2_Log_20250126_075200.trn' 
WITH CREDENTIAL = N's3://<<s3_bucket>>/Prod', 
NORECOVERY,  NOUNLOAD,  STATS = 10
GO


USE [master];     
RESTORE DATABASE [AOAG_TEST3]  FROM  URL = N's3://<<s3_bucket>>/STG/DBStgClust01$AG-Test-STG/AOAG_TEST3/FULL_COPY_ONLY/DBStgClust01$AG-Test-STG_AOAG_TEST3_FULL_COPY_ONLY_20250126_074303.bak'  
WITH  CREDENTIAL = N's3://<<s3_bucket>>/Prod', REPLACE,NORECOVERY,  NOUNLOAD,  STATS = 5, MOVE 'AOAG_TEST3' TO 'D:\MSSQL\DATA\AOAG_TEST3.mdf',
  MOVE  'AOAG_TEST3_log' TO 'L:\MSSQL\DATA\AOAG_TEST3_log.ldf'
GO
RESTORE LOG [AOAG_TEST3] FROM URL = N's3://<<s3_bucket>>/STG/DBStgClust01$AG-Test-STG/AOAG_TEST3/Log/DBStgClust01$AG-Test-STG_AOAG_TEST3_Log_20250126_075202.trn' 
WITH CREDENTIAL = N's3://<<s3_bucket>>/Prod', 
NORECOVERY,  NOUNLOAD,  STATS = 10
GO

WAITFOR DELAY '00:00:05';
go

:SETVAR AGSource AG-Test-STG
:SETVAR AGDest AG-TEST
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest  <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 AOAG_TEST
:SETVAR DB2 AOAG_TEST2
:SETVAR DB3 AOAG_TEST3

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
GO
WAITFOR DELAY '00:00:05';
go



-- check that all sync in global, and forwarder in recovery/sync.
-- then run the failover dag on the forwarder


-------------------------------------------  FailOver DAG -------------------------------
:SETVAR AGSource AG-Test-STG
:SETVAR AGDest AG-TEST
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest  <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 AOAG_TEST
:SETVAR DB2 AOAG_TEST2
:SETVAR DB3 AOAG_TEST3

:CONNECT $(ListenerDest)
/*
use master
go
print('Failvoer DAG from forwarder')
ALTER AVAILABILITY GROUP [DAG_$(ListenerSource)-$(ListenerDest)] FORCE_FAILOVER_ALLOW_DATA_LOSS; 

*/

---------------------------------------    DROP DAG ----------------------------------
:SETVAR AGSource AG-Test-STG
:SETVAR AGDest AG-TEST
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest  <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 AOAG_TEST
:SETVAR DB2 AOAG_TEST2
:SETVAR DB3 AOAG_TEST3

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

:CONNECT $(ListenerDest)
USE [master]
GO
print('Upgrade Comptability level')
ALTER DATABASE AOAG_TEST SET COMPATIBILITY_LEVEL = 160;
ALTER DATABASE AOAG_TEST2 SET COMPATIBILITY_LEVEL = 160;
ALTER DATABASE AOAG_TEST3 SET COMPATIBILITY_LEVEL = 160;



