
while 1=1
begin
    ;with ActiveConnections as (
        select db_name(s.database_id) as DatabaseName,
               s.login_name as LoginName,
               c.client_net_address as ClientIP,
               s.host_name as HostName,
               s.program_name AS ProgramName,
               s.login_time as LoginTime
        FROM sys.dm_exec_sessions s
        JOIN sys.dm_exec_connections c
            ON s.session_id = c.session_id
        WHERE DB_NAME(s.database_id)  IN ('RPPSRail','Beka','PushToPayExpress','P2PTransaction','VisaDirectRail','TabaPayRail','P2PReconciliation ','P2PFxRate','P2POneTimeCode','P2PInvalidRequests','P2PIntelligence','P2PIframeConfig','P2PCustomerPortal','P2PCreditCard','MCSend.Parameter','MCSend')

    )
    SELECT *,
           (SELECT COUNT(*) FROM ActiveConnections) AS RwCount
    FROM ActiveConnections;

    WAITFOR DELAY '00:00:05'; -- 5 second pause
END


