

-- script to check AG 
select * from sys.dm_hadr_database_replica_states where group_id = 'B8E616A6-A118-F23C-D9DE-759FEFBA54EF'


select * from sys.dm_hadr_availability_replica_states where group_id = 'B8E616A6-A118-F23C-D9DE-759FEFBA54EF'
select * from sys.availability_replicas



-- main script to check Health AG
SELECT *,
                    ag.name  AS [Dist AG Name],
                                ar.replica_server_name [AG Name],
                                DB_NAME(drs.database_id) AS database_name,  --DONT ASK WHY JUST ACCEPT THAT IT NEEDS TO COME THIS WAY OTHER TABLE IS OUTER JOIN
                                ars.connected_state_desc,
                                CASE ars.role_desc 
                                   WHEN 'PRIMARY' THEN   'Global Primary'
                                   WHEN 'SECONDARY' THEN 'DAG Secondary'
                                   ELSE                  'No DAG Status'
                                END AS [role_desc],
                                ar.availability_mode_desc, --FR
                    drs.synchronization_state_desc,
                drs.synchronization_health_desc,
                    DATEDIFF(MINUTE, drs.last_sent_time, drs.last_received_time) AS [Min_Behind],
                    (drs.last_received_lsn-drs.last_sent_lsn) AS [LSN_Behind],
                    drs.recovery_lsn,
                    drs.truncation_lsn,
                    drs.last_sent_lsn,
                    drs.last_sent_time,
                    drs.last_received_lsn,
                    drs.last_received_time,
                    drs.last_hardened_lsn,
                    drs.last_hardened_time,
                    drs.last_redone_lsn,
                    drs.last_redone_time,
                    drs.log_send_queue_size,
                    drs.log_send_rate,
                    drs.redo_rate,
                    drs.redo_queue_size,
                    drs.filestream_send_rate,
                    drs.end_of_log_lsn,
                    drs.last_commit_lsn,
                    drs.last_commit_time
FROM sys.availability_groups ag LEFT JOIN  sys.dm_hadr_database_replica_states drs ON ag.group_id = drs.group_id
                                                                                                                LEFT JOIN sys.availability_databases_cluster adc ON drs.group_id = adc.group_id AND drs.group_database_id = adc.group_database_id
                                                                                                                LEFT JOIN sys.availability_replicas ar ON ag.group_id=ar.group_id
                             LEFT JOIN sys.dm_hadr_availability_replica_states ars ON ars.replica_id=ar.replica_id
WHERE ag.is_distributed=1

