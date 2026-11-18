
-- Create a temporary table to hold the results of DBCC SQLPERF('LOGSPACE')
CREATE TABLE #TempLogSpace (
    DatabaseName VARCHAR(128),
    LogSizeMB FLOAT,
    LogSpaceUsedPercent FLOAT,
    Status INT
);

-- Insert the results of DBCC SQLPERF('LOGSPACE') into the temporary table
INSERT INTO #TempLogSpace (DatabaseName, LogSizeMB, LogSpaceUsedPercent, Status)
EXEC ('DBCC SQLPERF(''LOGSPACE'')');

-- Create another temporary table to hold the log file paths
CREATE TABLE #LogFilePaths (
    DatabaseName VARCHAR(128),
    LogFilePath NVARCHAR(260)
);

-- Insert the log file paths into the temporary table
INSERT INTO #LogFilePaths (DatabaseName, LogFilePath)
SELECT 
    DB_NAME(database_id) AS DatabaseName,
    physical_name AS LogFilePath
FROM 
    sys.master_files
WHERE 
    type_desc = 'LOG';

-- Join the two temporary tables to get the desired result
SELECT 
    tls.DatabaseName,
    tls.LogSizeMB,
    tls.LogSpaceUsedPercent,
    tls.Status,
    lfp.LogFilePath
FROM 
    #TempLogSpace tls
JOIN 
    #LogFilePaths lfp ON tls.DatabaseName = lfp.DatabaseName
                order by tls.LogSizeMB desc;

-- Drop the temporary tables when done
DROP TABLE #TempLogSpace;
DROP TABLE #LogFilePaths;


