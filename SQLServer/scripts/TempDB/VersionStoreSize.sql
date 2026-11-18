
-- check version store size

USE tempdb

SELECT SUM (version_store_reserved_page_count) AS Version_Store_Reserved
FROM sys.dm_db_file_space_usage


SELECT CAST(SUM((total_page_count) * 8) / 1024. AS DECIMAL(25, 2)) AS Total_Size_MB
                ,CAST(SUM((version_store_reserved_page_count) * 8) / 1024. AS DECIMAL(25, 2)) AS Version_Store_MB

FROM tempdb.sys.dm_db_file_space_usage
GO

SELECT CAST(SUM((total_page_count) * 8) / 1024. AS DECIMAL(25, 2)) AS Total_Size_MB
                ,--Works on SQL 2012 and future editions
                CAST(SUM((unallocated_extent_page_count) * 8) / 1024. AS DECIMAL(25, 2)) AS Free_Space_MB
                ,CAST(SUM((user_object_reserved_page_count) * 8) / 1024. AS DECIMAL(25, 2)) AS User_Objects_MB
                ,CAST(SUM((internal_object_reserved_page_count) * 8) / 1024. AS DECIMAL(25, 2)) AS Internal_Objects_MB
                ,CAST(SUM((version_store_reserved_page_count) * 8) / 1024. AS DECIMAL(25, 2)) AS Version_Store_MB
                ,CAST(SUM((mixed_extent_page_count) * 8) / 1024. AS DECIMAL(25, 2)) AS Mixed_Extent_MB
FROM tempdb.sys.dm_db_file_space_usage
GO

SELECT * FROM sys.dm_os_performance_counters WHERE counter_name IN ( 'Longest Transaction Running Time' ,'Version Store Size (KB)' ,'Version Cleanup rate (KB/s)' ,'Version Generation rate (KB/s)' )


