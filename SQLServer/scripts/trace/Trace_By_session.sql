
use DBAUtilities
go

-- start the trace
CREATE PROCEDURE [dbo].[spTraceMySessionStart1]
@spid INT
AS
DECLARE @rc INT
DECLARE @TraceID INT
DECLARE @maxfilesize bigint
SET @maxfilesize = 5
DECLARE @filename NVARCHAR(245)
SET @filename = 'C:\temp\TraceMySession23_' + CONVERT(NVARCHAR(10), @spid) + '_d' + REPLACE(CONVERT(VARCHAR, GETDATE(), 111), '/', '') + REPLACE(CONVERT(VARCHAR, GETDATE(), 108), ':', '')
EXEC @rc = sp_trace_create @TraceID output, 2, @filename, @maxfilesize, NULL
IF (@rc != 0) GOTO error

-- Set the events
DECLARE @on bit
SET @on = 1
EXEC sp_trace_setevent @TraceID, 12, 1, @on  -- TextData
EXEC sp_trace_setevent @TraceID, 12, 12, @on -- SPID
EXEC sp_trace_setevent @TraceID, 12, 13, @on -- Duration

-- Set the Filters
EXEC sp_trace_setfilter @TraceID, 12, 1, 0, @spid

-- Start the trace
EXEC sp_trace_setstatus @TraceID, 1

-- Display trace id for future references
SELECT TraceID = @TraceID
GOTO finish

error:
SELECT ErrorCode = @rc
finish:

-- stop the trace
CREATE PROCEDURE [dbo].[spTraceMySessionStart2]
@TraceID INT
AS
EXEC sp_trace_setstatus @TraceID, 0  -- Stop the trace
EXEC sp_trace_setstatus @TraceID, 2  -- Close the trace

-- run the trace
EXEC dbo.[spTraceMySessionStart1] 56

-- get information on the trace
SELECT TEXTData, StartTime , Duration
FROM ::fn_trace_gettable('c:\temp\TraceMySession23_56_d20250120133726.trc', DEFAULT) 
WHERE TEXTData IS NOT NULL 


-- to find the trace id
SELECT *
FROM sys.traces
WHERE Status = 1

EXEC [dbo].[spTraceMySessionStop] @TraceID = 2


