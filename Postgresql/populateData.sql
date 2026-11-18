
create extension if not exists "pgcrypto";
create extension if not exists "uuid-ossp";

CREATE OR REPLACE FUNCTION getPaymentId(num integer) RETURNS UUID LANGUAGE plpgsql
as
$$
  DECLARE iidd UUID;
  begin
                select "PaymentId"
                into iidd
                from "Payment"
                offset num limit 1;
                
                RETURN iidd;
  END;
$$;

CREATE OR REPLACE FUNCTION getInterestCalculationMethodId() RETURNS UUID LANGUAGE plpgsql
as
$$
  DECLARE iidd UUID;
  begin
                select "InterestCalculationMethodId"
                into iidd
                from "InterestCalculationMethod"
                limit 1;
                
                RETURN iidd;
  END;
$$;

CREATE OR REPLACE FUNCTION getVolumeFeeCalculationMethodId() RETURNS UUID LANGUAGE plpgsql
as
$$
  DECLARE iidd UUID;
  begin
                select "VolumeFeeCalculationMethodId"
                into iidd
                from "VolumeFeeCalculationMethod"
                limit 1;
                
                RETURN iidd;
  END;
$$;

CREATE OR REPLACE FUNCTION getSeasoningId() RETURNS UUID LANGUAGE plpgsql
as
$$
  DECLARE iidd UUID;
  begin
                select "SeasoningId"
                into iidd
                from "Seasoning"
                limit 1;
                
                RETURN iidd;
  END;
$$;



CREATE OR REPLACE FUNCTION getAccountid() RETURNS UUID LANGUAGE plpgsql
as
$$
  DECLARE iidd UUID;
  begin
                select "AccountId"
                into iidd
                from "Account"
                limit 1;
                
                RETURN iidd;
  END;
$$;

CREATE OR REPLACE FUNCTION getLoanid() RETURNS UUID LANGUAGE plpgsql
as
$$
  DECLARE iidd UUID;
  begin
                select "LoanId"
                into iidd
                from "Loan"
                limit 1;
                
                RETURN iidd;
  END;
$$;



CREATE OR REPLACE FUNCTION getAccountid() RETURNS UUID LANGUAGE plpgsql
as
$$
  DECLARE iidd UUID;
  begin
                select "AccountId"
                into iidd
                from "Account"
                limit 1;
                
                RETURN iidd;
  END;
$$;



CREATE OR REPLACE FUNCTION getAccountingConfigurationuuid() RETURNS UUID LANGUAGE plpgsql
as
$$
  DECLARE iidd UUID;
  begin
                select "AccountingConfigurationId"
                into iidd
                from "AccountingConfiguration"
                limit 1;
                
                RETURN iidd;
  END;
$$;




CREATE OR REPLACE FUNCTION getMpl() RETURNS CHAR(3) LANGUAGE plpgsql
as
$$
  DECLARE iidd CHAR(3);
  begin
                select "MplId"
                into iidd
                from "Mpl"
                limit 1;
                
                RETURN iidd;
  END;
$$;

CREATE OR REPLACE FUNCTION getInvestorId() RETURNS UUID LANGUAGE plpgsql
as
$$
  DECLARE iidd UUID;
  begin
                select "InvestorId"
                into iidd
                from "Investor"
                limit 1;
                
                RETURN iidd;
  END;
$$;


CREATE FUNCTION getuuid() RETURNS UUID LANGUAGE plpgsql
as
$$
  DECLARE uid UUID;
  begin
                select "TierRangeId"
                into uid
                from "TierRange"
                limit 1;
                
                RETURN uid;
  END;
$$;


insert into "__EFMigrationsHistory"
SELECT CONCAT(
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode, CONCAT(
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode1 
FROM generate_series(1,1500);


insert into "AccountObjectiveTypeEntity"
SELECT *,CONCAT(
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
                      chr((random() * 25)::integer + 65), 
                      chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode, CONCAT(
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode1 
FROM generate_series(1,1500) ;



insert into "AccountTypeEntity"
SELECT *,CONCAT(
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
                      chr((random() * 25)::integer + 65), 
                      chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode, CONCAT(
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode1 
FROM generate_series(1,1500) ;



insert into "ContractFeeChargingTypeEntity"
SELECT *,CONCAT(
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
                      chr((random() * 25)::integer + 65), 
                      chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode, CONCAT(
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode1 
FROM generate_series(1,1500) ;




insert into "InterestCalculationTypeEntity"
SELECT *,CONCAT(
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
                      chr((random() * 25)::integer + 65), 
                      chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode, CONCAT(
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode1 
FROM generate_series(1,1500) ;



insert into "Investor"
SELECT gen_random_uuid(),CONCAT(
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
                      chr((random() * 25)::integer + 65), 
                      chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode, CONCAT(
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode1 
FROM generate_series(1,1500) ;




insert into "IssuingBankTypeEntity"
SELECT *,CONCAT(
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
                      chr((random() * 25)::integer + 65), 
                      chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode, CONCAT(
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode1 
FROM generate_series(1,1500) ;



insert into "LoanEventTypeEntity"
SELECT *,CONCAT(
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
                      chr((random() * 25)::integer + 65), 
                      chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode, CONCAT(
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode1 
FROM generate_series(1,1500) ;




insert into "LoanOriginationStatusEntity"
SELECT *,CONCAT(
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
                      chr((random() * 25)::integer + 65), 
                      chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode, CONCAT(
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode1 
FROM generate_series(1,1500) ;




insert into "LoanTypeEntity"
SELECT *,CONCAT(
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
                      chr((random() * 25)::integer + 65), 
                      chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode, CONCAT(
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode1 
FROM generate_series(1,1500) ;





insert into "Mpl"
SELECT CONCAT(
          chr((random() * 24)::integer + 65), 
          chr((random() * 23)::integer + 66),
          chr((random() * 25)::integer + 67)
       ) AS random_passcode, CONCAT(
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode1 
FROM generate_series(1,150) ;


insert into "PaymentStatusEntity"
SELECT *,CONCAT(
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
                      chr((random() * 25)::integer + 65), 
                      chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode, CONCAT(
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode1 
FROM generate_series(1,1500) ;


insert into "PaymentTypeEntity"
SELECT *,CONCAT(
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
                      chr((random() * 25)::integer + 65), 
                      chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode, CONCAT(
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode1 
FROM generate_series(1,1500) ;



insert into "SeasoningPeriodEntity"
SELECT *,CONCAT(
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
                      chr((random() * 25)::integer + 65), 
                      chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode, CONCAT(
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode1 
FROM generate_series(1,1500) ;




insert into "SeasoningStartEntity"
SELECT *,CONCAT(
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
                      chr((random() * 25)::integer + 65), 
                      chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode, CONCAT(
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode1 
FROM generate_series(1,1500) ;


insert into "TierRange"
SELECT gen_random_uuid(),random()+13*random()*random(), random()+13*random()*random()
FROM generate_series(1,1500) ;



insert into "Account"
SELECT gen_random_uuid(),CONCAT(
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
                      chr((random() * 25)::integer + 65), 
                      chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode, CONCAT(
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode1 ,*
FROM generate_series(1,1500) ;


insert into "InterestCalculationMethod"
SELECT gen_random_uuid(),random(),random()+13*random()*random(), 'false', *
FROM generate_series(1,1500) ;



insert into "AccountingConfiguration"
SELECT gen_random_uuid(),CONCAT(
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode1, generate_series('2023-01-31', '2023-12-31', INTERVAL '1 MONTH'), 
                   generate_series('2023-01-31', '2023-12-31', INTERVAL '1 MONTH'), *,
                   getInvestorId(), getMpl(), * 
FROM generate_series(1,150) ;



insert into "LoanSaleStatusEntity"
SELECT *,CONCAT(
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
                      chr((random() * 25)::integer + 65), 
                      chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode, CONCAT(
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode1 
FROM generate_series(1,1500) ;


insert into "Loan"
SELECT gen_random_uuid(),*, 
generate_series('2022-01-31', '2023-12-31', INTERVAL '1 MONTH'), 
                   generate_series('2022-01-31', '2023-12-31', INTERVAL '1 MONTH'),
                   random()+11*random()*random(),
                   random()+12*random()*random(),
                   random()+13*random()*random(),
                   random()+13*random()*random(),
                   random()+16*random()*random(),
                   random()+10*random()*random(),
                   random()+10*random()*random(),
                   generate_series('2022-01-31', '2023-12-31', INTERVAL '1 MONTH'),
                   'false',
                   'true',
                   generate_series('2022-01-31', '2023-12-31', INTERVAL '1 MONTH'),*,*,*, getMpl()
FROM generate_series(1,150) ;



insert into "Seasoning"
SELECT gen_random_uuid(),*, *,*,*
FROM generate_series(1,150) ;


insert into "VolumeFeeCalculationMethod"
SELECT gen_random_uuid(), 'false', getuuid()
FROM generate_series(1,150) ;


insert into "AccountMapping"
SELECT gen_random_uuid(), generate_series('2022-01-31', '2023-12-31', INTERVAL '1 MONTH'),
generate_series('2022-01-31', '2023-12-31', INTERVAL '1 MONTH'),*, getAccountingConfigurationuuid(),
getAccountid()
FROM generate_series(1,150) ;



insert into "Batch"
SELECT gen_random_uuid(), getLoanid() 
FROM generate_series(1,150) ;



insert into "LoanEvent"
SELECT gen_random_uuid(), generate_series('2022-01-31', '2023-12-31', INTERVAL '1 MONTH'), 'xxx',
CONCAT(
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode1, *, getLoanid() 
                   
FROM generate_series(1,150) ;


insert into "Payment"
SELECT gen_random_uuid(),
CONCAT(
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode1, 
CONCAT(
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode2, 
                   generate_series('2022-01-31', '2023-12-31', INTERVAL '1 MONTH'),
                   generate_series('2022-01-31', '2023-12-31', INTERVAL '1 MONTH'),
                   random()+11*random()*random(),*,*,*, getAccountid() , getAccountid(), getLoanid()
FROM generate_series(1,550) ;


insert into "Contract"
SELECT gen_random_uuid(),
CONCAT(
          chr((random() * 25)::integer + 65), 
                                  chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65),
          chr((random() * 25)::integer + 65), 
          chr((random() * 25)::integer + 65)
       ) AS random_passcode1,
generate_series('2021-01-31', '2023-12-31', INTERVAL '1 MONTH'),
  generate_series('2021-01-31', '2023-12-31', INTERVAL '1 MONTH'),
   generate_series('2021-01-31', '2023-12-31', INTERVAL '1 MONTH'),
   *, getMpl(), getInterestCalculationMethodId(), 
   getVolumeFeeCalculationMethodId(),getSeasoningId()
   FROM generate_series(1,550) ;
   
   
do $$
begin
                for cnt in 1..300 loop
                                insert into "PaymentOutbox"
                                SELECT getPaymentId(cnt), '2021-01-31';
                end loop;
end; $$;



-- check rows on tables
CREATE or replace function count_rows(schema text, tablename text) returns integer
as
$body$
declare
  result integer;
  query varchar;
begin
  query := 'SELECT count(1) FROM "' || schema || '"."' || tablename || '"';
  execute query into result;
  return result;
end;
$body$
language plpgsql;


select 
  table_schema,
  table_name, 
  count_rows(table_schema, table_name) as cnt_rows
from information_schema.tables
where 
  table_schema = 'public'  
  and table_type='BASE TABLE'
order by cnt_rows desc;


