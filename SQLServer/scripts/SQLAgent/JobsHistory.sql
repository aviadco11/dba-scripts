
SELECT @@servername as server_ip ,
sj.[name],
sh.run_date,
sh.step_name,
STUFF(STUFF(STUFF(RIGHT(REPLICATE('0', 8) + CAST(sh.run_duration as varchar(8)), 8), 3, 0, ':'), 6, 0, ':'), 9, 0, ':') 'run_duration (DD:HH:MM:SS) '
FROM msdb.dbo.sysjobs sj with (nolock)
JOIN msdb.dbo.sysjobhistory sh with (nolock)
ON sj.job_id = sh.job_id
where sh.run_date > 20220805
order by 'run_duration (DD:HH:MM:SS) ' desc



