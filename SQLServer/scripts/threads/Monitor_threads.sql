
-- script to monitor threads


/* Instance-wide and per-scheduler worker thread availability */
;
-- Summary (instance-wide)
WITH sched AS (
    SELECT
        scheduler_id,
        current_workers_count,
        active_workers_count,
        work_queue_count
    FROM sys.dm_os_schedulers
    WHERE scheduler_id < 255            -- visible/online schedulers only
)
SELECT
    SUM(current_workers_count) AS total_workers,
    SUM(active_workers_count)  AS active_workers,
    SUM(current_workers_count - active_workers_count) AS available_workers,
    SUM(work_queue_count)      AS runnable_tasks_in_queue
FROM sched;

-- Detail (per scheduler)   useful for spotting imbalances or pressure
SELECT
    scheduler_id,
    current_workers_count,
    active_workers_count,
    (current_workers_count - active_workers_count) AS available_workers,
    work_queue_count AS runnable_tasks_in_queue,
    is_online,
    is_idle
FROM sys.dm_os_schedulers
WHERE scheduler_id < 255
ORDER BY scheduler_id;


SELECT
    session_id,
    wait_type,
    wait_time,
    last_wait_type,
    blocking_session_id,
*
FROM sys.dm_exec_requests
WHERE wait_type = 'THREADPOOL'



