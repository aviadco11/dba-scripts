
USE [master]

GO


-- first remove database from AG, you musr run it on primary node
ALTER AVAILABILITY GROUP [AG_Test] REMOVE DATABASE [test_AG3];
GO


-- then you can drop the Database, start with Secondary ASYNC, Secondary sync and then in the end Primary
drop database [test_AG3]




