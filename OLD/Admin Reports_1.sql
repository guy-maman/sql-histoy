--MTN--ericsson

select  case type when 'M_S_ORIGINATING' then 'Outgoing' else 'Incoming' end types
        ,substring(toString(dateForStartOfCharge), 1, 10)  || ' ' || substring(toString(timeForStartOfCharge), 12) start_date
        ,substring(toString(dateForStartOfCharge), 1, 10)  || ' ' || substring(toString(chargeableDuration), 12) end_date
        ,toUnixTimestamp(chargeableDuration) callDuration
        ,substring(callingPartyNumber,3) calling_number
        ,case when ((substring(calledPartyNumber,3)) like '025%'
                    or (substring(calledPartyNumber,3)) like '074%')
             then substring(calledPartyNumber,6)
             else substring(calledPartyNumber,3) end as called_number
        ,case  when type = 'M_S_ORIGINATING' then callingSubscriberIMEI else calledSubscriberIMEI end IMEI
from    ericsson
where   EventDate >= toDateTime(:startDate)
        and EventDate <= toDateTime(:endDate)
        and type in ('M_S_ORIGINATING', 'M_S_TERMINATING')
        and case when type = 'M_S_ORIGINATING' then callingPartyNumber like (:phoneNumber) else calledPartyNumber like (:phoneNumber) end
order by start_date

--Orange--ZTE

select  case type when 'MO_CALL_RECORD' then 'Outgoing' else 'Incoming' end types, answerTime start_date,
        releaseTime end_date, callDuration
        ,case when (substring((case when callingNumber = '' then servedMSISDN else callingNumber end),3)) like '38%'
            THEN substring((case when callingNumber = '' then servedMSISDN else callingNumber end),5)
            else substring((case when callingNumber = '' then servedMSISDN else callingNumber end),3)
            end  as calling_number
        ,substring((case when calledNumber = '' then servedMSISDN else calledNumber end),3) as called_number
        ,servedIMEI IMEI
from    mediation.zte
where   type in ('MO_CALL_RECORD', 'MT_CALL_RECORD')
        and eventTimeStamp >= toDateTime(:startDate)
        and eventTimeStamp <= toDateTime(:endDate)
        and (servedMSISDN like (:phoneNumber))
order by end_date
limit 500



---------------------------



select  rowNumberInAllBlocks() id,type,incomingRoute,outgoingRoute,mscAddress,mobileStationRoamingNumber
        ,substring(toString(dateForStartOfCharge), 1, 10)  || ' ' || substring(toString(timeForStartOfCharge), 12) start_date
        ,substring(toString(dateForStartOfCharge), 1, 10)  || ' ' || substring(toString(chargeableDuration), 12) end_date
        ,toUnixTimestamp(chargeableDuration) callDuration
        ,substring(callingPartyNumber,3) calling_number
        ,case when ((substring(calledPartyNumber,3)) like '025%'
                    or (substring(calledPartyNumber,3)) like '074%')
             then substring(calledPartyNumber,6)
             else substring(calledPartyNumber,3) end as called_number
--         ,case  when type = 'M_S_ORIGINATING' then callingSubscriberIMEI else calledSubscriberIMEI end IMEI
from    ericsson
where   EventDate >= toDateTime(:startDate)
        and EventDate <= toDateTime(:endDate)
        and (callingPartyNumber like (:phoneNumber) or calledPartyNumber like (:phoneNumber))
--         and type in ('M_S_ORIGINATING', 'M_S_TERMINATING')
--         and case when type = 'M_S_ORIGINATING' then callingPartyNumber like (:phoneNumber) else calledPartyNumber like (:phoneNumber) end
order by start_date


------Orange test calls


select  answerTime start_date,releaseTime end_date, callDuration
        ,case when (substring((case when callingNumber = '' then servedMSISDN else callingNumber end),3)) like '38%'
            THEN substring((case when callingNumber = '' then servedMSISDN else callingNumber end),5)
            else substring((case when callingNumber = '' then servedMSISDN else callingNumber end),3)
            end  as calling_number
        ,substring((case when calledNumber = '' then servedMSISDN else calledNumber end),3) as called_number
        ,outgoingTKGPName,incomingTKGPName

-- select distinct calledNumber
from    mediation.zte
where   toYear(eventTimeStamp) = (:year)
        and toMonth(eventTimeStamp) = (:month)
        and incomingTKGPName in ('OCS-SIP-LAB')
        and callDuration >0
--         and called_number not like ('077%')
--         and toDayOfMonth(eventTimeStamp) = 1
--         and (servedMSISDN like (:phoneNumber))
order by end_date
limit 1500