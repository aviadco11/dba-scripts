
-- mail events

-- get mail events
select top 100 *
from msdb..sysmail_event_log
order by log_Date desc

EXEC msdb.dbo.sysmail_help_queue_sp @queue_type = 'Mail';
EXEC msdb.dbo.sysmail_help_queue_sp

-- check mail items
select mailitem_id, send_request_date, sent_status, sent_date
from msdb.dbo.sysmail_allitems
order by send_request_date desc

EXEC msdb.dbo.sysmail_help_status_sp;




-- mail events in rds sql server
SELECT sent_status,* FROM msdb.dbo.rds_fn_sysmail_allitems() order by send_request_date desc; --WHERE sent_status='sent' or 'failed' or 'unsent'

SELECT * FROM msdb.dbo.rds_fn_sysmail_event_log() order by log_Date desc;


EXECUTE msdb.dbo.rds_sysmail_control start;
GO

EXECUTE msdb.dbo.rds_sysmail_control state;
GO

EXECUTE msdb.dbo.rds_sysmail_control stop;
GO

