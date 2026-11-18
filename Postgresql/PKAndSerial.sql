


create table person (
  id               serial primary key,
  first_name       text not null check (char_length(first_name) < 80),
  last_name        text check (char_length(last_name) < 80),
  about            text,
  created_at       timestamp default now()
);


create table person22 (
  id               bigserial primary key,
  first_name       text not null check (char_length(first_name) < 80),
  last_name        text check (char_length(last_name) < 80),
  about            text,
  created_at       timestamp default now()
);

create table person33 (
  id               bigint GENERATED ALWAYS as IDENTITY primary key,
  first_name       text not null check (char_length(first_name) < 80),
  last_name        text check (char_length(last_name) < 80),
  about            text,
  created_at       timestamp default now()
);


create extension if not exists "uuid-ossp";

create table person1 (
  id uuid primary key default uuid_generate_v1mc(),
  first_name       text not null check (char_length(first_name) < 80),
  last_name        text check (char_length(last_name) < 80),
  about            text,
  created_at       timestamp default now()
);


create extension if not exists "pgcrypto";

create table person2 (
  id uuid primary key default gen_random_uuid(),
  first_name       text not null check (char_length(first_name) < 80),
  last_name        text check (char_length(last_name) < 80),
  about            text,
  created_at       timestamp default now()
);

insert into person(first_name,last_name,about) values ('dsfsdf','fdgfdg', 'dsfdsfdsf');
insert into person(first_name,last_name,about) values ('dcxxf','fxxxdg', 'dsxxxxxdsf');
insert into person1(first_name,last_name,about) values ('dsfsdf', 'fdgfdg', 'dsfdsfdsf');
insert into person1(first_name,last_name,about) values ('dcxxf','fxxxdg', 'dsxxxxxdsf');
insert into person2(first_name,last_name,about) values ('dsfsdf', 'fdgfdg', 'dsfdsfdsf');
insert into person2(first_name,last_name,about) values ('dcxxf','fxxxdg', 'dsxxxxxdsf');

select * from person;
select * from person1;
select * from person2;




