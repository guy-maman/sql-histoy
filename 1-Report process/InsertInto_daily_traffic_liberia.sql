

--ORANGE
--On Net
insert into default.daily_traffic_liberia

SELECT 'ORANGE'                             AS operator,
       toStartOfDay(eventTimeStamp) AS date,
       'On Net'                             AS trafficType,
       sum(cd)/60*1.012            AS volume
FROM (
            select
            if(incomingTKGPName in (dictGet('mediation.orange_trunk_groups', 'trunks','1')), null ,incomingTKGPName) ir,
            if(outgoingTKGPName in (dictGet('mediation.orange_trunk_groups', 'trunks','1')), null ,outgoingTKGPName) outr,
                eventTimeStamp,
                toUnixTimestamp(callDuration) cd
        from    mediation.zte
        where
            type = 'MO_CALL_RECORD'
            and toYYYYMM(eventTimeStamp) = (:yyyymm)
            and outr is null
            and ir is null
     )
GROUP BY operator,
         trafficType,
         date;

--DATA
insert into default.daily_traffic_liberia

select  'ORANGE' operator,toStartOfDay(date) date,'DATA MB' trafficType,
    round((sum(download1) + sum(upload1))/1024/1024)*1.01 as volume
from (
select  toStartOfDay(recordOpeningTime) date,sum(listOfTrafficIn) download1,sum(listOfTrafficOut) upload1
   		from mediation.data_zte
   		where toYYYYMM(recordOpeningTime) = (:yyyymm)
group by date
union all
select  toStartOfDay(recordOpeningTime) date,sum(downloadAmount) download1,sum(uploadAmount) upload1
   		from mediation.zte_wtp
   		where  toYYYYMM(recordOpeningTime) = (:yyyymm)
group by date
) group by date
order by date;

--Orange_To_MTN
insert into default.daily_traffic_liberia

select  'ORANGE' operator,toStartOfDay(eventTimeStamp) date,'Orange to MTN' trafficType,
    sum(callDuration)/60 volume
from    mediation.zte
where
    type in ('OUT_GATEWAY_RECORD')
    and toYYYYMM(eventTimeStamp) = (:yyyymm)
    and outgoingTKGPName in (dictGet('mediation.orange_trunk_groups', 'trunks','8'))
group by operator,trafficType,date;

--MTN_To_Orange
insert into default.daily_traffic_liberia

select  'ORANGE' operator,toStartOfDay(eventTimeStamp) date,'MTN to Orange' trafficType,
    sum(callDuration)/60 volume
FROM mediation.zte
WHERE (type IN ('INC_GATEWAY_RECORD'))
  and toYYYYMM(eventTimeStamp) = (:yyyymm)
  AND incomingTKGPName in (dictGet('mediation.orange_trunk_groups', 'trunks','8'))
GROUP BY operator,
         trafficType,
         date;

--INTL Outgoing
insert into default.daily_traffic_liberia

select 'ORANGE' operator,toStartOfDay(Date) date,'INTL Outgoing' trafficType,
    sum(callDuration)/60 volume
from default.INTL
where toYYYYMM(Date) = (:yyyymm)
  and Operator = 'ORANGE'
  and Direction = 'Outgoing'
group by date;

--INTL Incoming
insert into default.daily_traffic_liberia

select 'ORANGE' operator,toStartOfDay(Date) date,'INTL Incoming' trafficType,
    sum(callDuration)/60 volume
from default.INTL
where toYYYYMM(Date) = (:yyyymm)
  and Operator = 'ORANGE'
  and Direction = 'Incoming'
group by date;

--MTN
-- On Net
insert into default.daily_traffic_liberia

select  'MTN' operator,toStartOfDay(EventDate) date,'On Net' trafficType,
    sum(cd)/60 volume
FROM (
        select
            if(incomingRoute in (dictGet('mediation.mtn_trunk_groups', 'trunks','1')), null ,incomingRoute) ir,
            if(outgoingRoute in (dictGet('mediation.mtn_trunk_groups', 'trunks','1')), null ,outgoingRoute) outr,
                networkCallReference,
                EventDate,
                toUnixTimestamp(chargeableDuration) cd
        from    mediation.ericsson
        where
            type = 'M_S_ORIGINATING'
            and toYYYYMM(EventDate) = (:yyyymm)
            and outr is null
            and ir is null
         )
GROUP BY operator,
         trafficType,
         date;

--Orange_To_MTN
insert into default.daily_traffic_liberia

select  'MTN' operator,toStartOfDay(EventDate) date,'Orange to MTN' trafficType,
    sum(toUnixTimestamp(chargeableDuration))/60 volume
FROM mediation.ericsson
WHERE (originForCharging = '1')
  and toYYYYMM(EventDate) = (:yyyymm)
  AND incomingRoute in dictGet('mediation.mtn_trunk_groups', 'trunks','8')
GROUP BY operator,
         trafficType,
         date;

--MTN_To_Orange
insert into default.daily_traffic_liberia

select  'MTN' operator,toStartOfDay(EventDate) date,'MTN to Orange' trafficType,
    sum(toUnixTimestamp(chargeableDuration))/60 volume
FROM mediation.ericsson
WHERE outgoingRoute in dictGet('mediation.mtn_trunk_groups', 'trunks','8')
    and toYYYYMM(EventDate) = (:yyyymm)
GROUP BY operator,
         trafficType,
         date;

--DATA
insert into default.daily_traffic_liberia

select  'MTN' operator,toStartOfDay(ts) date,'DATA MB' trafficType
        ,round(sum(down + up) / 1024 / 1024) as volume
from    mediation.data_ericsson_traffic_summary
where   toYYYYMM(ts) = (:yyyymm)
group by date;

--INTL Outgoing
insert into default.daily_traffic_liberia

select 'MTN' operator,toStartOfDay(Date) date,'INTL Outgoing' trafficType,
    sum(callDuration)/60 volume
from default.INTL
where toYYYYMM(Date) = (:yyyymm)
  and Operator = 'MTN'
  and Direction = 'Outgoing'
group by date;

--INTL Incoming
insert into default.daily_traffic_liberia

select 'MTN' operator,toStartOfDay(Date) date,'INTL Incoming' trafficType,
    sum(callDuration)/60 volume
from default.INTL
where toYYYYMM(Date) = (:yyyymm)
  and Operator = 'MTN'
  and Direction = 'Incoming'
group by date;

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
from    default.daily_traffic_liberia
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
from    default.daily_traffic_liberia
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
from    default.daily_traffic_liberia
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
from    default.daily_traffic_liberia
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
from    default.daily_traffic_liberia
where   toYYYYMM(date) = (:yyyymm)
    and ind = 6
group by operator,type, date
order by operator, date,ind
);