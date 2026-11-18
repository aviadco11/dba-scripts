
-- tempdb consumption

use tempdb

declare @perc numeric(5,2), @version_store_size DECIMAL(25,2)
select @perc = cast(((SUM(allocated_extent_page_count)*1.0/128) / (SUM(total_page_count)*1.0/128)) * 100 as numeric(5,2)),
                                @version_store_size = CAST(SUM((version_store_reserved_page_count) * 8) / 1024. AS DECIMAL(25, 2))
FROM sys.dm_db_file_space_usage



SELECT getdate() as [collection_time],CAST(SUM((total_page_count) * 8) / 1024. AS DECIMAL(25, 2)) AS Total_Size_MB
                ,--Works on SQL 2012 and future editions
                CAST(SUM((unallocated_extent_page_count) * 8) / 1024. AS DECIMAL(25, 2)) AS Free_Space_MB
                ,CAST(SUM((user_object_reserved_page_count) * 8) / 1024. AS DECIMAL(25, 2)) AS User_Objects_MB
                ,CAST(SUM((internal_object_reserved_page_count) * 8) / 1024. AS DECIMAL(25, 2)) AS Internal_Objects_MB
                ,CAST(SUM((version_store_reserved_page_count) * 8) / 1024. AS DECIMAL(25, 2)) AS Version_Store_MB
                ,@perc as [PercentUsed(%)] 
FROM tempdb.sys.dm_db_file_space_usage
GO

