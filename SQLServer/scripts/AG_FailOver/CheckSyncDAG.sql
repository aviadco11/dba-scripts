
-- Run this query on the Global Primary and the forwarder
-- Check the results to see if synchronization_state_desc is SYNCHRONIZED, and the last_hardened_lsn is the same per database on both the global primary and       forwarder 
-- If not rerun the query on both side every 5 seconds until it is the case
-- to check sync on DAG

SELECT ag.name
       , drs.database_id
       , db_name(drs.database_id) as database_name
       , drs.group_id
       , drs.replica_id
       , drs.synchronization_state_desc
       , drs.last_hardened_lsn  
FROM sys.dm_hadr_database_replica_states drs 
INNER JOIN sys.availability_groups ag on drs.group_id = ag.group_id;


