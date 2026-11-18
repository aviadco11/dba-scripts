
use [DBAUtilities]

EXECUTE [DBAUtilities].dbo.DatabaseBackup
       @Databases = 'ArixUnderwriting',
       @Directory ='\\<<ip_address>>\<<s3_bucket>>\DEV\ad_hocbackup\' ,
       @BackupType = 'FULL',
       @Verify = 'N',
       @CheckSum = 'N',
       @Compress = 'Y',
       @CopyOnly='Y', 
@BlockSize  = 8192

