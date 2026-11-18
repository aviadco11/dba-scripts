
-- get all tempdb size used by each db

EXEC sp_msforeachdb '
IF ''?'' NOT IN (''master'', ''model'', ''msdb'', ''tempdb'')
BEGIN
    USE [?];
    SELECT 
        DB_NAME(database_id) AS DatabaseName,
        SUM(user_object_reserved_page_count) * 8 / 1024 AS UserObjectsMB,
        SUM(internal_object_reserved_page_count) * 8 / 1024 AS InternalObjectsMB,
        SUM(version_store_reserved_page_count) * 8 / 1024 AS VersionStoreMB,
        SUM(unallocated_extent_page_count) * 8 / 1024 AS UnallocatedSpaceMB,
        SUM(mixed_extent_page_count) * 8 / 1024 AS MixedExtentsMB
    FROM tempdb.sys.dm_db_file_space_usage
    GROUP BY database_id;
END
';

