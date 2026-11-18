
-- find executiopn plan by statement

use ArixUnderwriting

SELECT top 20 cplan.plan_handle,cplan.usecounts, cplan.objtype, qtext.text, qplan.query_plan, cplan.cacheobjtype, db_name(qplan.dbid) as DBName
FROM sys.dm_exec_cached_plans AS cplan
CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS qtext
CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qplan
where objtype = 'Prepared' and qtext.text like '%GetLoansByComplianceType%'
ORDER BY cplan.usecounts DESC


-- find stored procedure in execution plan
SELECT OBJECT_NAME(procstats.object_id) AS proc_name,

    --execution plan

     qplan.query_plan,

    --total stats

    procstats.execution_count,

    procstats.total_logical_reads,

    procstats.total_physical_reads,

    procstats.total_worker_time/1000000.0 AS total_worker_time_sec,

    procstats.total_elapsed_time/1000000.0 AS total_elapsed_time_sec,

    --last stats

    procstats.last_execution_time,

    procstats.last_elapsed_time AS last_elapsed_time_microsec,

    procstats.last_elapsed_time/1000000.0 AS last_elapsed_time_sec,

    procstats.last_logical_reads,

    procstats.last_physical_reads,

    procstats.last_worker_time AS last_cpu_time_microsec,

    procstats.last_worker_time/1000000.0 AS last_cpu_time

    FROM sys.dm_exec_procedure_stats procstats

    CROSS APPLY sys.dm_exec_query_plan (procstats.plan_handle) qplan

    WHERE procstats.database_id = DB_ID()
    
                AND procstats.type = 'P' 
    
                AND OBJECT_NAME(procstats.object_id) = 'GetLoansByComplianceType'

    ORDER BY proc_name

    --  total_logical_reads desc

    --last_execution_time desc

    --last_logical_reads desc

   -- last_worker_time desc


