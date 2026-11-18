
--run on the global primary

--SQLCOMMAND MODE > Query (top of ssms) > SQLCMD Mode

GO

:SETVAR AGSource AG-P2P-STG
:SETVAR AGDest AG-CP-SBX-2017
:SETVAR ListenerSource STG-LS-P2P
:SETVAR ListenerDest  AWS-LS-CP2-SBX



----run on global primary
ALTER AVAILABILITY GROUP [DAG_$(ListenerSource)-$(ListenerDest)] MODIFY AVAILABILITY GROUP ON
'$(AGSource)' WITH (AVAILABILITY_MODE = SYNCHRONOUS_COMMIT),
'$(AGDest)' WITH (AVAILABILITY_MODE = SYNCHRONOUS_COMMIT);


SELECT 
    ag.name AS [Availability Group],
    ar.replica_server_name AS [Replica Server],
    CASE ar.availability_mode
        WHEN 0 THEN 'Asynchronous_Commit'
        WHEN 1 THEN 'Synchronous_Commit'
        ELSE 'Unknown'
    END AS [Availability Mode],
    CASE ar.failover_mode
        WHEN 0 THEN 'Manual'
        WHEN 1 THEN 'Automatic'
        ELSE 'Unknown'
    END AS [Failover Mode],
    ar.availability_mode_desc AS [Availability Mode Description],
    ar.failover_mode_desc AS [Failover Mode Description],
    ar.primary_role_allow_connections_desc AS [Primary Connections],
    ar.secondary_role_allow_connections_desc AS [Secondary Connections]
FROM 
    sys.availability_groups AS ag
JOIN 
    sys.availability_replicas AS ar ON ag.group_id = ar.group_id
WHERE ag.name IN ('$(AGSource)','$(AGDest)','DAG_$(ListenerSource)-$(ListenerDest)' )
ORDER BY 
    ag.name, ar.replica_server_name;

