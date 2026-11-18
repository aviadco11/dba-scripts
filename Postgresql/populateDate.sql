
create table "__EFMigrationsHistory"
(
    "MigrationId"    varchar(150) not null
        constraint "PK___EFMigrationsHistory"
            primary key,
    "ProductVersion" varchar(32)  not null
);

select 'aaa'+generate_series(1,5) from generate_series(1,5);
select generate_series(1,5);

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

alter table "__EFMigrationsHistory"
    owner to pgadmin;




create table "AccountObjectiveTypeEntity"
(
    "Id"          integer      not null
        constraint "PK_AccountObjectiveTypeEntity"
            primary key,
    "Value"       varchar(100) not null,
    "Description" varchar(100) not null
);

alter table "AccountObjectiveTypeEntity"
    owner to pgadmin;

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



create table "AccountTypeEntity"
(
    "Id"          integer      not null
        constraint "PK_AccountTypeEntity"
            primary key,
    "Value"       varchar(100) not null,
    "Description" varchar(255) not null
);

alter table "AccountTypeEntity"
    owner to pgadmin;



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

create table "ContractFeeChargingTypeEntity"
(
    "Id"          integer      not null
        constraint "PK_ContractFeeChargingTypeEntity"
            primary key,
    "Value"       varchar(100) not null,
    "Description" varchar(100) not null
);

alter table "ContractFeeChargingTypeEntity"
    owner to pgadmin;



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

create table "InterestCalculationTypeEntity"
(
    "Id"          integer      not null
        constraint "PK_InterestCalculationTypeEntity"
            primary key,
    "Value"       varchar(100) not null,
    "Description" varchar(100) not null
);

alter table "InterestCalculationTypeEntity"
    owner to pgadmin;


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




create table "Investor"
(
    "InvestorId"  uuid        not null
        constraint "PK_Investor"
            primary key,
    "Name"        varchar(50) not null,
    "Description" varchar(150)
);

alter table "Investor"
    owner to pgadmin;

create extension "pgcrypto";

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





create table "IssuingBankTypeEntity"
(
    "Id"          integer      not null
        constraint "PK_IssuingBankTypeEntity"
            primary key,
    "Value"       varchar(100) not null,
    "Description" varchar(100) not null
);

alter table "IssuingBankTypeEntity"
    owner to pgadmin;


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



create table "LoanEventTypeEntity"
(
    "Id"          integer      not null
        constraint "PK_LoanEventTypeEntity"
            primary key,
    "Value"       varchar(100) not null,
    "Description" varchar(100) not null
);

alter table "LoanEventTypeEntity"
    owner to pgadmin;



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



create table "LoanOriginationStatusEntity"
(
    "Id"          integer      not null
        constraint "PK_LoanOriginationStatusEntity"
            primary key,
    "Value"       varchar(100) not null,
    "Description" varchar(100) not null
);

alter table "LoanOriginationStatusEntity"
    owner to pgadmin;


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

create table "LoanSaleStatusEntity"
(
    "Id"          integer      not null
        constraint "PK_LoanSaleStatusEntity"
            primary key,
    "Value"       varchar(100) not null,
    "Description" varchar(100) not null
);

alter table "LoanSaleStatusEntity"
    owner to pgadmin;



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

create table "LoanTypeEntity"
(
    "Id"          integer      not null
        constraint "PK_LoanTypeEntity"
            primary key,
    "Value"       varchar(100) not null,
    "Description" varchar(100) not null
);

alter table "LoanTypeEntity"
    owner to pgadmin;



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



create table "Mpl"
(
    "MplId"            varchar(3)                   not null
        constraint "PK_Mpl"
            primary key,
    "Name"             varchar(35)                  not null,
    "LastMonthVol"     double precision default 0.0 not null,
    "ThreeMonthAvgVol" double precision default 0.0 not null
);

alter table "Mpl"
    owner to pgadmin;

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



create table "PaymentStatusEntity"
(
    "Id"          integer      not null
        constraint "PK_PaymentStatusEntity"
            primary key,
    "Value"       varchar(100) not null,
    "Description" varchar(100) not null
);

alter table "PaymentStatusEntity"
    owner to pgadmin;

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

create table "PaymentTypeEntity"
(
    "Id"          integer      not null
        constraint "PK_PaymentTypeEntity"
            primary key,
    "Value"       varchar(100) not null,
    "Description" varchar(100) not null
);

alter table "PaymentTypeEntity"
    owner to pgadmin;


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

create table "SeasoningPeriodEntity"
(
    "Id"          integer      not null
        constraint "PK_SeasoningPeriodEntity"
            primary key,
    "Value"       varchar(100) not null,
    "Description" varchar(100) not null
);

alter table "SeasoningPeriodEntity"
    owner to pgadmin;


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

create table "SeasoningStartEntity"
(
    "Id"          integer      not null
        constraint "PK_SeasoningStartEntity"
            primary key,
    "Value"       varchar(100) not null,
    "Description" varchar(100) not null
);

alter table "SeasoningStartEntity"
    owner to pgadmin;


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

create table "TierRange"
(
    "TierRangeId" uuid             not null
        constraint "PK_TierRange"
            primary key,
    "From"        double precision not null,
    "To"          double precision
);

alter table "TierRange"
    owner to pgadmin;


insert into "TierRange"
SELECT gen_random_uuid(),random()+13*random()*random(), random()+13*random()*random()
FROM generate_series(1,1500) ;


create table "Account"
(
    "AccountId"     uuid        not null
        constraint "PK_Account"
            primary key,
    "AccountName"   varchar(30) not null,
    "AccountNumber" varchar(17) not null,
    "AccountType"   integer     not null
        constraint "FK_Account_AccountTypeEntity_AccountType"
            references "AccountTypeEntity"
            on delete cascade
);

alter table "Account"
    owner to pgadmin;

create index "IX_Account_AccountType"
    on "Account" ("AccountType");


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




create table "InterestCalculationMethod"
(
    "InterestCalculationMethodId" uuid                  not null
        constraint "PK_InterestCalculationMethod"
            primary key,
    "AccrualMethod"               integer               not null,
    "BasisPointsOverRate"         numeric               not null,
    "IsLeapYear"                  boolean default false not null,
    "InterestCalculationType"     integer               not null
        constraint "FK_InterestCalculationMethod_InterestCalculationTypeEntity_Int~"
            references "InterestCalculationTypeEntity"
            on delete cascade
);

alter table "InterestCalculationMethod"
    owner to pgadmin;

create index "IX_InterestCalculationMethod_InterestCalculationType"
    on "InterestCalculationMethod" ("InterestCalculationType");


insert into "InterestCalculationMethod"
SELECT gen_random_uuid(),random(),random()+13*random()*random(), 'false', *
FROM generate_series(1,1500) ;



create table "AccountingConfiguration"
(
    "AccountingConfigurationId" uuid                     not null
        constraint "PK_AccountingConfiguration"
            primary key,
    "Program"                   varchar(70),
    "DateCreated"               timestamp with time zone not null,
    "LatestDateUpdated"         timestamp with time zone,
    "LoanType"                  integer                  not null
        constraint "FK_AccountingConfiguration_LoanTypeEntity_LoanType"
            references "LoanTypeEntity"
            on delete cascade,
    "InvestorId"                uuid
        constraint "FK_AccountingConfiguration_Investor_InvestorId"
            references "Investor",
    "MplId"                     varchar(3)               not null
        constraint "FK_AccountingConfiguration_Mpl_MplId"
            references "Mpl"
            on delete cascade,
    "IssuingBankType"           integer                  not null
        constraint "FK_AccountingConfiguration_IssuingBankTypeEntity_IssuingBankTy~"
            references "IssuingBankTypeEntity"
            on delete cascade
);

alter table "AccountingConfiguration"
    owner to pgadmin;

create index "IX_AccountingConfiguration_InvestorId"
    on "AccountingConfiguration" ("InvestorId");

create index "IX_AccountingConfiguration_IssuingBankType"
    on "AccountingConfiguration" ("IssuingBankType");

create index "IX_AccountingConfiguration_LoanType"
    on "AccountingConfiguration" ("LoanType");

create index "IX_AccountingConfiguration_MplId"
    on "AccountingConfiguration" ("MplId");

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
                   'b527db12-668d-4a0f-b7b5-711301fd65ec','URV', * 
FROM generate_series(1,150) ;





create table "Loan"
(
    "LoanId"                  uuid                     not null
        constraint "PK_Loan"
            primary key,
    "LoanNumber"              varchar(150)             not null,
    "OriginalPurchaseDate"    timestamp with time zone not null,
    "PurchaseDate"            timestamp with time zone not null,
    "InterestRate"            double precision,
    "Interest"                double precision         not null,
    "VolumeFee"               double precision         not null,
    "LoanAmountFunded"        double precision         not null,
    "LoanAmountAdjusted"      double precision,
    "LoanAmount"              double precision,
    "OriginationFee"          double precision         not null,
    "NoteDate"                timestamp with time zone not null,
    "StopInterestAccrual"     boolean default false    not null,
    "InterestAccrualReversed" boolean default false    not null,
    "FundedDate"              timestamp with time zone,
    "LoanSaleStatus"          integer                  not null
        constraint "FK_Loan_LoanSaleStatusEntity_LoanSaleStatus"
            references "LoanSaleStatusEntity"
            on delete cascade,
    "LoanOriginationStatus"   integer                  not null
        constraint "FK_Loan_LoanOriginationStatusEntity_LoanOriginationStatus"
            references "LoanOriginationStatusEntity"
            on delete cascade,
    "LoanType"                integer                  not null
        constraint "FK_Loan_LoanTypeEntity_LoanType"
            references "LoanTypeEntity"
            on delete cascade,
    "MplId"                   varchar(3)               not null
        constraint "FK_Loan_Mpl_MplId"
            references "Mpl"
            on delete cascade
);

alter table "Loan"
    owner to pgadmin;

create index "IX_Loan_LoanOriginationStatus"
    on "Loan" ("LoanOriginationStatus");

create index "IX_Loan_LoanSaleStatus"
    on "Loan" ("LoanSaleStatus");

create index "IX_Loan_LoanType"
    on "Loan" ("LoanType");

create index "IX_Loan_MplId"
    on "Loan" ("MplId");


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
                   generate_series('2022-01-31', '2023-12-31', INTERVAL '1 MONTH'),*,*,*,'GQH'
FROM generate_series(1,150) ;



create table "Seasoning"
(
    "SeasoningId"              uuid    not null
        constraint "PK_Seasoning"
            primary key,
    "SeasoningPeriod"          integer not null
        constraint "FK_Seasoning_SeasoningPeriodEntity_SeasoningPeriod"
            references "SeasoningPeriodEntity"
            on delete cascade,
    "SeasoningStart"           integer not null
        constraint "FK_Seasoning_SeasoningStartEntity_SeasoningStart"
            references "SeasoningStartEntity"
            on delete cascade,
    "LimitOfDaysDelayPurchase" integer not null,
    "NumberOfSeasoningDays"    integer not null
);

alter table "Seasoning"
    owner to pgadmin;

create index "IX_Seasoning_SeasoningPeriod"
    on "Seasoning" ("SeasoningPeriod");

create index "IX_Seasoning_SeasoningStart"
    on "Seasoning" ("SeasoningStart");


insert into "Seasoning"
SELECT gen_random_uuid(),*, *,*,*
FROM generate_series(1,150) ;

create table "VolumeFeeCalculationMethod"
(
    "VolumeFeeCalculationMethodId" uuid    not null
        constraint "PK_VolumeFeeCalculationMethod"
            primary key,
    "IsWaterfall"                  boolean not null,
    "TierRangeId"                  uuid    not null
        constraint "FK_VolumeFeeCalculationMethod_TierRange_TierRangeId"
            references "TierRange"
            on delete cascade
);

alter table "VolumeFeeCalculationMethod"
    owner to pgadmin;

create index "IX_VolumeFeeCalculationMethod_TierRangeId"
    on "VolumeFeeCalculationMethod" ("TierRangeId");


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


insert into "VolumeFeeCalculationMethod"
SELECT gen_random_uuid(), 'false', getuuid()
FROM generate_series(1,150) ;




create table "AccountMapping"
(
    "AccountMappingId"          uuid                     not null
        constraint "PK_AccountMapping"
            primary key,
    "DateCreated"               timestamp with time zone not null,
    "LatestDateUpdated"         timestamp with time zone,
    "AccountObjectiveType"      integer                  not null
        constraint "FK_AccountMapping_AccountObjectiveTypeEntity_AccountObjectiveT~"
            references "AccountObjectiveTypeEntity"
            on delete cascade,
    "AccountingConfigurationId" uuid                     not null
        constraint "FK_AccountMapping_AccountingConfiguration_AccountingConfigurat~"
            references "AccountingConfiguration"
            on delete cascade,
    "AccountId"                 uuid                     not null
        constraint "FK_AccountMapping_Account_AccountId"
            references "Account"
            on delete cascade
);

alter table "AccountMapping"
    owner to pgadmin;

create index "IX_AccountMapping_AccountId"
    on "AccountMapping" ("AccountId");

create index "IX_AccountMapping_AccountingConfigurationId"
    on "AccountMapping" ("AccountingConfigurationId");

create index "IX_AccountMapping_AccountObjectiveType"
    on "AccountMapping" ("AccountObjectiveType");


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




insert into "AccountMapping"
SELECT gen_random_uuid(), generate_series('2022-01-31', '2023-12-31', INTERVAL '1 MONTH'),
generate_series('2022-01-31', '2023-12-31', INTERVAL '1 MONTH'),*, getAccountingConfigurationuuid(),
getAccountid()
FROM generate_series(1,150) ;

create table "Batch"
(
    "BatchId" uuid not null,
    "LoanId"  uuid not null
        constraint "FK_Batch_Loan_LoanId"
            references "Loan"
            on delete cascade,
    constraint "PK_Batch"
        primary key ("LoanId", "BatchId")
);

alter table "Batch"
    owner to pgadmin;
                
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
                
                
insert into "Batch"
SELECT gen_random_uuid(), getLoanid() 
FROM generate_series(1,150) ;





create table "LoanEvent"
(
    "LoanEventId"   uuid                     not null
        constraint "PK_LoanEvent"
            primary key,
    "Timestamp"     timestamp with time zone not null,
    "Payload"       text default '{}'::text  not null,
    "Initiator"     varchar(100)             not null,
    "LoanEventType" integer                  not null
        constraint "FK_LoanEvent_LoanEventTypeEntity_LoanEventType"
            references "LoanEventTypeEntity"
            on delete cascade,
    "LoanId"        uuid                     not null
        constraint "FK_LoanEvent_Loan_LoanId"
            references "Loan"
            on delete cascade
);

alter table "LoanEvent"
    owner to pgadmin;

create index "IX_LoanEvent_LoanEventType"
    on "LoanEvent" ("LoanEventType");

create index "IX_LoanEvent_LoanId"
    on "LoanEvent" ("LoanId");


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




create table "Payment"
(
    "PaymentId"       uuid                     not null
        constraint "PK_Payment"
            primary key,
    "CosId"           varchar(100),
    "CosMessage"      varchar(1024),
    "CreatedDate"     timestamp with time zone not null,
    "LastUpdateDate"  timestamp with time zone not null,
    "PaymentAmount"   double precision         not null,
    "RetriesNr"       integer default 0        not null,
    "PaymentStatus"   integer                  not null
        constraint "FK_Payment_PaymentStatusEntity_PaymentStatus"
            references "PaymentStatusEntity"
            on delete cascade,
    "PaymentType"     integer                  not null
        constraint "FK_Payment_PaymentTypeEntity_PaymentType"
            references "PaymentTypeEntity"
            on delete cascade,
    "DebitAccountId"  uuid                     not null
        constraint "FK_Payment_Account_DebitAccountId"
            references "Account"
            on delete cascade,
    "CreditAccountId" uuid                     not null
        constraint "FK_Payment_Account_CreditAccountId"
            references "Account"
            on delete cascade,
    "LoanId"          uuid                     not null
        constraint "FK_Payment_Loan_LoanId"
            references "Loan"
            on delete cascade
);

alter table "Payment"
    owner to pgadmin;

create index "IX_Payment_CreditAccountId"
    on "Payment" ("CreditAccountId");

create index "IX_Payment_DebitAccountId"
    on "Payment" ("DebitAccountId");

create index "IX_Payment_LoanId"
    on "Payment" ("LoanId");

create index "IX_Payment_PaymentStatus"
    on "Payment" ("PaymentStatus");

create index "IX_Payment_PaymentType"
    on "Payment" ("PaymentType");



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





create table "Contract"
(
    "ContractId"                   uuid                     not null
        constraint "PK_Contract"
            primary key,
    "Name"                         varchar(200)             not null,
    "EffectiveDate"                timestamp with time zone not null,
    "MaxPurchaseDate"              timestamp with time zone not null,
    "ExpirationDate"               timestamp with time zone not null,
    "ContractFeeChargingType"      integer                  not null
        constraint "FK_Contract_ContractFeeChargingTypeEntity_ContractFeeChargingT~"
            references "ContractFeeChargingTypeEntity"
            on delete cascade,
    "MplId"                        varchar(3)               not null
        constraint "FK_Contract_Mpl_MplId"
            references "Mpl"
            on delete cascade,
    "InterestCalculationMethodId"  uuid                     not null
        constraint "FK_Contract_InterestCalculationMethod_InterestCalculationMetho~"
            references "InterestCalculationMethod"
            on delete cascade,
    "VolumeFeeCalculationMethodId" uuid                     not null
        constraint "FK_Contract_VolumeFeeCalculationMethod_VolumeFeeCalculationMet~"
            references "VolumeFeeCalculationMethod"
            on delete cascade,
    "SeasoningId"                  uuid                     not null
        constraint "FK_Contract_Seasoning_SeasoningId"
            references "Seasoning"
            on delete cascade
);

alter table "Contract"
    owner to pgadmin;

create index "IX_Contract_ContractFeeChargingType"
    on "Contract" ("ContractFeeChargingType");

create index "IX_Contract_InterestCalculationMethodId"
    on "Contract" ("InterestCalculationMethodId");

create index "IX_Contract_MplId"
    on "Contract" ("MplId");

create index "IX_Contract_SeasoningId"
    on "Contract" ("SeasoningId");

create index "IX_Contract_VolumeFeeCalculationMethodId"
    on "Contract" ("VolumeFeeCalculationMethodId");


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
   
create table "PaymentOutbox"
(
    "PaymentId" uuid                     not null
        constraint "PK_PaymentOutbox"
            primary key
        constraint "FK_PaymentOutbox_Payment_PaymentId"
            references "Payment"
            on delete cascade,
    "Timestamp" timestamp with time zone not null
);

alter table "PaymentOutbox"
    owner to pgadmin;


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

select getPaymentId(1);


do $$
begin
                for cnt in 1..300 loop
                                insert into "PaymentOutbox"
                                SELECT getPaymentId(cnt), '2021-01-31';
                end loop;
end; $$




create or replace function 
count_rows(schema text, tablename text) returns integer
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
