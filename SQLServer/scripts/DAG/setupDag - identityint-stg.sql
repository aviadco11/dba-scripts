
:SETVAR AGSource AG-IDSVRINT-STG
:SETVAR AGDest AG-IDSRVINT2-STG
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest  <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 DelegatedAdministration
:SETVAR DB2 IdentityServerINT
:SETVAR DB3 IdentityServerSelfServiceINT
:SETVAR DB4 IdentityServerUsersINT

-- run backup on AWS side :
:CONNECT $(ListenerDest)
use master 
go
backup database DelegatedAdministration to disk = '\T:\backup_no_delete\DelegatedAdministration_01292024.bak' with stats=10
backup database IdentityServerINT to disk = 'T:\backup_no_delete\IdentityServerINT_01292024.bak' with stats=10
backup database IdentityServerSelfServiceINT to disk = 'T:\backup_no_delete\IdentityServerSelfServiceINT_01292024.bak' with stats=10
backup database IdentityServerUsersINT to disk = 'T:\backup_no_delete\IdentityServerUsersINT_01292024.bak' with stats=10


:SETVAR AGSource AG-IDSVRINT-STG
:SETVAR AGDest AG-IDSRVINT2-STG
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest  <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 DelegatedAdministration
:SETVAR DB2 IdentityServerINT
:SETVAR DB3 IdentityServerSelfServiceINT
:SETVAR DB4 IdentityServerUsersINT

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

:SETVAR AGSource AG-IDSVRINT-STG
:SETVAR AGDest AG-IDSRVINT2-STG
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest  <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 DelegatedAdministration
:SETVAR DB2 IdentityServerINT
:SETVAR DB3 IdentityServerSelfServiceINT
:SETVAR DB4 IdentityServerUsersINT

:CONNECT $(ListenerDest)
use master
go
print ('Ensure there is no DBs in the FORWARDER')
select * from sys.databases where name in ('$(DB1)','$(DB2)','$(DB3)','$(DB4)')
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
:SETVAR AGSource AG-IDSVRINT-STG
:SETVAR AGDest AG-IDSRVINT2-STG
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest  <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 DelegatedAdministration
:SETVAR DB2 [IdentityServerINT]
:SETVAR DB3 [IdentityServerSelfServiceINT]
:SETVAR DB4 [IdentityServerUsersINT]

:CONNECT $(ListenerDest)
print('Run Restore on Forwarder')
use master
go

-- doing restore
-- before you run it , run transacion backup log on padbstg01
USE [master];     
GO
RESTORE DATABASE [IdentityServerINT]  FROM  URL = N'S3://<<s3_bucket>>/STG/DBStgClust01$AG-IDSVRINT-STG/IdentityServerINT/FULL_COPY_ONLY/DBStgClust01$AG-IDSVRINT-STG_IdentityServerINT_FULL_COPY_ONLY_20250127_222953.bak'  
WITH  CREDENTIAL = N's3://<<s3_bucket>>/Prod', 
REPLACE,NORECOVERY,  NOUNLOAD,  STATS = 5, 
MOVE 'IdentityServerINT' TO 'D:\MSSQL\DATA\IdentityServerINT.mdf' ,
MOVE  'IdentityServerINT_log' TO 'L:\MSSQL\DATA\IdentityServerINT_log.ldf'
GO
RESTORE LOG [IdentityServerINT] FROM URL = N'S3://<<s3_bucket>>/STG/DBStgClust01$AG-IDSVRINT-STG/IdentityServerINT/LOG/DBStgClust01$AG-IDSVRINT-STG_IdentityServerINT_LOG_20250128_153004.trn' 
WITH CREDENTIAL = N's3://<<s3_bucket>>/Prod', 
NORECOVERY,  NOUNLOAD,  STATS = 10
GO


USE [master];     
RESTORE DATABASE [IdentityServerSelfServiceINT]  FROM  URL = N'S3://<<s3_bucket>>/STG/DBStgClust01$AG-IDSVRINT-STG/IdentityServerSelfServiceINT/FULL_COPY_ONLY/DBStgClust01$AG-IDSVRINT-STG_IdentityServerSelfServiceINT_FULL_COPY_ONLY_20250127_223024.bak'  
WITH  CREDENTIAL = N's3://<<s3_bucket>>/Prod', 
REPLACE, NORECOVERY,  NOUNLOAD,  STATS = 5, 
MOVE 'IdentityServerSelfServiceINT' TO 'D:\MSSQL\DATA\IdentityServerSelfServiceINT.mdf' ,
MOVE 'IdentityServerSelfServiceINT_log' TO 'L:\MSSQL\DATA\IdentityServerSelfServiceINT_log.ldf'
GO

RESTORE LOG [IdentityServerSelfServiceINT] FROM URL = N'S3://<<s3_bucket>>/STG/DBStgClust01$AG-IDSVRINT-STG/IdentityServerSelfServiceINT/LOG/DBStgClust01$AG-IDSVRINT-STG_IdentityServerSelfServiceINT_LOG_20250128_153028.trn' 
WITH CREDENTIAL = N's3://<<s3_bucket>>/Prod', 
NORECOVERY,  NOUNLOAD,  STATS = 10

USE [master];     
RESTORE DATABASE [IdentityServerUsersINT]  FROM  URL = N'S3://<<s3_bucket>>/STG/DBStgClust01$AG-IDSVRINT-STG/IdentityServerUsersINT/FULL_COPY_ONLY/DBStgClust01$AG-IDSVRINT-STG_IdentityServerUsersINT_FULL_COPY_ONLY_20250127_223028.bak'  
WITH  CREDENTIAL = N's3://<<s3_bucket>>/Prod', 
REPLACE,NORECOVERY,  NOUNLOAD,  STATS = 5, 
MOVE 'IdentityServerUsersINT' TO 'D:\MSSQL\DATA\IdentityServerUsersINT.mdf',
MOVE  'IdentityServerUsersINT_log' TO 'L:\MSSQL\DATA\IdentityServerUsersINT_log.ldf'
GO

RESTORE LOG [IdentityServerUsersINT] FROM URL = N'S3://<<s3_bucket>>/STG/DBStgClust01$AG-IDSVRINT-STG/IdentityServerUsersINT/LOG/DBStgClust01$AG-IDSVRINT-STG_IdentityServerUsersINT_LOG_20250128_153053.trn' 
WITH CREDENTIAL = N's3://<<s3_bucket>>/Prod', 
NORECOVERY,  NOUNLOAD,  STATS = 10
GO

USE [master];     
RESTORE DATABASE [DelegatedAdministration]  FROM  URL = N'S3://<<s3_bucket>>/STG/DBStgClust01$AG-IDSVRINT-STG/DelegatedAdministration/FULL_COPY_ONLY/DBStgClust01$AG-IDSVRINT-STG_DelegatedAdministration_FULL_COPY_ONLY_20250127_222951.bak'  
WITH  CREDENTIAL = N's3://<<s3_bucket>>/Prod', 
REPLACE,NORECOVERY,  NOUNLOAD,  STATS = 5, 
MOVE 'DelegatedAdministration' TO 'D:\MSSQL\DATA\DelegatedAdministration.mdf' ,
MOVE 'DelegatedAdministration_log' TO 'L:\MSSQL\DATA\DelegatedAdministration_log.ldf'
GO

RESTORE LOG [DelegatedAdministration] FROM URL = N'S3://<<s3_bucket>>/STG/DBStgClust01$AG-IDSVRINT-STG/DelegatedAdministration/LOG/DBStgClust01$AG-IDSVRINT-STG_DelegatedAdministration_LOG_20250128_152942.trn' 
WITH CREDENTIAL = N's3://<<s3_bucket>>/Prod', 
NORECOVERY,  NOUNLOAD,  STATS = 10
GO

-- run on the primary forwarder
:SETVAR AGSource AG-IDSVRINT-STG
:SETVAR AGDest AG-IDSRVINT2-STG
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest  <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 DelegatedAdministration
:SETVAR DB2 IdentityServerINT
:SETVAR DB3 IdentityServerSelfServiceINT
:SETVAR DB4 IdentityServerUsersINT

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
:SETVAR AGSource AG-IDSVRINT-STG
:SETVAR AGDest AG-IDSRVINT2-STG
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest  <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 DelegatedAdministration
:SETVAR DB2 IdentityServerINT
:SETVAR DB3 IdentityServerSelfServiceINT
:SETVAR DB4 IdentityServerUsersINT

:CONNECT $(FORWARDER_SECONDARY)
USE [master];     
GO
RESTORE DATABASE [IdentityServerINT]  FROM  URL = N'S3://<<s3_bucket>>/STG/DBStgClust01$AG-IDSVRINT-STG/IdentityServerINT/FULL_COPY_ONLY/DBStgClust01$AG-IDSVRINT-STG_IdentityServerINT_FULL_COPY_ONLY_20250127_222953.bak'  
WITH  CREDENTIAL = N's3://<<s3_bucket>>/Prod', 
REPLACE,NORECOVERY,  NOUNLOAD,  STATS = 5, 
MOVE 'IdentityServerINT' TO 'D:\MSSQL\DATA\IdentityServerINT.mdf' ,
MOVE  'IdentityServerINT_log' TO 'L:\MSSQL\DATA\IdentityServerINT_log.ldf'
GO
RESTORE LOG [IdentityServerINT] FROM URL = N'S3://<<s3_bucket>>/STG/DBStgClust01$AG-IDSVRINT-STG/IdentityServerINT/LOG/DBStgClust01$AG-IDSVRINT-STG_IdentityServerINT_LOG_20250128_153004.trn' 
WITH CREDENTIAL = N's3://<<s3_bucket>>/Prod', 
NORECOVERY,  NOUNLOAD,  STATS = 10
GO


USE [master];     
RESTORE DATABASE [IdentityServerSelfServiceINT]  FROM  URL = N'S3://<<s3_bucket>>/STG/DBStgClust01$AG-IDSVRINT-STG/IdentityServerSelfServiceINT/FULL_COPY_ONLY/DBStgClust01$AG-IDSVRINT-STG_IdentityServerSelfServiceINT_FULL_COPY_ONLY_20250127_223024.bak'  
WITH  CREDENTIAL = N's3://<<s3_bucket>>/Prod', 
REPLACE, NORECOVERY,  NOUNLOAD,  STATS = 5, 
MOVE 'IdentityServerSelfServiceINT' TO 'D:\MSSQL\DATA\IdentityServerSelfServiceINT.mdf' ,
MOVE 'IdentityServerSelfServiceINT_log' TO 'L:\MSSQL\DATA\IdentityServerSelfServiceINT_log.ldf'
GO

RESTORE LOG [IdentityServerSelfServiceINT] FROM URL = N'S3://<<s3_bucket>>/STG/DBStgClust01$AG-IDSVRINT-STG/IdentityServerSelfServiceINT/LOG/DBStgClust01$AG-IDSVRINT-STG_IdentityServerSelfServiceINT_LOG_20250128_153028.trn' 
WITH CREDENTIAL = N's3://<<s3_bucket>>/Prod', 
NORECOVERY,  NOUNLOAD,  STATS = 10

USE [master];     
RESTORE DATABASE [IdentityServerUsersINT]  FROM  URL = N'S3://<<s3_bucket>>/STG/DBStgClust01$AG-IDSVRINT-STG/IdentityServerUsersINT/FULL_COPY_ONLY/DBStgClust01$AG-IDSVRINT-STG_IdentityServerUsersINT_FULL_COPY_ONLY_20250127_223028.bak'  
WITH  CREDENTIAL = N's3://<<s3_bucket>>/Prod', 
REPLACE,NORECOVERY,  NOUNLOAD,  STATS = 5, 
MOVE 'IdentityServerUsersINT' TO 'D:\MSSQL\DATA\IdentityServerUsersINT.mdf',
MOVE  'IdentityServerUsersINT_log' TO 'L:\MSSQL\DATA\IdentityServerUsersINT_log.ldf'
GO

RESTORE LOG [IdentityServerUsersINT] FROM URL = N'S3://<<s3_bucket>>/STG/DBStgClust01$AG-IDSVRINT-STG/IdentityServerUsersINT/LOG/DBStgClust01$AG-IDSVRINT-STG_IdentityServerUsersINT_LOG_20250128_153053.trn' 
WITH CREDENTIAL = N's3://<<s3_bucket>>/Prod', 
NORECOVERY,  NOUNLOAD,  STATS = 10
GO

USE [master];     
RESTORE DATABASE [DelegatedAdministration]  FROM  URL = N'S3://<<s3_bucket>>/STG/DBStgClust01$AG-IDSVRINT-STG/DelegatedAdministration/FULL_COPY_ONLY/DBStgClust01$AG-IDSVRINT-STG_DelegatedAdministration_FULL_COPY_ONLY_20250127_222951.bak'  
WITH  CREDENTIAL = N's3://<<s3_bucket>>/Prod', 
REPLACE,NORECOVERY,  NOUNLOAD,  STATS = 5, 
MOVE 'DelegatedAdministration' TO 'D:\MSSQL\DATA\DelegatedAdministration.mdf' ,
MOVE 'DelegatedAdministration_log' TO 'L:\MSSQL\DATA\DelegatedAdministration_log.ldf'
GO

RESTORE LOG [DelegatedAdministration] FROM URL = N'S3://<<s3_bucket>>/STG/DBStgClust01$AG-IDSVRINT-STG/DelegatedAdministration/LOG/DBStgClust01$AG-IDSVRINT-STG_DelegatedAdministration_LOG_20250128_152942.trn' 
WITH CREDENTIAL = N's3://<<s3_bucket>>/Prod', 
NORECOVERY,  NOUNLOAD,  STATS = 10
GO

WAITFOR DELAY '00:00:05';
go

:SETVAR AGSource AG-IDSVRINT-STG
:SETVAR AGDest AG-IDSRVINT2-STG
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest  <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 DelegatedAdministration
:SETVAR DB2 IdentityServerINT
:SETVAR DB3 IdentityServerSelfServiceINT
:SETVAR DB4 IdentityServerUsersINT

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



-- check that all sync in global, and forwarder in recovery/sync.
-- then run the failover dag on the forwarder


-------------------------------------------  FailOver DAG -------------------------------
:SETVAR AGSource AG-IDSVRINT-STG
:SETVAR AGDest AG-IDSRVINT2-STG
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest  <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 DelegatedAdministration
:SETVAR DB2 IdentityServerINT
:SETVAR DB3 IdentityServerSelfServiceINT
:SETVAR DB4 IdentityServerUsersINT

:CONNECT $(ListenerDest)
/*
use master
go
print('Failvoer DAG from forwarder')
ALTER AVAILABILITY GROUP [DAG_$(ListenerSource)-$(ListenerDest)] FORCE_FAILOVER_ALLOW_DATA_LOSS; 

*/
/*
---------------------------------------    DROP DAG ----------------------------------
:SETVAR AGSource AG-IDSVRINT-STG
:SETVAR AGDest AG-IDSRVINT2-STG
:SETVAR ListenerSource <<servername>>
:SETVAR ListenerDest  <<servername>>
:SETVAR FORWARDER_SECONDARY <<servername>>
:SETVAR DB1 DelegatedAdministration
:SETVAR DB2 IdentityServerINT
:SETVAR DB3 IdentityServerSelfServiceINT
:SETVAR DB4 IdentityServerUsersINT

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
*/

/*
------------------------     Upgrade Comptability level     ----------------------     
:CONNECT $(ListenerDest)
USE [master]
GO
print('Upgrade Comptability level')
ALTER DATABASE [$(DB1)] SET COMPATIBILITY_LEVEL = 160;
ALTER DATABASE [$(DB2)] SET COMPATIBILITY_LEVEL = 160;
ALTER DATABASE [$(DB3)] SET COMPATIBILITY_LEVEL = 160;
ALTER DATABASE [$(DB4)] SET COMPATIBILITY_LEVEL = 160;

*/


