
/*
create table default.Liberia_Traffic (Operator String,Traffic_Type String,Date DateTime,Duration int)
ENGINE = MergeTree() order by Date;
*/
-- alter table mediation_shard.daily_traffic_liberia_shard on cluster liberia delete where toStartOfMonth(date) = '2024-05-01';


insert into default.daily_traffic_liberia
--ORANGE
--On Net
select  'ORANGE' operator,toStartOfDay(answerTime) date,'On Net' trafficType,(sum(callDuration)/60)volume
from    (
select  callReference,answerTime,callDuration
from    mediation.zte
where   toYYYYMM(eventTimeStamp) = (:yyyymm)
    and callDuration > 0
    and type in ('OUT_GATEWAY_RECORD','MO_CALL_RECORD','ROAM_RECORD','MCF_CALL_RECORD',
                    'MT_CALL_RECORD','INC_GATEWAY_RECORD')
    and ((incomingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','1')
            or incomingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','10'))
    and (outgoingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','1')
            or outgoingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','10')))
group by answerTime,callReference,callDuration)
group by operator,trafficType,date
order by date;

insert into default.daily_traffic_liberia
--Orange_To_MTN
select  'ORANGE' operator,toStartOfDay(answerTime) date,'Orange to MTN' trafficType,sum(callDuration)/60 volume
from    (
select  callReference,answerTime,callDuration
from    mediation.zte
where   toYYYYMM(eventTimeStamp) = (:yyyymm)
    and callDuration > 0
    and type in ('OUT_GATEWAY_RECORD','MO_CALL_RECORD','ROAM_RECORD','MCF_CALL_RECORD',
                    'MT_CALL_RECORD','INC_GATEWAY_RECORD')
    and outgoingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','8')
group by answerTime,callReference,callDuration)
group by operator,trafficType,date
order by date;

insert into default.daily_traffic_liberia
--MTN_To_Orange
select  'ORANGE' operator,toStartOfDay(answerTime) date,'MTN to Orange' trafficType,sum(callDuration)/60 volume
from    (
select  callReference,answerTime,callDuration
from    mediation.zte
where   toYYYYMM(eventTimeStamp) = (:yyyymm)
    and callDuration > 0
    and type in ('OUT_GATEWAY_RECORD','MO_CALL_RECORD','ROAM_RECORD','MCF_CALL_RECORD',
                    'MT_CALL_RECORD','INC_GATEWAY_RECORD')
    and incomingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','8')
group by answerTime,callReference,callDuration)
group by operator,trafficType,date
order by date;

insert into default.daily_traffic_liberia
--DATA
select  'ORANGE' operator,toStartOfDay(date) date,'DATA MB' trafficType,round((sum(download1) + sum(upload1))/1024/1024) as volume
from (
select  toStartOfDay(recordOpeningTime) date,sum(listOfTrafficIn) download1,sum(listOfTrafficOut) upload1
   		from mediation.data_zte
   		where toYear(recordOpeningTime) = (:year)
   			and toMonth(recordOpeningTime) = (:month)
group by date
union all
select  toStartOfDay(recordOpeningTime) date,sum(downloadAmount) download1,sum(uploadAmount) upload1
   		from mediation.zte_wtp
   		where toYear(recordOpeningTime) = (:year)
   			and toMonth(recordOpeningTime) = (:month)
group by date
) group by date
order by date

insert into default.daily_traffic_liberia
--INTL Outgoing
select  'ORANGE' operator,toStartOfDay(Date) date,'INTL Outgoing' trafficType,sum(Duration)/60 volume
from (
select  callReference,toStartOfDay(answerTime) Date,sum(callDuration) Duration
from    mediation.zte
where   toYYYYMM(eventTimeStamp) = (:yyyymm)
    and callDuration > 0
    and type in ('OUT_GATEWAY_RECORD','MO_CALL_RECORD','ROAM_RECORD','MCF_CALL_RECORD',
                    'MT_CALL_RECORD','INC_GATEWAY_RECORD')
    and outgoingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','7')
group by Date,callReference
)group by date
order by date;

insert into default.daily_traffic_liberia
--INTL Incoming
select  'ORANGE' operator,toStartOfDay(Date) date,'INTL Incoming' trafficType,sum(Duration)/60 volume
from (
select  callReference,toStartOfDay(eventTimeStamp) Date,sum(callDuration) Duration
from    mediation.zte
where   toYYYYMM(eventTimeStamp) = (:yyyymm)
    and callDuration > 0
    and type in ('OUT_GATEWAY_RECORD','MO_CALL_RECORD','ROAM_RECORD','MCF_CALL_RECORD',
                    'MT_CALL_RECORD','INC_GATEWAY_RECORD')
    and incomingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','7')
group by Date,callReference
)group by date
order by date;

insert into default.daily_traffic_liberia
--MTN
--On Net
select  'MTN' operator,toStartOfDay(EventDate) date,'On Net' trafficType,sum(chargeableDuration)/60 volume
from (
select  EventDate,callingPartyNumber,calledPartyNumber,toUnixTimestamp(chargeableDuration) chargeableDuration
from    mediation.ericsson
where   toYYYYMM(EventDate) = (:yyyymm)
    and originForCharging = '1'
    and incomingRoute not in
        ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I', 'L2MBC1I','L1MBC2I','L2MBC2I', 'CELLCI')
    and outgoingRoute not in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O', 'L2MBC2O', 'ZURO', 'CELLCO'
                ,'BCPBX1O','ISON1O','IVR1O','MAV2O','VIAMOO')
    and length(calledPartyNumber) > 7
    and length(callingPartyNumber) > 7
group by EventDate,callingPartyNumber,calledPartyNumber,chargeableDuration
)group by date
order by date

insert into default.daily_traffic_liberia
--Orange_To_MTN
select  'MTN' operator,toStartOfDay(EventDate) date,'Orange to MTN' trafficType,sum(chargeableDuration)/60 volume
from (
select  EventDate,callingPartyNumber,calledPartyNumber,toUnixTimestamp(chargeableDuration) chargeableDuration
from    mediation.ericsson
where   toYYYYMM(EventDate) = (:yyyymm)
    and originForCharging = '1'
    and incomingRoute in ('CELLCI', 'ORGSBCI')
group by EventDate,callingPartyNumber,calledPartyNumber,chargeableDuration
        )group by date
order by date

insert into default.daily_traffic_liberia
--MTN_To_Orange
select  'MTN' operator,toStartOfDay(EventDate) date,'MTN to Orange' trafficType,sum(chargeableDuration)/60 volume
from (
select  EventDate,callingPartyNumber,calledPartyNumber,toUnixTimestamp(chargeableDuration) chargeableDuration
from    mediation.ericsson
where   toYYYYMM(EventDate) = (:yyyymm)
    and outgoingRoute in ('CELLCO', 'ORGSBCO')
group by EventDate,callingPartyNumber,calledPartyNumber,chargeableDuration
        )group by date
order by date

insert into default.daily_traffic_liberia
--DATA
select  'MTN' operator,toStartOfDay(ts) date,'DATA MB' trafficType
        ,round(sum(down + up) / 1024 / 1024) as volume
from    mediation.data_ericsson_traffic_summary
where   toYear(ts) = (:year)
    and toMonth(ts) = (:month)
group by date

insert into default.daily_traffic_liberia
--INTL Outgoing
select  'MTN' operator,toStartOfDay(Date) date,'INTL Outgoing' trafficType,sum(callDuration)/60*1.04 volume
from (
select  networkCallReference callReference,sum(toUnixTimestamp(chargeableDuration)) callDuration,
        toDateTime(substring(toString(dateForStartOfCharge), 1, 10)  || ' ' || substring(toString(timeForStartOfCharge), 12)) Date
from    mediation.ericsson
where   toYYYYMM(EventDate) = (:yyyymm)
    and outgoingRoute in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O', 'L2MBC2O', 'ZURO')
    and type not in ('M_S_ORIGINATING_SMS_IN_MSC','M_S_TERMINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
group by Date,callReference
)group by date
order by date

insert into default.daily_traffic_liberia
--INTL Incoming
select  'MTN' operator,toStartOfDay(Date) date,'INTL Incoming' trafficType,sum(callDuration)/60 volume
from (
select  networkCallReference callReference,max(toUnixTimestamp(chargeableDuration)) callDuration,
        EventDate Date
from    mediation.ericsson
where   toYYYYMM(EventDate) = (:yyyymm)
        and type not in ('M_S_ORIGINATING_SMS_IN_MSC','M_S_TERMINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
        and incomingRoute in
            ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I', 'L1MBC1I', 'L2MBC1I',
             'L1MBC2I', 'L2MBC2I')
group by Date,callReference
)group by date
order by date