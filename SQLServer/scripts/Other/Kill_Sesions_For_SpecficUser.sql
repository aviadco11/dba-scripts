
-- kill sessions for specefic login
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT @sql += N'KILL ' + CONVERT(VARCHAR(11), session_id) + N';'FROM sys.dm_exec_sessions
  WHERE login_name = N'<<username>>' ;
  print @sql
EXEC sys.sp_executesql @sql;

