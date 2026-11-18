
/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [ID]
      ,[DatabaseName]
      ,[CommandType]
      ,[StartTime]
      ,[EndTime]
                  , [Command]
                  , DateDiff(HOUR, [StartTime], [EndTime]) as Duration
  FROM [DBAUtilities].[dbo].[CommandLog]
  where [StartTime] > DATEADD(DAY, -20,getdate()) and DateDiff(HOUR, [StartTime], [EndTime]) > 3
  --and [DatabaseName] = 'Sponge_Prod'
  order by Duration desc



