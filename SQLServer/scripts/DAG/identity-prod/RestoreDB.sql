



RESTORE DATABASE [DelegatedAdministration]  
FROM  URL = N'S3://<<s3_bucket>>/Prod/DBProdClust01$AG-IDSERVER/DelegatedAdministration/FULL_COPY_ONLY/DBProdClust01$AG-IDSERVER_DelegatedAdministration_FULL_COPY_ONLY_20250210_064213.bak'  
WITH  CREDENTIAL = N's3://<<s3_bucket>>/prod', 
REPLACE,NORECOVERY,  NOUNLOAD,  STATS = 5, 
MOVE 'DelegatedAdministration' TO 'D:\MSSQL\DATA\DelegatedAdministration.mdf' ,
MOVE 'DelegatedAdministration_log' TO 'L:\MSSQL\DATA\DelegatedAdministration_log.ldf'
GO

RESTORE LOG [DelegatedAdministration] 
FROM URL = N'S3://<<s3_bucket>>/Prod/DBProdClust01$AG-IDSERVER/DelegatedAdministration/LOG/DBProdClust01$AG-IDSERVER_DelegatedAdministration_LOG_20250210_064927.trn' 
WITH CREDENTIAL = N's3://<<s3_bucket>>/prod', NORECOVERY,  NOUNLOAD,  STATS = 10
GO


--------------------------------
RESTORE DATABASE [Crb.IdentityServer] 
FROM  URL = N'S3://<<s3_bucket>>/Prod/DBProdClust01$AG-IDSERVER/Crb.IdentityServer/FULL_COPY_ONLY/DBProdClust01$AG-IDSERVER_Crb.IdentityServer_FULL_COPY_ONLY_20250210_064019.bak'  
WITH  CREDENTIAL = N's3://<<s3_bucket>>/prod', 
REPLACE,NORECOVERY,  NOUNLOAD,  STATS = 5, 
MOVE 'Crb.IdentityServer' TO 'D:\MSSQL\DATA\Crb.IdentityServer.mdf' ,
MOVE 'Crb.IdentityServer_log' TO 'L:\MSSQL\DATA\Crb.IdentityServer_log.ldf'
GO

RESTORE LOG [Crb.IdentityServer] 
FROM URL = N'S3://<<s3_bucket>>/Prod/DBProdClust01$AG-IDSERVER/Crb.IdentityServer/LOG/DBProdClust01$AG-IDSERVER_Crb.IdentityServer_LOG_20250210_064912.trn' 
WITH CREDENTIAL = N's3://<<s3_bucket>>/prod', NORECOVERY,  NOUNLOAD,  STATS = 10
GO



----------------------------

RESTORE DATABASE [Crb.IdentityServerSelfService] 
FROM  URL = N'S3://<<s3_bucket>>/Prod/DBProdClust01$AG-IDSERVER/Crb.IdentityServerSelfService/FULL_COPY_ONLY/DBProdClust01$AG-IDSERVER_Crb.IdentityServerSelfService_FULL_COPY_ONLY_20250210_064210.bak'  
WITH  CREDENTIAL = N's3://<<s3_bucket>>/prod', 
REPLACE,NORECOVERY,  NOUNLOAD,  STATS = 5, 
MOVE 'Crb.IdentityServerSelfService' TO 'D:\MSSQL\DATA\Crb.IdentityServerSelfService.mdf' ,
MOVE 'Crb.IdentityServerSelfService_log' TO 'L:\MSSQL\DATA\Crb.IdentityServerSelfService_log.ldf'
GO

RESTORE LOG [Crb.IdentityServerSelfService] 
FROM URL = N'S3://<<s3_bucket>>/Prod/DBProdClust01$AG-IDSERVER/Crb.IdentityServerSelfService/LOG/DBProdClust01$AG-IDSERVER_Crb.IdentityServerSelfService_LOG_20250210_064917.trn' 
WITH CREDENTIAL = N's3://<<s3_bucket>>/prod', NORECOVERY,  NOUNLOAD,  STATS = 10
GO


RESTORE DATABASE [Crb.IdentityServerUsers] 
FROM  URL = N'S3://<<s3_bucket>>/Prod/DBProdClust01$AG-IDSERVER/Crb.IdentityServerUsers/FULL_COPY_ONLY/DBProdClust01$AG-IDSERVER_Crb.IdentityServerUsers_FULL_COPY_ONLY_20250210_064212.bak'  
WITH  CREDENTIAL = N's3://<<s3_bucket>>/prod', 
REPLACE,NORECOVERY,  NOUNLOAD,  STATS = 5, 
MOVE 'Crb.IdentityServerUsers' TO 'D:\MSSQL\DATA\Crb.IdentityServerUsers.mdf' ,
MOVE 'Crb.IdentityServerUsers_log' TO 'L:\MSSQL\DATA\Crb.IdentityServerUsers_log.ldf'
GO

RESTORE LOG [Crb.IdentityServerUsers]
FROM URL = N'S3://<<s3_bucket>>/Prod/DBProdClust01$AG-IDSERVER/Crb.IdentityServerUsers/LOG/DBProdClust01$AG-IDSERVER_Crb.IdentityServerUsers_LOG_20250210_064922.trn' 
WITH CREDENTIAL = N's3://<<s3_bucket>>/prod', NORECOVERY,  NOUNLOAD,  STATS = 10
GO


