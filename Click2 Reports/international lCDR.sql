
-- select * from Site_Info_MTN
-- select * from mediation.CountryCode
/*
create table INTL (Operator Nullable(String),Direction Nullable(String),callReference Nullable(String),Date DateTime
    ,CallingNumber Nullable(String),CalledNumber Nullable(String),RoamingNumber Nullable(String),callDuration Nullable(Int32),Route Nullable(String),CountryName Nullable(String))
    ENGINE = MergeTree() order by Date;

create table CountryCode (ind Int8,CountryCode Nullable(Int32),CountryName Nullable(String))
    ENGINE = MergeTree() order by ind;
*/
-- create table mediation.CountryCode ( CountryCode int, CountryName String) engine = MergeTree() order by CountryCode;

/*
-- alter table mediation_shard.daily_traffic_liberia_shard on cluster liberia delete where toStartOfMonth(date) = '2024-04-01';

insert into CountryCode

select  ind,CountryCode,CountryName
from    mediation.CountryCode

SELECT  Operator,Direction,sum(callDuration)/60
from    default.INTL
where   toYear(Date) = (:year)
    and toMonth(Date) = (:month)
group by Operator,Direction
  */

--ORANGE Outgoing
insert into default.INTL
select  Operator,Direction,callReference,Date,CallingNumber,CalledNumber,RoamingNumber,callDuration,Route,CountryName
from
     (
select  case
            when type = ('MO_CALL_RECORD') then 1
            when type = ('ROAM_RECORD') then 2
            when type = ('MCF_CALL_RECORD') then 3
        end ind,
        hex(callReference) callReference,'ORANGE' Operator,'Outgoing' Direction,outgoingTKGPName Route,answerTime Date,
        case
            when substring(CalledNumber,1,3) = '231' and RoamingNumber > '' then
            (case
                when substring(RoamingNumber,1,1) = '1' then substring(RoamingNumber,1,4)
                when RoamingNumber = '' then '231'
                else substring(RoamingNumber,1,3)
            end)
            else
            (case
                when substring(CalledNumber,1,1) = '1' then substring(CalledNumber,1,4)
                when CalledNumber = '' then '231'
                else substring(CalledNumber,1,3)
            end)
        end CountryCode,
        case
            when ind = 1 then substring(servedMSISDN,3)
            when ind = 2 and substring(callingNumber,1,2) = '10' then substring(callingNumber,7)
            when ind in (2,3) and substring(callingNumber,1,2) = '12' then  '231' || '' || substring(callingNumber,5)
            else substring(callingNumber,5)
        end CallingNumber,
        case
            when ind in (1,3) and substring(calledNumber,3,2) = '00' then substring(calledNumber,5)
            when ind = 1 and substring(calledNumber,3,2) in ('07','08','05') then '231' || '' || substring(calledNumber,4)
            when ind = 2 and substring(servedMSISDN,3,3) = '231' then substring(servedMSISDN,3)
            when ind=2 and substring(servedMSISDN,3,3) <> '231' then '231' || '' || substring(servedMSISDN,3)
            else substring(calledNumber,3)
        end CalledNumber,
        case
            when ind = 3 and substring(servedMSISDN,1,2) = '18' then '231' || '' || substring(servedMSISDN,3)
            when ind in (1,2) then  substring(roamingNumber,5)
            else substring(servedMSISDN,3)
        end RoamingNumber,
        callDuration
from    mediation.zte
where   toYear(eventTimeStamp) = (:year)
    and toMonth(eventTimeStamp) = (:month)
    and callDuration > 0
    and type in ('MO_CALL_RECORD','ROAM_RECORD','MCF_CALL_RECORD')
    and length(calledNumber) >7
--     and roamingNumber = ''
    and outgoingTKGPName in ('OLIB_SBC_OFR','BARAK SIP 2','BIC_SBC_SIP','BIC_SBC_SIP_NAIROBI','BICS_SBC_SIP_NAIROBI','BICS-4193','BICS-4194',
                             'BTS_SBC_SIP','BTS_SBC_SIP OUT','BTS_SBC_SIP_IN','OCI_ASSB','OCI_KM4','Orange-12482','Orange-12490','OSL_SBC_SIP')
order by answerTime
        ) as a
left any join
(
    select CountryName, toString(CountryCode) CountryCode from mediation.CountryCode
    ) as b on a.CountryCode = b.CountryCode

--ORANGE Incoming
insert into default.INTL
select  Operator,Direction,callReference,Date,CallingNumber,CalledNumber,RoamingNumber,callDuration,Route,CountryName
from
     (
select  case
            when type = ('MT_CALL_RECORD') then 1
            when type = ('ROAM_RECORD') then 2
            when type = ('MCF_CALL_RECORD') then 3
        end ind,
        hex(callReference) callReference,'ORANGE' Operator,'Incoming' Direction,incomingTKGPName Route,answerTime Date,
        case
            when ind = 2 and substring(RoamingNumber,1,1) = '1' then substring(roamingNumber,1,4)
            when ind = 2 and substring(RoamingNumber,1,1) <> '1' then substring(roamingNumber,1,3)
            when substring(CallingNumber,1,1) = '1' then substring(CallingNumber,1,4)
            when CallingNumber = '' then 'Unknown'
            else substring(CallingNumber,1,3)
        end CountryCode,
        case when substring(callingNumber,5,2) = '00' then substring(callingNumber,7)
               else substring(callingNumber,5) end as CallingNumber,
        substring(servedMSISDN,3) CalledNumber,
        case when type = 'ROAM_RECORD' then substring(roamingNumber,5)
            else '' end as RoamingNumber,
        callDuration
from    mediation.zte
where   toYear(eventTimeStamp) = (:year)
    and toMonth(eventTimeStamp) = (:month)
    and callDuration > 0
    and type in ('MT_CALL_RECORD','ROAM_RECORD','MCF_CALL_RECORD')
    and incomingTKGPName in ('OLIB_SBC_OFR','BARAK SIP 2','BIC_SBC_SIP','BIC_SBC_SIP_NAIROBI','BICS_SBC_SIP_NAIROBI','BICS-4193','BICS-4194',
                             'BTS_SBC_SIP','BTS_SBC_SIP OUT','BTS_SBC_SIP_IN','OCI_ASSB','OCI_KM4','Orange-12482','Orange-12490','OSL_SBC_SIP')
order by answerTime
        ) as a
left any join
(
    select CountryName, toString(CountryCode) CountryCode from mediation.CountryCode
    ) as b on a.CountryCode = b.CountryCode;

--MTN

--MTN Outgoing
insert into default.INTL
select  Operator,Direction,callReference,Date,CallingNumber,CalledNumber,RoamingNumber,callDuration,Route,CountryName
from
     (
select  'MTN' Operator,'Outgoing' Direction,networkCallReference callReference,
        toDateTime(substring(toString(dateForStartOfCharge), 1, 10)  || ' ' || substring(toString(timeForStartOfCharge), 12)) Date,
        toInt32(
        case when type = 'ROAMING_CALL_FORWARDING' and substring(RoamingNumber,1,1) = '1' then substring(RoamingNumber,1,4)
             when type = 'ROAMING_CALL_FORWARDING' and substring(RoamingNumber,1,1) <> '1' then substring(RoamingNumber,1,3)
             when type <> 'ROAMING_CALL_FORWARDING' and substring(CalledNumber,1,1) = '1'then substring(CalledNumber,1,4)
             else substring(CalledNumber,1,3)
        end) CountryCodes,
        case
            when substring(callingPartyNumber,3,2) = '00' then substring(callingPartyNumber,5)
            when substring(callingPartyNumber,3,2) in ('55','77','88') then '231' || '' || substring(callingPartyNumber,3)
            when substring(callingPartyNumber,3,2) in ('05','07','08') then '231' || '' || substring(callingPartyNumber,4)
            else substring(callingPartyNumber,3)
        end CallingNumber,
        case when substring(calledPartyNumber,1,2) = '11' then substring(calledPartyNumber,3)
             when substring(calledPartyNumber,1,4) = '1200' then substring(calledPartyNumber,5)
             when substring(calledPartyNumber,1,5) in ('14055','14088','14077','12055','12088','12077') then '231' || '' || substring(calledPartyNumber,4)
             when substring(calledPartyNumber,1,5) in ('14076') then '2317' || '' || substring(calledPartyNumber,5)
             when calledPartyNumber like ('120%') and substring(calledPartyNumber,1,5) not in ('12055','12077','12088')
                and substring(calledPartyNumber,6,2) = '00' then substring(calledPartyNumber,8)
             when calledPartyNumber like ('120%') and substring(calledPartyNumber,1,5) not in ('12055','12077','12088')
                and substring(calledPartyNumber,6,1) <> '0' then substring(calledPartyNumber,6)
             when calledPartyNumber like ('120%') and substring(calledPartyNumber,1,5) not in ('12055','12077','12088')
                and substring(calledPartyNumber,6,2) in ('05','07','08') then '231' || '' || substring(calledPartyNumber,7)
             else substring(calledPartyNumber,3)
        end CalledNumber,
        substring(mobileStationRoamingNumber,3) RoamingNumber,
        (toUnixTimestamp(chargeableDuration)) callDuration,outgoingRoute Route
from    mediation.ericsson
where   toYear(EventDate) = (:year)
    and toMonth(EventDate) = (:month)
    and outgoingRoute in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O', 'L2MBC2O', 'ZURO','GENO')
    and type not in ('M_S_ORIGINATING_SMS_IN_MSC','M_S_TERMINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
group by Date,callReference,CallingNumber,CalledNumber,RoamingNumber,CountryCodes,Route,callDuration
order by Date,CallingNumber,CalledNumber
        ) as a
left any join
(
    select CountryName,CountryCode from mediation.CountryCode
    ) as b on a.CountryCodes = b.CountryCode

--MTN Incoming
insert into default.INTL
select  Operator,Direction,callReference,Date,CallingNumber,max(CalledNumber) CalledNumber,max(RoamingNumber) RoamingNumber
        ,max(callDuration) callDuration, max(Route) Route,max(CountryName) CountryName
from (
select  Operator,Direction,callReference,Date,CallingNumber,CalledNumber,RoamingNumber,callDuration,Route,CountryName
from
     (
select  'MTN' Operator,'Incoming' Direction,networkCallReference callReference,
        toDateTime(substring(toString(dateForStartOfCharge), 1, 10)  || ' ' || substring(toString(timeForStartOfCharge), 12)) Date,
        case
            when substring(CallingNumber,1,1) = '1' then substring(CallingNumber,1,4)
            when CallingNumber = '' then '231' else substring(CallingNumber,1,3)
        end CountryCode,
        case
            when callingPartyNumber like '1400%' then substring(callingPartyNumber,5)
            else substring(callingPartyNumber,3)
        end CallingNumber,
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
        ) as a
left any join
(
    select CountryName, toString(CountryCode) CountryCode from mediation.CountryCode
    ) as b on a.CountryCode = b.CountryCode
)group by Operator,Direction,callReference,Date,CallingNumber;
