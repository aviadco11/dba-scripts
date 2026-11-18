
-- check mail status, start it if it's in stop mode

DECLARE @MailStatus TABLE (CurrentState VARCHAR(10))
INSERT @MailStatus
EXEC msdb.dbo.sysmail_help_status_sp;

IF NOT EXISTS(
      SELECT 1 FROM @MailStatus
      WHERE CurrentState = 'STARTED'
      )
      BEGIN
            EXECUTE msdb..sysmail_start_sp; -- START IT, IF NEEDED

