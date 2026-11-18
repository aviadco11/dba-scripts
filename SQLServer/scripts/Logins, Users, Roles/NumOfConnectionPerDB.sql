
-- Get number of connection per DB, loginame

SELECT DB_NAME(dbid) AS DBName, COUNT(dbid) AS NumberOfConnections, loginame
FROM    sys.sysprocesses
GROUP BY dbid, loginame
ORDER BY NumberOfConnections desc


-- Get active number of connection per DB, loginame
SELECT DB_NAME(dbid) AS DBName, COUNT(dbid) AS NumberOfConnections, loginame
FROM    sys.sysprocesses
where [status] like '%run%'
GROUP BY dbid, loginame
ORDER BY NumberOfConnections desc







