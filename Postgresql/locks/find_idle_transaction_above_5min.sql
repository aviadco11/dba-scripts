
SELECT

    pid,

    application_name,

    client_addr,

    now() - xact_start AS transaction_age,

    now() - backend_start AS connection_age,

    query

FROM pg_stat_activity

WHERE state = 'idle in transaction'

  AND now() - xact_start > interval '5 minutes'

ORDER BY transaction_age DESC;









-- terminate all idel transaction above 5 minutes 
WITH blocker_sessions AS (
    SELECT DISTINCT blocking.pid
    FROM pg_stat_activity AS blocked
    CROSS JOIN LATERAL unnest(pg_blocking_pids(blocked.pid)) AS blocker_pid
    JOIN pg_stat_activity AS blocking
        ON blocking.pid = blocker_pid
    WHERE blocked.query_start < now() - interval '5 minutes'
      AND blocked.wait_event_type = 'Lock'
      AND blocking.pid <> pg_backend_pid()
      AND blocking.backend_type = 'client backend'
)
SELECT
    pid,
    pg_terminate_backend(pid) AS terminated
FROM blocker_sessions;

