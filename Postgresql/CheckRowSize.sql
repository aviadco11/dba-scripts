


select pg_column_size(row()) AS empty,
                   pg_column_size(row(0::SMALLINT)) AS byte2,
                   pg_column_size(row(0::BIGINT)) AS byte8,
                   pg_column_size(row(0::SMALLINT, 0::BIGINT)) AS byte16,
                   pg_column_size(row(0::BIGINT, 0::SMALLINT)) AS byte10,
                   pg_column_size(row(0::BIGINT, 0::INT)) AS bytebigintint,
                   pg_column_size(row(0::INT, 0::BIGINT)) AS byteintbig,
                   pg_column_size(row(0::INT, 2::INT)) AS byteintint;
                   
                   pg_column_size(row(0::BIGINT, 0::INT)) AS byte12,
                   pg_column_size(row(0::TEXT, 0::INT)) AS byte12,
                   pg_column_size(row(0::INT, 'sad'::TEXT)) AS byte12;
                   
                   
select pg_column_size(row('gjhjyjytuytjytjghjhgjytuytuytu'::character varying(1500))) AS byte8,
                   pg_column_size(row('2023-01-01'::timestamp)) AS byte2,
                   pg_column_size(row('2023-01-01'::timestamp without time zone)) AS byte2;
                   
                   


