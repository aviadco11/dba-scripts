
-- check Page life expectancy 
/*

Monitoring Page Life Expectancy in SQL Server
By: Amit Parikh
The SQL Server Page Life Expectancy (PLE) metric has long been considered a key performance indicator for DBAs looking at the overall health of their database instances. PLE shows whether the system is under internal memory pressure using counters provided by the Buffer Manager object.
A Closer Look at Page Life Expectancy
PLE is a measure of the length of time (in seconds) a data file page is expected to stay in SQL Server s buffer pool. This metric is not an aggregate or accumulation, but simply a point-in-time value that DBAs will query out of the Buffer Manager.  
SQL Server only reads data pages from the buffer pool (i.e., logical read), so if the page isn t in the buffer pool, it finds it on the disk (i.e., physical read) and moves the page to the buffer pool so it can do a logical read. This is a time-consuming process and can negatively affect performance.

What Is a  Good  PLE Value?
A high PLE value means a page is staying in the buffer pool longer, so SQL Server is less likely to have to go to disk looking for the data page, which makes the system run faster.
Historically, DBAs considered 300 seconds (five minutes) the PLE sweet spot. However, that number is fairly arbitrary. Microsoft recommended 300 as the PLE standard back in the 2000s when memory was limited.
Today, DBAs don t focus on a  right  number because buckets of memory come standard on most systems. It s not unusual for SQL Server to run on a system that has TBs of RAM at its disposal, so DBAs have adopted a formulaic approach to identifying a  good  PLE value: 
Page Life Expectancy = 300 seconds for every 4 GB of RAM on your server

*/

SELECT [object_name],
[counter_name],
[cntr_value] FROM sys.dm_os_performance_counters
WHERE [object_name] LIKE '%Manager%'
AND [counter_name] = 'Page life expectancy'


-- run on default instance
SELECT (a.cntr_value * 1.0 / b.cntr_value) * 100.0 as BufferCacheHitRatio
FROM sys.dm_os_performance_counters  a
JOIN  (SELECT cntr_value, OBJECT_NAME 
    FROM sys.dm_os_performance_counters  
    WHERE counter_name = 'Buffer cache hit ratio base'
        AND OBJECT_NAME = 'SQLServer:Buffer Manager') b ON  a.OBJECT_NAME = b.OBJECT_NAME
WHERE a.counter_name = 'Buffer cache hit ratio'
AND a.OBJECT_NAME = 'SQLServer:Buffer Manager'


-- run on named instance
SELECT (a.cntr_value * 1.0 / b.cntr_value) * 100.0 as BufferCacheHitRatio
FROM sys.dm_os_performance_counters  a
JOIN  (SELECT cntr_value, OBJECT_NAME 
    FROM sys.dm_os_performance_counters  
    WHERE counter_name = 'Buffer cache hit ratio base'
        AND OBJECT_NAME LIKE '%:Buffer Manager%') b ON  a.OBJECT_NAME = b.OBJECT_NAME
WHERE a.counter_name = 'Buffer cache hit ratio'
AND a.OBJECT_NAME LIKE '%:Buffer Manager%'


