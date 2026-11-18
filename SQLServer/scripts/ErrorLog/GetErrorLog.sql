
-- get ErrorLog location
SELECT SERVERPROPERTY('ErrorLogFileName') 
               AS 'Error log file location'

-- show ErrorLog
EXECUTE SP_READERRORLOG

-- search for msg in ErrorLog
exec xp_readerrorlog 0, 1, N'Logging SQL Server messages in file', 
                        NULL, NULL, NULL, N'asc'

