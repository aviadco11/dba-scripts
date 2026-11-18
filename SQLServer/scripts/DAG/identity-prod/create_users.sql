
use Crb.IdentityServer
GO

CREATE USER [<<username>>] FOR LOGIN [<<username>>]
CREATE USER [<<username>>] FOR LOGIN [<<username>>]
CREATE USER [<<username>>] FOR LOGIN [<<username>>]
CREATE USER [<<username>>] FOR LOGIN [<<username>>]

EXEC sp_AddRoleMember 'db_executor', '<<username>>'
EXEC sp_AddRoleMember 'db_owner', 'dbo'
EXEC sp_AddRoleMember 'db_owner', '<<username>>'
EXEC sp_AddRoleMember 'db_owner', '<<username>>'
EXEC sp_AddRoleMember 'db_datareader', '<<username>>'
EXEC sp_AddRoleMember 'db_datareader', '<<username>>'
EXEC sp_AddRoleMember 'db_datareader', '<<username>>'
EXEC sp_AddRoleMember 'db_datareader', '<<username>>'

use Crb.IdentityServerSelfService
go

CREATE USER [<<username>>] FOR LOGIN [<<username>>]
CREATE USER [<<username>>] FOR LOGIN [<<username>>]
CREATE USER [<<username>>] FOR LOGIN [<<username>>]
GO
EXEC sp_AddRoleMember 'db_executor', '<<username>>'
EXEC sp_AddRoleMember 'db_executor', '<<username>>'
EXEC sp_AddRoleMember 'db_executor', '<<username>>'
EXEC sp_AddRoleMember 'db_owner', 'dbo'
EXEC sp_AddRoleMember 'db_ddladmin', '<<username>>'
EXEC sp_AddRoleMember 'db_ddladmin', '<<username>>'
EXEC sp_AddRoleMember 'db_datareader', '<<username>>'
EXEC sp_AddRoleMember 'db_datareader', '<<username>>'
EXEC sp_AddRoleMember 'db_datareader', '<<username>>'
EXEC sp_AddRoleMember 'db_datareader', '<<username>>'
EXEC sp_AddRoleMember 'db_datareader', '<<username>>'
EXEC sp_AddRoleMember 'db_datawriter', '<<username>>'
EXEC sp_AddRoleMember 'db_datawriter', '<<username>>'

USE Crb.IdentityServerUsers
GO
CREATE USER [<<username>>] FOR LOGIN [<<username>>]
CREATE USER [<<username>>] FOR LOGIN [<<username>>]
CREATE USER [<<username>>] FOR LOGIN [<<username>>]
CREATE USER [<<username>>] FOR LOGIN [<<username>>]
CREATE USER [<<username>>] FOR LOGIN [<<username>>]
GO
EXEC sp_AddRoleMember 'SelfService_ddladmin', '<<username>>'
EXEC sp_AddRoleMember 'db_executor', '<<username>>'
EXEC sp_AddRoleMember 'db_owner', 'dbo'
EXEC sp_AddRoleMember 'db_owner', '<<username>>'
EXEC sp_AddRoleMember 'db_owner', '<<username>>'
EXEC sp_AddRoleMember 'db_datareader', '<<username>>'
EXEC sp_AddRoleMember 'db_datareader', '<<username>>'
EXEC sp_AddRoleMember 'db_datareader', '<<username>>'
EXEC sp_AddRoleMember 'db_datareader', '<<username>>'
EXEC sp_AddRoleMember 'db_datareader', '<<username>>'
EXEC sp_AddRoleMember 'db_datareader', '<<username>>'
EXEC sp_AddRoleMember 'db_datawriter', '<<username>>'
EXEC sp_AddRoleMember 'db_datawriter', '<<username>>'

use DelegatedAdministration
GO
CREATE USER [<<username>>] FOR LOGIN [<<username>>]
CREATE USER [<<username>>] FOR LOGIN [<<username>>]
CREATE USER [<<username>>] FOR LOGIN [<<username>>]
GO
EXEC sp_AddRoleMember 'db_executor', '<<username>>'
EXEC sp_AddRoleMember 'db_executor', '<<username>>'
EXEC sp_AddRoleMember 'db_executor', '<<username>>'
EXEC sp_AddRoleMember 'db_owner', 'dbo'
EXEC sp_AddRoleMember 'db_ddladmin', '<<username>>'
EXEC sp_AddRoleMember 'db_datareader', '<<username>>'
EXEC sp_AddRoleMember 'db_datareader', '<<username>>'
EXEC sp_AddRoleMember 'db_datareader', '<<username>>'
EXEC sp_AddRoleMember 'db_datareader', '<<username>>'
EXEC sp_AddRoleMember 'db_datareader', '<<username>>'
EXEC sp_AddRoleMember 'db_datawriter', '<<username>>'
EXEC sp_AddRoleMember 'db_datawriter', '<<username>>'
EXEC sp_AddRoleMember 'db_datawriter', '<<username>>'


