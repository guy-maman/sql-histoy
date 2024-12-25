/*
create table mediation.INTL (Operator Nullable(String),Direction Nullable(String),callReference Nullable(String),Date DateTime
    ,CallingNumber Nullable(String),CalledNumber Nullable(String),RoamingNumber Nullable(String),callDuration Nullable(Int32),Route Nullable(String),CountryName Nullable(String))
    ENGINE = MergeTree() order by Date;
*/
-- select * from Site_Info_MTN
-- select * from mediation.CountryCode
-- create table mediation.CountryCode ( CountryCode int, CountryName String) engine = MergeTree() order by CountryCode;

------------------------------------------------------  MTN  -------------------------------------------------
truncate table mediation.INTL

insert into mediation.INTL


select  Operator,Direction,callReference,Date,CallingNumber,CalledNumber,RoamingNumber,callDuration,Route,CountryName
from
     (

select  'MTN' Operator,'Outgoing' Direction,networkCallReference callReference,
        toDateTime(substring(toString(dateForStartOfCharge), 1, 10)  || ' ' || substring(toString(timeForStartOfCharge), 12)) Date,
        toInt32(case when type = 'ROAMING_CALL_FORWARDING' and substring(RoamingNumber,1,1) = '1'
             then substring(RoamingNumber,1,4)
             else
        (case when type = 'ROAMING_CALL_FORWARDING' and substring(RoamingNumber,1,1) <> '1'
             then substring(RoamingNumber,1,3)
             else
        (case when type <> 'ROAMING_CALL_FORWARDING' and substring(CalledNumber,1,1) = '1'
             then substring(CalledNumber,1,4)
              else substring(CalledNumber,1,3)end)end)end) as CountryCodes,
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
        max(toUnixTimestamp(chargeableDuration)) callDuration,outgoingRoute Route
from    mediation.ericsson
where   toYear(EventDate) = (:year)
    and toMonth(EventDate) = (:month)
    and outgoingRoute in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O', 'L2MBC2O', 'ZURO')
    and type not in ('M_S_ORIGINATING_SMS_IN_MSC','M_S_TERMINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
group by Date,callReference,CallingNumber,CalledNumber,RoamingNumber,CountryCodes,Route--,calledPartyNumber--callDuration,,callingPartyNumber
order by Date,CallingNumber,CalledNumber
        ) as a
left any join
(
    select CountryName, /*toString(CountryCode)*/ CountryCode from mediation.CountryCode
    ) as b on a.CountryCodes = b.CountryCode;




---------------------------------------------------

insert into mediation.INTL

select  Operator,Direction,callReference,Date,CallingNumber,max(CalledNumber) CalledNumber,max(RoamingNumber) RoamingNumber
        ,max(callDuration) callDuration, max(Route) Route,max(CountryName) CountryName
from (
select  Operator,Direction,callReference,Date,CallingNumber,CalledNumber,RoamingNumber,callDuration,Route,CountryName
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
        ) as a
left any join
(
    select CountryName, toString(CountryCode) CountryCode from mediation.CountryCode
    ) as b on a.CountryCode = b.CountryCode
)group by Operator,Direction,callReference,Date,CallingNumber;

--------------------------------------------------------   ORANGE   -----------------------------------------

insert into mediation.INTL

----------------- MO

select  Operator,Direction,callReference,Date,CallingNumber,CalledNumber,RoamingNumber,callDuration,Route,CountryName
from
     (
select  hex(callReference) callReference,'ORANGE' Operator,'Outgoing' Direction,outgoingTKGPName Route,answerTime Date,
        case when substring(CalledNumber,1,1) = '1' then substring(CalledNumber,1,4)
              else
        (case when CalledNumber = '' then '231' else substring(CalledNumber,1,3)end) end as CountryCode,
        substring(servedMSISDN,3) CallingNumber,
        case    when substring(calledNumber,3,2) = '00' then substring(calledNumber,5)
                else
        (case   when substring(calledNumber,3,2) in ('07','08','05') then '231' || '' || substring(calledNumber,4)
                else substring(calledNumber,3)
                end)end CalledNumber,substring(roamingNumber,5) RoamingNumber,
        callDuration
from    mediation.zte
where   toYear(eventTimeStamp) = (:year)
    and toMonth(eventTimeStamp) = (:month)
    and callDuration > 0
    and type in ('MO_CALL_RECORD')
    and length(calledNumber) >7
    and roamingNumber = ''
    and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482', 'BARAK SIP 2','OLIB_SBC_OFR')
order by answerTime
        ) as a
left any join
(
    select CountryName, toString(CountryCode) CountryCode from mediation.CountryCode
    ) as b on a.CountryCode = b.CountryCode;

---------------------------- ROAM

insert into mediation.INTL

select  Operator,Direction,callReference,Date,CallingNumber,CalledNumber,RoamingNumber,callDuration,Route,CountryName
from
     (
select  hex(callReference) callReference,'ORANGE' Operator,'Outgoing' Direction,outgoingTKGPName Route,answerTime Date,
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
        callDuration
from    mediation.zte
where   toYear(eventTimeStamp) = (:year)
    and toMonth(eventTimeStamp) = (:month)
    and callDuration > 0
    and type in ('ROAM_RECORD')
    and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482', 'BARAK SIP 2','OLIB_SBC_OFR')
order by answerTime
        ) as a
left any join
(
    select CountryName, toString(CountryCode) CountryCode from mediation.CountryCode
    ) as b on a.CountryCode = b.CountryCode;

-------------------------- MCF

insert into mediation.INTL

select  Operator,Direction,callReference,Date,CallingNumber,CalledNumber,RoamingNumber,callDuration,Route,CountryName
from
     (
select  hex(callReference) callReference,'ORANGE' Operator,'Outgoing' Direction,outgoingTKGPName Route,answerTime Date,
        case when substring(CalledNumber,1,1) = '1' then substring(CalledNumber,1,4)
              else
        (case when CalledNumber = '' then '231' else substring(CalledNumber,1,3)end) end as CountryCode,
        case when substring(callingNumber,1,2) = '12' then  '231' || '' || substring(callingNumber,5)
                else substring(callingNumber,5) end as CallingNumber,
        case when substring(calledNumber,3,2) = '00' then substring(calledNumber,5)
                else substring(calledNumber,3) end as CalledNumber,
        case when substring(servedMSISDN,1,2) = '18' then 'MCF' || ' ' || '231' || '' || substring(servedMSISDN,3)
                else 'MCF' || ' ' || substring(servedMSISDN,3) end as RoamingNumber,
        callDuration
from    mediation.zte
where   toYear(eventTimeStamp) = (:year)
    and toMonth(eventTimeStamp) = (:month)
    and callDuration > 0
    and type in ('MCF_CALL_RECORD')
    and outgoingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482', 'BARAK SIP 2','OLIB_SBC_OFR')
order by answerTime
        ) as a
left any join
(
    select CountryName, toString(CountryCode) CountryCode from mediation.CountryCode
    ) as b on a.CountryCode = b.CountryCode;


----------------------------------------------------------------
----------------- MT, ROAM & MCF

insert into mediation.INTL

select  Operator,Direction,callReference,Date,CallingNumber,CalledNumber,RoamingNumber,callDuration,Route,CountryName
from
     (
select  hex(callReference) callReference,'ORANGE' Operator,'Incoming' Direction,incomingTKGPName Route,answerTime Date,
        case when type = 'ROAM_RECORD' and substring(RoamingNumber,1,1) = '1' then substring(roamingNumber,1,4)
            else
        (case when type = 'ROAM_RECORD' and substring(RoamingNumber,1,1) <> '1' then substring(roamingNumber,1,3)
            else
        (case when substring(CallingNumber,1,1) = '1' then substring(CallingNumber,1,4)
              else
        (case when CallingNumber = '' then '231' else substring(CallingNumber,1,3)end)end)end) end as CountryCode,
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
    and incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482', 'BARAK SIP 2','OLIB_SBC_OFR')
order by answerTime
        ) as a
left any join
(
    select CountryName, toString(CountryCode) CountryCode from mediation.CountryCode
    ) as b on a.CountryCode = b.CountryCode;

--International Traffic

select Operator,Direction,CountryName,callDuration
from (
      select Top 10 1 ind, Operator, Direction, CountryName, round(sum(callDuration)/60,2) callDuration
      from mediation.INTL
      where toYear(Date) = (:year)
        and toMonth(Date) = (:month)
        and CountryName not in ('Liberia')
        and Operator = 'ORANGE'
        and Direction = 'Incoming'
      group by Operator, Direction, CountryName
      order by callDuration desc
      union all
      select Top 10 2 ind, Operator, Direction, CountryName, round(sum(callDuration)/60,2) callDuration
      from (
      select Operator, Direction, CountryName,callReference,Date,sum(callDuration) callDuration
      from mediation.INTL
      where toYear(Date) = (:year)
        and toMonth(Date) = (:month)
        and CountryName not in ('Liberia')
        and Operator = 'MTN'
        and Direction = 'Incoming'
      group by Operator, Direction, CountryName,Date,callReference
      )
      group by Operator, Direction, CountryName
      order by callDuration desc
      union all
      select Top 10 3 ind, 'Merged' Operator, Direction, CountryName, round(sum(callDuration)/60,2) callDuration
      from mediation.INTL
      where toYear(Date) = (:year)
        and toMonth(Date) = (:month)
        and CountryName not in ('Liberia')
--     and Operator = 'MTN'
        and Direction = 'Incoming'
      group by Operator, Direction, CountryName
      order by callDuration desc
      union all
      select Top 10 4 ind, Operator, Direction, CountryName, round(sum(callDuration)/60,2) callDuration
      from mediation.INTL
      where toYear(Date) = (:year)
        and toMonth(Date) = (:month)
        and CountryName not in ('Liberia')
        and Operator = 'ORANGE'
        and Direction = 'Outgoing'
      group by Operator, Direction, CountryName
      order by callDuration desc
      union all
      select Top 10 5 ind, Operator, Direction, CountryName, round(sum(callDuration)/60,2) callDuration
      from mediation.INTL
      where toYear(Date) = (:year)
        and toMonth(Date) = (:month)
        and CountryName not in ('Liberia')
        and Operator = 'MTN'
        and Direction = 'Outgoing'
      group by Operator, Direction, CountryName
      order by callDuration desc
      union all
      select Top 10 6 ind, 'Merged' Operator, Direction, CountryName, round(sum(callDuration)/60,2) callDuration
      from mediation.INTL
      where toYear(Date) = (:year)
        and toMonth(Date) = (:month)
        and CountryName not in ('Liberia')
--     and Operator = 'ORANGE'
        and Direction = 'Outgoing'
      group by Operator, Direction, CountryName
      order by callDuration desc
         )
order by ind,callDuration desc;


-- select * from INTL

-- 994913.17
/*
--International
select  round(sum(callDuration)/60,2) callDuration
from (
select  Operator,Direction,callReference,Date,CallingNumber,max(CalledNumber) CalledNumber,max(RoamingNumber) RoamingNumber
        ,max(callDuration) callDuration, max(Route) Route,max(CountryName) CountryName
from    mediation.INTL
where   toYear(Date) = (:year)
    and toMonth(Date) = (:month)
    and Operator = 'ORANGE'
--     and Direction = 'Incoming'
    and Direction = 'Outgoing'
group by Operator,Direction,callReference,Date,CallingNumber
order by Direction,Date
)
*/
-- insert into mediation.Top10

-- select  toDate(Date) Date,Operator,Direction,CountryName,round(sum(callDuration)/60,2) callDuration
-- select  Operator,Direction,round(sum(callDuration)/60,2) callDuration

-- group by Operator,Direction
-- group by Date,Operator,Direction,CountryName

-- insert into CountryCodes (CountryCode ,CountryName) values (,'Other')

/*
select  Operator,Direction,sum(callDuration)/60 callDuration
from    mediation.International_traffic
where   toYear(Date) = (:year)
    and toMonth(Date) = (:month)
group by Operator,Direction
*/
/*---------------------------------------------------------TEST-----------------------------------------------------------------------------

select  substring(servedMSISDN,1,2) x,substring(servedMSISDN,3,3) y
from    mediation.zte
where   toYear(eventTimeStamp) = (:year)
    and toMonth(eventTimeStamp) = (:month)
--     and toDayOfMonth(eventTimeStamp) = (:day)
--     and (callingNumber like '%777824482' or servedMSISDN like '%777824482')
    and callDuration > 0
    and type in ('MCF_CALL_RECORD')--,'ROAM_RECORD','MCF_CALL_RECORD')
--     and length(calledNumber) >7
    and roamingNumber = ''
--     and callReference = ('2242B6E7')
    and incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482', 'BARAK SIP 2','OLIB_SBC_OFR')
group by x,y
order by x,y

-- select  Operator,Direction,Route,Date,CallingNumber,CalledNumber,callDuration
select  type,callReference,servedMSISDN,callingNumber,calledNumber,roamingNumber,answerTime
-- select  callReference,outgoingTKGPName Route,answerTime Date,
--         (case    when substring(callingNumber,1,2) = '10' then substring(callingNumber,7)
--                 else
--         (case   when substring(callingNumber,1,2) = '12' then '231' || '' || substring(callingNumber,5)
--                 else substring(callingNumber,5)
--                 end)end) as CallingNumber,
--         case    when (substring(servedMSISDN,3,3) = '231' or substring(servedMSISDN,1,2) = '18')
--                 then
--                 ((case when substring(calledNumber,3,2) = '00' then substring(calledNumber,5) else substring(calledNumber,3) end) || '-' || substring(servedMSISDN,3))
--                 else substring(servedMSISDN,3) || '-' || (case when substring(calledNumber,3,2) = '00' then substring(calledNumber,5) else substring(calledNumber,3)
--                     end) end as CalledNumber,
--        callDuration
from    mediation.zte
where   toYear(eventTimeStamp) = (:year)
    and toMonth(eventTimeStamp) = (:month)
--     and toDayOfMonth(eventTimeStamp) between (:day) and (:day1)
--     and (callingNumber like '%777824482' or servedMSISDN like '%777824482')
    and callDuration > 0
--     and recordType in ('13','2')
    and type in (/*'MO_CALL_RECORD',*/'MCF_CALL_RECORD'/*,'ROAM_RECORD','MCF_CALL_RECORD'*/)
    and roamingNumber = ''
--     or  (type = ('MO_CALL_RECORD') and roamingNumber = '' and length(calledNumber) > 7)
--     and length(calledNumber) >7
--     and callingNumber like '11381%'
--     and callReference = ('C205025E')
    and incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482', 'BARAK SIP 2','OLIB_SBC_OFR')
order by answerTime,callReference




----------------- MT, ROAM & MCF

select  Operator,Direction,Route,CountryName,Date,CallingNumber,CalledNumber,callDuration
from
     (
select  'ORANGE' Operator,'Incoming' Direction,outgoingTKGPName Route,answerTime Date,
        case when substring(CallingNumber,1,1) = '1' then substring(CallingNumber,1,4)
              else substring(CallingNumber,1,3) end as CountryCode,
        case when substring(callingNumber,5,2) = '00' then substring(callingNumber,7)
               else substring(callingNumber,5) end as CallingNumber,
        substring(servedMSISDN,3) CalledNumber,callDuration
from    mediation.zte
where   toYear(eventTimeStamp) = (:year)
    and toMonth(eventTimeStamp) = (:month)
    and callDuration > 0
    and type in ('MT_CALL_RECORD','ROAM_RECORD','MCF_CALL_RECORD')
    and incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482', 'BARAK SIP 2','OLIB_SBC_OFR')
order by answerTime
        )any left join
(
    select CountryName, toString(CountryCode) CountryCode from CountryCodes
    )using CountryCode;

---------------------------- ROAM

select  Operator,Direction,Route,CountryName,Date,CallingNumber,CalledNumber,callDuration
from
     (
select  'ORANGE' Operator,'Incoming' Direction,outgoingTKGPName Route,answerTime Date,
        case when substring(CallingNumber,1,1) = '1' then substring(CallingNumber,1,4)
              else substring(CallingNumber,1,3) end as CountryCode,
        (case    when substring(callingNumber,1,2) = '10' then substring(callingNumber,7)
                else
        (case   when substring(callingNumber,1,2) = '12' then '231' || '' || substring(callingNumber,5)
                else substring(callingNumber,5)
                end)end) as CallingNumber,
        substring(servedMSISDN,3) CalledNumber,
        callDuration
from    mediation.zte
where   toYear(eventTimeStamp) = (:year)
    and toMonth(eventTimeStamp) = (:month)
    and callDuration > 0
    and type in ('ROAM_RECORD')
    and incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482', 'BARAK SIP 2','OLIB_SBC_OFR')
order by answerTime
        )any left join
(
    select CountryName, toString(CountryCode) CountryCode from CountryCodes
    )using CountryCode;


-------------------------- MCF

select  Operator,Direction,Route,CountryName,Date,CallingNumber,CalledNumber,callDuration
from
     (
select  'ORANGE' Operator,'Incoming' Direction,outgoingTKGPName Route,answerTime Date,
        case when substring(CallingNumber,1,1) = '1' then substring(CallingNumber,1,4)
              else substring(CallingNumber,1,3) end as CountryCode,
        case   when substring(callingNumber,1,2) = '12' then '231' || '' || substring(callingNumber,5)
                else substring(callingNumber,5)
                end as CallingNumber,
        case    when (substring(servedMSISDN,3,3) = '231' or substring(servedMSISDN,1,2) = '18')
                then
                ((case when substring(calledNumber,3,2) = '00' then substring(calledNumber,5) else substring(calledNumber,3) end) || '-' || substring(servedMSISDN,3))
                else substring(servedMSISDN,3) || '-' || (case when substring(calledNumber,3,2) = '00' then substring(calledNumber,5) else substring(calledNumber,3)
                    end) end as CalledNumber,
       callDuration
from    mediation.zte
where   toYear(eventTimeStamp) = (:year)
    and toMonth(eventTimeStamp) = (:month)
    and callDuration > 0
    and type in ('MCF_CALL_RECORD')
    and roamingNumber = ''
    and incomingTKGPName in ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193','Orange-12482', 'BARAK SIP 2','OLIB_SBC_OFR')
order by answerTime
        )any left join
(
    select CountryName, toString(CountryCode) CountryCode from CountryCodes
    )using CountryCode;




-------------------------------------------------------------------------------------------------------------------------

select  Date,Call_Type,sum(callDuration) callDuration
from (
select  Date, Call_Type, callDuration
from (
select  callReference,
        toDate(eventTimeStamp) Date,
        callDuration,
        case    when (incomingTKGPName in
                 ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY', 'MSC_SBC_ACS', 'SBC_FriendnChat',
                  'SBC_siptrunk', 'VOIPE_PBX_SIP', 'OCS-SIP-A', 'OCS-SIP-B', 'OCS-SIP-C', 'OCS-SIP-D')
                and outgoingTKGPName in
                   ('', 'CALL_CENTER', 'LEC_PBX', 'US AMBASY', 'MSC_SBC_ACS', 'SBC_FriendnChat',
                    'SBC_siptrunk', 'VOIPE_PBX_SIP', 'OCS-SIP-A', 'OCS-SIP-B', 'OCS-SIP-C', 'OCS-SIP-D'))
                then 'On_Net'
        else (
        case    when incomingTKGPName in
                  ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482',
                   'BARAK SIP 2',
                   'OLIB_SBC_OFR')
                then 'International_Incoming'
        else (
        case    when outgoingTKGPName in
                 ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193',
                  'Orange-12482', 'BARAK SIP 2',
                  'OLIB_SBC_OFR')
                then 'International_Outgoing'
        else (
        case    when incomingTKGPName in ('Comium', 'LoneStar', 'MSC_SBC_MTN')
                then 'MTN_To_Orange'
        else (
        case    when outgoingTKGPName in ('Comium', 'LoneStar', 'MSC_SBC_MTN')
                then 'Orange_To_MTN'
        else (
        case    when (outgoingTKGPName in
                ('IVR_OBD_SERV2', 'IVR1_SERV1', 'RBT_SERV1','RBT_SERV2', 'Religious_Service','SBC_VoiceMail',
                'VoiceMail_1', 'VoiceMail_2', 'OCS-SIP-LAB')
                or incomingTKGPName in
                ('IVR_OBD_SERV2', 'IVR1_SERV1', 'RBT_SERV1','RBT_SERV2', 'Religious_Service','SBC_VoiceMail',
                    'VoiceMail_1', 'VoiceMail_2','OCS-SIP-LAB'))
                and length(calledNumber) > 6
                then 'Ex'
        else (incomingTKGPName || ',' || outgoingTKGPName)
        end) end) end) end) end) end as Call_Type
from    mediation.zte
where   toYear(eventTimeStamp) = (:year)
    and toMonth(eventTimeStamp) = (:month)
    and type in
        ('MT_CALL_RECORD', 'INC_GATEWAY_RECORD', 'MO_CALL_RECORD', 'OUT_GATEWAY_RECORD', 'ROAM_RECORD',
         'MCF_CALL_RECORD')
    and callDuration > 0
         )  group by Date, callReference, Call_Type, callDuration
         )  group by Date, Call_Type;












/*
select  EventDate,max(toUnixTimestamp(chargeableDuration)) chargeableDuration,callingPartyNumber
        ,case   when substring(calledPartyNumber, 3, 3) in ('055', '077', '088')
                then '231' || '' || substring(calledPartyNumber, 4)
                else
        (case   when substring(calledPartyNumber,1,5) in ('12025','12073','12074','12076','12085','12086','12095','12096')
                        and substring(calledPartyNumber,6,3) in ('055', '077', '088')
                then ('231' || '' || substring(calledPartyNumber, 7))
                else
        (case   when substring(calledPartyNumber,1,5) in ('12025','12073','12074','12076','12085','12086','12095','12096')
                        and substring(calledPartyNumber,6,2) = '00'
                then substring(calledPartyNumber, 8)
                else
        (case   when substring(calledPartyNumber,1,5) in ('12025','12073','12074','12076','12085','12086','12095','12096')
                then substring(calledPartyNumber, 6)
                else
        (case   when substring(calledPartyNumber, 3, 2) = '00'
                then substring(calledPartyNumber, 5)
                else
        (case   when substring(calledPartyNumber, 3, 3) in ('025', '074', '095', '096')
                then substring(calledPartyNumber, 6)
                else substring(calledPartyNumber, 3) end) end) end) end) end) end as calledPartyNumber
from    mediation.ericsson
where   toYear(EventDate) = (:year)
    and toMonth(EventDate) = (:month)
    and type in  ('TRANSIT','M_S_ORIGINATING')  -- ('M_S_ORIGINATING','ROAMING_CALL_FORWARDING','TRANSIT','CALL_FORWARDING')--,'M_S_TERMINATING')
    and calledPartyNumber not like '231%'
    and length(calledPartyNumber) >7
group by EventDate,calledPartyNumber,callingPartyNumber--,chargeableDuration
order by EventDate
*/*/