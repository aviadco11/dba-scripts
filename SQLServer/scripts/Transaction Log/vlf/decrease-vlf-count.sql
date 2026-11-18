
DECLARE
                  @MinVLFCountForAlert int = 50
                , @RunRemediation varchar(10) = 'n'

SET NOCOUNT ON;

DECLARE @majorver int
SET @majorver = CONVERT(int, (@@microsoftversion / 0x1000000) & 0xff);

DECLARE @Results AS TABLE
(
DatabaseName sysname,
LogFileName sysname,
VLF_Count int,
LogSizeMB int,
PotentialSizeMB int,
PotentialVLFCount int,
LastLogBackup datetime NULL
);

IF OBJECT_ID('sys.dm_db_log_stats') IS NULL
BEGIN
--table variable to hold results  
 DECLARE @vlfcounts AS TABLE(dbname SYSNAME,VLF_Count INT);
DECLARE @dbccloginfo AS TABLE
(  
  RecoveryUnitId INT NULL, 
  fileid  SMALLINT NULL,  
  file_size BIGINT NULL,  
  start_offset BIGINT NULL,  
  fseqno  INT NULL,  
  [status] TINYINT NULL,  
  parity  TINYINT NULL,  
  create_lsn NUMERIC(25,0) NULL
)

DECLARE @dbname SYSNAME,@query NVARCHAR(1000),@count_VLF INT;
DECLARE minor_crsr
CURSOR LOCAL FAST_FORWARD
FOR
SELECT [name]
FROM sys.databases
WHERE database_id > 4
AND [state] = 0 AND is_read_only = 0;

SET @query = 'DBCC LOGINFO (@dbname) WITH NO_INFOMSGS'

OPEN minor_crsr;
FETCH NEXT FROM minor_crsr INTO @dbname;
  
WHILE @@FETCH_STATUS = 0
BEGIN
  IF @majorver < 11
  BEGIN
   INSERT @dbccloginfo
   (fileid, file_size, start_offset, fseqno, [status], parity, create_lsn)
   EXEC sp_executesql @query, N'@dbname sysname', @dbname
   SET @count_VLF = @@ROWCOUNT;
  END
  ELSE
  BEGIN
   INSERT @dbccloginfo
   EXEC sp_executesql @query, N'@dbname sysname', @dbname
   SET @count_VLF = @@ROWCOUNT;
  END

  INSERT @vlfcounts 
  VALUES(@dbname,@count_VLF);

  FETCH NEXT FROM minor_crsr INTO @dbname;
END

CLOSE minor_crsr;  
DEALLOCATE minor_crsr;  
 
INSERT INTO @Results
SELECT dbname AS DatabaseName
, mf.name AS LogFileName
, VLF_Count
, LogSizeMB = m.size_mb
, PotentialSizeMB = iter.potsize
, potential.PotentialVLFCount
, LastLogBackup = (SELECT MAX(bu.backup_start_date) FROM msdb.dbo.backupset AS bu WHERE bu.database_name = dbname AND bu.type IN ('L','D'))
FROM @vlfcounts
INNER JOIN sys.master_files AS mf
ON mf.database_id = DB_ID(dbname) AND mf.type_desc = 'LOG'
CROSS APPLY (SELECT mf.size / 128) AS m(size_mb)
CROSS APPLY (
                SELECT n_iter = NULLIF((SELECT CASE WHEN m.size_mb <= 64 THEN 1
                                                WHEN m.size_mb > 64 AND m.size_mb < 256 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/256, 0)
                                                WHEN m.size_mb >= 256 AND m.size_mb < 1024 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/512, 0)
                                                WHEN m.size_mb >= 1024 AND m.size_mb < 4096 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/1024, 0)
                                                WHEN m.size_mb >= 4096 AND m.size_mb < 8192 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/2048, 0)
                                                WHEN m.size_mb >= 8192 AND m.size_mb < 16384 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/4096, 0)
                                                WHEN m.size_mb >= 16384 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/8192, 0)
                                                END), 0)
                , potsize = (SELECT CASE WHEN m.size_mb <= 64 THEN 1*64
                                                WHEN m.size_mb > 64 AND m.size_mb < 256 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/256, 0)*256
                                                WHEN m.size_mb >= 256 AND m.size_mb < 1024 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/512, 0)*512
                                                WHEN m.size_mb >= 1024 AND m.size_mb < 4096 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/1024, 0)*1024
                                                WHEN m.size_mb >= 4096 AND m.size_mb < 8192 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/2048, 0)*2048
                                                WHEN m.size_mb >= 8192 AND m.size_mb < 16384 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/4096, 0)*4096
                                                WHEN m.size_mb >= 16384 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/8192, 0)*8192
                                                END)
                WHERE @majorver >= 11

                UNION ALL

                SELECT n_iter = NULLIF((SELECT CASE WHEN m.size_mb <= 64 THEN 1
                                                WHEN m.size_mb > 64 AND m.size_mb < 256 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/256, 0)
                                                WHEN m.size_mb >= 256 AND m.size_mb < 1024 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/512, 0)
                                                WHEN m.size_mb >= 1024 AND m.size_mb < 4096 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/1024, 0)
                                                WHEN m.size_mb >= 4096 AND m.size_mb < 8192 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/2048, 0)
                                                WHEN m.size_mb >= 8192 AND m.size_mb < 16384 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/4000, 0)
                                                WHEN m.size_mb >= 16384 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/8000, 0)
                                                END), 0)
                , potsize = (SELECT CASE WHEN m.size_mb <= 64 THEN 1*64
                                                WHEN m.size_mb > 64 AND m.size_mb < 256 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/256, 0)*256
                                                WHEN m.size_mb >= 256 AND m.size_mb < 1024 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/512, 0)*512
                                                WHEN m.size_mb >= 1024 AND m.size_mb < 4096 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/1024, 0)*1024
                                                WHEN m.size_mb >= 4096 AND m.size_mb < 8192 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/2048, 0)*2048
                                                WHEN m.size_mb >= 8192 AND m.size_mb < 16384 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/4000, 0)*4000
                                                WHEN m.size_mb >= 16384 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/8000, 0)*8000
                                                END)
                WHERE @majorver < 11
) AS iter
CROSS APPLY (SELECT PotentialVLFCount = CASE WHEN iter.potsize <= 64 THEN (iter.potsize/(iter.potsize/iter.n_iter))*4
                                                WHEN iter.potsize > 64 AND iter.potsize < 1024 THEN (iter.potsize/(iter.potsize/iter.n_iter))*8
                                                WHEN iter.potsize >= 1024 THEN (iter.potsize/(iter.potsize/iter.n_iter))*16
                                                END) AS potential
WHERE VLF_Count > @MinVLFCountForAlert
AND VLF_Count > potential.PotentialVLFCount
END
ELSE
BEGIN 

INSERT INTO @Results
SELECT d.[name] AS DatabaseName
, mf.name AS LogFileName
, VLF_Count = vlf.total_vlf_count
, LogSizeMB = m.size_mb
, PotentialSizeMB = iter.potsize
, potential.PotentialVLFCount
, LastLogBackup = vlf.log_backup_time
FROM sys.databases d
CROSS APPLY sys.dm_db_log_stats(d.database_id) AS vlf
INNER JOIN sys.master_files AS mf
ON mf.database_id = d.database_id AND mf.type_desc = 'LOG'
CROSS APPLY (SELECT mf.size / 128) AS m(size_mb)
CROSS APPLY (
                SELECT n_iter = NULLIF((SELECT CASE WHEN m.size_mb <= 64 THEN 1
                                                WHEN m.size_mb > 64 AND m.size_mb < 256 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/256, 0)
                                                WHEN m.size_mb >= 256 AND m.size_mb < 1024 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/512, 0)
                                                WHEN m.size_mb >= 1024 AND m.size_mb < 4096 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/1024, 0)
                                                WHEN m.size_mb >= 4096 AND m.size_mb < 8192 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/2048, 0)
                                                WHEN m.size_mb >= 8192 AND m.size_mb < 16384 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/4096, 0)
                                                WHEN m.size_mb >= 16384 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/8192, 0)
                                                END), 0)
                , potsize = (SELECT CASE WHEN m.size_mb <= 64 THEN 1*64
                                                WHEN m.size_mb > 64 AND m.size_mb < 256 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/256, 0)*256
                                                WHEN m.size_mb >= 256 AND m.size_mb < 1024 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/512, 0)*512
                                                WHEN m.size_mb >= 1024 AND m.size_mb < 4096 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/1024, 0)*1024
                                                WHEN m.size_mb >= 4096 AND m.size_mb < 8192 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/2048, 0)*2048
                                                WHEN m.size_mb >= 8192 AND m.size_mb < 16384 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/4096, 0)*4096
                                                WHEN m.size_mb >= 16384 THEN ROUND(CONVERT(FLOAT, ROUND(m.size_mb, -2))/8192, 0)*8192
                                                END)
) AS iter
CROSS APPLY (SELECT PotentialVLFCount = CASE WHEN iter.potsize <= 64 THEN (iter.potsize/(iter.potsize/iter.n_iter))*4
                                                WHEN iter.potsize > 64 AND iter.potsize < 1024 THEN (iter.potsize/(iter.potsize/iter.n_iter))*8
                                                WHEN iter.potsize >= 1024 THEN (iter.potsize/(iter.potsize/iter.n_iter))*16
                                                END) AS potential
WHERE d.database_id > 4
AND d.[state] = 0 AND d.is_read_only = 0
AND vlf.total_vlf_count > @MinVLFCountForAlert
AND vlf.total_vlf_count > potential.PotentialVLFCount
OPTION (RECOMPILE);
END

-- Output remediation commands with PRINT timestamps, no GO, CHAR(10) for proper line breaks in SSMS grid copy
SELECT *
, RemediationCmd =
      N'PRINT CONVERT(varchar(23), GETDATE(), 121) + '' - STARTING BACKUP LOG'';' + CHAR(10)
    + N'BACKUP LOG ' + QUOTENAME(DatabaseName)
    + N' TO DISK = N''C:\temp\' + DatabaseName + N'_log.trn'' WITH COMPRESSION;' + CHAR(10)
    + N'PRINT CONVERT(varchar(23), GETDATE(), 121) + '' - COMPLETE BACKUP LOG'';' + CHAR(10)
    + N'USE ' + QUOTENAME(DatabaseName) + N';' + CHAR(10)
    + N'PRINT CONVERT(varchar(23), GETDATE(), 121) + '' - STARTING SHRINK LOG'';' + CHAR(10)
    + N'DBCC SHRINKFILE (N' + QUOTENAME(LogFileName, '''') + N' , 0, TRUNCATEONLY) WITH NO_INFOMSGS;' + CHAR(10)
    + N'PRINT CONVERT(varchar(23), GETDATE(), 121) + '' - COMPLETE SHRINK LOG'';' + CHAR(10)
    + N'USE [master];' + CHAR(10)
    + N'PRINT CONVERT(varchar(23), GETDATE(), 121) + '' - STARTING MODIFY SIZE LOG FILE'';' + CHAR(10)
    + N'ALTER DATABASE ' + QUOTENAME(DatabaseName)
    + N' MODIFY FILE ( NAME = N' + QUOTENAME(LogFileName, '''')
    + N', SIZE = ' + CONVERT(nvarchar(max),PotentialSizeMB) + N'MB );' + CHAR(10)
    + N'PRINT CONVERT(varchar(23), GETDATE(), 121) + '' - COMPLETE MODIFY SIZE LOG FILE'';' + CHAR(10)
    + N'USE [master];' + CHAR(10)
    + N'ALTER DATABASE ' + QUOTENAME(DatabaseName)
    + N' MODIFY FILE ( NAME = N' + QUOTENAME(LogFileName, '''')
    + N', FILEGROWTH = 1048576KB );'
FROM @Results;

DECLARE @CurrDB sysname, @CurrLogFileName sysname, @PotentialSizeMB int, @CMD nvarchar(max), @ErrMsg nvarchar(4000);

DECLARE Logs CURSOR
LOCAL FAST_FORWARD
FOR
SELECT DatabaseName, LogFileName, PotentialSizeMB
FROM @Results

OPEN Logs

IF LEFT(@RunRemediation, 1) = 'Y'
BEGIN
        -- ============================================================
        -- EXECUTE MODE
        -- ============================================================
        WHILE 1=1
        BEGIN
                FETCH NEXT FROM Logs INTO @CurrDB, @CurrLogFileName, @PotentialSizeMB
                IF @@FETCH_STATUS <> 0 BREAK;

                BEGIN TRY
                                PRINT N'============================================================';
                                PRINT CONVERT(varchar(23), GETDATE(), 121) + N' - [' + @CurrDB + N'] STARTING REMEDIATION';
                                PRINT N'============================================================';

                                -- ============================================================
                                -- Batch 1: BACKUP LOG
                                -- ============================================================
                                SET @CMD = N'BACKUP LOG ' + QUOTENAME(@CurrDB)
                                         + N' TO DISK = N''C:\temp\' + @CurrDB + N'_log.trn'''
                                         + N' WITH COMPRESSION;'

                                PRINT N'------------------------------------------------------------';
                                PRINT CONVERT(varchar(23), GETDATE(), 121) + N' - [' + @CurrDB + N'] STEP 1/4 STARTING - BACKUP LOG';
                                PRINT @CMD;
                                EXEC(@CMD);
                                PRINT CONVERT(varchar(23), GETDATE(), 121) + N' - [' + @CurrDB + N'] STEP 1/4 COMPLETED - BACKUP LOG';
                                PRINT N'------------------------------------------------------------';

                                -- ============================================================
                                -- Batch 2: DBCC SHRINKFILE
                                -- ============================================================
                                SET @CMD = N'USE ' + QUOTENAME(@CurrDB) + N';' + CHAR(10)
                                         + N'DBCC SHRINKFILE (N' + QUOTENAME(@CurrLogFileName, '''') + N' , 0, TRUNCATEONLY) WITH NO_INFOMSGS;'

                                PRINT N'------------------------------------------------------------';
                                PRINT CONVERT(varchar(23), GETDATE(), 121) + N' - [' + @CurrDB + N'] STEP 2/4 STARTING - SHRINK LOG';
                                PRINT @CMD;
                                EXEC(@CMD);
                                PRINT CONVERT(varchar(23), GETDATE(), 121) + N' - [' + @CurrDB + N'] STEP 2/4 COMPLETED - SHRINK LOG';
                                PRINT N'------------------------------------------------------------';

                                -- ============================================================
                                -- Batch 3: ALTER DATABASE MODIFY SIZE
                                -- ============================================================
                                SET @CMD = N'USE [master];' + CHAR(10)
                                         + N'ALTER DATABASE ' + QUOTENAME(@CurrDB)
                                         + N' MODIFY FILE ( NAME = N' + QUOTENAME(@CurrLogFileName, '''')
                                         + N', SIZE = ' + CONVERT(nvarchar(max),@PotentialSizeMB) + N'MB );'

                                PRINT N'------------------------------------------------------------';
                                PRINT CONVERT(varchar(23), GETDATE(), 121) + N' - [' + @CurrDB + N'] STEP 3/4 STARTING - MODIFY SIZE LOG FILE';
                                PRINT @CMD;
                                EXEC(@CMD);
                                PRINT CONVERT(varchar(23), GETDATE(), 121) + N' - [' + @CurrDB + N'] STEP 3/4 COMPLETED - MODIFY SIZE LOG FILE';
                                PRINT N'------------------------------------------------------------';

                                -- ============================================================
                                -- Batch 4: ALTER DATABASE MODIFY FILEGROWTH
                                -- ============================================================
                                SET @CMD = N'USE [master];' + CHAR(10)
                                         + N'ALTER DATABASE ' + QUOTENAME(@CurrDB)
                                         + N' MODIFY FILE ( NAME = N' + QUOTENAME(@CurrLogFileName, '''')
                                         + N', FILEGROWTH = 1048576KB );'

                                PRINT N'------------------------------------------------------------';
                                PRINT CONVERT(varchar(23), GETDATE(), 121) + N' - [' + @CurrDB + N'] STEP 4/4 STARTING - MODIFY FILEGROWTH LOG FILE';
                                PRINT @CMD;
                                EXEC(@CMD);
                                PRINT CONVERT(varchar(23), GETDATE(), 121) + N' - [' + @CurrDB + N'] STEP 4/4 COMPLETED - MODIFY FILEGROWTH LOG FILE';
                                PRINT N'------------------------------------------------------------';

                                PRINT N'============================================================';
                                PRINT CONVERT(varchar(23), GETDATE(), 121) + N' - [' + @CurrDB + N'] ALL STEPS COMPLETED SUCCESSFULLY';
                                PRINT N'============================================================';
                END TRY
                BEGIN CATCH
                                SET @ErrMsg = ERROR_MESSAGE();
                                PRINT CONVERT(varchar(23), GETDATE(), 121) + N' - [' + @CurrDB + N'] ERROR: ' + @ErrMsg;
                END CATCH
        END
END
ELSE
BEGIN
        -- ============================================================
        -- DRY RUN MODE (@RunRemediation = 'n') - print only, no execution
        -- ============================================================
        WHILE 1=1
        BEGIN
                FETCH NEXT FROM Logs INTO @CurrDB, @CurrLogFileName, @PotentialSizeMB
                IF @@FETCH_STATUS <> 0 BREAK;

                PRINT N'============================================================';
                PRINT CONVERT(varchar(23), GETDATE(), 121) + N' - [' + @CurrDB + N'] DRY RUN - Commands that would be executed:';
                PRINT N'============================================================';

                -- Batch 1: BACKUP LOG
                SET @CMD = N'BACKUP LOG ' + QUOTENAME(@CurrDB)
                         + N' TO DISK = N''C:\temp\' + @CurrDB + N'_log.trn'''
                         + N' WITH COMPRESSION;'
                PRINT N'------------------------------------------------------------';
                PRINT CONVERT(varchar(23), GETDATE(), 121) + N' - [' + @CurrDB + N'] STEP 1/4 - BACKUP LOG';
                PRINT @CMD;
                PRINT N'------------------------------------------------------------';

                -- Batch 2: DBCC SHRINKFILE
                SET @CMD = N'USE ' + QUOTENAME(@CurrDB) + N';' + CHAR(10)
                         + N'DBCC SHRINKFILE (N' + QUOTENAME(@CurrLogFileName, '''') + N' , 0, TRUNCATEONLY) WITH NO_INFOMSGS;'
                PRINT N'------------------------------------------------------------';
                PRINT CONVERT(varchar(23), GETDATE(), 121) + N' - [' + @CurrDB + N'] STEP 2/4 - SHRINK LOG';
                PRINT @CMD;
                PRINT N'------------------------------------------------------------';

                -- Batch 3: ALTER DATABASE MODIFY SIZE
                SET @CMD = N'USE [master];' + CHAR(10)
                         + N'ALTER DATABASE ' + QUOTENAME(@CurrDB)
                         + N' MODIFY FILE ( NAME = N' + QUOTENAME(@CurrLogFileName, '''')
                         + N', SIZE = ' + CONVERT(nvarchar(max),@PotentialSizeMB) + N'MB );'
                PRINT N'------------------------------------------------------------';
                PRINT CONVERT(varchar(23), GETDATE(), 121) + N' - [' + @CurrDB + N'] STEP 3/4 - MODIFY SIZE LOG FILE';
                PRINT @CMD;
                PRINT N'------------------------------------------------------------';

                -- Batch 4: ALTER DATABASE MODIFY FILEGROWTH
                SET @CMD = N'USE [master];' + CHAR(10)
                         + N'ALTER DATABASE ' + QUOTENAME(@CurrDB)
                         + N' MODIFY FILE ( NAME = N' + QUOTENAME(@CurrLogFileName, '''')
                         + N', FILEGROWTH = 1048576KB );'
                PRINT N'------------------------------------------------------------';
                PRINT CONVERT(varchar(23), GETDATE(), 121) + N' - [' + @CurrDB + N'] STEP 4/4 - MODIFY FILEGROWTH LOG FILE';
                PRINT @CMD;
                PRINT N'------------------------------------------------------------';

                PRINT N'============================================================';
                PRINT CONVERT(varchar(23), GETDATE(), 121) + N' - [' + @CurrDB + N'] DRY RUN COMPLETED - No commands were executed';
                PRINT N'============================================================';
        END
END

CLOSE Logs;
DEALLOCATE Logs;


