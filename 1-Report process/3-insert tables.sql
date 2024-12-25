
/*
alter table mediation_shard.daily_traffic_liberia_shard on cluster liberia
    delete where toStartOfMonth(date) = '2024-11-01';
alter table default.INTL delete where toStartOfMonth(Date) = '2024-11-01';
alter table default.report_daily_table delete where toStartOfMonth(Date) = '2024-10-01';
*/


-- insert to INTL table
insert into default.INTL

select  Operator,Direction,callReference,Date,CallingNumber,CalledNumber,RoamingNumber,
        round(callDuration*1.065) callDuration,Route,CountryName
from    default.Pre_INTL
where   toYYYYMM(Date) = (:yyyymm)
    and Operator = 'MTN'
    and Direction = '4';

insert into default.INTL

select  Operator,Direction,callReference,Date,CallingNumber,CalledNumber,RoamingNumber,callDuration
        ,Route,CountryName
from    default.Pre_INTL
where   toYYYYMM(Date) = (:yyyymm)
    and Operator = 'MTN'
    and Direction = '3';

insert into default.INTL

select  Operator,Direction,callReference,Date,CallingNumber,CalledNumber,RoamingNumber,
        round(callDuration) callDuration,Route,CountryName
from    default.Pre_INTL
where   toYYYYMM(Date) = (:yyyymm)
    and Operator = 'ORANGE'
    and Direction = '4';

insert into default.INTL

select  Operator,Direction,callReference,Date,CallingNumber,CalledNumber,RoamingNumber,
        round(callDuration) callDuration ,Route,CountryName
from    default.Pre_INTL
where   toYYYYMM(Date) = (:yyyymm)
    and Operator = 'ORANGE'
    and Direction = '3';

/*
-- insert daily traffic liberia
insert into default.daily_traffic_liberia

select o.value operator,
       toStartOfDay(eventTimeStamp) ts,
       t.value traffic_Type,
       multiIf(
               trafficType = 1, toFloat64(sum(duration)/60*1.019),
               trafficType = 2, toFloat64(sum(duration)*1.005),
               trafficType = 5, toFloat64(sum(duration)/60*1.011),
               trafficType = 6, toFloat64(sum(duration)/60*1.009),
               null
       )                              volume
from    mediation.hourly_traffic d
    join mediation.operators o on o.operatorId = d.operator
    join mediation.traffic_types t on d.trafficType = t.operatorId
where   toYYYYMM(eventTimeStamp) = (:yyyymm)
    and t.operatorId in (1,2,5,6)
    and o.operatorId = 1
group by operator, traffic_Type, ts,trafficType
order by ts,operator,trafficType;

insert into default.daily_traffic_liberia

select o.value operator,
       toStartOfDay(eventTimeStamp) ts,
       t.value traffic_Type,
       multiIf(
               trafficType = 1, toFloat64(sum(duration)/60),
               trafficType = 2, toFloat64(sum(duration)),
               trafficType = 5, toFloat64(sum(duration)/60*1.001),
               trafficType = 6, toFloat64(sum(duration)/60),
               null
       )                              volume
from    mediation.hourly_traffic d
    join mediation.operators o on o.operatorId = d.operator
    join mediation.traffic_types t on d.trafficType = t.operatorId
where   toYYYYMM(eventTimeStamp) = (:yyyymm)
    and t.operatorId in (1,2,5,6)
    and o.operatorId = 2
group by operator, traffic_Type, ts,trafficType
order by ts,operator,trafficType;
*/
--INTL Outgoing
insert into default.daily_traffic_liberia

select 'ORANGE' operator,toStartOfDay(Date) date,'INTL Outgoing' trafficType,
    sum(callDuration)/60 volume
from default.INTL
where toYYYYMM(Date) = (:yyyymm)
  and Operator = 'ORANGE'
  and Direction = '4'
group by date;

--INTL Incoming
insert into default.daily_traffic_liberia

select 'ORANGE' operator,toStartOfDay(Date) date,'INTL Incoming' trafficType,
    sum(callDuration)/60 volume
from default.INTL
where toYYYYMM(Date) = (:yyyymm)
  and Operator = 'ORANGE'
  and Direction = '3'
group by date;

insert into default.daily_traffic_liberia

select 'MTN' operator,toStartOfDay(Date) date,'INTL Outgoing' trafficType,
    sum(callDuration)/60 volume
from default.INTL
where toYYYYMM(Date) = (:yyyymm)
  and Operator = 'MTN'
  and Direction = '4'
group by date;

--INTL Incoming
insert into default.daily_traffic_liberia

select 'MTN' operator,toStartOfDay(Date) date,'INTL Incoming' trafficType,
    sum(callDuration)/60 volume
from default.INTL
where toYYYYMM(Date) = (:yyyymm)
  and Operator = 'MTN'
  and Direction = '3'
group by date;


select  operator,toStartOfMonth(date) date,t.operatorId ind,type,
        sum(volume) volume
from    default.daily_traffic_liberia d
    join mediation.traffic_types t on t.value = type
where   toYYYYMM(date) = (:yyyymm)
--     and ind = 1
group by operator,type, date,ind
order by operator desc, date,ind
/*
create table default.report_daily_table (Operator Nullable(String),Date DateTime
    ,On_Net Nullable(Float64),DATA Nullable(Float64),International_Incoming Nullable(Float64),
    International_Outgoing Nullable(Float64),Orange_To_MTN Nullable(Float64),MTN_To_Orange Nullable(Float64))
    ENGINE = MergeTree() order by Date;
*/
--Daily traffic collection
truncate table default.report_daily_table

insert into default.report_daily_table (Operator,Date,On_Net)

select  operator Operator,date Date,sum(volume) volume
from    default.daily_traffic_liberia d
    join mediation.traffic_types t on t.value = type
where   toYYYYMM(date) = (:yyyymm)
    and t.operatorId = 1
group by operator,date
order by operator desc, date;

insert into default.report_daily_table (Operator,Date,DATA)

select  operator Operator,date Date,sum(volume) volume
from    default.daily_traffic_liberia d
    join mediation.traffic_types t on t.value = type
where   toYYYYMM(date) = (:yyyymm)
    and t.operatorId = 2
group by operator,date
order by operator desc, date;

insert into default.report_daily_table (Operator,Date,International_Incoming)

select  operator Operator,date Date,sum(volume) volume
from    default.daily_traffic_liberia d
    join mediation.traffic_types t on t.value = type
where   toYYYYMM(date) = (:yyyymm)
    and t.operatorId = 3
group by operator,date
order by operator desc, date;

insert into default.report_daily_table (Operator,Date,International_Outgoing)

select  operator Operator,date Date,sum(volume) volume
from    default.daily_traffic_liberia d
    join mediation.traffic_types t on t.value = type
where   toYYYYMM(date) = (:yyyymm)
    and t.operatorId = 4
group by operator,date
order by operator desc, date;

insert into default.report_daily_table (Operator,Date,Orange_To_MTN)

select  operator Operator,date Date,sum(volume) volume
from    default.daily_traffic_liberia d
    join mediation.traffic_types t on t.value = type
where   toYYYYMM(date) = (:yyyymm)
    and t.operatorId = 5
group by operator,date
order by operator desc, date;

insert into default.report_daily_table (Operator,Date,MTN_To_Orange)

select  operator Operator,date Date,sum(volume) volume
from    default.daily_traffic_liberia d
    join mediation.traffic_types t on t.value = type
where   toYYYYMM(date) = (:yyyymm)
    and t.operatorId = 6
group by operator,date
order by operator desc, date;

--Daily traffic table
select  Operator,Date,sum(On_Net) On_Net,sum(DATA) DATA,sum(International_Incoming) International_Incoming
        ,sum(International_Outgoing) International_Outgoing,sum(Orange_To_MTN) Orange_To_MTN
        ,sum(MTN_To_Orange) MTN_To_Orange
from    default.report_daily_table
where   toYYYYMM(Date) = (:yyyymm)
group by Operator,Date
order by Operator desc,Date;