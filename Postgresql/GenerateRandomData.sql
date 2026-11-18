
-- generate series 1..5
select * from generate_series(1,5);

-- generate random series
select generate_series * random() from generate_series(1,5);

-- generate random series of double precision data
select random()+11*random()*random() from generate_series(1,5);;

-- generate series
select * from generate_series(1.1,5, 0.3);

-- get datetime
select date_trunc('day', NOW());

-- get date
select CURRENT_DATE, now();


-- to generate normally distributed data
select random_normal(0,1)::integer
from generate_series(1,5)
order by 1;

-- to generate random uuid
create extension if not exists "pgcrypto";
select gen_random_uuid();

-- to generate dates series
select * from generate_series('2008-03-01 00:00'::timestamp,'2008-03-04 12:00', '10 hours');



