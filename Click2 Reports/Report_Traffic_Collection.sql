/*
1,on    'On Net'
2,otm   'Orange to MTN'
3,mto   'MTN to Orange'
4,data  'DATA MB'
5,intlo 'INTL Outgoing'
6,intli 'INTL Incoming'
*/

--Daily traffic collection

truncate table default.report_daily_table

insert into default.report_daily_table (Operator,Date,On_Net)

select  operator,date,volume
from (
select  operator,date,
        case
            when type = 'On Net'            then 1
            when type = 'DATA MB'           then 2
            when type = 'INTL Incoming'     then 3
            when type = 'INTL Outgoing'     then 4
            when type = 'Orange to MTN'     then 5
            when type = 'MTN to Orange'     then 6
        end ind,type,
        sum(volume) volume
from    default.daily_traffic_liberia
where   toYYYYMM(date) = (:yyyymm)
    and ind = 1
group by operator,type, date
order by operator, date,ind
);

insert into default.report_daily_table (Operator,Date,DATA)

select  operator,date,volume
from (
select  operator,date,
        case
            when type = 'On Net'            then 1
            when type = 'DATA MB'           then 2
            when type = 'INTL Incoming'     then 3
            when type = 'INTL Outgoing'     then 4
            when type = 'Orange to MTN'     then 5
            when type = 'MTN to Orange'     then 6
        end ind,type,
        sum(volume) volume
from    daily_traffic_liberia
where   toYYYYMM(date) = (:yyyymm)
    and ind = 2
group by operator,type, date
order by operator, date,ind
);

insert into default.report_daily_table (Operator,Date,International_Incoming)

select  operator,date,volume
from (
select  operator,date,
        case
            when type = 'On Net'            then 1
            when type = 'DATA MB'           then 2
            when type = 'INTL Incoming'     then 3
            when type = 'INTL Outgoing'     then 4
            when type = 'Orange to MTN'     then 5
            when type = 'MTN to Orange'     then 6
        end ind,type,
        sum(volume) volume
from    daily_traffic_liberia
where   toYYYYMM(date) = (:yyyymm)
    and ind = 3
group by operator,type, date
order by operator, date,ind
);

insert into default.report_daily_table (Operator,Date,International_Outgoing)

select  operator,date,volume
from (
select  operator,date,
        case
            when type = 'On Net'            then 1
            when type = 'DATA MB'           then 2
            when type = 'INTL Incoming'     then 3
            when type = 'INTL Outgoing'     then 4
            when type = 'Orange to MTN'     then 5
            when type = 'MTN to Orange'     then 6
        end ind,type,
        sum(volume) volume
from    daily_traffic_liberia
where   toYYYYMM(date) = (:yyyymm)
    and ind = 4
group by operator,type, date
order by operator, date,ind
);

insert into default.report_daily_table (Operator,Date,Orange_To_MTN)

select  operator,date,volume
from (
select  operator,date,
        case
            when type = 'On Net'            then 1
            when type = 'DATA MB'           then 2
            when type = 'INTL Incoming'     then 3
            when type = 'INTL Outgoing'     then 4
            when type = 'Orange to MTN'     then 5
            when type = 'MTN to Orange'     then 6
        end ind,type,
        sum(volume) volume
from    daily_traffic_liberia
where   toYYYYMM(date) = (:yyyymm)
    and ind = 5
group by operator,type, date
order by operator, date,ind
);

insert into default.report_daily_table (Operator,Date,MTN_To_Orange)

select  operator,date,volume
from (
select  operator,date,
        case
            when type = 'On Net'            then 1
            when type = 'DATA MB'           then 2
            when type = 'INTL Incoming'     then 3
            when type = 'INTL Outgoing'     then 4
            when type = 'Orange to MTN'     then 5
            when type = 'MTN to Orange'     then 6
        end ind,type,
        sum(volume) volume
from    daily_traffic_liberia
where   toYYYYMM(date) = (:yyyymm)
    and ind = 6
group by operator,type, date
order by operator, date,ind
);














/*select top 100 *
from mediation.zte
where type*/

/*
-- select distinct Type
-- from default.Daily_Traffic_Liberia;

select o.value, t.value, toStartOfDay(h.eventTimeStamp) tsmp, sum(h.duration)  duration
from mediation.hourly_traffic h
         join mediation.operators o on h.operator = o.operatorId
         join mediation.traffic_types t on h.trafficType = t.trafficType
where eventTimeStamp > toStartOfDay(now())
group by o.value, t.value, tsmp
order by 1,2 ;

select  o.value,
        t.value,
        toStartOfDay(h.eventTimeStamp) tsmp, sum(h.duration)  duration
;
select  t.value,toStartOfDay(h.eventTimeStamp) tsp,round(sum(h.duration)/60) ORANGE
from    mediation.hourly_traffic h
         join mediation.operators o on h.operator = o.operatorId
         join mediation.traffic_types t on h.trafficType = t.trafficType
where   toYear(h.eventTimeStamp) = (:year)
    and toMonth(h.eventTimeStamp) = (:month)
    and operator = 1
--     and trafficType = 1
group by operator,trafficType,tsp
order by b.ind2 ;

select t.value, /*toStartOfDay(h.eventTimeStamp) tsmp,*/ sum(h.duration)  duration
from mediation.hourly_traffic h
         join mediation.operators o on h.operator = o.operatorId
         join mediation.traffic_types t on h.trafficType = t.trafficType
where   toYear(h.eventTimeStamp) = (:year)
    and toMonth(h.eventTimeStamp) = (:month)
    and operator = 1
group by  t.value--, tsmp
order by 1,2 ;
*/
