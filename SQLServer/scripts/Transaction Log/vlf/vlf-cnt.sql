
SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#VLFInfo') IS NOT NULL DROP TABLE #VLFInfo;
CREATE TABLE #VLFInfo (DbName SYSNAME, VlfCount INT);

-- Loop through databases and pull VLF counts dynamically
EXEC sp_MSforeachdb N'
    USE [?];
    INSERT INTO #VLFInfo (DbName, VlfCount)
    SELECT DB_NAME(), COUNT(*) 
    FROM sys.dm_db_log_info(DB_ID());
';

-- Show me everything with more than 100 VLFs
SELECT DbName, VlfCount,
       'Action Required' = CASE 
           WHEN VlfCount > 500 THEN 'Critical: Schedule Shrink & Regrow immediately'
           WHEN VlfCount > 200 THEN 'Warning: Log file is becoming fragmented'
           ELSE 'Healthy' END
FROM #VLFInfo
WHERE VlfCount > 200
ORDER BY VlfCount DESC;


