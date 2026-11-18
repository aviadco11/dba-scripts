
-- Query to check Query Store size on each user database

DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql = @sql + 
    N'USE ' + QUOTENAME(name) + N';
    SELECT 
        ''' + name + N''' AS DatabaseName,
        actual_state_desc AS QueryStoreState,
        current_storage_size_mb AS CurrentSizeMB,
        max_storage_size_mb AS MaxSizeMB,
        CAST((current_storage_size_mb * 100.0 / NULLIF(max_storage_size_mb, 0)) AS DECIMAL(5,2)) AS PercentUsed
    FROM sys.database_query_store_options;
    '
FROM sys.databases
WHERE database_id > 4  -- Exclude system databases
    AND state_desc = 'ONLINE'
    AND name NOT IN ('tempdb');

EXEC sp_executesql @sql;

