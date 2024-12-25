
---Orange DATA

select
filePath path,
'zte_ggsn' data_type,
servedIMSI,
servedIMEI,
servedMSISDN,
locationAreaCode locationInfo,
accessPointNameNI,
sum(toInt32(listOfTrafficIn)) trafficIn,
sum(toInt32(listOfTrafficOut)) trafficOut,
toStartOfHour(recordOpeningTime) recordOpeningTime,
sum(toInt32(duration)) duration
from    mediation.data_zte
where   recordOpeningTime >= toDateTime(:dateFrom)
    and recordOpeningTime <= toDateTime(:dateTo)
group by recordOpeningTime,path,
        servedIMSI,
        servedIMEI,
        locationInfo,
        accessPointNameNI,
        servedMSISDN

;

select
src path,
'zte_odc' data_type,
servedIMSI,
servedIMEISV servedIMEI,
servedMSISDN,
ePCUserLocationInformation locationInfo,
accessPointNameNI,
sum(toInt32(zte_wtp.downloadAmount)) trafficIn,
sum(toInt32(zte_wtp.uploadAmount)) trafficOut,
toStartOfHour(recordOpeningTime) recordOpeningTime,
sum(toInt32(duration)) duration
from mediation.zte_wtp
where   recordOpeningTime >= toDateTime(:dateFrom)
    and recordOpeningTime <= toDateTime(:dateTo)
group by recordOpeningTime,path,
        servedIMSI,
        servedIMEI,
        locationInfo,
        accessPointNameNI,
        servedMSISDN
;

---MTN DATA

select
        filePath path,
        'ericsson' data_type,
        servedIMSI,
        servedIMEI,
        servedMSISDN,
        locationAreaCode locationInfo,
        accessPointNameNI,
        sum(toInt32(listOfTrafficIn)) trafficIn,
        sum(toInt32(listOfTrafficOut)) trafficOut,
        toStartOfHour(recordOpeningTime) recordOpeningTime,
        sum(toInt32(duration)) duration
from mediation.data_ericsson
where   recordOpeningTime >= toDateTime(:dateFrom)
    and recordOpeningTime <= toDateTime(:dateTo)
    and accessPointNameOI <> 'mnc001.mcc618.gprs'
group by recordOpeningTime,path,
        servedIMSI,
        servedIMEI,
        locationInfo,
        accessPointNameNI,
        servedMSISDN
;

select
        path path,
        'ericsson_lte' data_type,
        servedIMSI,
        servedIMEISV servedIMEI,
        servedMSISDN,
        servedPDPPDNAddress locationInfo,
        accessPointNameNI,
        sum(toInt32(dataVolumeGPRSDownLink)) trafficIn,
        sum(toInt32(dataVolumeGPRSUplink)) trafficOut,
        toStartOfHour(recordOpeningTime) recordOpeningTime,
        sum(toInt32(duration)) duration
from mediation.ericsson_lte
where   recordOpeningTime >= toDateTime(:dateFrom)
    and recordOpeningTime <= toDateTime(:dateTo)
group by recordOpeningTime,path,
        servedIMSI,
        servedIMEI,
        locationInfo,
        accessPointNameNI,
        servedMSISDN

---MTN Voice

select
        filepath,
        type,
        EventDate,
        callingPartyNumber,
        callingSubscriberIMSI,
        callingSubscriberIMEI,
        calledPartyNumber,
        calledSubscriberIMSI,
        calledSubscriberIMEI,
        mobileStationRoamingNumber,
        dateForStartOfCharge,
        timeForStartOfCharge,
        timeForStopOfCharge,
        chargeableDuration,
        originForCharging,
        mscIdentification,
        outgoingRoute,
        incomingRoute,
        firstCallingLocationInformation,
        lastCallingLocationInformation,
        mscAddress,
        networkCallReference,
        originalCalledNumber,
        redirectingNumber,
        redirectingIMSI
from mediation.ericsson
where  type in ('M_S_ORIGINATING','M_S_TERMINATING','TRANSIT','CALL_FORWARDING','ROAMING_CALL_FORWARDING')
    and EventDate >= toDateTime(:dateFrom)
    and EventDate <= toDateTime(:dateTo)
;

---Orange voice

select
        filepath,
        type,
        servedIMSI,
        servedIMEI,
        servedMSISDN,
        callingNumber,
        calledNumber,
        translatedNumber,
        connectedNumber,
        roamingNumber,
        location1,
        location2,
        location3,
        seizureTime,
        answerTime,
        releaseTime,
        callDuration,
        callReference,
        networkCallReference,
        mscAddress,
        dialledNumber,
        calledLocation,
        callingLocation,
        calledIMSI,
        incomingTKGPName,
        outgoingTKGPName,
        millisecDuration,
        transRoamingNumber,
        errorCode
from    mediation.zte
where   type in ('MO_CALL_RECORD','MT_CALL_RECORD','OUT_GATEWAY_RECORD','INC_GATEWAY_RECORD','ROAM_RECORD','MCF_CALL_RECORD')
    and eventTimeStamp >= toDateTime(:dateFrom)
    and eventTimeStamp <= toDateTime(:dateTo)



