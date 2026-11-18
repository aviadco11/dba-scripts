
-- ways to monitor space used

use tempdb
select db_name(mf.database_id) as DBName, total_page_count*8/1024 as SizeMB, allocated_extent_page_count*8/1024 as UsedMB, unallocated_extent_page_count*8/1024 as FreeMB, mf.physical_name, 
cast(cast (allocated_extent_page_count as float)/cast( total_page_count as float)*100 as decimal(4,2)) as [percentused(%)] ,version_store_reserved_page_count*8/1024 as VersionStore_usedMB, user_object_reserved_page_count*8/1024 as UserObjects_usedMB 
from sys.dm_db_file_space_usage dm
join sys.master_files mf
on dm.file_id = mf.file_id
where [name] like 'temp%'

DBCC SQLPERF('LOGSPACE')

select * from sys.master_files where name like 'temp%'

SELECT DB_NAME() AS DbName,
        name AS FileName, 
        type_desc,
        cast(size/128.0 as numeric(9,1)) AS CurrentSizeMB,  
        cast(size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT)/128.0 as numeric(9,1)) AS FreeSpaceMB,
                                cast(cast(CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT)/128.0 as numeric(9,1)) / cast(size/128.0 as numeric(9,1))*100 as numeric(9,1)) as [PercentUsed(%)] ,
                                dm.version_store_reserved_page_count*8/1024 as VersionStore_usedMB, dm.user_object_reserved_page_count*8/1024 as UserObjects_usedMB 
FROM sys.database_files df
left join sys.dm_db_file_space_usage dm
on df.file_id = dm.file_id
WHERE type IN (0,1);




-- Create a temporary table to hold the results
CREATE TABLE #TempLogSpace (
    DatabaseName VARCHAR(128),
    LogSizeMB FLOAT,
    LogSpaceUsedPercent FLOAT,
    Status INT
);

-- Insert the results of DBCC SQLPERF('LOGSPACE') into the temporary table
INSERT INTO #TempLogSpace (DatabaseName, LogSizeMB, LogSpaceUsedPercent, Status)
EXEC ('DBCC SQLPERF(''LOGSPACE'')');

-- Select from the temporary table to verify the results
SELECT * FROM #TempLogSpace order by LogSizeMB desc;

-- Drop the temporary table when done
DROP TABLE #TempLogSpace;


