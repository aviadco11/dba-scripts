
SELECT
    blocked.pid                                        AS blocked_pid,
    blocked.query                                      AS blocked_query,
    blocking.pid                                       AS blocker_pid,
    blocking.query                                     AS blocker_query,
    blocked.wait_event_type,
    blocked.wait_event,
    EXTRACT(EPOCH FROM (now() - blocked.query_start))  AS blocked_for_seconds
FROM pg_stat_activity AS blocked
JOIN pg_stat_activity AS blocking
    ON blocking.pid = ANY(pg_blocking_pids(blocked.pid))
WHERE cardinality(pg_blocking_pids(blocked.pid)) > 0
ORDER BY blocked_for_seconds DESC;







SELECT
    blocked.pid                                          AS blocked_pid,
    blocked.usename                                      AS blocked_user,
    blocked.state                                        AS blocked_state,
    blocked.wait_event_type,
    blocked.wait_event,
    EXTRACT(EPOCH FROM now() - blocked.query_start)::int AS blocked_seconds,
    blocked.query                                        AS blocked_query,
    blocking.pid                                         AS blocker_pid,
    blocking.usename                                     AS blocker_user,
    blocking.state                                       AS blocker_state,
    EXTRACT(EPOCH FROM now() - blocking.state_change)::int AS blocker_held_seconds,
    blocking.query                                       AS blocker_query
FROM pg_stat_activity AS blocked
JOIN pg_stat_activity AS blocking
    ON blocking.pid = ANY(pg_blocking_pids(blocked.pid))
WHERE cardinality(pg_blocking_pids(blocked.pid)) > 0
ORDER BY blocked_seconds DESC;

