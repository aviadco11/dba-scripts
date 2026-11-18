
-- script to build the AG for [<<database_name>>]

-- connect to primary :
------------------------
-- full backup primary
BACKUP DATABASE [Crb.IdentityServerArchive] TO URL = N's3://<<s3_bucket>>/prod/2025/03/31/<<servername>>$<<ag_name>>/Crb.IdentityServerArchive/Crb.IdentityServerArchive.bak'
  WITH  CREDENTIAL = N's3://<<s3_bucket>>/stg',  FORMAT, COMPRESSION, MAXTRANSFERSIZE = 20971520, NAME = N'Crb.IdentityServerArchive_FULL_backup',  STATS = 5

  -- log backup primary
BACKUP LOG [Crb.IdentityServerArchive] TO URL = N's3://<<s3_bucket>>/prod/2025/03/31/<<servername>>$<<ag_name>>/Crb.IdentityServerArchive/Crb.IdentityServerArchive_log.trn'
WITH  CREDENTIAL = N's3://<<s3_bucket>>/stg'

-- connect to secondary :
--------------------------
-- restore full backup secondary
RESTORE DATABASE [Crb.IdentityServerArchive] FROM URL = N's3://<<s3_bucket>>/prod/2025/03/31/<<servername>>$<<ag_name>>/Crb.IdentityServerArchive/Crb.IdentityServerArchive.bak'
WITH  CREDENTIAL = N's3://<<s3_bucket>>/stg', NORECOVERY,
STATS=5, 
MOVE 'Crb.IdentityServerArchive' to 'D:\MSSQL\DATA\Crb.IdentityServerArchive.mdf',
move 'Crb.IdentityServerArchive_log' to 'L:\MSSQL\DATA\Crb.IdentityServerArchive_log.ldf'


-- restore log backup secondary
  RESTORE LOG [Crb.IdentityServerArchive]  
FROM  URL = N's3://<<s3_bucket>>/prod/2025/03/31/<<servername>>$<<ag_name>>/Crb.IdentityServerArchive/Crb.IdentityServerArchive_log.trn'  
WITH  CREDENTIAL = N's3://<<s3_bucket>>/stg', 
NORECOVERY 


