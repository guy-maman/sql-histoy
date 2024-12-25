/*
alter table default.INTL delete where toStartOfMonth(Date) = '2024-09-01';
select *
from    default.INTL
where   toYYYYMM(Date) = (:yyyymm);
*/
------------------------------------- MTN --------------------------------------
truncate table default.Pre_INTL;
insert into default.Pre_INTL

--MTN Outgoing
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
    and (outgoingRoute in dictGet('mediation.mtn_trunk_groups', 'trunks','7')
        or outgoingRoute in ('HUASIPO'))
    and type not in ('M_S_ORIGINATING_SMS_IN_MSC','M_S_TERMINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
group by Date,callReference,CallingNumber,CalledNumber,RoamingNumber,CountryCode,Route,CountryName--,calledPartyNumber--callDuration,,callingPartyNumber
order by Date,CallingNumber,CalledNumber);

---------
insert into default.Pre_INTL

--MTN Incoming
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
        and (incomingRoute in dictGet('mediation.mtn_trunk_groups', 'trunks','7')
            or incomingRoute in 'HUASIPI')
group by Date,callReference,CallingNumber,CalledNumber,RoamingNumber,Route,callDuration,CountryName
order by Date,callReference
        )group by Operator,Direction,callReference,Date,CallingNumber;

--------------------------------------------------------   ORANGE   -----------------------------------------

insert into default.Pre_INTL

--orange outgoing
select  Operator,Direction,callReference,Date,CallingNumber,CalledNumber,RoamingNumber,callDuration,Route,CountryName
from
     (
select  'ORANGE' Operator,'4' Direction,hex(callReference) callReference,answerTime Date,
        multiIf(left((if(type = 'MO_CALL_RECORD',servedMSISDN,callingNumber)) as x,2)
               in ('10','11','12','14') and substring(x,5,2) in ('77','88','55')
                ,'231' || substring(x,5),
                left(x,2) in ('18','19') and  substring(x,3,2) = '00',substring(x,5),
                left(x,2) in ('1A','1C') and  substring(x,3,2) in ('77','88','55'),'231' || substring(x,3),
                substring(x,3)) CallingNumber,
                multiIf(substring((multiIf(roamingNumber <> '',roamingNumber,
                                    type = 'ROAM_RECORD',servedMSISDN,calledNumber)
                ) as z,3,2) = '00',substring(z,5),
                substring(z,3,2) = '07','231' || substring(z,4),
                substring(z,1,4) = '1877', '231' || substring(z,3),
                substring(z,3)) CalledNumber,
                max(if(roamingNumber <>'',
                (multiIf(substring((if(type = 'ROAM_RECORD',servedMSISDN,calledNumber)) as y,3,2) = '00',substring(y,5),
                substring(y,3,2) = '07','231' || substring(y,4),
                substring(y,1,4) = '1877', '231' || substring(y,3),
                substring(y,3))),'')) RoamingNumber,
        callDuration,outgoingTKGPName Route,
        if(CalledNumber like '1%',substring(CalledNumber,1,4),substring(CalledNumber,1,3)) CountryCode,c.country_name CountryName
from    mediation.zte d
    join mediation.country_keys c on toString(CountryCode) = toString(c.country_code)
where   toYYYYMM(eventTimeStamp) = (:yyyymm)
    and callDuration > 0
    and type in ('MO_CALL_RECORD','ROAM_RECORD','MCF_CALL_RECORD','OUT_GATEWAY_RECORD')
    and outgoingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','7')
group by answerTime,callReference,callDuration,
         outgoingTKGPName,CallingNumber,CalledNumber,CountryCode,country_name
order by answerTime,callReference);

----------
insert into default.Pre_INTL

--orange incoming
select  Operator,Direction,callReference,Date,CallingNumber,CalledNumber,RoamingNumber,callDuration,Route,CountryName
from (
select  'ORANGE' Operator,'3' Direction,
        hex(callReference) callReference,answerTime Date,callDuration,--type,servedMSISDN,callingNumber,calledNumber,
        multiIf(callingNumber like '1900%',substring(callingNumber,5),
                left(callingNumber,2) ='11' and substring(callingNumber,5,2) ='00',
                substring(callingNumber,7),
                left(callingNumber,2) ='11',substring(callingNumber,5),
                substring(callingNumber,3)) CallingNumber,
        (multiIf(substring((if(type = 'INC_GATEWAY_RECORD',calledNumber,servedMSISDN)) as a,3,2) = '00',
        substring(a,5),substring(a,3,2) = '77' and substring(a,1,2) = '1A' ,'231' || substring(a,3),
        substring(a,3))) CalledNumber,
        max(substring(roamingNumber,5)) RoamingNumber,
        if(CallingNumber like '1%',left(CallingNumber,4),left(CallingNumber,3)) CountryCode,
        incomingTKGPName Route,country_name CountryName
from    mediation.zte d
    join mediation.country_keys c on toString(CountryCode) = toString(c.country_code)
where   toYYYYMM(eventTimeStamp) = (:yyyymm)
    and callDuration > 0
    and type in ('ROAM_RECORD','MCF_CALL_RECORD','MT_CALL_RECORD','INC_GATEWAY_RECORD')
    and incomingTKGPName in dictGet('mediation.orange_trunk_groups', 'trunks','7')
group by callReference,Date,CallingNumber,CalledNumber,/*RoamingNumber,*/callDuration,Route,CountryCode,CountryName
order by Date,callReference);

-- test value
select  Operator, Direction,t.value,toStartOfMonth(Date) date,sum(callDuration)/60
from    default.Pre_INTL i
    join mediation.traffic_types t on i.Direction = toString(t.operatorId)
where   toYYYYMM(Date) = (:yyyymm)
GROUP BY Operator, Direction,t.value,date
order by Operator, Direction,date;

