
SELECT l.pid,
       l.mode,
       l.granted,
       a.usename,
       a.state,
       a.wait_event_type,
       a.wait_event,
       EXTRACT(EPOCH FROM now() - a.query_start)::int AS age_seconds,
       a.query
FROM pg_locks l
JOIN pg_stat_activity a ON a.pid = l.pid
JOIN pg_class c         ON c.oid = l.relation
JOIN pg_namespace n     ON n.oid = c.relnamespace
WHERE n.nspname = 'selling_x'
  AND c.relname = 'contract'
ORDER BY l.granted DESC, age_seconds DESC;

--granted = true → holding the lock (root blocker)
--granted = false → waiting for the lock (DDL + victims)


-- show all exlusive lokc on the relation 
SELECT
    l.pid,
    l.mode,
    l.granted,
    a.usename,
    a.application_name,
    a.client_addr,
    a.state,
    a.wait_event_type,
    a.wait_event,
    EXTRACT(
        EPOCH FROM now() - COALESCE(a.xact_start, a.query_start)
    )::int AS age_seconds,
    a.xact_start,
    a.query_start,
    a.query
FROM pg_locks AS l
JOIN pg_stat_activity AS a
    ON a.pid = l.pid
JOIN pg_class AS c
    ON c.oid = l.relation
JOIN pg_namespace AS n
    ON n.oid = c.relnamespace
WHERE l.locktype = 'relation'
  AND n.nspname = 'selling_x'
  AND c.relname = 'contract'
  AND l.mode IN (
      'RowExclusiveLock',
      'ShareRowExclusiveLock',
      'ExclusiveLock',
      'AccessExclusiveLock'
  )
ORDER BY
    l.granted DESC,
    age_seconds DESC;




