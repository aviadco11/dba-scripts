
-- create event for real page split. capture it from transaction log 
-- just configure the right db_id

create EVENT SESSION [TrackPageSplit] ON SERVER 
ADD EVENT sqlserver.transaction_log( 
ACTION(sqlserver.database_name,sqlserver.session_id, sqlserver.username, sqlserver.sql_text, sqlserver.client_app_name, sqlserver.client_hostname, task_time)
WHERE operation = 11 and database_id = 98)
ADD TARGET package0.event_file(SET filename=N'TrackPageSplit',max_file_size=(20)),
ADD TARGET package0.histogram(SET filtering_event_name=N'sqlserver.transaction_log',source=N'alloc_unit_id',source_type=(0))
WITH (STARTUP_STATE=OFF)
GO

-- start EVENT SESSION
ALTER EVENT SESSION
                TrackPageSplit
ON
                SERVER STATE = START;
GO

-- count the number of page splits based on session event of [TrackPageSplit]
select
                SchemaName = SCHEMA_NAME (Tables.schema_id),
                TableName = Tables.name, 
                IndexId = Indexes.index_id,
                IndexName = Indexes.name,
                PageSplitCount = AllocationUnitWithPageSplits.PageSplitCount,
                IndexFillFactor = Indexes.fill_factor
FROM
                (
                                SELECT
                                                AllocationUnitId = Slot.value ('(value)[1]', 'BIGINT'),
                                                PageSplitCount = Slot.value('(@count)[1]', 'BIGINT')
                                FROM
                                                (
                                                                SELECT
                                                                                TargetData = CAST(target_data as XML)
                                                                FROM
                                                                                sys.dm_xe_sessions AS EventSessions
                                                                INNER JOIN
                                                                                sys.dm_xe_session_targets AS EventSessionTargets
                                                                ON
                                                                                EventSessions.address = EventSessionTargets.event_session_address
                                                                WHERE
                                                                                EventSessions.name = N'TrackPageSplit'
                                                                AND
                                                                                EventSessionTargets.target_name = N'histogram'
                                                )
                                                AS
                                                                EventSessionsAndTargets
                                CROSS APPLY
                                                TargetData.nodes (N'HistogramTarget/Slot') AS HistogramSlots (Slot)
                )
                AS
                                AllocationUnitWithPageSplits
INNER JOIN
                sys.allocation_units AS AllocationUnits
ON
                AllocationUnitWithPageSplits.AllocationUnitId = AllocationUnits.allocation_unit_id
INNER JOIN
                sys.partitions AS Partitions
ON
                AllocationUnits.container_id = Partitions.partition_id
INNER JOIN
                sys.indexes AS Indexes
ON
                Partitions.object_id = Indexes.object_id
AND
                Partitions.index_id = Indexes.index_id
INNER JOIN
                sys.tables AS Tables
ON
                Indexes.object_id = Tables.object_id
ORDER BY
                SchemaName ASC,
                TableName ASC,
                IndexId ASC;
GO



