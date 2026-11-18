
-- scripts to get locks types and blocking

exec sp_WhoIsActive 103, @get_locks=1

sp_lock 103

exec sp_who2 421

/*
Lock Type          nchar(4)            The lock type by hirechy:

RID = Lock on a single row in a table identified by a row identifier (RID).

KEY = Lock within an index that protects a range of keys in serializable transactions.

PAG = Lock on a data or index page.

EXT = Lock on an extent.

TAB = Lock on an entire table, including all data and indexes.

DB = Lock on a database.

FIL = Lock on a database file.

APP = Lock on an application-specified resource.

MD = Locks on metadata, or catalog information.

HBT = Lock on a heap or B-Tree (HoBT). This information is incomplete in SQL Server.

AU = Lock on an allocation unit. This information is incomplete in SQL Server.
*/

use ArixLendingHooks
go
select l.resource_type, l.request_session_id,l.request_mode,db_name(l.resource_database_id) as dbname, o.[name]
from sys.dm_tran_locks l
left join sys.objects o on l.resource_associated_entity_id = o.[object_id]
where l.resource_type <> 'DataBase' and db_name(resource_database_id) like 'ArixLendingHooks'
--order by db_name(resource_database_id)


use ArixLendingHooks
go
select l.resource_type, l.request_session_id,l.request_mode,db_name(l.resource_database_id) as dbname, o.[name], count(*) as cnt
from sys.dm_tran_locks l
left join sys.objects o on l.resource_associated_entity_id = o.[object_id]
where l.resource_type <> 'DataBase' and db_name(resource_database_id) like 'ArixLendingHooks'
group by l.resource_type, l.request_session_id, l.request_mode,db_name(l.resource_database_id), o.[name]

use [DBAUtilities]
go
exec sp_WhoIsActive 421, @get_locks=1

exec sp_WhoIsActive @get_locks=1


-- the following script show you exactly from type of locks you have
-- List all Locks of the Current Database 
SELECT TL.resource_type AS ResType 
      ,TL.resource_description AS ResDescr 
      ,TL.request_mode AS ReqMode 
      ,TL.request_type AS ReqType 
      ,TL.request_status AS ReqStatus 
      ,TL.request_owner_type AS ReqOwnerType 
      ,TAT.[name] AS TransName 
      ,TAT.transaction_begin_time AS TransBegin 
      ,DATEDIFF(ss, TAT.transaction_begin_time, GETDATE()) AS TransDura 
      ,ES.session_id AS S_Id 
      ,ES.login_name AS LoginName 
      ,COALESCE(OBJ.name, PAROBJ.name) AS ObjectName 
      ,PARIDX.name AS IndexName 
      ,ES.host_name AS HostName 
      ,ES.program_name AS ProgramName 
FROM sys.dm_tran_locks AS TL 
     INNER JOIN sys.dm_exec_sessions AS ES 
         ON TL.request_session_id = ES.session_id 
     LEFT JOIN sys.dm_tran_active_transactions AS TAT 
         ON TL.request_owner_id = TAT.transaction_id 
            AND TL.request_owner_type = 'TRANSACTION' 
     LEFT JOIN sys.objects AS OBJ 
         ON TL.resource_associated_entity_id = OBJ.object_id 
            AND TL.resource_type = 'OBJECT' 
     LEFT JOIN sys.partitions AS PAR 
         ON TL.resource_associated_entity_id = PAR.hobt_id 
            AND TL.resource_type IN ('PAGE', 'KEY', 'RID', 'HOBT') 
     LEFT JOIN sys.objects AS PAROBJ 
         ON PAR.object_id = PAROBJ.object_id 
     LEFT JOIN sys.indexes AS PARIDX 
         ON PAR.object_id = PARIDX.object_id 
            AND PAR.index_id = PARIDX.index_id 
WHERE TL.resource_database_id  = DB_ID() 
      AND ES.session_id <> @@Spid -- Exclude "my" session 
      -- optional filter  
      AND TL.request_mode <> 'S' -- Exclude simple shared locks 
ORDER BY TL.resource_type 
        ,TL.request_mode 
        ,TL.request_type 
        ,TL.request_status 
        ,ObjectName 
        ,ES.login_name;



-- TSQL commands
SELECT 
    db_name(rsc_dbid) AS 'DATABASE_NAME',
    CASE rsc_type 
        WHEN 1 THEN 'null'
        WHEN 2 THEN 'DATABASE' 
        WHEN 3 THEN 'FILE'
        WHEN 4 THEN 'INDEX'
        WHEN 5 THEN 'TABLE'
        WHEN 6 THEN 'PAGE'
        WHEN 7 THEN 'KEY'
        WHEN 8 THEN 'EXTEND'
        WHEN 9 THEN 'RID (ROW ID)'
        WHEN 10 THEN 'APPLICATION' 
    END AS 'REQUEST_TYPE',
    CASE req_ownertype 
        WHEN 1 THEN 'TRANSACTION'
        WHEN 2 THEN 'CURSOR'
        WHEN 3 THEN 'SESSION'
        WHEN 4 THEN 'ExSESSION' 
    END AS 'REQUEST_OWNERTYPE',
    OBJECT_NAME(rsc_objid, rsc_dbid) AS 'OBJECT_NAME', 
    PROCESS.HOSTNAME, 
    PROCESS.program_name, 
    PROCESS.nt_domain, 
    PROCESS.nt_username, 
    SQLTEXT.text
FROM 
    sys.syslockinfo LOCK
JOIN 
    sys.sysprocesses PROCESS ON LOCK.req_spid = PROCESS.spid
CROSS APPLY 
    sys.dm_exec_sql_text(PROCESS.sql_handle) SQLTEXT
WHERE 
    db_name(rsc_dbid) = db_name();


SELECT 
    OBJECT_NAME(p.OBJECT_ID) AS TableName, 
    resource_type, 
    resource_description 
FROM 
    sys.dm_tran_locks l 
JOIN 
    sys.partitions p 
ON 
    l.resource_associated_entity_id = p.hobt_id;


-- To check if an entire table is locked in SQL Server, you can use the following query. 
-- This script will help you identify if there are any locks on the table level:

SELECT 
    OBJECT_NAME(p.OBJECT_ID) AS TableName, 
    l.resource_type, 
    l.request_mode, 
    l.request_status, 
    l.request_session_id
FROM 
    sys.dm_tran_locks l 
JOIN 
    sys.partitions p 
ON 
    l.resource_associated_entity_id = p.hobt_id
--WHERE 
  --  l.resource_type = 'OBJECT' 
    --AND OBJECT_NAME(p.OBJECT_ID) in ('AuditEntries');


SELECT 
    OBJECT_NAME(p.OBJECT_ID) AS TableName, 
    i.name AS IndexName, 
    l.resource_type, 
    l.request_mode, 
    l.request_status, 
    l.request_session_id
FROM 
    sys.dm_tran_locks l 
JOIN 
    sys.partitions p 
ON 
    l.resource_associated_entity_id = p.hobt_id
JOIN 
    sys.indexes i 
ON 
    p.object_id = i.object_id 
    AND p.index_id = i.index_id
WHERE 
    i.type = 1 -- Clustered index
    AND OBJECT_NAME(p.OBJECT_ID) = 'AuditEntries';

-- find blocks 
SELECT 
    blocking_session_id AS BlockingSessionID, db_name(database_id) as [db_name],
    session_id AS BlockedSessionID,
    wait_type,
    wait_resource
FROM sys.dm_exec_requests
WHERE blocking_session_id = 102;

SELECT dm_tran_locks.request_session_id,
       dm_tran_locks.resource_database_id,
       DB_NAME(dm_tran_locks.resource_database_id) AS dbname,
       CASE
           WHEN resource_type = 'OBJECT'
               THEN OBJECT_NAME(dm_tran_locks.resource_associated_entity_id)
           ELSE OBJECT_NAME(partitions.OBJECT_ID)
       END AS ObjectName,
       partitions.index_id,
       indexes.name AS index_name,
       dm_tran_locks.resource_type,
       dm_tran_locks.resource_description,
       dm_tran_locks.resource_associated_entity_id,
       dm_tran_locks.request_mode,
       dm_tran_locks.request_status
FROM sys.dm_tran_locks
LEFT JOIN sys.partitions ON partitions.hobt_id = dm_tran_locks.resource_associated_entity_id
LEFT JOIN sys.indexes ON indexes.OBJECT_ID = partitions.OBJECT_ID AND indexes.index_id = partitions.index_id
WHERE resource_associated_entity_id > 0
  AND resource_database_id = DB_ID()
ORDER BY request_session_id, resource_associated_entity_id 

