
-- add comments
comment on table person3311 IS 'AAADSFEWR';
comment on COLUMN person3311.about IS 'sadsad';

select obj_description('person3311'::regclass, 'pg_class');

-- to see all comments
select description from pg_description
join pg_class on pg_description.objoid = pg_class.oid
where relname = 'person3311'

