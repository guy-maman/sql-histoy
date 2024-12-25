
ALTER TABLE mediation_shard.dictionary_data ON CLUSTER liberia
UPDATE value = 'Canada'
WHERE  dictionary_name = 'COUNTRY_CODE' and id = '1204'

insert into mediation_shard.dictionary_data (dictionary_name,id,value)
    values ('ORANGE_TRUNK',1,'HQMSC11_MSC71');

ALTER TABLE mediation_shard.dictionary_data ON CLUSTER liberia
UPDATE id = '1'
WHERE  dictionary_name = 'ORANGE_TRUNK' and value = 'MSCS_ODC'

ALTER TABLE mediation_shard.dictionary_data ON CLUSTER liberia
delete WHERE  dictionary_name = 'ORANGE_TRUNK' and id = '10'

select *
from mediation_shard.dictionary_data
where dictionary_name = 'traffic_types'
;
operator
traffic_types


insert into mediation_shard.dictionary_data values ('ZTE_TRUNK','7','HUASIPI');

create table default.Pre_INTL (Operator Nullable(String),Direction Nullable(String),callReference Nullable(String),Date DateTime
    ,CallingNumber Nullable(String),CalledNumber Nullable(String),RoamingNumber Nullable(String),callDuration Nullable(Float64),Route Nullable(String),CountryName Nullable(String))
    ENGINE = MergeTree() order by Date;

create table default.CountryCodes (ind Int8,CountryCode Nullable(Int32),CountryName Nullable(String))
    ENGINE = MergeTree() order by ind;

create table default.subsList (date DateTime,Operator Nullable(String),Activity Nullable(Int32),MSISDN Nullable(String))
    ENGINE = MergeTree() order by date;

-- create table mediation.CountryCode ( CountryCode int, CountryName String) engine = MergeTree() order by CountryCode;


alter table mediation_shard.daily_traffic_liberia_shard on cluster liberia delete
    where toStartOfMonth(date) = '2024-10-01';

alter table default.INTL delete where toStartOfMonth(Date) = '2024-10-01';

alter table default.report_daily_table delete where toStartOfMonth(Date) = '2024-10-01';
