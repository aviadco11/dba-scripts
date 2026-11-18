
select
  relname as table_name,
  pg_size_pretty(pg_total_relation_size(relid)) as "Table Size",
  pg_size_pretty(pg_indexes_size(relid)) as "Index Size",
  pg_size_pretty(pg_relation_size(relid)) as "Total Size"
from pg_catalog.pg_statio_user_tables
order by pg_total_relation_size(relid) desc;

