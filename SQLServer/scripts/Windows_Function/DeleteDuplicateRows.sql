

-- delete duplicate rows

use [P2PInvalidRequests]
go

    with CTE1 as (
  select ID,[Error],OriginalRequestId, RequesterId, RequestJson,ROW_NUMBER() OVER (PARTITION BY OriginalRequestId, RequesterId order by OriginalRequestId, RequesterId   ) 
  rownum from [P2PInvalidRequests].[dbo].[InvalidRequests]  )
select * from CTE1 where rownum > 1




