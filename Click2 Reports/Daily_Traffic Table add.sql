
-- select distinct Type
-- from default.Daily_Traffic_Liberia;
/*
alter table mediation_shard.daily_traffic_liberia_shard on cluster liberia delete where toStartOfMonth(date) = '2024-04-01';
*/

--compare
select  case
            when h.operator = 1 then 'ORANGE'
            when h.operator = 2 then 'MTN'
        end Operator,
        toStartOfMonth(h.eventTimeStamp) date,
        case
            when type = 'On Net'            then 1
            when type = 'DATA MB'           then 2
            when type = 'INTL Incoming'     then 3
            when type = 'INTL Outgoing'     then 4
            when type = 'Orange to MTN'     then 5
            when type = 'MTN to Orange'     then 6
        end ind,
        case
            when h.trafficType = 1 then 'On Net'
            when h.trafficType = 2 then 'Orange to MTN'
            when h.trafficType = 3 then 'MTN to Orange'
            when h.trafficType = 4 then 'DATA MB'
            when h.trafficType = 5 then 'INTL Outgoing'
            when h.trafficType = 6 then 'INTL Incoming'
        end type,
        case
            when h.operator = 1 and h.trafficType = 1  then round(sum(h.duration)/60)
            when h.operator = 1 and h.trafficType = 2  then round(sum(h.duration)/60)
            when h.operator = 1 and h.trafficType = 3  then round(sum(h.duration)/60)
            when h.operator = 1 and h.trafficType = 4  then toFloat64(sum(h.duration))
            when h.operator = 1 and h.trafficType = 5  then round(sum(h.duration)/60)
            when h.operator = 1 and h.trafficType = 6  then round(sum(h.duration)/60)
            when h.operator = 2 and h.trafficType = 1  then round(sum(h.duration)/60)
            when h.operator = 2 and h.trafficType = 2  then round(sum(h.duration)/60)
            when h.operator = 2 and h.trafficType = 3  then round(sum(h.duration)/60)
            when h.operator = 2 and h.trafficType = 4  then toFloat64(sum(h.duration))
            when h.operator = 2 and h.trafficType = 5  then round(sum(h.duration)/60)
            when h.operator = 2 and h.trafficType = 6  then round(sum(h.duration)/60)
            end volume
from    mediation.hourly_traffic h
where   toYYYYMM(h.eventTimeStamp) = (:yyyymm)
    and ind in (1,2,5,6)
group by operator,trafficType,date
order by operator,date,ind;

-- insert into default.daily_traffic_liberia

select  case
            when h.operator = 1 then 'ORANGE'
            when h.operator = 2 then 'MTN'
        end Operator,
        toStartOfDay(h.eventTimeStamp) date,
--         'On Net' type,
        case
            when h.trafficType = 1 then 'On Net'
            when h.trafficType = 2 then 'Orange to MTN'
            when h.trafficType = 3 then 'MTN to Orange'
            when h.trafficType = 4 then 'DATA MB'
            when h.trafficType = 5 then 'INTL Outgoing'
            when h.trafficType = 6 then 'INTL Incoming'
        end type,
        case
            when h.operator = 1 and h.trafficType = 1  then round(sum(h.duration)/60*1.01)
            when h.operator = 1 and h.trafficType = 2  then round(sum(h.duration)/60)
            when h.operator = 1 and h.trafficType = 3  then round(sum(h.duration)/60)
            when h.operator = 1 and h.trafficType = 4  then toFloat64(sum(h.duration))
            when h.operator = 1 and h.trafficType = 5  then round(sum(h.duration)/60*1.01)
            when h.operator = 1 and h.trafficType = 6  then round(sum(h.duration)/60*1.01)
            when h.operator = 2 and h.trafficType = 1  then round(sum(h.duration)/60)
            when h.operator = 2 and h.trafficType = 2  then round(sum(h.duration)/60)
            when h.operator = 2 and h.trafficType = 3  then round(sum(h.duration)/60*1)
            when h.operator = 2 and h.trafficType = 4  then toFloat64(sum(h.duration))
            when h.operator = 2 and h.trafficType = 5  then round(sum(h.duration)/60*1.07)
            when h.operator = 2 and h.trafficType = 6  then round(sum(h.duration)/60*1)
            end volume
from    mediation.hourly_traffic h
where   toYYYYMM(h.eventTimeStamp) = (:yyyymm)
group by operator,trafficType,date
order by operator,date,type;

/*
select o.value, t.value, toStartOfDay(h.eventTimeStamp) tsmp, sum(h.duration)  duration
from mediation.hourly_traffic h
         join mediation.operators o on h.operator = o.operatorId
         join mediation.traffic_types t on h.trafficType = t.trafficType
where eventTimeStamp > toStartOfDay(now())
group by o.value, t.value, tsmp
order by 1,2 ;
*/
/*
1,on
2,otm
3,mto
4,data
5,intlo
6,intli
*/
/*

select operator,toStartOfMonth(date) date,type,sum(volume) s
from daily_traffic_liberia
    where toYear(date) = (:year)
        and toMonth(date) = (:month)
group by operator,type, date
order by operator,type

select operator,date,type,sum(volume) s
from daily_traffic_liberia
    where toYear(date) = (:year)
        and toMonth(date) = (:month)
group by operator,type, date
order by operator,type

select  'ORANGE' Operator,toStartOfMonth(h.eventTimeStamp) date,'INTL Incoming' type,round(sum(h.duration)/60*1.01)  volume
from    mediation.hourly_traffic h
where   toYear(h.eventTimeStamp) = (:year)
    and toMonth(h.eventTimeStamp) = (:month)
    and operator = 2
    and trafficType = 6
group by operator,trafficType,date

select  'mtn' Operator,'intli' Traffic_Type,toStartOfHour(Date) Date,sum(callDuration) Duration
from (
select  networkCallReference callReference,max(toUnixTimestamp(chargeableDuration)) callDuration,
        EventDate Date
from    mediation.ericsson
where   toYear(EventDate) = (:year)
        and toMonth(EventDate) = (:month)
        and type not in ('M_S_ORIGINATING_SMS_IN_MSC','M_S_TERMINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
        and incomingRoute in
            ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I', 'L2MBC1I',
             'L1MBC2I', 'L2MBC2I')
group by Date,callReference
)group by Date

select toStartOfMonth(Date) Date,sum(callDuration)/60 Duration
from (
select  Operator,Direction,callReference,Date,CallingNumber,max(CalledNumber) CalledNumber,max(RoamingNumber) RoamingNumber
        ,max(callDuration) callDuration, max(Route) Route
from (
select  Operator,Direction,callReference,Date,CallingNumber,CalledNumber,RoamingNumber,callDuration,Route
from
     (
select  'MTN' Operator,'Incoming' Direction,networkCallReference callReference,
        toDateTime(substring(toString(dateForStartOfCharge), 1, 10)  || ' ' || substring(toString(timeForStartOfCharge), 12)) Date,
        case when substring(CallingNumber,1,1) = '1' then substring(CallingNumber,1,4)
              else
        (case when CallingNumber = '' then '231' else substring(CallingNumber,1,3)end) end as CountryCode,
        case when callingPartyNumber like '1400%' then substring(callingPartyNumber,5)
             else substring(callingPartyNumber,3) end as CallingNumber,
        substring(calledPartyNumber,3) CalledNumber,
        '' RoamingNumber,toUnixTimestamp(chargeableDuration) callDuration,
        incomingRoute Route
from    mediation.ericsson
where   toYear(EventDate) = (:year)
        and toMonth(EventDate) = (:month)
        and type not in ('M_S_ORIGINATING_SMS_IN_MSC','M_S_TERMINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
        and incomingRoute in
            ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I', 'L2MBC1I',
             'L1MBC2I', 'L2MBC2I')
group by Date,callReference,CallingNumber,CalledNumber,RoamingNumber,Route,callDuration
order by Date,callReference
        )
)group by Operator,Direction,callReference,Date,CallingNumber
    )group by Date

 */