
-- Author:          Nicholas Chammas
--                                            Turbine / WB Games
--                                             2011/10/13
-- Inspired by: http://vyaskn.tripod.com/sql_server_check_identity_columns.htm
-- Purpose: Find all IDENTITY columns on all databases on this instance 
--                                             and show how much of their range they have exhausted.
-- 
-- CAVEATS
-- 
--   1.    Developed using SQL Server 2008 syntax.
--                             
--                             To port to SQL Server 2005:
--                                             * split out variable assignments into separate SET statements
--                             
--                             To port to SQL Server 2000:
--                                             * perform all steps required to port to SQL Server 2005
--                                             * convert CTE into derived table
--                                             * replace the 2005+ sys.catalog_views with SQL Server 2000 equivalents
--                                               (don't know how much of the script will have to be rewritten to do this)
-- 
--   2. This script will not catch identity columns that are about to overflow
--                             due to ridiculously large identity increments. For example, a tinyint
--                             column with a current identity value of 50 is about 50/255 ~= 20% full.
--                             However, this column will overflow a LOT faster if the increment is 50
--                             (which gives you 4 more inserts) as opposed to 1 (which gives you 205 
--                             more inserts).
--
-- NOTE:
--            gist makes the spacing look all messed up. If you copy the raw code and
--            paste it into SQL Server Management Studio everything should look good.

SET NOCOUNT ON;

DECLARE          @fullness_threshold DECIMAL(4, 1)               = 70.0;
DECLARE @identity_query                    NVARCHAR(MAX);

--drop table if exists #identity_column


CREATE TABLE #identity_columns1 (
                  [database]                                     [sysname]                                        NOT NULL
                , [schema]                                                       [sysname]                                        NOT NULL
                , [table]                                                              [sysname]                                        NOT NULL
                , [column]                                                        [sysname]                                        NOT NULL
                , [data_type]                                    [sysname]                                        NOT NULL
                , [precision]                                     [tinyint]                                              NOT NULL
                , [identity_value]                          [decimal](38,0)                            NOT NULL
                , [identity_increment]               [decimal](38,0)                            NOT NULL
                , [identity_limit]                            [float]                                                  NOT NULL
                , [percentage_used]                   [decimal](4, 1)                              NOT NULL
                
                -- only one IDENTITY column allowed per table
                , PRIMARY KEY (
                                  [database]
                                , [schema]
                                , [table]
                  )
);

DECLARE db_cursor CURSOR FAST_FORWARD FOR 
SELECT QUOTENAME(name)
FROM sys.databases
WHERE name  IN (
                  'DBName'
);


-- query to pull identity columns and calculate their fullness
-- copied from separate query file
SET @identity_query = '
                DECLARE @MAX_TINYINT TINYINT = 255;
                DECLARE @MAX_SMALLINT SMALLINT = 32767;
                DECLARE @MAX_INT INT = 2147483647;
                DECLARE @MAX_BIGINT BIGINT = 9223372036854775807;

                DECLARE @MIN_TINYINT TINYINT = 0;
                DECLARE @MIN_SMALLINT SMALLINT = -32768;
                DECLARE @MIN_INT INT = -2147483648;
                DECLARE @MIN_BIGINT BIGINT = -9223372036854775808;

                WITH identity_columns AS (
                                SELECT
                                                  DB_NAME()                                                                                                                                   AS [database]
                                                , SCHEMA_NAME(t.schema_id)                                                                         AS [schema]
                                                , t.name                                                                                                                                             AS [table]
                                                , c.name                                                                                                                                            AS [column]
                                                , typ.name                                                                                                                                        AS [data_type]
                                                , c.precision                                                                                                                    AS [precision]
                --                             , c.scale                                                                                                                                             AS [scale]                                -- is always 0 for IDENTITY columns
                                                
                                                , IDENT_SEED(SCHEMA_NAME(t.schema_id) + ''.'' + t.name)                         AS [identity_seed]
                                                , IDENT_CURRENT(SCHEMA_NAME(t.schema_id) + ''.'' + t.name)              AS [identity_value]
                                                , IDENT_INCR(SCHEMA_NAME(t.schema_id) + ''.'' + t.name)                         AS [identity_increment]
                                                
                                                , CASE
                                                                WHEN typ.name = ''bigint''    THEN @MIN_BIGINT
                                                                WHEN typ.name = ''int''                           THEN @MIN_INT
                                                                WHEN typ.name = ''smallint''              THEN @MIN_SMALLINT
                                                                WHEN typ.name = ''tinyint''   THEN @MIN_TINYINT
                                                                WHEN typ.name IN (
                                                                                  ''decimal''
                                                                                , ''numeric''
                                                                )                                                                                                              THEN -POWER(1e1, typ.precision) + 1
                                                  END                                                                                                                                                                                                                   AS [identity_min]
                                                , CASE
                                                                WHEN typ.name = ''bigint''                    THEN @MAX_BIGINT
                                                                WHEN typ.name = ''int''                                           THEN @MAX_INT
                                                                WHEN typ.name = ''smallint''              THEN @MAX_SMALLINT
                                                                WHEN typ.name = ''tinyint''                   THEN @MAX_TINYINT
                                                                WHEN typ.name IN (
                                                                                  ''decimal''
                                                                                , ''numeric''
                                                                )                                                                                                              THEN POWER(1e1, typ.precision) - 1
                                                  END                                                                                                                                                                                                                   AS [identity_max]
                                                , CASE
                                                                                                                                                                                                -- casting to larger type so the intermediate result can fit; arithmetic overflow otherwise
                                                                WHEN typ.name = ''bigint''                    THEN CAST(@MAX_BIGINT  AS NUMERIC(38, 0))         - @MIN_BIGINT
                                                                WHEN typ.name = ''int''                                           THEN CAST(@MAX_INT                           AS BIGINT)                                       - @MIN_INT
                                                                WHEN typ.name = ''smallint''              THEN CAST(@MAX_SMALLINT           AS INT)                                                       - @MIN_SMALLINT
                                                                WHEN typ.name = ''tinyint''                   THEN CAST(@MAX_TINYINT AS SMALLINT)                       - @MIN_TINYINT
                                                                WHEN typ.name IN (
                                                                                  ''decimal''
                                                                                , ''numeric''
                                                                )                                                                                                              THEN 2 * POWER(1e1, typ.precision) - 2
                                                  END                                                                                                                                                                                                                   AS identity_range_size
                                FROM
                                                                                                sys.columns   AS c 
                                                INNER JOIN     
                                                                                                sys.tables         AS t
                                                                                                                ON t.[object_id] = c.[object_id]
                                                INNER JOIN     
                                                                                                sys.types           AS typ
                                                                                                                -- not system_type_id; user-defined types mapped to system types 
                                                                                                                -- create duplicate sys.types records when you join on system_type_id
                                                                                                                ON c.user_type_id = typ.user_type_id
                                WHERE              
                                                c.is_identity = 1
                )
                SELECT
                                  [database]
                                , [schema]
                                , [table]
                                , [column]
                                , [data_type]
                                , [precision]
                                
                                , [identity_value]
                                , [identity_increment]
                                , CASE SIGN([identity_increment])
                                                WHEN -1 THEN             [identity_min]
                                                ELSE                                    [identity_max]
                                  END                                                   AS [identity_limit]
                                
                                , CAST(
                                                  ([identity_value] - [identity_min])
                                                / [identity_range_size] 
                                                * 100
                                  AS DECIMAL(4, 1)) AS [percentage_used]
                FROM
                                                identity_columns
                ;
';

DECLARE @db_name SYSNAME;

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @db_name;

-- run identity overflow check on each database
-- and collect results in table variable
WHILE @@FETCH_STATUS = 0  
BEGIN  
                INSERT INTO #identity_columns1
                EXECUTE ('USE ' + @db_name + '; ' + @identity_query);
                
                FETCH NEXT FROM db_cursor INTO @db_name;
END;

CLOSE db_cursor;
DEALLOCATE db_cursor;

DECLARE @problem_columns INT = (
                SELECT COUNT(*)
                FROM #identity_columns1
                WHERE percentage_used >= @fullness_threshold
);

SELECT *
FROM #identity_columns1
WHERE [percentage_used] >= @fullness_threshold
ORDER BY
                  [percentage_used]   DESC
                , [database]                    ASC
                , [schema]                                       ASC
                , [table]                                              ASC
                , [column]                                        ASC
;

DROP TABLE #identity_columns1;

