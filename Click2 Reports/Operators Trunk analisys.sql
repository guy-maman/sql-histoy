
/*
create table CountryCode (ind Int8,CountryCode Nullable(Int32),CountryName Nullable(String))
    ENGINE = MergeTree() order by ind;
*/
/*
create table default.trunkIndex (ind Int8,trank  Nullable(String))
    ENGINE = MergeTree() order by ind;

create table default.trunkTraffic (ind Int8,in Nullable(String),out Nullable(String),dur Int8)
    ENGINE = MergeTree() order by ind;
*/

select  'orange' Operator,'otm' Traffic_Type,toStartOfMonth(eventTimeStamp) Date,sum(callDuration)/60 Duration
from    mediation.zte
where   toYear(eventTimeStamp) = (:year)
    and toMonth(eventTimeStamp) = (:month)
    and type in ('OUT_GATEWAY_RECORD')
    and outgoingTKGPName in ('Comium', 'LoneStar', 'MSC_SBC_MTN')
group by Operator,Traffic_Type,Date

select  'orange' Operator,'intli' Traffic_Type, Date,sum(Duration)/60 Duration
from (
select  callReference,toDate(eventTimeStamp) Date,sum(callDuration) Duration
from    mediation.zte
where   toYear(eventTimeStamp) = (:year)
    and toMonth(eventTimeStamp) = (:month)
    and callDuration > 0
    and type in ('MT_CALL_RECORD','ROAM_RECORD','MCF_CALL_RECORD')
    and incomingTKGPName in ('OLIB_SBC_OFR','BARAK SIP 2','BIC_SBC_SIP','BIC_SBC_SIP_NAIROBI','BICS_SBC_SIP_NAIROBI','BICS-4193','BICS-4194',
                             'BTS_SBC_SIP','BTS_SBC_SIP OUT','BTS_SBC_SIP_IN','OCI_ASSB','OCI_KM4','Orange-12482','Orange-12490','OSL_SBC_SIP')
group by Date,callReference
)group by Date
order by Date

select  'orange' Operator,'intlo' Traffic_Type, Date,sum(Duration)/60 Duration
from (
select  callReference,toDate(eventTimeStamp) Date,sum(callDuration) Duration
from    mediation.zte
where   toYear(eventTimeStamp) = (:year)
    and toMonth(eventTimeStamp) = (:month)
    and callDuration > 0
    and type in ('MO_CALL_RECORD','ROAM_RECORD','MCF_CALL_RECORD')
    and length(calledNumber) >7
--     and roamingNumber = ''
    and outgoingTKGPName in ('OLIB_SBC_OFR','BARAK SIP 2','BIC_SBC_SIP','BIC_SBC_SIP_NAIROBI','BICS_SBC_SIP_NAIROBI','BICS-4193','BICS-4194',
                             'BTS_SBC_SIP','BTS_SBC_SIP OUT','BTS_SBC_SIP_IN','OCI_ASSB','OCI_KM4','Orange-12482','Orange-12490','OSL_SBC_SIP')
group by Date,callReference
)group by Date
order by Date

/*
create table mediation.trunkTraffic (operator Int8,trafficType Int8,trunkName Nullable(String))
    ENGINE = MergeTree() order by operator;
*/
-- CREATE MATERIALIZED VIEW mediation.zte_on_net_mv
--             TO mediation.hourly_traffic
--             (
--              `operator` UInt8,
--              `trafficType` UInt8,
--              `eventTimeStamp` DateTime,
--              `duration` UInt64
--                 )
-- AS
SELECT tI.operator                  AS operator,
       tI.trafficType                  AS trafficType,
       toStartOfDay(t.eventTimeStamp) AS eventTimeStamp,
       sum(t.callDuration)             AS duration
FROM mediation.zte t
    left join mediation.trunkTraffic tI on t.incomingTKGPName = tI.trunkName
    left join mediation.trunkTraffic tO on t.incomingTKGPName = tO.trunkName
WHERE t.type IN ('MO_CALL_RECORD')
    and toYYYYMM(t.eventTimeStamp) = 202405
    AND tI.trafficType = 1
    and tO.trafficType = 1
GROUP BY tI.operator,
         tI.trafficType,
         t.eventTimeStamp;

-- select * from mediation.trunkTraffic

select o.value, t.value, toStartOfDay(h.eventTimeStamp) tsmp, sum(h.duration)  duration
from mediation.hourly_traffic h
         join mediation.operators o on h.operator = o.operatorId
         join mediation.traffic_types t on h.trafficType = t.trafficType
where toYYYYMM(h.eventTimeStamp) = 202405 --eventTimeStamp > toStartOfDay(now())
group by o.value, t.value, tsmp
order by 1,2 ;

/*
select  * --sum(dur)
from    default.trunkTraffic t
    left join default.trunkIndex tI on t.in = tI.trank
    left join default.trunkIndex tO on t.out = tO.trank
where  tO.ind = 1
order by t.ind

;*/


-- Orange

select distinct incomingTKGPName
from zte
where toYYYYMM(eventTimeStamp) = 202405
--  outgoingTKGPName
-- incomingTKGPName

;

select  filepath,
type,
hex(callReference) callReference,
-- hex(networkCallReference) networkCallReference,
eventTimeStamp,
seizureTime,
servedMSISDN,
callingNumber,
calledNumber,
translatedNumber,
connectedNumber,
roamingNumber,
callDuration,
mscAddress,
incomingTKGPName,
outgoingTKGPName,
recordType,
-- mcfType,
servedIMSI,
servedIMEI,
msClassmark,
recordingEntity,
startTime,
endTime,
location1,
location2,
location3,
basicService,
mscIncomingTKGP,
mscOutgoingTKGP,
answerTime,
releaseTime,
diagnostics1,
isCAMELCall,
exchangeIdentity,
dialledNumber,
recordSequenceNumber,
calledLocation,
callingLocation,
mscSPC14,
mscSPC24,
calledIMSI,
forwardCallIndicator,
millisecDuration,
transRoamingNumber
from zte
where toYYYYMM(eventTimeStamp) = 202405
--     and toHour(eventTimeStamp) = 17
    and type in (
                'INC_GATEWAY_RECORD',
                'MCF_CALL_RECORD',
                'MO_CALL_RECORD',
                'MT_CALL_RECORD',
                'OUT_GATEWAY_RECORD',
                'ROAM_RECORD')
    and (incomingTKGPName in (/*'MSC_SBC_ACS',*/'MSC71_ATCF'/*,'MSC71_HQMSC11','MSC71_MGCF76','MSCS_ODC'*/)
        or outgoingTKGPName in (/*'MSC_SBC_ACS',*/'MSC71_ATCF'/*,'MSC71_HQMSC11','MSC71_MGCF76','MSCS_ODC'*/))
order by eventTimeStamp desc,callReference,callDuration
limit 1000;

select  distinct type --incomingTKGPName,outgoingTKGPName
from zte
where toYYYYMM(eventTimeStamp) = 202405
--     and toHour(eventTimeStamp) = 17
    and filepath like '%ODC%'
group by incomingTKGPName,outgoingTKGPName
;

select  filepath,
type,
hex(callReference) callReference,
-- hex(networkCallReference) networkCallReference,
answerTime,
-- eventTimeStamp,
-- seizureTime,
servedMSISDN,
callingNumber,
calledNumber,
-- translatedNumber,
-- connectedNumber,
roamingNumber,
callDuration,
-- mscAddress,
incomingTKGPName,
outgoingTKGPName,
-- recordType,
-- mcfType,
servedIMSI,
servedIMEI,
-- msClassmark,
-- recordingEntity,
-- startTime,
-- endTime,
location1,
location2,
location3,
-- basicService,
-- mscIncomingTKGP,
-- mscOutgoingTKGP,
releaseTime,
-- diagnostics1,
-- isCAMELCall,
-- exchangeIdentity,
dialledNumber,
-- recordSequenceNumber,
calledLocation,
callingLocation,
-- mscSPC14,
-- mscSPC24,
calledIMSI,
-- forwardCallIndicator,
-- millisecDuration,
transRoamingNumber
from    mediation.zte
where   toYYYYMM(eventTimeStamp) = (:yyyymm)
--     toYYYYMM(eventTimeStamp) between 202404 and 202406
        and incomingTKGPName in ('BTS_SBC_SIP_IN','BTS_SBC_SIP'/*,'MSC71_HQMSC11','MSC71_MGCF76','MSCS_ODC'*/)
--     and toHour(eventTimeStamp) = 11
--     and toMinute(eventTimeStamp) between 40 and 50
--     and filepath like '%ODC%'
--     and (servedMSISDN like '%776040702' or callingNumber like '%776040702' or calledNumber like '%776040702' or translatedNumber like '%776040702' or connectedNumber like '%776040702' or roamingNumber like '%776040702')
    and type in (
                'INC_GATEWAY_RECORD',
                'MCF_CALL_RECORD',
                'MO_CALL_RECORD',
                'MT_CALL_RECORD',
                'OUT_GATEWAY_RECORD',
                'ROAM_RECORD')
order by answerTime,callReference
limit 1000
;
select distinct outgoingTKGPName from zte
where   toYear(eventTimeStamp) = 2024
    and filepath like '%ODC%'

incomingTKGPName,
outgoingTKGPName,

""
MSC71_HQMSC11
MSC71_MGCF76
""
MSC71_HQMSC11
MSC71_MGCF76
OCS-SIP-A


'MSC_SBC_ACS'
'MSC71_ATCF'
'MSC71_HQMSC11'
'MSC71_MGCF76'
'MSCS_ODC'
--     and (servedMSISDN like '%777777922' or callingNumber like '%777777922' or calledNumber like '%777777922' or translatedNumber like '%777777922' or connectedNumber like '%777777922' or roamingNumber like '%777777922')

/*
--MTN
select
        filepath,
        type,
        networkCallReference,
        EventDate,
        callingPartyNumber,
        calledPartyNumber,
        mobileStationRoamingNumber,
        dateForStartOfCharge,
        timeForStartOfCharge,
        timeForStopOfCharge,
        chargeableDuration,
        chargedParty,
        mscIdentification,
        outgoingRoute,
        incomingRoute,
        firstCallingLocationInformation,
        lastCallingLocationInformation,
        relatedCallNumber,
        recordSequenceNumber,
        subscriptionType,
        mscAddress,
        exchangeIdentity,
        switchIdentity,
        translatedNumber,
        originalCalledNumber,
        redirectingNumber,
        gsmCallReferenceNumber
from    mediation.ericsson
where   toYear(EventDate) = (:year)
    and toMonth(EventDate) = (:month)
--     and outgoingRoute in ('BRFO', 'BRGO', 'GENO', 'L1MBC1O', 'L1MBC2O', 'L2MBC1O', 'L2MBC2O', 'ZURO')
--     and type not in ('M_S_ORIGINATING_SMS_IN_MSC','M_S_TERMINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
-- group by Date,callReference,CallingNumber,CalledNumber,RoamingNumber,CountryCodes,Route --,incomingRoute
order by EventDate,networkCallReference
limit 10000;

-- select  distinct substring(calledPartyNumber,1,5) x
select  type,
        networkCallReference,
        callingPartyNumber,
        calledPartyNumber,
        outgoingRoute,
        incomingRoute
-- select distinct incomingRoute
from    mediation.ericsson
where   toYear(EventDate) between 2023 and 2024
--     and toMonth(EventDate) = (:month)
    and (outgoingRoute = 'VIAMOI'
    or incomingRoute = 'VIAMOI')
--     and type not in ('M_S_ORIGINATING_SMS_IN_MSC','M_S_TERMINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
limit 1000;



