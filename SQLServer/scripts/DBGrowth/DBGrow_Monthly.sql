
WITH DATES 
AS
(
       SELECT [ServerName]
                ,[DatabaseName]
                ,[Database_Id]
                ,[db_size_mb]
                ,[Collection_date]
                ,MAX(DATEPART(MONTH, Collection_date)) AS MONTH
                ,ROW_NUMBER() OVER (PARTITION BY ServerName, DatabaseName, DATEPART(MONTH, Collection_date) ORDER BY ServerName, DatabaseName, Collection_date DESC) AS rownum
         FROM [DBAUtilities].[Monitoring].[DatabaseGrowth]
         WHERE DatabaseName = 'CosSystemLogs'
         GROUP BY [ServerName]
                ,[DatabaseName]
                ,[Database_Id]
                ,[db_size_mb]
                ,[Collection_date]
)


SELECT D.ServerName,[Collection_date]
      ,D.DatabaseName
         ,D.db_size_mb
         ,FORMAT(D.db_size_mb -LAG(D.db_size_mb) OVER (ORDER BY D. Collection_date), 'N0') AS MB_GROWTH_PER_MONTH
FROM DATES D
WHERE rownum = 1
order by [Collection_date] desc

