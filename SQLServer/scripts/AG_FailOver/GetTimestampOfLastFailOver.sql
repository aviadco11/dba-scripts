
select @@SERVERNAME as [ServerName],sqlserver_start_time as LastInstanceStart, DATEDIFF(HOUR, sqlserver_start_time, GETDATE()) as HoursSinceFailover
       from sys.dm_os_sys_info;

