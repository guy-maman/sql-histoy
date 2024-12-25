

--ORANGE
--On Net
SELECT 1                             AS operator,
       1                             AS trafficType,
       toStartOfDay(eventTimeStamp) AS eventTimeStamp,
       sum(cd)/60             AS duration
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
         eventTimeStamp;

--Orange_To_MTN
select  1 operator,
        5 trafficType,
        toStartOfDay(eventTimeStamp) eventTimeStamp,
        sum(callDuration)/60 duration
from    mediation.zte
where
    type in ('OUT_GATEWAY_RECORD')
    and toYYYYMM(eventTimeStamp) = (:yyyymm)
    and outgoingTKGPName in (dictGet('mediation.orange_trunk_groups', 'trunks','8'))
group by operator,trafficType,eventTimeStamp;



--MTN_To_Orange -- done
SELECT 1                             AS operator,
       6                             AS trafficType,
       toStartOfMonth(eventTimeStamp) AS eventTimeStamp,
       sum(callDuration)/60             AS duration
FROM mediation.zte
WHERE (type IN ('INC_GATEWAY_RECORD'))
  and toYYYYMM(eventTimeStamp) = (:yyyymm)
  AND incomingTKGPName in (dictGet('mediation.orange_trunk_groups', 'trunks','8'))
GROUP BY operator,
         trafficType,
         eventTimeStamp;


--DATA -- Done
SELECT 1                                                              AS operator,
       2                                                              AS trafficType,
       toStartOfMonth(recordOpeningTime)                               AS eventTimeStamp,
       ((sum(listOfTrafficIn) + sum(listOfTrafficOut)) / 1024) / 1024 AS duration
FROM mediation.data_zte
where toYYYYMM(recordOpeningTime) = (:yyyymm)
GROUP BY operator,
         trafficType,
         eventTimeStamp;


SELECT 1                                                         AS operator,
       2                                                         AS trafficType,
       toStartOfMonth(recordOpeningTime)                          AS eventTimeStamp,
       ((sum(downloadAmount) + sum(uploadAmount)) / 1024) / 1024 AS duration
FROM mediation.zte_wtp
where toYYYYMM(recordOpeningTime) = (:yyyymm)
GROUP BY operator,
         trafficType,
         eventTimeStamp;



--INTL Outgoing -- done
SELECT 1                   AS operator,
       4                   AS trafficType,
       toStartOfMonth(Date) AS eventTimeStamp,
       sum(Duration)       AS duration
FROM (
         SELECT callReference,
                toStartOfHour(eventTimeStamp) AS Date,
                sum(callDuration)/60             AS Duration
         FROM mediation.zte
         WHERE (callDuration > 0)
           and toYYYYMM(eventTimeStamp) = (:yyyymm)
           AND (type IN ('MO_CALL_RECORD', 'ROAM_RECORD', 'MCF_CALL_RECORD'))
--            and if(type = 'MO_CALL_RECORD',length(calledNumber) >7,length(calledNumber) <>1)
--            and if(type = 'MO_CALL_RECORD',roamingNumber = '',roamingNumber <> '')
           AND (outgoingTKGPName in (dictGet('mediation.orange_trunk_groups', 'trunks','7')))
         GROUP BY Date,
                  callReference
         )
GROUP BY operator,
         trafficType,
         eventTimeStamp;

--INTL Incoming done
SELECT 1                   AS operator,
       3                   AS trafficType,
       toStartOfMonth(Date) AS eventTimeStamp,
       sum(Duration)/60       AS duration
FROM (
         SELECT callReference,
                toStartOfHour(eventTimeStamp) AS Date,
                sum(callDuration)             AS Duration
         FROM mediation.zte
         WHERE (callDuration > 0)
           and toYYYYMM(eventTimeStamp) = (:yyyymm)
           AND (type IN ('MT_CALL_RECORD', 'ROAM_RECORD', 'MCF_CALL_RECORD'))
           AND (incomingTKGPName in (dictGet('mediation.orange_trunk_groups', 'trunks','7')))
         GROUP BY Date,
                  callReference
         )
GROUP BY operator,
         trafficType,
         eventTimeStamp;

--MTN
-- On Net
SELECT 2                        AS operator,
       1                        AS trafficType,
       toStartOfMonth(EventDate) AS eventTimeStamp,
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




--Orange_To_MTN -- Done
SELECT 2                                        AS operator,
       5                                        AS trafficType,
       toStartOfMonth(EventDate)                 AS eventTimeStamp,
       sum(toUnixTimestamp(chargeableDuration))/60 AS duration
FROM mediation.ericsson
WHERE (originForCharging = '1')
  and toYYYYMM(EventDate) = (:yyyymm)
  AND incomingRoute in dictGet('mediation.mtn_trunk_groups', 'trunks','8')
GROUP BY operator,
         trafficType,
         eventTimeStamp;

--MTN_To_Orange -- done
SELECT 2                                        AS operator,
       6                                        AS trafficType,
       toStartOfMonth(EventDate)                 AS eventTimeStamp,
       sum(toUnixTimestamp(chargeableDuration))/60 AS duration
FROM mediation.ericsson
WHERE outgoingRoute in dictGet('mediation.mtn_trunk_groups', 'trunks','8')
    and toYYYYMM(EventDate) = (:yyyymm)
GROUP BY operator,
         trafficType,
         eventTimeStamp;

--DATA
SELECT 2                                                                     AS operator,
       2                                                                     AS trafficType,
       toStartOfMonth(recordOpeningTime)                                      AS eventTimeStamp,
       round(((sum(listOfTrafficIn) + sum(listOfTrafficOut)) / 1024) / 1024) AS duration
FROM mediation.data_ericsson
WHERE accessPointNameOI != 'mnc001.mcc618.gprs'
    and toYYYYMM(recordOpeningTime) = (:yyyymm)
GROUP BY operator,
         trafficType,
         eventTimeStamp;


--INTL Outgoing -- done
SELECT 2                   AS operator,
       4                   AS trafficType,
       toStartOfMonth(Date) AS eventTimeStamp,
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


--INTL Incoming -- done
SELECT 2                   AS operator,
       3                   AS trafficType,
       toStartOfMonth(Date) AS eventTimeStamp,
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
