
USE [master]
GO
CREATE LOGIN [svcuser] WITH PASSWORD=N'pwd', DEFAULT_DATABASE=[@dbname], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO


-- after creaete Login, check is sid 
USE @dbname
GO 
SELECT name, sid 
FROM sys.sysusers 
WHERE name = 'svcuser' 
GO 

USE MASTER 
GO 
SELECT name, sid FROM sys.sql_logins WHERE name = 'svcuser' 
GO


-- on secondary 
CREATE Login [svcuser] WITH password = N'pwd', SID = xxxx, DEFAULT_DATABASE=[@dbname], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF


