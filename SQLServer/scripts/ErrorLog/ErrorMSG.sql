
select * from  sys.messages where language_id = 1033

with CTE1 as (
select ROW_NUMBER() over (partition by message_id order by [text] desc) as rownum, message_id, [text]
from sys.messages
) 
select * from CTE1 where rownum = 1

select * from  sys.messages where language_id = 1033
except
select * from sys.messages
where ((language_id = 1033) and ([text] like '%Error%' or [text] like '%fail%'  or [text] like '%Fail%' or [text] like '%Timeout%' or [text] like '%not%'  
or [text] like '%invalid%' or [text] like '%allowed%' or [text] like '%Incorrect%' or [text] like '%Cannot%' or [text] like '%Cannot%'
or [text] like '%too long%' or [text] like '%cannot%' or [text] like '%incorrect%' or [text] like '%Invalid%' or [text] like '%error%'
or [text] like '%Cannot join%' or [text] like '%DUMP%' or [text] like '%Exception%' or [text] like '%dump%' or [text] like '%Warning%'
or [text] like '%inactive%' or [text] like '%terminate%' or [text] like '%duplicate%' or [text] like '%Too many%' or [text] like '%must be%'
or [text] like '%Missing%' or [text] like '%Must pass%'  or [text] like '%must%' or [text] like '%nomust%' or [text] like '%Unable%'
or [text] like '%cancelled%' or [text] like '%out of%' or [text] like '%time out%' or [text] like '%exceed%' or [text] like '%can only%'
or [text] like '%no%' or [text] like '%Corruption%' or [text] like '%No%' or [text] like '%insufficient%' or [text] like '%overflow%'
or [text] like '%Unclosed%' or [text] like '%require%' or [text] like '%incompatible%' or [text] like '%corrupted%' or [text] like '%already%'
or [text] like '%expected%' or [text] like '%Undeclare%' or [text] like '%permission%' or [text] like '%large%' or [text] like '%Ambiguous%'
or [text] like '%Time-out%' or [text] like '%wrong%' or [text] like '%buffer%' or [text] like '%Conflict%' or [text] like '%range%' 
 or [text] like '%mismatch%' or [text] like '%sysadmin%' or [text] like '%recover%' or [text] like '%timed out%' or [text] like '%don''t%'
or [text] like '%doesn''t%' or [text] like '%pending%' or [text] like '%disable%' or [text] like '%Should be%' or [text] like '%inconsistency%'
or [text] like '%bad%'))



