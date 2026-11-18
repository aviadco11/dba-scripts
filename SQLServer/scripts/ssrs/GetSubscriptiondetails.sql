
-- get subscription details
use [ReportServer]
go

SELECT Reportname = c.Name 
  ,FileLocation = c.Path
  ,SubscriptionDesc=su.Description 
  ,Subscriptiontype=su.EventType ,
   su.SubscriptionID
  ,su.LastStatus 
  ,su.LastRunTime 
  ,Schedulename=sch.Name 
  ,ScheduleType = sch.EventType 
  ,ScheduleFrequency = 
   CASE sch.RecurrenceType 
   WHEN 1 THEN 'Once' 
   WHEN 2 THEN 'Hourly' 
   WHEN 4 THEN 'Daily/Weekly' 
   WHEN 5 THEN 'Monthly' 
   END 
  ,su.Parameters 
  FROM Reportserver.dbo.Subscriptions su 
  JOIN Reportserver.dbo.Catalog c 
    ON su.Report_OID = c.ItemID 
  JOIN Reportserver.dbo.ReportSchedule rsc 
    ON rsc.ReportID = c.ItemID 
   AND rsc.SubscriptionID = su.SubscriptionID 
  JOIN Reportserver.dbo.Schedule Sch 
    ON rsc.ScheduleID = sch.ScheduleID 
--where c.Name  like '%Closed Debit Card%'
--where su.SubscriptionID = 'accc18a2-2953-4f51-9343-c245e4cb533e'
--where su.LastStatus like '%error%' and su.LastStatus not like '%0%'
ORDER BY LastRunTime DESC



