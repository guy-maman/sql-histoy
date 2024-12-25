/*
alter table default.INTL delete where toStartOfMonth(Date) = '2024-09-01';
select *
from    default.INTL
where   toYYYYMM(Date) = (:yyyymm);
*/
--INTL
truncate table default.Pre_INTL;
insert into default.Pre_INTL

select  Operator,Direction,callReference,Date,CallingNumber,CalledNumber,RoamingNumber,callDuration,Route,CountryName
from
     (
select  'MTN' Operator,'4' Direction,networkCallReference callReference,
        toDateTime(substring(toString(dateForStartOfCharge), 1, 10)  || ' ' || substring(toString(timeForStartOfCharge), 12)) Date,
        (case when type = 'ROAMING_CALL_FORWARDING' and substring(RoamingNumber,1,1) = '1'
             then substring(RoamingNumber,1,4)
             else
        (case when type = 'ROAMING_CALL_FORWARDING' and substring(RoamingNumber,1,1) <> '1'
             then substring(RoamingNumber,1,3)
             else
        (case when type <> 'ROAMING_CALL_FORWARDING' and substring(CalledNumber,1,1) = '1'
             then substring(CalledNumber,1,4)
              else substring(CalledNumber,1,3)end)end)end) as CountryCode,
        case when substring(callingPartyNumber,3,2) = '00' then substring(callingPartyNumber,5)
             else
        (case when substring(callingPartyNumber,3,2) in ('55','77','88') then '231' || '' || substring(callingPartyNumber,3)
              else
        (case when substring(callingPartyNumber,3,2) in ('05','07','08') then '231' || '' || substring(callingPartyNumber,4)
              else substring(callingPartyNumber,3)
                 end)end)end CallingNumber,
        case when substring(calledPartyNumber,1,2) = '11'
             then substring(calledPartyNumber,3)
             else
        (case when substring(calledPartyNumber,1,4) = '1200'
              then substring(calledPartyNumber,5)
              else
        (case when substring(calledPartyNumber,1,5) in ('14055','14088','14077','12055','12088','12077')
              then '231' || '' || substring(calledPartyNumber,4)
              else
        (case when substring(calledPartyNumber,1,5) in ('14076')
              then '2317' || '' || substring(calledPartyNumber,5)
              else
        (case when calledPartyNumber like ('120%') and substring(calledPartyNumber,1,5) not in ('12055','12077','12088')
                    and substring(calledPartyNumber,6,2) = '00'
              then substring(calledPartyNumber,8)
              else
        (case when calledPartyNumber like ('120%') and substring(calledPartyNumber,1,5) not in ('12055','12077','12088')
                    and substring(calledPartyNumber,6,1) <> '0'
              then substring(calledPartyNumber,6)
              else
        (case when calledPartyNumber like ('120%') and substring(calledPartyNumber,1,5) not in ('12055','12077','12088')
                    and substring(calledPartyNumber,6,2) in ('05','07','08')
              then '231' || '' || substring(calledPartyNumber,7)
              else substring(calledPartyNumber,3)
                end)end)end)end)end)end)end as CalledNumber,
        substring(mobileStationRoamingNumber,3) RoamingNumber,
        max(toUnixTimestamp(chargeableDuration)) callDuration,outgoingRoute Route,c.country_name CountryName
from    mediation.ericsson d
    join mediation.country_keys c on toString(CountryCode) = toString(c.country_code)
where   toYYYYMM(EventDate) = (:yyyymm)
    and outgoingRoute in dictGet('mediation.mtn_trunk_groups', 'trunks','7')
    and type not in ('M_S_ORIGINATING_SMS_IN_MSC','M_S_TERMINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
group by Date,callReference,CallingNumber,CalledNumber,RoamingNumber,CountryCode,Route,CountryName--,calledPartyNumber--callDuration,,callingPartyNumber
order by Date,CallingNumber,CalledNumber
);

---------------------------------------------------

insert into default.Pre_INTL

select  Operator,Direction,callReference,Date,CallingNumber,max(CalledNumber) CalledNumber,max(RoamingNumber) RoamingNumber
        ,max(callDuration) callDuration, max(Route) Route,max(CountryName) CountryName
from (
select  'MTN' Operator,'3' Direction,networkCallReference callReference,
        toDateTime(substring(toString(dateForStartOfCharge), 1, 10)  || ' ' || substring(toString(timeForStartOfCharge), 12)) Date,
        case when substring(CallingNumber,1,1) = '1' then substring(CallingNumber,1,4)
              else
        (case when CallingNumber = '' then '231' else substring(CallingNumber,1,3)end) end as CountryCode,
        case when callingPartyNumber like '1400%' then substring(callingPartyNumber,5)
             else substring(callingPartyNumber,3) end as CallingNumber,
        substring(calledPartyNumber,3) CalledNumber,
        '' RoamingNumber,toUnixTimestamp(chargeableDuration) callDuration,
        incomingRoute Route,c.country_name CountryName
from    mediation.ericsson d
    join mediation.country_keys c on toString(CountryCode) = toString(c.country_code)
where   toYYYYMM(EventDate) = (:yyyymm)
        and type not in ('M_S_ORIGINATING_SMS_IN_MSC','M_S_TERMINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
        and incomingRoute in dictGet('mediation.mtn_trunk_groups', 'trunks','7')
group by Date,callReference,CallingNumber,CalledNumber,RoamingNumber,Route,callDuration,CountryName
order by Date,callReference
        )group by Operator,Direction,callReference,Date,CallingNumber;

--------------------------------------------------------   ORANGE   -----------------------------------------
----------------- MO
insert into default.Pre_INTL

select  Operator,Direction,callReference,Date,CallingNumber,CalledNumber,RoamingNumber,callDuration,Route,CountryName
from
     (
select  hex(callReference) callReference,'ORANGE' Operator,'4' Direction,outgoingTKGPName Route,answerTime Date,
        case when substring(CalledNumber,1,1) = '1' then substring(CalledNumber,1,4)
              else
        (case when CalledNumber = '' then '231' else substring(CalledNumber,1,3)end) end as CountryCode,
        substring(servedMSISDN,3) CallingNumber,
        case    when substring(calledNumber,3,2) = '00' then substring(calledNumber,5)
                else
        (case   when substring(calledNumber,3,2) in ('07','08','05') then '231' || '' || substring(calledNumber,4)
                else substring(calledNumber,3)
                end)end CalledNumber,substring(roamingNumber,5) RoamingNumber,
        callDuration,c.country_name CountryName
from    mediation.zte d
    join mediation.country_keys c on toString(CountryCode) = toString(c.country_code)
where   toYYYYMM(eventTimeStamp) = (:yyyymm)
    and callDuration > 0
    and type in ('MO_CALL_RECORD')
    and length(calledNumber) >7
    and roamingNumber = ''
    and outgoingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','7')
order by answerTime
        );

---------------------------- ROAM

insert into default.Pre_INTL

select  Operator,Direction,callReference,Date,CallingNumber,CalledNumber,RoamingNumber,callDuration,Route,CountryName
from
     (
select  hex(callReference) callReference,'ORANGE' Operator,'4' Direction,outgoingTKGPName Route,answerTime Date,
        case when substring(RoamingNumber,1,1) = '1' then substring(RoamingNumber,1,4)
              else
        (case when CalledNumber = '' then '231' else substring(CalledNumber,1,3)end) end as CountryCode,

        (case    when substring(callingNumber,1,2) = '10' then substring(callingNumber,7)
                else
        (case   when substring(callingNumber,1,2) = '12' then '231' || '' || substring(callingNumber,5)
                else substring(callingNumber,5)
                end)end) as CallingNumber,
        case    when substring(servedMSISDN,3,3) = '231' then substring(servedMSISDN,3)
                else '231' || '' || substring(servedMSISDN,3) end as CalledNumber,
        substring(roamingNumber,5) RoamingNumber,
        callDuration,c.country_name CountryName
from    mediation.zte d
    join mediation.country_keys c on toString(CountryCode) = toString(c.country_code)
where   toYYYYMM(eventTimeStamp) = (:yyyymm)
    and callDuration > 0
    and type in ('ROAM_RECORD')
    and outgoingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','7')
order by answerTime
        );

-------------------------- MCF

insert into default.Pre_INTL

select  Operator,Direction,callReference,Date,CallingNumber,CalledNumber,RoamingNumber,callDuration,Route,CountryName
from
     (
select  hex(callReference) callReference,'ORANGE' Operator,'4' Direction,outgoingTKGPName Route,answerTime Date,
        case when substring(CalledNumber,1,1) = '1' then substring(CalledNumber,1,4)
              else
        (case when CalledNumber = '' then '231' else substring(CalledNumber,1,3)end) end as CountryCode,
        case when substring(callingNumber,1,2) = '12' then  '231' || '' || substring(callingNumber,5)
                else substring(callingNumber,5) end as CallingNumber,
        case when substring(calledNumber,3,2) = '00' then substring(calledNumber,5)
                else substring(calledNumber,3) end as CalledNumber,
        case when substring(servedMSISDN,1,2) = '18' then 'MCF' || ' ' || '231' || '' || substring(servedMSISDN,3)
                else 'MCF' || ' ' || substring(servedMSISDN,3) end as RoamingNumber,
        callDuration,c.country_name CountryName
from    mediation.zte d
    join mediation.country_keys c on toString(CountryCode) = toString(c.country_code)
where   toYYYYMM(eventTimeStamp) = (:yyyymm)
    and callDuration > 0
    and type in ('MCF_CALL_RECORD')
    and outgoingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','7')
order by answerTime
        );


----------------------------------------------------------------
----------------- MT, ROAM & MCF

insert into default.Pre_INTL

select Operator,Direction,callReference,Date,CallingNumber,CalledNumber,RoamingNumber,CallDuration callDuration,Route,c.country_name CountryName
from
(
SELECT  'ORANGE' Operator,'3' Direction,
    greatest(t1.eventTimeStamp,t2.eventTimeStamp,t3.eventTimeStamp,t6.eventTimeStamp) AS Date,
    greatest(t1.callReference,t2.callReference,t3.callReference,t6.callReference) as callReference,
    greatest(t1.incomingTKGPName,t2.incomingTKGPName,t3.incomingTKGPName,t6.incomingTKGPName) as Route,
    multiIf(greatest(t1.callingNumber,t2.callingNumber,t3.callingNumber,t6.callingNumber) as b like '1900%',substring(b,5),
        b like '113800%',substring(b,7),b like '113A00%',substring(b,7),b like '11%',substring(b,5),substring(b,3)) CallingNumber,
    substring(if(greatest(t1.servedMSISDN,t2.servedMSISDN,t3.servedMSISDN,t6.servedMSISDN) as a != '',a,
    greatest(t1.calledNumber,t2.calledNumber,t3.calledNumber,t6.calledNumber)),3) CalledNumber,
    multiIf(RoamingNumber !='' and RoamingNumber like '1%',substring(RoamingNumber,1,4),
            RoamingNumber !='' and RoamingNumber not like '1%',substring(RoamingNumber,1,3),
            CallingNumber = '', '999999',CallingNumber like '1%',substring(CallingNumber,1,4),
            substring(CallingNumber,1,3)) CountryCode,
    substring(t6.roamingNumber,5) AS RoamingNumber,
    greatest(t1.callDuration,t2.callDuration,t3.callDuration,t6.callDuration) as CallDuration
FROM
    (SELECT callReference,answerTime,eventTimeStamp, servedMSISDN, callingNumber, calledNumber, roamingNumber, callDuration, incomingTKGPName
     FROM mediation.zte
     WHERE toYYYYMM(eventTimeStamp) = (:yyyymm)
       AND incomingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','7')
       AND type = 'INC_GATEWAY_RECORD') t1
FULL OUTER JOIN
    (SELECT callReference,answerTime,eventTimeStamp, servedMSISDN, callingNumber, calledNumber, roamingNumber, callDuration, incomingTKGPName
     FROM mediation.zte
     WHERE toYYYYMM(eventTimeStamp) = (:yyyymm)
       AND incomingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','7')
       AND type = 'MT_CALL_RECORD') t2
    ON t1.callReference = t2.callReference and t1.answerTime = t2.answerTime
FULL OUTER JOIN
    (SELECT callReference,answerTime, eventTimeStamp, servedMSISDN, callingNumber, calledNumber, roamingNumber, callDuration, incomingTKGPName
     FROM mediation.zte
     WHERE toYYYYMM(eventTimeStamp) = (:yyyymm)
       AND incomingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','7')
       AND type = 'MCF_CALL_RECORD') t3
    ON t1.callReference = t3.callReference and t1.answerTime = t3.answerTime
FULL OUTER JOIN
    (SELECT callReference,answerTime, eventTimeStamp, servedMSISDN, callingNumber, calledNumber, roamingNumber, callDuration, incomingTKGPName
     FROM mediation.zte
     WHERE toYYYYMM(eventTimeStamp) = (:yyyymm)
       AND incomingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','7')
       AND type = 'ROAM_RECORD') t6
    ON t1.callReference = t6.callReference and t1.answerTime = t6.answerTime
where (t1.callDuration >0 or t2.callDuration > 0 or t3.callDuration > 0 or t6.callDuration > 0)
    ) as t7
left JOIN
       mediation.country_keys c on toString(t7.CountryCode) = toString(c.country_code)
ORDER BY Date, callReference;

-- select  Operator,Direction,callReference,Date,CallingNumber,CalledNumber,RoamingNumber,callDuration,Route,CountryName
-- from
--      (
-- select  hex(callReference) callReference,'ORANGE' Operator,'3' Direction,incomingTKGPName Route,answerTime Date,
--         case when type = 'ROAM_RECORD' and substring(RoamingNumber,1,1) = '1' then substring(roamingNumber,1,4)
--             else
--         (case when type = 'ROAM_RECORD' and substring(RoamingNumber,1,1) <> '1' then substring(roamingNumber,1,3)
--             else
--         (case when substring(CallingNumber,1,1) = '1' then substring(CallingNumber,1,4)
--               else
--         (case when CallingNumber = '' then '231' else substring(CallingNumber,1,3)end)end)end) end as CountryCode,
--         case when substring(callingNumber,5,2) = '00' then substring(callingNumber,7)
--                else substring(callingNumber,5) end as CallingNumber,
--         substring(servedMSISDN,3) CalledNumber,
--         case when type = 'ROAM_RECORD' then substring(roamingNumber,5)
--             else '' end as RoamingNumber,
--         callDuration,c.country_name CountryName
-- from    mediation.zte d
--     join mediation.country_keys c on toString(CountryCode) = toString(c.country_code)
-- where   toYYYYMM(eventTimeStamp) = (:yyyymm)
--     and callDuration > 0
--     and type in ('MT_CALL_RECORD','INC_GATEWAY_RECORD','ROAM_RECORD','MCF_CALL_RECORD')
--     and incomingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','7')
-- order by answerTime
--         );

-- test value
select  Operator, Direction,t.value,toStartOfMonth(Date) date,sum(callDuration)/60
from    default.Pre_INTL i
    join mediation.traffic_types t on i.Direction = toString(t.operatorId)
where   toYYYYMM(Date) = (:yyyymm)
GROUP BY Operator, Direction,t.value,date
order by Operator, Direction,date;

-- select  * --Operator, Direction,toStartOfMonth(Date) date,sum(callDuration)/60
-- from    default.Pre_INTL
-- where   toYYYYMM(Date) = (:yyyymm)
--     and CountryName is null

/*
-- insert to INTL table
insert into default.INTL

select  Operator,Direction,callReference,Date,CallingNumber,CalledNumber,RoamingNumber,round(callDuration*1.044) callDuration
        ,Route,CountryName
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

select  Operator,Direction,callReference,Date,CallingNumber,CalledNumber,RoamingNumber,round(callDuration*1.027) callDuration
        ,Route,CountryName
from    default.Pre_INTL
where   toYYYYMM(Date) = (:yyyymm)
    and Operator = 'ORANGE'
    and Direction = '4';

insert into default.INTL

select  Operator,Direction,callReference,Date,CallingNumber,CalledNumber,RoamingNumber,callDuration*1.030
        ,Route,CountryName
from    default.Pre_INTL
where   toYYYYMM(Date) = (:yyyymm)
    and Operator = 'ORANGE'
    and Direction = '3';

-- test value
select  Operator, Direction,toStartOfMonth(Date) date,sum(callDuration)/60
from    default.INTL
where   toYYYYMM(Date) = (:yyyymm)
GROUP BY Operator, Direction,date
order by Operator, Direction,date;