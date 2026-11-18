
USE DBAUtilities
GO

IF NOT EXISTS(SELECT 1 FROM sys.objects WHERE type = 'U' AND Name = 'DisableAccounts')
BEGIN
                CREATE TABLE [dbo].[DisableAccounts](
                                [Servername] [nvarchar](128) NULL,
                                [Loginname] [sysname] NOT NULL,
                                [hasaccess] [int] NULL,
                                [isntname] [int] NULL
                );
END;

DECLARE @loginname [sysname];
DECLARE @SQL NVARCHAR(MAX)
DECLARE @Enable BIT = 1  -- O Means DISABLE THE ACCOUNT AND 1 MEANS ENABLE
INSERT INTO dbo.[DisableAccounts]
(ServerName
,LoginName
,hasaccess
,isntname)
SELECT @@SERVERNAME AS Servername
      ,l.name AS Loginname
                  ,l.hasaccess
                  ,l.isntname
FROM master.sys.syslogins l
WHERE l.sysadmin <> 1
AND l.loginname NOT LIKE '%##'
AND l.loginname NOT LIKE 'NT %'
AND l.denylogin = 0
AND NOT EXISTS(SELECT 1 FROM Sys.dm_server_services ss
               WHERE l.loginname = ss.service_account)

DECLARE curLogins Cursor FOR SELECT Loginname FROM dbo.DisableAccounts

OPEN curLogins

FETCH NEXT FROM curLogins INTO @loginname
WHILE @@FETCH_STATUS = 0
BEGIN
                SET @SQL = CONCAT('ALTER LOGIN ',QUOTENAME(@LoginName), ' ', CASE WHEN @Enable = 0 THEN 'DISABLE' ELSE 'ENABLE' END , ';')
                SELECT @SQL
                --EXEC sp_executesql @SQL  --WHEN YOU WANT TO ACTUALLY RUN THE CODE UNCOMMENT THIS OUT
                FETCH NEXT FROM curLogins INTO @loginname
END      

CLOSE curLogins

DEALLOCATE curLogins

