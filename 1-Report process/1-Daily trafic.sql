
/*
create table default.Liberia_Traffic (Operator String,Date DateTime,Traffic_Type String,Duration Float64)
ENGINE = MergeTree() order by Date;
*/

--ORANGE
insert into default.Liberia_Traffic
--On Net
SELECT 1                             AS operator,
       toStartOfDay(answerTime) AS eventTimeStamp,
       1                             AS trafficType,
       sum(cd)/60             AS duration
FROM (
        select callReference,answerTime,
            multiIf(incomingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','1'),null,
                    incomingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','10'),null,
                    incomingTKGPName) ir,
            multiIf(outgoingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','1'),null,
                    outgoingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','10'),null,
                    outgoingTKGPName) outr,
                (callDuration) cd
        from    mediation.zte
        where
            type in ('OUT_GATEWAY_RECORD','MO_CALL_RECORD','ROAM_RECORD','MCF_CALL_RECORD',
                    'MT_CALL_RECORD','INC_GATEWAY_RECORD')
            and toYYYYMM(eventTimeStamp) = (:yyyymm)
            and callDuration > 0
            and outr is null
            and ir is null
        group by answerTime,callReference,cd,ir,outr
     )
GROUP BY operator,
         trafficType,
         eventTimeStamp
order by eventTimeStamp;

insert into default.Liberia_Traffic
--Orange_To_MTN
select  1 operator,
        toStartOfDay(answerTime) eventTimeStamp,
        5 trafficType,
        sum(callDuration)/60 duration
from (
select  callReference,answerTime,callDuration
from    mediation.zte
where   type in ('OUT_GATEWAY_RECORD','MO_CALL_RECORD','ROAM_RECORD','MCF_CALL_RECORD',
                    'MT_CALL_RECORD','INC_GATEWAY_RECORD')
        and toYYYYMM(eventTimeStamp) = (:yyyymm)
        and callDuration > 0
    and outgoingTKGPName in (dictGet('mediation.orange_trunk_groups', 'trunks','8'))
group by callReference,answerTime,callDuration)
group by operator,trafficType,eventTimeStamp;


insert into default.Liberia_Traffic
--MTN_To_Orange
SELECT 1                             AS operator,
       toStartOfDay(answerTime) AS eventTimeStamp,
       6                             AS trafficType,
       sum(callDuration)/60             AS duration
from (
select  callReference,answerTime,callDuration
FROM mediation.zte
WHERE type in ('OUT_GATEWAY_RECORD','MO_CALL_RECORD','ROAM_RECORD','MCF_CALL_RECORD',
                    'MT_CALL_RECORD','INC_GATEWAY_RECORD')
    and toYYYYMM(eventTimeStamp) = (:yyyymm)
    and callDuration > 0
    AND incomingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','8')
group by callReference,answerTime,callDuration)
GROUP BY operator,
         trafficType,
         eventTimeStamp;
/*
insert into default.Liberia_Traffic
--DATA
select operator,eventTimeStamp,trafficType,sum(duration) duration
from (
SELECT 1                                                              AS operator,
       toStartOfDay(recordOpeningTime)                               AS eventTimeStamp,
       2                                                              AS trafficType,
       ((sum(listOfTrafficIn) + sum(listOfTrafficOut)) / 1024) / 1024 AS duration
FROM mediation.data_zte
where toYYYYMM(recordOpeningTime) = (:yyyymm)
GROUP BY operator,
         trafficType,
         eventTimeStamp
union all
SELECT 1                                                         AS operator,
       toStartOfDay(recordOpeningTime)                          AS eventTimeStamp,
       2                                                         AS trafficType,
       ((sum(downloadAmount) + sum(uploadAmount)) / 1024) / 1024 AS duration
FROM mediation.zte_wtp
where toYYYYMM(recordOpeningTime) = (:yyyymm)
GROUP BY operator,
         trafficType,
         eventTimeStamp)
GROUP BY operator,
         trafficType,
         eventTimeStamp;

insert into default.Liberia_Traffic
--INTL Outgoing
SELECT 1                   AS operator,
       toStartOfDay(Date) AS eventTimeStamp,
       4                   AS trafficType,
       sum(Duration)/60       AS duration
FROM (
         SELECT callReference,
                answerTime AS Date,
                (callDuration)            AS Duration
         FROM mediation.zte
         WHERE type in ('OUT_GATEWAY_RECORD','MO_CALL_RECORD','ROAM_RECORD','MCF_CALL_RECORD',
                    'MT_CALL_RECORD','INC_GATEWAY_RECORD')
                and toYYYYMM(eventTimeStamp) = (:yyyymm)
                and callDuration > 0
                AND outgoingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','7')
         GROUP BY Date,callReference,Duration
         )
GROUP BY operator,
         trafficType,
         eventTimeStamp;

insert into default.Liberia_Traffic
--INTL Incoming
SELECT 1                   AS operator,
       toStartOfDay(Date) AS eventTimeStamp,
       3                   AS trafficType,
       sum(Duration)/60       AS duration
FROM (
         SELECT callReference,
                answerTime AS Date,
                (callDuration)             AS Duration
         FROM mediation.zte
         WHERE type in ('OUT_GATEWAY_RECORD','MO_CALL_RECORD','ROAM_RECORD','MCF_CALL_RECORD',
                    'MT_CALL_RECORD','INC_GATEWAY_RECORD')
                and toYYYYMM(eventTimeStamp) = (:yyyymm)
                and callDuration > 0
                AND incomingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','7')
         GROUP BY Date,callReference,Duration
         )
GROUP BY operator,
         trafficType,
         eventTimeStamp;
*/
--MTN
insert into default.Liberia_Traffic
-- On Net
SELECT 2                        AS operator,
       toStartOfDay(EventDate) AS eventTimeStamp,
       1                        AS trafficType,
       sum(cd)/60  AS duration
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
         eventTimeStamp



insert into default.Liberia_Traffic
--Orange_To_MTN
SELECT 2                                        AS operator,
       toStartOfDay(EventDate)                 AS eventTimeStamp,
       5                                        AS trafficType,
       sum(toUnixTimestamp(chargeableDuration))/60 AS duration
FROM mediation.ericsson
WHERE (originForCharging = '1')
  and toYYYYMM(EventDate) = (:yyyymm)
  AND incomingRoute in dictGet('mediation.mtn_trunk_groups', 'trunks','8')
GROUP BY operator,
         trafficType,
         eventTimeStamp;

insert into default.Liberia_Traffic
--MTN_To_Orange
SELECT 2                                        AS operator,
       toStartOfDay(EventDate)                 AS eventTimeStamp,
       6                                        AS trafficType,
       sum(toUnixTimestamp(chargeableDuration))/60 AS duration
FROM mediation.ericsson
WHERE outgoingRoute in dictGet('mediation.mtn_trunk_groups', 'trunks','8')
    and toYYYYMM(EventDate) = (:yyyymm)
GROUP BY operator,
         trafficType,
         eventTimeStamp;
/*
insert into default.Liberia_Traffic
--DATA
SELECT 2                                                                     AS operator,
       toStartOfDay(recordOpeningTime)                                      AS eventTimeStamp,
       2                                                                     AS trafficType,
       round(((sum(listOfTrafficIn) + sum(listOfTrafficOut)) / 1024) / 1024) AS duration
FROM mediation.data_ericsson
WHERE accessPointNameOI != 'mnc001.mcc618.gprs'
    and toYYYYMM(recordOpeningTime) = (:yyyymm)
GROUP BY operator,
         trafficType,
         eventTimeStamp;

insert into default.Liberia_Traffic
--INTL Outgoing
SELECT 2                   AS operator,
       toStartOfDay(Date) AS eventTimeStamp,
       4                   AS trafficType,
       sum(callDuration)/60   AS duration
FROM (
         SELECT networkCallReference                                              AS callReference,
                sum(toUnixTimestamp(chargeableDuration))                          AS callDuration,
                toDateTime(concat(substring(toString(dateForStartOfCharge), 1, 10), ' ',
                                  substring(toString(timeForStartOfCharge), 12))) AS Date
         FROM mediation.ericsson
         WHERE outgoingRoute in dictGet('mediation.mtn_trunk_groups', 'trunks','7')
           and toYYYYMM(EventDate) = (:yyyymm)
           AND (type NOT IN ('M_S_ORIGINATING_SMS_IN_MSC', 'M_S_TERMINATING_SMS_IN_MSC', 'S_S_PROCEDURE'))
         GROUP BY Date,
                  callReference
         )
GROUP BY operator,
         trafficType,
         eventTimeStamp;

insert into default.Liberia_Traffic
--INTL Incoming
SELECT 2                   AS operator,
       toStartOfDay(Date) AS eventTimeStamp,
       3                   AS trafficType,
       sum(callDuration)/60   AS duration
FROM (
         SELECT networkCallReference                                              AS callReference,
                max(toUnixTimestamp(chargeableDuration))                          AS callDuration,
                toDateTime(concat(substring(toString(dateForStartOfCharge), 1, 10), ' ',
                                  substring(toString(timeForStartOfCharge), 12))) AS Date
         FROM mediation.ericsson
         WHERE (type NOT IN ('M_S_ORIGINATING_SMS_IN_MSC', 'M_S_TERMINATING_SMS_IN_MSC', 'S_S_PROCEDURE'))
           and toYYYYMM(EventDate) = (:yyyymm)
           AND incomingRoute in dictGet('mediation.mtn_trunk_groups', 'trunks','7')
         GROUP BY Date,
                  callReference
         )
GROUP BY operator,
         trafficType,
         eventTimeStamp;
*/

--check
select  o.value op,toString(t.operatorId) id,t.value ty,--sum(h.duration)/60
        if(t.operatorId = 2,toFloat64(sum(h.Duration)),sum(h.Duration)) duration
from    default.Liberia_Traffic h
    join mediation.operators o on toString(h.Operator) = toString(o.operatorId)
    join mediation.traffic_types t on toString(h.Traffic_Type) = toString(t.operatorId)
where   toYYYYMM(Date) = (:yyyymm)
--     and t.operatorId not in (3,4)
group by o.value, t.value,o.operatorId,t.operatorId
order by op desc,id;


--insert
insert into default.daily_traffic_liberia

select o.value operator,
       toStartOfDay(Date) ts,
       t.value traffic_Type,
       multiIf(
                Traffic_Type = '1', toFloat64(sum(Duration)),
                Traffic_Type = '2', toFloat64(sum(Duration)*1),
--                 Traffic_Type = '3', toFloat64(sum(Duration)*1.03),
--                 Traffic_Type = '4', toFloat64(sum(Duration)*1.02),
                Traffic_Type = '5', toFloat64(sum(Duration)*1),
                Traffic_Type = '6', toFloat64(sum(Duration)*1),
               null
       )                              volume
from    default.Liberia_Traffic d
    join mediation.operators o on toString(d.Operator) = toString(o.operatorId)
    join mediation.traffic_types t on toString(d.Traffic_Type) = toString(t.operatorId)
where   toYYYYMM(Date) = (:yyyymm)
    and t.operatorId in (1,2,5,6)
    and (o.operatorId) = 1
group by operator, traffic_Type, ts,Traffic_Type
order by ts,operator,Traffic_Type;

insert into default.daily_traffic_liberia

select o.value operator,
       toStartOfDay(Date) ts,
       t.value traffic_Type,
       multiIf(
                Traffic_Type = '1', toFloat64(sum(Duration)*1),
                Traffic_Type = '2', toFloat64(sum(Duration)*1),
--                 Traffic_Type = '3', toFloat64(sum(Duration)*1),
--                 Traffic_Type = '4', toFloat64(sum(Duration)*1.065),
                Traffic_Type = '5', toFloat64(sum(Duration)*1),
                Traffic_Type = '6', toFloat64(sum(Duration)*1),
               null
       )                              volume
from    default.Liberia_Traffic d
    join mediation.operators o on toString(d.Operator) = toString(o.operatorId)
    join mediation.traffic_types t on toString(d.Traffic_Type) = toString(t.operatorId)
where   toYYYYMM(Date) = (:yyyymm)
    and t.operatorId in (1,2,5,6)
    and o.operatorId = 2
group by operator, traffic_Type, ts,Traffic_Type
order by ts,operator,Traffic_Type;






