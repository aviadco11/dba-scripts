
-- here 3 ways to rebuild index for entire DB

use [DBAUtilities]
go
EXECUTE dbo.IndexOptimize @Databases = N'<<database_name>>',
@FragmentationLow = NULL,
@FragmentationMedium =  'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
@FragmentationHigh = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
@FragmentationLevel1 = 10,
@FragmentationLevel2 = 40,
@Execute = 'Y',
@LogToTable = 'Y'

-- online rebuild
use [<<database_name>>]
go
Exec sp_msforeachtable 'SET QUOTED_IDENTIFIER ON; ALTER INDEX ALL ON ? REBUILD'
GO

-- online rebuild with FillFactoe
use [<<database_name>>]
go
DECLARE @TableName VARCHAR(255)
DECLARE @sql NVARCHAR(500)
DECLARE @fillfactor INT
SET @fillfactor = 80 
DECLARE TableCursor CURSOR FOR
SELECT QUOTENAME(OBJECT_SCHEMA_NAME([object_id]))+'.' + QUOTENAME(name) AS TableName
FROM sys.tables
OPEN TableCursor
FETCH NEXT FROM TableCursor INTO @TableName
WHILE @@FETCH_STATUS = 0
BEGIN
SET @sql = 'ALTER INDEX ALL ON ' + @TableName + ' REBUILD WITH (FILLFACTOR = ' + CONVERT(VARCHAR(3),@fillfactor) + ')'
EXEC (@sql)
FETCH NEXT FROM TableCursor INTO @TableName
END
CLOSE TableCursor
DEALLOCATE TableCursor
GO


ALTER INDEX [PK_AggregatedReconTransactions] on [dbo].[AggregatedReconTransactions] REBUILD with (ONLINE=ON)

