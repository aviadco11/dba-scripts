
-- The following query can be used to determine space consumed in tempdb, 
-- by version store of each database in a SQL Server instance
SELECT 
  DB_NAME(database_id) as 'Database Name',
  reserved_page_count,
  reserved_space_kb 
FROM sys.dm_tran_version_store_space_usage;

