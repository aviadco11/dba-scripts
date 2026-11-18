
-- audit enable

USE [master]

GO

CREATE SERVER AUDIT [Audit-TblChanges]
TO FILE 
(   FILEPATH = N'C:\temp'
    ,MAXSIZE = 0 MB
    ,MAX_ROLLOVER_FILES = 2147483647
    ,RESERVE_DISK_SPACE = OFF
)
WITH
(   QUEUE_DELAY = 1000
    ,ON_FAILURE = CONTINUE
)

GO

USE [test_AG]
GO

CREATE DATABASE AUDIT SPECIFICATION [DatabaseAuditSpecification-MyTable]
FOR SERVER AUDIT [Audit-TblChanges]
ADD (UPDATE,INSERT,DELETE,SELECT  ON DATABASE::test_AG BY public)

GO


USE [master]
GO
ALTER SERVER AUDIT [Audit-TblChanges] WITH (STATE = ON);

USE [test_AG]
GO
ALTER DATABASE AUDIT SPECIFICATION [DatabaseAuditSpecification-MyTable] WITH (STATE = ON);
GO

----------------------------------------------------------------------------------------------------------------------------------------------------

-- audit view 
select * from sys.fn_get_audit_file('c:\temp\Audit-TblChanges_CD7CD9A3-DA63-4D41-9842-8759F9976BF3_0_133475489558550000.sqlaudit', DEFAULT,DEFAULT)
where schema_name not like 'sys'




-- audit drop 

USE [master]
GO
ALTER SERVER AUDIT [Audit-TblChanges] WITH (STATE = OFF);

USE [test_AG]
GO
ALTER DATABASE AUDIT SPECIFICATION [DatabaseAuditSpecification-MyTable]
WITH (STATE = OFF)
GO
USE [test_AG]
GO
DROP DATABASE AUDIT SPECIFICATION [DatabaseAuditSpecification-MyTable]
GO


USE [master]
GO
drop SERVER AUDIT [Audit-TblChanges]

