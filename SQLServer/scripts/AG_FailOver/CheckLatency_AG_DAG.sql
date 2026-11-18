
WITH Secondary_CTE ( ag_name, is_distributed, replica_server_name, DB, endpoint_url,availability_mode_desc,session_timeout,role_desc, connected_state_desc, 
     synchronization_health_desc,synchronization_state_desc, last_commit_time,log_send_queue_size,log_send_rate, redo_queue_size, redo_rate,
     last_commit_lsn,last_hardened_lsn,last_received_lsn,last_sent_lsn,last_redone_lsn,
      last_hardened_time,last_received_time,last_sent_time,last_redone_time
     )
AS
(
   SELECT ag1.[name], ag1.is_distributed, ar1.replica_server_name, dbs.[name] as 'DB', endpoint_url, availability_mode_desc, session_timeout,
        role_desc,connected_state_desc, ars1.synchronization_health_desc,drs1.synchronization_state_desc,
        drs1.last_commit_time, drs1.log_send_queue_size, drs1.log_send_rate,drs1.redo_queue_size, drs1.redo_rate,
        last_commit_lsn,last_hardened_lsn,last_received_lsn,last_sent_lsn,last_redone_lsn,
        last_hardened_time,last_received_time,last_sent_time,last_redone_time
   FROM sys.availability_groups ag1 
         JOIN sys.dm_hadr_database_replica_states drs1 ON drs1.group_id = ag1.group_id
         JOIN sys.dm_hadr_availability_replica_states ars1 ON ars1.replica_id = drs1.replica_id
         JOIN sys.availability_replicas ar1 ON ar1.replica_id = ars1.replica_id
         JOIN sys.databases dbs ON dbs.database_id = drs1.database_id
   WHERE 1=1 
         and ars1.role_desc != 'PRIMARY'
)
SELECT  
         --getdate() as Create_time, 
         Secondary_CTE.ag_name, Secondary_CTE.is_distributed, 
         ar.replica_server_name as pri_replica_server_name, 
         --ar.endpoint_url as Primary_EndPoint,
         Secondary_CTE.replica_server_name AS Sec_replica_server_name, dbs.[name] as DB, 
         --Secondary_CTE.endpoint_url as endpoint_url, Secondary_CTE.availability_mode_desc, 
         Secondary_CTE.role_desc, Secondary_CTE.session_timeout, Secondary_CTE.connected_state_desc, 
         Secondary_CTE.synchronization_health_desc,Secondary_CTE.synchronization_state_desc,
         --drs.last_commit_time as 'Pri_Last_commit_time', Secondary_CTE.last_commit_time 'Sec_Last_commit_time', 
         --datediff(ns,Secondary_CTE.last_commit_time, drs.last_commit_time) as 'lag_in_nanosec',
         datediff(ss,Secondary_CTE.last_commit_time,drs.last_commit_time) as 'lag_in_sec',
         Secondary_CTE.log_send_queue_size/1024 as log_send_queue_size_mb,
         Secondary_CTE.log_send_rate/1024 as log_send_rate_mb,
         Secondary_CTE.redo_queue_size/1024 as redo_queue_size_mb, 
         Secondary_CTE.redo_rate/1024 as redo_rate_mb,
         drs.last_commit_lsn as Pri_last_commit_lsn,
         Secondary_CTE.last_commit_lsn as Sec_last_commit_lsn,
         drs.last_hardened_lsn as Pri_last_hardened_lsn ,
         Secondary_CTE.last_hardened_lsn as Sec_last_hardened_lsn,
         --drs.last_received_lsn as Pri_last_received_lsn,
         Secondary_CTE.last_received_lsn as Sec_last_received_lsn,
         --drs.last_sent_lsn as Pri_last_sent_lsn,
         Secondary_CTE.last_sent_lsn as Sec_last_sent_lsn,
         --drs.last_redone_lsn as Pri_last_redone_lsn,
         Secondary_CTE.last_redone_lsn as Sec_last_redone_lsn,
         Secondary_CTE.last_hardened_time as Sec_last_hardened_time,
         Secondary_CTE.last_received_time as Sec_last_received_time,
         Secondary_CTE.last_sent_time as sec_last_sent_time,
         Secondary_CTE.last_redone_time as Sec_last_redone_time
FROM sys.availability_groups ag 
         JOIN sys.dm_hadr_database_replica_states drs ON drs.group_id = ag.group_id
         JOIN sys.dm_hadr_availability_replica_states ars ON ars.replica_id = drs.replica_id
         JOIN sys.availability_replicas ar ON ar.replica_id = ars.replica_id
         JOIN sys.databases dbs ON dbs.database_id = drs.database_id
         JOIN Secondary_CTE ON Secondary_CTE.DB = dbs.name 
  WHERE 1=1 
         and ars.role_desc = 'PRIMARY'
         --AND (Secondary_CTE.replica_server_name LIKE '%B')
         and dbs.name IN ('CosSystemLogs')
order by lag_in_sec desc


