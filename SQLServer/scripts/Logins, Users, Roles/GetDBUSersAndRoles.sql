
-- fix Orphan Users

EXEC sp_change_users_login 'Report'


EXEC sp_change_users_login 'Auto_Fix', 'svcPrologue'


-- list Querying database roles in SQL Server for a user

SELECT r.name role_principal_name, m.name AS member_principal_name

FROM sys.database_role_members rm 

JOIN sys.database_principals r 

    ON rm.role_principal_id = r.principal_id

JOIN sys.database_principals m 

    ON rm.member_principal_id = m.principal_id





-- generate script : 

SELECT 'CREATE USER [' + NAME + '] FOR LOGIN [' + NAME + ']' AS '--Database Users Creation--'
FROM sys.database_principals
WHERE Type IN (
                                'U'
                                ,'S'
                                )
                AND NAME NOT IN (
                                'dbo'
                                ,'guest'
                                ,'sys'
                                ,'INFORMATION_SCHEMA'
                                )

SELECT 'EXEC sp_AddRoleMember ''' + DBRole.NAME + ''', ''' + DBUser.NAME + '''' AS '--Add Users to Database Roles--'
FROM sys.database_principals DBUser
INNER JOIN sys.database_role_members DBM ON DBM.member_principal_id = DBUser.principal_id
INNER JOIN sys.database_principals DBRole ON DBRole.principal_id = DBM.role_principal_id


