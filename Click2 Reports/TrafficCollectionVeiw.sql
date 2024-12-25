
-- create table mediation.Liberia_Traffic (Operator String,Traffic_Type String,Date DateTime,Duration int)
-- ENGINE = MergeTree() order by Date;

-- select * from mediation.orange_trunk_groups;

-- select * from mediation_shard.dictionary_data where dictionary_name = 'traffic_types';
/*
create dictionary mediation.trunk_groups on cluster liberia_replica
(
    traffic_type String,
    trunks Array(String)
) primary key traffic_type
    source ( CLICKHOUSE(DB 'mediation_shard' USER 'default' PASSWORD 'rootpass' QUERY
                        'select id traffic_type, groupArray(value) trunks from mediation_shard.dictionary_data where dictionary_name = ''ORANGE_TRUNK'' group by id') )
    layout ( FLAT(INITIAL_ARRAY_SIZE 50000 MAX_ARRAY_SIZE 5000000) )
    lifetime ( min 0 max 86400);

*/
/*
ALTER TABLE mediation_shard.dictionary_data ON CLUSTER liberia
UPDATE value = 'Canada'
WHERE  dictionary_name = 'COUNTRY_CODE' and id = 1204

*/
/*
select      distinct outgoingTKGPName --   'orange' Operator,'on' Traffic_Type,toStartOfHour(eventTimeStamp) Date,sum(callDuration) Duration
    from    mediation.zte
        where   toYear(eventTimeStamp) = 2024
            and toMonth(eventTimeStamp) = 1
            and type in ('MO_CALL_RECORD')
            and incomingTKGPName in (dictGet('mediation.orange_trunk_groups', 'trunks','1'))
            and outgoingTKGPName in (dictGet('mediation.orange_trunk_groups', 'trunks', '1'))
  --      group by Operator,Traffic_Type,Date;


traffic_types,1,on
traffic_types,2,otm
traffic_types,3,mto
traffic_types,4,data
traffic_types,5,intlo
traffic_types,6,intli
*/

--ORANGE
--On Net
select  'orange' Operator,'on' Traffic_Type,toStartOfHour(eventTimeStamp) Date,sum(callDuration) Duration
from    mediation.zte
where   toYear(eventTimeStamp) = (:year)
    and toMonth(eventTimeStamp) = (:month)
    and type in ('MO_CALL_RECORD')
    and incomingTKGPName in (dictGet('mediation.orange_trunk_groups', 'trunks','1'))
    and outgoingTKGPName in (dictGet('mediation.orange_trunk_groups', 'trunks','1'))
group by Operator,Traffic_Type,Date

--Orange_To_MTN
select  'orange' Operator,'otm' Traffic_Type,toStartOfHour(eventTimeStamp) Date,sum(callDuration) Duration
from    mediation.zte
where   toYear(eventTimeStamp) = (:year)
    and toMonth(eventTimeStamp) = (:month)
    and type in ('OUT_GATEWAY_RECORD')
    and outgoingTKGPName in (dictGet('mediation.orange_trunk_groups', 'trunks','8'))
--         ('Comium', 'LoneStar', 'MSC_SBC_MTN')
group by Operator,Traffic_Type,Date

--MTN_To_Orange
select  'orange' Operator,'mto' Traffic_Type,toStartOfHour(eventTimeStamp) Date,sum(callDuration) Duration
from    mediation.zte
where   toYear(eventTimeStamp) = (:year)
    and toMonth(eventTimeStamp) = (:month)
    and type in ('INC_GATEWAY_RECORD')
    and incomingTKGPName in (dictGet('mediation.orange_trunk_groups', 'trunks','8'))
group by Operator,Traffic_Type,Date

--DATA
select  'orange' Operator,'data' Traffic_Type,toStartOfHour(date) Date,round((sum(download1) + sum(upload1))/1024/1024) as Duration
from (
select  toStartOfHour(recordOpeningTime) date,sum(listOfTrafficIn) download1,sum(listOfTrafficOut) upload1
   		from mediation.data_zte
   		where toYear(recordOpeningTime) = (:year)
   			and toMonth(recordOpeningTime) = (:month)
group by date
union all
select  toStartOfHour(recordOpeningTime) date,sum(downloadAmount) download1,sum(uploadAmount) upload1
   		from mediation.zte_wtp
   		where toYear(recordOpeningTime) = (:year)
   			and toMonth(recordOpeningTime) = (:month)
group by date
) group by date

--INTL Outgoing
select  'orange' Operator,'intlo' Traffic_Type, Date,sum(Duration) Duration
from (
select  callReference,toStartOfHour(eventTimeStamp) Date,sum(callDuration) Duration
from    mediation.zte
where   toYear(eventTimeStamp) = (:year)
    and toMonth(eventTimeStamp) = (:month)
    and callDuration > 0
    and type in ('MO_CALL_RECORD','ROAM_RECORD','MCF_CALL_RECORD')
    and length(calledNumber) >7
    and roamingNumber = ''
    and outgoingTKGPName in (dictGet('mediation.orange_trunk_groups', 'trunks','7'))
group by Date,callReference
)group by Date

--INTL Incoming
select  'orange' Operator,'intli' Traffic_Type, Date,sum(Duration) Duration
from (
select  callReference,toStartOfHour(eventTimeStamp) Date,sum(callDuration) Duration
from    mediation.zte
where   toYear(eventTimeStamp) = (:year)
    and toMonth(eventTimeStamp) = (:month)
    and callDuration > 0
    and type in ('MT_CALL_RECORD','ROAM_RECORD','MCF_CALL_RECORD')
    and incomingTKGPName in (dictGet('mediation.orange_trunk_groups', 'trunks','7'))
group by Date,callReference
)group by Date


-- On Net correct info
select  'mtn' Operator,'on' Traffic_Type,toStartOfMonth(EventDate) Date,sum(chargeableDuration) chargeableDuration
from (
select  EventDate,if(incomingRoute = '' and outgoingRoute = '', sum(chargeableDuration) / 60, 0) chargeableDuration
from (
select  top 10000 max(if(incomingRoute in (dictGet('mediation.zte_trunk_groups', 'trunks','1')),'',incomingRoute)) incomingRoute,
        max(if(outgoingRoute in (dictGet('mediation.zte_trunk_groups', 'trunks','1')),'',outgoingRoute)) outgoingRoute,
        networkCallReference,EventDate,(toUnixTimestamp(chargeableDuration)) chargeableDuration
from    mediation.ericsson
where   toYear(EventDate) = (:year)
    and toMonth(EventDate) = (:month)
    and type = 'M_S_ORIGINATING'
group by EventDate,networkCallReference,/*incomingRoute,outgoingRoute,*/chargeableDuration
order by EventDate,networkCallReference
)group by EventDate,incomingRoute,outgoingRoute
)group by Date;

--MTN
--On Net
-- select  'mtn' Operator,'on' Traffic_Type,toStartOfHour(EventDate) Date,sum(chargeableDuration) Duration
-- from (
-- select  EventDate,callingPartyNumber,calledPartyNumber,toUnixTimestamp(chargeableDuration) chargeableDuration
-- from    mediation.ericsson
-- where   toYear(EventDate) = (:year)
--     and toMonth(EventDate) = (:month)
--     and originForCharging = '1'
--     and incomingRoute in dictGet('mediation.zte_trunk_groups', 'trunks','1')
--     and outgoingRoute in dictGet('mediation.zte_trunk_groups', 'trunks','1')
-- group by EventDate,callingPartyNumber,calledPartyNumber,chargeableDuration
-- )group by Date

--Orange_To_MTN
select  'mtn' Operator,'otm' Traffic_Type,toStartOfHour(EventDate) Date,sum(chargeableDuration) Duration
from (
select  EventDate,callingPartyNumber,calledPartyNumber,toUnixTimestamp(chargeableDuration) chargeableDuration
from    mediation.ericsson
where   toYear(EventDate) = (:year)
    and toMonth(EventDate) = (:month)
    and originForCharging = '1'
    and incomingRoute in dictGet('mediation.zte_trunk_groups', 'trunks','8')
group by EventDate,callingPartyNumber,calledPartyNumber,chargeableDuration
        )group by Date

--MTN_To_Orange
select  'mtn' Operator,'mto' Traffic_Type,toStartOfHour(EventDate) Date,sum(chargeableDuration) Duration
from (
select  EventDate,callingPartyNumber,calledPartyNumber,toUnixTimestamp(chargeableDuration) chargeableDuration
from    mediation.ericsson
where   toYear(EventDate) = (:year)
    and toMonth(EventDate) = (:month)
    and outgoingRoute in dictGet('mediation.zte_trunk_groups', 'trunks','8')
group by EventDate,callingPartyNumber,calledPartyNumber,chargeableDuration
        )group by Date

--DATA
select 'mtn' Operator,'data' Traffic_Type,toStartOfHour(recordOpeningTime) Date,round((sum(listOfTrafficIn) + sum(listOfTrafficOut))/1024/1024) Duration
from    mediation.data_ericsson
where   toYear(recordOpeningTime) = (:year)
	and toMonth(recordOpeningTime) = (:month)
    and accessPointNameOI <> 'mnc001.mcc618.gprs'
group by Date

--INTL Outgoing
select  'mtn' Operator,'intlo' Traffic_Type,toStartOfHour(Date) Date,sum(callDuration) Duration
from (
select  networkCallReference callReference,sum(toUnixTimestamp(chargeableDuration)) callDuration,
        toDateTime(substring(toString(dateForStartOfCharge), 1, 10)  || ' ' || substring(toString(timeForStartOfCharge), 12)) Date
from    mediation.ericsson
where   toYear(EventDate) = (:year)
    and toMonth(EventDate) = (:month)
    and outgoingRoute in dictGet('mediation.zte_trunk_groups', 'trunks','7')
    and type not in ('M_S_ORIGINATING_SMS_IN_MSC','M_S_TERMINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
group by Date,callReference
)group by Date

--INTL Incoming
select  'mtn' Operator,'intli' Traffic_Type,toStartOfHour(Date) Date,sum(callDuration) Duration
from (
select  networkCallReference callReference,max(toUnixTimestamp(chargeableDuration)) callDuration,
        EventDate Date
from    mediation.ericsson
where   toYear(EventDate) = (:year)
        and toMonth(EventDate) = (:month)
        and type not in ('M_S_ORIGINATING_SMS_IN_MSC','M_S_TERMINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
        and incomingRoute in dictGet('mediation.zte_trunk_groups', 'trunks','7')
group by Date,callReference
)group by Date