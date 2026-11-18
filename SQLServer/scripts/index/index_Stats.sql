
use <dbname>

SELECT OBJECT_NAME(IX.OBJECT_ID) Table_Name
                   ,IX.name AS Index_Name
                   ,IX.type_desc Index_Type
                   ,SUM(PS.[used_page_count]) * 8 IndexSizeKB
                   ,IXUS.user_seeks AS NumOfSeeks
                   ,IXUS.user_scans AS NumOfScans
                   ,IXUS.user_lookups AS NumOfLookups
                   ,IXUS.user_updates AS NumOfUpdates
                   ,IXUS.last_user_seek AS LastSeek
                   ,IXUS.last_user_scan AS LastScan
                   ,IXUS.last_user_lookup AS LastLookup
                   ,IXUS.last_user_update AS LastUpdate
FROM sys.indexes IX
INNER JOIN sys.dm_db_index_usage_stats IXUS ON IXUS.index_id = IX.index_id AND IXUS.OBJECT_ID = IX.OBJECT_ID
INNER JOIN sys.dm_db_partition_stats PS on PS.object_id=IX.object_id
WHERE OBJECTPROPERTY(IX.OBJECT_ID,'IsUserTable') = 1 and database_id = db_id() 
GROUP BY OBJECT_NAME(IX.OBJECT_ID) ,IX.name ,IX.type_desc ,IXUS.user_seeks ,IXUS.user_scans ,IXUS.user_lookups,IXUS.user_updates ,IXUS.last_user_seek ,IXUS.last_user_scan ,IXUS.last_user_lookup ,IXUS.last_user_update
order by Table_Name,Index_Name


SELECT   OBJECT_NAME(S.[OBJECT_ID]) AS Table_Name, 
         I.[NAME] AS [INDEX)NAME], 
         USER_SEEKS, 
         USER_SCANS, 
         USER_LOOKUPS, 
         USER_UPDATES 
FROM     SYS.DM_DB_INDEX_USAGE_STATS AS S 
         INNER JOIN SYS.INDEXES AS I 
           ON I.[OBJECT_ID] = S.[OBJECT_ID] 
              AND I.INDEX_ID = S.INDEX_ID 
WHERE    OBJECTPROPERTY(S.[OBJECT_ID],'IsUserTable') = 1 and I.[NAME] in ('Index_Source','IX_Accounts_MerchantId',
                                                                                                'IX_Accounts_NetworkId','Index_InsertedDateTime_Source', 'Index_ReconCorrelationId')  and database_id = db_id() 
order by [Table_Name],[Index_Name]




SELECT   OBJECT_NAME(S.[OBJECT_ID]) AS Table_Name, 
         I.[NAME] AS [INDEX_NAME], 
         USER_SEEKS, 
         USER_SCANS, 
         USER_LOOKUPS, 
         USER_UPDATES 
FROM     SYS.DM_DB_INDEX_USAGE_STATS AS S 
         INNER JOIN SYS.INDEXES AS I 
           ON I.[OBJECT_ID] = S.[OBJECT_ID] 
              AND I.INDEX_ID = S.INDEX_ID 
WHERE    OBJECTPROPERTY(S.[OBJECT_ID],'IsUserTable') = 1  and database_id = db_id() 
order by Table_Name,[INDEX_NAME]




