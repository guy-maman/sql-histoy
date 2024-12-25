/*
ALTER TABLE mediation_shard.dictionary_data ON CLUSTER liberia
UPDATE value = 'Canada'
WHERE  dictionary_name = 'COUNTRY_CODE' and id = '1204'
*/
-- select  *--distinct dictionary_name
-- from    mediation_shard.dictionary_data
-- where   dictionary_name = 'ZTE_TRUNK'
-- insert into mediation_shard.dictionary_data values ('ZTE_TRUNK','1','HWRNC2O')
/*
select distinct dictionary_name from mediation_shard.dictionary_data;
select * from mediation_shard.dictionary_data where dictionary_name = 'ZTE_TRUNK';

insert into mediation_shard.dictionary_data (dictionary_name,id,value)
    values ('ZTE_TRUNK',1,'CNSBC1I');
*/
-- GTI__SBC_SIP
-- HQMSC11_MSC71
-- OPC__SBC1_SIP
-- OPC__SBC2_SIP_PRODUCTION
-- OPC__SBC1_SIP_PRODUCTION
-- BICS_SBC_SIP_Nigeria


HUASIPI --
HUASIPO


--orange trunk check incoming
select   incomingTKGPName,mscIncomingTKGP
from    mediation.zte
where   toYear(eventTimeStamp) = (:yyyymm)
    and incomingTKGPName not in dictGet('mediation.orange_trunk_groups', 'trunks','1')
--     and outgoingTKGPName not in dictGet('mediation.orange_trunk_groups', 'trunks','1')
    and incomingTKGPName not in dictGet('mediation.orange_trunk_groups', 'trunks','7')
--     and outgoingTKGPName not in dictGet('mediation.orange_trunk_groups', 'trunks','7')
    and incomingTKGPName not in dictGet('mediation.orange_trunk_groups', 'trunks','8')
--     and outgoingTKGPName not in dictGet('mediation.orange_trunk_groups', 'trunks','8')
    and incomingTKGPName not in dictGet('mediation.orange_trunk_groups', 'trunks','9')
--     and outgoingTKGPName not in dictGet('mediation.orange_trunk_groups', 'trunks','9')
    and incomingTKGPName not in dictGet('mediation.orange_trunk_groups', 'trunks','10')
--     and outgoingTKGPName not in dictGet('mediation.orange_trunk_groups', 'trunks','10')
group by incomingTKGPName,mscIncomingTKGP;


--orange trunk check outgoing
select   outgoingTKGPName,mscOutgoingTKGP
from    mediation.zte
where   toYear(eventTimeStamp) = (:yyyymm)
--     and incomingTKGPName not in dictGet('mediation.orange_trunk_groups', 'trunks','1')
    and outgoingTKGPName not in dictGet('mediation.orange_trunk_groups', 'trunks','1')
--     and incomingTKGPName not in dictGet('mediation.orange_trunk_groups', 'trunks','7')
    and outgoingTKGPName not in dictGet('mediation.orange_trunk_groups', 'trunks','7')
--     and incomingTKGPName not in dictGet('mediation.orange_trunk_groups', 'trunks','8')
    and outgoingTKGPName not in dictGet('mediation.orange_trunk_groups', 'trunks','8')
--     and incomingTKGPName not in dictGet('mediation.orange_trunk_groups', 'trunks','9')
    and outgoingTKGPName not in dictGet('mediation.orange_trunk_groups', 'trunks','9')
--     and incomingTKGPName not in dictGet('mediation.orange_trunk_groups', 'trunks','10')
    and outgoingTKGPName not in dictGet('mediation.orange_trunk_groups', 'trunks','10')
group by outgoingTKGPName,mscOutgoingTKGP;

-----------MTN

-- mtn trunk check incoming
select   incomingRoute--,outgoingRoute
from    mediation.ericsson
where   toYear(EventDate) = (:yyyymm)
    and incomingRoute not in dictGet('mediation.mtn_trunk_groups', 'trunks','1')
--     and outgoingRoute not in dictGet('mediation.mtn_trunk_groups', 'trunks','1')
    and incomingRoute not in dictGet('mediation.mtn_trunk_groups', 'trunks','7')
--     and outgoingRoute not in dictGet('mediation.mtn_trunk_groups', 'trunks','7')
    and incomingRoute not in dictGet('mediation.mtn_trunk_groups', 'trunks','8')
--     and outgoingRoute not in dictGet('mediation.mtn_trunk_groups', 'trunks','8')
    and incomingRoute not in dictGet('mediation.mtn_trunk_groups', 'trunks','9')
--     and outgoingRoute not in dictGet('mediation.mtn_trunk_groups', 'trunks','9')
    and incomingRoute not in dictGet('mediation.mtn_trunk_groups', 'trunks','10')
--     and outgoingRoute not in dictGet('mediation.mtn_trunk_groups', 'trunks','10')
group by incomingRoute;--,outgoingRoute;

-- mtn trunk check outgoing
select   outgoingRoute
from    mediation.ericsson
where   toYear(EventDate) = (:yyyymm)
--     and incomingRoute not in dictGet('mediation.mtn_trunk_groups', 'trunks','1')
    and outgoingRoute not in dictGet('mediation.mtn_trunk_groups', 'trunks','1')
--     and incomingRoute not in dictGet('mediation.mtn_trunk_groups', 'trunks','7')
    and outgoingRoute not in dictGet('mediation.mtn_trunk_groups', 'trunks','7')
--     and incomingRoute not in dictGet('mediation.mtn_trunk_groups', 'trunks','8')
    and outgoingRoute not in dictGet('mediation.mtn_trunk_groups', 'trunks','8')
--     and incomingRoute not in dictGet('mediation.mtn_trunk_groups', 'trunks','9')
    and outgoingRoute not in dictGet('mediation.mtn_trunk_groups', 'trunks','9')
--     and incomingRoute not in dictGet('mediation.mtn_trunk_groups', 'trunks','10')
    and outgoingRoute not in dictGet('mediation.mtn_trunk_groups', 'trunks','10')
group by outgoingRoute;

--MTN trunk CDR check
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
-- select sum(toUnixTimestamp(chargeableDuration))/60
from    mediation.ericsson
where   toYYYYMM(EventDate) = (:yyyymm)
    and outgoingRoute in ('HUASIPI') --('BC2CNSI','CNSBC2I','HWBSC2I','HWBSC2O','HWRNC2I','HWRNC2O')
    or incomingRoute in ('HUASIPI') --('BC2CNSI','CNSBC2I','HWBSC2I','HWBSC2O','HWRNC2I','HWRNC2O')
    and type not in ('M_S_ORIGINATING_SMS_IN_MSC','M_S_TERMINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
--     and networkCallReference = '789253193731'
-- group by Date,callReference,CallingNumber,CalledNumber,RoamingNumber,CountryCodes,Route --,incomingRoute
-- order by EventDate,networkCallReference
limit 500;
-- 636481634306
0
BC1CNSI
HUASIPI --
CNSBC1I
HUASIPO

-- orange trunk CDR check
select
        filepath,
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
from    mediation.zte
where toYear(eventTimeStamp) = (:yyyymm)
--     and toHour(eventTimeStamp) = 17
    and type in ('INC_GATEWAY_RECORD','MCF_CALL_RECORD','MO_CALL_RECORD','MT_CALL_RECORD','OUT_GATEWAY_RECORD','ROAM_RECORD')
    and (incomingTKGPName in (/*'MSC_SBC_ACS',*/'GTI__SBC_SIP'/*,'MSC71_HQMSC11','MSC71_MGCF76','MSCS_ODC'*/)
        or outgoingTKGPName in (/*'MSC_SBC_ACS',*/'GTI__SBC_SIP'/*,'MSC71_HQMSC11','MSC71_MGCF76','MSCS_ODC'*/))
--     and callDuration >0
-- order by eventTimeStamp desc,callReference,callDuration
limit 1000;

select sum(callDuration)/60 callDuration
from (
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
        or  outgoingRoute in ('HUASIPO'))
    and type not in ('M_S_ORIGINATING_SMS_IN_MSC','M_S_TERMINATING_SMS_IN_MSC', 'S_S_PROCEDURE')
group by Date,callReference,CallingNumber,CalledNumber,RoamingNumber,CountryCode,Route,CountryName--,calledPartyNumber--callDuration,,callingPartyNumber
order by Date,CallingNumber,CalledNumber))