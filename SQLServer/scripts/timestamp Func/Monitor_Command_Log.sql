
/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [ID]
      ,[DatabaseName]
      ,[SchemaName]
      ,[ObjectName]
      ,[ObjectType]
      ,[IndexName]
      ,[IndexType]
      ,[StatisticsName]
      ,[PartitionNumber]
      ,[ExtendedInfo]
      ,[Command]
      ,[CommandType]
      ,[StartTime]
      ,[EndTime]
      ,[ErrorNumber]
      ,[ErrorMessage]
                  ,DATEDIFF(MINUTE,[StartTime],[EndTime]) as Duration
  FROM [DBAUtilities].[dbo].[CommandLog]
  where [StartTime] > '2022-09-04 00:00:01.817'
  order by Duration desc

