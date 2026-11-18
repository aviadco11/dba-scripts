
-- Default trace

DECLARE @path NVARCHAR(260)

SELECT @path=path FROM sys.traces WHERE is_default = 1
select @path


SELECT TextData, Duration, StartTime, EndTime, SPID, ApplicationName, LoginName,DatabaseName  
FROM sys.fn_trace_gettable(@path, DEFAULT)
WHERE DatabaseName like 'ETLControl_Prod' and TextData like '%db_denydata%'
ORDER BY StartTime DESC

