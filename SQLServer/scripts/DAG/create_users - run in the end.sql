
use DelegatedAdministration
go

CREATE USER [<<username>>] FOR LOGIN [<<username>>]
CREATE USER [CRBCLOUD\svcSAWSRSISstg] FOR LOGIN [CRBCLOUD\svcSAWSRSISstg]
CREATE USER [<<username>>] FOR LOGIN [<<username>>]
CREATE USER [<<username>>] FOR LOGIN [<<username>>]
CREATE USER [CRBCLOUD\<<username>>] FOR LOGIN [CRBCLOUD\<<username>>]

EXEC sp_AddRoleMember 'db_executor', '<<username>>'
EXEC sp_AddRoleMember 'db_executor', '<<username>>'
EXEC sp_AddRoleMember 'db_executor', '<<username>>'
EXEC sp_AddRoleMember 'db_executor', 'CRBCLOUD\<<username>>'
EXEC sp_AddRoleMember 'db_owner', 'dbo'
EXEC sp_AddRoleMember 'db_ddladmin', '<<username>>'
EXEC sp_AddRoleMember 'db_ddladmin', '<<username>>'
EXEC sp_AddRoleMember 'db_datareader', 'CRB\secIAMDevTeam'
EXEC sp_AddRoleMember 'db_datareader', '<<username>>'
EXEC sp_AddRoleMember 'db_datareader', 'CRBCLOUD\svcSAWSRSISstg'
EXEC sp_AddRoleMember 'db_datareader', '<<username>>'
EXEC sp_AddRoleMember 'db_datareader', '<<username>>'
EXEC sp_AddRoleMember 'db_datareader', 'CRBCLOUD\<<username>>'
EXEC sp_AddRoleMember 'db_datawriter', '<<username>>'
EXEC sp_AddRoleMember 'db_datawriter', '<<username>>'
EXEC sp_AddRoleMember 'db_datawriter', '<<username>>'
EXEC sp_AddRoleMember 'db_datawriter', 'CRBCLOUD\<<username>>'


use [IdentityServerINT]
go

CREATE USER [CRBCLOUD\<<username>>] FOR LOGIN [CRBCLOUD\<<username>>]
CREATE USER [CRBCLOUD\svcAAWSRSISstg02] FOR LOGIN [CRBCLOUD\svcAAWSRSISstg02]
CREATE USER [CRBCLOUD\svcAAWSRSISstg01] FOR LOGIN [CRBCLOUD\svcAAWSRSISstg01]
CREATE USER [CRBCLOUD\svcSAWSRSISstg] FOR LOGIN [CRBCLOUD\svcSAWSRSISstg]
CREATE USER [<<username>>] FOR LOGIN [<<username>>]
CREATE USER [<<username>>] FOR LOGIN [<<username>>]


EXEC sp_AddRoleMember 'db_executor', 'CRBCLOUD\<<username>>'
EXEC sp_AddRoleMember 'db_executor', '<<username>>'
EXEC sp_AddRoleMember 'db_executor', '<<username>>'
EXEC sp_AddRoleMember 'db_owner', 'dbo'
EXEC sp_AddRoleMember 'db_ddladmin', 'CRBCLOUD\<<username>>'
EXEC sp_AddRoleMember 'db_ddladmin', '<<username>>'
EXEC sp_AddRoleMember 'db_ddladmin', '<<username>>'
EXEC sp_AddRoleMember 'db_datareader', 'CRBCLOUD\<<username>>'
EXEC sp_AddRoleMember 'db_datareader', 'CRB\SecIdsrvDevelopersGrp'
EXEC sp_AddRoleMember 'db_datareader', 'CRBCLOUD\svcAAWSRSISstg02'
EXEC sp_AddRoleMember 'db_datareader', 'CRBCLOUD\svcAAWSRSISstg01'
EXEC sp_AddRoleMember 'db_datareader', 'CRBCLOUD\svcSAWSRSISstg'
EXEC sp_AddRoleMember 'db_datareader', '<<username>>'
EXEC sp_AddRoleMember 'db_datareader', '<<username>>'
EXEC sp_AddRoleMember 'db_datawriter', 'CRBCLOUD\<<username>>'
EXEC sp_AddRoleMember 'db_datawriter', '<<username>>'
EXEC sp_AddRoleMember 'db_datawriter', '<<username>>'

use [IdentityServerSelfServiceINT]
go
CREATE USER [CRBCLOUD\<<username>>] FOR LOGIN [CRBCLOUD\<<username>>]
CREATE USER [CRBCLOUD\svcAAWSRSISstg02] FOR LOGIN [CRBCLOUD\svcAAWSRSISstg02]
CREATE USER [CRBCLOUD\svcAAWSRSISstg01] FOR LOGIN [CRBCLOUD\svcAAWSRSISstg01]
CREATE USER [CRBCLOUD\svcSAWSRSISstg] FOR LOGIN [CRBCLOUD\svcSAWSRSISstg]
CREATE USER [<<username>>] FOR LOGIN [<<username>>]


EXEC sp_AddRoleMember 'db_executor', 'CRBCLOUD\<<username>>'
EXEC sp_AddRoleMember 'db_executor', '<<username>>'
EXEC sp_AddRoleMember 'db_owner', 'dbo'
EXEC sp_AddRoleMember 'db_ddladmin', 'CRBCLOUD\<<username>>'
EXEC sp_AddRoleMember 'db_ddladmin', '<<username>>'
EXEC sp_AddRoleMember 'db_datareader', 'CRB\SecIdsrvDevelopersGrp'
EXEC sp_AddRoleMember 'db_datareader', 'CRBCLOUD\<<username>>'
EXEC sp_AddRoleMember 'db_datareader', 'CRBCLOUD\svcAAWSRSISstg02'
EXEC sp_AddRoleMember 'db_datareader', 'CRBCLOUD\svcAAWSRSISstg01'
EXEC sp_AddRoleMember 'db_datareader', 'CRBCLOUD\svcSAWSRSISstg'
EXEC sp_AddRoleMember 'db_datareader', '<<username>>'
EXEC sp_AddRoleMember 'db_datawriter', 'CRBCLOUD\<<username>>'
EXEC sp_AddRoleMember 'db_datawriter', '<<username>>'

use [IdentityServerUsersINT]
go
CREATE USER [CRBCLOUD\<<username>>] FOR LOGIN [CRBCLOUD\<<username>>]
CREATE USER [CRBCLOUD\<<username>>] FOR LOGIN [CRBCLOUD\<<username>>]
CREATE USER [CRBCLOUD\svcAAWSRSISstg02] FOR LOGIN [CRBCLOUD\svcAAWSRSISstg02]
CREATE USER [CRBCLOUD\svcAAWSRSISstg01] FOR LOGIN [CRBCLOUD\svcAAWSRSISstg01]
CREATE USER [CRBCLOUD\svcSAWSRSISstg] FOR LOGIN [CRBCLOUD\svcSAWSRSISstg]
CREATE USER [<<username>>] FOR LOGIN [<<username>>]
CREATE USER [<<username>>] FOR LOGIN [<<username>>]
CREATE USER [<<username>>] FOR LOGIN [<<username>>]


EXEC sp_AddRoleMember 'db_executor', 'CRBCLOUD\<<username>>'
EXEC sp_AddRoleMember 'db_executor', 'CRBCLOUD\<<username>>'
EXEC sp_AddRoleMember 'db_executor', '<<username>>'
EXEC sp_AddRoleMember 'db_executor', '<<username>>'
EXEC sp_AddRoleMember 'db_executor', '<<username>>'
EXEC sp_AddRoleMember 'db_owner', 'dbo'
EXEC sp_AddRoleMember 'db_ddladmin', 'CRBCLOUD\<<username>>'
EXEC sp_AddRoleMember 'db_ddladmin', 'CRBCLOUD\<<username>>'
EXEC sp_AddRoleMember 'db_ddladmin', '<<username>>'
EXEC sp_AddRoleMember 'db_ddladmin', '<<username>>'
EXEC sp_AddRoleMember 'db_datareader', 'CRB\SecIdsrvDevelopersGrp'
EXEC sp_AddRoleMember 'db_datareader', 'CRBCLOUD\<<username>>'
EXEC sp_AddRoleMember 'db_datareader', 'CRBCLOUD\<<username>>'
EXEC sp_AddRoleMember 'db_datareader', 'CRBCLOUD\svcAAWSRSISstg02'
EXEC sp_AddRoleMember 'db_datareader', 'CRBCLOUD\svcAAWSRSISstg01'
EXEC sp_AddRoleMember 'db_datareader', 'CRBCLOUD\svcSAWSRSISstg'
EXEC sp_AddRoleMember 'db_datareader', '<<username>>'
EXEC sp_AddRoleMember 'db_datareader', '<<username>>'
EXEC sp_AddRoleMember 'db_datareader', '<<username>>'
EXEC sp_AddRoleMember 'db_datawriter', 'CRBCLOUD\<<username>>'
EXEC sp_AddRoleMember 'db_datawriter', 'CRBCLOUD\<<username>>'
EXEC sp_AddRoleMember 'db_datawriter', '<<username>>'
EXEC sp_AddRoleMember 'db_datawriter', '<<username>>'
EXEC sp_AddRoleMember 'db_datawriter', '<<username>>'



