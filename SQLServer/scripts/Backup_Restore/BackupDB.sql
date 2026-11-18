
use [DBAUtilities]
-- please run at prod08
EXECUTE [DBAUtilities].dbo.DatabaseBackup
       @Databases = 'ArixUnderwriting',
       @Directory ='D:\AdHocBackup\' ,
       @BackupType = 'FULL',
       @Verify = 'N',
       @CheckSum = 'N',
       @Compress = 'Y',
       @CopyOnly='Y', 
@BlockSize  = 8192

