
-- calculate number of update/writes on hour interval
SELECT dateadd(hour, datediff(hour, 0, TimeStamp), 0) as TimeStampHour, Count(*) as HourWrite
FROM [dbo].[LoanSummary]
where [TimeStamp] > '2023-01-01'
GROUP BY dateadd(hour, datediff(hour, 0, TimeStamp), 0)
ORDER BY dateadd(hour, datediff(hour, 0, TimeStamp), 0) desc;




-- Get the max value writes of interval of 1 hour
select max(x.DayWrite) as maxWritesPerHour from (
SELECT dateadd(hour, datediff(hour, 0, TimeStamp), 0) as TimeStampHour, Count(*) as DayWrite
FROM [dbo].[LoanSummary]
where [TimeStamp] > '2022-01-01'
GROUP BY dateadd(hour, datediff(hour, 0, TimeStamp), 0)  )x






-- calculate number of update/writes in 30 min interval
WITH Data
AS ( SELECT T.* ,
            DATEADD(MINUTE, DATEDIFF(MINUTE, CAST(T.[TimeStamp] AS DATE), T.[TimeStamp]) / 30 * 30, CAST(CAST(T.[TimeStamp] AS DATE) AS DATETIME)) AS BucketStart,
            DATEADD(MINUTE, 30 + DATEDIFF(MINUTE, CAST(T.[TimeStamp] AS DATE), T.[TimeStamp]) / 30 * 30, CAST(CAST(T.[TimeStamp] AS DATE) AS DATETIME)) AS BucketEnd
     FROM   [dbo].[LoanSummary] T )

SELECT   CONVERT(VARCHAR(20), D.BucketStart, 120) + ' - ' + CONVERT(VARCHAR(10), BucketEnd, 108) AS Bucket,
         COUNT(*) as CntPer30Min
FROM     Data D
GROUP BY D.BucketStart, BucketEnd
ORDER BY D.BucketStart desc;



-- Get the max value writes of interval of 30 min
WITH Data
AS ( SELECT T.* ,
            DATEADD(MINUTE, DATEDIFF(MINUTE, CAST(T.[TimeStamp] AS DATE), T.[TimeStamp]) / 30 * 30, CAST(CAST(T.[TimeStamp] AS DATE) AS DATETIME)) AS BucketStart,
            DATEADD(MINUTE, 30 + DATEDIFF(MINUTE, CAST(T.[TimeStamp] AS DATE), T.[TimeStamp]) / 30 * 30, CAST(CAST(T.[TimeStamp] AS DATE) AS DATETIME)) AS BucketEnd
     FROM   [dbo].[LoanSummary] T )
select max(x.CntPer30Min) from (
SELECT   CONVERT(VARCHAR(20), D.BucketStart, 120) + ' - ' + CONVERT(VARCHAR(10), BucketEnd, 108) AS Bucket,
         COUNT(*) as CntPer30Min
FROM     Data D
GROUP BY D.BucketStart, BucketEnd
) x






