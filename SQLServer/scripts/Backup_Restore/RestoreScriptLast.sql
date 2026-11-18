
--RUN ON PRIMARY BUT EXECUTE COMMANDS ON SECONDARY
DROP TABLE IF EXISTS #Backups;

------------------------------------------------------------------------------------------- 
--Most Recent Database Backup for Each Database - Detailed 
------------------------------------------------------------------------------------------- 
SELECT  
   --A.[Server],  
   A.database_name,
   B.backup_start_date,
   A.last_db_backup_date,  
   --B.physical_device_name,
   CONCAT('USE [master];', '
   RESTORE DATABASE ' , QUOTENAME(A.database_name), '
FROM  DISK = ',  'N''', B.physical_device_name, '''','
WITH FILE = 1, NORECOVERY,  NOUNLOAD,  STATS = 5') RESTORE_SQL
INTO #Backups
FROM 
   ( 
   SELECT   
      CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server, 
      msdb.dbo.backupset.database_name,  
      MAX(msdb.dbo.backupset.backup_finish_date) AS last_db_backup_date 
   FROM 
      msdb.dbo.backupmediafamily  
      INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id  
   WHERE 
      msdb..backupset.type = 'D' 
   GROUP BY 
      msdb.dbo.backupset.database_name  
   ) AS A 
   LEFT JOIN  
   ( 
   SELECT   
      CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server, 
      msdb.dbo.backupset.database_name,  
      msdb.dbo.backupset.backup_start_date,  
      msdb.dbo.backupset.backup_finish_date, 
      msdb.dbo.backupset.expiration_date, 
      msdb.dbo.backupset.backup_size,  
      msdb.dbo.backupmediafamily.logical_device_name,  
      msdb.dbo.backupmediafamily.physical_device_name,   
      msdb.dbo.backupset.name AS backupset_name, 
      msdb.dbo.backupset.description 
   FROM 
      msdb.dbo.backupmediafamily  
      INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id  
   WHERE 
      msdb..backupset.type = 'D' 
   ) AS B 
   ON A.[server] = B.[server] AND A.[database_name] = B.[database_name] AND A.[last_db_backup_date] = B.[backup_finish_date] 
   WHERE A.database_name LIKE 'COS%'
ORDER BY  
   A.database_name

 
SELECT * FROM #Backups

;WITH LOGS 
AS
(
                SELECT              s.Database_name
                      , s.backup_start_date
                                  ,ROW_NUMBER() OVER (PARTITION BY s.database_name ORDER BY s.database_name, S.backup_start_date) AS Rownum
                                  , 'restore LOG [' + b.database_name + '] FROM  DISK = N''' + m.physical_device_name + ''' WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 10;' AS RESTORE_LOG
                FROM msdb.dbo.backupset s join msdb.dbo.backupmediafamily m on s.media_set_id=m.media_set_id
                JOIN #Backups B
                                ON s.database_name = B.Database_name
                WHERE s.backup_start_date >= B.backup_start_date
                and s.type = 'L'     
) 
SELECT LOGS.database_name
      ,LOGS.backup_start_date
      ,LOGS.RESTORE_LOG 
FROM LOGS 
ORDER BY LOGS.database_name
        ,LOGS.backup_start_date

