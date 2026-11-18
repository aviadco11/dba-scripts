
-- Run this on the FORWARDER and verify synchronized
:CONNECT sqldbsbx03-01
select @@SERVERNAME

SELECT     DB_NAME(database_id) AS DBName,     is_primary_replica,     synchronization_state_desc,     database_state_desc 
FROM     sys.dm_hadr_database_replica_states;

:CONNECT padbstg01
select @@SERVERNAME
-- Run this on the GLOBAL PRIMARY
USE [P2PFxRate]
GO

CREATE TABLE [dbo].[TestDAGSync](
                [name] varchar(20) NOT NULL,
) ON [PRIMARY]
GO

INSERT INTO [dbo].[TestDAGSync] values ('Hey1')
GO


-- Run this on the FORWARDER and verify synchronized
:CONNECT sqldbsbx03-01
select @@SERVERNAME
USE [P2PFxRate]
GO
select * from [dbo].[TestDAGSync] 

-- Run this on the Second Forwared and verify synchronized
:CONNECT sqldbsbx03-02
select @@SERVERNAME
USE [P2PFxRate]
GO
select * from [dbo].[TestDAGSync]




--RUN ON GLOBAL PRIMARY AND FORWARDER.


/*
-- create the temp table on the global primary
CREATE TABLE #LastLSNGobalPrimary (Server VARCHAR(500), DBname VARCHAR(500), Last_hardened_lsn DECIMAL(38,0))
CREATE TABLE #LastLSNForwarder (Server VARCHAR(500), DBname VARCHAR(500), Last_hardened_lsn DECIMAL(38,0))


--Run this on global primary, take all the insert commands (last column) and run them on the global primary
SELECT @@servername, AGs.name, db_name(database_id) DBName, synchronization_state_desc, last_hardened_lsn, 'insert into #LastLSNGobalPrimary (Server, DBname, Last_hardened_lsn) select ''GlobalPrimary'', '''+CAST(DB_NAME(database_id) AS VARCHAR(500))+''','''+CAST(last_hardened_lsn AS VARCHAR(500))+''''
FROM sys.dm_hadr_database_replica_states replicaStates
JOIN sys.availability_groups AGs ON AGs.group_id = replicaStates.group_id
WHERE  (is_primary_replica = 1) -- or (is_distributed = 1) 
AND db_name(database_id) like 'P2P%' --AND db_name(database_id) NOT IN ('ArixACH','ArixLendingAuditTrail','ArixLendingBilling','ArixRPPS')

--Run this on Forwarder, take all the insert commands (last column) and run them on the global primary
SELECT @@servername,AGs.name, db_name(database_id) DBName, synchronization_state_desc, last_hardened_lsn, 'insert into #LastLSNForwarder (Server, DBname, Last_hardened_lsn) select ''Forwarder'', '''+CAST(DB_NAME(database_id) AS VARCHAR(500))+''','''+CAST(last_hardened_lsn AS VARCHAR(500))+''''
FROM sys.dm_hadr_database_replica_states replicaStates
JOIN sys.availability_groups AGs ON AGs.group_id = replicaStates.group_id
WHERE  (is_primary_replica = 1) -- or (is_distributed = 1) 
AND db_name(database_id) like 'P2P%'


insert into #LastLSNGobalPrimary (Server, DBname, Last_hardened_lsn) select 'GlobalPrimary', 'P2PReconciliation ','272897000126908900001'
insert into #LastLSNGobalPrimary (Server, DBname, Last_hardened_lsn) select 'GlobalPrimary', 'P2POneTimeCode','10385000006883200001'
insert into #LastLSNGobalPrimary (Server, DBname, Last_hardened_lsn) select 'GlobalPrimary', 'P2PCustomerPortal','76000001089600001'
insert into #LastLSNGobalPrimary (Server, DBname, Last_hardened_lsn) select 'GlobalPrimary', 'P2PCreditCard','270000001505300001'
insert into #LastLSNGobalPrimary (Server, DBname, Last_hardened_lsn) select 'GlobalPrimary', 'P2PIntelligence','327000001699200001'
insert into #LastLSNGobalPrimary (Server, DBname, Last_hardened_lsn) select 'GlobalPrimary', 'P2PInvalidRequests','635000002552500001'
insert into #LastLSNGobalPrimary (Server, DBname, Last_hardened_lsn) select 'GlobalPrimary', 'P2PFxRate','5601000002788600001'
insert into #LastLSNGobalPrimary (Server, DBname, Last_hardened_lsn) select 'GlobalPrimary', 'P2PIframeConfig','66000000274300001'
insert into #LastLSNGobalPrimary (Server, DBname, Last_hardened_lsn) select 'GlobalPrimary', 'P2PTransaction','871000000275400001'

insert into #LastLSNForwarder (Server, DBname, Last_hardened_lsn) select 'Forwarder', 'P2PIntelligence','327000001700000001'
insert into #LastLSNForwarder (Server, DBname, Last_hardened_lsn) select 'Forwarder', 'P2PTransaction','871000000275900001'
insert into #LastLSNForwarder (Server, DBname, Last_hardened_lsn) select 'Forwarder', 'P2PReconciliation ','272897000126909300001'
insert into #LastLSNForwarder (Server, DBname, Last_hardened_lsn) select 'Forwarder', 'P2POneTimeCode','10385000006883400001'
insert into #LastLSNForwarder (Server, DBname, Last_hardened_lsn) select 'Forwarder', 'P2PInvalidRequests','635000002552500001'
insert into #LastLSNForwarder (Server, DBname, Last_hardened_lsn) select 'Forwarder', 'P2PIframeConfig','66000000274300001'
insert into #LastLSNForwarder (Server, DBname, Last_hardened_lsn) select 'Forwarder', 'P2PFxRate','5601000002794800001'
insert into #LastLSNForwarder (Server, DBname, Last_hardened_lsn) select 'Forwarder', 'P2PCustomerPortal','76000001089600001'
insert into #LastLSNForwarder (Server, DBname, Last_hardened_lsn) select 'Forwarder', 'P2PCreditCard','270000001505300001'


--run this select to see if they are in sync, If ThereIsAProblem column is anything but 0, then they are not in sync
SELECT g.DBname, g.Last_hardened_lsn AS GlobalLSN, f.Last_hardened_lsn AS forwarderLSN, g.Last_hardened_lsn-f.Last_hardened_lsn AS ThereIsAProblem
FROM #LastLSNGobalPrimary g
                LEFT JOIN #LastLSNForwarder f
                                ON f.DBname=g.DBname
                                


DROP TABLE #LastLSNGobalPrimary
DROP TABLE #LastLSNForwarder

*/


