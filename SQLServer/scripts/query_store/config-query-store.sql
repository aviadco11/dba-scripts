
-- configure query store for all user databases

DECLARE @sql NVARCHAR(MAX) = '';
DECLARE @dbName NVARCHAR(128);

DECLARE db_cursor CURSOR FOR
SELECT name
FROM sys.databases
WHERE database_id > 4  -- Exclude system databases
  AND state_desc = 'ONLINE'  -- Only online databases
  AND is_read_only = 0;  -- Exclude read-only databases

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @dbName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = '
    ALTER DATABASE ' + QUOTENAME(@dbName) + ' 
    SET QUERY_STORE = ON (
        OPERATION_MODE = READ_WRITE,
        CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30),
        DATA_FLUSH_INTERVAL_SECONDS = 900,
        MAX_STORAGE_SIZE_MB = 500,
        INTERVAL_LENGTH_MINUTES = 60,
        SIZE_BASED_CLEANUP_MODE = AUTO,
        QUERY_CAPTURE_MODE = AUTO,
        MAX_PLANS_PER_QUERY = 200,
        WAIT_STATS_CAPTURE_MODE = ON
    );';
    
    PRINT 'Enabling Query Store on database: ' + @dbName;
    EXEC sp_executesql @sql;
    
    FETCH NEXT FROM db_cursor INTO @dbName;
END;

CLOSE db_cursor;
DEALLOCATE db_cursor;

PRINT 'Query Store configuration completed for all user databases.';

