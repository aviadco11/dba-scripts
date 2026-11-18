
restore filelistonly from disk = '\\<<ip_address>>\<<s3_bucket>>\Prod\DBProdClust01$AG-Arix\ArixUnderwriting\FULL_COPY_ONLY\DBProdClust01$AG-Arix_ArixUnderwriting_FULL_COPY_ONLY_20230808_023701_1.bak',
disk = '\\<<ip_address>>\<<s3_bucket>>\Prod\DBProdClust01$AG-Arix\ArixUnderwriting\FULL_COPY_ONLY\DBProdClust01$AG-Arix_ArixUnderwriting_FULL_COPY_ONLY_20230808_023701_2.bak',
disk = '\\<<ip_address>>\<<s3_bucket>>\Prod\DBProdClust01$AG-Arix\ArixUnderwriting\FULL_COPY_ONLY\DBProdClust01$AG-Arix_ArixUnderwriting_FULL_COPY_ONLY_20230808_023701_3.bak',
disk = '\\<<ip_address>>\<<s3_bucket>>\Prod\DBProdClust01$AG-Arix\ArixUnderwriting\FULL_COPY_ONLY\DBProdClust01$AG-Arix_ArixUnderwriting_FULL_COPY_ONLY_20230808_023701_4.bak',
disk = '\\<<ip_address>>\<<s3_bucket>>\Prod\DBProdClust01$AG-Arix\ArixUnderwriting\FULL_COPY_ONLY\DBProdClust01$AG-Arix_ArixUnderwriting_FULL_COPY_ONLY_20230808_023701_5.bak',
disk = '\\<<ip_address>>\<<s3_bucket>>\Prod\DBProdClust01$AG-Arix\ArixUnderwriting\FULL_COPY_ONLY\DBProdClust01$AG-Arix_ArixUnderwriting_FULL_COPY_ONLY_20230808_023701_6.bak',
disk = '\\<<ip_address>>\<<s3_bucket>>\Prod\DBProdClust01$AG-Arix\ArixUnderwriting\FULL_COPY_ONLY\DBProdClust01$AG-Arix_ArixUnderwriting_FULL_COPY_ONLY_20230808_023701_7.bak',
disk = '\\<<ip_address>>\<<s3_bucket>>\Prod\DBProdClust01$AG-Arix\ArixUnderwriting\FULL_COPY_ONLY\DBProdClust01$AG-Arix_ArixUnderwriting_FULL_COPY_ONLY_20230808_023701_8.bak'







use [master] 

alter database [ArixUnderwriting] set single_user with rollback immediate
restore database [ArixUnderwriting] from disk = '\\<<ip_address>>\<<s3_bucket>>\Prod\DBProdClust01$AG-Arix\ArixUnderwriting\FULL_COPY_ONLY\DBProdClust01$AG-Arix_ArixUnderwriting_FULL_COPY_ONLY_20230808_023701_1.bak',
disk = '\\<<ip_address>>\<<s3_bucket>>\Prod\DBProdClust01$AG-Arix\ArixUnderwriting\FULL_COPY_ONLY\DBProdClust01$AG-Arix_ArixUnderwriting_FULL_COPY_ONLY_20230808_023701_2.bak',
disk = '\\<<ip_address>>\<<s3_bucket>>\Prod\DBProdClust01$AG-Arix\ArixUnderwriting\FULL_COPY_ONLY\DBProdClust01$AG-Arix_ArixUnderwriting_FULL_COPY_ONLY_20230808_023701_3.bak',
disk = '\\<<ip_address>>\<<s3_bucket>>\Prod\DBProdClust01$AG-Arix\ArixUnderwriting\FULL_COPY_ONLY\DBProdClust01$AG-Arix_ArixUnderwriting_FULL_COPY_ONLY_20230808_023701_4.bak',
disk = '\\<<ip_address>>\<<s3_bucket>>\Prod\DBProdClust01$AG-Arix\ArixUnderwriting\FULL_COPY_ONLY\DBProdClust01$AG-Arix_ArixUnderwriting_FULL_COPY_ONLY_20230808_023701_5.bak',
disk = '\\<<ip_address>>\<<s3_bucket>>\Prod\DBProdClust01$AG-Arix\ArixUnderwriting\FULL_COPY_ONLY\DBProdClust01$AG-Arix_ArixUnderwriting_FULL_COPY_ONLY_20230808_023701_6.bak',
disk = '\\<<ip_address>>\<<s3_bucket>>\Prod\DBProdClust01$AG-Arix\ArixUnderwriting\FULL_COPY_ONLY\DBProdClust01$AG-Arix_ArixUnderwriting_FULL_COPY_ONLY_20230808_023701_7.bak',
disk = '\\<<ip_address>>\<<s3_bucket>>\Prod\DBProdClust01$AG-Arix\ArixUnderwriting\FULL_COPY_ONLY\DBProdClust01$AG-Arix_ArixUnderwriting_FULL_COPY_ONLY_20230808_023701_8.bak'
with move 'ArixUnderwriting' to 'D:\MSSQL\DATA\ArixUnderwriting.mdf',
move 'ARIXUNDERWRITING_NServiceBus_COMMENTS' to 'D:\MSSQL\DATA\ArixUnderwriting_NServiceBus_COMMENTS.ndf',
move 'ArixUnderwriting_dbo_COMMENTS' to 'D:\MSSQL\DATA\ArixUnderwriting_dbo_COMMENTS.ndf',
move 'ArixUnderwriting_log' to 'D:\MSSQL\DATA\ArixUnderwriting_log.ldf',
replace, stats=5
alter database [ArixUnderwriting] set multi_user with rollback immediate




