
-- example with rank and lead

;with cte1 as(
select RANK() over (partition by [database_name] order by [dd hh:mm:ss.mss] desc) as rownum,* from [LongRunningQuery].[VWGetResForStakeHolder])
select *, LEAD(rownum,1) over(order by [database_name]) nextrownum into #QueryAginfo from cte1

