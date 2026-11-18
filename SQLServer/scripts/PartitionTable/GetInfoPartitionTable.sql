
-- script to check what the partition tables in DB
exec sp_msforeachdb '
use [?];  
if (select count(distinct t.name)
from sys.partitions p
inner join sys.tables t
on p.object_id = t.object_id
where p.partition_number <> 1) > 0'


-- script to GET Parition tables info in DB
SELECT 
      CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(p.object_id)), N'.', QUOTENAME(OBJECT_NAME(p.object_id))) AS ObjectName 
    , i.name AS IndexName
    , p.index_id AS IndexID 
    , ds.name AS PartitionScheme 
    , p.partition_number AS PartitionNumber 
    , fg.name AS FileGroupName 
    , prv_left.value AS LowerBoundaryValue 
    , prv_right.value AS UpperBoundaryValue 
    , CASE pf.boundary_value_on_right WHEN 1 THEN 'RIGHT' ELSE 'LEFT' END AS PartitionFunctionRange 
    , p.rows AS Rows
--  , pst.used_page_count AS UsedPages,
--  , pst.used_page_count * 8 AS UsedSpaceKB,
--  , pst.reserved_page_count as ReservedPages,
--  , pst.reserved_page_count * 8 as ReservedSpaceKB
FROM
    sys.partitions AS p 
    --INNER JOIN sys.dm_db_partition_stats AS pst ON p.partition_id = pst.partition_id
    INNER JOIN sys.indexes AS i ON i.[object_id] = p.[object_id] AND i.index_id = p.index_id
    INNER JOIN sys.data_spaces AS ds ON ds.data_space_id = i.data_space_id
    INNER JOIN sys.partition_schemes AS ps ON ps.data_space_id = ds.data_space_id
    INNER JOIN sys.partition_functions AS pf ON pf.function_id = ps.function_id
    INNER JOIN sys.destination_data_spaces AS dds2 ON dds2.partition_scheme_id = ps.data_space_id AND dds2.destination_id = p.partition_number
    INNER JOIN sys.filegroups AS fg ON fg.data_space_id = dds2.data_space_id
    LEFT OUTER JOIN sys.partition_range_values AS prv_left ON ps.function_id = prv_left.function_id AND prv_left.boundary_id = p.partition_number - 1
    LEFT OUTER JOIN sys.partition_range_values AS prv_right ON ps.function_id = prv_right.function_id AND prv_right.boundary_id = p.partition_number
where i.name like '%PK%' and prv_right.value is null
ORDER BY
p.partition_number desc


